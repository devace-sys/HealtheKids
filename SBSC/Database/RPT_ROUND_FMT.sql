USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_ROUND_FMT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_ROUND_FMT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[RPT_ROUND_FMT](@amount AS DECIMAL(18,8)) 
RETURNS VARCHAR(100) 
WITH SCHEMABINDING 
AS     
    
/***************************************************************************    
 * RPT_ROUND_FMT */    
/**    
 * Formats amounts for financial reporting    
 * Rounds amount to the nearest whole dollar, inserts commas for each    
 * thousands place, and removes the decimal point.    
 *    
 * @param  amount          Dollar amount    
 * @return                 Formatted dollar    
 ***************************************************************************/            
    
BEGIN    
        
  declare @tempAmount as varchar(100)    
  declare @idx        as int    
     
  /*-------------------------------    
   * Round amount to nearest dollar    
   *------------------------------*/    
    
  set @amount = round(@amount,0)     
    
  /*-------------------------------    
   * Convert rounded amount to     
   * string and insert thousands    
   * seperators (commas)    
   *------------------------------*/    
    
  set @tempAmount = CONVERT(VARCHAR(100), CONVERT(money,@amount),1)    
    
  /*-------------------------------    
   * Remove cents (.00) and return    
   *------------------------------*/    
      
  set @idx = charindex('.',@tempAmount) - 1    
  return left(@tempamount,@idx)    
    
END  
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT EXECUTE ON  [dbo].[RPT_ROUND_FMT] TO [webuser]
GO
