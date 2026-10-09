USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Validate') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SvcJournal_Journal_Validate
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Validate] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @journalID         BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journal_Validate */    
 /**    
  * Returns a list of problems with the journal
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select * from dbo.SvcJournal_Journal_Journal_Validate(@userID,@userGroup,@userRank,@clientID,@journalID)
  union all
  select * from dbo.SvcJournal_Journal_Entries_Validate(@userID,@userGroup,@userRank,@clientID,@journalID,null)
  union all
  select * from dbo.SvcJournal_Journal_Entries_Validate_Missing_Orp (@userID,@userGroup,@userRank,@clientID,@journalID)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Validate] TO [webuser]
GO  
