USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateTimeEntryDay]    Script Date: 1/25/2020 8:02:37 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_CreateTimeEntryDay]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_CreateTimeEntryDay]    Script Date: 1/25/2020 8:02:37 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_CreateTimeEntryDay]
(
  @EmployeeId                BIGINT,
  @dateForTimeEntry          DATE,
  @Id						 BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;

    DECLARE @Count INT
	SELECT 
		@Count=Count(*)
	FROM
		 [TimeKeeper].[dbo].[TimeEntry_Day]
	WHERE
		employeeID = @EmployeeId
		AND dateForTimeEntry = @dateForTimeEntry
	
	if (@Count = 0)
	BEGIN  
		INSERT INTO [TimeKeeper].[dbo].[TimeEntry_Day]
		(
			employeeID,
			dateForTimeEntry
		)
		VALUES
		(
			@EmployeeId,
			@dateForTimeEntry
		)
	
		SET @Id = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT TOP 1
			@Id = id
		FROM
			[TimeKeeper].[dbo].[TimeEntry_Day]
		WHERE
			employeeID = @EmployeeId
			AND dateForTimeEntry = @dateForTimeEntry
	END

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_CreateTimeEntryDay]  TO [webuser]
GO


