# TIMECARD WORKDAYS

# DROP PROCEDURE: Remove the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS insert_timecard_workdays_data;

# CREATE PROCEDURE
DELIMITER #
CREATE PROCEDURE insert_timecard_workdays_data()
BEGIN
    /*
    Step 1: Declare variables for the loop and initialize them
    - day_max: Total number of days to process (default is 31)
    - day_counter: Counter to track the current day (starts at 1)
    - date: Start date for timecard entries (default is '2019-10-01')
    - user: User ID for whom timecard data is generated (default is 'USER')
    - weekday: Stores the name of the day (e.g., Monday, Tuesday)
    */
    DECLARE day_max INT UNSIGNED DEFAULT 31;
    DECLARE day_counter INT UNSIGNED DEFAULT 1;
    DECLARE `date` DATE DEFAULT '2019-10-01';
    DECLARE `user` VARCHAR(6) DEFAULT 'USER';
    DECLARE `weekday` VARCHAR(50);

    /*
    Step 2: Delete existing timecard records for the given user
    - Ensures no duplicate or conflicting timecard data exists before inserting new records.
    */
    DELETE
    FROM timecard
    WHERE timecard_user = 'USER';
        
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
        IF `weekday` IN ('Saturday', 'Sunday') THEN
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
        timecard_booked_by)
        VALUES 
        (`user`, CONCAT_WS(' ', `date`, '07:15:00'), 'in', `user`),
        (`user`, CONCAT_WS(' ', `date`, '10:00:00'), 'out', `user`),
        (`user`, CONCAT_WS(' ', `date`, '10:15:00'), 'in', `user`),
        (`user`, CONCAT_WS(' ', `date`, '12:00:00'), 'out', `user`),
        (`user`, CONCAT_WS(' ', `date`, '12:45:00'), 'in', `user`),
        (`user`, CONCAT_WS(' ', `date`, '16:15:00'), 'out', `user`);
        
        /*
        Step 4.4: Increment the day counter and move to the next date
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
CALL insert_timecard_workdays_data();

# TESTING - SELECT TIMECARD DATA: Verify the inserted timecard data for the user
SELECT * FROM timecard
WHERE timecard_user = 'USER' ORDER BY id;

# SANITIZE - DELETE TIMECARD DATA: Clean up timecard data for the user
DELETE
FROM timecard
WHERE timecard_user = 'USER';