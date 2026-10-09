USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoScheduleInfo]    Script Date: 1/25/2020 7:34:40 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[TIMESHEET_GetAutoScheduleInfo]
GO

/****** Object:  StoredProcedure [dbo].[TIMESHEET_GetAutoScheduleInfo]    Script Date: 1/25/2020 7:34:40 PM ******/


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TIMESHEET_GetAutoScheduleInfo]
	@Id BIGINT
AS    
BEGIN    
SET NOCOUNT ON;

    select
	    APST.id AS TemplateId
	    ,APST.name AS TemplateName
	    ,APST.description AS TemplateDescription
		,ISNULL(APST.autoPopulateTaskTemplateId, -1) AS 'AutoPopulateTaskTemplateId'
	    ,ISNULL(APSD.id, -1) AS AutoScheduleDaysId
	    ,ISNULL(DOW.id, -1) AS DayOfWeekId
	    ,ISNULL(DOW.day, '') AS DayOfWeek
	    ,ISNULL(APSST.id, -1) AS StartStopTimeId
	    ,ISNULL(APSST.starttime, '') AS StartTime
	    ,ISNULL(APSST.stoptime, '') AS EndTime
    from
	    TimeKeeper.dbo.AutoPopulateScheduleTemplate APST
	    left join TimeKeeper.dbo.AutoPopulateScheduleDays APSD
		    ON APSD.scheduleid = APST.id
	    left join TimeKeeper.dbo.DaysOfTheWeek DOW
		    ON DOW.id = APSD.dayId
	    left join timeKeeper.dbo.AutoPopulateScheduleStartAndStopTime APSST
		    ON APSST.autoPopulateScheduleDaysId = APSD.id
    where
	    APST.id = @Id
    order by
	    APSD.id
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[TIMESHEET_GetAutoScheduleInfo]  TO [webuser]
GO


