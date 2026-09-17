-- ============================================================
-- TASKY -- Comprehensive Seed Data (48 Users, 8 Projects)
-- ============================================================
-- Run AFTER schema.sql.
-- Password for ALL users: password123
-- BCrypt hash: $2b$10$DzYSU/E6cNledVHArbIeE.0k/0QjHSr9PjGIrYWyRW9wxemvhQvC6
-- ============================================================
SET SQL_SAFE_UPDATES = 0;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- CLEAR EXISTING DATA
-- ============================================================
DELETE FROM `audit_log`;
DELETE FROM `ai_suggestion`;
DELETE FROM `pm_settings`;
DELETE FROM `daily_tracker`;
DELETE FROM `daily_log_compliance`;
DELETE FROM `task_review`;
DELETE FROM `progress_update`;
DELETE FROM `daily_work_log`;
DELETE FROM `task_comment`;
DELETE FROM `task_assignment`;
DELETE FROM `task_dependency`;
DELETE FROM `subtask`;
DELETE FROM `task`;
DELETE FROM `project_phase`;
DELETE FROM `workspace_invite`;
DELETE FROM `project_member`;
DELETE FROM `project`;
DELETE FROM `leave_request`;
DELETE FROM `employee_availability`;
DELETE FROM `notification`;
DELETE FROM `invite_code`;
DELETE FROM `user`;
DELETE FROM `role`;
DELETE FROM `organization`;

-- ============================================================
-- 1. ORGANIZATION
-- ============================================================
INSERT INTO `organization` (`id`, `name`, `domain`, `logo_url`) VALUES
(1, 'Tasky Inc.', 'tasky.com', NULL),
(2, 'Acme Corp.', 'acme.com', NULL);

-- ============================================================
-- 2. ROLES (9 roles)
-- ============================================================
INSERT INTO `role` (`id`, `org_id`, `name`, `description`, `access_level`) VALUES
(1, 1, 'Admin',               'System Administrator',              'admin'),
(2, 1, 'Project Manager',     'Manages projects and resources',    'manager'),
(3, 1, 'Senior Developer',    'Senior software developer',         'employee'),
(4, 1, 'Full Stack Developer','Full stack developer',              'employee'),
(5, 1, 'UI/UX Designer',      'User interface designer',           'employee'),
(6, 1, 'Backend Developer',   'Backend systems developer',         'employee'),
(7, 1, 'DevOps Engineer',     'Infrastructure and deployment',     'employee'),
(8, 1, 'QA Engineer',         'Quality assurance engineer',        'employee'),
(9, 1, 'Business Analyst',    'Business analysis and requirements','employee'),
(10, 2, 'Admin',               'System Administrator',              'admin'),
(11, 2, 'Project Manager',     'Manages projects and resources',    'manager'),
(12, 2, 'Senior Developer',    'Senior software developer',         'employee'),
(13, 2, 'Full Stack Developer','Full stack developer',              'employee'),
(14, 2, 'UI/UX Designer',      'User interface designer',           'employee'),
(15, 2, 'Backend Developer',   'Backend systems developer',         'employee'),
(16, 2, 'DevOps Engineer',     'Infrastructure and deployment',     'employee'),
(17, 2, 'QA Engineer',         'Quality assurance engineer',        'employee'),
(18, 2, 'Business Analyst',    'Business analysis and requirements','employee');

-- ============================================================
-- 3. USERS (3 PMs + 45 Employees = 48 total)
-- ============================================================
-- BCrypt hash for 'password123': $2b$10$DzYSU/E6cNledVHArbIeE.0k/0QjHSr9PjGIrYWyRW9wxemvhQvC6
SET @pw = '$2b$10$DzYSU/E6cNledVHArbIeE.0k/0QjHSr9PjGIrYWyRW9wxemvhQvC6';

INSERT INTO `user` (`id`,`org_id`,`role_id`,`employee_code`,`first_name`,`last_name`,`email`,`password_hash`,`phone`,`professional_role`,`application_role`,`skills`,`max_hours_per_week`,`is_active`) VALUES
-- Project Managers (IDs 1-3)
(1, 1,2,'PM-001','Alex',      'Morgan',      'alex.m@tasky.com',         @pw,'+1-555-0101','other',            'project_manager','["Project Management","Agile","Scrum","JIRA"]',      40.00,1),
(2, 1,2,'PM-002','Jessica',   'Lee',         'jessica.l@tasky.com',      @pw,'+1-555-0102','other',            'project_manager','["Project Management","Kanban","Risk Management"]',  40.00,1),
(3, 2,11,'PM-003','David',     'Kim',         'david.k@tasky.com',        @pw,'+1-555-0103','other',            'project_manager','["Project Management","Agile","DevOps","Scrum"]',    40.00,1),
-- Senior Developers (IDs 4-9, role_id=3)
(4, 1,3,'EMP-001','Sarah',    'Johnson',     'sarah.j@tasky.com',        @pw,'+1-555-0201','developer',        'employee',       '["Vue.js","React","TypeScript","CSS","Node.js"]',    40.00,1),
(5, 1,3,'EMP-002','Michael',  'Chen',        'michael.c@tasky.com',      @pw,'+1-555-0202','developer',        'employee',       '["Node.js","Python","Vue.js","MySQL","Redis"]',      40.00,1),
(6, 1,3,'EMP-003','Ryan',     'Thompson',    'ryan.t@tasky.com',         @pw,'+1-555-0203','developer',        'employee',       '["Java","Spring Boot","Microservices","AWS"]',       40.00,1),
(7, 1,3,'EMP-004','Emma',     'Wilson',      'emma.w@tasky.com',         @pw,'+1-555-0204','developer',        'employee',       '["React","GraphQL","TypeScript","MongoDB"]',         40.00,1),
(8, 1,3,'EMP-005','Daniel',   'Park',        'daniel.p@tasky.com',       @pw,'+1-555-0205','developer',        'employee',       '["Angular","RxJS","TypeScript","Node.js"]',          40.00,1),
(9, 1,3,'EMP-006','Olivia',   'Brown',       'olivia.b@tasky.com',       @pw,'+1-555-0206','developer',        'employee',       '["Vue.js","Nuxt.js","JavaScript","Tailwind"]',       40.00,1),
-- Full Stack Developers (IDs 10-16, role_id=4)
(10,1,4,'EMP-007','James',    'Davis',       'james.d@tasky.com',        @pw,'+1-555-0207','developer',        'employee',       '["React","Node.js","PostgreSQL","Docker"]',          40.00,1),
(11,1,4,'EMP-008','Sophia',   'Martinez',    'sophia.m@tasky.com',       @pw,'+1-555-0208','developer',        'employee',       '["Vue.js","Express","MySQL","Tailwind"]',            40.00,1),
(12,1,4,'EMP-009','Noah',     'Anderson',    'noah.a@tasky.com',         @pw,'+1-555-0209','developer',        'employee',       '["Next.js","TypeScript","Prisma","PostgreSQL"]',     40.00,1),
(13,1,4,'EMP-010','Ava',      'Thomas',      'ava.t@tasky.com',          @pw,'+1-555-0210','developer',        'employee',       '["React","Redux","Node.js","MongoDB"]',              40.00,1),
(14,1,4,'EMP-011','Liam',     'Jackson',     'liam.j@tasky.com',         @pw,'+1-555-0211','developer',        'employee',       '["Vue.js","Laravel","MySQL","REST APIs"]',           40.00,1),
(15,1,4,'EMP-012','Isabella', 'White',       'isabella.w@tasky.com',     @pw,'+1-555-0212','developer',        'employee',       '["React","Node.js","GraphQL","AWS"]',                35.00,1),
(16,1,4,'EMP-013','Mason',    'Harris',      'mason.h@tasky.com',        @pw,'+1-555-0213','developer',        'employee',       '["Angular","Spring Boot","Java","SQL Server"]',      40.00,1),
-- UI/UX Designers (IDs 17-20, role_id=5)
(17,1,5,'EMP-014','Emily',    'Clark',       'emily.c@tasky.com',        @pw,'+1-555-0214','designer',         'employee',       '["Figma","Adobe XD","CSS","HTML","Prototyping"]',   35.00,1),
(18,1,5,'EMP-015','Ethan',    'Lewis',       'ethan.l@tasky.com',        @pw,'+1-555-0215','designer',         'employee',       '["Figma","Sketch","Illustrator","User Research"]',  40.00,1),
(19,1,5,'EMP-016','Charlotte','Robinson',    'charlotte.r@tasky.com',    @pw,'+1-555-0216','designer',         'employee',       '["Figma","Adobe XD","CSS","Motion Design"]',         35.00,1),
(20,1,5,'EMP-017','Aiden',    'Walker',      'aiden.w@tasky.com',        @pw,'+1-555-0217','designer',         'employee',       '["Figma","Photoshop","UI Design","Wireframing"]',   40.00,1),
-- Backend Developers (IDs 21-26, role_id=6)
(21,1,6,'EMP-018','Benjamin', 'Hall',        'benjamin.h@tasky.com',     @pw,'+1-555-0218','developer',        'employee',       '["Node.js","Express","PostgreSQL","Redis","AWS"]',  40.00,1),
(22,1,6,'EMP-019','Mia',      'Allen',       'mia.a@tasky.com',          @pw,'+1-555-0219','developer',        'employee',       '["Python","Django","FastAPI","MySQL","Docker"]',     40.00,1),
(23,1,6,'EMP-020','Alexander','Young',       'alex.y@tasky.com',         @pw,'+1-555-0220','developer',        'employee',       '["Java","Spring","Hibernate","PostgreSQL"]',         40.00,1),
(24,1,6,'EMP-021','Harper',   'King',        'harper.k@tasky.com',       @pw,'+1-555-0221','developer',        'employee',       '["Go","gRPC","Kafka","MongoDB"]',                   40.00,1),
(25,1,6,'EMP-022','Elijah',   'Wright',      'elijah.w@tasky.com',       @pw,'+1-555-0222','developer',        'employee',       '["PHP","Laravel","MySQL","Redis"]',                 40.00,1),
(26,2,15,'EMP-023','Abigail',  'Scott',       'abigail.s@tasky.com',      @pw,'+1-555-0223','developer',        'employee',       '["Ruby","Rails","PostgreSQL","Sidekiq"]',            40.00,1),
-- DevOps Engineers (IDs 27-30, role_id=7)
(27,2,16,'EMP-024','Lucas',    'Green',       'lucas.g@tasky.com',        @pw,'+1-555-0224','other',            'employee',       '["AWS","Docker","Kubernetes","Terraform","CI/CD"]', 40.00,1),
(28,2,16,'EMP-025','Amelia',   'Baker',       'amelia.b@tasky.com',       @pw,'+1-555-0225','other',            'employee',       '["GCP","Ansible","Jenkins","Prometheus","ELK"]',    40.00,1),
(29,2,16,'EMP-026','Kevin',    'Adams',       'kevin.a@tasky.com',        @pw,'+1-555-0226','other',            'employee',       '["Azure","Docker","Helm","GitLab CI","Grafana"]',   40.00,1),
(30,2,16,'EMP-027','Hannah',   'Nelson',      'hannah.n@tasky.com',       @pw,'+1-555-0227','other',            'employee',       '["AWS","Terraform","CloudFormation","EKS"]',        40.00,1),
-- QA Engineers (IDs 31-35, role_id=8)
(31,2,17,'EMP-028','Logan',    'Carter',      'logan.c@tasky.com',        @pw,'+1-555-0228','qa_engineer',      'employee',       '["Selenium","Jest","Cypress","Postman","TestNG"]',  40.00,1),
(32,2,17,'EMP-029','Chloe',    'Mitchell',    'chloe.m@tasky.com',        @pw,'+1-555-0229','qa_engineer',      'employee',       '["Cypress","Playwright","Jest","API Testing"]',     40.00,1),
(33,2,17,'EMP-030','Jackson',  'Perez',       'jackson.p@tasky.com',      @pw,'+1-555-0230','qa_engineer',      'employee',       '["JMeter","LoadRunner","Performance Testing"]',     40.00,1),
(34,2,17,'EMP-031','Aria',     'Roberts',     'aria.r@tasky.com',         @pw,'+1-555-0231','qa_engineer',      'employee',       '["Manual Testing","Test Plans","JIRA","Bugzilla"]', 35.00,1),
(35,2,17,'EMP-032','Nathan',   'Turner',      'nathan.t@tasky.com',       @pw,'+1-555-0232','qa_engineer',      'employee',       '["Selenium","TestRail","Regression Testing","SQL"]',40.00,1),
-- Business Analysts (IDs 36-38, role_id=9)
(36,2,18,'EMP-033','Grace',    'Phillips',    'grace.p@tasky.com',        @pw,'+1-555-0233','business_analyst', 'employee',       '["Requirements Analysis","JIRA","Confluence","SQL"]',40.00,1),
(37,2,18,'EMP-034','Owen',     'Campbell',    'owen.c@tasky.com',         @pw,'+1-555-0234','business_analyst', 'employee',       '["Business Analysis","UML","Agile","Power BI"]',    40.00,1),
(38,2,18,'EMP-035','Lily',     'Parker',      'lily.p@tasky.com',         @pw,'+1-555-0235','business_analyst', 'employee',       '["Requirements Gathering","Process Modeling","SQL"]',40.00,1),
-- Additional Full Stack (IDs 39-43, role_id=4)
(39,2,13,'EMP-036','Dylan',    'Evans',       'dylan.e@tasky.com',        @pw,'+1-555-0236','developer',        'employee',       '["React","Node.js","MySQL","REST APIs","Redux"]',   40.00,1),
(40,2,13,'EMP-037','Zoe',      'Edwards',     'zoe.e@tasky.com',          @pw,'+1-555-0237','developer',        'employee',       '["Vue.js","Nuxt.js","PostgreSQL","Docker"]',         40.00,1),
(41,2,13,'EMP-038','Carter',   'Collins',     'carter.c@tasky.com',       @pw,'+1-555-0238','developer',        'employee',       '["Next.js","React","TypeScript","Tailwind"]',        40.00,1),
(42,2,13,'EMP-039','Penelope', 'Stewart',     'penelope.s@tasky.com',     @pw,'+1-555-0239','developer',        'employee',       '["Angular","Node.js","MongoDB","Express"]',          40.00,1),
(43,2,13,'EMP-040','Caleb',    'Morris',      'caleb.m@tasky.com',        @pw,'+1-555-0240','developer',        'employee',       '["React","GraphQL","Node.js","PostgreSQL"]',         40.00,1),
-- Additional Backend (IDs 44-48, role_id=6)
(44,2,15,'EMP-041','Scarlett', 'Rogers',      'scarlett.r@tasky.com',     @pw,'+1-555-0241','developer',        'employee',       '["Node.js","Express","MySQL","Redis","Kafka"]',     40.00,1),
(45,2,15,'EMP-042','Hunter',   'Reed',        'hunter.r@tasky.com',       @pw,'+1-555-0242','developer',        'employee',       '["Python","FastAPI","PostgreSQL","Celery"]',         40.00,1),
(46,2,15,'EMP-043','Addison',  'Cook',        'addison.c@tasky.com',      @pw,'+1-555-0243','developer',        'employee',       '["Java","Spring Boot","MySQL","Elasticsearch"]',     40.00,1),
(47,2,15,'EMP-044','Connor',   'Bailey',      'connor.b@tasky.com',       @pw,'+1-555-0244','developer',        'employee',       '["Node.js","TypeScript","PostgreSQL","Docker"]',    40.00,1),
(48,2,15,'EMP-045','Victoria', 'Rivera',      'victoria.r@tasky.com',     @pw,'+1-555-0245','developer',        'employee',       '["Python","Django","MongoDB","AWS Lambda"]',         40.00,1);

