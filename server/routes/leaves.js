import { Router } from 'express';
import { handleLeaveApproval } from '../services/schedulingEngine.js';

const router = Router();

export default function leavesRoutes(pool) {
  // GET /api/leaves
  router.get('/', async (req, res) => {
    try {
      const orgId = req.user.org_id;
      const [leaves] = await pool.execute(
        `SELECT lr.*, u.first_name, u.last_name 
         FROM leave_request lr
         JOIN user u ON lr.user_id = u.id
         WHERE u.org_id = ?
         ORDER BY lr.created_at DESC`,
        [orgId]
      );
      res.json({ success: true, leaves });
    } catch (error) {
      console.error('Get leaves error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/leaves
  router.post('/', async (req, res) => {
    try {
      const userId = req.user.id;
      const { start_date, end_date, type, reason } = req.body;
      
      const [result] = await pool.execute(
        `INSERT INTO leave_request (user_id, start_date, end_date, type, reason, status)
         VALUES (?, ?, ?, ?, ?, 'pending')`,
        [userId, start_date, end_date, type, reason]
      );
      
      res.json({ success: true, leave_id: result.insertId });
    } catch (error) {
      console.error('Create leave error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // PUT /api/pm/leaves/:id/approve (Assuming mounted at /api/pm/leaves in server.js)
  router.put('/:id/approve', async (req, res) => {
    try {
      const leaveId = req.params.id;
      const pmId = req.user.id;

      await pool.execute(
        `UPDATE leave_request SET status = 'approved', approved_by = ?, updated_at = NOW() WHERE id = ?`,
        [pmId, leaveId]
      );

      await handleLeaveApproval(pool, leaveId);

      res.json({ success: true });
    } catch (error) {
      console.error('Approve leave error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/employee/leaves - Get employee's own approved leaves
  router.get('/employee/:userId', async (req, res) => {
    try {
      const userId = parseInt(req.params.userId);
      const [leaves] = await pool.execute(
        `SELECT * FROM leave_request 
         WHERE user_id = ? AND status = 'approved' 
         ORDER BY start_date ASC`,
        [userId]
      );
      res.json({ success: true, leaves });
    } catch (error) {
      console.error('Get employee leaves error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/employee/leave-impact - Get tasks affected by leave periods
  router.get('/employee/:userId/impact', async (req, res) => {
    try {
      const userId = parseInt(req.params.userId);

      // Get approved leaves from leave_request table
      const [leaves] = await pool.execute(
        `SELECT * FROM leave_request
         WHERE user_id = ? AND status = 'approved'
         ORDER BY start_date ASC`,
        [userId]
      );

      // Get manually marked leave days from daily_log_compliance
      const [manualLeaves] = await pool.execute(
        `SELECT log_date as start_date, log_date as end_date, 'manual' as type, 'approved' as status
         FROM daily_log_compliance
         WHERE user_id = ? AND day_status = 'leave'
         ORDER BY log_date ASC`,
        [userId]
      );

      // Combine both leave sources
      const allLeaves = [...leaves, ...manualLeaves];

      console.log('=== LEAVE IMPACT DETECTION ===');
      console.log('User ID:', userId);
      console.log('Approved leaves from leave_request:', leaves.length);
      console.log('Manual leaves from daily_log_compliance:', manualLeaves.length);
      console.log('Total leaves to check:', allLeaves.length);

      // Get all tasks assigned to the employee
      const [tasks] = await pool.execute(
        `SELECT t.*, ta.assigned_at
         FROM task t
         JOIN task_assignment ta ON t.id = ta.task_id
         WHERE ta.user_id = ? AND ta.is_active = 1
         AND t.status NOT IN ('completed', 'in-review')`,
        [userId]
      );

      console.log('Total tasks to check:', tasks.length);

      const affectedTasks = [];

      for (const task of tasks) {
        const taskDeadline = new Date(task.deadline);

        // Extract date string (YYYY-MM-DD) for comparison
        const taskDeadlineDate = taskDeadline.toISOString().split('T')[0];

        for (const leave of allLeaves) {
          const leaveStart = new Date(leave.start_date);
          const leaveEnd = new Date(leave.end_date);

          // Extract leave date strings
          const leaveStartDate = leaveStart.toISOString().split('T')[0];
          const leaveEndDate = leaveEnd.toISOString().split('T')[0];

          // Check if task deadline falls on leave date (exact match or within range)
          const deadlineOnLeave = taskDeadlineDate >= leaveStartDate && taskDeadlineDate <= leaveEndDate;

          if (deadlineOnLeave) {
            console.log('Affected task found:', task.title, 'deadline:', taskDeadlineDate, 'leave range:', leaveStartDate, 'to', leaveEndDate);
            affectedTasks.push({
              ...task,
              deadline_on_leave: true,
              leave_start: leave.start_date,
              leave_end: leave.end_date,
              leave_type: leave.leave_type || 'manual'
            });
            break; // Only add once per task
          }
        }
      }

      console.log('Total affected tasks:', affectedTasks.length);
      res.json({ success: true, affected_tasks: affectedTasks, leaves: allLeaves });
    } catch (error) {
      console.error('Get leave impact error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // GET /api/employee/tasks/:taskId/deadline-on-leave - Check if task deadline falls on leave
  router.get('/employee/:userId/tasks/:taskId/deadline-on-leave', async (req, res) => {
    try {
      const userId = parseInt(req.params.userId);
      const taskId = parseInt(req.params.taskId);

      // Get approved leaves for the employee
      const [leaves] = await pool.execute(
        `SELECT * FROM leave_request
         WHERE user_id = ? AND status = 'approved'
         ORDER BY start_date ASC`,
        [userId]
      );

      // Get manually marked leave days from daily_log_compliance
      const [manualLeaves] = await pool.execute(
        `SELECT log_date as start_date, log_date as end_date
         FROM daily_log_compliance
         WHERE user_id = ? AND day_status = 'leave'
         ORDER BY log_date ASC`,
        [userId]
      );

      // Combine both leave sources
      const allLeaves = [...leaves, ...manualLeaves];

      // Get task deadline
      const [tasks] = await pool.execute(
        `SELECT deadline FROM task WHERE id = ?`,
        [taskId]
      );

      if (tasks.length === 0) {
        return res.json({ success: false, error: 'Task not found' });
      }

      const taskDeadline = new Date(tasks[0].deadline);

      for (const leave of allLeaves) {
        const leaveStart = new Date(leave.start_date);
        const leaveEnd = new Date(leave.end_date);

        if (taskDeadline >= leaveStart && taskDeadline <= leaveEnd) {
          return res.json({
            success: true,
            deadline_on_leave: true,
            leave: leave
          });
        }
      }

      res.json({ success: true, deadline_on_leave: false });
    } catch (error) {
      console.error('Check deadline on leave error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  // POST /api/employee/tasks/:taskId/automate-deadline - Calculate next valid working day
  router.post('/employee/:userId/tasks/:taskId/automate-deadline', async (req, res) => {
    try {
      const userId = parseInt(req.params.userId);
      const taskId = parseInt(req.params.taskId);

      // Get approved leaves for the employee
      const [leaves] = await pool.execute(
        `SELECT * FROM leave_request
         WHERE user_id = ? AND status = 'approved'
         ORDER BY start_date ASC`,
        [userId]
      );

      // Get manually marked leave days from daily_log_compliance
      const [manualLeaves] = await pool.execute(
        `SELECT log_date as start_date, log_date as end_date
         FROM daily_log_compliance
         WHERE user_id = ? AND day_status = 'leave'
         ORDER BY log_date ASC`,
        [userId]
      );

      // Combine both leave sources
      const allLeaves = [...leaves, ...manualLeaves];

      // Get current task deadline
      const [tasks] = await pool.execute(
        `SELECT deadline FROM task WHERE id = ?`,
        [taskId]
      );

      if (tasks.length === 0) {
        return res.json({ success: false, error: 'Task not found' });
      }

      let newDeadline = new Date(tasks[0].deadline);
      newDeadline.setDate(newDeadline.getDate() + 1); // Start from next day

      // Find next valid working day (not on leave, not weekend)
      let foundValidDate = false;
      let attempts = 0;
      const maxAttempts = 30; // Prevent infinite loop

      while (!foundValidDate && attempts < maxAttempts) {
        const dayOfWeek = newDeadline.getDay();
        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6; // 0 = Sunday, 6 = Saturday

        let isOnLeave = false;
        for (const leave of allLeaves) {
          const leaveStart = new Date(leave.start_date);
          const leaveEnd = new Date(leave.end_date);
          if (newDeadline >= leaveStart && newDeadline <= leaveEnd) {
            isOnLeave = true;
            break;
          }
        }

        if (!isWeekend && !isOnLeave) {
          foundValidDate = true;
        } else {
          newDeadline.setDate(newDeadline.getDate() + 1);
        }

        attempts++;
      }

      if (!foundValidDate) {
        return res.json({ success: false, error: 'Could not find valid working day within 30 days' });
      }

      // Update task deadline
      await pool.execute(
        `UPDATE task SET deadline = ? WHERE id = ?`,
        [newDeadline.toISOString().split('T')[0], taskId]
      );

      res.json({
        success: true,
        new_deadline: newDeadline.toISOString().split('T')[0]
      });
    } catch (error) {
      console.error('Automate deadline error:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  return router;
}
