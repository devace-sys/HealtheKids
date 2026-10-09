USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_CreateNewScheduleApproved]    Script Date: 1/25/2020 8:07:22 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_CreateNewScheduleApproved]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_CreateNewScheduleApproved]    Script Date: 1/25/2020 8:07:22 PM ******/

CREATE PROCEDURE [dbo].[SCHEDULE_CreateNewScheduleApproved]
(
  @EmployeeId                BIGINT,
  @StartDate				 DATE,
  @EndDate					 DATE,
  @Id						 BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	DECLARE @ScheduleCount INT
	
	SELECT 
		@ScheduleCount=count(*) 
	FROM
		[TimeKeeper].[dbo].[ScheduleApproved]
	WHERE
		employeeID = @EmployeeId
		AND startDate = @StartDate
		AND endDate = @endDate

	if (@ScheduleCount = 0)
	begin
		INSERT INTO [TimeKeeper].[dbo].[ScheduleApproved]
		(
			employeeID,
			startDate,
			endDate,
			isApproved
		)
		VALUES
		(
			@EmployeeId,
			@StartDate,
			@EndDate,
			0
		)
	
		SET @Id = SCOPE_IDENTITY()
	end
	else
	begin
		Select Top 1
			@Id = id
		from
			[TimeKeeper].[dbo].[ScheduleApproved]
		WHERE
			employeeID = @EmployeeId
			AND startDate = @StartDate
			AND endDate = @endDate
	end

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_CreateNewScheduleApproved] TO [webuser]
GO


