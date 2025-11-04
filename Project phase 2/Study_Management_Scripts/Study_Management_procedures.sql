-- ============================================================
-- Sarah Kayembe
-- STORED PROCEDURES FOR STUDY MANAGEMENT & GAMIFICATION SYSTEM
-- ============================================================

DELIMITER //
-- The DELIMITER above is important as it tells MySQL to top when it sees "//" instead of ";"

/* ============================================================
   TOPICS MANAGEMENT
   (CRUD operations)
   ============================================================ */

-- CREATE: Add a new topic under a course
CREATE PROCEDURE add_topic(
    IN p_course_id BIGINT,
    IN p_user_id BIGINT,
    IN p_topic_name VARCHAR(150),
    IN p_topic_type ENUM('lecture','lab','tutorial','assignment','exam','reading','project','discussion','review','other')
)
BEGIN
    INSERT INTO topics(course_id, user_id, topic_name, topic_type)
    VALUES (p_course_id, p_user_id, p_topic_name, p_topic_type);
END //

-- READ: Retrieve all topics for a specific course (latest first)
CREATE PROCEDURE get_topics_by_course(IN p_course_id BIGINT)
BEGIN
    SELECT * FROM topics WHERE course_id = p_course_id ORDER BY created_at DESC;
END //

-- UPDATE: Modify topic name or type
CREATE PROCEDURE update_topic(
    IN p_topic_id BIGINT,
    IN p_new_name VARCHAR(150),
    IN p_new_type ENUM('lecture','lab','tutorial','assignment','exam','reading','project','discussion','review','other')
)
BEGIN
    UPDATE topics
    SET topic_name = p_new_name,
        topic_type = p_new_type
    WHERE topic_id = p_topic_id;
END //

-- DELETE: Remove a topic by ID
CREATE PROCEDURE delete_topic(IN p_topic_id BIGINT)
BEGIN
    DELETE FROM topics WHERE topic_id = p_topic_id;
END //


/* ============================================================
   TASKS MANAGEMENT
   (CRUD for assignments, projects, and to-dos)
   ============================================================ */

-- CREATE: Add a new task
CREATE PROCEDURE add_task(
    IN p_user_id BIGINT,
    IN p_course_id BIGINT,
    IN p_topic_id BIGINT,
    IN p_title VARCHAR(200),
    IN p_due_date DATETIME,
    IN p_priority TINYINT,
    IN p_category ENUM('assignment','project','exam_prep','quiz','reading','lab','meeting','presentation','revision','misc')
)
BEGIN
    INSERT INTO tasks(user_id, course_id, topic_id, title, due_date, priority, category)
    VALUES (p_user_id, p_course_id, p_topic_id, p_title, p_due_date, p_priority, p_category);
END //

