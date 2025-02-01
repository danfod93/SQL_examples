# LEAVE

# DROP PROCEDURE: Remove the procedure if it already exists to avoid conflicts
DROP PROCEDURE IF EXISTS insert_leaves;

# CREATE PROCEDURE
DELIMITER //

CREATE PROCEDURE insert_leaves(`user` VARCHAR(6), `status` VARCHAR(50), `department` VARCHAR(50)) 
BEGIN
    /*
    Step 1: Delete existing leave records for the given user
    - Ensures no duplicate or conflicting leave data exists before inserting new records.
    */
    DELETE
    FROM timesheet_data_leave
    WHERE leave_user_id = 'USER';

    /*
    Step 2: Insert new leave records for the user with predefined dates and details
    - Adds multiple leave entries for the user with specific leave types, dates, and comments.
    */
    INSERT IGNORE INTO timesheet_data_leave
                (`leave_department`,
                 `leave_user_id`,
                 `leave_type`,
                 `leave_date`,
                 `leave_time_hours`,
                 `leave_status`,
                 `leave_comment`,
                 `leave_booked_by`,
                 `leave_timestamp`)
    VALUES (`department`, `user`, '000033', '2019-10-10', '8.00', `status`, 'Sick Leave Test', `user`, '2019-10-25 11:00:00'),
           (`department`, `user`, '000033', '2019-10-11', '8.00', `status`, 'Sick Leave Test', `user`, '2019-10-25 11:02:00'),
           (`department`, `user`, '000021', '2019-11-06', '8.00', `status`, 'Personal Leave Test', `user`, '2019-10-25 11:04:00'),
           (`department`, `user`, '000021', '2019-11-15', '8.00', `status`, 'Personal Leave Test', `user`, '2019-10-25 11:06:00'),
           (`department`, `user`, '000021', '2019-12-19', '8.00', `status`, 'Personal Leave Test', `user`, '2019-10-25 11:08:00'),
           (`department`, `user`, '000021', '2019-12-20', '8.00', `status`, 'Personal Leave Test', `user`, '2019-10-25 11:10:00');
    
    /*
    Step 3: Remove corresponding timecard entries for the leave dates
    - Deletes timecard records for the user that overlap with the leave dates.
    */
    DELETE
    FROM timecard
    WHERE timecard_user = 'USER'
    AND DATE(timecard_timestamp) IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');

    /*
    Step 4: Remove corresponding timesheet entries for the leave dates
    - Deletes timesheet records for the user that overlap with the leave dates.
    */
    DELETE
    FROM timesheet
    WHERE timesheet_user = 'USER'
    AND timesheet_date IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');
    
END; //

DELIMITER ;

# CALL THE PROCEDURE: Example of calling the procedure to insert leave data
CALL insert_leaves('USER', 'Approved', '000236');
 
# TESTING 1 - SELECT: Verify leave records for the user
SELECT * FROM timesheet_data_leave
WHERE leave_user_id = 'USER';

# TESTING 2 - SELECT: Verify leave records for specific dates
SELECT * FROM timesheet_data_leave
WHERE leave_user_id = 'USER'
AND leave_date IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');
        
# SANITIZE - DELETE LEAVE DATA of the given user_id
DELETE
FROM timesheet_data_leave
WHERE leave_user_id = 'USER';

# TESTING 3 - DELETE LEAVE DAYS FROM TIMECARD
DELETE
FROM timecard
WHERE timecard_user = 'USER'
AND DATE(timecard_timestamp) IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');

# TESTING 3 - SELECT TIMECARD AFTER DELETION
SELECT * FROM timecard
WHERE timecard_user = 'USER'
AND timecard_timestamp IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');

# TESTING 4 - DELETE LEAVE DAYS FROM TIMESHEET
DELETE
FROM timesheet
WHERE timesheet_user = 'USER'
AND timesheet_date IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');

# TESTING 4 - SELECT TIMESHEET AFTER DELETION
SELECT * FROM timesheet
WHERE timesheet_user = 'USER'
AND timesheet_date IN ('2019-10-10', '2019-10-11', '2019-11-06', '2019-11-15', '2019-12-19', '2019-12-20');