-- ============================================================
-- 4. INVITE CODE
-- ============================================================
INSERT INTO `invite_code` (`org_id`,`code`,`created_by`,`max_uses`,`current_uses`,`is_active`,`expires_at`) VALUES
(1,'TASKY2024',1,200,25,1,CONCAT(DATE_ADD(CURDATE(), INTERVAL 365 DAY),' 23:59:59')),
(2,'ACME2024',3,200,23,1,CONCAT(DATE_ADD(CURDATE(), INTERVAL 365 DAY),' 23:59:59'));

-- ============================================================
-- 5. PROJECTS (8 projects)
-- ============================================================
-- Relative dates: all relative to CURDATE()
INSERT INTO `project` (`id`,`org_id`,`created_by`,`name`,`description`,`status`,`priority`,`color`,`start_date`,`end_date`,`progress`) VALUES
(1,1,1,'E-Commerce Platform Redesign',
 'Complete overhaul of the e-commerce platform with modern UI, improved performance, and new payment integrations. Includes product catalog, shopping cart, checkout, and admin dashboard.',
 'active','high','#1976D2',
 DATE_SUB(CURDATE(),INTERVAL 60 DAY), DATE_ADD(CURDATE(),INTERVAL 50 DAY), 0),

(2,1,1,'Mobile Banking App',
 'Native mobile application for banking services with secure transactions, account management, bill payments, and real-time notifications. Critical security requirements.',
 'active','critical','#D32F2F',
 DATE_SUB(CURDATE(),INTERVAL 45 DAY), DATE_ADD(CURDATE(),INTERVAL 95 DAY), 0),

(3,1,2,'Internal Analytics Dashboard',
 'Business intelligence dashboard for internal metrics and reporting. Includes data visualization, KPI tracking, report generation, and role-based access control.',
 'active','medium','#388E3C',
 DATE_SUB(CURDATE(),INTERVAL 25 DAY), DATE_ADD(CURDATE(),INTERVAL 65 DAY), 0),

(4,1,2,'Marketing Campaign Platform',
 'Automated marketing campaign management with email templates, A/B testing, audience segmentation, and performance tracking analytics.',
 'planning','low','#7B1FA2',
 DATE_ADD(CURDATE(),INTERVAL 20 DAY), DATE_ADD(CURDATE(),INTERVAL 150 DAY), 0),

(5,2,3,'CRM System Upgrade',
 'Major upgrade to the customer relationship management system. Includes contact management, lead pipeline, customer analytics, email integration, and mobile app.',
 'active','high','#F57C00',
 DATE_SUB(CURDATE(),INTERVAL 30 DAY), DATE_ADD(CURDATE(),INTERVAL 80 DAY), 0),

(6,2,3,'DevOps Infrastructure Overhaul',
 'Complete modernization of infrastructure: migrate to Kubernetes, implement full CI/CD, set up monitoring stack, and establish DR procedures.',
 'active','critical','#455A64',
 DATE_SUB(CURDATE(),INTERVAL 20 DAY), DATE_ADD(CURDATE(),INTERVAL 100 DAY), 0),

(7,1,1,'HR Portal Development',
 'Employee self-service portal for leave management, payroll, performance reviews, document management, and onboarding workflows. Currently on hold pending budget approval.',
 'on-hold','medium','#00838F',
 DATE_SUB(CURDATE(),INTERVAL 45 DAY), DATE_ADD(CURDATE(),INTERVAL 100 DAY), 0),

(8,1,2,'AI-Powered Customer Chatbot',
 'Intelligent customer service chatbot using NLP to handle Tier-1 support queries, escalation workflows, knowledge base integration, and live agent handoff.',
 'planning','high','#E91E63',
 DATE_ADD(CURDATE(),INTERVAL 30 DAY), DATE_ADD(CURDATE(),INTERVAL 200 DAY), 0);

-- ============================================================
-- 6. PROJECT PHASES (3-4 per project)
-- ============================================================
INSERT INTO `project_phase` (`id`,`project_id`,`name`,`description`,`sort_order`,`start_date`,`end_date`,`status`) VALUES
-- E-Commerce (Project 1)
(1, 1,'Design',      'UI/UX design and prototyping',               1, DATE_SUB(CURDATE(),INTERVAL 60 DAY), DATE_SUB(CURDATE(),INTERVAL 30 DAY), 'completed'),
(2, 1,'Development', 'Core feature development',                   2, DATE_SUB(CURDATE(),INTERVAL 29 DAY), DATE_ADD(CURDATE(),INTERVAL 30 DAY), 'in-progress'),
(3, 1,'Testing',     'QA testing and bug fixes',                   3, DATE_ADD(CURDATE(),INTERVAL 31 DAY), DATE_ADD(CURDATE(),INTERVAL 50 DAY), 'pending'),
-- Mobile Banking (Project 2)
(4, 2,'Architecture','System architecture and security design',     1, DATE_SUB(CURDATE(),INTERVAL 45 DAY), DATE_SUB(CURDATE(),INTERVAL 10 DAY), 'in-progress'),
(5, 2,'Development', 'Feature development',                        2, DATE_SUB(CURDATE(),INTERVAL 9 DAY),  DATE_ADD(CURDATE(),INTERVAL 65 DAY), 'pending'),
(6, 2,'Security QA', 'Security testing and compliance',            3, DATE_ADD(CURDATE(),INTERVAL 66 DAY), DATE_ADD(CURDATE(),INTERVAL 95 DAY), 'pending'),
-- Analytics Dashboard (Project 3)
(7, 3,'Design',      'Dashboard wireframes and design',            1, DATE_SUB(CURDATE(),INTERVAL 25 DAY), DATE_SUB(CURDATE(),INTERVAL 3 DAY),  'completed'),
(8, 3,'Development', 'Backend and frontend development',           2, DATE_SUB(CURDATE(),INTERVAL 2 DAY),  DATE_ADD(CURDATE(),INTERVAL 50 DAY), 'in-progress'),
(9, 3,'Deployment',  'Deployment and monitoring setup',            3, DATE_ADD(CURDATE(),INTERVAL 51 DAY), DATE_ADD(CURDATE(),INTERVAL 65 DAY), 'pending'),
-- Marketing Platform (Project 4)
(10,4,'Planning',    'Requirements and architecture',              1, DATE_ADD(CURDATE(),INTERVAL 20 DAY), DATE_ADD(CURDATE(),INTERVAL 55 DAY), 'pending'),
(11,4,'Development', 'Platform development',                       2, DATE_ADD(CURDATE(),INTERVAL 56 DAY), DATE_ADD(CURDATE(),INTERVAL 120 DAY),'pending'),
(12,4,'Launch',      'Beta launch and feedback',                   3, DATE_ADD(CURDATE(),INTERVAL 121 DAY),DATE_ADD(CURDATE(),INTERVAL 150 DAY),'pending'),
-- CRM (Project 5)
(13,5,'Analysis',    'Requirements analysis and design',           1, DATE_SUB(CURDATE(),INTERVAL 30 DAY), DATE_SUB(CURDATE(),INTERVAL 12 DAY), 'completed'),
(14,5,'Development', 'Core module development',                    2, DATE_SUB(CURDATE(),INTERVAL 11 DAY), DATE_ADD(CURDATE(),INTERVAL 45 DAY), 'in-progress'),
(15,5,'Integration', 'Third-party integrations',                   3, DATE_ADD(CURDATE(),INTERVAL 46 DAY), DATE_ADD(CURDATE(),INTERVAL 70 DAY), 'pending'),
(16,5,'Testing',     'UAT and performance testing',                4, DATE_ADD(CURDATE(),INTERVAL 71 DAY), DATE_ADD(CURDATE(),INTERVAL 80 DAY), 'pending'),
-- DevOps (Project 6)
(17,6,'Assessment',  'Current state assessment',                   1, DATE_SUB(CURDATE(),INTERVAL 20 DAY), DATE_SUB(CURDATE(),INTERVAL 5 DAY),  'completed'),
(18,6,'Implementation','Infrastructure implementation',            2, DATE_SUB(CURDATE(),INTERVAL 4 DAY),  DATE_ADD(CURDATE(),INTERVAL 60 DAY), 'in-progress'),
(19,6,'Migration',   'Service migration and cutover',              3, DATE_ADD(CURDATE(),INTERVAL 61 DAY), DATE_ADD(CURDATE(),INTERVAL 100 DAY),'pending'),
-- HR Portal (Project 7 - on-hold)
(20,7,'Requirements','Requirements gathering',                     1, DATE_SUB(CURDATE(),INTERVAL 45 DAY), DATE_SUB(CURDATE(),INTERVAL 20 DAY), 'completed'),
(21,7,'Design',      'System design and architecture',             2, DATE_SUB(CURDATE(),INTERVAL 19 DAY), DATE_ADD(CURDATE(),INTERVAL 30 DAY), 'in-progress'),
(22,7,'Development', 'Portal development',                         3, DATE_ADD(CURDATE(),INTERVAL 31 DAY), DATE_ADD(CURDATE(),INTERVAL 100 DAY),'pending'),
-- AI Chatbot (Project 8)
(23,8,'Research',    'Technology research and POC',                1, DATE_ADD(CURDATE(),INTERVAL 30 DAY), DATE_ADD(CURDATE(),INTERVAL 65 DAY), 'pending'),
(24,8,'Prototype',   'Prototype development',                      2, DATE_ADD(CURDATE(),INTERVAL 66 DAY), DATE_ADD(CURDATE(),INTERVAL 120 DAY),'pending'),
(25,8,'Development', 'Production development',                     3, DATE_ADD(CURDATE(),INTERVAL 121 DAY),DATE_ADD(CURDATE(),INTERVAL 200 DAY),'pending');

