import { Router } from 'express';
import {
  recommendResources,
  analyzeImpact,
  getOrgResourceWorkloads,
} from '../services/schedulingEngine.js';

const router = Router();

export default function schedulingRoutes(pool) {
  // POST /api/pm/schedule/auto-assign
  router.post('/auto-assign', async (req, res) => {
    try {
      const orgId = req.user.org_id;
      const pmId = req.user.id;
      const { task_id } = req.body;

      if (!task_id) {
        return res.status(400).json({ success: false, error: 'Task ID is required' });
      }

      // Check task exists and isn't completed
      const [tasks] = await pool.execute('SELECT * FROM task WHERE id = ?', [task_id]);
      if (tasks.length === 0)
        return res.status(404).json({ success: false, error: 'Task not found' });
      if (tasks[0].status === 'completed')
        return res.status(400).json({ success: false, error: 'Cannot assign completed task' });

      // Run recommendation engine
      const recommendations = await recommendResources(pool, orgId, task_id);

      if (recommendations.length === 0) {
        return res.json({ success: false, message: 'No suitable resources found' });
      }

      // Take the top recommendation
      const bestResource = recommendations[0];

      // Assign them
      await pool.execute(
        `
        INSERT INTO task_assignment (task_id, user_id, assigned_by)
        VALUES (?, ?, ?)
      `,
        [task_id, bestResource.user_id, pmId],
      );

      // Return success with details
      res.json({
        success: true,
        message: `Successfully auto-assigned to ${bestResource.name}`,
        assignedResource: bestResource,
      });
    } catch (error) {
      console.error('Auto-assign error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/pm/schedule/recommend-preview
  router.post('/recommend-preview', async (req, res) => {
    try {
      const orgId = req.user.org_id;
      const { project_id, title, description } = req.body;

      const resources = await getOrgResourceWorkloads(pool, orgId);

      // Get project involvement: users with active tasks in this specific project
      let projectUserIds = new Set();
      if (project_id) {
        const [projectAssignments] = await pool.execute(
          `SELECT DISTINCT ta.user_id
           FROM task_assignment ta
           JOIN task t ON t.id = ta.task_id
           WHERE t.project_id = ? AND ta.is_active = 1`,
          [project_id]
        );
        projectAssignments.forEach((a) => projectUserIds.add(a.user_id));
      }

      // Build keyword set from task title + description for skill matching
      const taskText = `${title || ''} ${description || ''}`.toLowerCase();

      const scored = resources.map((r) => {
        let score = 0;

        // 1. Capacity score (0-40): lower utilization = higher score
        const capacityScore = Math.max(0, 40 - r.utilization * 0.4);
        score += capacityScore;

        // 2. Project involvement (0-15): already working on this project
        const isOnProject = projectUserIds.has(r.user_id);
        score += isOnProject ? 15 : 0;

        // 3. Task load score (0-15): fewer active tasks = higher score
        const taskLoadScore = Math.max(0, 15 - r.active_task_count * 2.5);
        score += taskLoadScore;

        // 4. Skill match (0-20): match user skills against task keywords
        let skillScore = 0;
        if (r.skills && taskText.length > 0) {
          const userSkills = (typeof r.skills === 'string'
            ? r.skills.split(',')
            : Array.isArray(r.skills) ? r.skills : []
          ).map((s) => s.trim().toLowerCase());
          const matches = userSkills.filter((skill) => skill && taskText.includes(skill));
          skillScore = Math.min(20, matches.length * 7);
        }
        score += skillScore;

        return {
          id: r.user_id,
          name: `${r.first_name} ${r.last_name}`,
          employee_code: r.employee_code,
          role_name: r.role_name,
          avatar: r.avatar,
          utilization: r.utilization,
          active_task_count: r.active_task_count,
          workload_status: r.workload_status,
          score: Math.round(score * 100) / 100,
          _rand: Math.random(),
          reasons: [
            `Capacity: ${Math.round(100 - r.utilization)}% available`,
            `Current tasks: ${r.active_task_count}`,
            ...(isOnProject ? ['Already involved in this project'] : []),
            ...(skillScore > 0 ? [`Skill match score: ${skillScore}`] : []),
          ],
        };
      }).sort((a, b) => {
        if (b.score !== a.score) return b.score - a.score;
        return b._rand - a._rand;
      });

      res.json({ success: true, recommendations: scored });
    } catch (error) {
      console.error('Preview error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/pm/schedule/rebalance
  router.post('/rebalance', async (req, res) => {
    try {
      // In a real advanced system this would re-distribute tasks based on capacity
      // For now, it returns suggestions on who should be unassigned and who should take over
      const orgId = req.user.org_id;
      const { project_id } = req.body;

      if (!project_id)
        return res.status(400).json({ success: false, error: 'Project ID is required' });

      // Identify overloaded resources working on this project
      const allResources = await getOrgResourceWorkloads(pool, orgId);
      const overloaded = allResources.filter((r) => r.utilization > 100);

      const suggestions = [];

      for (const r of overloaded) {
        // Find their tasks in this project
        const [tasks] = await pool.execute(
          `
          SELECT t.* FROM task t
          JOIN task_assignment ta ON ta.task_id = t.id AND ta.is_active = 1
          WHERE t.project_id = ? AND ta.user_id = ? AND t.status IN ('not-started','in-progress')
        `,
          [project_id, r.user_id],
        );

        if (tasks.length > 0) {
          // For their largest task, find an alternative resource
          const largestTask = tasks.sort((a, b) => b.expected_effort - a.expected_effort)[0];
          const alternates = await recommendResources(pool, orgId, largestTask.id);

          // Filter out other overloaded resources
          const viableAlternates = alternates.filter((alt) => alt.utilization < 90);

          if (viableAlternates.length > 0) {
            suggestions.push({
              action: 'reassign',
              task: { id: largestTask.id, title: largestTask.title },
              from: {
                id: r.user_id,
                name: `${r.first_name} ${r.last_name}`,
                utilization: r.utilization,
              },
              to: {
                id: viableAlternates[0].user_id,
                name: viableAlternates[0].name,
                new_utilization:
                  viableAlternates[0].utilization +
                  (largestTask.expected_effort / viableAlternates[0].max_hours_per_week) * 100,
              },
              reason: `To reduce ${r.first_name}'s overload (${r.utilization}%).`,
            });
          }
        }
      }

      res.json({ success: true, suggestions });
    } catch (error) {
      console.error('Rebalance error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/pm/schedule/impact-analysis
  router.post('/impact-analysis', async (req, res) => {
    try {
      const { task_id, delay_days } = req.body;

      if (!task_id) return res.status(400).json({ success: false, error: 'Task ID is required' });

      const impact = await analyzeImpact(pool, task_id, parseInt(delay_days) || 0);

      res.json({ success: true, impact });
    } catch (error) {
      console.error('Impact analysis error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/pm/schedule/suggestions
  router.get('/suggestions', async (req, res) => {
    try {
      const pmId = req.user.id;

      // Fetch AI/Rule-based suggestions stored in the DB (or generated on the fly)
      // The seed data has a table for this, let's just fetch from there
      const [suggestions] = await pool.execute(
        `
        SELECT * FROM ai_suggestion
        WHERE project_id IN (SELECT id FROM project WHERE created_by = ?)
        ORDER BY created_at DESC
        LIMIT 10
      `,
        [pmId],
      );

      res.json({ success: true, suggestions });
    } catch (error) {
      console.error('Get suggestions error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/pm/schedule/queue
  router.get('/queue', async (req, res) => {
    try {
      const orgId = req.user.org_id;
      const [events] = await pool.execute(
        `SELECT * FROM reschedule_event WHERE org_id = ? AND status = 'pending_review' ORDER BY created_at DESC`,
        [orgId]
      );
      res.json({ success: true, events });
    } catch (error) {
      console.error('Queue error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/pm/schedule/queue/:eventId/confirm
  router.post('/queue/:eventId/confirm', async (req, res) => {
    try {
      const { applyRescheduleProposal } = await import('../services/schedulingEngine.js');
      const pmId = req.user.id;
      const result = await applyRescheduleProposal(pool, req.params.eventId, pmId);
      res.json(result);
    } catch (error) {
      console.error('Confirm error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/pm/schedule/queue/:eventId/reject
  router.post('/queue/:eventId/reject', async (req, res) => {
    try {
      await pool.execute(
        `UPDATE reschedule_event SET status = 'pm_rejected', reviewed_at = NOW() WHERE id = ?`,
        [req.params.eventId]
      );
      res.json({ success: true });
    } catch (error) {
      console.error('Reject error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/pm/schedule/trigger-reschedule
  router.post('/trigger-reschedule', async (req, res) => {
    try {
      const { buildRescheduleProposal } = await import('../services/schedulingEngine.js');
      const orgId = req.user.org_id;
      // Get all active users
      const [users] = await pool.execute('SELECT id FROM user WHERE org_id = ? AND is_active = 1', [orgId]);
      const userIds = users.map(u => u.id);
      const proposal = await buildRescheduleProposal(pool, orgId, 'manual', null, userIds);
      res.json({ success: true, proposal });
    } catch (error) {
      console.error('Trigger error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/pm/schedule/task/:taskId/history
  router.get('/task/:taskId/history', async (req, res) => {
    try {
      const [history] = await pool.execute(
        `SELECT * FROM task_schedule_history WHERE task_id = ? ORDER BY created_at DESC`,
        [req.params.taskId]
      );
      res.json({ success: true, history });
    } catch (error) {
      console.error('History error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/pm/schedule/timeline
  router.get('/timeline', async (req, res) => {
    try {
      const orgId = req.user.org_id;
      const [tasks] = await pool.execute(
        `SELECT t.*, p.name as project_name, u.first_name, u.last_name 
         FROM task t
         JOIN project p ON t.project_id = p.id
         LEFT JOIN task_assignment ta ON t.id = ta.task_id AND ta.is_active = 1
         LEFT JOIN user u ON ta.user_id = u.id
         WHERE p.org_id = ? AND t.status != 'completed'
         ORDER BY t.urgency_score DESC, t.deadline ASC`,
        [orgId]
      );
      res.json({ success: true, tasks });
    } catch (error) {
      console.error('Timeline error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  return router;
}
