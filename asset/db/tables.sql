-- Noorul Ilm Integrated College - Simplified MVP schema (22 tables)
-- MySQL 8.0+ / InnoDB. Fresh development database only.
CREATE DATABASE IF NOT EXISTS school_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE school_management;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS notifications,store_transactions,store_items,appointments,messages,student_checkins,payments,invoices,lesson_plans,timetable,attendance,results,teacher_assignments,subjects,sessions,classes,programs,student_parents,parents,students,staff_invitations,users;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE users (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(80) NULL UNIQUE,
 email VARCHAR(190) NULL UNIQUE,
 password_hash VARCHAR(255) NULL,
 role ENUM('admin','teacher','storekeeper','student','parent') NOT NULL,
 status ENUM('invited','pending_profile','active','deactivated','locked') NOT NULL DEFAULT 'active',
 must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
 last_login_at DATETIME NULL,
 failed_login_attempts SMALLINT UNSIGNED NOT NULL DEFAULT 0,
 locked_until DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX(role,status)
) ENGINE=InnoDB;

CREATE TABLE staff_invitations (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 token_hash CHAR(64) NOT NULL UNIQUE,
 invited_by BIGINT UNSIGNED NOT NULL,
 expires_at DATETIME NOT NULL,
 accepted_at DATETIME NULL,
 revoked_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(invited_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE students (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NULL UNIQUE,
 registration_number VARCHAR(50) NOT NULL UNIQUE,
 admission_type ENUM('existing','new') NOT NULL DEFAULT 'new',
 first_name VARCHAR(100) NOT NULL,
 middle_name VARCHAR(100) NULL,
 last_name VARCHAR(100) NOT NULL,
 gender ENUM('male','female','other','not_specified') NULL,
 date_of_birth DATE NULL,
 phone VARCHAR(30) NULL,
 email VARCHAR(190) NULL,
 address TEXT NULL,
 profile_completed_at DATETIME NULL,
 admission_date DATE NULL,
 status ENUM('active','inactive','graduated','withdrawn') NOT NULL DEFAULT 'active',
 created_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL,
 INDEX(last_name,first_name)
) ENGINE=InnoDB;

CREATE TABLE parents (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL UNIQUE,
 first_name VARCHAR(100) NOT NULL,
 last_name VARCHAR(100) NOT NULL,
 phone VARCHAR(30) NOT NULL,
 email VARCHAR(190) NULL,
 address TEXT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_parents (
 student_id BIGINT UNSIGNED NOT NULL,
 parent_id BIGINT UNSIGNED NOT NULL,
 relationship ENUM('father','mother','guardian','other') DEFAULT 'guardian',
 is_primary BOOLEAN DEFAULT FALSE,
 PRIMARY KEY(student_id,parent_id),
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(parent_id) REFERENCES parents(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE programs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(100) NOT NULL UNIQUE,
 level ENUM('primary','junior_secondary','senior_secondary','other') NOT NULL,
 active BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE classes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 program_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(100) NOT NULL,
 section VARCHAR(30) NULL,
 active BOOLEAN DEFAULT TRUE,
 FOREIGN KEY(program_id) REFERENCES programs(id) ON DELETE RESTRICT,
 UNIQUE(program_id,name,section)
) ENGINE=InnoDB;

CREATE TABLE sessions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(20) NOT NULL UNIQUE,
 start_date DATE NOT NULL,
 end_date DATE NOT NULL,
 current_session BOOLEAN DEFAULT FALSE,
 CHECK(end_date >= start_date)
) ENGINE=InnoDB;

CREATE TABLE subjects (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 program_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(100) NOT NULL,
 code VARCHAR(30) NULL,
 active BOOLEAN DEFAULT TRUE,
 FOREIGN KEY(program_id) REFERENCES programs(id) ON DELETE RESTRICT,
 UNIQUE(program_id,name)
) ENGINE=InnoDB;

CREATE TABLE teacher_assignments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 teacher_user_id BIGINT UNSIGNED NOT NULL,
 subject_id BIGINT UNSIGNED NOT NULL,
 class_id BIGINT UNSIGNED NOT NULL,
 session_id BIGINT UNSIGNED NOT NULL,
 FOREIGN KEY(teacher_user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE RESTRICT,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE RESTRICT,
 FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE,
 UNIQUE(teacher_user_id,subject_id,class_id,session_id)
) ENGINE=InnoDB;

CREATE TABLE results (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 student_id BIGINT UNSIGNED NOT NULL,
 class_id BIGINT UNSIGNED NOT NULL,
 subject_id BIGINT UNSIGNED NOT NULL,
 session_id BIGINT UNSIGNED NOT NULL,
 term ENUM('First Term','Second Term','Third Term') NOT NULL,
 teacher_user_id BIGINT UNSIGNED NOT NULL,
 ca_score DECIMAL(5,2) NOT NULL DEFAULT 0,
 exam_score DECIMAL(5,2) NOT NULL DEFAULT 0,
 total_score DECIMAL(5,2) GENERATED ALWAYS AS (ca_score+exam_score) STORED,
 grade VARCHAR(5) NULL,
 remark VARCHAR(100) NULL,
 status ENUM('draft','submitted','approved','published') DEFAULT 'draft',
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE RESTRICT,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE RESTRICT,
 FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE RESTRICT,
 FOREIGN KEY(teacher_user_id) REFERENCES users(id) ON DELETE RESTRICT,
 UNIQUE(student_id,subject_id,class_id,session_id,term),
 CHECK(ca_score>=0 AND exam_score>=0)
) ENGINE=InnoDB;

CREATE TABLE attendance (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 student_id BIGINT UNSIGNED NOT NULL,
 class_id BIGINT UNSIGNED NOT NULL,
 session_id BIGINT UNSIGNED NOT NULL,
 attendance_date DATE NOT NULL,
 status ENUM('present','absent','late','excused') DEFAULT 'present',
 taken_by BIGINT UNSIGNED NOT NULL,
 note VARCHAR(255) NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE RESTRICT,
 FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE RESTRICT,
 FOREIGN KEY(taken_by) REFERENCES users(id) ON DELETE RESTRICT,
 UNIQUE(student_id,class_id,attendance_date)
) ENGINE=InnoDB;

CREATE TABLE timetable (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 class_id BIGINT UNSIGNED NOT NULL,
 subject_id BIGINT UNSIGNED NOT NULL,
 teacher_user_id BIGINT UNSIGNED NOT NULL,
 session_id BIGINT UNSIGNED NOT NULL,
 day_of_week TINYINT UNSIGNED NOT NULL COMMENT '1 Monday to 7 Sunday',
 start_time TIME NOT NULL,
 end_time TIME NOT NULL,
 room VARCHAR(50) NULL,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE CASCADE,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE RESTRICT,
 FOREIGN KEY(teacher_user_id) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE,
 CHECK(day_of_week BETWEEN 1 AND 7),
 CHECK(end_time>start_time)
) ENGINE=InnoDB;

CREATE TABLE lesson_plans (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 teacher_user_id BIGINT UNSIGNED NOT NULL,
 class_id BIGINT UNSIGNED NOT NULL,
 subject_id BIGINT UNSIGNED NOT NULL,
 session_id BIGINT UNSIGNED NOT NULL,
 term ENUM('First Term','Second Term','Third Term') NOT NULL,
 topic VARCHAR(255) NOT NULL,
 objectives TEXT NULL,
 lesson_content TEXT NULL,
 teaching_method TEXT NULL,
 materials TEXT NULL,
 evaluation TEXT NULL,
 lesson_date DATE NULL,
 status ENUM('draft','submitted','approved','rejected') DEFAULT 'draft',
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(teacher_user_id) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(class_id) REFERENCES classes(id) ON DELETE RESTRICT,
 FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE RESTRICT,
 FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE invoices (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 invoice_number VARCHAR(40) NOT NULL UNIQUE,
 student_id BIGINT UNSIGNED NOT NULL,
 session_id BIGINT UNSIGNED NOT NULL,
 term ENUM('First Term','Second Term','Third Term') NULL,
 description VARCHAR(180) NOT NULL,
 amount DECIMAL(12,2) NOT NULL,
 due_date DATE NULL,
 status ENUM('unpaid','part_paid','paid','cancelled') DEFAULT 'unpaid',
 created_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE RESTRICT,
 FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE RESTRICT,
 FOREIGN KEY(created_by) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(amount>=0),
 INDEX(student_id,status)
) ENGINE=InnoDB;

CREATE TABLE payments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 receipt_number VARCHAR(40) NOT NULL UNIQUE,
 invoice_id BIGINT UNSIGNED NOT NULL,
 student_id BIGINT UNSIGNED NOT NULL,
 amount DECIMAL(12,2) NOT NULL,
 method ENUM('cash','bank_transfer','pos','online','other') NOT NULL,
 reference VARCHAR(120) NULL UNIQUE,
 provider VARCHAR(40) NULL,
 status ENUM('pending','successful','failed','reversed') DEFAULT 'pending',
 received_by BIGINT UNSIGNED NULL,
 paid_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE RESTRICT,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE RESTRICT,
 FOREIGN KEY(received_by) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(amount>0),
 INDEX(student_id,status)
) ENGINE=InnoDB;

CREATE TABLE student_checkins (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 student_id BIGINT UNSIGNED NOT NULL,
 qr_token_hash CHAR(64) NOT NULL,
 school_date DATE NOT NULL,
 check_in_at DATETIME NULL,
 check_out_at DATETIME NULL,
 recorded_by BIGINT UNSIGNED NULL,
 method ENUM('qr','manual') DEFAULT 'qr',
 note VARCHAR(255) NULL,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
 FOREIGN KEY(recorded_by) REFERENCES users(id) ON DELETE SET NULL,
 UNIQUE(student_id,school_date),
 INDEX(school_date)
) ENGINE=InnoDB;

CREATE TABLE messages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 conversation_key VARCHAR(100) NOT NULL,
 student_id BIGINT UNSIGNED NULL,
 sender_user_id BIGINT UNSIGNED NOT NULL,
 recipient_user_id BIGINT UNSIGNED NOT NULL,
 body TEXT NOT NULL,
 attachment_path VARCHAR(500) NULL,
 read_at DATETIME NULL,
 sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE SET NULL,
 FOREIGN KEY(sender_user_id) REFERENCES users(id) ON DELETE RESTRICT,
 FOREIGN KEY(recipient_user_id) REFERENCES users(id) ON DELETE RESTRICT,
 INDEX(conversation_key,sent_at),
 INDEX(recipient_user_id,read_at)
) ENGINE=InnoDB;

CREATE TABLE appointments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 parent_id BIGINT UNSIGNED NOT NULL,
 student_id BIGINT UNSIGNED NOT NULL,
 staff_user_id BIGINT UNSIGNED NULL,
 title VARCHAR(180) NOT NULL,
 details TEXT NULL,
 start_at DATETIME NOT NULL,
 end_at DATETIME NOT NULL,
 status ENUM('pending','approved','declined','cancelled','completed') DEFAULT 'pending',
 response_note TEXT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(parent_id) REFERENCES parents(id) ON DELETE RESTRICT,
 FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE RESTRICT,
 FOREIGN KEY(staff_user_id) REFERENCES users(id) ON DELETE SET NULL,
 CHECK(end_at>start_at),
 INDEX(staff_user_id,start_at,status)
) ENGINE=InnoDB;

CREATE TABLE store_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 item_code VARCHAR(40) NULL UNIQUE,
 name VARCHAR(150) NOT NULL,
 quantity INT NOT NULL DEFAULT 0,
 unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
 active BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CHECK(quantity>=0 AND unit_price>=0)
) ENGINE=InnoDB;

