USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BIT_TO_MSG') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BIT_TO_MSG
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BIT_TO_MSG] (@bitin bit, 
                                    @truemsg varchar(8000), 
                                    @falsemsg varchar(8000)) RETURNS varchar(8000) 
WITH SCHEMABINDING 
AS    
BEGIN    
  
  declare @msgout as varchar(8000)
  
  if (@bitin is null) return ''
  
  if (@truemsg  is null) set @truemsg = ''
  if (@falsemsg is null) set @falsemsg = ''
  
  if (@bitin = 1) 
    set @msgout = @truemsg
  else 
    set @msgout = @falsemsg
         
  return @msgout
  
END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[BIT_TO_MSG] TO [webuser]

GO