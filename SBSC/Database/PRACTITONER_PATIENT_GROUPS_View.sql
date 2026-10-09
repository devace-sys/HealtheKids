USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONER_PATIENT_GROUPS_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONER_PATIENT_GROUPS_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITONER_PATIENT_GROUPS_View]    
(@userID     INT,    
 @userGroup  INT,    
 @userRank   INT,
 @clientID   INT,
 @pracID     INT,
 @dos        DATETIME,
 @name       VARCHAR(500),
 @active     BIT,
 @recID      INT)    

RETURNS TABLE

 /***************************************************************************    
  * PRACTITONER_PATIENT_GROUPS_View */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client. 
  * @param  pracID          Required.  ID of practitioner.    
  * @param  patID           Required.  ID of patient.
  * @param  startDate       Start of month.
  * @param  endDate         End of month
  * @return                 Table of expected service data   
  ***************************************************************************/     
  
AS RETURN
(

with

/*============================================================
 * Get group data
 *============================================================*/  
 
cte_pass_0
as
(
select 
  pptg.id,
  pptg.name,
  isnull(pptg.description,'') as description,
  pptg.clientID,
  cc.CLIENT_NAME as clientName,
  pptg.pracID,
  pr.CONCAT_NAME as pracName,
  pptg.startDate,
  dbo.RPT_DATE_FMT(pptg.startDate)        as startDateStr,
  pptgs.startTime,
  CONVERT(varchar(20),pptgs.startTime,22) as startTimeStr,
  dbo.DATE_OR_MIN_MAX(pptg.endDate,1)     as endDate,
  dbo.RPT_DATE_FMT(pptg.endDate)          as endDateStr,  
  pptgs.numMins,
  pptgs.grpMtg2,
  pptgs.grpMtg3,
  pptgs.grpMtg4,
  pptgs.grpMtg5,
  pptgs.grpMtg6,
  dbo.RPT_WEEKDAYS_SELECTED(pptgs.grpMtg2, pptgs.grpMtg3, pptgs.grpMtg4, pptgs.grpMtg5, pptgs.grpMtg6) as grpMtgsStr,
  pptgs.patIDsStr,
  pptgs.effectiveDate,
  dbo.RPT_DATE_FMT(pptgs.effectiveDate)   as effectiveDateStr
from PRACTITIONER_PATIENT_TREATMENT_GROUPS                 as pptg
join PRACTITIONER_PATIENT_TREATMENT_GROUP_SERVICE_SCHEDULE as pptgs on pptgs.treatmentGroupID = pptg.id
                                                                    and pptgs.id = pptg.curSvcSchID
join CLIENTS_CLIENT                                        as cc    on  cc.CLIENT_ID          = pptg.clientID
join PRACTITIONER_Practitioner                             as pr    on  pr.PRACTITIONER_ID    = pptg.pracID                  

where 
      (1=1)
  and ((@clientID is null) or (pptg.clientID  = @clientID)) 
  and ((@pracID   is null) or (pptg.pracID    = @pracID))   
  and ((@active   is null) or (pptg.ACTIVE    = @active))
  and ((@recID    is null) or (pptg.ID        = @recID))
  
)
,

/*============================================================
 * Limit by date if applicable
 *============================================================*/  

cte_pass_1
as
(
select 
  id,
    name,
    description,
    clientID,
    clientName,
    pracID,
    pracName,
    startDate,
    startDateStr,
    startTime,
    startTimeStr,
    endDate,
    endDateStr,
    numMins,
    grpMtg2,
    grpMtg3,
    grpMtg4,
    grpMtg5,
    grpMtg6,
    grpMtgsStr,
    patIDsStr,
    effectiveDate,
    effectiveDateStr
from cte_pass_0
where 
  (1=1) and ((@dos is null) or (@dos between startDate and endDate))
)
,

/*============================================================
 * Parse patient ids and get seperate names
 * There will be multiple rows as a result of this
 *============================================================*/  

cte_pass_2
as
(
  select 
  * 
  from cte_pass_1 as t1
  cross apply (
    select 
      pp.CONCAT_NAME as [patName]      
    from dbo.MULTI_RECORD_ID_PARSE(t1.patIDsStr,',') as pids
    join PATIENTS_PATIENT                            as pp on pp.PATIENT_ID = pids.recID
  ) as t2
)
,

/*============================================================
 * Combine patient names into a pipe delimited column
 * The number of rows will be restored to what they were
 *============================================================*/  

cte_pass_3
as
(
   select distinct 
    id,
    name,
    description,
    clientID,
    clientName,
    pracID,
    pracName,
    startDate,
    startDateStr,
    startTime,
    startTimeStr,
    endDate,
    endDateStr,
    numMins,
    grpMtg2,
    grpMtg3,
    grpMtg4,
    grpMtg5,
    grpMtg6,
    grpMtgsStr,
    patIDsStr,
    effectiveDate,
    effectiveDateStr,
    patNames = substring((select ( '|' + t2.patName)                 from cte_pass_2 as t2
                 where 
                   (t1.id           = t2.id)           and
                   (t1.name         = t2.name)         and
                   (t1.description  = t2.description)  and
                   (t1.clientID     = t2.clientID)     and
                   (t1.clientName   = t2.clientName)   and
                   (t1.pracID       = t2.pracID)       and
                   (t1.pracName     = t2.pracName)     and
                   (t1.startDate    = t2.startDate)    and
                   (t1.startDateStr = t2.startDateStr) and
                   (t1.startTime    = t2.startTime)    and
                   (t1.startTimeStr = t2.startTimeStr) and
                   (t1.endDate      = t2.endDate)      and
                   (t1.endDateStr   = t2.endDateStr)   and
                   (t1.numMins      = t2.numMins)      and
                   (t1.grpMtg2      = t2.grpMtg2)      and
                   (t1.grpMtg3      = t2.grpMtg3)      and
                   (t1.grpMtg4      = t2.grpMtg4)      and
                   (t1.grpMtg5      = t2.grpMtg5)      and
                   (t1.grpMtg6      = t2.grpMtg6)      and
                   (t1.grpMtgsStr   = t2.grpMtgsStr)   and                   (t1.patIDsStr    = t2.patIDsStr)    and                   (t1.effectiveDate    = t2.effectiveDate)    and
                   (t1.effectiveDateStr = t2.effectiveDateStr)   
                                   for xml path ( '' )), 2, 1000 )
    from cte_pass_2 as t1
    group by  
      t1.id,
      t1.name,
      t1.description,
      t1.clientID,
      t1.clientName,
      t1.pracID,
      t1.pracName,
      t1.startDate,
      t1.startDateStr,
      t1.startTime,
      t1.startTimeStr,
      t1.endDate,
      t1.endDateStr,      
      t1.numMins,
      t1.grpMtg2,
      t1.grpMtg3,
      t1.grpMtg4,
      t1.grpMtg5,
      t1.grpMtg6,
      grpMtgsStr,
      t1.patName,
      t1.patIDsStr,
      t1.effectiveDate,
      t1.effectiveDateStr 
)

/*============================================================
 * Output
 *============================================================*/  

select * from cte_pass_3
)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITONER_PATIENT_GROUPS_View] TO [webuser]
GO
