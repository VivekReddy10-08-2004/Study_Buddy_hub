use StudyBuddy;

-- Inserting data into colleges table

LOAD DATA LOCAL INFILE 'C:\\Users\\Work\\Documents\\GitHub\\Study_Buddy_hub\\Project phase 2\\data\\clean\\colleges_clean.csv'
INTO TABLE colleges
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(college_name);


-- Inserting data in courses table

LOAD DATA LOCAL INFILE 'C:\\Users\\Work\\Documents\\GitHub\\Study_Buddy_hub\\Project phase 2\\data\\clean\\usm_courses_clean.csv'
INTO TABLE courses
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(course_code, course_name, college_id);