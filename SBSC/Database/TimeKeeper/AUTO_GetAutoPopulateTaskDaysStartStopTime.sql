USE [TimeKeeper]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 7:36:11 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTime]
GO

/****** Object:  StoredProcedure [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTime]    Script Date: 1/25/2020 7:36:11 PM ******/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTime]
(
  @autoPopulateTaskDetailsId					 BIGINT
)    
AS    
BEGIN    
SET NOCOUNT ON;
	  
	SELECT 
		APTDSS.id
		,APTDSS.autoPopulateTaskDaysId
		,REPLACE(REPLACE(CONVERT(varchar(15),CAST(APTDSS.starttime AS TIME),100), 'PM', ' PM'), 'AM', ' AM') AS 'starttime'
		,REPLACE(REPLACE(CONVERT(varchar(15),CAST(APTDSS.stoptime AS TIME),100), 'PM', ' PM'), 'AM', ' AM') AS 'stoptime'
		,APTD.dayid
		,APTD.autoPopulateTaskDetailsId
		,APTD.numberOfMinutes
	FROM 
		[TimeKeeper].[dbo].[AutoPopulateTaskDaysStartStopTime] APTDSS
		INNER JOIN [TimeKeeper].[dbo].[AutoPopulateTaskDays] APTD
			ON APTD.id = APTDSS.autoPopulateTaskDaysId
	WHERE
		APTD.autoPopulateTaskDetailsId = @autoPopulateTaskDetailsId
	ORDER BY
		APTD.dayid

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[AUTO_GetAutoPopulateTaskDaysStartStopTime] TO [webuser]
GO


