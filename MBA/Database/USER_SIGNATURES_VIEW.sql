USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_SIGNATURES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USER_SIGNATURES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[USER_SIGNATURES_VIEW] (
   @userID              BIGINT    
 , @userGroup           INT    
 , @userRank            INT
 , @signatureUserID     BIGINT
 , @signaturePersonID   BIGINT
 , @active              BIT
 , @recID               INT )    
RETURNS TABLE
 
 /***************************************************************************    
  * USER_SIGNATURES_VIEW */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
(

select top (dbo.CONST_MAX_ROWS()) 
  * 
from dbo.USER_SIGNATURES_VIEW_CORE (
    @userID           
  , @userGroup        
  , @userRank         
  , @signatureUserID  
  , @signaturePersonID
  , @active           
  , @recID       ) as t1     

order by 
  t1.id desc
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[USER_SIGNATURES_VIEW] TO [webuser]
GO