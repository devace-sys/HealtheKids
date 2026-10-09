USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW] ()    

RETURNS TABLE
 
 /***************************************************************************    
  * CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW */    
 /**    
  * Returns a processed list of records from CDE_SCHOOLS_PUBLIC
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with 
cte_cde_public_schools_pass_1
as
(
  select 
    *
    ,[CountyCode]   = left     (CDSCode, 2) 
    ,[DistrictCode] = substring(CDSCode, 3, 5)
    ,[SchoolCode]   = right    (CDSCode, 7)    
  from CDE_SCHOOLS_PUBLIC
)
,
cte_cde_public_schools_pass_2
as
(
  select 
    *   
    , [IsDistrictRecord] = case when SchoolCode = '0000000'               then 1 else 0 end
    , [IsCharterRecord]  = case when Charter = 'Y'                        then 1 else 0 end
    , [IsCurrent]        = case when StatusType in ('Active','Pending')   then 1 else 0 end
  from cte_cde_public_schools_pass_1
)

select top (dbo.CONST_MAX_ROWS()) * from cte_cde_public_schools_pass_2 order by School

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CDE_SCHOOLS_PUBLIC_SCHOOLS_CORE_VIEW] TO [webuser]
GO   
