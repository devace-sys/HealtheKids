USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_NOTES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))

DROP FUNCTION dbo.SVCNOTES_NOTES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTES_VIEW
(
   @userID        INT  
  ,@userGroup     INT    
  ,@userRank      INT
  ,@clientID      INT
  ,@pracID        INT
  ,@noteID        BIGINT
  ,@questionID    BIGINT
  ,@completed     BIT
  ,@active        BIT
)

RETURNS TABLE AS RETURN (

  with cte_notes_base_1
  as
  (
    select 
       sn.*
      ,cid.*
    from dbo.SvcNote_Notes       as sn
    cross apply (select CurrentQuestionID = dbo.SVCNOTES_NOTE_QUESTION_GET_CURRENT_ID (@userID,@userGroup,@userRank,sn.clientID,sn.pracID,sn.id)) as cid
    where
        ((1=1)    
    and ((@pracID    is null) or (sn.PracID    = @pracID))
    and ((@noteID    is null) or (sn.id        = @noteID))
    and ((@completed is null) or (sn.Completed = @completed))
    and ((@active    is null) or (sn.active    = @active)))
  )
  ,
  cte_notes_base_2
  as
  (
    select 
       cnb1.*
      ,snnt.NoteTypeName as [noteTypeName]
      ,coalesce (CurrentQuestionID, LastQuestionAnsweredID) as [DefaultQuestionID]
    from cte_notes_base_1 as cnb1
    join SvcNote_NoteType as snnt on snnt.id = cnb1.noteTypeID
  )
  ,
  cte_notes_base_3
  as
  (
    select 
         cnb2.*       
       , coalesce (@questionID, DefaultQuestionID) as [ReferenceQuestionID]
     from cte_notes_base_2 as cnb2
  )
  ,
  cte_notes_base_4
  as
  (
    select 
         cnb3.*
       , pnid.* 
     from cte_notes_base_3 as cnb3
     cross apply (select  PreviousQuestionID = dbo.SVCNOTES_NOTE_QUESTION_GET_PREVIOUS_ID (@userID,@userGroup,@userRank,cnb3.clientID,cnb3.pracID,cnb3.id,cnb3.ReferenceQuestionID)
                         ,NextQuestionID     = dbo.SVCNOTES_NOTE_QUESTION_GET_NEXT_ID     (@userID,@userGroup,@userRank,cnb3.clientID,cnb3.pracID,cnb3.id,cnb3.ReferenceQuestionID)) as pnid
  )
  ,
  cte_notes_and_entity_data_1
  as
  (
    select 
       sn.*
      ,cc.CLIENT_NAME  as [clientName]
      ,prp.CONCAT_NAME as [pracName]      
      ,ppa.CONCAT_NAME as [patName]      
      ,snsr.svcRecID   as [svcRecID]
      ,srve.id         as [svcRecEditableID]      
      
    from cte_notes_base_4 as sn

    join CLIENTS_CLIENT             as cc   on   cc.CLIENT_ID         = sn.clientID    
    join PRACTITIONER_CLIENT        as prc  on   prc.CLIENT_ID        = sn.clientID
                                            and  prc.PRACTITIONER_ID  = sn.pracID
    join PRACTITIONER_PRACTITIONER  as prp  on   prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID
    join PATIENTS_CLIENT            as pac  on   pac.CLIENT_ID        = sn.clientID
                                            and  pac.PATIENT_ID       = sn.patID                                           
    join PATIENTS_PATIENT           as ppa  on   ppa.PATIENT_ID       = pac.PATIENT_ID      
    left join SvcNote_SvcRec        as snsr on   snsr.svcNoteID       = sn.id   
    left join SERVICE_RECORDS_VIEW_EDITABLE (@clientID, @userID, @userGroup, @userRank, 1) as srve on srve.id = snsr.svcRecID
  )
  ,
  
  cte_output_1
  as
  (  
  select 
      id                                 as  [noteID]
    , clientID                           as  [clientID]
    , pracID                             as  [pracID]
    , patID                              as  [patID]
    , Dos                                as  [noteForDos]
    , clientName                         as  [noteFromClient]
    , pracName                           as  [noteFromPractitioner]
    , patName                            as  [noteForPatient]
    , noteTypeID                         as  [noteTypeID]
    , noteTypeName                       as  [noteTypeName]
    , ReferenceQuestionID                as  [questionID]
    , DefaultQuestionID                  as  [dfltQuestionID]
    , PreviousQuestionID                 as  [prevQuestionID]
    , CurrentQuestionID                  as  [currQuestionID]    
    , NextQuestionID                     as  [nextQuestionID]    
    , LastQuestionAnsweredID             as  [lastQuestionID]
    , Created                            as  [noteCreatedOn]    
    , Completed                          as  [noteCompleted]
    , CompletionDate                     as  [noteCompletedOn]
    , Active                             as  [noteActive]
    , NoteRefKey                         as  [noteRefKey]
    , svcRecID                           as  [svcRecID]
    ,[canDeleteNoteAndSvcRec] = case 
      when (svcRecID is null)     and (svcRecEditableID is null)     then cast(0 as bit)  -- 0
      when (svcRecID is null)     and (svcRecEditableID is not null) then cast(0 as bit)  -- 0
      when (svcRecID is not null) and (svcRecEditableID is null)     then cast(0 as bit)  -- 0
      when (svcRecID is not null) and (svcRecEditableID is not null) then cast(1 as bit)  -- 1
    end

  from cte_notes_and_entity_data_1
  )
  ,
  cte_output_2
  as
  (
   select     
     *
     , [noteText]       = noteTypeName + ' note for ' + noteForPatient + ' provided on ' + dbo.RPT_DATE_FMT(noteForDos) + ' by ' + noteFromPractitioner
     , [noteStatusText] = case when noteCompleted = 1 then 'Completed on ' + dbo.RPT_DATE_FMT(noteCompletedOn) else 'Incomplete as of ' + dbo.RPT_DATE_FMT(noteCreatedOn) end
   from cte_output_1  
  )
       
  select * from cte_output_2
)   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTES_VIEW] TO [webuser]
GO