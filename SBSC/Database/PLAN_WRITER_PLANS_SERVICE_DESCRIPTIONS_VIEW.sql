USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW] (
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
  * PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW */    
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
 
select top 1 

    * 
  , name = svcName

from PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW_CORE (
    @userID
  , @userGroup
  , @userRank 
  , @clientID 
  , @groupSvcClassNameID 
  , @planID 
  , @active 
  , @recID )
order by 
  effectiveDate desc

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_SERVICE_DESCRIPTIONS_VIEW] TO [webuser]
GO