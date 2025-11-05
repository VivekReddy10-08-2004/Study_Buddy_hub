CREATE DATABASE User_ManagementDB;
USE User_ManagementDB;

-- ----------------------------------------------------------------------------------------------
-- Schema for User_Management
-- By Rise Akizaki
-- ----------------------------------------------------------------------------------------------

-- Table for "college"
-- Basic identifying information of a student's college
CREATE TABLE college (
	college_id int PRIMARY KEY AUTO_INCREMENT,
    college_name varchar(255) NOT NULL UNIQUE
);

-- Table for "majors"
-- Basic identifying information of a student's majors
CREATE TABLE majors (
	major_id int PRIMARY KEY AUTO_INCREMENT,
    major_name varchar(255) NOT NULL UNIQUE
);

-- Table for "user"
-- Stores basic user information, as well as their colleges, and majors (Foreign keys)
CREATE TABLE user (
	user_id int PRIMARY KEY AUTO_INCREMENT,
    email varchar(255) NOT NULL UNIQUE,
    password_hash varchar(255) NOT NULL,
    first_name varchar(100) NOT NULL,
    last_name varchar(100) NOT NULL,
    college_level enum('Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate') NULL,
    created_at datetime NOT NULL DEFAULT NOW(),
    bio text NULL,
    college_id int,
    major_id int,
    FOREIGN KEY (college_id) references college(college_id),
    FOREIGN KEY (major_id) references major(major_id)
);

-- Table for "courses"
-- Stores basic information about a course, including what college it belongs to (Foreign key)
CREATE TABLE courses (
	course_id int PRIMARY KEY AUTO_INCREMENT,
    course_code varchar(20) NOT NULL,
    course_name varchar(255) NOT NULL,
    college_id int,
    FOREIGN KEY (college_id) references college(college_id)
);

-- ----------------------------------------------------------------------------------------------