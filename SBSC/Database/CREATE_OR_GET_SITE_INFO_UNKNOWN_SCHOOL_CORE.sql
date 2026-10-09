USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


DROP PROCEDURE if exists dbo.CREATE_OR_GET_SITE_INFO_UNKNOWN_SCHOOL_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE PROCEDURE [dbo].[CREATE_OR_GET_SITE_INFO_UNKNOWN_SCHOOL_CORE]
                       -- so called because this doesn't contain it's own transaction block
(
  @clientID bigint,
  @siteID   bigint output,
  @siteCDS  nchar(7) output
)
AS 
BEGIN

  select top 1
    @siteID  = SITE_ID,
    @siteCDS = SITE_CDS
  FROM  [dbo].[GET_SITE_INFO_UNKNOWN_SCHOOL] (@clientID)

  IF ( @siteID IS NOT NULL)
    RETURN (0)

  INSERT INTO dbo.SITES_Site
  (
   SITE_CLIENT_ID ,
   SITE_CDS ,
   SITE_NAME ,
   ACTIVE
  )
  
  SELECT top 1
    @clientID ,
    nex7_v.NEXT_CDS_NUMBER ,  
    dbo.CONST_UNKNOWN_SCHOOL_NAME(),
    1
  FROM [dbo].[GENERATE_NEXT_CDS_7_X_CODE] nex7_v

  select top 1
    @siteID  = SITE_ID,
    @siteCDS = SITE_CDS
  FROM  [dbo].[GET_SITE_INFO_UNKNOWN_SCHOOL] (@clientID)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[CREATE_OR_GET_SITE_INFO_UNKNOWN_SCHOOL_CORE] TO [webuser]
GO

