USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Recent_Procedure_Entries_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Recent_Procedure_Entries_View 
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Recent_Procedure_Entries_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID			   BIGINT
  , @dos               date
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Recent_Procedure_Entries_View */    
 /**    
  * Returns a list of journals
  *
  * @return table 
  ***************************************************************************/   
           
  AS RETURN
(
with
cte_p0
as
(
  select top 1 
    clientID   = @clientID
  , patID      = @patID
  , startDate  = dateadd(week,-2, @dos)
  , endDate    = @dos  
)
,
cte_p1
as
(
  select 
     p0.clientID
   , p0.patID 
   , recs.*
 from cte_p0 as p0
 cross apply (
     select 
        sj.dos  
      , sjee.entryStartTime
      , sjee.entryEndTime
      , patName     = pap.CONCAT_NAME
      , pracName    = prp.CONCAT_NAME
      , pracTitle   = ggd.GROUP_NAME
      ,  procedureName = isnull(orpDocSvcName.[NAME],sjet.eventLabel)
      ,  procedureNotes =  isnull(sjee.entryNotes ,'') 
      , journalID = sj.id
      , entryID =  sjee.id
      , sjee.pracID
 
    from dbo.SvcJournals               as sj
    join dbo.PATIENTS_Patient          as pap  on pap.PATIENT_ID = sj.patID
    join dbo.SvcJournal_Event_Entries  as sjee on sjee.journalID = sj.id
    join dbo.SvcJournal_Event_Types    as sjet on (sjet.id = sjee.eventType)
                                               and (sjet.id in (5,6,12)) /* Limit to procedures likely to be administered in health office  */
    join dbo.PRACTITIONER_Practitioner as prp  on prp.PRACTITIONER_ID = sjee.pracID
    join dbo.PRACTITIONER_GROUPS       as pgd  on (pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                             and (pgd.GROUP_TYPE in (1,2))
 
    join dbo.GROUP_Group                           as ggd   on ggd.GROUP_ID = pgd.GROUP_ID
 
    outer apply (
      select top 1 
        odssn.[NAME]
      from dbo.ORP_DOCUMENTS                         as od    
      join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as odssn on odssn.ID = od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
      where 
        (od.ID = sjee.orpDocID)
    ) as orpDocSvcName
    where (
          ((sj.clientID = @clientID)
      and (sj.patID = @patID)
      and (sj.dos between p0.startDate and p0.endDate))
      and (sj.active = 1)
    )
  ) as recs
)
 
select top (dbo.CONST_MAX_ROWS())
    p1.* 
  , dosStr            = dbo.RPT_DATE_FMT(p1.dos)
  , entryStartTimeStr = dbo.RPT_TIME_FMT(p1.entryStartTime,0)
  , entryEndTimeStr   = dbo.RPT_TIME_FMT(p1.entryEndTime,0)
from cte_p1 as p1
order by 
    p1.dos desc
  , p1.entryStartTime desc

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Recent_Procedure_Entries_View] TO [webuser]
GO  

