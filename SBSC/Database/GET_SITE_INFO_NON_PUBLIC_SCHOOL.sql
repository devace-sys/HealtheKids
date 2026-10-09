USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

DROP FUNCTION if exists dbo.GET_SITE_INFO_NON_PUBLIC_SCHOOL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[GET_SITE_INFO_NON_PUBLIC_SCHOOL] (@clientID as bigint)     
RETURNS TABLE
AS 
RETURN (

select top 1
  ss.SITE_ID,
  ss.SITE_CDS
from dbo.SITES_Site as ss
where
   (ss.SITE_ID = dbo.GET_SITE_ID_NON_PUBLIC_SCHOOL(@clientID))


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[GET_SITE_INFO_NON_PUBLIC_SCHOOL] TO [webuser]
GO


