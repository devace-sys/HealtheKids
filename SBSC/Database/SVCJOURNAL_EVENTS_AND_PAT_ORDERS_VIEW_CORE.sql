USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE] (
    @userID                   as BIGINT
  , @userGroup                as INT  
  , @userRank                 as INT      
  , @clientID                 as BIGINT
  , @journalID                as BIGINT
  , @pracID			          as BIGINT
  , @patID			          as BIGINT
  , @isDefault                as BIT
  , @noteNamespace            as VARCHAR(500)
  , @noteSource               as VARCHAR(500)
  , @groupSvcClassNameID      as BIGINT
  , @includeOnlyOrpDocTypeIDs as VARCHAR(8000)
  , @displayRank              as BIGINT
  , @refID                    as BIGINT
  , @orpDocTypeID             as INT
  , @dos                      as Date
  , @groupID                  as BIGINT
  , @term			          as VARCHAR(255)
  , @includeOrders            as bit = 1
  , @includeEvents            as bit = 1  
  , @active                   as BIT
  , @recID                    as BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE */    
 /**    
  * Returns a list of open journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
	/* Event selections */

	with 
	cte_journal_events
	as
	(
	  select 
	    t1.*
	  from dbo.SvcJournal_Event_Selections (@userID, @userGroup, @userRank, null, null, null, @journalID, @pracID, @term, null) as t1
	  where 
	    (@includeEvents = 1)
	)
	,

	/* Patient orders */

	cte_orders
	as
	(
	  select 
	      t2.*
        , ssn.formBuilderContentForServiceJournalEntryNotesJSON
		, ssn.serviceJournalAssociatedEventTypeID
	  from dbo.ORP_DOCUMENTS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @groupSvcClassNameID, @patID, @dos, @term, @orpDocTypeID, @refID, @includeOnlyOrpDocTypeIDs, @displayRank, @active, null) as t2
      join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as ssn on ssn.id = t2.orpDocumentStandardSelectionNameID
	  where 
	    (@includeOrders = 1)
	)
	,
	cte_combine
	as
	(
	  select
		  id                   = p1.serviceJournalAssociatedEventTypeID  /* Used for event type */
		, orpDocID             = p1.id
		, reqORPDoc            = 1
		, name                 = p1.name
		, context1
		, label                = p1.svcNoteTemplateTitle
		, svcNoteTemplateTitle = p1.svcNoteTemplateTitle
		, svcNoteTemplateText
		, svcNoteCriteriaFormQuestionsJSON 
		, orpDocName           = p1.name
		, reqStartTime         = 1
		, reqEndTime           = 1
		, iep                  = p1.iep
		, p1.lastApprovalExpirationState
		, p1.formBuilderContentForServiceJournalEntryNotesJSON

	  from cte_orders  as p1
	
	  union all
	
	  select
	   
	      id                   = p2.id
		, orpDocID             = p2.orpDocID
		, reqORPDoc            = iif(p2.reqORPDoc = 1 or p2.orpDocID is not null, 1, 0)
		, name                 = p2.name
		, context1             = ''
		, label                = p2.eventLabel
		, svcNoteTemplateTitle = ''
		, svcNoteTemplateText  = ''
		, svcNoteCriteriaFormQuestionsJSON = ''
		, orpDocName           = p2.orpDocName
		, reqStartTime         = p2.reqStartTime
		, reqEndTime           = p2.reqEndTime
		, iep                  = null -- if this is added later, just change this to p2.iep
		, lastApprovalExpirationState = 1
		, formBuilderContentForServiceJournalEntryNotesJSON = ''
		
	  from cte_journal_events as p2
	)

	select 
		   p3.*
		 , svcNameID = setpgs.nameID

	from cte_combine as p3

	left join dbo.SvcJournal_Event_Types_PracClass_Groups_ServiceNames as setpgs
		on setpgs.eventType = p3.id and setpgs.planType = 2 and setpgs.groupID = @groupID
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE] TO [webuser]
GO  
