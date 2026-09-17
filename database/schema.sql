-- ============================================================
-- TASKY -- Smart Project Task Management & Resource Scheduling
-- MySQL Database Schema v2.0 (Consolidated & Corrected)
-- ============================================================
-- Engine  : InnoDB
-- Charset : utf8mb4
-- All columns required by the application are defined here directly.
-- No ALTER TABLE migrations needed after this file.
-- Run schema.sql FIRST, then seed.sql.
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- DROP TABLES (reverse FK dependency order)
-- ============================================================
DROP TABLE IF EXISTS `audit_log`;
DROP TABLE IF EXISTS `ai_suggestion`;
DROP TABLE IF EXISTS `pm_settings`;
DROP TABLE IF EXISTS `daily_tracker`;
DROP TABLE IF EXISTS `daily_log_compliance`;
DROP TABLE IF EXISTS `task_review`;
DROP TABLE IF EXISTS `progress_update`;
DROP TABLE IF EXISTS `daily_work_log`;
DROP TABLE IF EXISTS `task_comment`;
DROP TABLE IF EXISTS `task_assignment`;
DROP TABLE IF EXISTS `task_dependency`;
DROP TABLE IF EXISTS `subtask`;
DROP TABLE IF EXISTS `task`;
DROP TABLE IF EXISTS `project_phase`;
DROP TABLE IF EXISTS `workspace_invite`;
DROP TABLE IF EXISTS `project_member`;
DROP TABLE IF EXISTS `project`;
DROP TABLE IF EXISTS `leave_request`;
DROP TABLE IF EXISTS `employee_availability`;
DROP TABLE IF EXISTS `notification`;
DROP TABLE IF EXISTS `invite_code`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS `role`;
DROP TABLE IF EXISTS `organization`;

-- ============================================================
-- 1. ORGANIZATION
-- ============================================================
CREATE TABLE `organization` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(200)  NOT NULL,
  `domain`     VARCHAR(100)  DEFAULT NULL COMMENT 'e.g. acme.com',
  `logo_url`   VARCHAR(500)  DEFAULT NULL,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_org_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 2. ROLE
-- ============================================================
CREATE TABLE `role` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `org_id`       INT UNSIGNED NOT NULL,
  `name`         VARCHAR(100) NOT NULL COMMENT 'e.g. Senior Developer, QA Engineer',
  `description`  TEXT         DEFAULT NULL,
  `access_level` ENUM('admin','manager','employee') NOT NULL DEFAULT 'employee',
  `is_active`    TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_role_org_name` (`org_id`, `name`),
  CONSTRAINT `fk_role_org` FOREIGN KEY (`org_id`) REFERENCES `organization` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 3. USER
-- ============================================================
-- All application columns included here -- no ALTER TABLE needed.
CREATE TABLE `user` (
  `id`                      INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `org_id`                  INT UNSIGNED  NOT NULL,
  `role_id`                 INT UNSIGNED  NOT NULL,
  `employee_code`           VARCHAR(30)   NOT NULL COMMENT 'Internal employee ID e.g. EMP-001',
  `first_name`              VARCHAR(100)  NOT NULL,
  `last_name`               VARCHAR(100)  NOT NULL,
  `email`                   VARCHAR(255)  NOT NULL,
  `password_hash`           VARCHAR(255)  NOT NULL,
  `avatar`                  VARCHAR(512)  DEFAULT NULL COMMENT 'Profile picture URL (short form used by API)',
  `avatar_url`              VARCHAR(500)  DEFAULT NULL COMMENT 'Full profile picture URL',
  `phone`                   VARCHAR(20)   DEFAULT NULL,
  `professional_role`       VARCHAR(50)   DEFAULT NULL COMMENT 'developer|designer|qa_engineer|business_analyst|devops|other',
  `professional_role_other` VARCHAR(100)  DEFAULT NULL COMMENT 'Custom role when professional_role = other',
  `application_role`        ENUM('employee','project_manager') DEFAULT NULL,
  `skills`                  JSON          DEFAULT NULL COMMENT '["Vue.js","TypeScript","Node.js"]',
  `max_hours_per_week`      DECIMAL(5,2)  NOT NULL DEFAULT 40.00,
  `points`                  INT           NOT NULL DEFAULT 0 COMMENT 'Gamification points',
  `is_active`               TINYINT(1)    NOT NULL DEFAULT 1,
  `last_login_at`           DATETIME      DEFAULT NULL,
  `created_at`              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_email`    (`email`),
  UNIQUE KEY `uq_user_emp_code` (`org_id`, `employee_code`),
  INDEX `idx_user_org`          (`org_id`),
  INDEX `idx_user_role`         (`role_id`),
  INDEX `idx_user_app_role`     (`application_role`),
  CONSTRAINT `fk_user_org`  FOREIGN KEY (`org_id`)  REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 4. INVITE CODE
