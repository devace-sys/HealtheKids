USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PCAL_PROMISED_SERVICE_DELIVERY_COMPLIANCE_RATING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PCAL_PROMISED_SERVICE_DELIVERY_COMPLIANCE_RATING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CALC_PCAL_PROMISED_SERVICE_DELIVERY_COMPLIANCE_RATING (@pctExpectedSatisfied real) 
RETURNS TINYINT
WITH SCHEMABINDING
AS     
BEGIN 
 
  return convert(tinyint,(case  	
	when @pctExpectedSatisfied between 95 and 100  then 10 /* 95% - 100% */
    when @pctExpectedSatisfied between 85 and 94   then 8  /* 85% - 94% */
    when @pctExpectedSatisfied between 50 and 84   then 6  /* 50% - 84% */
    when @pctExpectedSatisfied between 25 and 49   then 4  /* 25% - 49% */
    when @pctExpectedSatisfied <= 24               then 2  /* Below 25% */	
    else -1 end /* Should never get here */ ))

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_PCAL_PROMISED_SERVICE_DELIVERY_COMPLIANCE_RATING] TO [webuser]
GO