/* 
   These indexes target frequent filter, join, and order-by patterns
   redeuces filesorts and improve range-scan
*/

-- Study_Group: filter by (course_id, is_private), then join by PK
-- Enables quick access to public groups for a course
CREATE INDEX idx_group_course_priv ON Study_Group(course_id, is_private, group_id);

-- Extra course to group path for cross-course queries (shared courses).
CREATE INDEX idx_group_course_group ON Study_Group(course_id, group_id);

-- Group_Member: enables lookups both by user and by group
-- “My Groups” lists and “Upcoming Sessions” joins.
CREATE INDEX idx_gm_user_group ON Group_Member(user_id, group_id);

-- Study_Session:
--  “today” sessions: session_date to group to start_time
--   User’s upcoming sessions: group to session_date to start_time
CREATE INDEX idx_session_date_group_start ON Study_Session(session_date, group_id, start_time);
CREATE INDEX idx_session_group_date_start ON Study_Session(group_id, session_date, start_time);

-- Join_Request: filters by join_status and ordering by expire_date or request_date.
-- Allows “Using index” reads instead of filesorts
CREATE INDEX idx_jr_status_expire_group ON Join_Request(join_status, expire_date, group_id, user_id, request_date);
CREATE INDEX idx_jr_status_reqdate_group ON Join_Request(join_status, request_date, group_id, user_id);

-- Chat_Message: chat history lookup by group and sent_time.
CREATE INDEX idx_chat_group_time ON Chat_Message(group_id, sent_time);

-- Message_Request: covering index for inbox filtering, sorting, and projection.
CREATE INDEX idx_mr_target_created ON Message_Request(target_user_id, created_at, request_id, requester_user_id, course_id, request_status);


/* 
   GROUP SUMMARY TABLE
   Stores precomputed aggregates to improve performance for
   group discovery queries (member counts and latest session)
 */

