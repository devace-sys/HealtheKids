USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journal_Entries_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journal_Entries_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journal_Entries_View] (
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
  * SvcJournal_Journal_Entries_View */    
 /**    
  * Returns a list of journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select 
  
    * 
    , rank() over (order by sjee.dosVal, sjee.startTimeVal, sjee.pracID, sjee.endTimeVal) as [rowOrder]
  
  from dbo.SvcJournal_Journal_Entries_View_Core (  @userID
                                                 , @userGroup
                                                 , @userRank
                                                 , @clientID
                                                 , @pracID
                                                 , @journalID
                                                 , @recID) as sjee
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journal_Entries_View] TO [webuser]
GO  
