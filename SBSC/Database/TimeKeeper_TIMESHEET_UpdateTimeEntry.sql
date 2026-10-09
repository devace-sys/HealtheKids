USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntry]    Script Date: 1/25/2020 9:29:43 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntry]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntry]    Script Date: 1/25/2020 9:29:43 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntry]
(
	 @Id bigint
	,@timeEntryDayID bigint
	,@timeOfTask datetime
	,@numberMinutes int
	,@timeEntrytaskID bigint
	,@orgClientID bigint
	,@note varchar(max)
	,@dateEntryUpdated datetime
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
)    
AS
    
BEGIN  
  
SET NOCOUNT ON;
	  
	exec [TimeKeeper].[dbo].[TIMESHEET_UpdateTimeEntry] 
			@Id
			,@timeEntryDayID
			,@timeOfTask
			,@numberMinutes
			,@timeEntrytaskID
			,@orgClientID
			,@note
			,@dateEntryUpdated
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

 

END

GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TimeKeeper_TIMESHEET_UpdateTimeEntry] TO [webuser]
GO

