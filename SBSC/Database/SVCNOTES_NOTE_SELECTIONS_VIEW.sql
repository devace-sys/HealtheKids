USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('SVCNOTES_NOTE_SELECTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[SVCNOTES_NOTE_SELECTIONS_VIEW]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].SVCNOTES_NOTE_SELECTIONS_VIEW ( 
  @userID         bigint,
  @userGroup      int,   
  @userRank       int,
  @clientID	   bigint,
  @pracID		   bigint,
  @completed      bit,
  @noteID         bigint,
  @questionID     bigint) 

RETURNS TABLE AS RETURN(
  with cte_base
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
    , NoteRefKey                         as  [noteRefKey]

  from SVCNOTES_NOTES_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @completed, @noteID, @questionID)   
  )
  ,
  cte_output
  as
  (
    select     
      *
      , [noteText]       = noteTypeName + ' note for ' + noteForPatient + ' provided on ' + dbo.RPT_DATE_FMT(noteForDos) + ' by ' + noteFromPractitioner
      , [noteStatusText] = case when noteCompleted = 1 then 'Completed on ' + dbo.RPT_DATE_FMT(noteCompletedOn) else 'Incomplete as of ' + dbo.RPT_DATE_FMT(noteCreatedOn) end
    from cte_base  
  )
  select * from cte_output
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCNOTES_NOTE_SELECTIONS_VIEW] TO [webuser]
GO