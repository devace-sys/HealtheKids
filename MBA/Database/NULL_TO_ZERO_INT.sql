USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NULL_TO_ZERO_INT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NULL_TO_ZERO_INT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION NULL_TO_ZERO_INT (@valin as int) returns int 
WITH SCHEMABINDING 

/***************************************************************************    
 * NULL_TO_ZERO_INT */    
/**    
 * If @valin is null, returns a 0 otherwise returns valin
 *
 * @param  valin Integer value
 * @return int 
 ***************************************************************************/            
     
as           
begin    
    
if (@valin is null) set @valin = 0
return @valin
          
end    
GO
