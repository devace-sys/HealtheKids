USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_BY_DISP_SUMMARY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_BY_DISP_SUMMARY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_BY_DISP_SUMMARY]
(@clientID AS INT
)

RETURNS TABLE 

/***************************************************************************    
 * ONE_ON_ONE_AIDE_ASSIGNMENT_BY_DISP_SUMMARY */      
/**    
 * Returns a table of one on one aide assignment data summarized by
 * client, patient, discpline, and date range
 * 
 * @param   clientID        Client ID you wish to work with or null for all
 ***************************************************************************/   

AS RETURN
(

/*============================================================
 * All Active One on One Aide Records 
 *============================================================*/  
 
with cte_aide_records
as
(
select 
  clientID,
  patID, 
  oneOnOneAideType,
  calendarID,
  scheduleID,
  startDate, 
  endDate, 
  [numDailyMins] = busMinsAM + siteMins + busMinsPM  /* Combined minutes of daily aid for this aide */
  
from ONE_ON_ONE_AIDE_ASSIGNMENT as aa
where 
  active = 1
  and ((@clientID is null) or (aa.clientID = @clientID))
)
,
/*============================================================
 * Same date, same aide type, total daily minutes, and
 * different people combined
 * 
 * For example different AM and PM health aides
 *============================================================*/  

cte_aide_records_combine_same_date_same_disp_dif_aides
as
(
select
  clientID,
  patID, 
  oneOnOneAideType,
  calendarID,
  scheduleID,
  startDate, 
  endDate, 
  sum(numDailyMins) as numMinsExpected
from cte_aide_records
group by
  clientID,
  patID,
  oneOnOneAideType,
  calendarID,
  scheduleID,
  startDate,
  endDate
)

/*============================================================
 * Output data
 *============================================================*/  

select * from cte_aide_records_combine_same_date_same_disp_dif_aides

)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_BY_DISP_SUMMARY] TO [webuser]
GO   

