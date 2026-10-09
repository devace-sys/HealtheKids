USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Entries_Validate_Missing_Orp') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Journal_Entries_Validate_Missing_Orp
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Entries_Validate_Missing_Orp] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT
  , @clientID          BIGINT      
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Entries_Validate_Missing_Orp */    
 /**    
  * Returns a list of orp compliance issues with the journal entries
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select  
     [journalID] = sj.id 
   , [pracID]    = sjee.pracID
   , [pracName]  = prp.CONCAT_NAME
   , [retState]  = dbo.CONST_RET_ERR()
   , [retStatus] = 'Problem'
   , [problem] = 'Missing order or prescription for '
               + dbo.RPT_TIME_FMT(sjee.entryStartTime,0) 
               + ' ' + sjet.eventLabel              
   from dbo.SvcJournals               as sj 
   join dbo.SvcJournal_Event_Entries  as sjee on sjee.journalID = sj.id
   join dbo.PRACTITIONER_Practitioner as prp  on prp.PRACTITIONER_ID = sjee.pracID
   join dbo.SvcJournal_Event_Types    as sjet on sjet.id        = sjee.eventType
 
   where (
          (sj.id       = @journalID)  
      and (sj.clientID = @clientID)
      and (sj.dos >= dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE())
      and (sj.completed = 0) 
      and (sj.active    = 1)
      and (sjee.active  = 1)
      and (sjet.reqORP  = 1)
      and (isnull(sjee.orpDocID,0) = 0)
  )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Entries_Validate_Missing_Orp] TO [webuser]
GO  
