USE [TimeKeeper]
GO

DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetTimeEntry]
GO



CREATE PROCEDURE [dbo].[TIMESHEET_GetTimeEntry]
(
	 @Id bigint
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
		SELECT
			TE.id
			,TE.timeEntryDayID
			,TE.numberMinutes
			,TE.timeOfTask
			,TE.StartEntryDateTime
			,TE.EndEntryDateTime
			,ISNULL(TES.name, '')  AS 'task'
			,ISNULL(TES.id, 0) AS 'task_id'
			,ISNULL(TKH.Name, '') AS 'holiday'
			,ISNULL(TKH.id, 0) AS 'holidayTaskID'
                
                                            
			,O.[name] AS 'client' 

			,O.id AS 'client_id'
			,CASE
				WHEN TE.IsProjectManagement = 1 THEN 'true'
				ELSE 'false'
			 END AS 'isPM'
			 ,CASE
				WHEN TE.IsHelpDesk = 1 THEN 'true'
				ELSE 'false'
			 END AS 'isHelpDesk'
			 ,ISNULL(TE.ITPM_ID, '') AS 'ITPM_ID'
			 ,ISNULL(TE.HD_ROW_ID, '') AS 'HD_ROW_ID'
			 ,ISNULL(TE.Description, '') AS 'Description'
			 ,ISNULL(TE.FileNameReference, '') AS 'FileNameReference'
			 ,ISNULL(TE.note, '') AS 'note'
		FROM
			[TimeKeeper].[dbo].[TimeEntries] TE
			LEFT JOIN [TimeKeeper].[dbo].[TimeEntry_Tasks] TES
				ON TES.id = TE.timeEntrytaskID
			LEFT JOIN [TimeKeeper].[dbo].[TimeKeeperHolidays] TKH
				ON TKH.ID = TE.holidayTaskID

      LEFT JOIN [TimeKeeper].[dbo].[Organizations] O
        ON TE.orgClientID = O.id



		WHERE 
          TE.timeEntryDayID = @Id
            AND TE.numberMinutes > 0
END

GO

grant execute on [dbo].[TIMESHEET_GetTimeEntry] to webuser
go