
-- Trigger to enforce one owner only
-- Will work on optimizing this later... 

DELIMITER //
CREATE TRIGGER one_owner_only
BEFORE INSERT ON Group_Member
FOR EACH ROW
BEGIN
    DECLARE owner_count INT DEFAULT 0;
    -- count

    -- only check when trying to add an owner
    IF NEW.role = 'owner' THEN
        SELECT COUNT(*) INTO owner_count
        FROM Group_Member
        WHERE group_id = NEW.group_id
        AND role = 'owner';
        IF owner_count > 0 THEN
            -- stop the insert by setting a bad value or doing nothing
            SET NEW.role = NULL;
        END IF;
    END IF;
END//
DELIMITER ;

-- making sure end time before start time
ALTER TABLE Study_Session
ADD CONSTRAINT chk_time CHECK (end_time > start_time);
