USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID             BIGINT
  , @startDate         DATETIME
  , @endDate           DATETIME
  , @completed         BIGINT
  , @recID             BIGINT)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_View_Core */    
 /**    
  * Returns a list of journal entry data
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
RETURN
(
  select * from dbo.SvcJournal_View_Core(@userID,@userGroup,@userRank,@clientID, @patID , @startDate, @endDate, @completed, @recID)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_View] TO [webuser]
GO  

