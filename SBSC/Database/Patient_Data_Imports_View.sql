USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[Patient_Data_Imports_View] (
    @userID               BIGINT
  , @userGroup            INT  
  , @userRank             INT 
  , @clientID             BIGINT  
  , @waitingForProcessing bit
  , @currentlyProcessing  bit
  , @processingComplete   bit
)    

RETURNS TABLE
 
 /***************************************************************************    
  * Patient_Data_Imports_View */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN

select 
  t1.* 
from dbo.Patient_Data_Imports_View_Core (
    @userID 
  , @userGroup
  , @userRank 
  , @clientID
  , @waitingForProcessing 
  , @currentlyProcessing
  , @processingComplete
  , null) as t1

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patient_Data_Imports_View] TO [webuser]
GO  
