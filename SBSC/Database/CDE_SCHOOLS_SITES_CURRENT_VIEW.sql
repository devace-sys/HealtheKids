USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CDE_SCHOOLS_SITES_CURRENT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CDE_SCHOOLS_SITES_CURRENT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CDE_SCHOOLS_SITES_CURRENT_VIEW] (  @term     as varchar(255)
                                                        , @cdsCode  as varchar(14))

RETURNS TABLE
 
/***************************************************************************    
 * CDE_SCHOOLS_SITES_CURRENT_VIEW */    
/**    
 * Returns a list of public and private school sites
 *
 * @return table 
 ***************************************************************************/                         
     
AS RETURN
(
select 
  * 
from dbo.CDE_SCHOOLS_SITES_CURRENT
where (
      (1=1)
  and ((@cdsCode is null) or (CDSCode = @cdsCode))
  and ((@term    is null) or (School like ((@term + '%'))))
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CDE_SCHOOLS_SITES_CURRENT_VIEW] TO [webuser]
GO   
