USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TASK_Update]    Script Date: 1/25/2020 8:05:08 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TASK_Update]
GO

/****** Object:  StoredProcedure [dbo].[TASK_Update]    Script Date: 1/25/2020 8:05:08 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TASK_Update]
(
	@Id bigint,
	@taskType						BIGINT,
	@name							VARCHAR(300),
    @description                                            varchar(max),
    @ttfn_code                      bigint,
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
	@SpecifyStartStopTime                 BIT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	UPDATE [TimeKeeper].[dbo].[TimeEntry_Tasks]
	   SET 
			 [taskType]                     =  @taskType
			,[name]                         =  @name
            ,[Task_description]             = @description
            ,[TTFN_code]                    = @ttfn_code                      
			,[defaultMinDuration]			=  @defaultMinDuration			 
			,[defaultClient]				=  @defaultClient				 
			,[active]						=  @active						 
			,[IsProjectManagementRequired]	=  @IsProjectManagementRequired	 
			,[IsITHelpDeskRequired]			=  @IsITHelpDeskRequired			 
			,[IsITPM_ID_Required]			=  @IsITPM_ID_Required			 
			,[IsHD_ROW_ID_Required]			=  @IsHD_ROW_ID_Required			 
			,[IsDescriptionRequired]		=  @IsDescriptionRequired		 
			,[IsFileNameReferenceRequired]	=  @IsFileNameReferenceRequired	 
			,[CanBeScheduledInTheFuture]	=  @CanBeScheduledInTheFuture
			,[CanHaveMultipleClients]       =  @CanHaveMultipleClients
			,[SpecifyStartStopTime] = @SpecifyStartStopTime
	 WHERE 									 
		Id = @Id

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TASK_Update] TO [webuser]
GO



