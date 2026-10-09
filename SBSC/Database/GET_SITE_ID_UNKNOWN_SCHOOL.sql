USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_SITE_ID_UNKNOWN_SCHOOL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_SITE_ID_UNKNOWN_SCHOOL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_SITE_ID_UNKNOWN_SCHOOL] (@clientID as bigint)     
RETURNS bigint 
AS 
BEGIN
declare @siteID as bigint = null

select top 1
  @siteID = ss.SITE_ID 
from dbo.SITES_Site as ss
where (
      (ss.SITE_CLIENT_ID = @clientID)
  and (dbo.CDS_7_IS_X_CODE(ss.SITE_CDS) = 1)
  and (ss.SITE_NAME = dbo.CONST_UNKNOWN_SCHOOL_NAME())
  and (ss.ACTIVE = 1)
)
return @siteID

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[GET_SITE_ID_UNKNOWN_SCHOOL] TO [webuser]
GO

