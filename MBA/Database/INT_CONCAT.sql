USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INT_CONCAT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INT_CONCAT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION INT_CONCAT (@val1 as int,     
                            @val2 as int)    
returns                     int 
WITH SCHEMABINDING 

/***************************************************************************    
 * INT_CONCAT */    
/**    
 * Convert val1 and val2 into strings.  Concats the strings together and
 * returns the result of the concat as an integer.
 * 
 * The values must be positive
 *
 * For example:
 *
 *   INT_CONCAT(1,9) will return a 19   
 *
 * @param  val1   First integer value
 * @param  val2   Second integer value
 * @return        int 
 ***************************************************************************/            
     
as           
begin    
    

declare @val1Str     as varchar(7)
declare @val2Str     as varchar(7)
declare @val1val2Str as varchar(14)
declare @val1val2    as int

/*-------------------------------    
 * Force positive values
 *------------------------------*/    

if (@val1 < 0) set @val1 = @val1 * -1
if (@val2 < 0) set @val2 = @val2 * -1

/*-------------------------------    
 * Convert values to strings
 *------------------------------*/    

set @val1Str = CONVERT(varchar(7),@val1)
set @val2Str = CONVERT(varchar(7),@val2)

/*-------------------------------    
 * Concat them
 *------------------------------*/    

set @val1val2Str = @val1Str + @val2Str

/*-------------------------------    
 * Convert concated value back
 * to integer and return it
 *------------------------------*/    

set @val1val2 = CONVERT(int,@val1val2Str)
return @val1val2
          
end    
GO
