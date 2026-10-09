USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TASK_CreateNew]    Script Date: 1/25/2020 9:38:35 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TASK_CreateNew]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TASK_CreateNew]    Script Date: 1/25/2020 9:38:35 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TASK_CreateNew]
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
	@SpecifyStartStopTime                 BIT,
    @Id								BIGINT OUTPUT
AS    
BEGIN    
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TASK_CreateNew] 
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
			,@Id							
	
END


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TASK_CreateNew]  TO [webuser]
GO


