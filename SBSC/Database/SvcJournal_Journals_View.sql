USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_Journals_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_Journals_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_Journals_View] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID             BIGINT 
  , @dos               DATETIME
  , @completed         BIT
  , @recID             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SvcJournal_Journals_View */    
 /**    
  * Returns a list of journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select 
    * 
    , rank() over (order by sj.dosVal, sj.patName, sj.patID) as [rowOrder]
  from dbo.SvcJournal_Journals_View_Core (@userID, @userGroup, @userRank, @clientID, @patID, @dos, @completed, @recID) as sj
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_Journals_View] TO [webuser]
GO  
