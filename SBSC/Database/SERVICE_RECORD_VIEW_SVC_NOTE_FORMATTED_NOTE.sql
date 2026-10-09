USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE] (
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
return (  

/***************************************************************************    
 * SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 ***************************************************************************/     
    

select top (dbo.CONST_MAX_ROWS())             id             = snna.id  , svcRecID       = snsr.svcRecID    , noteID         = snn.id  , questionNumber = DENSE_RANK() over (partition by snn.id order by snq.id)   , questionText   = snq.QuestionText  , headerText     = isnull(snnah.HeaderText,'')  , answerNumber   = ROW_NUMBER() over (partition by snn.id, snq.id order by snna.id)   , answerText     = snna.AnswerValue from  dbo.SvcNote_Notes        as snnjoin  dbo.SvcNote_Note_Answers as snna on snna.NoteID     = snn.idjoin  dbo.SvcNote_Questions    as snq  on snna.QuestionID = snq.idjoin  dbo.SvcNote_SvcRec       as snsr on snn.id          = snsr.svcNoteIDouter apply (
  select 
    HeaderText = AnswerValue 
  from dbo.SvcNote_Note_Answers 
  where id  = snna.Parent_NoteAnswerID
) as snnah
where 
  ((snsr.svcRecID = @recID)
  and  ((@clientID is null) or (snn.clientID  = @clientID))
  and  ((@pracID   is null) or (snn.pracID    = @pracID))
  and  ((@patID    is null) or (snn.patID     = @patID)))
 
order by snna.id
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORD_VIEW_SVC_NOTE_FORMATTED_NOTE] TO [webuser]
GO