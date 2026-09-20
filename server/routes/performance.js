import { Router } from 'express';

const VALID_RANGES = new Set(['this_week', 'this_month', 'last_3_months']);
const PRIORITIES = ['critical', 'high', 'medium', 'low'];
const PROJECT_COLORS = ['#1976D2', '#21BA45', '#C10015', '#F2C037', '#26A69A', '#9C27B0'];

function formatDate(date) {
  return date.toISOString().slice(0, 10);
}

function addDays(date, days) {
  const result = new Date(date);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
}

function getRange(range) {
  const today = new Date();
  const current = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate()));
  let start;
  let end;

  if (range === 'this_week') {
    const day = current.getUTCDay() || 7;
    start = addDays(current, 1 - day);
    end = addDays(start, 7);
  } else if (range === 'last_3_months') {
    start = new Date(Date.UTC(current.getUTCFullYear(), current.getUTCMonth() - 2, 1));
    end = new Date(Date.UTC(current.getUTCFullYear(), current.getUTCMonth() + 1, 1));
  } else {
    start = new Date(Date.UTC(current.getUTCFullYear(), current.getUTCMonth(), 1));
    end = new Date(Date.UTC(current.getUTCFullYear(), current.getUTCMonth() + 1, 1));
  }

  const durationDays = Math.max(1, Math.round((end - start) / 86400000));
  return {
    start: formatDate(start),
    end: formatDate(end),
    durationDays,
    startDate: start,
    endDate: end,
  };
}

function number(value) {
  return Number(value || 0);
}

function percentage(numerator, denominator) {
  return denominator ? Number(((numerator / denominator) * 100).toFixed(1)) : 0;
}

function getBucketIndex(value, range, bucketCount) {
  const date = new Date(value);
  const index = Math.floor((date - range.startDate) / (7 * 86400000));
  return Math.max(0, Math.min(bucketCount - 1, index));
}