-- ============================================================
-- 7. TASKS (~80 tasks across 8 projects)
-- ============================================================
INSERT INTO `task` (`id`,`project_id`,`phase_id`,`created_by`,`title`,`description`,`status`,`priority`,`deadline`,`start_date`,`expected_effort`,`actual_effort`,`progress`,`risk_status`,`is_self_assigned`,`resources_needed`) VALUES
-- === PROJECT 1: E-Commerce (Tasks 1-12, PM=Alex) ===
(1, 1,1,1,'Design System Implementation',
 'Create a comprehensive design system with reusable components, color palette, typography, and spacing guidelines.',
 'completed','high', DATE_SUB(CURDATE(),INTERVAL 32 DAY), DATE_SUB(CURDATE(),INTERVAL 55 DAY), 24.00,26.00,100.00,'completed',0,2),

(2, 1,2,1,'Product Catalog API',
 'Build RESTful API for product catalog management including CRUD operations, search, filtering, and pagination.',
 'in-progress','high', DATE_ADD(CURDATE(),INTERVAL 10 DAY), DATE_SUB(CURDATE(),INTERVAL 20 DAY), 40.00,22.00, 55.00,'on-track',0,2),

(3, 1,2,1,'Shopping Cart Module',
 'Develop shopping cart functionality with add/remove items, quantity management, price calculation, and session persistence.',
 'in-progress','high', DATE_ADD(CURDATE(),INTERVAL 18 DAY), DATE_SUB(CURDATE(),INTERVAL 8 DAY),  32.00, 9.60, 30.00,'on-track',0,2),

(4, 1,2,1,'Payment Gateway Integration',
 'Integrate Stripe and PayPal payment gateways with secure checkout flow, error handling, and refund support.',
 'not-started','critical', DATE_ADD(CURDATE(),INTERVAL 28 DAY), NULL, 48.00, 0.00,  0.00,'on-track',0,2),

(5, 1,2,1,'User Authentication & Profiles',
 'Implement user registration, login, password reset, social login, profile management, and order history.',
 'in-progress','medium', DATE_ADD(CURDATE(),INTERVAL 15 DAY), DATE_SUB(CURDATE(),INTERVAL 14 DAY), 28.00,18.20, 65.00,'on-track',0,2),

