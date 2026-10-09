USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CLOSURE_VERIFY_NODE_EXISTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLOSURE_VERIFY_NODE_EXISTS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about specific node, confirm that the identity closure for that node exists */

CREATE FUNCTION [dbo].CLOSURE_VERIFY_NODE_EXISTS ( 
  
  @closure_type		bigint,
  @node_type		bigint,
  @node_value		bigint
  ) 

RETURNS bit

AS
BEGIN
 declare @exists bit = 0
 
	if exists (select 1 from Closure_Table_Structure 
					where closure_type = @closure_type and depth = 0 
					and	parent = @node_value and parent_type = @node_type and child = @node_value and child_type = @node_type)
	BEGIN
		set @exists = 1	
	END
 
	return @exists	 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].CLOSURE_VERIFY_NODE_EXISTS TO [webuser]
GO