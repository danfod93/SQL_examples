# TIMESHEET WORKDAYS

# DROP PROCEDURE: Remove the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS insert_timesheet_workdays_data;

# CREATE PROCEDURE
DELIMITER #
CREATE PROCEDURE insert_timesheet_workdays_data(day_max INT UNSIGNED, day_counter INT UNSIGNED, `date` DATE, `user` VARCHAR(6), `weekday` VARCHAR(50))
BEGIN
    /*
    Step 1: Delete existing timesheet records for the given user
    - Ensures no duplicate or conflicting timesheet data exists before inserting new records.
    */
    DELETE
    FROM timesheet
    WHERE timesheet_user = `user`;
      
    /*
    Step 2: Start a transaction to ensure atomicity
    - All changes will be committed together or rolled back in case of an error.
    */
    START TRANSACTION;

    /*
    Step 3: Loop through the days until the day_counter reaches day_max
    - For each day, check if it's a weekday and insert timesheet entries accordingly.
    */
    myloop: WHILE day_counter < day_max DO
    
        /*
        Step 3.1: Determine the day of the week for the current date
        - Use DATE_FORMAT to extract the weekday name (e.g., Monday, Tuesday).
        */
        SET `weekday` = DATE_FORMAT(`date`, '%W');

        /*
        Step 3.2: Skip weekends (Saturday and Sunday)
        - If the day is a weekend, increment the counter and move to the next date.
        */
        IF `weekday` IN ('Saturday', 'Sunday') THEN
            SET day_counter = day_counter + 1;
            SET `date` = DATE_ADD(`date`, INTERVAL +1 DAY);
            ITERATE myloop;
        END IF;
    
        /*
        Step 3.3: Insert timesheet entries for a workday
        - Simulates a typical workday with multiple time intervals and predefined combinations, destinations, and comments.
        */
        INSERT INTO timesheet
        (`timesheet_user`,
        `timesheet_date`,
        `timesheet_time_in`,
        `timesheet_time_out`,
        `timesheet_combination`,
        `timesheet_destination`,
        `timesheet_comment`)
        VALUES 
        (`user`, `date`, '07:15:00', '10:00:00', '336713', '93', 'SD00206 - Destinations Table'),
        (`user`, `date`, '10:15:00', '12:00:00', '336693', '93', 'QS0046 - Internal vacancy'),
        (`user`, `date`, '12:45:00', '16:15:00', '336710', '93', 'QS0039 - Email Monitoring Software');
        
        /*
        Step 3.4: Increment the day counter and move to the next date
        - Advances the loop to process the next day.
        */
        SET day_counter = day_counter + 1;
        SET `date` = DATE_ADD(`date`, INTERVAL +1 DAY);
    
    END WHILE myloop;

    /*
    Step 4: Commit the transaction to save changes
    - Ensures all inserted records are saved to the database.
    */
    COMMIT;
END #
DELIMITER ;

# CALL THE PROCEDURE: Example of calling the procedure to generate timesheet data
CALL insert_timesheet_workdays_data('364', '0', '2019-01-01', 'USER', '');

# TESTING - SELECT TIMESHEET DATA: Verify the inserted timesheet data for the user
SELECT * FROM timesheet
WHERE timesheet_user = 'USER';
	
# SANITIZE - DELETE TIMESHEET DATA: Clean up timesheet data for the user
DELETE
FROM timesheet
WHERE timesheet_user = 'USER';