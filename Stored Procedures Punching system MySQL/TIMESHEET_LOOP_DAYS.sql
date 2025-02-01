# TIMESHEET

# DROP PROCEDURE: Remove the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS load_timesheet_test_data;

# CREATE PROCEDURE
DELIMITER #
CREATE PROCEDURE load_timesheet_test_data()
BEGIN
    /*
    Step 1: Declare variables for the loop and initialize them
    - day_max: Total number of days to process (default is 31)
    - day_counter: Counter to track the current day (starts at 1)
    - date: Start date for timesheet entries (default is '2019-10-01')
    - user: User ID for whom timesheet data is generated (default is 'USER')
    */
    DECLARE day_max INT UNSIGNED DEFAULT 31;
    DECLARE day_counter INT UNSIGNED DEFAULT 1;
    DECLARE `date` DATE DEFAULT '2019-10-01';
    DECLARE `user` VARCHAR(6) DEFAULT 'USER';

    /*
    Step 2: Delete existing timesheet records for the given user
    - Ensures no duplicate or conflicting timesheet data exists before inserting new records.
    */
    DELETE
    FROM timesheet
    WHERE timesheet_user = 'USER';
      
    /*
    Step 3: Start a transaction to ensure atomicity
    - All changes will be committed together or rolled back in case of an error.
    */
    START TRANSACTION;

    /*
    Step 4: Loop through the days until the day_counter reaches day_max
    - For each day, insert timesheet entries with predefined time intervals.
    */
    WHILE day_counter < day_max DO
        /*
        Step 4.1: Insert timesheet entries for the current day
        - Simulates a typical workday with multiple time intervals (in/out events).
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
        (`user`, `date`, '07:15:00', '10:00:00', '336668', '0', ''),
        (`user`, `date`, '10:15:00', '12:00:00', '336668', '0', ''),
        (`user`, `date`, '12:45:00', '16:15:00', '336668', '0', '');
        
        /*
        Step 4.2: Increment the day counter and move to the next date
        - Advances the loop to process the next day.
        */
        SET day_counter = day_counter + 1;
        SET `date` = DATE_ADD(`date`, INTERVAL +1 DAY);
    END WHILE;

    /*
    Step 5: Commit the transaction to save changes
    - Ensures all inserted records are saved to the database.
    */
    COMMIT;
END #
DELIMITER ;

# CALL THE PROCEDURE: Example of calling the procedure to generate timesheet data
CALL load_timesheet_test_data();

# TESTING - SELECT: Verify the inserted timesheet data for the user
SELECT * FROM timesheet
WHERE timesheet_user = 'USER';
	
# SANITIZE - DELETE: Clean up timesheet data for the user
DELETE
FROM timesheet
WHERE timesheet_user = 'USER';