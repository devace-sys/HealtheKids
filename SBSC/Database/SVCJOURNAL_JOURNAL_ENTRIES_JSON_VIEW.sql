USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @journalID         BIGINT
  , @recID             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW */    
 /**    
  * Returns a list of open journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select distinct
	  [id]                  = sje.id
	, dosStr                = convert(varchar, FORMAT(sje.dosVal, 'MM/dd/yyyy'))
	, eventID               = sje.eventID
	, eventLabel            = iif(isnull(sje.orpDocID,'') = '', sje.eventLabel, sje.orpDocName)
	, iep                   = sje.iepVal
	, startTime             = convert(varchar, sje.startTimeVal)
	, endTime               = convert(varchar, sje.endTimeVal)
	, sessionDeliveryStatus = ''
	, notes                 = sje.notes
	, pracID                = sje.pracID
	, pracName              = sje.pracName
	, reqORPDoc             = sjet.reqORP
	, reqStartTime          = sjet.reqStartTime
	, reqEndTime            = sjet.reqEndTime
	, orpDocID				= sje.orpDocID
	, orpDocName			= sje.orpDocName
	, entryNotesFormBuilderQuestionsJSON = seefbd.entryNotesFormBuilderQuestionsJSON
	, entryNotesFormBuilderAnswersJSON   = seefbd.entryNotesFormBuilderAnswersJSON
	, noteCriteriaQuestionsJSON          = seencqa.noteCriteriaQuestionsJSON
	, noteCriteriaAnswersJSON            = seencqa.noteCriteriaAnswersJSON
  from dbo.SvcJournal_Journal_Entries_View (
			  @userID       
			, @userGroup    
			, @userRank     
			, @clientID     
			, null       
			, @journalID   
			, null        
		) as sje
   join dbo.SvcJournal_Event_Types as sjet on sjet.id = sje.eventID
   left join dbo.SvcJournal_Event_Entries_Form_Builder_Data as seefbd on seefbd.entryID = sje.id
   left join dbo.SvcJournal_Event_Entries_Note_Criteria_Questions_Answers as seencqa on seencqa.entryID = sje.id
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_ENTRIES_JSON_VIEW] TO [webuser]
GO  
