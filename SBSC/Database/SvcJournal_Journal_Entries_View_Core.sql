USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Entries_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Entries_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Entries_View_Core] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT
  , @pracID            BIGINT
  , @journalID         BIGINT
  , @recID             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Entries_View_Core */    
 /**    
  * Returns a list of journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  with 
  cte_pass_1
  as
  (
    select 
            
      id               = sjee.id
    , journalID        = sj.id    
    , clientID         = sj.clientID
    , clientName       = cc.CLIENT_NAME
    , pracID           = sjee.pracID
    , pracName         = prp.CONCAT_NAME
    , patID            = sj.patID
    , patName          = pap.CONCAT_NAME    
    , eventID          = sje.id
    , eventLabel       = sje.eventLabel
    
    , iep              = sjee.iep
    , iepVal           = sjee.iep
    
    , dos              = dbo.RPT_DATE_FMT(sj.dos)
    , dosVal           = sj.dos
    
    , startTime        = case when sje.reqStartTime = 1 then dbo.RPT_TIME_FMT(sjee.entryStartTime,0) else '' end  
    , startTimeVal     = sjee.entryStartTime
    
    , endTime          = case when sje.reqEndTime = 1 then dbo.RPT_TIME_FMT(sjee.entryEndTime,0) else '' end
    , endTimeVal       = sjee.entryEndTime
    , orpDocID         = sjee.orpDocID
    , orpDocName       = orpd.name
    , notes            = sjee.entryNotes    
    , canEdit          = convert (bit,case when ((sj.active = 1) and (sj.completed = 0) and (sjee.createdBy = @userID) and (sjee.active = 1) and (sjee.pracID = @pracID)) then 1 else 0 end)
    
    from      dbo.SvcJournal_Event_Entries  as sjee
    join      dbo.SvcJournals               as sj   on sj.id               = sjee.journalID  
    join      dbo.SvcJournal_Event_Types    as sje  on sje.id              = sjee.eventType
    join      dbo.CLIENTS_Client            as cc   on cc.CLIENT_ID        = sj.clientID
    join      dbo.PRACTITIONER_Practitioner as prp  on prp.PRACTITIONER_ID = sjee.pracID
    join      dbo.PATIENTS_Patient          as pap  on pap.PATIENT_ID      = sj.patID
    left join dbo.ORP_DOCUMENTS_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, null, null, null, null, null, null, null) as orpd on orpd.id = sjee.orpDocID
    
    where 
          ((sjee.active = 1)          
      and ((@clientID   is null) or (sj.clientID       = @clientID))
      and ((@journalID  is null) or (sjee.journalID    = @journalID))
      and ((@recID      is null) or (sjee.id           = @recID)))
  )
  ,
  
  cte_pass_2
  as
  (
 
    select 
       p1.*
     , [name]                  = eventLabel + ' - ' + startTime + ' - ' + endTime
     , [startTimeEndTimeLabel] = startTime  + ' - ' + endTime
	 , fbQA2.*
	 , ncQA2.*

    from cte_pass_1 as p1

	outer apply (
      select top 1 
          fbQA1.entryNotesFormBuilderQuestionsJSON
        , fbQA1.entryNotesFormBuilderAnswersJSON
        , entryNotesFormBuilderText = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT ( fbQA1.entryNotesFormBuilderQuestionsJSON
                                                                        , fbQA1.entryNotesFormBuilderAnswersJSON
                                                                        , 1
                                                                        , 0
                                                                        , 1
                                                                        , 0
																		, 1
																		, 0)
      from dbo.SvcJournal_Event_Entries_Form_Builder_Data as fbQA1
      where 
        (fbQA1.entryID = p1.id)
    ) as fbQA2

	outer apply (
      select top 1 
          ncQA1.noteCriteriaQuestionsJSON
        , ncQA1.noteCriteriaAnswersJSON
        , noteCriteriaText = dbo.FORM_BUILDER_JSON_QA_DATA_TO_TEXT (  ncQA1.noteCriteriaQuestionsJSON
                                                                    , ncQA1.noteCriteriaAnswersJSON
                                                                    , 1
                                                                    , 0
                                                                    , 1
                                                                    , 0
																	, 1
																	, 0)
      from dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers as ncQA1
      where 
        (ncQA1.entryID = p1.id)
    ) as ncQA2

  )
  ,

  cte_pass_3
  as
  (
   
  select 
     p2.* 
   , entryNotesFormBuilderTextAndNoteCritTextAndNotes = ''  
                                                      + convert(varchar(max),iif(p2.orpDocName is null, N'', 'Service: ' + p2.orpDocName))
                                                      + char(13)
                                                      + convert(varchar(max),isnull(p2.entryNotesFormBuilderText,N''))
                                                      + char(13)
                                                      + convert(varchar(max),isnull(p2.noteCriteriaText,N''))
													  + char(13)
													  + '* Additional Notes: ' + isnull(p2.notes,'')
   from cte_pass_2 as p2
   
  )

  select * from cte_pass_3
  )

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Entries_View_Core] TO [webuser]
GO  
