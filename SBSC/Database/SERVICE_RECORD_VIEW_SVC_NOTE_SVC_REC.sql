USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC] (
    @userID        as   bigint
  , @userGroup     as   int  
  , @userRank      as   int    
  , @clientID      as   bigint
  , @pracID        as   bigint
  , @patID         as   bigint
  , @recID         as   bigint
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

with
cte_pass_1 
as
(
  select top 1 
    
      sr.id
    , sr.userID                                as inputByUserID   
    , sr.clientID                              as clientID
    , clc.CLIENT_NAME                          as clientName
    , sr.pracID                                as pracID
    , prp.CONCAT_NAME                          as pracName
    , sr.patID                                 as patID
    , pap.DATE_OF_BIRTH                        as patDOB
    , convert(varchar(8),pap.DATE_OF_BIRTH,1)  as patDOBStr
    , pap.CONCAT_NAME                          as patName
    , sr.dos                                   as dos
    , convert(varchar(8),sr.dos,1)             as dosStr
    , vs.[SERVICE_NAME]                        as svcName
    , sr.nameID                                as nameID
    , [minsOrMiles]   = dbo.RPT_MINUTES_OR_START_END_MILES (   sr.svcType
                                                             , sr.numMins
                                                             , sr.trip1Start
                                                             , sr.trip1End 
                                                             , sr.trip2Start
                                                             , sr.trip2End
                                                             , sr.trip3Start
                                                             , sr.trip3End
                                                             , sr.trip4Start
                                                             , sr.trip4End)
    , sr.numMins                                   as numMins
    
    , isnull(sraCurr.ReviewStatus , '')            as currReviewStatus
    , isnull(sraCurr.ReviewNotes  , '')            as currReviewNotes
    , sraCurr.journalID                            as journalID
    
  from dbo.SERVICE_RECORDS           as sr
  join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID       = sr.clientID
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = sr.pracID
  join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID      = sr.patID
  
  outer apply (

    select top 1  
      
        [ReviewStatus] = case 
          when (s.reviewed = 0 and s.approved is null) then 'Waiting for Review'
          when (s.reviewed = 1 and s.approved = 1)     then 'Approved by ' + s.reviewedByName  
          when (s.reviewed = 1 and s.approved = 0)     then 'Held by '     + s.reviewedByName
          else 'Unknown'
        end     
                
        , [ReviewNotes] = isnull(s.reviewNotes,'')  
        , [journalID]   = s.journalID
    
    from dbo.SERVICE_RECORDS_APPROVAL as s
    
    where 
          s.svcRecID = sr.id 
      and s.clientID = sr.clientID
      and s.active   = 1  
  
  ) as sraCurr
  
  cross apply (
    select top 1 * from dbo.SERVICE_NAME_LOOKUP (  sr.planType
                                                 , sr.svcType
                                                 , sr.nameID
                                                 , sr.nameIDAliasID
                                                 , sr.dos
                                                 , sr.groupID
                                                 , sr.hasSvcDetFlags
                                                 , sr.svcDetFlag1
                                                 , sr.svcDetFlag2
                                                 , sr.svcDetFlag3
                                                 , sr.svcDetFlag4 ) as vr 
  ) as vs
  
  where (
         (sr.id  = @recID)
    and ((@clientID is null) or (sr.clientID  = @clientID))
    and ((@pracID   is null) or (sr.pracID    = @pracID))
    and ((@patID    is null) or (sr.patID     = @patID))
  )
)
,
cte_pass_2
as
(
  select 
      p1.*
    , isnull(sraPrev.ReviewStatus ,'')  as prevReviewStatus
    , isnull(sraPrev.ReviewNotes  ,'')  as prevReviewNotes
  
  from cte_pass_1 as p1
   
  outer apply (
    select top 1  
      [ReviewStatus] = case 
        when (s.reviewed = 0 and s.approved is null) then 'Waiting for Review'
        when (s.reviewed = 1 and s.approved = 1)     then 'Approved by ' + s.reviewedByName  
        when (s.reviewed = 1 and s.approved = 0)     then 'Held by '     + s.reviewedByName
        else 'Unknown'
      end
    , [ReviewNotes] = isnull(s.reviewNotes,'')    
    
    from 
    (
      select top 1 sra1.* 
      from dbo.SERVICE_RECORDS_APPROVAL as sra1 
      where ((sra1.svcRecID = p1.id) and (sra1.active = 0)) 
      order by sra1.id desc
      
      union
      
      select top 1 sra2.* 
      from dbo.SERVICE_RECORDS_APPROVAL as sra2 
      join dbo.SERVICE_RECORDS          as sr2 on sr2.id = sra2.svcRecID
      where ((sra2.journalID = p1.journalID) and (sra2.active = 0) and (sra2.pracID = p1.pracID) and (sr2.nameID = p1.nameID))
      order by sra2.id desc
    ) as s 
  ) as sraPrev
)

select top 1 * from cte_pass_2

)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORD_VIEW_SVC_NOTE_SVC_REC] TO [webuser]
GO