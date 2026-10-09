USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DECODE_FLAG') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DECODE_FLAG
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[DECODE_FLAG] (@flags int, @flag smallint)    
returns bit  
WITH SCHEMABINDING   
    
/***************************************************************************    
 * DECODE_FLAG */    
/**    
 *    
 * @param   flags            Flags
 * @param   flag             Flag to decode 
 * @return  bit
 ***************************************************************************/            
     
as           
begin    

  declare @flagValue as bit
  set @flagValue = cast(0 as bit)

  /*-------------------------------    
   * Handle undefined or 
   * innapropriate values
   *------------------------------*/   

  if @flags is null return null
  if @flag  is null return null
  if @flag = 0      return null

  /*-------------------------------    
   * Bitwise AND to unmask 
   *------------------------------*/   

  set @flagValue = cast(((@flags & @flag)/@flag) as bit)
  return @flagValue

end    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXEC ON [dbo].[DECODE_FLAG] TO [webuser]
GO