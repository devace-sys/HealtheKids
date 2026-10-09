USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_CAN_SHOW_FOR_PLAN_TYPE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_CAN_SHOW_FOR_PLAN_TYPE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICES_CAN_SHOW_FOR_PLAN_TYPE]
(    
    @planType                     int = 0
  , @participatesInLeaBop         bit = 0
  , @participatesInLEABOPNonSpEd  bit = 0
  , @participatesInCYBHI          bit = 0
  , @participatesInRUHealth       bit = 0
  
) 
RETURNS bit
WITH SCHEMABINDING
AS     
BEGIN    
  if ((@planType in (1,2))   and (@participatesInLeaBop        = 1))  return 1
  if ((@planType = 3)        and (@participatesInLEABOPNonSpEd = 1))  return 1
  if ((@planType = 4)        and (@participatesInCYBHI         = 1))  return 1
  if ((@planType = 5)        and (@participatesInRUHealth      = 1))  return 1
  return 0    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[SERVICES_CAN_SHOW_FOR_PLAN_TYPE] TO [webuser]
GO