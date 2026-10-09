USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA] (
  @purposeSpecificData  varchar(max)
)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA */    
 /**    
  * Decodes purpose specific data
  *    
  ***************************************************************************/     
 
AS RETURN
( 
  select top 1
      psd.patID  
	, psd.iepFormType
  from OPENJSON(@purposeSpecificData)
  WITH (
      patID       bigint  '$.patID'   
	, iepFormType bigint  '$.iepFormType'
  ) as psd
)

GO

GRANT SELECT ON [dbo].[TELECOMM_IEP_DESERIALIZE_PURPOSE_SPECIFIC_DATA] TO [webuser]
GO
