-- ============================================================
-- QUICK LEAVE IMPACT TEST DATA
-- ============================================================
-- Minimal data to test leave impact feature
-- Run this after your existing schema is set up
-- ============================================================

-- 1. Mark 2026-09-17 as Leave for user 36
INSERT IGNORE INTO `daily_log_compliance` (`user_id`, `log_date`, `status`, `day_status`)
VALUES (36, '2026-09-17', 'not-required', 'leave');

-- 2. Verify the leave date is set
SELECT * FROM `daily_log_compliance`
WHERE `user_id` = 36 AND `log_date` = '2026-09-17';

-- 3. The task "Load Balancer Configuration" (id: 59) already has deadline 2026-09-17
-- and is assigned to user 36, so it should be detected as affected

-- ============================================================
-- TEST STEPS:
-- ============================================================
-- 1. Login as EMP007 (password: password123)
-- 2. Go to Planner
-- 3. Navigate to September 2026
-- 4. Click on "Leave Impact" under 17 Sep
-- 5. Dialog should open showing affected task
-- 6. Go to Task Manager
-- 7. Task should show red progress bar and "Leave affected" indicator