-- READ: Retrieve all tasks for a specific user, ordered by due date
CREATE PROCEDURE get_tasks_by_user(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM tasks WHERE user_id = p_user_id ORDER BY due_date ASC;
END //

-- UPDATE: Modify task status or title
CREATE PROCEDURE update_task(
    IN p_task_id BIGINT,
    IN p_new_status ENUM('todo','in_progress','done'),
    IN p_new_title VARCHAR(200)
)
BEGIN
    UPDATE tasks
    SET status = p_new_status,
        title = p_new_title,
        updated_at = NOW()
    WHERE task_id = p_task_id;
END //

-- DELETE: Remove a task by ID
CREATE PROCEDURE delete_task(IN p_task_id BIGINT)
BEGIN
    DELETE FROM tasks WHERE task_id = p_task_id;
END //


/* ============================================================
   TIMER SESSIONS (Pomodoro / Flowtime)
   ============================================================ */

-- CREATE: Add a new timer session record
CREATE PROCEDURE add_timer_session(
    IN p_host_id BIGINT,
    IN p_start DATETIME,
    IN p_end DATETIME,
    IN p_topic_id BIGINT,
    IN p_type ENUM('pomodoro','flowtime','custom'),
    IN p_short_break TINYINT,
    IN p_long_break TINYINT,
    IN p_session_type ENUM('solo','group')
)
BEGIN
    INSERT INTO timerSessions(host_id, start_time, end_time, topic_id, technique_type, short_break_min, long_break_min, session_type)
    VALUES (p_host_id, p_start, p_end, p_topic_id, p_type, p_short_break, p_long_break, p_session_type);
END //

-- READ: Fetch all timer sessions for a user
CREATE PROCEDURE get_timer_sessions_by_user(IN p_host_id BIGINT)
BEGIN
    SELECT * FROM timerSessions WHERE host_id = p_host_id ORDER BY start_time DESC;
END //

-- UPDATE: Adjust start/end times of a session
CREATE PROCEDURE update_timer_session_time(
    IN p_timer_id BIGINT,
    IN p_new_start DATETIME,
    IN p_new_end DATETIME
)
BEGIN
    UPDATE timerSessions
    SET start_time = p_new_start,
        end_time = p_new_end
    WHERE timer_id = p_timer_id;
END //

-- DELETE: Remove a session
CREATE PROCEDURE delete_timer_session(IN p_timer_id BIGINT)
BEGIN
    DELETE FROM timerSessions WHERE timer_id = p_timer_id;
END //


/* ============================================================
   DAILY FOCUS LOG
   (Track daily session and focus minutes)
   ============================================================ */

-- CREATE / UPDATE: Add or update daily focus summary
CREATE PROCEDURE add_or_update_daily_focus(
    IN p_user_id BIGINT,
    IN p_focus_date DATE,
    IN p_sessions INT,
    IN p_minutes INT
)
BEGIN
    INSERT INTO dailyFocusLog(user_id, focus_date, total_sessions, total_focus_min)
    VALUES (p_user_id, p_focus_date, p_sessions, p_minutes)
    ON DUPLICATE KEY UPDATE
        total_sessions = total_sessions + p_sessions,
        total_focus_min = total_focus_min + p_minutes;
END //

-- READ: Retrieve all daily logs for a user
CREATE PROCEDURE get_focus_log_by_user(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM dailyFocusLog WHERE user_id = p_user_id ORDER BY focus_date DESC;
END //

-- DELETE: Remove a log entry
CREATE PROCEDURE delete_focus_log(IN p_log_id BIGINT)
BEGIN
    DELETE FROM dailyFocusLog WHERE log_id = p_log_id;
END //


/* ============================================================
   USER STUDY STATS
   ============================================================ */

-- CREATE: Initialize stats for a new user
CREATE PROCEDURE create_user_stats(IN p_user_id BIGINT)
BEGIN
    INSERT INTO studyStats(user_id) VALUES (p_user_id);
END //

-- READ: Get stats for a given user
CREATE PROCEDURE get_user_stats(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM studyStats WHERE user_id = p_user_id;
END //

-- UPDATE: Increment session and focus time totals
CREATE PROCEDURE update_user_stats(
    IN p_user_id BIGINT,
    IN p_sessions INT,
    IN p_minutes INT
)
BEGIN
    UPDATE studyStats
    SET total_sessions = total_sessions + p_sessions,
        total_focus_time_min = total_focus_time_min + p_minutes,
        last_session_at = NOW()
    WHERE user_id = p_user_id;
END //

-- DELETE: Clear stats for a user
CREATE PROCEDURE delete_user_stats(IN p_user_id BIGINT)
BEGIN
    DELETE FROM studyStats WHERE user_id = p_user_id;
END //


/* ============================================================
   FOCUS ITEMS & INVENTORY SYSTEM
   ============================================================ */

-- CREATE: Add a new collectible item
CREATE PROCEDURE add_focus_item(
    IN p_type ENUM('plant','animal','house','floor','decoration','vehicle','structure','other'),
    IN p_name VARCHAR(100),
    IN p_cost INT,
    IN p_rarity ENUM('common','rare','epic','legendary')
)
BEGIN
    INSERT INTO focusItems(item_type, item_name, focus_cost_min, rarity_level)
    VALUES (p_type, p_name, p_cost, p_rarity);
END //

-- READ: Fetch all available focus items
CREATE PROCEDURE get_focus_items()
BEGIN
    SELECT * FROM focusItems;
END //

-- UPDATE: Rename a focus item
CREATE PROCEDURE update_focus_item_name(
    IN p_item_id BIGINT,
    IN p_new_name VARCHAR(100)
)
BEGIN
    UPDATE focusItems SET item_name = p_new_name WHERE item_id = p_item_id;
END //

-- DELETE: Remove a focus item
CREATE PROCEDURE delete_focus_item(IN p_item_id BIGINT)
BEGIN
    DELETE FROM focusItems WHERE item_id = p_item_id;
END //

-- CREATE: Award item to user (increment quantity if already owned)
CREATE PROCEDURE add_user_focus_item(IN p_user_id BIGINT, IN p_item_id BIGINT)
BEGIN
    INSERT INTO userFocusItems(user_id, item_id, quantity, last_earned_at)
    VALUES (p_user_id, p_item_id, 1, NOW())
    ON DUPLICATE KEY UPDATE quantity = quantity + 1, last_earned_at = NOW();
END //


/* ============================================================
   CITY LAYOUT (User placement of earned items)
   ============================================================ */

-- CREATE: Place an item on user’s city map
CREATE PROCEDURE add_city_item(
    IN p_user_id BIGINT,
    IN p_item_id BIGINT,
    IN p_x INT,
    IN p_y INT
)
BEGIN
    INSERT INTO userCityLayout(user_id, item_id, position_x, position_y)
    VALUES (p_user_id, p_item_id, p_x, p_y);
END //

-- READ: Get all city layout items for a user
CREATE PROCEDURE get_city_items(IN p_user_id BIGINT)
BEGIN
    SELECT * FROM userCityLayout WHERE user_id = p_user_id;
END //

-- UPDATE: Move a city item to new coordinates
CREATE PROCEDURE update_city_item_position(
    IN p_layout_id BIGINT,
    IN p_new_x INT,
    IN p_new_y INT
)
BEGIN
    UPDATE userCityLayout
    SET position_x = p_new_x,
        position_y = p_new_y
    WHERE layout_id = p_layout_id;
END //

-- DELETE: Remove an item from layout
CREATE PROCEDURE delete_city_item(IN p_layout_id BIGINT)
BEGIN
    DELETE FROM userCityLayout WHERE layout_id = p_layout_id;
END //


/* ============================================================
   MONTHLY CHALLENGES & USER PROGRESS
   ============================================================ */

-- CREATE: Add new monthly challenge
CREATE PROCEDURE add_challenge(
    IN p_title VARCHAR(150),
    IN p_desc VARCHAR(255),
    IN p_start DATE,
    IN p_end DATE,
    IN p_goal INT,
    IN p_reward BIGINT
)
BEGIN
    INSERT INTO monthlyChallenges(title, description, start_date, end_date, goal_minutes, reward_item_id)
    VALUES (p_title, p_desc, p_start, p_end, p_goal, p_reward);
END //

-- UPDATE: Modify challenge description
CREATE PROCEDURE update_challenge_desc(IN p_id BIGINT, IN p_new_desc VARCHAR(255))
BEGIN
    UPDATE monthlyChallenges SET description = p_new_desc WHERE challenge_id = p_id;
END //

-- CREATE: Register user progress record for challenge
CREATE PROCEDURE add_user_challenge_progress(IN p_user BIGINT, IN p_challenge BIGINT)
BEGIN
    INSERT INTO userChallengeProgress(user_id, challenge_id) VALUES (p_user, p_challenge);
END //

-- UPDATE: Increment user’s challenge progress (auto-mark complete)
CREATE PROCEDURE update_user_progress(IN p_user BIGINT, IN p_challenge BIGINT, IN p_minutes INT)
BEGIN
    UPDATE userChallengeProgress
    SET total_minutes = total_minutes + p_minutes,
        is_completed = (total_minutes + p_minutes >= (SELECT goal_minutes FROM monthlyChallenges WHERE challenge_id = p_challenge))
    WHERE user_id = p_user AND challenge_id = p_challenge;
END //


/* ============================================================
   MOOD TRACKING (User well-being reflection)
   ============================================================ */

-- CREATE: Add a mood entry linked to a study session
CREATE PROCEDURE add_mood_entry(
    IN p_user BIGINT,
    IN p_timer BIGINT,
    IN p_mood ENUM('very_bad','bad','neutral','good','great'),
    IN p_note VARCHAR(255)
)
BEGIN
    INSERT INTO moodTracking(user_id, timer_id, mood_level, note)
    VALUES (p_user, p_timer, p_mood, p_note);
END //

-- READ: Get all mood entries for a user (latest first)
CREATE PROCEDURE get_moods_by_user(IN p_user BIGINT)
BEGIN
    SELECT * FROM moodTracking WHERE user_id = p_user ORDER BY recorded_at DESC;
END //

-- UPDATE: Edit mood note
CREATE PROCEDURE update_mood_note(IN p_mood_id BIGINT, IN p_new_note VARCHAR(255))
BEGIN
    UPDATE moodTracking SET note = p_new_note WHERE mood_id = p_mood_id;
END //

-- DELETE: Remove mood entry
CREATE PROCEDURE delete_mood(IN p_mood_id BIGINT)
BEGIN
    DELETE FROM moodTracking WHERE mood_id = p_mood_id;
END //


/* ============================================================
   LEADERBOARD (Top performers tracking)
   ============================================================ */

-- UPDATE / UPSERT: Add or update leaderboard statistics
CREATE PROCEDURE update_leaderboard(
    IN p_user BIGINT,
    IN p_minutes INT,
    IN p_sessions INT
)
BEGIN
    INSERT INTO leaderboardStats(user_id, total_focus_min, total_sessions, updated_at)
    VALUES (p_user, p_minutes, p_sessions, NOW())
    ON DUPLICATE KEY UPDATE
        total_focus_min = total_focus_min + p_minutes,
        total_sessions = total_sessions + p_sessions,
        updated_at = NOW();
END //

-- READ: Retrieve top 10 users for a period
CREATE PROCEDURE get_top_leaderboard(IN p_period ENUM('daily','weekly','monthly','all_time'))
BEGIN
    SELECT u.username, l.total_focus_min, l.total_sessions, l.streak_days
    FROM leaderboardStats l
    JOIN users u ON u.user_id = l.user_id
    WHERE period_type = p_period
    ORDER BY l.total_focus_min DESC
    LIMIT 10;
END //


/* ============================================================
   REMINDERS (Task alerts)
   ============================================================ */

-- CREATE: Add a new reminder for a task
CREATE PROCEDURE add_reminder(
    IN p_task BIGINT,
    IN p_time DATETIME,
    IN p_method ENUM('in_app','email','sms')
)
BEGIN
    INSERT INTO reminders(task_id, reminder_time, method)
    VALUES (p_task, p_time, p_method);
END //

-- READ: Retrieve reminders by user (via joined tasks)
CREATE PROCEDURE get_reminders_by_user(IN p_user BIGINT)
BEGIN
    SELECT r.* FROM reminders r
    JOIN tasks t ON r.task_id = t.task_id
    WHERE t.user_id = p_user ORDER BY reminder_time;
END //

-- UPDATE: Change reminder time
CREATE PROCEDURE update_reminder_time(IN p_id BIGINT, IN p_new_time DATETIME)
BEGIN
    UPDATE reminders SET reminder_time = p_new_time WHERE reminder_id = p_id;
END //

-- DELETE: Remove reminder
CREATE PROCEDURE delete_reminder(IN p_id BIGINT)
BEGIN
    DELETE FROM reminders WHERE reminder_id = p_id;
END //

DELIMITER ;
