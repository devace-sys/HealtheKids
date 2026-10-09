USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW] (  @CountyCode as varchar(2)
                                                           ,@term       as varchar(255))

RETURNS TABLE
 
 /***************************************************************************    
  * CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW */    
 /**    
  * Returns a list of public counties
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with 
cte_cde_public_schools
as
(
  select * from CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW()  
)
,
cte_cde_public_counties
as
(
  select distinct [CdsCode] = '', [CountyCode], County as [CountyName] from cte_cde_public_schools where IsCurrent = 1
)
,
cte_cde_output
as
(
select
    name  = [CountyName]
  , value = [CountyCode]
  , * 
from cte_cde_public_counties
where 
      ((1=1)
  and ((@CountyCode is null) or (CountyCode = @CountyCode))
  and ((@term is null) or (CountyName like ((@term + '%')))))
)
select top (dbo.CONST_MAX_ROWS()) * from cte_cde_output order by CountyName


)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CDE_SCHOOLS_PUBLIC_COUNTIES_VIEW] TO [webuser]
GO   