CREATE TABLE store_transactions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 item_id BIGINT UNSIGNED NOT NULL,
 transaction_type ENUM('stock_in','stock_out','sale','adjustment') NOT NULL,
 quantity INT NOT NULL,
 unit_price DECIMAL(12,2) NULL,
 reference VARCHAR(100) NULL,
 note VARCHAR(200) NULL,
 recorded_by BIGINT UNSIGNED NOT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(item_id) REFERENCES store_items(id) ON DELETE RESTRICT,
 FOREIGN KEY(recorded_by) REFERENCES users(id) ON DELETE RESTRICT,
 CHECK(quantity>0)
) ENGINE=InnoDB;

CREATE TABLE notifications (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 title VARCHAR(150) NOT NULL,
 message TEXT NOT NULL,
 type VARCHAR(40) DEFAULT 'general',
 link_url VARCHAR(500) NULL,
 read_at DATETIME NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX(user_id,read_at,created_at)
) ENGINE=InnoDB;

-- Implementation reminders:
-- • PHP generates registration numbers inside a transaction; UNIQUE protects duplicates.
-- • Use password_hash/password_verify; never store plain passwords.
-- • Student registration number + surname is ONLY initial verification; require password setup.
-- • Use random QR tokens; store hashes and never encode student details in QR.
-- • Verify online payments server-to-server; never trust browser payment status.
-- • Use transactions for payment and stock changes.
-- • Restrict all child/student data by authenticated user and guardian relationship.
