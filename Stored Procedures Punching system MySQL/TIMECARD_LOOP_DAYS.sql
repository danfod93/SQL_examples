# TIMECARD

# DROP PROCEDURE: Remove the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS load_timecard_test_data;

# CREATE PROCEDURE
DELIMITER #
CREATE PROCEDURE load_timecard_test_data()
BEGIN
    /*
    Step 1: Declare variables for the loop and initialize them
    - day_max: Total number of days to process (default is 31)
    - day_counter: Counter to track the current day (starts at 1)
    - date: Start date for timecard entries (default is '2019-10-01')
    - user: User ID for whom timecard data is generated (default is 'USER')
    */
    DECLARE day_max INT UNSIGNED DEFAULT 31;
    DECLARE day_counter INT UNSIGNED DEFAULT 1;
    DECLARE `date` DATE DEFAULT '2019-10-01';
    DECLARE `user` VARCHAR(6) DEFAULT 'USER';

    /*
    Step 2: Delete existing timecard records for the given user
    - Ensures no duplicate or conflicting data exists before inserting new records
    */
    DELETE
    FROM timecard
    WHERE timecard_user = 'USER';
        
    /*
    Step 3: Start a transaction to ensure atomicity
    - All changes will be committed together or rolled back in case of an error
    */
    START TRANSACTION;

    /*
    Step 4: Loop through the days and insert timecard entries
    - For each day, insert a series of 'in' and 'out' events to simulate a workday
    */
    WHILE day_counter < day_max DO
        INSERT INTO timecard
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
        Step 4.1: Increment the day counter and move to the next date
        - day_counter: Tracks the number of processed days
        - date: Advances to the next day
        */
        SET day_counter = day_counter + 1;
        SET `date` = DATE_ADD(`date`, INTERVAL +1 DAY);
    END WHILE;

    /*
    Step 5: Commit the transaction to save changes
    - Ensures all inserted records are saved to the database
    */
    COMMIT;
END #
DELIMITER ;

# CALL THE FUNCTION: Example of calling the procedure to generate test data
CALL load_timecard_test_data();

# TESTING - SELECT TIMECARD DATA: Verify the inserted timecard data for the user
SELECT * FROM timecard
WHERE timecard_user = 'USER' ORDER BY id;

# SANITIZE - DELETE TIMECARD DATA: Clean up timecard data for the user
DELETE FROM timecard
WHERE timecard_user = 'USER';