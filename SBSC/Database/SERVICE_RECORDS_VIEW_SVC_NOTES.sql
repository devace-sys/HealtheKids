USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_VIEW_SVC_NOTES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_VIEW_SVC_NOTES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_VIEW_SVC_NOTES] (
    @userID        as   bigint
  , @userGroup     as   int  
  , @userRank      as   int    
  , @clientID      as   bigint
  , @startDate     as   datetime
  , @endDate       as   datetime
  , @pracID        as   bigint
  , @patID         as   bigint
  , @hasFmtSvcNote as   bit
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_VIEW_SVC_NOTES */    
/**    
 *     
 * TODO: Consolidate with regular view
 *
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    
with

/*###########################################################################
  # Service records and unformatted note text
  ###########################################################################*/ 

cte_svc_recs_p1
as
(
  select    
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
    , sr.patAbsent                             as patAbsent
    , dbo.RPT_BIT_TO_YN(sr.patAbsent)          as patAbsentStr
    , sr.dos                                   as dos
    , convert(varchar(8),sr.dos,1)             as dosStr
    , vs.[SERVICE_NAME]                        as svcName
    , sr.numMins                               as numMins
    , sr.startTime                             as startTime
    , dbo.RPT_TIME_FMT(startTime,0)            as startTimeStr
    , ltrim(rtrim(isnull(notes,'')))           as notes
  from dbo.SERVICE_RECORDS           as sr
  join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID       = sr.clientID
  join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = sr.pracID
  join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID      = sr.patID
  cross apply (
    select * from dbo.SERVICE_NAME_LOOKUP (  sr.planType
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
          (sr.clientID  = @clientID) 
      and (sr.dos between @startDate and @endDate)
      and (sr.state != dbo.CONST_SVC_REC_STATE_DEL())
      and (sr.state != dbo.CONST_SVC_REC_STATE_CIF())
      and ((@pracID is null) or (sr.pracID = @pracID))
      and ((@patID  is null) or (sr.patID  = @patID))) 
)
,

/*###########################################################################
  # Formatted notes with derived columns for sortation
  ###########################################################################*/ 

cte_svc_notes
as
(
  select top (dbo.CONST_MAX_ROWS())           svcRecID       = snsr.svcRecID    , noteID         = snn.id    , questionNumber = DENSE_RANK() over (partition by snn.id order by snq.id)     , questionText   = snq.QuestionText    , headerText     = isnull(snnah.HeaderText,'')    , answerNumber   = ROW_NUMBER() over (partition by snn.id, snq.id order by snna.id)     , answerText     = snna.AnswerValue   from  dbo.SvcNote_Notes        as snn  join  dbo.SvcNote_Note_Answers as snna on snna.NoteID     = snn.id  join  dbo.SvcNote_Questions    as snq  on snna.QuestionID = snq.id  join  dbo.SvcNote_SvcRec       as snsr on snn.id          = snsr.svcNoteID  outer apply (
    select 
      HeaderText = AnswerValue 
    from dbo.SvcNote_Note_Answers 
    where id  = snna.Parent_NoteAnswerID
  ) as snnah
  where (snn.clientID = @clientID)
  and   (snn.dos between @startDate and @endDate)
  and  ((@pracID   is null) or (snn.pracID   = @pracID))
  and  ((@patID    is null) or (snn.patID    = @patID))
  order by snna.id
)
,

/*###########################################################################
  # Service records with NO formatted notes
  ###########################################################################*/ 

cte_svc_recs_sn_no
as
(
  select    
      sr.*    
    , hasFmtSvcNote  = CONVERT(bit,0)
    , notesText      = case (sr.notes) when '' then 'No Unformatted Note Recorded' else sr.notes end
    , questionNumber = 1
    , questionText   = 'Formatted Notes Not Used'
    , answerNumber   = 1
    , answerText     = ''
  from      cte_svc_recs_p1    as sr
  left join dbo.SvcNote_SvcRec as snsr on snsr.svcRecID = sr.id
  where (snsr.id is null) 
)
,

/*###########################################################################
  # Service records with formatted notes
  ###########################################################################*/ 

cte_svc_recs_sn_yes
as
(  
  select 
      sr.*       
    , hasFmtSvcNote   = CONVERT(bit,1)
    , notesText       = case (sr.notes) when '' then  'No Unformatted Note Recorded' 
                                                else  case (sr.inputByUserID) 
                                                      when @userID then sr.notes 
                                                      else 'Private Unformatted Note Recorded' 
                                                      end
                                                end 
    , sn.questionNumber
    , questionText    = case (sn.answerNumber) when 1 then sn.QuestionText else '' end
    , sn.answerNumber
    , sn.answerText
  from  cte_svc_recs_p1 as sr
  join  cte_svc_notes   as sn on sn.svcRecID = sr.id
)
,

/*###########################################################################
  # Combine service recs with no unformated notes and those with formatted 
  # notes
  ###########################################################################*/ 

cte_svc_recs_sn_no_yes_combined
as
(
  select * 
  from
  (
          select * from cte_svc_recs_sn_no 
    union select * from cte_svc_recs_sn_yes  
  ) q1
  where ((1=1) and ((@hasFmtSvcNote is null) or (q1.hasFmtSvcNote = @hasFmtSvcNote)))
)
,

/*###########################################################################
  # Output columns and derive recNum and recLine columns we will use for 
  # sorting
  ###########################################################################*/ 

cte_output_p1
as
(
  select 
    recNumber = DENSE_RANK() over (order by 
                                       clientName
                                     , clientID
                                     , pracName
                                     , pracID
                                     , patName
                                     , patDOB
                                     , patID
                                     , dos
                                     , id )
  , recLine   = ROW_NUMBER() over (partition by 
                                     id 
                                   order by 
                                       clientName
                                     , clientID
                                     , pracName
                                     , pracID
                                     , patName
                                     , patDOB
                                     , patID
                                     , dos
                                     , id
                                     , questionNumber
                                     , answerNumber )
  , * 
  from cte_svc_recs_sn_no_yes_combined
)
,

/*###########################################################################
  # Output columns and sort results.  Also filter our repeated values to
  # improve readability
  ###########################################################################*/ 

cte_output_p2
as
(
  select 
    recNumber
  , recLine
  , case (recLine) when 1 then pracName                    else '' end as [Practitioner] 
  , case (recLine) when 1 then patName + ' - ' + patDOBStr else '' end as [Patient]
  , case (recLine) when 1 then dosStr                      else '' end as [DOS]
  , case (recLine) when 1 then patAbsentStr                else '' end as [Patient Absent]
  , case (recLine) when 1 then svcName                     else '' end as [Service]
  , case (recLine) when 1 then convert(varchar(3),numMins) else '' end as [Mins]
  , case (recLine) when 1 then startTimeStr                else '' end as [Start Time]
  , case (recLine) when 1 then notesText                   else '' end as [Unformatted Notes]
  , questionText  as [Formatted Note Question]
  , answerText    as [Formatted Note Answers]
  from cte_output_p1
)

select 
top (dbo.CONST_MAX_ROWS()) * 
from cte_output_p2 
order by recNumber, recLine

)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORDS_VIEW_SVC_NOTES] TO [webuser]
GO