USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE] (
  @userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,
  @clientID            BIGINT, 
  @planID              BIGINT,
  @recID               INT )    
 
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
 
select 
    id                      = pwd.ID
  , name                    = pwd.NAME
  , description             = pwd.DESCRIPTION
  , clientID                = pwd.CLIENT_ID  
from dbo.PLAN_WRITER_PLANS_DIAGNOSES as pwd

where (
       (1=1)   
   and ((@clientID is null) or (pwd.CLIENT_ID = @clientID))
   and ((@planID is null)   or (pwd.PLAN_ID = @planID)) 
   and ((@recID     is null)  or (pwd.ID      = @recID))
)

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_DIAGNOSES_VIEW_CORE] TO [webuser]
GO