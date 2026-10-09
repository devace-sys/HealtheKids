USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.USER_IS_ACTIVE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.USER_IS_ACTIVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION USER_IS_ACTIVE (@roleIdUid as uniqueidentifier)    

returns                         bit   
    
/***************************************************************************    
 * USER_IS_ACTIVE */    
/**    
 * Returns the users active status.
 *    
 * @return 0 = inactive 1= active
 ***************************************************************************/            
     
as           
begin    
    
  if (@roleIDUid is null)                     return 0
  if (@roleIdUid = dbo.CONST_ROLE_INACTIVE()) return 0
  return 1
end    
    
GO
