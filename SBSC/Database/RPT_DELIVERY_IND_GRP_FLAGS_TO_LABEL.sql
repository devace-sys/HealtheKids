USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL] (
    @individualDelivery bit
  , @groupDelivery      bit
)
RETURNS varchar(50) 
WITH SCHEMABINDING 
AS     
BEGIN    
  set @individualDelivery = isnull(@individualDelivery,0)
  set @groupDelivery      = isnull(@groupDelivery,0)
  if ((@individualDelivery = 0) and (@groupDelivery = 0)) return 'Delivery Not Specified'
  if ((@individualDelivery = 0) and (@groupDelivery = 1)) return 'Group Delivery'
  if ((@individualDelivery = 1) and (@groupDelivery = 0)) return 'Individual Delivery'
  if ((@individualDelivery = 1) and (@groupDelivery = 1)) return 'Individual and Group Delivery'
  return ''
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL] TO [webuser]
GO
