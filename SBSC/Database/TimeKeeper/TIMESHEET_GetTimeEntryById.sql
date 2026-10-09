USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntryById]    Script Date: 1/25/2020 7:14:45 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetTimeEntryById]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetTimeEntryById]    Script Date: 1/25/2020 7:14:45 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TIMESHEET_GetTimeEntryById] 
(
  @Id                BIGINT
)    
AS    
BEGIN    
    
/***************************************************************************    
 * TIMESHEET_GetTimeEntryById */    
/**    
 * Gets personal Timesheet 
 *    d
 * @param   PersonID        Unique key that identifies person in timesheet database
 ***************************************************************************/    
    
SET NOCOUNT ON    

	select
		TED.employeeID,
		O.name AS 'employer_name',
		O.id AS 'employer_id',
		ISNULL(ET.taskID, 0) AS ET_TaskID,
		ISNULL(OT.taskID, 0) AS OT_TaskID,
		ISNULL(PT.taskID, 0) AS PT_TaskID,
		ISNULL(PTE.taskID, 0) AS PTE_TaskID,
		ISNULL(PTE.projectID, 0) AS PTE_ProjectID,
		TE.*
	from
		TimeKeeper.dbo.TimeEntries TE
		INNER JOIN TimeKeeper.dbo.TimeEntry_Day TED
			ON TED.id = TE.timeEntryDayID
		INNER JOIN TimeKeeper.dbo.Employees E
			ON E.id = TED.employeeID
		INNER JOIN TimeKeeper.dbo.Organizations O
			ON O.id = E.organizationID
		INNER JOIN TimeKeeper.dbo.TimeEntry_Tasks TET
			ON TET.id = TE.timeEntrytaskID
		LEFT JOIN TimeKeeper.dbo.Employee_Tasks ET
			ON ET.taskID = TET.id
		LEFT JOIN TimeKeeper.dbo.Organization_Tasks OT
			ON OT.taskID = TET.id
		LEFT JOIN TimeKeeper.dbo.Position_Tasks PT
			ON PT.taskID = TET.id
		LEFT JOIN TimeKeeper.dbo.Project_TimeEntries PTE
			ON PTE.taskID = TET.id
	where
		TE.id = @Id
	    
END    


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetTimeEntryById]  TO [webuser]
GO


