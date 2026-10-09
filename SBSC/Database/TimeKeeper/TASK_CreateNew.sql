USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TASK_CreateNew]    Script Date: 8/13/2020 10:35:46 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TASK_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[TASK_CreateNew]    Script Date: 8/13/2020 10:35:46 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TASK_CreateNew]
(
	@taskType						BIGINT,
	@name							VARCHAR(300),
    @description                                            VARCHAR(max),
	@ttfn_code				        BIGINT,
    @defaultMinDuration				SMALLINT,
	@defaultClient					BIGINT,
	@active							BIT,
	@IsProjectManagementRequired	BIT,
	@IsITHelpDeskRequired			BIT,
	@IsITPM_ID_Required				BIT,
	@IsHD_ROW_ID_Required			BIT,
	@IsDescriptionRequired			BIT,
	@IsFileNameReferenceRequired	BIT,
	@CanBeScheduledInTheFuture      BIT,
	@CanHaveMultipleClients         BIT,
	@SpecifyStartStopTime                 BIT,
    @Id								BIGINT OUTPUT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	DECLARE @TaskCount INT
	
	SELECT 
		@TaskCount=count(*) 
	FROM
		[TimeKeeper].[dbo].[TimeEntry_Tasks]
	WHERE
		[name] = @Name

	if (@TaskCount = 0)
	begin
		 INSERT INTO [TimeKeeper].[dbo].[TimeEntry_Tasks]
		(
			 [taskType]
			,[name]
            ,[Task_description]
            ,[TTFN_code] 
			,[defaultMinDuration]
			,[defaultClient]
			,[active]
			,[IsProjectManagementRequired]
			,[IsITHelpDeskRequired]
			,[IsITPM_ID_Required]
			,[IsHD_ROW_ID_Required]
			,[IsDescriptionRequired]
			,[IsFileNameReferenceRequired]
			,[CanBeScheduledInTheFuture]
			,[CanHaveMultipleClients]
			,[SpecifyStartStopTime]
		)	
		VALUES
		(
			 @taskType
			,@name
            ,@description
            ,@ttfn_code
			,@defaultMinDuration
			,@defaultClient
			,@active
			,@IsProjectManagementRequired
			,@IsITHelpDeskRequired
			,@IsITPM_ID_Required
			,@IsHD_ROW_ID_Required
			,@IsDescriptionRequired
			,@IsFileNameReferenceRequired
			,@CanBeScheduledInTheFuture
			,@CanHaveMultipleClients
			,@SpecifyStartStopTime
		)	
		SET @Id = SCOPE_IDENTITY()
	end
	else
	begin
		if (@TaskCount = 1)
		begin
			Select 
				@Id = id
			FROM
				[TimeKeeper].[dbo].[TimeEntry_Tasks]
			WHERE
				[name] = @Name		
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

GRANT EXECUTE ON [dbo].[TASK_CreateNew] TO [webuser]
GO



