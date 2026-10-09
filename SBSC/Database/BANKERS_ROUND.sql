USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BANKERS_ROUND') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BANKERS_ROUND
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BANKERS_ROUND](@value Decimal(32,16), @digits INT) RETURNS Decimal(32,16)
WITH SCHEMABINDING
AS     
BEGIN    
return 
    
    -- Courtesey of George Mastros
    -- http://blogs.lessthandot.com/index.php/DataMgmt/DataDesign/sql-server-rounding-methods
  
  case 
    when Abs(@value - Round(@value, @digits, 1)) * Power(10, @digits + 1) = 5
    then Round(@value, @digits, Case When Convert(int, Round(abs(@value) * power(10,@digits), 0, 1)) % 2 = 1 Then 0 Else 1 End)
    else Round(@value, @digits)
  end    
END    
GO
