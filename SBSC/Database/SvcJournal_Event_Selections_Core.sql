USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Event_Selections_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Event_Selections_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Event_Selections_Core] (
    @userID        bigint    
  , @userGroup     int  
  , @userRank      int
  , @noteNamespace varchar(500)
  , @noteSource    varchar(500)
  , @isDefault     bit
  , @journalID     bigint
  , @pracID        bigint
  , @term          varchar(255)
  , @recID         int
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Event_Selection_Core */    
 /**    
  * Returns a list of event selections
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

/*###########################################################################
  # All event types that given pracID can select from
  ###########################################################################*/

with
cte_event_types_p1
as
(
  select 
      sjet.*    
    , clientID = jd.clientID
    , dos     = jd.dos
    , patID   = jd.patID
    , groupID = pg.GROUP_ID
      
  from dbo.SvcJournal_PracClass_PracGroup as sjcg
  join dbo.PRACTITIONER_GROUPS            as pg   on  pg.GROUP_ID        = sjcg.groupID
                                                  and pg.PRACTITIONER_ID = @pracID
  join dbo.SvcJournal_Event_Types         as sjet on  sjet.pracClass     = sjcg.pracClass
  
  outer apply (
    select top 1 clientID, dos, patID from dbo.SvcJournals where (id = @journalID)
  ) as jd
  
  where ( 
        (sjet.active = 1) 
    and (display     = 1)
  )
)
,
cte_event_types_p2
as
(
  select        
      p1.*    
    
	/* Note: ~ is used as an invert */

	, reqORPDoc  = dbo.IS_ORP_REQUIRED_FOR_SVC (~p1.reqORP, 2, p1.dos,1)
    , orpDocID    = orp.id
    , orpDocName  = orp.name
    , orpDocRefID = orp.refID
  
  from cte_event_types_p1 as p1
   
  outer apply (
  
     select top 1 
     
         id
       , name 
       , refID
    
     from dbo.ORP_DOCUMENTS_VIEW_CORE (  @userID        
                                       , @userGroup
                                       , @userRank
                                       , p1.clientID             /* Limit to client */
                                       , 3                       /* Limit to health services group family */
                                       , p1.patID                /* Only docs for patient */
                                       , null
                                       , case when (p1.ORP_DOCUMENT_TYPE_ID = 3) then 3 else -1 end                                       
									   , null
                                       , 1           /* Active only */    
                                       , null )
  ) as orp
)

select top (dbo.CONST_MAX_ROWS())
   
     id
   , name=eventLabel 
   , eventLabel
   , reqStartTime
   , reqEndTime
   , reqNote
   , reqORPDoc   
   , orpDocTypeID = ORP_DOCUMENT_TYPE_ID
   , orpDocID
   , orpDocName
   , orpDocRefID 
   , isDefault
   , contSvcGroupPart
   , noteNamespace
   , noteSource
   , active
   , clientID
   , dos
   , patID
   , groupID
from 

  cte_event_types_p2 as jet

where (
        (1=1)
    and ((@recID         is null) or (jet.id            = @recID))
    and ((@noteNamespace is null) or (jet.noteNamespace = @noteNamespace))
    and ((@noteSource    is null) or (jet.noteSource    = @noteSource))
    and ((@isDefault     is null) or (jet.isDefault     = @isDefault))
    and ((@term          is null) or (jet.eventLabel like ((@term + '%'))))
)

order by 
  displayOrder

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Event_Selections_Core] TO [webuser]
GO  
