USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CLOSURE_TREE_RELTYPE_DEPTH_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLOSURE_TREE_RELTYPE_DEPTH_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given a specified closure tree, provide filtering options based on the types of parent and child, as well as the maximum depth to return results on. */

CREATE FUNCTION [dbo].CLOSURE_TREE_RELTYPE_DEPTH_VIEW ( 
  
  @closure_type bigint,
  @include_identities bit = 0,
  @parent_type bigint,
  @child_type bigint,
  
  @maxdepth bigint
 
  ) 

RETURNS TABLE AS RETURN(
 
select 
	parent_type , parent , 
	child_type , child , 
	depth
from 
	CLOSURE_TYPE_TREE_VIEW(@closure_type, @include_identities) cttv
	where (parent_type = @parent_type or @parent_type is null)
		and (child_type = @child_type or @child_type is null)
		and (depth <= @maxdepth or @maxdepth is null)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].CLOSURE_TREE_RELTYPE_DEPTH_VIEW TO [webuser]
GO