-- ============================================================
-- LEAVE IMPACT TEST DATA
-- ============================================================
-- This file contains the schema and test data to test the leave impact feature
-- Run this SQL to set up the database for testing
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- RELEVANT SCHEMA TABLES FOR LEAVE IMPACT TESTING
-- ============================================================

-- USER TABLE (if not exists)
CREATE TABLE IF NOT EXISTS `user` (
  `id`              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `org_id`          INT UNSIGNED     NOT NULL,
  `role_id`         INT UNSIGNED     NOT NULL,
  `employee_code`   VARCHAR(30)      NOT NULL,
  `first_name`      VARCHAR(100)     NOT NULL,
  `last_name`       VARCHAR(100)     NOT NULL,
  `email`           VARCHAR(255)     NOT NULL,
  `password_hash`   VARCHAR(255)     NOT NULL,
  `avatar_url`      VARCHAR(500)     DEFAULT NULL,
  `phone`           VARCHAR(20)      DEFAULT NULL,
  `skills`          JSON             DEFAULT NULL,
  `max_hours_per_week` DECIMAL(5,2)  NOT NULL DEFAULT 40.00,
  `is_active`       TINYINT(1)       NOT NULL DEFAULT 1,
  `last_login_at`   DATETIME         DEFAULT NULL,
  `created_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_email` (`email`),
  UNIQUE KEY `uq_user_emp_code` (`org_id`, `employee_code`),
  INDEX `idx_user_org` (`org_id`),
  INDEX `idx_user_role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- PROJECT TABLE (if not exists)
CREATE TABLE IF NOT EXISTS `project` (
  `id`              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `org_id`          INT UNSIGNED     NOT NULL,
  `created_by`      INT UNSIGNED     NOT NULL,
  `name`            VARCHAR(255)     NOT NULL,
  `description`     TEXT             DEFAULT NULL,
  `status`          ENUM('planning','active','on-hold','completed','archived') NOT NULL DEFAULT 'planning',
  `priority`        ENUM('critical','high','medium','low') NOT NULL DEFAULT 'medium',
  `color`           VARCHAR(7)       DEFAULT '#1976D2',
  `start_date`      DATE             NOT NULL,
  `end_date`        DATE             NOT NULL,
  `progress`        DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `created_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_project_org` (`org_id`),
  INDEX `idx_project_status` (`status`),
  INDEX `idx_project_priority` (`priority`),
  INDEX `idx_project_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- TASK TABLE (if not exists)
CREATE TABLE IF NOT EXISTS `task` (
  `id`              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `project_id`      INT UNSIGNED     NOT NULL,
  `phase_id`        INT UNSIGNED     DEFAULT NULL,
  `created_by`      INT UNSIGNED     NOT NULL,
  `title`           VARCHAR(300)     NOT NULL,
  `description`     TEXT             DEFAULT NULL,
  `status`          ENUM('not-started','in-progress','completed','blocked','on-hold','in-review') NOT NULL DEFAULT 'not-started',
  `priority`        ENUM('critical','high','medium','low') NOT NULL DEFAULT 'medium',
  `deadline`        DATE             NOT NULL,
  `start_date`      DATE             DEFAULT NULL,
  `expected_effort` DECIMAL(7,2)     NOT NULL DEFAULT 0.00,
  `actual_effort`   DECIMAL(7,2)     NOT NULL DEFAULT 0.00,
  `progress`        DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `risk_status`     ENUM('on-track','at-risk','delayed','completed') NOT NULL DEFAULT 'on-track',
  `is_self_assigned` TINYINT(1)      NOT NULL DEFAULT 0,
  `delay_reason`    TEXT             DEFAULT NULL,
  `delay_flagged_at` DATETIME        DEFAULT NULL,
  `completed_at`    DATETIME         DEFAULT NULL,
  `created_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_task_project` (`project_id`),
  INDEX `idx_task_phase` (`phase_id`),
  INDEX `idx_task_status` (`status`),
  INDEX `idx_task_priority` (`priority`),
  INDEX `idx_task_deadline` (`deadline`),
  INDEX `idx_task_risk` (`risk_status`),
  INDEX `idx_task_created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- TASK ASSIGNMENT TABLE (if not exists)
CREATE TABLE IF NOT EXISTS `task_assignment` (
  `id`              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `task_id`         INT UNSIGNED     NOT NULL,
  `user_id`         INT UNSIGNED     NOT NULL,
  `assigned_by`     INT UNSIGNED     NOT NULL,
  `assigned_at`     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `unassigned_at`   DATETIME         DEFAULT NULL,
  `is_active`       TINYINT(1)       NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_active_assignment` (`task_id`, `user_id`, `is_active`),
  INDEX `idx_assignment_user` (`user_id`),
  INDEX `idx_assignment_task` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- DAILY LOG COMPLIANCE TABLE (if not exists)
CREATE TABLE IF NOT EXISTS `daily_log_compliance` (
  `id`              INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `user_id`         INT UNSIGNED     NOT NULL,
  `log_date`        DATE             NOT NULL,
  `status`          ENUM('not-required','draft','submitted','reviewed','approved','rejected') NOT NULL DEFAULT 'draft',
  `day_status`      ENUM('worked','leave','holiday','weekend','no-entry') DEFAULT 'worked',
  `reminder_sent_at` DATETIME         DEFAULT NULL,
  `warning_shown`   TINYINT(1)       NOT NULL DEFAULT 0,
  `warning_acknowledged_at` DATETIME DEFAULT NULL,
  `submitted_at`    DATETIME         DEFAULT NULL,
  `created_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_daily_log` (`user_id`, `log_date`),
  INDEX `idx_compliance_user` (`user_id`),
  INDEX `idx_compliance_date` (`log_date`),
  INDEX `idx_compliance_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- TEST DATA FOR LEAVE IMPACT FEATURE
-- ============================================================

-- 1. Organization (if needed)
INSERT IGNORE INTO `organization` (`id`, `name`, `domain`) VALUES
(1, 'Test Organization', 'test.com');

-- 2. Role (if needed)
INSERT IGNORE INTO `role` (`id`, `org_id`, `name`, `access_level`) VALUES
(1, 1, 'Employee', 'employee');

-- 3. Test User (Employee)
-- Password: password123 (hashed)
INSERT IGNORE INTO `user` (`id`, `org_id`, `role_id`, `employee_code`, `first_name`, `last_name`, `email`, `password_hash`) VALUES
(36, 1, 1, 'EMP007', 'Test', 'Employee', 'test@tasky.com', '$2b$10$rKJQZzQXZzZzZzZzZzZzZeXZzZzZzZzZzZzZzZzZzZzZzZzZzZzZ');

-- 4. Test Project
INSERT IGNORE INTO `project` (`id`, `org_id`, `created_by`, `name`, `description`, `status`, `priority`, `start_date`, `end_date`) VALUES
(4, 1, 36, 'E-Commerce Platform Redesign', 'Redesign the e-commerce platform', 'active', 'critical', '2024-01-01', '2026-12-31');

-- 5. Test Task with deadline on a leave date
INSERT IGNORE INTO `task` (`id`, `project_id`, `created_by`, `title`, `description`, `status`, `priority`, `deadline`, `progress`, `is_self_assigned`) VALUES
(59, 4, 36, 'Load Balancer Configuration', 'Configured Nginx load balancer for high availability', 'not-started', 'critical', '2026-09-17', 0.00, 1);

-- 6. Task Assignment (assign task to employee)
INSERT IGNORE INTO `task_assignment` (`task_id`, `user_id`, `assigned_by`, `is_active`) VALUES
(59, 36, 36, 1);

-- 7. Mark a date as Leave in daily_log_compliance
-- This date (2026-09-17) matches the task deadline
INSERT IGNORE INTO `daily_log_compliance` (`user_id`, `log_date`, `status`, `day_status`) VALUES
(36, '2026-09-17', 'not-required', 'leave');

-- ============================================================
-- ALTERNATIVE TEST DATA (different date)
-- ============================================================

-- If you want to test with a different date, use this instead:
-- Change task deadline to 2026-09-20
-- UPDATE `task` SET `deadline` = '2026-09-20' WHERE `id` = 59;

-- Mark 2026-09-20 as leave
-- INSERT IGNORE INTO `daily_log_compliance` (`user_id`, `log_date`, `status`, `day_status`) VALUES
-- (36, '2026-09-20', 'not-required', 'leave');

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check if user exists
-- SELECT * FROM `user` WHERE `id` = 36;

-- Check if task exists with deadline
-- SELECT id, title, deadline FROM `task` WHERE `id` = 59;

-- Check if task is assigned to user
-- SELECT * FROM `task_assignment` WHERE `task_id` = 59 AND `user_id` = 36;

-- Check if leave date is marked
-- SELECT * FROM `daily_log_compliance` WHERE `user_id` = 36 AND `log_date` = '2026-09-17';

-- ============================================================
-- TEST INSTRUCTIONS
-- ============================================================
-- 1. Run this SQL file in your MySQL database
-- 2. Login to the application with:
--    - Email: test@tasky.com
--    - Password: password123
-- 3. Go to Planner
-- 4. Navigate to September 2026
-- 5. You should see:
--    - 17 Sep marked as "Leave"
--    - "Leave Impact" indicator
-- 6. Click on "Leave Impact" to open the dialog
-- 7. The dialog should show "Load Balancer Configuration" task
-- 8. The dialog should show "⚠️ Task deadline falls on your leave"
-- 9. Go to Task Manager
-- 10. The task should show:
--     - Red progress bar
--     - "🔴 Leave affected — 17 Sep 2026" indicator

SET FOREIGN_KEY_CHECKS = 1;