async function calculatePerformance(pool, userId, rangeName) {
  const range = getRange(rangeName);
  const [users] = await pool.query(
    "SELECT max_hours_per_week FROM user WHERE id = ? AND application_role = 'employee'",
    [userId],
  );

  if (!users.length) {
    const error = new Error('Employee not found');
    error.status = 404;
    throw error;
  }

  const [tasks] = await pool.query(
    `SELECT t.id, t.title, t.status, t.priority, t.deadline, t.expected_effort,
            t.completed_at, t.created_at, p.name AS project_name, p.color AS project_color,
            ta.assigned_at
     FROM task t
     JOIN task_assignment ta ON ta.task_id = t.id
       AND ta.user_id = ? AND ta.is_active = 1
       AND ta.assigned_at < ?
       AND (ta.unassigned_at IS NULL OR ta.unassigned_at >= ?)
     LEFT JOIN project p ON p.id = t.project_id
     ORDER BY t.created_at DESC`,
    [userId, range.end, range.start],
  );

  const [logs] = await pool.query(
    `SELECT dwl.log_date, dwl.hours_spent, dwl.task_id, p.name AS project_name,
            p.color AS project_color
     FROM daily_work_log dwl
     LEFT JOIN task t ON t.id = dwl.task_id
     LEFT JOIN project p ON p.id = t.project_id
     WHERE dwl.user_id = ? AND dwl.log_date >= ? AND dwl.log_date < ?`,
    [userId, range.start, range.end],
  );

  const [activityRows] = await pool.query(
    `SELECT activity_date, COUNT(*) AS activity_count
     FROM (
       SELECT log_date AS activity_date FROM daily_work_log
       WHERE user_id = ? AND log_date >= ? AND log_date < ?
       UNION ALL
       SELECT DATE(created_at) AS activity_date FROM progress_update
       WHERE user_id = ? AND created_at >= ? AND created_at < ?
       UNION ALL
       SELECT log_date AS activity_date FROM daily_log_compliance
       WHERE user_id = ? AND log_date >= ? AND log_date < ?
         AND status IN ('logged', 'late', 'submitted', 'reviewed')
     ) activities
     GROUP BY activity_date ORDER BY activity_date`,
    [userId, range.start, range.end, userId, range.start, range.end, userId, range.start, range.end],
  );

  const [reviews] = await pool.query(
    `SELECT tr.task_id, tr.status
     FROM task_review tr
     JOIN task_assignment ta ON ta.task_id = tr.task_id
       AND ta.user_id = ? AND ta.is_active = 1
     WHERE tr.task_owner_id = ? AND tr.submitted_at >= ? AND tr.submitted_at < ?`,
    [userId, userId, range.start, range.end],
  );

  const totalTasks = tasks.length;
  const completedTasks = tasks.filter((task) => task.status === 'completed').length;
  const inProgressTasks = tasks.filter((task) => task.status === 'in-progress').length;
  const notStartedTasks = tasks.filter((task) => task.status === 'not-started').length;
  const overdueTasks = tasks.filter(
    (task) => task.status !== 'completed' && new Date(task.deadline) < new Date(),
  ).length;
  const onTimeCompleted = tasks.filter(
    (task) => task.status === 'completed' && task.completed_at && new Date(task.completed_at) <= new Date(task.deadline),
  ).length;
  const hoursLogged = logs.reduce((sum, log) => sum + number(log.hours_spent), 0);
  const estimatedHours = tasks.reduce((sum, task) => sum + number(task.expected_effort), 0);
  const remainingHours = Math.max(0, estimatedHours - hoursLogged);
  const weeksInRange = Math.max(1, range.durationDays / 7);
  const capacityHours = number(users[0].max_hours_per_week) * weeksInRange;
  // Utilization is logged hours divided by the employee's configured weekly capacity for this period.
  const utilization = percentage(hoursLogged, capacityHours);
  const completedEstimatedHours = tasks
  .filter((task) => task.status === 'completed')
  .reduce(
    (sum, task) => sum + number(task.expected_effort),
    0,
  );

// Workload completion = completed estimated work / total assigned estimated work.
const efficiency = estimatedHours
  ? Number(
      ((completedEstimatedHours / estimatedHours) * 100).toFixed(1),
    )
  : null;
  const completionRate = percentage(completedTasks, totalTasks);
  const onTimeRate = percentage(onTimeCompleted, completedTasks);
  // Productivity combines completion rate and on-time rate from assigned tasks.
  const productivityScore = totalTasks ? Number(((completionRate + onTimeRate) / 2).toFixed(1)) : null;
  // Focus is the share of weekdays with recorded activity in the selected period.
  const weekdays = Array.from({ length: range.durationDays }, (_, index) => addDays(range.startDate, index))
    .filter((date) => date.getUTCDay() > 0 && date.getUTCDay() < 6).length;
  const activeWeekdays = activityRows.filter((row) => {
    const day = new Date(row.activity_date).getUTCDay();
    return day > 0 && day < 6;
  }).length;
  const focusScore = percentage(activeWeekdays, weekdays);

  const reviewByTask = new Map();
  reviews.forEach((review) => {
    const existing = reviewByTask.get(review.task_id) || [];
    existing.push(review.status);
    reviewByTask.set(review.task_id, existing);
  });
  const reviewedTasks = [...reviewByTask.values()].filter((statuses) =>
    statuses.some((status) => ['review-done', 'finalized'].includes(status)),
  );
  const firstTimeTasks = reviewedTasks.filter(
    (statuses) => !statuses.includes('changes-requested'),
  ).length;

  const qualityMetrics = {
    reopenedTasks: null,
    revisionRequests: reviews.filter((review) => review.status === 'changes-requested').length,
    firstTimeCompletionRate: percentage(firstTimeTasks, reviewedTasks.length),
    avgSubtaskAccuracy: null,
  };

  const priorityPerformance = PRIORITIES.map((priority) => {
    const priorityTasks = tasks.filter((task) => task.priority === priority);
    const completed = priorityTasks.filter((task) => task.status === 'completed');
    const delayed = priorityTasks.filter(
      (task) => task.status !== 'completed' && new Date(task.deadline) < new Date(),
    );
    const completionDays = completed
      .filter((task) => task.completed_at && task.assigned_at)
      .map((task) => (new Date(task.completed_at) - new Date(task.assigned_at)) / 86400000);
    return {
      priority,
      completed: completed.length,
      delayed: delayed.length,
      completionRate: percentage(completed.length, priorityTasks.length),
      avgCompletionTime: completionDays.length
        ? Number((completionDays.reduce((sum, days) => sum + days, 0) / completionDays.length).toFixed(1))
        : null,
    };
  });

  const allocation = new Map();
  logs.forEach((log) => {
    const label = log.project_name || 'General work';
    const existing = allocation.get(label) || {
      label,
      value: 0,
      color: log.project_color || PROJECT_COLORS[allocation.size % PROJECT_COLORS.length],
    };
    existing.value += number(log.hours_spent);
    allocation.set(label, existing);
  });
  const totalAllocatedHours = [...allocation.values()].reduce((sum, item) => sum + item.value, 0);
  const timeAllocation = [...allocation.values()].map((item) => ({
    ...item,
    value: Number(item.value.toFixed(2)),
    percentage: percentage(item.value, totalAllocatedHours),
  }));

  const bucketCount = rangeName === 'this_week' ? 1 : rangeName === 'this_month' ? 5 : 13;
  const weeklyProgress = Array.from({ length: bucketCount }, (_, index) => ({
    week: `Week ${index + 1}`,
    assigned: 0,
    completed: 0,
    delayed: 0,
  }));
  tasks.forEach((task) => {
    if (new Date(task.assigned_at) >= range.startDate && new Date(task.assigned_at) < range.endDate) {
      weeklyProgress[getBucketIndex(task.assigned_at, range, bucketCount)].assigned += 1;
    }
    if (task.completed_at && new Date(task.completed_at) >= range.startDate && new Date(task.completed_at) < range.endDate) {
      weeklyProgress[getBucketIndex(task.completed_at, range, bucketCount)].completed += 1;
    }
    if (task.status !== 'completed' && new Date(task.deadline) >= range.startDate && new Date(task.deadline) < range.endDate) {
      weeklyProgress[getBucketIndex(task.deadline, range, bucketCount)].delayed += 1;
    }
  });

  return {
    overallScore: productivityScore,
    productivityScore,
    completionRate,
    onTimeRate,
    focusScore,
    efficiency,
    totalTasks,
    completedTasks,
    inProgressTasks,
    notStartedTasks,
    overdueTasks,
    hoursLogged: Number(hoursLogged.toFixed(2)),
    estimatedHours: Number(estimatedHours.toFixed(2)),
    remainingHours: Number(remainingHours.toFixed(2)),
    utilization,
    weeklyProgress,
    timeAllocation,
    dailyActivity: Array.from({ length: range.durationDays }, (_, index) => {
      const date = formatDate(addDays(range.startDate, index));
      const activity = activityRows.find((row) => formatDate(new Date(row.activity_date)) === date);
      return { activity_date: date, activity_count: activity ? number(activity.activity_count) : 0 };
    }),
    qualityMetrics,
    priorityPerformance,
    recentTasks: tasks.slice(0, 5).map((task) => ({
      id: task.id,
      title: task.title,
      status: task.status,
      priority: task.priority,
      project_name: task.project_name,
    })),
  };
}

