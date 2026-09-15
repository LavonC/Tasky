import { Router } from 'express';
const router = Router();

export default function performanceRoutes(pool) {
  // GET /api/pm/employee-performance/:id/work-logs
  router.get('/:id/work-logs', async (req, res) => {
    try {
      const { id: userId } = req.params;
      
      const [submissions] = await pool.query(
        `SELECT c.*, DATE_FORMAT(c.log_date, '%Y-%m-%d') as log_date
         FROM daily_log_compliance c
         WHERE c.user_id = ?
         ORDER BY c.log_date DESC
         LIMIT 30`,
        [userId]
      );
      
      const submissionsWithLogs = [];
      const logsByDate = {};
      
      for (let sub of submissions) {
        const [logs] = await pool.query(
          `SELECT d.*, t.title as task_title 
           FROM daily_work_log d LEFT JOIN task t ON d.task_id = t.id 
           WHERE d.user_id = ? AND DATE(d.log_date) = ?`,
          [userId, sub.log_date]
        );
        submissionsWithLogs.push({ ...sub, logs });
        logsByDate[sub.log_date] = logs;
      }
      
      res.json({ success: true, submissions: submissionsWithLogs, logsByDate });
    } catch (error) {
      console.error('Error fetching work logs:', error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  });

  // GET /api/pm/employee-performance/:id
  router.get('/:id', async (req, res) => {
    try {
      const { id: userId } = req.params;

      const [taskStats] = await pool.query(
        `SELECT
          COUNT(*) AS totalTasks,
          SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) AS completedTasks,
          SUM(CASE WHEN t.status NOT IN ('completed') AND t.deadline < CURDATE() THEN 1 ELSE 0 END) AS overdueTasks
        FROM task t JOIN task_assignment ta ON t.id = ta.task_id
        WHERE ta.user_id = ? AND ta.is_active = 1`,
        [userId]
      );

      const [logStats] = await pool.query(
        `SELECT SUM(hours_spent) as hoursLogged FROM daily_work_log WHERE user_id = ?`,
        [userId]
      );

      const [statusStats] = await pool.query(
        `SELECT t.status, COUNT(*) as count 
         FROM task t JOIN task_assignment ta ON t.id = ta.task_id 
         WHERE ta.user_id = ? AND ta.is_active = 1 
         GROUP BY t.status`,
        [userId]
      );

      const taskStatusObj = {};
      statusStats.forEach(row => {
        taskStatusObj[row.status] = row.count;
      });

      const [recentTasks] = await pool.query(
        `SELECT t.id, t.title, t.status, p.name as project_name 
         FROM task t 
         JOIN task_assignment ta ON t.id = ta.task_id 
         JOIN project p ON t.project_id = p.id 
         WHERE ta.user_id = ? AND ta.is_active = 1 
         ORDER BY t.created_at DESC LIMIT 5`,
        [userId]
      );

      const [weeklyProgressRaw] = await pool.query(
        `SELECT DATE_FORMAT(log_date, '%x-%v') as week, SUM(hours_spent) as hours
         FROM daily_work_log
         WHERE user_id = ? AND log_date >= DATE_SUB(CURDATE(), INTERVAL 8 WEEK)
         GROUP BY week
         ORDER BY week ASC`,
        [userId]
      );

      const tStats = taskStats[0] || { totalTasks: 0, completedTasks: 0, overdueTasks: 0 };
      const hoursLogged = logStats[0]?.hoursLogged || 0;
      
      let overallScore = 0;
      if (tStats.totalTasks > 0) {
        overallScore = Math.round((tStats.completedTasks / tStats.totalTasks) * 100);
      } else {
        overallScore = 100;
      }

      res.json({
        success: true,
        performance: {
          totalTasks: tStats.totalTasks,
          completedTasks: tStats.completedTasks,
          overdueTasks: tStats.overdueTasks,
          hoursLogged: hoursLogged,
          overallScore: overallScore,
          utilization: 80,
          taskStats: taskStatusObj,
          recentTasks,
          weeklyProgress: weeklyProgressRaw.map(wp => ({ week: wp.week, hours: Number(wp.hours) }))
        }
      });
    } catch (error) {
      console.error('Error fetching employee performance:', error);
      res.status(500).json({ success: false, message: 'Server error' });
    }
  });

  return router;
}
