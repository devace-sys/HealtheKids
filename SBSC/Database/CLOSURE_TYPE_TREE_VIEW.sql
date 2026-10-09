USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CLOSURE_TYPE_TREE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLOSURE_TYPE_TREE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given a specific type, return the transitive closure subtable for which that type applies. Includes identity filtering. */

CREATE FUNCTION [dbo].CLOSURE_TYPE_TREE_VIEW ( 
  
  @closure_type bigint,
  @include_identities bit = 0
 
  ) 

RETURNS TABLE AS RETURN(
 
select 
	parent_type , parent , 
	child_type , child , 
	depth
from 
	Closure_Table_Structure cts
	where cts.closure_type = @closure_type
	 and (cts.depth <> 0 or @include_identities = 1)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].CLOSURE_TYPE_TREE_VIEW TO [webuser]
GO