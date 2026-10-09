USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW] (
  @userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,
  @clientID            BIGINT,
  @groupSvcClassNameID bigint,
  @planID              bigint,
  @active              BIT,
  @recID               INT )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW */    
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
 
SELECT top (dbo.CONST_MAX_ROWS())  
    *
  , name = ORP_DOCUMENT_STANDARD_SELECTION_NAME
FROM dbo.PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW_CORE (
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @groupSvcClassNameID
  , @planID
  , @active
  , @recID )
ORDER BY
   effectiveDate DESC
  ,svcName

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_PRESCRIBED_ORDERS_VIEW] TO [webuser]
GO