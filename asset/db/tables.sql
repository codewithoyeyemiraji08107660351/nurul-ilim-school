CREATE DATABASE IF NOT EXISTS school_management
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE school_management;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'teacher', 'student', 'storekeeper') NOT NULL,
    status TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    registration_number VARCHAR(50) NOT NULL UNIQUE,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    gender ENUM('Male', 'Female'),
    date_of_birth DATE,

    phone VARCHAR(30),
    address TEXT,

    status ENUM('active', 'inactive') DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE SET NULL
);

CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,

    staff_number VARCHAR(50) NOT NULL UNIQUE,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,

    phone VARCHAR(30),
    email VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
);

CREATE TABLE programs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE student_programs (
    id INT AUTO_INCREMENT PRIMARY KEY,

    student_id INT NOT NULL,
    program_id INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(student_id, program_id),

    FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE CASCADE,

    FOREIGN KEY (program_id) REFERENCES programs(id)
        ON DELETE CASCADE
);

CREATE TABLE sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE,
    status ENUM('active', 'closed') DEFAULT 'active'
);


CREATE TABLE terms (
    id INT AUTO_INCREMENT PRIMARY KEY,

    session_id INT NOT NULL,

    name ENUM(
        'First Term',
        'Second Term',
        'Third Term'
    ) NOT NULL,

    FOREIGN KEY (session_id) REFERENCES sessions(id)
        ON DELETE CASCADE,

    UNIQUE(session_id, name)
);

CREATE TABLE classes (
    id INT AUTO_INCREMENT PRIMARY KEY,

    program_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,

    FOREIGN KEY (program_id) REFERENCES programs(id)
        ON DELETE CASCADE,

    UNIQUE(program_id, name)
);

CREATE TABLE student_classes (
    id INT AUTO_INCREMENT PRIMARY KEY,

    student_id INT NOT NULL,
    class_id INT NOT NULL,
    session_id INT NOT NULL,

    FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE CASCADE,

    FOREIGN KEY (class_id) REFERENCES classes(id)
        ON DELETE CASCADE,

    FOREIGN KEY (session_id) REFERENCES sessions(id)
        ON DELETE CASCADE,

    UNIQUE(student_id, class_id, session_id)
);

CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,

    program_id INT NOT NULL,

    name VARCHAR(100) NOT NULL,

    FOREIGN KEY (program_id) REFERENCES programs(id)
        ON DELETE CASCADE,

    UNIQUE(program_id, name)
);

CREATE TABLE teacher_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,

    teacher_id INT NOT NULL,
    subject_id INT NOT NULL,
    class_id INT NOT NULL,

    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
        ON DELETE CASCADE,

    FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON DELETE CASCADE,

    FOREIGN KEY (class_id) REFERENCES classes(id)
        ON DELETE CASCADE,

    UNIQUE(teacher_id, subject_id, class_id)
);

CREATE TABLE results (
    id INT AUTO_INCREMENT PRIMARY KEY,

    student_id INT NOT NULL,
    program_id INT NOT NULL,
    class_id INT NOT NULL,

    subject_id INT NOT NULL,
    term_id INT NOT NULL,

    teacher_id INT NOT NULL,

    ca_score DECIMAL(5,2) DEFAULT 0,
    exam_score DECIMAL(5,2) DEFAULT 0,

    total_score DECIMAL(5,2)
        GENERATED ALWAYS AS (ca_score + exam_score) STORED,

    grade VARCHAR(5),
    remark VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (program_id) REFERENCES programs(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (term_id) REFERENCES terms(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id),

    UNIQUE(
        student_id,
        subject_id,
        class_id,
        term_id
    )
);

CREATE TABLE attendance (
    id INT AUTO_INCREMENT PRIMARY KEY,

    student_id INT NOT NULL,
    class_id INT NOT NULL,

    attendance_date DATE NOT NULL,

    status ENUM(
        'Present',
        'Absent',
        'Late'
    ) NOT NULL DEFAULT 'Present',

    taken_by INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (taken_by) REFERENCES teachers(id),

    UNIQUE(
        student_id,
        class_id,
        attendance_date
    )
);

CREATE TABLE timetable (
    id INT AUTO_INCREMENT PRIMARY KEY,

    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,

    day_of_week ENUM(
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
    ) NOT NULL,

    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

CREATE TABLE lesson_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,

    teacher_id INT NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    term_id INT NOT NULL,

    topic VARCHAR(255) NOT NULL,

    objectives TEXT,
    lesson_content TEXT,
    teaching_method TEXT,
    teaching_materials TEXT,
    evaluation TEXT,

    lesson_date DATE,

    status ENUM(
        'draft',
        'submitted',
        'approved'
    ) DEFAULT 'draft',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (teacher_id) REFERENCES teachers(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (term_id) REFERENCES terms(id)
);

CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,

    student_id INT NOT NULL,

    amount DECIMAL(10,2) NOT NULL,

    payment_type VARCHAR(100) NOT NULL,

    reference VARCHAR(100) NOT NULL UNIQUE,

    status ENUM(
        'pending',
        'successful',
        'failed'
    ) DEFAULT 'pending',

    paid_at DATETIME NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (student_id) REFERENCES students(id)
);

CREATE TABLE store_items (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(150) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,

    unit_price DECIMAL(10,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);