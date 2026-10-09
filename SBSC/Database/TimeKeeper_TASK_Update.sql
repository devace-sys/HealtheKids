USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TASK_Update]    Script Date: 1/25/2020 9:38:35 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TASK_Update]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TASK_Update]    Script Date: 1/25/2020 9:38:35 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TASK_Update]
	@Id                             bigint,
	@taskType						BIGINT,
	@name							VARCHAR(300),
    @description                    varchar(max),
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
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TASK_Update] 
			@Id                            
			,@taskType						
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
	
END


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TASK_Update]  TO [webuser]
GO


