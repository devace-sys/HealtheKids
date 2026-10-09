USE [SPEDMON]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryById]    Script Date: 1/25/2020 9:27:39 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryById]
GO

/****** Object:  StoredProcedure [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryById]    Script Date: 1/25/2020 9:27:39 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryById] 
(
  @Id                BIGINT
)    
AS    
BEGIN    
    
/***************************************************************************    
 * TimeKeeper_TIMESHEET_GetTimeEntryById */    
/**    
 * Gets personal Timesheet 
 *    d
 * @param   PersonID        Unique key that identifies person in timesheet database
 ***************************************************************************/    
    
SET NOCOUNT ON    
	
	exec [TimeKeeper].[dbo].[TIMESHEET_GetTimeEntryById] @id
	    
END    


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TimeKeeper_TIMESHEET_GetTimeEntryById]  TO [webuser]
GO


