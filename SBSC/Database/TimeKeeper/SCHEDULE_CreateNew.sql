USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_CreateNew]    Script Date: 1/25/2020 8:06:18 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[SCHEDULE_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[SCHEDULE_CreateNew]    Script Date: 1/25/2020 8:06:18 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SCHEDULE_CreateNew]
(
  @EmployeeId                BIGINT,
  @ScheduleApproveId         BIGINT,
  @DateOfSchedule            DATETIME,
  @Id						 BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	DECLARE @ScheduleCount INT
	
	SELECT 
		@ScheduleCount=count(*) 
	FROM
		[TimeKeeper].[dbo].[Schedule]
	WHERE
		employeeID = @EmployeeId
		AND DATEADD(dd, DATEDIFF(dd, 0, dateOfSchedule), 0) = DATEADD(dd, DATEDIFF(dd, 0, @DateOfSchedule), 0)

	if (@ScheduleCount = 0)
	begin
		INSERT INTO [TimeKeeper].[dbo].[Schedule]
		(
			employeeID,
			scheduleApprovedId,
			dateOfSchedule
		)
		VALUES
		(
			@EmployeeId,
			@ScheduleApproveId,
			@DateOfSchedule
		)
	
		SET @Id = SCOPE_IDENTITY()
	end
	else
	begin
		if (@ScheduleCount = 1)
		begin
			Select 
				@Id = id
			from
				[TimeKeeper].[dbo].[Schedule]
			WHERE
				employeeID = @EmployeeId
				AND DATEADD(dd, DATEDIFF(dd, 0, dateOfSchedule), 0) = DATEADD(dd, DATEDIFF(dd, 0, @DateOfSchedule), 0)
		end
		else
		begin
			SET @Id = -1
		end
	end

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[SCHEDULE_CreateNew] TO [webuser]
GO




