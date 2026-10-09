USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_DIFFERENCE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_DIFFERENCE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_DIFFERENCE](@value1 DECIMAL(32,16), @value2 DECIMAL(32,16), @calculation INT) 
RETURNS DECIMAL(32,16) 
WITH SCHEMABINDING
AS     
BEGIN    
  
  /*-------------------------------
   * If any of our values are null
   * return null
   *------------------------------*/
  
  if (@value1      is null) return null
  if (@value2      is null) return null
  
  declare @diffamt as DECIMAL(32,16)  
  declare @diffper as DECIMAL(32,16)
  
  /*-------------------------------
   * Calculate difference (amount)
   * between value2 and 1
   *------------------------------*/

  set @diffamt = @value2 - @value1
   
  /*-------------------------------
   * Return it, if this calculation
   * is what is asked for
   *------------------------------*/

  if (@calculation = 1) 
    return @diffamt
   
   /*-------------------------------
    * Calculate difference (percent)
    * if this is what is asked for
    *------------------------------*/

  if (@calculation = 2)
  begin
    
    /*-------------------------------
     * If value1 is 0 then we cannot
     * compute a percentage
     *------------------------------*/
   
    if (@value1 = 0) 
      return null    
     
    /*-------------------------------
     * Calculate and return
     *------------------------------*/

    set @diffper = (@diffamt / @value1) * 100
    return @diffper
  end
  
  /*-------------------------------
   * If we reach this point
   * calculation was unknown
   * return null
   *------------------------------*/

  return null
END  
GO