(6, 1,3,1,'Performance Optimization',
 'Optimize load times, implement lazy loading, CDN caching, image compression, and database query optimization.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 46 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(7, 1,2,1,'Admin Dashboard',
 'Build admin panel for product management, order processing, user management, and sales analytics.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 32 DAY), NULL, 36.00, 0.00,  0.00,'on-track',0,1),

(8, 1,3,1,'E2E Testing Suite',
 'Create comprehensive end-to-end testing suite covering the full checkout flow, user management, and edge cases.',
 'not-started','low',    DATE_ADD(CURDATE(),INTERVAL 48 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(9, 1,2,1,'Product Search & Filtering',
 'Implement Elasticsearch-based product search with faceted filtering, autocomplete, and relevance ranking.',
 'in-progress','high', DATE_ADD(CURDATE(),INTERVAL 12 DAY), DATE_SUB(CURDATE(),INTERVAL 10 DAY), 20.00, 9.00, 45.00,'on-track',0,2),

(10,1,2,1,'Checkout Flow',
 'Multi-step checkout process with address management, shipping options, order review, and confirmation.',
 'not-started','critical', DATE_ADD(CURDATE(),INTERVAL 22 DAY), NULL, 28.00, 0.00,  0.00,'on-track',0,1),

(11,1,2,1,'Order Management System',
 'Backend system for order lifecycle management: tracking, status updates, cancellations, and returns.',
 'not-started','high', DATE_ADD(CURDATE(),INTERVAL 35 DAY), NULL, 32.00, 0.00,  0.00,'on-track',0,2),

(12,1,2,1,'Email Notification System',
 'Transactional email system for order confirmations, shipping updates, password resets, and marketing emails.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 40 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 2: Mobile Banking (Tasks 13-23, PM=Alex) ===
(13,2,4,1,'Security Architecture Design',
 'Design the security architecture including encryption standards, token management, biometric auth, and audit logging.',
 'completed','critical', DATE_SUB(CURDATE(),INTERVAL 14 DAY), DATE_SUB(CURDATE(),INTERVAL 40 DAY), 30.00,32.00,100.00,'completed',0,2),

(14,2,4,1,'User Authentication System',
 'Implement secure user auth with JWT, 2FA, biometric login, device fingerprinting, and session management.',
 'in-progress','critical', DATE_ADD(CURDATE(),INTERVAL 4 DAY),  DATE_SUB(CURDATE(),INTERVAL 18 DAY), 36.00,22.00, 60.00,'at-risk',0,2),

(15,2,5,1,'Account Management Module',
 'Build account overview, transaction history, statement generation, and account settings features.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 25 DAY), NULL, 40.00, 0.00,  0.00,'on-track',0,2),

(16,2,5,1,'Fund Transfer System',
 'Implement internal/external fund transfers, scheduled payments, beneficiary management, and transfer limits.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 38 DAY), NULL, 44.00, 0.00,  0.00,'on-track',0,2),

(17,2,5,1,'Push Notifications Service',
 'Real-time push notifications for transactions, security alerts, and account updates using FCM and APNs.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 55 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(18,2,5,1,'Bill Payment Integration',
 'Integrate utility bill payments, mobile recharge, and scheduled recurring payment features.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 65 DAY), NULL, 32.00, 0.00,  0.00,'on-track',0,2),

(19,2,6,1,'Security Penetration Testing',
 'Comprehensive security testing including penetration testing, vulnerability assessment, and compliance checks.',
 'not-started','critical', DATE_ADD(CURDATE(),INTERVAL 88 DAY), NULL, 24.00, 0.00,  0.00,'on-track',0,2),

(20,2,4,1,'Mobile UI Design',
 'High-fidelity mobile UI designs for all screens including onboarding, dashboard, transfer flows, and settings.',
 'completed','high',  DATE_SUB(CURDATE(),INTERVAL 20 DAY), DATE_SUB(CURDATE(),INTERVAL 40 DAY), 28.00,26.00,100.00,'completed',0,2),

(21,2,4,1,'Biometric Authentication Module',
 'Native bridge for fingerprint and Face ID authentication on iOS and Android.',
 'in-progress','critical', DATE_ADD(CURDATE(),INTERVAL 8 DAY),  DATE_SUB(CURDATE(),INTERVAL 6 DAY),  20.00, 8.00, 40.00,'at-risk',0,2),

(22,2,5,1,'Transaction History & Search',
 'Transaction history with search, filtering by date/amount/type, and export to PDF/CSV.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 30 DAY), NULL, 24.00, 0.00,  0.00,'on-track',0,1),

(23,2,5,1,'Statement Generation',
 'Automated monthly and on-demand statement generation with PDF export and email delivery.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 42 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 3: Analytics Dashboard (Tasks 24-33, PM=Jessica) ===
(24,3,7,2,'Dashboard Wireframes & Mockups',
 'Wireframes and high-fidelity mockups for all dashboard views including charts, tables, and filter panels.',
 'completed','high',  DATE_SUB(CURDATE(),INTERVAL 8 DAY),  DATE_SUB(CURDATE(),INTERVAL 22 DAY), 16.00,14.00,100.00,'completed',0,1),

(25,3,8,2,'Data Pipeline Setup',
 'ETL pipeline for aggregating data from multiple sources into the analytics database with transformation rules.',
 'in-progress','high',  DATE_ADD(CURDATE(),INTERVAL 15 DAY), CURDATE(),                          28.00,14.00, 50.00,'on-track',0,2),

(26,3,8,2,'Chart Components Library',
 'Reusable chart components (bar, line, pie, heatmap, scatter) with interactive tooltips and drill-down.',
 'in-progress','high',  DATE_ADD(CURDATE(),INTERVAL 7 DAY),  DATE_SUB(CURDATE(),INTERVAL 1 DAY), 24.00,16.80, 70.00,'at-risk',0,2),

(27,3,8,2,'User Access Control System',
 'Role-based access control for dashboard sections, data export permissions, and audit logging.',
 'in-progress','medium', DATE_ADD(CURDATE(),INTERVAL 20 DAY), DATE_ADD(CURDATE(),INTERVAL 2 DAY), 20.00, 5.00, 25.00,'on-track',0,1),

(28,3,8,2,'Report Generation Engine',
 'Automated and on-demand report generation with PDF/CSV export, scheduling, and email delivery.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 38 DAY), NULL, 24.00, 0.00,  0.00,'on-track',0,2),

(29,3,9,2,'Monitoring & Alerting Setup',
 'Application monitoring, error tracking, uptime alerts, and SLA dashboards using Prometheus and Grafana.',
 'not-started','low',    DATE_ADD(CURDATE(),INTERVAL 62 DAY), NULL, 12.00, 0.00,  0.00,'on-track',0,1),

(30,3,8,2,'KPI Dashboard',
 'Executive KPI dashboard with real-time business metrics, trend analysis, and configurable widgets.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 30 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,2),

(31,3,8,2,'Data Export System',
 'Bulk data export for analysts with field selection, scheduling, and format options (CSV, Excel, JSON).',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 45 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(32,3,8,2,'Data Aggregation Service',
 'Micro-service to aggregate raw events into time-series metrics, supporting hourly/daily/monthly rollups.',
 'in-progress','high',  DATE_ADD(CURDATE(),INTERVAL 18 DAY), DATE_SUB(CURDATE(),INTERVAL 2 DAY), 24.00, 9.60, 40.00,'on-track',0,2),

(33,3,9,2,'Historical Data Migration',
 'Migrate and validate 3 years of historical data into the new analytics data model.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 55 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 4: Marketing Platform (Tasks 34-41, PM=Jessica) ===
(34,4,10,2,'Requirements Documentation',
 'Gather and document detailed requirements for the marketing campaign platform features and integrations.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 42 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(35,4,10,2,'Technical Architecture Design',
 'Design system architecture, database schema, API contracts, and third-party integration strategy.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 50 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,2),

(36,4,11,2,'Email Template Engine',
 'Drag-and-drop email template builder with variable substitution, preview, and A/B testing support.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 85 DAY), NULL, 36.00, 0.00,  0.00,'on-track',0,2),

(37,4,11,2,'Campaign Analytics Module',
 'Campaign performance tracking with open rates, click rates, conversion tracking, and ROI reporting.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 100 DAY),NULL, 28.00, 0.00,  0.00,'on-track',0,2),

(38,4,11,2,'Audience Segmentation Tool',
 'Dynamic audience segmentation based on behavior, demographics, purchase history, and custom attributes.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 95 DAY), NULL, 32.00, 0.00,  0.00,'on-track',0,2),

(39,4,11,2,'A/B Testing Framework',
 'Framework for A/B testing email subject lines, content, send times, and audience segments.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 108 DAY),NULL, 24.00, 0.00,  0.00,'on-track',0,1),

(40,4,11,2,'Campaign Scheduler',
 'Rule-based campaign scheduling with timezone support, drip sequences, and trigger-based sends.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 115 DAY),NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(41,4,12,2,'Performance Analytics Dashboard',
 'Unified dashboard for all campaign metrics with custom date ranges, comparison periods, and export.',
 'not-started','low',    DATE_ADD(CURDATE(),INTERVAL 148 DAY),NULL, 20.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 5: CRM (Tasks 42-53, PM=David) ===
(42,5,13,3,'Requirements Analysis',
 'Stakeholder interviews, current-state analysis, gap analysis, and requirements documentation.',
 'completed','high',  DATE_SUB(CURDATE(),INTERVAL 15 DAY), DATE_SUB(CURDATE(),INTERVAL 28 DAY), 20.00,18.00,100.00,'completed',0,1),

(43,5,13,3,'Database Schema Design',
 'Design normalized database schema for contacts, leads, deals, activities, and custom fields.',
 'completed','high',  DATE_SUB(CURDATE(),INTERVAL 8 DAY),  DATE_SUB(CURDATE(),INTERVAL 20 DAY), 16.00,14.00,100.00,'completed',0,2),

(44,5,14,3,'Contact Management Module',
 'Full CRUD for contacts with custom fields, merge duplicates, activity history, and smart lists.',
 'in-progress','high',  DATE_ADD(CURDATE(),INTERVAL 15 DAY), DATE_SUB(CURDATE(),INTERVAL 8 DAY),  32.00,11.20, 35.00,'on-track',0,2),

(45,5,14,3,'Lead Pipeline Management',
 'Visual kanban pipeline for lead management with stages, scoring, assignment rules, and forecasting.',
 'in-progress','high',  DATE_ADD(CURDATE(),INTERVAL 20 DAY), DATE_SUB(CURDATE(),INTERVAL 5 DAY),  28.00,11.20, 40.00,'on-track',0,2),

(46,5,14,3,'Customer Analytics Dashboard',
 'Analytics dashboard for customer lifetime value, churn prediction, segment analysis, and trends.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 40 DAY), NULL, 24.00, 0.00,  0.00,'on-track',0,2),

(47,5,15,3,'Email Integration',
 'Two-way email sync with Gmail/Outlook, email tracking, templates, and sequence automation.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 52 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(48,5,15,3,'Calendar & Task Integration',
 'Calendar sync with meeting scheduling, task management, and reminder notifications.',
 'not-started','low',    DATE_ADD(CURDATE(),INTERVAL 58 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(49,5,16,3,'CRM Reporting Module',
 'Customizable reports for sales performance, pipeline velocity, win/loss analysis, and forecasting.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 68 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(50,5,15,3,'Mobile CRM App',
 'React Native mobile app for field sales with offline support, contact lookup, and quick log.',
 'not-started','low',    DATE_ADD(CURDATE(),INTERVAL 78 DAY), NULL, 36.00, 0.00,  0.00,'on-track',0,2),

(51,5,14,3,'REST API Development',
 'RESTful API for all CRM entities with OpenAPI documentation, rate limiting, and webhook support.',
 'in-progress','high',  DATE_ADD(CURDATE(),INTERVAL 25 DAY), DATE_SUB(CURDATE(),INTERVAL 3 DAY),  36.00,21.60, 60.00,'on-track',0,2),

(52,5,14,3,'User Roles & Permissions',
 'Granular role-based access control with custom roles, field-level permissions, and territory management.',
 'in-progress','medium', DATE_ADD(CURDATE(),INTERVAL 22 DAY), DATE_SUB(CURDATE(),INTERVAL 2 DAY),  20.00, 9.00, 45.00,'on-track',0,1),

(53,5,15,3,'Data Import & Export',
 'Bulk import from CSV/Excel with field mapping, deduplication, and export with custom field selection.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 62 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 6: DevOps Infrastructure (Tasks 54-63, PM=David) ===
(54,6,17,3,'Infrastructure Assessment',
 'Audit existing infrastructure, identify gaps, document current state, and produce migration roadmap.',
 'completed','high',  DATE_SUB(CURDATE(),INTERVAL 7 DAY),  DATE_SUB(CURDATE(),INTERVAL 18 DAY), 20.00,22.00,100.00,'completed',0,2),

(55,6,18,3,'CI/CD Pipeline Setup',
 'Set up GitLab CI/CD pipelines for all services including automated tests, build, and multi-stage deployment.',
 'in-progress','critical', DATE_ADD(CURDATE(),INTERVAL 15 DAY), DATE_SUB(CURDATE(),INTERVAL 3 DAY),  28.00,14.00, 50.00,'on-track',0,2),

(56,6,18,3,'Kubernetes Cluster Setup',
 'Deploy and configure production-grade Kubernetes cluster with namespaces, RBAC, and auto-scaling.',
 'in-progress','critical', DATE_ADD(CURDATE(),INTERVAL 20 DAY), DATE_SUB(CURDATE(),INTERVAL 1 DAY),  24.00,10.80, 45.00,'on-track',0,2),

(57,6,18,3,'Monitoring Stack Implementation',
 'Deploy Prometheus, Grafana, AlertManager, and Loki for full observability across all services.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 30 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(58,6,18,3,'Security Hardening',
 'Network policies, secret management with Vault, image scanning, and CIS benchmark compliance.',
 'not-started','critical', DATE_ADD(CURDATE(),INTERVAL 40 DAY), NULL, 24.00, 0.00,  0.00,'on-track',0,2),

(59,6,18,3,'Load Balancer Configuration',
 'Configure Nginx ingress controller, SSL termination, rate limiting, and traffic routing rules.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 28 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(60,6,19,3,'Backup & Recovery System',
 'Automated database and volume backups with versioning, retention policies, and tested restore procedures.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 65 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(61,6,19,3,'Disaster Recovery Planning',
 'DR runbook, RTO/RPO definition, multi-region failover setup, and quarterly DR drills.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 80 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,2),

(62,6,18,3,'Performance Tuning',
 'Database query optimization, caching layer (Redis), CDN setup, and load testing with k6.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 55 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,2),

(63,6,19,3,'Infrastructure Documentation',
 'Comprehensive runbooks, architecture diagrams, and on-call playbooks for all infrastructure components.',
 'not-started','low',    DATE_ADD(CURDATE(),INTERVAL 95 DAY), NULL, 12.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 7: HR Portal (Tasks 64-71, PM=Alex, on-hold) ===
(64,7,20,1,'Requirements Gathering',
 'Stakeholder workshops, as-is process mapping, and HR module requirements documentation.',
 'completed','high',  DATE_SUB(CURDATE(),INTERVAL 22 DAY), DATE_SUB(CURDATE(),INTERVAL 42 DAY), 20.00,18.00,100.00,'completed',0,1),

(65,7,21,1,'System Design & Architecture',
 'Technical architecture, data model, API design, and security requirements for the HR portal.',
 'on-hold',  'high',  DATE_ADD(CURDATE(),INTERVAL 25 DAY), DATE_SUB(CURDATE(),INTERVAL 15 DAY), 24.00, 7.20, 30.00,'on-track',0,2),

(66,7,22,1,'Employee Database Setup',
 'Core employee data model with org chart, employment history, and document storage.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 45 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(67,7,22,1,'Leave Management Module',
 'Leave request workflow, balance tracking, manager approvals, and holiday calendar integration.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 55 DAY), NULL, 28.00, 0.00,  0.00,'on-track',0,2),

(68,7,22,1,'Payroll Integration',
 'Integration with payroll system for salary processing, deductions, and payslip generation.',
 'not-started','critical', DATE_ADD(CURDATE(),INTERVAL 75 DAY), NULL, 36.00, 0.00,  0.00,'on-track',0,2),

(69,7,22,1,'Performance Review System',
 'Annual and 360-degree review workflows with goal setting, ratings, and calibration sessions.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 85 DAY), NULL, 28.00, 0.00,  0.00,'on-track',0,1),

(70,7,22,1,'Document Management',
 'Secure document storage for contracts, policies, and employee files with version control and e-signatures.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 90 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(71,7,22,1,'Onboarding Workflow',
 'Structured onboarding checklist, document collection, IT setup requests, and day-1 orientation scheduling.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 98 DAY), NULL, 24.00, 0.00,  0.00,'on-track',0,1),

-- === PROJECT 8: AI Chatbot (Tasks 72-78, PM=Jessica) ===
(72,8,23,2,'Technology Research & Assessment',
 'Evaluate NLP frameworks (Rasa, Dialogflow, OpenAI) and produce technology recommendation report.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 60 DAY), NULL, 16.00, 0.00,  0.00,'on-track',0,1),

(73,8,23,2,'Chatbot Architecture Design',
 'Design conversational flow architecture, intent taxonomy, entity definitions, and escalation logic.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 68 DAY), NULL, 20.00, 0.00,  0.00,'on-track',0,2),

(74,8,24,2,'NLP Model Training',
 'Train and fine-tune NLP model on customer support transcripts with intent classification and entity extraction.',
 'not-started','critical', DATE_ADD(CURDATE(),INTERVAL 115 DAY),NULL, 40.00, 0.00,  0.00,'on-track',0,2),

(75,8,24,2,'Backend API Development',
 'RESTful backend for chatbot sessions, conversation history, analytics, and admin management.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 120 DAY),NULL, 32.00, 0.00,  0.00,'on-track',0,2),

(76,8,24,2,'Frontend Chat Widget',
 'Embeddable React chat widget with streaming responses, file attachments, and accessibility support.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 130 DAY),NULL, 24.00, 0.00,  0.00,'on-track',0,2),

(77,8,24,2,'Knowledge Base Integration',
 'Connect chatbot to internal knowledge base for FAQ resolution with confidence scoring and fallback.',
 'not-started','medium', DATE_ADD(CURDATE(),INTERVAL 140 DAY),NULL, 20.00, 0.00,  0.00,'on-track',0,1),

(78,8,24,2,'Testing & Quality Assurance',
 'Automated conversation testing, intent accuracy benchmarking, load testing, and user acceptance testing.',
 'not-started','high',  DATE_ADD(CURDATE(),INTERVAL 195 DAY),NULL, 20.00, 0.00,  0.00,'on-track',0,2);

-- ============================================================
-- 8. TASK DEPENDENCIES
-- ============================================================
INSERT INTO `task_dependency` (`task_id`,`depends_on_id`,`dependency_type`) VALUES
-- E-Commerce
(3, 2,'finish-to-start'),   -- Shopping Cart -> Product Catalog API
(4, 3,'finish-to-start'),   -- Payment -> Shopping Cart
(7, 2,'start-to-start'),    -- Admin Dashboard -> Product Catalog API
(8, 4,'finish-to-start'),   -- E2E Testing -> Payment Gateway
(6, 5,'finish-to-start'),   -- Performance -> User Auth
(9, 2,'start-to-start'),    -- Search -> Product Catalog API
(10,3,'finish-to-start'),   -- Checkout -> Shopping Cart
(11,10,'finish-to-start'),  -- Order Mgmt -> Checkout
(12,5,'start-to-start'),    -- Email Notif -> User Auth
-- Mobile Banking
(14,13,'finish-to-start'),  -- User Auth -> Security Architecture
(15,14,'finish-to-start'),  -- Account Mgmt -> User Auth
(16,15,'finish-to-start'),  -- Fund Transfer -> Account Mgmt
(18,16,'start-to-start'),   -- Bill Payment -> Fund Transfer
(19,14,'finish-to-start'),  -- Security Testing -> User Auth
(21,14,'start-to-start'),   -- Biometric -> User Auth
(22,15,'finish-to-start'),  -- Transaction History -> Account Mgmt
(23,22,'start-to-start'),   -- Statement -> Transaction History
-- Analytics Dashboard
(25,24,'finish-to-start'),  -- Data Pipeline -> Wireframes
(26,25,'start-to-start'),   -- Charts -> Data Pipeline
(27,24,'finish-to-start'),  -- Access Control -> Wireframes
(28,25,'finish-to-start'),  -- Report Engine -> Data Pipeline
(29,25,'finish-to-start'),  -- Monitoring -> Report Engine
(30,26,'start-to-start'),   -- KPI Dashboard -> Charts
(32,25,'start-to-start'),   -- Data Aggregation -> Data Pipeline
-- Marketing Platform
(35,34,'finish-to-start'),  -- Architecture -> Requirements
(36,35,'finish-to-start'),  -- Email Engine -> Architecture
(37,36,'start-to-start'),   -- Campaign Analytics -> Email Engine
(38,35,'finish-to-start'),  -- Audience Segmentation -> Architecture
(39,36,'start-to-start'),   -- A/B Testing -> Email Engine
(40,38,'start-to-start'),   -- Scheduler -> Audience Segmentation
-- CRM
(43,42,'finish-to-start'),  -- Schema Design -> Requirements
(44,43,'finish-to-start'),  -- Contact Mgmt -> Schema Design
(45,43,'start-to-start'),   -- Lead Pipeline -> Schema Design
(51,44,'start-to-start'),   -- API Dev -> Contact Mgmt
(52,43,'finish-to-start'),  -- User Roles -> Schema Design
(53,44,'finish-to-start'),  -- Import/Export -> Contact Mgmt
-- DevOps
(55,54,'finish-to-start'),  -- CI/CD -> Assessment
(56,54,'finish-to-start'),  -- K8s -> Assessment
(57,55,'start-to-start'),   -- Monitoring -> CI/CD
(59,56,'finish-to-start'),  -- Load Balancer -> K8s
(60,59,'finish-to-start'),  -- Backup -> Load Balancer
(62,57,'start-to-start'),   -- Perf Tuning -> Monitoring
-- HR Portal
(65,64,'finish-to-start'),  -- Architecture -> Requirements
(66,65,'finish-to-start'),  -- Employee DB -> Architecture
(67,66,'finish-to-start'),  -- Leave Mgmt -> Employee DB
-- AI Chatbot
(73,72,'finish-to-start'),  -- Architecture -> Research
(74,73,'finish-to-start'),  -- NLP Model -> Architecture
(75,73,'start-to-start'),   -- Backend API -> Architecture
(76,75,'start-to-start');   -- Chat Widget -> Backend API

-- ============================================================
-- 9. TASK ASSIGNMENTS
-- ============================================================
INSERT INTO `task_assignment` (`task_id`,`user_id`,`assigned_by`,`is_active`) VALUES
-- E-Commerce (Project 1)
(1, 17,1,1), (1, 18,1,1),  -- Design System: Emily, Ethan (UI/UX)
(2,  5,1,1), (2, 21,1,1),  -- Product Catalog API: Michael, Benjamin (Backend)
(3,  4,1,1), (3, 11,1,1),  -- Shopping Cart: Sarah, Sophia (Full Stack)
(5,  5,1,1), (5, 10,1,1),  -- User Auth: Michael, James (Full Stack)
(7, 16,1,1),               -- Admin Dashboard: Mason (Full Stack)
(8,8,1,1),               -- E2E Testing: Logan (QA)
(9, 21,1,1), (9,23,1,1),  -- Search: Benjamin, Scarlett (Backend)
(12,24,1,1),               -- Email Notif: Scarlett (Backend)
-- Mobile Banking (Project 2)
(13, 6,1,1), (13,7,1,1),  -- Security Architecture: Ryan, Lucas (DevOps)
(14, 6,1,1), (14,9,1,1),  -- User Auth: Ryan, Hunter (Backend)
(17,14,1,1),               -- Push Notifications: Scarlett
(19,8,1,1), (19,15,1,1),  -- Security Testing: Logan, Chloe (QA)
(20,17,1,1), (20,19,1,1),  -- Mobile UI: Emily, Charlotte (UI/UX)
(21,22,1,1), (21, 6,1,1),  -- Biometric Auth: Mia, Ryan
-- Analytics Dashboard (Project 3)
(24,20,2,1),               -- Wireframes: Aiden (UI/UX)
(25,23,2,1), (25,7,2,1),  -- Data Pipeline: Scarlett, Lucas (DevOps)
(26, 4,2,1), (26,17,2,1),  -- Charts: Sarah, Emily
(27, 5,2,1),               -- Access Control: Michael
(28,9,2,1), (28,22,2,1),  -- Report Engine: Hunter, Mia
(29,25,2,1),               -- Monitoring: Amelia (DevOps)
(32,9,2,1), (32,24,2,1),  -- Data Aggregation: Hunter, Addison
-- CRM (Project 5)
(42,36,3,1),               -- Requirements: Grace (BA)
(43,47,3,1), (43,39,3,1),  -- Schema Design: Connor, Daniel
(44,40,3,1), (44,47,3,1),  -- Contact Mgmt: Ava, Connor
(45,41,3,1), (45,42,3,1),  -- Lead Pipeline: Noah, Benjamin
(46,37,3,1),               -- Analytics Dashboard: Owen (BA)
(51,43,3,1), (51,47,3,1),  -- API Dev: Mia, Connor
(52,48,3,1),               -- User Roles: Benjamin
-- DevOps (Project 6)
(54,27,3,1), (54,28,3,1),  -- Assessment: Lucas, Amelia
(55,27,3,1), (55,29,3,1),  -- CI/CD: Lucas, Kevin
(56,28,3,1), (56,30,3,1),  -- K8s: Amelia, Hannah
(57,29,3,1),               -- Monitoring: Kevin
(58,27,3,1), (58,29,3,1),  -- Security Hardening: Lucas, Kevin
(59,28,3,1),               -- Load Balancer: Amelia
-- HR Portal (Project 7)
(64,25,1,1),               -- Requirements: Lily (BA)
(65,19,1,1), (65,20,1,1);  -- Architecture: Charlotte, Aiden

-- ============================================================
-- 10. TASK ASSIGNMENTS (update completed tasks)
-- ============================================================
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 32 DAY),' 16:00:00') WHERE `id` = 1;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 14 DAY),' 15:30:00') WHERE `id` = 13;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 20 DAY),' 16:45:00') WHERE `id` = 20;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY), ' 17:00:00') WHERE `id` = 24;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 15 DAY),' 16:00:00') WHERE `id` = 42;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY), ' 15:00:00') WHERE `id` = 43;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 7 DAY), ' 16:30:00') WHERE `id` = 54;
UPDATE `task` SET `completed_at` = CONCAT(DATE_SUB(CURDATE(),INTERVAL 22 DAY),' 15:00:00') WHERE `id` = 64;

-- ============================================================
-- 11. DAILY WORK LOGS (past 10 days for active tasks)
-- ============================================================
INSERT INTO `daily_work_log` (`task_id`,`user_id`,`log_date`,`status`,`work_completed`,`remaining_work`,`hours_spent`) VALUES
-- Task 2 (Product Catalog API) - Michael & Benjamin
(2, 5,DATE_SUB(CURDATE(),INTERVAL 7 DAY),'in-progress','Set up project structure and database models','CRUD endpoints',8.00),
(2, 5,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Built CRUD endpoints for product management','Search and filtering',7.00),
(2, 5,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Implemented search with full-text indexing','Pagination and sorting',6.00),
(2, 5,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Added pagination, sorting, and category filters','Image upload pipeline',7.00),
(2, 5,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'in-progress','Working on image upload pipeline with S3','Caching layer',5.00),
(2,21,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Set up API rate limiting and input validation','Error handling middleware',6.00),
(2,21,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Implemented error handling and logging middleware','API documentation',7.00),
-- Task 3 (Shopping Cart) - Sarah & Sophia
(3, 4,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Set up cart state management and basic add/remove','Quantity updates and price calc',6.00),
(3, 4,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Built quantity management and price calculation','Session persistence',7.00),
(3, 4,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Implementing session persistence with Redis','Guest cart merging',6.00),
(3,11,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Built cart UI components and quantity stepper','Promo code integration',5.00),
-- Task 5 (User Auth) - Michael & James
(5, 5,DATE_SUB(CURDATE(),INTERVAL 7 DAY),'in-progress','Set up JWT auth flow and user model','Password reset flow',4.00),
(5, 5,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Built password reset with email verification','Profile management',3.00),
(5,10,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Implemented profile management and order history API','Social login',7.00),
(5,10,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Working on Google OAuth social login','Session management',6.00),
(5,10,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'in-progress','Completed social login; started session management','Testing edge cases',5.00),
-- Task 9 (Search) - Benjamin & Scarlett
(9,21,DATE_SUB(CURDATE(),INTERVAL 5 DAY),'in-progress','Set up Elasticsearch index and basic search','Faceted filtering',7.00),
(9,21,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Implemented faceted filtering by category and price','Autocomplete',6.00),
(9,23,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Built autocomplete suggestions with fuzzy matching','Relevance tuning',6.00),
-- Task 14 (Banking User Auth) - Ryan & Hunter
(14, 6,DATE_SUB(CURDATE(),INTERVAL 7 DAY),'in-progress','Started JWT implementation with refresh tokens','2FA implementation',7.00),
(14, 6,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Implemented 2FA with TOTP authenticator','Biometric auth bridge',8.00),
(14, 6,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Working on biometric auth native module','Session management',7.00),
(14,9,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Built session management and device fingerprinting','Rate limiting',6.00),
(14,9,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'in-progress','Implementing rate limiting and brute force protection','Integration testing',5.00),
-- Task 21 (Biometric Auth) - Mia & Ryan
(21,22,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Researched iOS biometric APIs and built native bridge','Android integration',7.00),
(21,22,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Completed iOS FaceID; started Android fingerprint','Testing on devices',6.00),
(21, 6,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Security review of biometric implementation','Fallback PIN flow',4.00),
-- Task 25 (Data Pipeline) - Scarlett & Lucas
(25,23,CURDATE(),'in-progress','Set up ETL framework and data source connectors','Transformation rules',7.00),
(25,7,CURDATE(),'in-progress','Configured infrastructure for pipeline deployment','Monitoring setup',6.00),
-- Task 26 (Chart Components) - Sarah & Emily
(26, 4,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Built bar and line chart components with tooltips','Pie chart and heatmap',8.00),
(26, 4,CURDATE(),'in-progress','Working on pie chart with drill-down capability','Heatmap component',6.00),
(26,17,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'in-progress','Designed chart color themes and accessibility palettes','Animation polish',5.00),
-- Task 27 (Access Control) - Michael
(27, 5,CURDATE(),'in-progress','Started role-based permission system design','Data export permissions',4.00),
-- Task 32 (Data Aggregation) - Hunter & Addison
(32,9,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Built hourly rollup aggregation service','Daily/monthly rollups',7.00),
(32,24,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Implemented daily metric aggregation with caching','Error handling',6.00),
-- Task 44 (CRM Contact Mgmt) - Ava & Connor
(44,40,DATE_SUB(CURDATE(),INTERVAL 5 DAY),'in-progress','Built contact list view with sorting and search','Contact detail view',7.00),
(44,40,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Implemented contact detail view and edit forms','Custom fields',6.00),
(44,47,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Built REST API for contact CRUD operations','Activity history',8.00),
(44,47,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Implemented activity history and timeline','Duplicate detection',7.00),
-- Task 45 (Lead Pipeline) - Noah & Benjamin
(45,41,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Built kanban board UI for lead pipeline','Drag-and-drop',6.00),
(45,41,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Implemented drag-and-drop stage movement','Lead scoring',7.00),
(45,42,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Built lead assignment rules and API','Forecasting module',7.00),
-- Task 51 (CRM API) - Mia & Connor
(51,43,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Designed REST API schema and OpenAPI spec','Endpoint implementation',6.00),
(51,43,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'in-progress','Implemented contact and lead API endpoints','Webhook support',7.00),
(51,47,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Built API authentication and rate limiting middleware','Documentation',5.00),
-- Task 52 (User Roles) - Benjamin
(52,48,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Designed RBAC schema and implemented role management','Field-level permissions',7.00),
-- Task 55 (CI/CD) - Lucas & Kevin
(55,27,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'in-progress','Set up GitLab CI pipelines for 3 core services','Build optimization',8.00),
(55,27,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Optimized Docker build cache; added automated tests','Staging deployment',6.00),
(55,29,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Configured staging deployment pipeline','Production pipeline',7.00),
-- Task 56 (Kubernetes) - Amelia & Hannah
(56,28,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'in-progress','Set up cluster with 3 namespaces and RBAC','Ingress configuration',8.00),
(56,28,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'in-progress','Configured ingress and cert-manager for SSL','Auto-scaling policies',6.00),
(56,30,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'in-progress','Set up node auto-scaling and resource quotas','PersistentVolume setup',7.00);

-- ============================================================
-- 12. PROGRESS UPDATES
-- ============================================================
INSERT INTO `progress_update` (`task_id`,`user_id`,`previous_progress`,`new_progress`,`notes`,`created_at`) VALUES
-- Task 1 (Design System - completed)
(1,17, 0,30,'Color palette and typography guide done',CONCAT(DATE_SUB(CURDATE(),INTERVAL 50 DAY),' 17:00:00')),
(1,18,30,60,'Wireframes completed and approved',      CONCAT(DATE_SUB(CURDATE(),INTERVAL 48 DAY),' 17:30:00')),
(1,17,60,85,'Component library built (15 components)',CONCAT(DATE_SUB(CURDATE(),INTERVAL 45 DAY),' 17:00:00')),
(1,18,85,100,'All mockups finalized and handed off',   CONCAT(DATE_SUB(CURDATE(),INTERVAL 32 DAY),' 16:00:00')),
-- Task 2 (Product Catalog API)
(2, 5, 0,15,'Project setup and DB models complete',CONCAT(DATE_SUB(CURDATE(),INTERVAL 7 DAY),' 17:00:00')),
(2,21,15,25,'Rate limiting and validation added',  CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(2, 5,25,35,'CRUD endpoints built',                CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:30:00')),
(2, 5,35,45,'Search implemented with indexing',    CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(2,21,45,50,'Error handling and logging done',     CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:30:00')),
(2, 5,50,55,'Pagination and filters added',        CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 3 (Shopping Cart)
(3, 4, 0,10,'Cart state management setup',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(3, 4,10,20,'Quantity and price calc done',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(3, 4,20,30,'Session persistence WIP',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 5 (User Auth)
(5, 5, 0,20,'JWT auth flow done',                   CONCAT(DATE_SUB(CURDATE(),INTERVAL 7 DAY),' 17:00:00')),
(5, 5,20,35,'Password reset built',                 CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(5,10,35,50,'Profile management done',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(5,10,50,60,'Social login WIP',                     CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(5,10,60,65,'Social login completed',               CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
-- Task 9 (Search)
(9,21, 0,20,'Elasticsearch index set up',           CONCAT(DATE_SUB(CURDATE(),INTERVAL 5 DAY),' 17:00:00')),
(9,21,20,35,'Faceted filtering implemented',        CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(9,23,35,45,'Autocomplete added',                   CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 13 (Security Architecture - completed)
(13, 6, 0,40,'Architecture document drafted',       CONCAT(DATE_SUB(CURDATE(),INTERVAL 38 DAY),' 17:00:00')),
(13, 6,40,75,'Encryption standards defined',        CONCAT(DATE_SUB(CURDATE(),INTERVAL 35 DAY),' 17:00:00')),
(13, 6,75,100,'Architecture approved by stakeholders',CONCAT(DATE_SUB(CURDATE(),INTERVAL 14 DAY),' 15:30:00')),
-- Task 14 (Banking User Auth)
(14, 6, 0,20,'JWT with refresh tokens done',        CONCAT(DATE_SUB(CURDATE(),INTERVAL 7 DAY),' 17:00:00')),
(14, 6,20,35,'2FA implemented',                     CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(14, 6,35,45,'Biometric auth WIP',                  CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(14,9,45,55,'Session management done',             CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(14,9,55,60,'Rate limiting WIP',                   CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
-- Task 20 (Mobile UI - completed)
(20,17, 0,40,'Onboarding screens designed',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 38 DAY),' 17:00:00')),
(20,17,40,75,'Dashboard and transfer screens done', CONCAT(DATE_SUB(CURDATE(),INTERVAL 32 DAY),' 17:00:00')),
(20,19,75,100,'All screens finalized and exported', CONCAT(DATE_SUB(CURDATE(),INTERVAL 20 DAY),' 16:45:00')),
-- Task 21 (Biometric Auth)
(21,22, 0,20,'iOS biometric bridge researched',     CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(21,22,20,40,'iOS FaceID implemented',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 24 (Dashboard Wireframes - completed)
(24,20, 0,60,'Main dashboard wireframes done',      CONCAT(DATE_SUB(CURDATE(),INTERVAL 20 DAY),' 17:00:00')),
(24,20,60,100,'All views finalized and approved',   CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY),' 17:00:00')),
-- Task 25 (Data Pipeline)
(25,23, 0,25,'ETL framework set up',                CONCAT(CURDATE(),' 17:00:00')),
(25,7,25,50,'Infrastructure configured',           CONCAT(CURDATE(),' 17:30:00')),
-- Task 26 (Charts)
(26, 4, 0,40,'Bar and line charts done',            CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(26, 4,40,70,'Pie chart with drill-down done',      CONCAT(CURDATE(),' 17:00:00')),
-- Task 27 (Access Control)
(27, 5, 0,25,'Permission system started',           CONCAT(CURDATE(),' 17:00:00')),
-- Task 32 (Data Aggregation)
(32,9, 0,20,'Hourly rollup service built',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(32,24,20,40,'Daily aggregation done',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 42 (CRM Requirements - completed)
(42,36, 0,50,'Stakeholder interviews done',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 25 DAY),' 17:00:00')),
(42,36,50,100,'Requirements document finalized',    CONCAT(DATE_SUB(CURDATE(),INTERVAL 15 DAY),' 16:00:00')),
-- Task 43 (Schema Design - completed)
(43,39, 0,50,'Initial schema drafted',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 18 DAY),' 17:00:00')),
(43,47,50,100,'Schema reviewed and finalized',      CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY),' 15:00:00')),
-- Task 44 (Contact Mgmt)
(44,40, 0,15,'Contact list view done',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 5 DAY),' 17:00:00')),
(44,47,15,25,'CRUD API built',                      CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:30:00')),
(44,40,25,30,'Detail view done',                    CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(44,47,30,35,'Activity history implemented',        CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 45 (Lead Pipeline)
(45,41, 0,20,'Kanban board UI built',               CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(45,42,20,30,'Assignment rules built',              CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(45,41,30,40,'Drag-and-drop done',                  CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 51 (CRM API)
(51,43, 0,25,'API schema designed',                 CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(51,47,25,40,'Auth middleware done',                CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(51,43,40,60,'Contact and lead endpoints done',     CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
-- Task 52 (User Roles)
(52,48, 0,45,'RBAC schema and role management done',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 54 (Infrastructure Assessment - completed)
(54,27, 0,50,'Current state audit done',            CONCAT(DATE_SUB(CURDATE(),INTERVAL 15 DAY),' 17:00:00')),
(54,28,50,100,'Roadmap document finalized',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 7 DAY),' 16:30:00')),
-- Task 55 (CI/CD)
(55,27, 0,25,'GitLab CI pipelines set up for 3 services',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(55,29,25,35,'Staging pipeline configured',         CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(55,27,35,50,'Build cache optimized; tests automated',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
-- Task 56 (Kubernetes)
(56,28, 0,25,'Cluster set up with namespaces',      CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(56,30,25,35,'Auto-scaling configured',             CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(56,28,35,45,'Ingress and SSL configured',          CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
-- Task 64 (HR Requirements - completed)
(64,25, 0,60,'Stakeholder workshops done',          CONCAT(DATE_SUB(CURDATE(),INTERVAL 38 DAY),' 17:00:00')),
(64,25,60,100,'Requirements document approved',     CONCAT(DATE_SUB(CURDATE(),INTERVAL 22 DAY),' 15:00:00')),
-- Task 65 (HR Architecture - on-hold)
(65,19, 0,20,'System design started',               CONCAT(DATE_SUB(CURDATE(),INTERVAL 12 DAY),' 17:00:00')),
(65,20,20,30,'Architecture diagrams drafted',       CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY),' 17:00:00'));

-- ============================================================
-- 13. TASK COMMENTS
-- ============================================================
INSERT INTO `task_comment` (`task_id`,`user_id`,`content`,`is_sticky`,`created_at`) VALUES
(2, 1,'Great progress on the API. Make sure to implement proper rate limiting before go-live.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 10:00:00')),
(2, 5,'Image upload pipeline is more complex than estimated — may need an extra 2-3 days.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 16:00:00')),
(3, 1,'Shopping cart must support guest checkout. Plan for cart merging when a guest signs up.',1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 14:00:00')),
(14,1,'This is our highest-priority task. Security must be bulletproof before we move to Account Management.',1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 6 DAY),' 09:00:00')),
(14, 6,'Working on biometric auth native bridge. Should be ready by end of week.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 15:00:00')),
(26, 2,'Charts look great! Please ensure color-blind friendly palettes for accessibility compliance.',0,CONCAT(CURDATE(),' 11:00:00')),
(44, 3,'Contact module is critical path — schedule a mid-sprint demo so we can validate the UX early.',1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 09:30:00')),
(45, 3,'Lead pipeline needs to support bulk actions (assign, move, delete). Please account for this.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 10:00:00')),
(55, 3,'CI/CD is blocking 3 other DevOps tasks. Prioritize getting the staging pipeline green.',1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 08:30:00')),
(55,27,'Staging pipeline is green for 2 services. Working on the third now.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 16:00:00')),
(56, 3,'Make sure to document all Kubernetes configurations in Confluence as you go.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 09:00:00')),
(65, 1,'Project is on hold pending budget approval. Keep the architecture document ready for when we resume.',0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 5 DAY),' 11:00:00'));

-- ============================================================
-- 14. SUBTASKS
-- ============================================================
INSERT INTO `subtask` (`task_id`,`title`,`status`,`completed`,`progress`,`estimated_hours`) VALUES
(2,'Set up database models and migrations', 'completed',1,100.00,4.00),
(2,'Build CRUD endpoints',                  'completed',1,100.00,8.00),
(2,'Add search and filtering',              'in-progress',0, 70.00,6.00),
(2,'Implement image upload with S3',        'in-progress',0, 20.00,6.00),
(2,'Add caching layer with Redis',          'not-started',0,  0.00,4.00),
(14,'JWT implementation with refresh tokens','completed',1,100.00,6.00),
(14,'Two-factor authentication (TOTP)',      'completed',1,100.00,8.00),
(14,'Biometric auth native bridge',          'in-progress',0, 50.00,8.00),
(14,'Device fingerprinting',                 'in-progress',0, 80.00,4.00),
(14,'Rate limiting and brute force protection','in-progress',0, 60.00,4.00),
(55,'GitLab CI pipeline for API service',    'completed',1,100.00,4.00),
(55,'GitLab CI pipeline for frontend',       'completed',1,100.00,4.00),
(55,'Staging deployment automation',         'in-progress',0, 60.00,6.00),
(55,'Production deployment pipeline',        'not-started',0,  0.00,6.00),
(56,'Cluster setup with RBAC',               'completed',1,100.00,6.00),
(56,'Namespace and resource quota setup',    'completed',1,100.00,4.00),
(56,'Ingress controller and SSL setup',      'in-progress',0, 80.00,4.00),
(56,'Horizontal Pod Autoscaler configuration','not-started',0, 0.00,4.00);

-- ============================================================
-- 15. TASK REVIEWS
-- ============================================================
INSERT INTO `task_review` (`task_id`,`task_owner_id`,`reviewer_id`,`completion_comment`,`review_comment`,`status`,`submitted_at`,`completed_at`,`task_owner_points`,`reviewer_points`) VALUES
(1, 17,18,'Design system is complete with all components documented and exported to Figma.',
    'Excellent work. Components are consistent and the documentation is thorough. Minor: add dark mode tokens.',
    'finalized', CONCAT(DATE_SUB(CURDATE(),INTERVAL 32 DAY),' 16:00:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 31 DAY),' 10:00:00'), 50, 20),
(13, 6,27,'Security architecture document completed and reviewed by the security team.',
    'Comprehensive architecture. Encryption standards are solid. Recommend adding a threat model annex.',
    'finalized', CONCAT(DATE_SUB(CURDATE(),INTERVAL 14 DAY),' 15:30:00'), CONCAT(DATE_SUB(CURDATE(),INTERVAL 13 DAY),' 09:00:00'), 50, 20),
(24,20,17,'All dashboard wireframes completed. 12 screens with interactive prototype in Figma.',
    'Clean wireframes. Suggest adding a mobile breakpoint view for the main dashboard.',
    'review-done', CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY),' 17:00:00'), NULL, 0, 0);

-- ============================================================
-- 16. DAILY LOG COMPLIANCE (past 5 days for active employees)
-- ============================================================
INSERT INTO `daily_log_compliance` (`user_id`,`log_date`,`status`,`day_status`,`submitted_at`) VALUES
-- Sarah (id=4): logged every day
(4, DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:30:00')),
(4, DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:15:00')),
(4, DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:45:00')),
(4, DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:20:00')),
(4, CURDATE(),'logged','worked',CONCAT(CURDATE(),' 17:00:00')),
-- Michael (id=5): logged every day
(5, DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(5, DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:30:00')),
(5, DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 18:00:00')),
(5, DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:15:00')),
(5, CURDATE(),'submitted','worked',CONCAT(CURDATE(),' 17:00:00')),
-- Ryan (id=6): missed 2 days
(6, DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 18:00:00')),
(6, DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:45:00')),
(6, DATE_SUB(CURDATE(),INTERVAL 2 DAY),'missed','worked',NULL),
(6, DATE_SUB(CURDATE(),INTERVAL 1 DAY),'late','worked',CONCAT(CURDATE(),' 09:30:00')),
(6, CURDATE(),'missed','worked',NULL),
-- Emily Clark (id=17): logged every day
(17,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 16:45:00')),
(17,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(17,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:30:00')),
(17,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 16:50:00')),
(17,CURDATE(),'missed','worked',NULL),
-- Lucas (id=27): on leave today
(27,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(27,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(27,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(27,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
(27,CURDATE(),'not-required','leave',NULL),
-- Ava (id=13): consecutive missed logs
(13,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(13,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:20:00')),
(13,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'missed','worked',NULL),
(13,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'missed','worked',NULL),
(13,CURDATE(),'missed','worked',NULL),
-- Amelia (id=28): logged every day
(28,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:30:00')),
(28,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:15:00')),
(28,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(28,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:45:00')),
(28,CURDATE(),'logged','worked',CONCAT(CURDATE(),' 17:00:00')),
-- Mia (id=22): logged
(22,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(22,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(22,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(22,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
(22,CURDATE(),'submitted','worked',CONCAT(CURDATE(),' 17:30:00')),
-- Scarlett (id=44): logged
(44,DATE_SUB(CURDATE(),INTERVAL 4 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 4 DAY),' 17:00:00')),
(44,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 3 DAY),' 17:00:00')),
(44,DATE_SUB(CURDATE(),INTERVAL 2 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 17:00:00')),
(44,DATE_SUB(CURDATE(),INTERVAL 1 DAY),'logged','worked',CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 17:00:00')),
(44,CURDATE(),'logged','worked',CONCAT(CURDATE(),' 17:00:00'));

-- ============================================================
-- 17. EMPLOYEE AVAILABILITY (current week + weekend)
-- ============================================================
INSERT INTO `employee_availability` (`user_id`,`date`,`is_available`,`available_hours`,`day_type`) VALUES
-- Lucas on leave today
(27,CURDATE(),0,0.00,'leave'),
-- Weekday availability for key employees (5 days)
(4,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(4,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(4,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(4,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(4,CURDATE(),1,8.00,'weekday'),
(5,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(5,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(5,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(5,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(5,CURDATE(),1,8.00,'weekday'),
(6,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(6,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(6,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(6,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(6,CURDATE(),1,8.00,'weekday'),
(10,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(10,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(10,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(10,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(10,CURDATE(),1,8.00,'weekday'),
(11,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(11,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(11,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(11,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(11,CURDATE(),1,8.00,'weekday'),
(12,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(12,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(12,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(12,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(12,CURDATE(),1,8.00,'weekday'),
(13,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(13,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(13,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(13,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(13,CURDATE(),1,8.00,'weekday'),
(17,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,7.00,'weekday'),(17,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,7.00,'weekday'),(17,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,7.00,'weekday'),(17,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,7.00,'weekday'),(17,CURDATE(),1,7.00,'weekday'),
(21,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(21,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(21,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(21,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(21,CURDATE(),1,8.00,'weekday'),
(22,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(22,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(22,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(22,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(22,CURDATE(),1,8.00,'weekday'),
(28,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(28,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(28,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(28,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(28,CURDATE(),1,8.00,'weekday'),
(44,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(44,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(44,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(44,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(44,CURDATE(),1,8.00,'weekday'),
(45,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(45,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(45,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(45,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(45,CURDATE(),1,8.00,'weekday'),
(47,DATE_SUB(CURDATE(),INTERVAL 4 DAY),1,8.00,'weekday'),(47,DATE_SUB(CURDATE(),INTERVAL 3 DAY),1,8.00,'weekday'),(47,DATE_SUB(CURDATE(),INTERVAL 2 DAY),1,8.00,'weekday'),(47,DATE_SUB(CURDATE(),INTERVAL 1 DAY),1,8.00,'weekday'),(47,CURDATE(),1,8.00,'weekday'),
-- Weekend off (next 2 days)
(4,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(4,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend'),
(5,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(5,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend'),
(6,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(6,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend'),
(10,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(10,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend'),
(21,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(21,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend'),
(27,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(27,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend'),
(44,DATE_ADD(CURDATE(),INTERVAL 1 DAY),0,0.00,'weekend'),(44,DATE_ADD(CURDATE(),INTERVAL 2 DAY),0,0.00,'weekend');

-- ============================================================
-- 18. LEAVE REQUESTS
-- ============================================================
INSERT INTO `leave_request` (`user_id`,`approved_by`,`leave_type`,`start_date`,`end_date`,`reason`,`status`) VALUES
(27,3,'planned',CURDATE(),CURDATE(),'Medical appointment (pre-scheduled)','approved'),
(17,1,'casual', DATE_ADD(CURDATE(),INTERVAL 5 DAY), DATE_ADD(CURDATE(),INTERVAL 6 DAY), 'Family event','approved'),
(13,1,'sick',   DATE_ADD(CURDATE(),INTERVAL 10 DAY),DATE_ADD(CURDATE(),INTERVAL 12 DAY),'Flu — doctor confirmed','pending'),
(6, 1,'planned',DATE_ADD(CURDATE(),INTERVAL 15 DAY),DATE_ADD(CURDATE(),INTERVAL 16 DAY),'Annual wellness check','pending'),
(31,3,'casual', DATE_ADD(CURDATE(),INTERVAL 20 DAY),DATE_ADD(CURDATE(),INTERVAL 20 DAY),'Personal errand','pending'),
(22,2,'planned',DATE_ADD(CURDATE(),INTERVAL 25 DAY),DATE_ADD(CURDATE(),INTERVAL 27 DAY),'Attending tech conference','approved'),
(45,3,'sick',   DATE_SUB(CURDATE(),INTERVAL 5 DAY), DATE_SUB(CURDATE(),INTERVAL 4 DAY), 'Recovery from illness','approved');

-- ============================================================
-- 19. NOTIFICATIONS
-- ============================================================
INSERT INTO `notification` (`user_id`,`type`,`title`,`message`,`reference_type`,`reference_id`,`is_read`,`created_at`) VALUES
-- PM Alex (id=1) notifications
(1,'risk_alert',         'Project At Risk: Mobile Banking App',    'Mobile Banking App has 2 tasks at risk. User Auth System deadline is in 4 days at 60% progress.','project',2,0,CONCAT(CURDATE(),' 09:00:00')),
(1,'daily_log_warning',  'Missing Daily Logs',                     'Ryan Thompson (3 days) and Ava Thomas (3 consecutive days) have not submitted their daily logs.','user',6,0,CONCAT(CURDATE(),' 17:30:00')),
(1,'risk_alert',         'Overloaded Resource: Ryan Thompson',     'Ryan Thompson is allocated 47h this week across 2 projects, exceeding the 40h capacity.','user',6,0,CONCAT(CURDATE(),' 08:30:00')),
(1,'task_status_changed','Task Completed: Design System',          'Emily Clark and Ethan Lewis completed "Design System Implementation" in E-Commerce Platform.','task',1,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 32 DAY),' 16:05:00')),
(1,'deadline_approaching','Deadline Approaching: Chart Components','Chart Components Library is due in 7 days at 70% progress. Monitor closely.','task',26,0,CONCAT(CURDATE(),' 08:00:00')),
(1,'comment_added',      'New Comment on Product Catalog API',     'Michael Chen: "Image upload pipeline is more complex than estimated."','task',2,0,CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 16:05:00')),
(1,'general',            'Weekly Project Summary',                 'E-Commerce: 24.6% | Mobile Banking: 27.3% | Analytics: 28.5% | CRM: 31.7% | DevOps: 19.5%',NULL,NULL,0,CONCAT(CURDATE(),' 07:00:00')),
-- PM Jessica (id=2) notifications
(2,'deadline_approaching','Deadline Alert: Chart Components',      'Chart Components Library (Task #26) deadline is in 7 days. Progress: 70%.','task',26,0,CONCAT(CURDATE(),' 09:00:00')),
(2,'task_status_changed','Task Completed: Dashboard Wireframes',   'Aiden Walker completed "Dashboard Wireframes & Mockups" in Analytics Dashboard.','task',24,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 8 DAY),' 17:05:00')),
(2,'ai_suggestion',      'AI: Resource Recommendation for Task 30','Based on current workload, Sarah Johnson is the best fit for "KPI Dashboard" (available 24h capacity).','task',30,0,CONCAT(CURDATE(),' 10:00:00')),
(2,'risk_alert',         'Missing Daily Log: Emily Clark',         'Emily Clark has not submitted today\'s daily log. She has 2 active task assignments.',NULL,NULL,0,CONCAT(CURDATE(),' 17:30:00')),
-- PM David (id=3) notifications
(3,'task_status_changed','Task Completed: Infrastructure Assessment','Lucas Green and Amelia Baker completed "Infrastructure Assessment" in DevOps Infrastructure.','task',54,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 7 DAY),' 16:35:00')),
(3,'risk_alert',         'Dependency Bottleneck: CI/CD Pipeline',  'CI/CD Pipeline (Task #55) is blocking 3 other DevOps tasks. Current progress: 50%.','task',55,0,CONCAT(CURDATE(),' 09:30:00')),
(3,'daily_log_warning',  'Consecutive Missed Logs: Ava Thomas',    'Ava Thomas has missed daily logs for 3 consecutive days. Please follow up.','user',13,0,CONCAT(CURDATE(),' 18:00:00')),
-- Employee notifications
(6,'task_assigned',      'Task Assigned: User Authentication System','You have been assigned to "User Authentication System" (Mobile Banking). Deadline: 4 days.','task',14,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 18 DAY),' 09:00:00')),
(6,'daily_log_reminder', 'Daily Log Reminder',                     'You have not submitted your daily work log yet today. Please log your progress by 6 PM.','task',14,0,CONCAT(CURDATE(),' 17:00:00')),
(13,'daily_log_warning', 'Warning: Missing Daily Logs',             'You have not submitted daily logs for 3 consecutive days. Please submit or contact your PM.',NULL,NULL,0,CONCAT(CURDATE(),' 08:00:00')),
(17,'task_assigned',     'Task Assigned: Chart Components Library', 'You have been assigned to "Chart Components Library" (Analytics Dashboard). Deadline: 7 days.','task',26,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 09:00:00')),
(27,'leave_approved',    'Leave Approved',                          'Your leave request for today has been approved by David Kim. Enjoy your time off!','leave_request',1,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),' 14:00:00')),
(44,'task_assigned',     'Task Assigned: Data Pipeline Setup',      'You have been assigned to "Data Pipeline Setup" (Analytics Dashboard).','task',25,1,CONCAT(DATE_SUB(CURDATE(),INTERVAL 2 DAY),' 09:00:00'));

-- ============================================================
-- 20. AI SUGGESTIONS
-- ============================================================
INSERT INTO `ai_suggestion` (`org_id`,`suggested_for`,`suggestion_type`,`reference_type`,`reference_id`,`title`,`description`,`suggested_action`,`status`) VALUES
(1,NULL,'resource_recommendation','task',30,
 'Recommended Resource for KPI Dashboard',
 'Based on skills and current availability: Sarah Johnson (24h free capacity, Vue.js/React expertise) is the best fit for Task #30 KPI Dashboard. Second choice: Sophia Martinez (28h free, Vue.js).',
 '{"recommended_user_id":4,"confidence":0.87,"reasons":["skill_match","availability"]}',
 'pending'),
(1,NULL,'workload_rebalance','user',6,
 'Workload Alert: Ryan Thompson at 117% Capacity',
 'Ryan Thompson has 47 logged hours across Mobile Banking (User Auth + Biometric Auth). Recommend moving Biometric Auth (Task #21) to Mia Allen who has 18h free capacity.',
 '{"from_user_id":6,"to_user_id":22,"task_id":21,"confidence":0.82}',
 'pending'),
(1,NULL,'risk_warning','task',14,
 'Risk Warning: User Authentication System',
 'Task #14 (User Authentication System) is at 60% progress with 4 days to deadline. At current pace of ~5%/day, it will reach ~80% by deadline. Recommend adding 1 additional Backend Developer.',
 '{"risk_level":"high","predicted_completion_percent":80,"days_until_deadline":4}',
 'pending'),
(1,NULL,'schedule_adjustment','task',10,
 'Suggested Deadline Adjustment: Checkout Flow',
 'Task #10 (Checkout Flow) depends on Shopping Cart (Task #3) which is 30% complete. If Shopping Cart takes 6 more days, Checkout must start later. Suggest shifting deadline by 7 days.',
 '{"current_deadline_offset":22,"suggested_deadline_offset":29,"blocker_task_id":3}',
 'pending'),
(1,NULL,'delay_mitigation','task',26,
 'Deadline Risk: Chart Components Library',
 'Chart Components Library (Task #26) is at 70% with 7 days remaining. Emily Clark (designer) may not have the backend skills needed for heatmap. Recommend pairing with Sarah Johnson.',
 '{"risk_score":0.65,"suggested_pairing_user_id":4}',
 'pending'),
(1,NULL,'task_detail_enrichment','task',4,
 'AI-Suggested Task Details: Payment Gateway Integration',
 'Based on similar tasks, suggested subtasks: (1) Stripe webhook setup (8h), (2) PayPal SDK integration (8h), (3) PCI DSS compliance review (4h), (4) Error handling and retry logic (6h), (5) Refund flow (8h).',
 '{"suggested_subtasks":[{"title":"Stripe webhook setup","hours":8},{"title":"PayPal SDK integration","hours":8},{"title":"PCI DSS compliance review","hours":4},{"title":"Error handling and retry logic","hours":6},{"title":"Refund flow","hours":8}]}',
 'pending');

-- ============================================================
-- 21. PM SETTINGS (for all 3 PMs)
-- ============================================================
INSERT INTO `pm_settings` (`user_id`,`strict_resource_limits`,`dynamic_deadline_shifting`,`high_priority_interruption`,`alert_missing_logs`,`alert_conflicts`,`max_hours_threshold`) VALUES
(1, 0, 1, 0, 1, 1, 40.00),  -- Alex: default settings
(2, 1, 1, 0, 1, 1, 40.00),  -- Jessica: strict resource limits on
(3, 0, 1, 1, 1, 1, 45.00);  -- David: high priority interruption, 45h threshold

-- ============================================================
-- 22. UPDATE PROJECT PROGRESS (from task averages)
-- ============================================================
-- E-Commerce: (100+55+30+0+65+0+0+0+45+0+0+0)/12 = 24.58
UPDATE `project` SET `progress` = 24.58 WHERE `id` = 1;
-- Mobile Banking: (100+60+0+0+0+0+0+100+40+0+0)/11 = 27.27
UPDATE `project` SET `progress` = 27.27 WHERE `id` = 2;
-- Analytics: (100+50+70+25+0+0+0+0+40+0)/10 = 28.50
UPDATE `project` SET `progress` = 28.50 WHERE `id` = 3;
-- Marketing: all 0
UPDATE `project` SET `progress` = 0.00 WHERE `id` = 4;
-- CRM: (100+100+35+40+0+0+0+0+0+60+45+0)/12 = 31.67
UPDATE `project` SET `progress` = 31.67 WHERE `id` = 5;
-- DevOps: (100+50+45+0+0+0+0+0+0+0)/10 = 19.50
UPDATE `project` SET `progress` = 19.50 WHERE `id` = 6;
-- HR Portal: (100+30+0+0+0+0+0+0)/8 = 16.25
UPDATE `project` SET `progress` = 16.25 WHERE `id` = 7;
-- AI Chatbot: all 0
UPDATE `project` SET `progress` = 0.00 WHERE `id` = 8;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- SEED DATA COMPLETE
-- ============================================================
-- Login Credentials (password: password123 for all users):
-- PM-1 Alex Morgan:    pm=alex.m@tasky.com      / PM-001
-- PM-2 Jessica Lee:   jessica.l@tasky.com      / PM-002
-- PM-3 David Kim:     david.k@tasky.com        / PM-003
-- EMP-001 Sarah J:    sarah.j@tasky.com        / EMP-001
-- EMP-002 Michael C:  michael.c@tasky.com      / EMP-002
-- ... (see user table for all 45 employees)
-- ============================================================
