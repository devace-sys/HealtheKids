USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PERCENTAGE_Fulfillment') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PERCENTAGE_Fulfillment
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PERCENTAGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PERCENTAGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CALC_PERCENTAGE (
    @dividend       int
  , @divisor        int
  , @multiplyBy100  bit = 1
  , @round          bit = 1
  , @roundPrecision int = 2
) 
RETURNS REAL 
WITH SCHEMABINDING
AS     
BEGIN 
     
  declare @pct         as real = 0
  declare @dividendVal as real = convert(real, @dividend)
  declare @divisorVal  as real = convert(real, @divisor)
  declare @quotient    as real = 0

  if (@dividend is null) return null
  if (@divisor  is null) return null
  
  set @dividendVal = convert(real, @dividend)
  set @divisorVal  = convert(real, @divisor)
  
  if (@dividendVal = 0) return 0
  if (@divisorVal  = 0) return 0
  set @quotient = (@dividendVal / @divisorVal)

  if (@multiplyBy100 = 1) 
    set @pct = (100 * @quotient)
  else
    set @pct = @quotient

  if (@round = 1) return round(@pct,@roundPrecision)    
  
  return @pct   
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_PERCENTAGE] TO [webuser]
GO