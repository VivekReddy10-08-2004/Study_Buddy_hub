use StudyBuddy;

-- Query Example for Analysis
-- Find course (names) which are part of USM, and are ART courses

-- Query 1
EXPLAIN ANALYZE
SELECT cr.course_name, cl.college_name
FROM Courses cr
JOIN Colleges cl ON cr.college_id = cl.college_id
WHERE cl.college_name LIKE '%University of Southern Maine%'
AND cr.course_code LIKE '%ART%';

-- Query 2
CREATE INDEX idx_college_name ON Colleges (college_name);
CREATE INDEX idx_course_code ON Courses (course_code);

EXPLAIN ANALYZE
SELECT cr.course_name, cl.college_name
FROM Courses cr
JOIN Colleges cl ON cr.college_id = cl.college_id
WHERE cl.college_name LIKE 'University of Southern Maine%'   
AND cr.course_code LIKE 'ART%';               
