USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUP_FIND_PARENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUP_FIND_PARENT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GROUP_FIND_PARENT]
(@groupID as bigint)     
RETURNS bigint 

/***************************************************************************
 * GROUP_FIND_PARENT */
/**
 * Returns parent group
 *             
 * @return            
 ***************************************************************************/  

AS 
BEGIN
declare @parent as bigint       
  select @parent = parent_group_id from GROUP_Group where group_id = @groupID
return @parent
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[GROUP_FIND_PARENT] TO [webuser]
GO

