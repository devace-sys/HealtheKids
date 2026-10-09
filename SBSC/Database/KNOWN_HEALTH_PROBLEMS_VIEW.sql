USE SPEDMON
GO
 

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.KNOWN_HEALTH_PROBLEMS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.KNOWN_HEALTH_PROBLEMS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[KNOWN_HEALTH_PROBLEMS_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT
  , @groupSvcClassNameID   BIGINT 
  , @term				   VARCHAR(256)
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(
with
cte_p1
as
(
select
  khp.*
  
, canView = case
  
  /* If this is a non prac user (all non prac users will pass a null) 
   * then user can view this selection */

  when (@groupSvcClassNameID is null) then 1 

  /* If this rec is mental health related and this is a mental health prac 
   * then user can view this selection. */
     
  when ((khp.belongsToMentalHealth = 1) and (@groupSvcClassNameID = 2)) then 1 
  
  /* If this rec is health service related and this is a health service prac 
   * then user can view this selection */

  when ((khp.belongsToHealthServices = 1) and (@groupSvcClassNameID = 3)) then 1 
  
  /* If this rec is mental health related and this is NOT a mental health prac 
   * then then user cannot view this selection*/ 

  when ((khp.belongsToMentalHealth   = 1) and ( @groupSvcClassNameID != 2)) then 0 

  /* If this rec is health service related and this is not a health service prac 
  * then user cannot view this selection */

  when ((khp.belongsToHealthServices = 1) and ( @groupSvcClassNameID != 3)) then 0 
  
  /* User can view the selection */

  else 1      
end
from dbo.KNOWN_HEALTH_PROBLEMS as khp
where (
      (1=1)
  and ((@recID is null) or (khp.id = @recID))
  and ((@term is null) or (khp.[name] like '%' + @term + '%'))
  and (khp.active = 1)
)
)
select top (dbo.CONST_MAX_ROWS()) 
  p1.*
from cte_p1 as p1
where
  (p1.canView = 1)
order by 
  p1.name

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[KNOWN_HEALTH_PROBLEMS_VIEW] TO [webuser]
GO