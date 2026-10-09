USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW] ( @CountyCode   as varchar(2)
                                                         ,@DistrictCode as varchar(5)
                                                         ,@SchoolCode   as varchar(7)
                                                         ,@term         as varchar(255))    

RETURNS TABLE
 
 /***************************************************************************    
  * CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW */    
 /**    
  * Returns list of public schools
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with 
cte_cde_public_schools_pass_1
as
(
  select * from CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW() 
  where IsCurrent = 1 and IsDistrictRecord = 0 and ((@CountyCode is null) or (CountyCode = @CountyCode)) and ((@DistrictCode is null) or (DistrictCode = @DistrictCode))
)
,
cte_cde_public_schools_pass_2
as
(
  select distinct 
    CdsCode,
    CountyCode, 
    County as [CountyName], 
    DistrictCode, 
    District as [DistrictName], 
    SchoolCode, 
    School as [SchoolName]
    
  from cte_cde_public_schools_pass_1
)
,
cte_cde_output
as
(
select 
    name  = [SchoolName]
  , value = [SchoolCode]
  , * 
from cte_cde_public_schools_pass_2
where 
      ((1=1)
  and ((@CountyCode   is null) or (CountyCode   = @CountyCode))
  and ((@DistrictCode is null) or (DistrictCode = @DistrictCode))
  and ((@SchoolCode   is null) or (SchoolCode   = @SchoolCode)) 
  and ((@term         is null) or (SchoolName like ((@term + '%')))))
)
select top (dbo.CONST_MAX_ROWS()) * from cte_cde_output order by CountyName, DistrictName, SchoolName



)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CDE_SCHOOLS_PUBLIC_SCHOOLS_VIEW] TO [webuser]
GO   
