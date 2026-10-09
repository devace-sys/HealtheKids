USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_DIAGNOSES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_DIAGNOSES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_DIAGNOSES_VIEW] (
 @userID              BIGINT,    
 @userGroup           INT,    
 @userRank            INT,
 @clientID            BIGINT, 
 @planID              BIGINT,
 @term                VARCHAR(256),
 @recID               BIGINT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE */    
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
from dbo.PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE (
  @userID,    
  @userGroup,    
  @userRank,
  @clientID, 
  @planID,
  @recID) 
where (
      (1=1)
  and ((@term is null) or (name like (isnull(@term,'') + '%')))  
)
order by
  name
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_DIAGNOSES_VIEW] TO [webuser]
GO