function validateRange(req, res) {
  const range = req.query.range || 'this_month';
  if (!VALID_RANGES.has(range)) {
    res.status(400).json({ success: false, error: 'Invalid range. Use this_week, this_month, or last_3_months.' });
    return null;
  }
  return range;
}

function sendPerformance(pool, getUserId) {
  return async (req, res) => {
    const range = validateRange(req, res);
    if (!range) return;
    try {
      const performance = await calculatePerformance(pool, getUserId(req), range);
      res.json({ success: true, performance });
    } catch (error) {
      console.error('Error fetching employee performance:', error);
      res.status(error.status || 500).json({ success: false, error: error.status ? error.message : 'Server error' });
    }
  };
}

export default function performanceRoutes(pool) {
  const router = Router();

  router.get('/:id/work-logs', async (req, res) => {
    try {
      const [submissions] = await pool.query(
        `SELECT c.*, DATE_FORMAT(c.log_date, '%Y-%m-%d') AS log_date
         FROM daily_log_compliance c WHERE c.user_id = ?
         ORDER BY c.log_date DESC LIMIT 30`,
        [req.params.id],
      );
      const logsByDate = {};
      for (const submission of submissions) {
        const [logs] = await pool.query(
          `SELECT d.*, t.title AS task_title FROM daily_work_log d
           LEFT JOIN task t ON d.task_id = t.id
           WHERE d.user_id = ? AND DATE(d.log_date) = ?`,
          [req.params.id, submission.log_date],
        );
        logsByDate[submission.log_date] = logs;
        submission.logs = logs;
      }
      res.json({ success: true, submissions, logsByDate });
    } catch (error) {
      console.error('Error fetching work logs:', error);
      res.status(500).json({ success: false, error: 'Server error' });
    }
  });

  router.get('/:id', sendPerformance(pool, (req) => req.params.id));
  return router;
}

export function employeePerformanceRoutes(pool) {
  const router = Router();
  router.get('/', sendPerformance(pool, (req) => req.user.id));
  return router;
}