# TIMECARD WORKDAYS

# DROP PROCEDURE: Remove the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS insert_timecard_workdays_data;

# CREATE PROCEDURE
DELIMITER #
CREATE PROCEDURE insert_timecard_workdays_data(day_max INT UNSIGNED, day_counter INT UNSIGNED, `date` DATE, `user` VARCHAR(6), `weekday` VARCHAR(50), relid INT)
BEGIN
    /*
    Step 1: Initialize `relid` with the maximum ID from the timecard table
    - This ensures that new entries can reference the latest ID for relational purposes.
    */
    SET relid = (SELECT MAX(id) FROM timecard);

    /*
    Step 2: Delete all existing timecard records for the given user
    - Clears any previous data for the user to avoid duplication or conflicts.
    */
    DELETE
    FROM timecard
    WHERE timecard_user = `user`;
        
    /*
    Step 3: Start a transaction to ensure atomicity
    - All changes will be committed together or rolled back in case of an error.
    */
    START TRANSACTION;

    /*
    Step 4: Loop through the days until the day_counter reaches day_max
    - For each day, check if it's a weekday and insert timecard entries accordingly.
    */
    myloop: WHILE day_counter < day_max DO
  
        /*
        Step 4.1: Determine the day of the week for the current date
        - Use DATE_FORMAT to extract the weekday name (e.g., Monday, Tuesday).
        */
        SET `weekday` = DATE_FORMAT(`date`, '%W');

        /*
        Step 4.2: Skip weekends (Saturday and Sunday)
        - If the day is a weekend, increment the counter and move to the next date.
        */
        IF `weekday` IN ('Saturday','Sunday') THEN
            SET day_counter = day_counter + 1;
            SET `date` = DATE_ADD(`date`, INTERVAL +1 DAY);
            ITERATE myloop;
        END IF;
    
        /*
        Step 4.3: Insert timecard entries for a workday (in/out events)
        - Simulate a typical workday with multiple in/out events at specific times.
        */
        INSERT IGNORE INTO timecard
       (timecard_user,
        timecard_timestamp,
        timecard_event,
        timecard_booked_by,
        timecard_relid)
        VALUES 
        (`user`, CONCAT_WS(' ', `date`, '07:15:00'), 'in', `user`, NULL),
        (`user`, CONCAT_WS(' ', `date`, '10:00:00'), 'out', `user`, relid+1),
        (`user`, CONCAT_WS(' ', `date`, '10:15:00'), 'in', `user`, NULL),
        (`user`, CONCAT_WS(' ', `date`, '12:00:00'), 'out', `user`, relid+3),
        (`user`, CONCAT_WS(' ', `date`, '12:45:00'), 'in', `user`, NULL),
        (`user`, CONCAT_WS(' ', `date`, '16:15:00'), 'out', `user`, relid+5);
        
        /*
        Step 4.4: Update `relid` with the latest ID from the timecard table
        - Ensures that the next set of entries references the correct relational ID.
        */
        SET relid = (SELECT MAX(id) FROM timecard);

        /*
        Step 4.5: Increment the day counter and move to the next date
        - Advances the loop to process the next day.
        */
        SET day_counter = day_counter + 1;
        SET `date` = DATE_ADD(`date`, INTERVAL +1 DAY);
    
    END WHILE myloop;

    /*
    Step 5: Commit the transaction to save changes
    - Ensures all inserted records are saved to the database.
    */
    COMMIT;
END #
DELIMITER ;

# CALL THE PROCEDURE: Example of calling the procedure to generate timecard data
CALL insert_timecard_workdays_data('364', '0', '2019-01-01', 'USER', '', '0');

# TESTING - SELECT TIMECARD DATA: Verify the inserted timecard data for the user
SELECT * FROM timecard
WHERE timecard_user = 'USER' ORDER BY id;

# SANITIZE - DELETE TIMECARD DATA: Clean up timecard data for the user
DELETE FROM timecard
WHERE timecard_user = 'USER';
