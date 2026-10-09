USE users
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_SIGNATURES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USER_SIGNATURES_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[USER_SIGNATURES_VIEW_CORE] (
   @userID              BIGINT    
 , @userGroup           INT    
 , @userRank            INT
 , @signatureUserID     BIGINT
 , @signaturePersonID   BIGINT
 , @active              BIT
 , @recID               INT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * USER_SIGNATURES_VIEW_CORE */    
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
 
select * from dbo.USER_SIGNATURES  as us
where (
	    (1=1)
	and (@signatureUserID = @userID)
	and ((@signatureUserID   is null) or (us.userID   = @signatureUserID  ))
	and ((@signaturePersonID is null) or (us.personID = @signaturePersonID))
	and ((@active            is null) or (us.active   = @active           ))
	and ((@recID             is null) or (us.id       = @recID            ))
)


)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[USER_SIGNATURES_VIEW_CORE] TO [webuser]
GO