USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntry]    Script Date: 1/25/2020 9:18:56 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntry]    Script Date: 1/25/2020 9:18:56 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntry]
(
	 @timeEntryDayID	bigint
	,@timeOfTask		datetime
	,@numberMinutes		int
	,@timeEntrytaskID	bigint
	,@orgClientID		bigint
	,@note				varchar(max)
	,@dateEntryCreated  datetime
    ,@IsProjectManagement bit
    ,@IsHelpDesk        bit
    ,@ITPM_ID           varchar(50)
    ,@HD_ROW_ID         varchar(50)
    ,@Description       varchar(max)
    ,@FileNameReference varchar(max)
	,@FileComments varchar(max)
	,@FileComplete bit
	,@HasMultipleClients bit
	,@StartEntryDateTime datetime
	,@EndEntryDateTime datetime
        ,@e_id bigint
	,@Id						 BIGINT OUTPUT
)    
AS 
   
BEGIN  
  
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_CreateTimeEntry] @timeEntryDayID	
		,@timeOfTask		
		,@numberMinutes		
		,@timeEntrytaskID	
		,@orgClientID		
		,@note				
		,@dateEntryCreated  
		,@IsProjectManagement 
		,@IsHelpDesk        
		,@ITPM_ID           
		,@HD_ROW_ID         
		,@Description       
		,@FileNameReference
		,@FileComments 
		,@FileComplete
		,@HasMultipleClients
		,@StartEntryDateTime
	    ,@EndEntryDateTime
            ,@e_id
		,@Id OUTPUT

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_CreateTimeEntry]  TO [webuser]
GO