CREATE TABLE `Group_Summary` (
  `group_id` INT NOT NULL,                      -- Matches Study_Group.group_id
  `member_count` INT NOT NULL DEFAULT 0,        -- Cached total members
  `last_session` DATE NULL,                     -- Most recent session date
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                ON UPDATE CURRENT_TIMESTAMP,    -- Auto-updated timestamp
  PRIMARY KEY (`group_id`),
  CONSTRAINT `fk_gs_group`
    FOREIGN KEY (`group_id`)
    REFERENCES `Study_Group`(`group_id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/*
   Seeds Group_Summary with existing data
*/

INSERT INTO Group_Summary (group_id, member_count, last_session)
SELECT
  g.group_id,
  COALESCE((
    SELECT COUNT(DISTINCT gm.user_id)
    FROM Group_Member gm
    WHERE gm.group_id = g.group_id
  ), 0) AS member_count,
  (
    SELECT MAX(s.session_date)
    FROM Study_Session s
    WHERE s.group_id = g.group_id
  ) AS last_session
FROM Study_Group g
ON DUPLICATE KEY UPDATE
  member_count = VALUES(member_count),
  last_session = VALUES(last_session);


/* 
    AUTO-MAINTAINS
   Keeps summary table in sync as members/sessions change.
 */

DELIMITER //

-- When a member joins a group, increment count (insert if new)
DROP TRIGGER IF EXISTS gm_after_insert//
CREATE TRIGGER gm_after_insert
AFTER INSERT ON Group_Member
FOR EACH ROW
BEGIN
  INSERT INTO Group_Summary (group_id, member_count)
  VALUES (NEW.group_id, 1)
  ON DUPLICATE KEY UPDATE member_count = member_count + 1;
END//

-- When a member leaves or is removed, decrement count safely.
DROP TRIGGER IF EXISTS gm_after_delete//
CREATE TRIGGER gm_after_delete
AFTER DELETE ON Group_Member
FOR EACH ROW
BEGIN
  UPDATE Group_Summary
  SET member_count = GREATEST(member_count - 1, 0)
  WHERE group_id = OLD.group_id;
END//

-- When a new study session is added, update the group’s last_session date.
DROP TRIGGER IF EXISTS session_after_insert//
CREATE TRIGGER session_after_insert
AFTER INSERT ON Study_Session
FOR EACH ROW
BEGIN
  INSERT INTO Group_Summary (group_id, last_session)
  VALUES (NEW.group_id, NEW.session_date)
  ON DUPLICATE KEY UPDATE
    last_session = IF(last_session IS NULL OR NEW.session_date > last_session,
                      NEW.session_date, last_session);
END//

DELIMITER ;


/* 
   accurate EXPLAIN results.
 */
ANALYZE TABLE
  Study_Group,
  Group_Member,
  Study_Session,
  Join_Request,
  Chat_Message,
  Match_Profile,
  Message_Request,
  Resource,
  Group_Summary;


/* 
   Each query now benefits from indexing.
*/

-- Discover public groups for a course
-- Uses Group_Summary to avoid recalculating counts and last sessions
EXPLAIN ANALYZE
SELECT g.group_id, g.group_name, g.max_members,
       gs.member_count AS members,
       gs.last_session
FROM Study_Group AS g
LEFT JOIN Group_Summary AS gs ON gs.group_id = g.group_id
WHERE g.course_id = 420
  AND g.is_private = FALSE
ORDER BY (gs.last_session IS NULL) ASC,
         gs.last_session DESC,
         gs.member_count DESC
LIMIT 20;


-- Retrieve all groups a user belongs to, along with their role
EXPLAIN ANALYZE
SELECT g.group_id, g.group_name, gm.role
FROM Group_Member AS gm
JOIN Study_Group AS g ON g.group_id = gm.group_id
WHERE gm.user_id = 1001
ORDER BY g.group_name;


-- View pending join requests (for group owners)
EXPLAIN ANALYZE
SELECT g.group_name, jr.user_id, jr.request_date, jr.expire_date
FROM Join_Request AS jr
JOIN Study_Group AS g ON g.group_id = jr.group_id
WHERE jr.join_status = 'pending'
ORDER BY jr.expire_date;


-- List pending join requests and determine if user is already a member
EXPLAIN ANALYZE
SELECT jr.request_id, jr.group_id, jr.user_id,
       CASE WHEN gm.user_id IS NULL THEN 'NOT_MEMBER' ELSE 'ALREADY_MEMBER' END AS membership_state
FROM Join_Request AS jr
LEFT JOIN Group_Member AS gm
  ON gm.group_id = jr.group_id AND gm.user_id = jr.user_id
WHERE jr.join_status = 'pending'
ORDER BY jr.request_date DESC
LIMIT 50;


-- Display today’s sessions across all groups
EXPLAIN ANALYZE
SELECT g.group_name, s.location, s.session_date, s.start_time, s.end_time, s.notes
FROM Study_Session AS s
JOIN Study_Group AS g ON g.group_id = s.group_id
WHERE s.session_date = CURRENT_DATE()
ORDER BY g.group_name, s.start_time;


-- Show upcoming sessions for a specific user 
EXPLAIN ANALYZE
SELECT g.group_name, s.session_date, s.start_time, s.location
FROM Group_Member AS gm
JOIN Study_Session AS s ON s.group_id = gm.group_id
JOIN Study_Group AS g ON g.group_id = gm.group_id
WHERE gm.user_id = 1001
  AND s.session_date >= CURRENT_DATE()
ORDER BY s.session_date, s.start_time
LIMIT 50;


-- Fetch chat history efficiently using keyset pagination
EXPLAIN ANALYZE
SELECT c.message_id, c.user_id, c.content, c.sent_time
FROM Chat_Message AS c
WHERE c.group_id = 1
ORDER BY c.sent_time DESC, c.message_id DESC
LIMIT 50;

-- Example for next-page pagination:
-- SET @last_time := '2025-11-10 23:59:59'; SET @last_id := 12345;
-- SELECT ... WHERE c.sent_time < @last_time OR (c.sent_time = @last_time AND c.message_id < @last_id)
-- ORDER BY c.sent_time DESC, c.message_id DESC LIMIT 50;


-- Suggest study partners based on shared courses and compatible styles/preferences
EXPLAIN ANALYZE
WITH shared_peers AS (
  SELECT DISTINCT gm2.user_id
  FROM Group_Member gm1
  JOIN Study_Group  g1 ON g1.group_id = gm1.group_id
  JOIN Study_Group  g2 ON g2.course_id = g1.course_id
  JOIN Group_Member gm2 ON gm2.group_id = g2.group_id
  WHERE gm1.user_id = 1001 AND gm2.user_id <> 1001
)
SELECT mp2.user_id, mp2.study_style, mp2.meeting_pref
FROM Match_Profile mp1
JOIN Match_Profile mp2
  ON mp1.user_id = 1001
 AND mp2.user_id IN (SELECT user_id FROM shared_peers)
WHERE (mp2.meeting_pref = mp1.meeting_pref OR mp2.study_style <> mp1.study_style)
ORDER BY mp2.user_id
LIMIT 20;


-- Retrieve recent message requests (user inbox view)
EXPLAIN ANALYZE
SELECT mr.request_id, mr.requester_user_id, mr.course_id, mr.request_status, mr.created_at
FROM Message_Request AS mr
WHERE mr.target_user_id = 1001
ORDER BY mr.created_at DESC
LIMIT 50;


-- Fetch latest uploaded resources (read-only view)
EXPLAIN ANALYZE
SELECT resource_id, title, filetype, source
FROM Resource
ORDER BY resource_id DESC
LIMIT 25;