-- ============================================================
CREATE TABLE `invite_code` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `org_id`       INT UNSIGNED NOT NULL,
  `code`         VARCHAR(50)  NOT NULL,
  `created_by`   INT UNSIGNED NOT NULL COMMENT 'PM who generated the code',
  `max_uses`     INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0 = unlimited',
  `current_uses` INT UNSIGNED NOT NULL DEFAULT 0,
  `is_active`    TINYINT(1)   NOT NULL DEFAULT 1,
  `expires_at`   DATETIME     NOT NULL,
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_invite_code`  (`code`),
  INDEX `idx_invite_org`       (`org_id`),
  INDEX `idx_invite_active`    (`is_active`, `org_id`),
  CONSTRAINT `fk_invite_org`     FOREIGN KEY (`org_id`)     REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_invite_creator` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 5. NOTIFICATION
-- ============================================================
CREATE TABLE `notification` (
  `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`        INT UNSIGNED NOT NULL COMMENT 'Recipient',
  `type`           ENUM('task_assigned','task_status_changed','deadline_approaching',
                        'deadline_missed','risk_alert','comment_added','ai_suggestion',
                        'delay_reason_required','daily_log_reminder','daily_log_warning',
                        'leave_approved','leave_rejected','general') NOT NULL DEFAULT 'general',
  `title`          VARCHAR(255) NOT NULL,
  `message`        TEXT         NOT NULL,
  `reference_type` ENUM('task','project','user','leave_request') DEFAULT NULL,
  `reference_id`   INT UNSIGNED DEFAULT NULL,
  `is_read`        TINYINT(1)   NOT NULL DEFAULT 0,
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_notif_user`    (`user_id`),
  INDEX `idx_notif_read`    (`user_id`, `is_read`),
  INDEX `idx_notif_type`    (`type`),
  INDEX `idx_notif_created` (`created_at`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 6. EMPLOYEE AVAILABILITY
-- ============================================================
CREATE TABLE `employee_availability` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`         INT UNSIGNED NOT NULL,
  `date`            DATE         NOT NULL,
  `is_available`    TINYINT(1)   NOT NULL DEFAULT 1,
  `available_hours` DECIMAL(4,2) NOT NULL DEFAULT 8.00,
  `day_type`        ENUM('weekday','weekend','holiday','leave') NOT NULL DEFAULT 'weekday',
  `notes`           VARCHAR(500) DEFAULT NULL,
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_availability` (`user_id`, `date`),
  INDEX `idx_avail_date` (`date`),
  CONSTRAINT `fk_avail_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 7. LEAVE REQUEST
-- ============================================================
CREATE TABLE `leave_request` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED NOT NULL,
  `approved_by` INT UNSIGNED DEFAULT NULL,
  `leave_type`  ENUM('casual','sick','planned','half-day','other') NOT NULL DEFAULT 'casual',
  `start_date`  DATE         NOT NULL,
  `end_date`    DATE         NOT NULL,
  `reason`      TEXT         DEFAULT NULL,
  `status`      ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_leave_user`   (`user_id`),
  INDEX `idx_leave_status` (`status`),
  INDEX `idx_leave_dates`  (`start_date`, `end_date`),
  CONSTRAINT `fk_leave_user`     FOREIGN KEY (`user_id`)     REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_leave_approver` FOREIGN KEY (`approved_by`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 8. PROJECT
-- ============================================================
CREATE TABLE `project` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `org_id`      INT UNSIGNED NOT NULL,
  `created_by`  INT UNSIGNED NOT NULL COMMENT 'PM who created the project',
  `name`        VARCHAR(255) NOT NULL,
  `description` TEXT         DEFAULT NULL,
  `status`      ENUM('planning','active','on-hold','completed','archived') NOT NULL DEFAULT 'planning',
  `priority`    ENUM('critical','high','medium','low') NOT NULL DEFAULT 'medium',
  `color`       VARCHAR(7)   DEFAULT '#1976D2',
  `start_date`  DATE         NOT NULL,
  `end_date`    DATE         NOT NULL,
  `progress`    DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_project_org`        (`org_id`),
  INDEX `idx_project_status`     (`status`),
  INDEX `idx_project_priority`   (`priority`),
  INDEX `idx_project_created_by` (`created_by`),
  CONSTRAINT `fk_project_org`     FOREIGN KEY (`org_id`)     REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_project_creator` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 9. PROJECT MEMBER
-- ============================================================
CREATE TABLE `project_member` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id` INT UNSIGNED NOT NULL,
  `user_id`    INT UNSIGNED NOT NULL,
  `added_by`   INT UNSIGNED NOT NULL,
  `joined_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_project_member` (`project_id`, `user_id`),
  CONSTRAINT `fk_member_project`  FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_member_user`     FOREIGN KEY (`user_id`)    REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_member_added_by` FOREIGN KEY (`added_by`)   REFERENCES `user` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 10. WORKSPACE INVITE
-- ============================================================
CREATE TABLE `workspace_invite` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `org_id`      INT UNSIGNED NOT NULL,
  `project_id`  INT UNSIGNED DEFAULT NULL,
  `email`       VARCHAR(255) DEFAULT NULL,
  `invite_code` VARCHAR(40)  NOT NULL,
  `invited_by`  INT UNSIGNED NOT NULL,
  `accepted_by` INT UNSIGNED DEFAULT NULL,
  `expires_at`  DATETIME     NOT NULL,
  `accepted_at` DATETIME     DEFAULT NULL,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_workspace_invite_code` (`invite_code`),
  INDEX `idx_wi_org` (`org_id`),
  CONSTRAINT `fk_wi_org`      FOREIGN KEY (`org_id`)      REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wi_project`  FOREIGN KEY (`project_id`)  REFERENCES `project` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_wi_inviter`  FOREIGN KEY (`invited_by`)  REFERENCES `user` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_wi_accepter` FOREIGN KEY (`accepted_by`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 11. PROJECT PHASE
-- ============================================================
CREATE TABLE `project_phase` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id`  INT UNSIGNED NOT NULL,
  `name`        VARCHAR(200) NOT NULL,
  `description` TEXT         DEFAULT NULL,
  `sort_order`  INT UNSIGNED NOT NULL DEFAULT 0,
  `start_date`  DATE         DEFAULT NULL,
  `end_date`    DATE         DEFAULT NULL,
  `status`      ENUM('pending','in-progress','completed') NOT NULL DEFAULT 'pending',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_phase_project` (`project_id`),
  CONSTRAINT `fk_phase_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 12. TASK
-- ============================================================
-- All application columns included directly -- no ALTER TABLE needed.
CREATE TABLE `task` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `project_id`       INT UNSIGNED NOT NULL,
  `phase_id`         INT UNSIGNED DEFAULT NULL,
  `created_by`       INT UNSIGNED NOT NULL,
  `title`            VARCHAR(300) NOT NULL,
  `description`      TEXT         DEFAULT NULL,
  `status`           ENUM('not-started','in-progress','completed','blocked','on-hold','in-review') NOT NULL DEFAULT 'not-started',
  `priority`         ENUM('critical','high','medium','low') NOT NULL DEFAULT 'medium',
  `deadline`         DATE         NOT NULL,
  `start_date`       DATE         DEFAULT NULL,
  `expected_effort`  DECIMAL(7,2) NOT NULL DEFAULT 0.00 COMMENT 'Estimated hours',
  `actual_effort`    DECIMAL(7,2) NOT NULL DEFAULT 0.00 COMMENT 'Sum of logged hours',
  `progress`         DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `risk_status`      ENUM('on-track','at-risk','delayed','completed') NOT NULL DEFAULT 'on-track',
  `is_self_assigned` TINYINT(1)   NOT NULL DEFAULT 0,
  `is_visible`       TINYINT(1)   NOT NULL DEFAULT 1 COMMENT 'Task visibility to employees',
  `resources_needed` INT          NOT NULL DEFAULT 1,
  `delay_reason`     TEXT         DEFAULT NULL,
  `delay_flagged_at` DATETIME     DEFAULT NULL,
  `completed_at`     DATETIME     DEFAULT NULL,
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_task_project`    (`project_id`),
  INDEX `idx_task_phase`      (`phase_id`),
  INDEX `idx_task_status`     (`status`),
  INDEX `idx_task_priority`   (`priority`),
  INDEX `idx_task_deadline`   (`deadline`),
  INDEX `idx_task_risk`       (`risk_status`),
  INDEX `idx_task_created_by` (`created_by`),
  INDEX `idx_task_visibility` (`is_visible`),
  CONSTRAINT `fk_task_project` FOREIGN KEY (`project_id`) REFERENCES `project` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_task_phase`   FOREIGN KEY (`phase_id`)   REFERENCES `project_phase` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_task_creator` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 13. SUBTASK
-- ============================================================
CREATE TABLE `subtask` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`         INT UNSIGNED NOT NULL,
  `title`           VARCHAR(255) NOT NULL,
  `status`          ENUM('not-started','in-progress','completed') DEFAULT 'not-started',
  `completed`       TINYINT(1)   DEFAULT 0,
  `progress`        DECIMAL(5,2) DEFAULT 0.00,
  `estimated_hours` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `created_at`      DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_subtask_task` (`task_id`),
  CONSTRAINT `fk_subtask_task` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 14. TASK DEPENDENCY
-- ============================================================
CREATE TABLE `task_dependency` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`         INT UNSIGNED NOT NULL COMMENT 'Successor (dependent) task',
  `depends_on_id`   INT UNSIGNED NOT NULL COMMENT 'Predecessor task',
  `dependency_type` ENUM('finish-to-start','start-to-start','finish-to-finish','start-to-finish') NOT NULL DEFAULT 'finish-to-start',
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_task_dep` (`task_id`, `depends_on_id`),
  INDEX `idx_dep_depends_on` (`depends_on_id`),
  CONSTRAINT `fk_dep_task`       FOREIGN KEY (`task_id`)       REFERENCES `task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dep_depends_on` FOREIGN KEY (`depends_on_id`) REFERENCES `task` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 15. TASK ASSIGNMENT
-- ============================================================
CREATE TABLE `task_assignment` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`       INT UNSIGNED NOT NULL,
  `user_id`       INT UNSIGNED NOT NULL,
  `assigned_by`   INT UNSIGNED NOT NULL,
  `assigned_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `unassigned_at` DATETIME     DEFAULT NULL,
  `is_active`     TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_active_assignment` (`task_id`, `user_id`, `is_active`),
  INDEX `idx_assignment_user` (`user_id`),
  INDEX `idx_assignment_task` (`task_id`),
  CONSTRAINT `fk_assignment_task`     FOREIGN KEY (`task_id`)     REFERENCES `task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignment_user`     FOREIGN KEY (`user_id`)     REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignment_assigner` FOREIGN KEY (`assigned_by`) REFERENCES `user` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 16. DAILY WORK LOG
-- ============================================================
-- task_id is nullable to support general (non-task) log entries.
CREATE TABLE `daily_work_log` (
  `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`        INT UNSIGNED DEFAULT NULL COMMENT 'NULL for general log entries',
  `user_id`        INT UNSIGNED NOT NULL,
  `log_date`       DATE         NOT NULL,
  `status`         ENUM('completed','partially-completed','in-progress','blocked','in-review') NOT NULL DEFAULT 'in-progress',
  `work_completed` TEXT         NOT NULL,
  `remaining_work` TEXT         DEFAULT NULL,
  `comments`       TEXT         DEFAULT NULL,
  `hours_spent`    DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_log_per_day` (`task_id`, `user_id`, `log_date`),
  INDEX `idx_log_user` (`user_id`),
  INDEX `idx_log_date` (`log_date`),
  CONSTRAINT `fk_log_task` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_log_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 17. PROGRESS UPDATE
-- ============================================================
CREATE TABLE `progress_update` (
  `id`                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`           INT UNSIGNED NOT NULL,
  `user_id`           INT UNSIGNED NOT NULL,
  `previous_progress` DECIMAL(5,2) NOT NULL,
  `new_progress`      DECIMAL(5,2) NOT NULL,
  `notes`             TEXT         DEFAULT NULL,
  `created_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_progress_task` (`task_id`),
  INDEX `idx_progress_user` (`user_id`),
  INDEX `idx_progress_date` (`created_at`),
  CONSTRAINT `fk_progress_task` FOREIGN KEY (`task_id`) REFERENCES `task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_progress_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 18. TASK COMMENT
-- ============================================================
CREATE TABLE `task_comment` (
  `id`                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`           INT UNSIGNED NOT NULL,
  `user_id`           INT UNSIGNED NOT NULL,
  `parent_comment_id` INT UNSIGNED DEFAULT NULL,
  `content`           TEXT         NOT NULL,
  `is_sticky`         TINYINT(1)   NOT NULL DEFAULT 0,
  `created_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_comment_task`   (`task_id`),
  INDEX `idx_comment_user`   (`user_id`),
  INDEX `idx_comment_parent` (`parent_comment_id`),
  CONSTRAINT `fk_comment_task`   FOREIGN KEY (`task_id`)           REFERENCES `task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_user`   FOREIGN KEY (`user_id`)           REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_comment_id`) REFERENCES `task_comment` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 19. TASK REVIEW
-- ============================================================
CREATE TABLE `task_review` (
  `id`                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `task_id`            INT UNSIGNED NOT NULL,
  `task_owner_id`      INT UNSIGNED NOT NULL,
  `reviewer_id`        INT UNSIGNED NOT NULL,
  `completion_comment` TEXT         DEFAULT NULL,
  `review_comment`     TEXT         DEFAULT NULL,
  `pm_final_comment`   TEXT         DEFAULT NULL,
  `status`             ENUM('pending','review-done','finalized','changes-requested') DEFAULT 'pending',
  `submitted_at`       DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `completed_at`       DATETIME     DEFAULT NULL,
  `task_owner_points`  INT          DEFAULT 0,
  `reviewer_points`    INT          DEFAULT 0,
  `finalized_at`       DATETIME     DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_review_task`     (`task_id`),
  INDEX `idx_review_owner`    (`task_owner_id`),
  INDEX `idx_review_reviewer` (`reviewer_id`),
  INDEX `idx_review_status`   (`status`),
  CONSTRAINT `fk_review_task`     FOREIGN KEY (`task_id`)       REFERENCES `task` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_owner`    FOREIGN KEY (`task_owner_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_review_reviewer` FOREIGN KEY (`reviewer_id`)   REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 20. DAILY LOG COMPLIANCE
-- ============================================================
-- Consolidated: merges both original versions.
-- status covers employee view (logged/missed/late/not-required)
-- AND PM workflow (submitted/reviewed).
CREATE TABLE `daily_log_compliance` (
  `id`                      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                 INT UNSIGNED NOT NULL,
  `log_date`                DATE         NOT NULL,
  `status`                  ENUM('logged','missed','late','not-required','submitted','reviewed') NOT NULL DEFAULT 'missed',
  `day_status`              ENUM('worked','leave','holiday','weekend','no-entry') DEFAULT 'worked',
  `pm_comment`              TEXT         DEFAULT NULL,
  `reviewed_by`             INT UNSIGNED DEFAULT NULL,
  `reviewed_at`             DATETIME     DEFAULT NULL,
  `reminder_sent_at`        DATETIME     DEFAULT NULL,
  `warning_shown`           TINYINT(1)   NOT NULL DEFAULT 0,
  `warning_acknowledged_at` DATETIME     DEFAULT NULL,
  `submitted_at`            DATETIME     DEFAULT NULL,
  `created_at`              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_compliance_user_date` (`user_id`, `log_date`),
  INDEX `idx_compliance_status` (`status`),
  INDEX `idx_compliance_date`   (`log_date`),
  CONSTRAINT `fk_compliance_user`     FOREIGN KEY (`user_id`)    REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_compliance_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 21. DAILY TRACKER
-- ============================================================
CREATE TABLE `daily_tracker` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `employee_id` INT UNSIGNED NOT NULL,
  `project_id`  INT UNSIGNED DEFAULT NULL,
  `title`       VARCHAR(255) NOT NULL,
  `description` TEXT         DEFAULT NULL,
  `date`        DATE         NOT NULL,
  `progress`    DECIMAL(5,2) DEFAULT 0.00,
  `status`      VARCHAR(50)  DEFAULT 'not-started',
  `created_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_tracker_employee_date` (`employee_id`, `date`),
  INDEX `idx_tracker_project`       (`project_id`),
  CONSTRAINT `fk_tracker_employee` FOREIGN KEY (`employee_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tracker_project`  FOREIGN KEY (`project_id`)  REFERENCES `project` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 22. AI SUGGESTION
-- ============================================================
CREATE TABLE `ai_suggestion` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `org_id`           INT UNSIGNED NOT NULL,
  `suggested_for`    INT UNSIGNED DEFAULT NULL,
  `suggestion_type`  ENUM('resource_recommendation','schedule_adjustment','risk_warning',
                          'workload_rebalance','delay_mitigation','task_detail_enrichment') NOT NULL,
  `reference_type`   ENUM('task','project','user') DEFAULT NULL,
  `reference_id`     INT UNSIGNED DEFAULT NULL,
  `title`            VARCHAR(300) NOT NULL,
  `description`      TEXT         NOT NULL,
  `suggested_action` JSON         DEFAULT NULL,
  `status`           ENUM('pending','accepted','rejected','expired') NOT NULL DEFAULT 'pending',
  `reviewed_by`      INT UNSIGNED DEFAULT NULL,
  `reviewed_at`      DATETIME     DEFAULT NULL,
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_ai_org`    (`org_id`),
  INDEX `idx_ai_status` (`status`),
  INDEX `idx_ai_type`   (`suggestion_type`),
  INDEX `idx_ai_ref`    (`reference_type`, `reference_id`),
  CONSTRAINT `fk_ai_org`      FOREIGN KEY (`org_id`)        REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ai_for`      FOREIGN KEY (`suggested_for`) REFERENCES `user` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ai_reviewer` FOREIGN KEY (`reviewed_by`)   REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 23. AUDIT LOG
-- ============================================================
CREATE TABLE `audit_log` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `org_id`      INT UNSIGNED    NOT NULL,
  `user_id`     INT UNSIGNED    DEFAULT NULL,
  `action`      VARCHAR(100)    NOT NULL,
  `entity_type` VARCHAR(50)     NOT NULL,
  `entity_id`   INT UNSIGNED    NOT NULL,
  `old_values`  JSON            DEFAULT NULL,
  `new_values`  JSON            DEFAULT NULL,
  `ip_address`  VARCHAR(45)     DEFAULT NULL,
  `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_audit_org`     (`org_id`),
  INDEX `idx_audit_user`    (`user_id`),
  INDEX `idx_audit_entity`  (`entity_type`, `entity_id`),
  INDEX `idx_audit_action`  (`action`),
  INDEX `idx_audit_created` (`created_at`),
  CONSTRAINT `fk_audit_org`  FOREIGN KEY (`org_id`)  REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 24. PM SETTINGS
-- ============================================================
CREATE TABLE `pm_settings` (
  `id`                         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                    INT UNSIGNED NOT NULL,
  `strict_resource_limits`     TINYINT(1)   NOT NULL DEFAULT 0,
  `dynamic_deadline_shifting`  TINYINT(1)   NOT NULL DEFAULT 1,
  `high_priority_interruption` TINYINT(1)   NOT NULL DEFAULT 0,
  `alert_missing_logs`         TINYINT(1)   NOT NULL DEFAULT 1,
  `alert_conflicts`            TINYINT(1)   NOT NULL DEFAULT 1,
  `max_hours_threshold`        DECIMAL(5,2) NOT NULL DEFAULT 40.00,
  `created_at`                 DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`                 DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_settings_user` (`user_id`),
  CONSTRAINT `fk_settings_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- VIEWS
-- ============================================================

CREATE OR REPLACE VIEW `vw_resource_workload` AS
SELECT
    u.id                         AS user_id,
    u.first_name, u.last_name, u.employee_code,
    r.name                       AS role_name,
    u.max_hours_per_week,
    COUNT(DISTINCT t.id)         AS active_task_count,
    COALESCE(SUM(t.expected_effort * (100 - t.progress) / 100), 0) AS remaining_effort_hours,
    COALESCE(SUM(t.actual_effort), 0) AS total_hours_logged,
    COUNT(DISTINCT t.project_id) AS project_count,
    CASE
        WHEN COALESCE(SUM(t.expected_effort * (100 - t.progress) / 100), 0) > u.max_hours_per_week       THEN 'overloaded'
        WHEN COALESCE(SUM(t.expected_effort * (100 - t.progress) / 100), 0) > u.max_hours_per_week * 0.8 THEN 'near-capacity'
        ELSE 'available'
    END AS workload_status
FROM `user` u
JOIN `role` r ON r.id = u.role_id
LEFT JOIN `task_assignment` ta ON ta.user_id = u.id AND ta.is_active = 1
LEFT JOIN `task` t ON t.id = ta.task_id AND t.status IN ('not-started','in-progress','blocked')
WHERE u.is_active = 1
GROUP BY u.id, u.first_name, u.last_name, u.employee_code, r.name, u.max_hours_per_week;


CREATE OR REPLACE VIEW `vw_at_risk_tasks` AS
SELECT
    t.id AS task_id, t.title, t.project_id,
    p.name AS project_name, t.priority, t.status, t.deadline,
    t.expected_effort, t.progress, t.risk_status,
    DATEDIFF(t.deadline, CURDATE()) AS days_until_deadline,
    CASE
        WHEN t.status = 'completed'                                              THEN 'completed'
        WHEN CURDATE() > t.deadline                                              THEN 'overdue'
        WHEN DATEDIFF(t.deadline, CURDATE()) <= 3 AND t.progress < 80           THEN 'critical-risk'
        WHEN DATEDIFF(t.deadline, CURDATE()) <= 7 AND t.progress < 60           THEN 'at-risk'
        ELSE 'on-track'
    END AS calculated_risk
FROM `task` t
JOIN `project` p ON p.id = t.project_id
WHERE t.status NOT IN ('completed')
ORDER BY CASE WHEN CURDATE() > t.deadline THEN 1
              WHEN DATEDIFF(t.deadline, CURDATE()) <= 3 AND t.progress < 80 THEN 2
              WHEN DATEDIFF(t.deadline, CURDATE()) <= 7 AND t.progress < 60 THEN 3
              ELSE 4 END, t.deadline ASC;


CREATE OR REPLACE VIEW `vw_unassigned_important_tasks` AS
SELECT
    t.id AS task_id, t.title, t.project_id, p.name AS project_name,
    t.priority, t.deadline, t.expected_effort,
    DATEDIFF(t.deadline, CURDATE()) AS days_until_deadline
FROM `task` t
JOIN `project` p ON p.id = t.project_id
LEFT JOIN `task_assignment` ta ON ta.task_id = t.id AND ta.is_active = 1
WHERE ta.id IS NULL AND t.status NOT IN ('completed') AND t.priority IN ('critical','high')
ORDER BY FIELD(t.priority, 'critical','high'), t.deadline ASC;


CREATE OR REPLACE VIEW `vw_task_priority_distribution` AS
SELECT
    p.id AS project_id, p.name AS project_name, t.priority,
    COUNT(*) AS task_count,
    SUM(CASE WHEN t.status = 'completed'   THEN 1 ELSE 0 END) AS completed_count,
    SUM(CASE WHEN t.status = 'in-progress' THEN 1 ELSE 0 END) AS in_progress_count,
    SUM(CASE WHEN t.status = 'not-started' THEN 1 ELSE 0 END) AS not_started_count,
    SUM(CASE WHEN t.status = 'blocked'     THEN 1 ELSE 0 END) AS blocked_count
FROM `task` t JOIN `project` p ON p.id = t.project_id
GROUP BY p.id, p.name, t.priority
ORDER BY p.name, FIELD(t.priority, 'critical','high','medium','low');


CREATE OR REPLACE VIEW `vw_missing_daily_logs` AS
SELECT
    u.id AS user_id, u.first_name, u.last_name, u.employee_code, u.email,
    CURDATE() AS check_date,
    COUNT(DISTINCT ta.task_id) AS active_task_count,
    COALESCE(dlc.status, 'missed') AS compliance_status,
    CASE WHEN dlc.status IN ('logged','submitted','reviewed') THEN 0 ELSE 1 END AS needs_reminder
FROM `user` u
JOIN `task_assignment` ta ON ta.user_id = u.id AND ta.is_active = 1
JOIN `task` t ON t.id = ta.task_id AND t.status IN ('in-progress','not-started')
LEFT JOIN `daily_log_compliance` dlc ON dlc.user_id = u.id AND dlc.log_date = CURDATE()
WHERE u.is_active = 1
GROUP BY u.id, u.first_name, u.last_name, u.employee_code, u.email, dlc.status
HAVING needs_reminder = 1;


CREATE OR REPLACE VIEW `vw_employee_analytics` AS
SELECT
    u.id AS user_id, u.first_name, u.last_name, u.employee_code,
    COUNT(DISTINCT t.id)    AS total_assigned_tasks,
    SUM(CASE WHEN t.status = 'completed'   THEN 1 ELSE 0 END) AS completed_tasks,
    SUM(CASE WHEN t.status = 'in-progress' THEN 1 ELSE 0 END) AS in_progress_tasks,
    SUM(CASE WHEN t.status = 'not-started' THEN 1 ELSE 0 END) AS not_started_tasks,
    SUM(CASE WHEN t.status = 'blocked'     THEN 1 ELSE 0 END) AS blocked_tasks,
    COALESCE(SUM(t.actual_effort), 0)   AS total_hours_logged,
    COALESCE(SUM(t.expected_effort), 0) AS total_expected_effort,
    COUNT(DISTINCT t.project_id)         AS project_count,
    CASE WHEN SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) = 0 THEN 0
         ELSE ROUND(SUM(CASE WHEN t.status = 'completed' AND t.completed_at <= t.deadline THEN 1 ELSE 0 END) * 100.0
                    / SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END), 2)
    END AS on_time_completion_rate,
    (SELECT COUNT(*) FROM `daily_log_compliance` dlc WHERE dlc.user_id = u.id
     AND dlc.status IN ('logged','submitted','reviewed') AND dlc.log_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) AS logs_submitted_30d,
    (SELECT COUNT(*) FROM `daily_log_compliance` dlc WHERE dlc.user_id = u.id
     AND dlc.status = 'missed' AND dlc.log_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) AS logs_missed_30d
FROM `user` u
LEFT JOIN `task_assignment` ta ON ta.user_id = u.id AND ta.is_active = 1
LEFT JOIN `task` t ON t.id = ta.task_id
WHERE u.is_active = 1
GROUP BY u.id, u.first_name, u.last_name, u.employee_code;

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

DELIMITER //

CREATE PROCEDURE `sp_get_employee_task_stats`(IN p_user_id INT UNSIGNED)
BEGIN
    SELECT COUNT(DISTINCT t.id) AS total_tasks, COUNT(DISTINCT t.project_id) AS total_projects,
           SUM(CASE WHEN t.status = 'completed'   THEN 1 ELSE 0 END) AS completed_tasks,
           SUM(CASE WHEN t.status = 'in-progress' THEN 1 ELSE 0 END) AS in_progress_tasks,
           SUM(CASE WHEN t.status = 'blocked'     THEN 1 ELSE 0 END) AS blocked_tasks,
           SUM(CASE WHEN t.status = 'not-started' THEN 1 ELSE 0 END) AS not_started_tasks,
           COALESCE(SUM(t.actual_effort), 0) AS total_hours_logged,
           COALESCE(SUM(t.expected_effort * (100 - t.progress) / 100), 0) AS remaining_effort
    FROM `task_assignment` ta JOIN `task` t ON t.id = ta.task_id
    WHERE ta.user_id = p_user_id AND ta.is_active = 1;

    SELECT t.id, t.title, t.status, t.priority, t.deadline, t.progress, t.risk_status,
           p.name AS project_name, p.color AS project_color
    FROM `task_assignment` ta
    JOIN `task` t ON t.id = ta.task_id
    JOIN `project` p ON p.id = t.project_id
    WHERE ta.user_id = p_user_id AND ta.is_active = 1
    ORDER BY FIELD(t.priority,'critical','high','medium','low'), t.deadline ASC;
END //

CREATE PROCEDURE `sp_update_project_progress`(IN p_project_id INT UNSIGNED)
BEGIN
    DECLARE v_progress DECIMAL(5,2);
    SELECT COALESCE(AVG(t.progress), 0) INTO v_progress FROM `task` t WHERE t.project_id = p_project_id;
    UPDATE `project` SET `progress` = v_progress, `updated_at` = NOW() WHERE `id` = p_project_id;
END //

DELIMITER ;

-- ============================================================
-- 23. RESCHEDULE EVENT
-- ============================================================
CREATE TABLE `reschedule_event` (
  `id`                  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `org_id`              INT UNSIGNED  NOT NULL,
  `trigger_type`        VARCHAR(50)   NOT NULL,
  `trigger_ref_id`      INT UNSIGNED  DEFAULT NULL,
  `affected_task_count` INT           NOT NULL DEFAULT 0,
  `status`              VARCHAR(20)   NOT NULL DEFAULT 'pending_review',
  `payload`             TEXT          NOT NULL,
  `created_at`          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `applied_by`          INT UNSIGNED  DEFAULT NULL,
  `reviewed_at`         DATETIME      DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_reschedule_event_org`  FOREIGN KEY (`org_id`)     REFERENCES `organization` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_reschedule_event_user` FOREIGN KEY (`applied_by`) REFERENCES `user` (`id`)         ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 24. TASK SCHEDULE HISTORY
-- ============================================================
CREATE TABLE `task_schedule_history` (
  `id`                  INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `task_id`             INT UNSIGNED  NOT NULL,
  `reschedule_event_id` INT UNSIGNED  NOT NULL,
  `old_scheduled_start` DATE          DEFAULT NULL,
  `new_scheduled_start` DATE          DEFAULT NULL,
  `old_scheduled_end`   DATE          DEFAULT NULL,
  `new_scheduled_end`   DATE          DEFAULT NULL,
  `reason`              VARCHAR(255)  DEFAULT NULL,
  `created_at`          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_task_schedule_history_task`  FOREIGN KEY (`task_id`)             REFERENCES `task` (`id`)             ON DELETE CASCADE,
  CONSTRAINT `fk_task_schedule_history_event` FOREIGN KEY (`reschedule_event_id`) REFERENCES `reschedule_event` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
-- ============================================================
-- END OF SCHEMA v2.0
-- ============================================================

