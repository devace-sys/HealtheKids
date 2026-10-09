USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA] (
  @purposeSpecificData  varchar(max)
)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA */    
 /**    
  * Decodes purpose specific data
  *    
  ***************************************************************************/     
 
AS RETURN
( 
  select top 1
     psd.serviceType
   , psd.serviceSubType
   , psd.patID
   , psd.patGroupID
  from OPENJSON(@purposeSpecificData)
  WITH (
     serviceType      bigint   '$.serviceType'
   , serviceSubType   bigint   '$.serviceSubType'
   , patID            bigint   '$.patID'
   , patGroupID       bigint   '$.patGroupID'
  ) as psd
)

GO

GRANT SELECT ON [dbo].[TELECOMM_HEALTH_DESERIALIZE_PURPOSE_SPECIFIC_DATA] TO [webuser]
GO
