
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLOSURE_DELETE_LINK') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLOSURE_DELETE_LINK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.CLOSURE_DELETE_LINK 
(
	@closuretype bigint,
	
	@parentfieldtype bigint,
	@parentfieldvalue bigint,

	@childfieldtype bigint,
	@childfieldvalue bigint
)

/***************************************** 
	Given an ancestor-descendant depth-1 link, remove that link and all dependent closure paths.
******************************************/

/* Replaces sproc SVCNOTES_DELETE_CLOSURE_LINKAGE */

AS
BEGIN
	IF dbo.CLOSURE_VERIFY_NODE_EXISTS(@closuretype, @parentfieldtype, @parentfieldvalue) = 1
	AND dbo.CLOSURE_VERIFY_NODE_EXISTS(@closuretype,@childfieldtype,@childfieldvalue) = 1
	
	/* Delete target closure specified in argument */
	delete from Closure_Table_Structure
		where 
			closure_type = @closuretype
			and parent_type = @parentfieldtype
			and parent = @parentfieldvalue
			and child_type = @childfieldtype
			and child = @childfieldvalue
		and Depth = 1

	/* Find all depth 2+ closures that have @descendant as a child and determine if they need to be deleted */
	
	
	delete Closure_Table_Structure 
	from Closure_Table_Structure fnc_ref
	inner join 
	
	(
	
	/* TODO: all these calls to Closure_Table_Structure could call a CTE around the DBF CLOSURE_TYPE_TREE_VIEW(@closuretype, 0) */
	
	select links_to_check.closure_type, links_to_check.[parent_type], links_to_check.parent, links_to_check.child_type, links_to_check.child, depth from Closure_Table_Structure as links_to_check
	CROSS APPLY
	(
		select COUNT(*) as NumOKLinks
			from Closure_Table_Structure fnc1 /* Find all existing links for the specified parent that go to the same depth as the parent we deleted link for */

				
			left outer join Closure_Table_Structure fnc2 /* find all depth 1 links upwards from the child that mach against the children from FNC1 */
				on fnc2.closure_type = fnc1.closure_type
				and fnc1.child = fnc2.parent
				and fnc1.child_type = fnc2.parent_type
				and fnc2.child = @childfieldvalue
				and fnc2.child_type = @childfieldtype
				and fnc2.depth = 1
				
			where	
			fnc1.closure_type = links_to_check.closure_type
				and links_to_check.parent = fnc1.parent
				and links_to_check.parent_type = fnc1.parent_type
				and fnc1.depth = links_to_check.depth - 1	
			and fnc2.depth is not null		
	)q

	where 	
		links_to_check.closure_type = @closuretype
		and links_to_check.child_type = @childfieldtype
		and links_to_check.child = @childfieldvalue
		and links_to_check.depth > 1
		and NumOKLinks = 0
	) linksToDelete
	on fnc_ref.closure_type = linksToDelete.closure_type
	and fnc_ref.parent_type = linksToDelete.parent_type
	and fnc_ref.parent = linksToDelete.parent
	and fnc_ref.child = linksToDelete.child
	and fnc_ref.child_type = linksToDelete.child_type
	and fnc_ref.depth = linksToDelete.depth

END
GO