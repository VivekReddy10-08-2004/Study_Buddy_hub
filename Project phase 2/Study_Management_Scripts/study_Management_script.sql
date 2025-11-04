-- ------------------------------------------------------------
-- Sarah Kayembe
-- Study Manangement and Gamification
-- ------------------------------------------------------------
-- ------------------------------------------------------------
-- topics
-- (Each course contains multiple topics)
-- ------------------------------------------------------------
CREATE TABLE topics (
    topic_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    user_id BIGINT DEFAULT NULL,
    topic_name VARCHAR(150) NOT NULL,
    topic_type ENUM('lecture','lab','tutorial','assignment','exam','reading',
                    'project','discussion','review','other') DEFAULT 'lecture',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_topic_course
        FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_topic_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL,
    CONSTRAINT uq_topic_per_course UNIQUE (course_id, topic_name)  -- Prevent duplicate topic names per course
    CONSTRAINT chk_topic_name_format CHECK (topic_name REGEXP '^[A-Za-z0-9 ]{3,100}$');
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index improves joins between topics and courses
CREATE INDEX idx_topic_course ON topics(course_id);
-- Index speeds up filtering topics created by user
CREATE INDEX idx_topic_user ON topics(user_id);



-- ------------------------------------------------------------
-- tasks
-- (Assignments, projects, and to-dos tracked by users)
-- ------------------------------------------------------------
CREATE TABLE tasks (
    task_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT DEFAULT NULL,
    topic_id BIGINT DEFAULT NULL,
    title VARCHAR(200) NOT NULL,
    due_date DATETIME,
    status ENUM('todo','in_progress','done') DEFAULT 'todo',
    priority TINYINT NOT NULL DEFAULT 3,
    category ENUM('assignment','project','exam_prep','quiz','reading','lab',
                  'meeting','presentation','revision','misc') DEFAULT 'assignment',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_task_course
        FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE SET NULL,
    CONSTRAINT fk_task_topic
        FOREIGN KEY (topic_id) REFERENCES topics(topic_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_priority_range CHECK (priority BETWEEN 1 AND 5)
    CONSTRAINT chk_task_title_format CHECK (title REGEXP '^[A-Za-z0-9 ,.!?-]{3,100}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index speeds up dashboard queries filtering by user, status, and due date
CREATE INDEX idx_task_user_status_due ON tasks(user_id, status, due_date);
-- Index helps joins with course/topic
CREATE INDEX idx_task_course ON tasks(course_id);
CREATE INDEX idx_task_topic ON tasks(topic_id);

-- ------------------------------------------------------------
-- timerSessions
-- (Represents focus or Pomodoro sessions)
-- ------------------------------------------------------------
CREATE TABLE timerSessions (
    timer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    host_id BIGINT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    duration_min INT GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, start_time, end_time)) STORED,
    topic_id BIGINT DEFAULT NULL,
    technique_type ENUM('pomodoro','flowtime','custom') DEFAULT 'pomodoro',
    short_break_min TINYINT DEFAULT NULL,
    long_break_min  TINYINT DEFAULT NULL,
    session_type ENUM('solo','group') DEFAULT 'solo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_timer_host
        FOREIGN KEY (host_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_timer_topic
        FOREIGN KEY (topic_id) REFERENCES topics(topic_id)
        ON DELETE SET NULL,
    CONSTRAINT chk_time_order CHECK (end_time > start_time),
    CONSTRAINT chk_max_duration CHECK (TIMESTAMPDIFF(MINUTE,start_time,end_time) <= 120),
    CONSTRAINT chk_short_break CHECK (short_break_min BETWEEN 1 AND 30),
    CONSTRAINT chk_long_break  CHECK (long_break_min BETWEEN 5 AND 60)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index speeds up filtering sessions by host and time
CREATE INDEX idx_timer_host_start ON timerSessions(host_id, start_time);
-- Index supports joins on topic
CREATE INDEX idx_timer_topic ON timerSessions(topic_id);

-- ------------------------------------------------------------
-- sessionParticipants
-- (Users participating in timer sessions)
-- ------------------------------------------------------------
CREATE TABLE sessionParticipants (
    timer_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    role ENUM('host','member') DEFAULT 'member',
    PRIMARY KEY (timer_id, user_id),
    CONSTRAINT fk_participant_timer
        FOREIGN KEY (timer_id) REFERENCES timerSessions(timer_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_participant_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index improves participant lookup by user
CREATE INDEX idx_participant_user ON sessionParticipants(user_id);

-- ------------------------------------------------------------
-- dailyFocusLog
-- (Daily log tracking user’s total focus time and sessions)
-- ------------------------------------------------------------
CREATE TABLE dailyFocusLog (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    focus_date DATE NOT NULL,
    total_sessions INT DEFAULT 0,
    total_focus_min INT DEFAULT 0,
    focus_start_times JSON,
    focus_topics JSON,
    item_earned_id BIGINT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_focuslog_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_user_date UNIQUE (user_id, focus_date)   -- Unique daily record per user
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- studyStats
-- (Aggregated user performance metrics)
-- ------------------------------------------------------------
CREATE TABLE studyStats (
    user_id BIGINT PRIMARY KEY,
    total_sessions INT DEFAULT 0,
    total_focus_time_min INT DEFAULT 0,
    avg_duration_min DECIMAL(6,2),
    longest_streak_days INT DEFAULT 0,
    current_streak_days INT DEFAULT 0,
    last_session_at DATETIME,
    favorite_item_type ENUM('plant','animal','house','floor','decoration',
                            'structure','other'),
    favorite_item_name VARCHAR(100),
    most_frequent_topic BIGINT,
    CONSTRAINT fk_stats_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_stats_topic
        FOREIGN KEY (most_frequent_topic) REFERENCES topics(topic_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index accelerates lookups by frequent topic
CREATE INDEX idx_stats_topic ON studyStats(most_frequent_topic);

-- ------------------------------------------------------------
-- focusItems
-- (Collectible or reward items users can earn)
-- ------------------------------------------------------------
CREATE TABLE focusItems (
    item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_type ENUM('plant','animal','house','floor','decoration',
                   'vehicle','structure','other') NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    image_url VARCHAR(255),
    rarity_level ENUM('common','rare','epic','legendary') DEFAULT 'common',
    focus_cost_min INT DEFAULT 0,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index to quickly filter by rarity or type (optional if performance needed)
CREATE INDEX idx_focus_type ON focusItems(item_type);

-- ------------------------------------------------------------
-- userFocusItems
-- (Items owned by each user)
-- ------------------------------------------------------------
CREATE TABLE userFocusItems (
    user_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    quantity INT DEFAULT 0,
    last_earned_at DATETIME,
    is_placed BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, item_id),
    CONSTRAINT fk_user_item_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_user_item_item
        FOREIGN KEY (item_id) REFERENCES focusItems(item_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index assists queries filtering by item
CREATE INDEX idx_user_item_item ON userFocusItems(item_id);

-- ------------------------------------------------------------
-- userCityLayout
-- (Where users arrange their focus items in a virtual city)
-- ------------------------------------------------------------
CREATE TABLE userCityLayout (
    layout_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    position_x INT NOT NULL,
    position_y INT NOT NULL,
    placed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_city_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_city_item
        FOREIGN KEY (item_id) REFERENCES focusItems(item_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Indexes optimize retrieval of layout by user or item
CREATE INDEX idx_city_user ON userCityLayout(user_id);
CREATE INDEX idx_city_item ON userCityLayout(item_id);

-- ------------------------------------------------------------
-- monthlyChallenges
--()
-- ------------------------------------------------------------
CREATE TABLE monthlyChallenges (
    challenge_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    goal_minutes INT DEFAULT 600,
    reward_item_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_challenge_reward
        FOREIGN KEY (reward_item_id) REFERENCES focusItems(item_id)
        ON DELETE SET NULL
    CONSTRAINT chk_challenge_title_format CHECK (title REGEXP '^[A-Za-z0-9 ]{3,150}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index speeds reward lookups
CREATE INDEX idx_challenge_reward ON monthlyChallenges(reward_item_id);

-- ------------------------------------------------------------
-- userChallengeProgress
-- (Tracks each user’s progress toward completing monthly study challenges)
-- ------------------------------------------------------------
CREATE TABLE userChallengeProgress (
    user_id BIGINT NOT NULL,
    challenge_id BIGINT NOT NULL,
    total_minutes INT DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at DATETIME,
    PRIMARY KEY (user_id, challenge_id),
    CONSTRAINT fk_progress_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_progress_challenge
        FOREIGN KEY (challenge_id) REFERENCES monthlyChallenges(challenge_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index speeds up aggregation by challenge
CREATE INDEX idx_progress_challenge ON userChallengeProgress(challenge_id);

-- ------------------------------------------------------------
-- moodTracking
-- (Records users’ daily moods linked to their focus sessions for emotional tracking)
-- ------------------------------------------------------------
CREATE TABLE moodTracking (
    mood_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    timer_id BIGINT,
    mood_level ENUM('very_bad','bad','neutral','good','great') DEFAULT 'neutral',
    note VARCHAR(255),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mood_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_mood_timer
        FOREIGN KEY (timer_id) REFERENCES timerSessions(timer_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index supports filtering moods by user or timer
CREATE INDEX idx_mood_user ON moodTracking(user_id);
CREATE INDEX idx_mood_timer ON moodTracking(timer_id);


-- ------------------------------------------------------------
-- leaderboardStats
-- (Stores each user’s cumulative study performance used to display leaderboards)
-- ------------------------------------------------------------
CREATE TABLE leaderboardStats (
    leaderboard_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id          BIGINT NOT NULL,
    total_focus_min  INT   DEFAULT 0,
    total_sessions   INT   DEFAULT 0,
    streak_days      INT   DEFAULT 0,
    period_type      ENUM('daily','weekly','monthly','all_time') DEFAULT 'weekly',
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_leader_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Index supports pulling a user’s row fast
CREATE INDEX idx_leader_user ON leaderboardStats(user_id);



-- ------------------------------------------------------------
-- reminders
-- (Notifications tied to tasks)
-- ------------------------------------------------------------
CREATE TABLE reminders (
    reminder_id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    task_id       BIGINT NOT NULL,
    reminder_time DATETIME NOT NULL,
    method        ENUM('in_app','email','sms') DEFAULT 'in_app',
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_reminder_task
        FOREIGN KEY (task_id) REFERENCES tasks(task_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- Indexes for upcoming reminders and task lookups
CREATE INDEX idx_reminder_time ON reminders(reminder_time);
CREATE INDEX idx_reminder_task ON reminders(task_id);
