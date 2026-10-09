USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW] ( @CountyCode   as varchar(2)
                                                           ,@DistrictCode as varchar(5)
                                                           ,@term         as varchar(255))    

RETURNS TABLE
 
 /***************************************************************************    
  * CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW */    
 /**    
  * Returns list of public districts from cde
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with 
cte_cde_public_schools
as
(
  select * 
  from CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW() 
  where (
        (IsCurrent = 1) 
    and ((IsDistrictRecord = 1) or (IsCharterRecord = 1))
    and ((@CountyCode is null)  or (CountyCode = @CountyCode))
  )
)
,
cte_cde_public_districts
as
(
  select distinct 
    CdsCode
    , [CountyCode]
    , County as [CountyName]
    , DistrictCode
    , [DistrictName] = case 
        when IsDistrictRecord = 0 and IsCharterRecord = 0 then District
        when IsDistrictRecord = 1 and IsCharterRecord = 0 then District
        when IsDistrictRecord = 0 and IsCharterRecord = 1 then School
        when IsDistrictRecord = 1 and IsCharterRecord = 1 then District
      end
    
  from cte_cde_public_schools
)
,
cte_cde_output
as
(
select 
    name  = [DistrictName]
  , value = [DistrictCode]
  , * 
from cte_cde_public_districts
where 
      ((1=1)
  and ((@CountyCode   is null) or (CountyCode   = @CountyCode))
  and ((@DistrictCode is null) or (DistrictCode = @DistrictCode))
  and ((@term         is null) or (DistrictName like ((@term + '%')))))
)
select top (dbo.CONST_MAX_ROWS()) * from cte_cde_output order by CountyName, DistrictName

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CDE_SCHOOLS_PUBLIC_DISTRICTS_VIEW] TO [webuser]
GO   
