
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_DELETE_CLOSURE_LINKAGE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_DELETE_CLOSURE_LINKAGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_DELETE_CLOSURE_LINKAGE 
(
	@ANCESTOR uniqueidentifier,
	@DESCENDANT uniqueidentifier
)

/***************************************** 
	Given an ancestor-descendant depth-1 link, remove that link and all dependent closure paths.
******************************************/

AS
BEGIN

	/* Delete target closure specified in argument */
	delete from SvcNote_Hierarchy_Closure
		where Ancestor = @ANCESTOR
		and Descendant = @DESCENDANT
		and Depth = 1

	/* Find all depth 2+ closures that have @descendant as a child */

	declare @allParentClosures bigint_tabletype

	insert into @allParentClosures
		select distinct id 
		from SvcNote_Hierarchy_Closure
		where Descendant = @DESCENDANT and Depth >= 2

	/* for each of these parents - what are their immediate (depth 1) closures? */

	declare @closurePaths table (closureChecking bigint, topParent uniqueidentifier, topParentDepth bigint, currAncestor uniqueidentifier, currDescendant uniqueidentifier, currDepth bigint)
	declare @closurePathsBuffer table (closureChecking bigint, topParent uniqueidentifier, topParentDepth bigint, currAncestor uniqueidentifier, currDescendant uniqueidentifier, currDepth bigint)

	insert into @closurePaths (closureChecking, topParent, topParentDepth, currAncestor, currDescendant, currDepth)
		select shc_apc.id, shc_apc.Ancestor, 1, shc_parents.Ancestor, shc_parents.Descendant , shc_parents.Depth
		from @allParentClosures apc 
		inner join SvcNote_Hierarchy_Closure shc_apc
			on apc.id = shc_apc.id
		inner join SvcNote_Hierarchy_Closure shc_parents
			on shc_apc.Ancestor = shc_parents.Ancestor and shc_parents.Depth = 1
		
	/* iterate through closure paths */
	while 
		(select COUNT(*) from @closurePaths) <> 0 /* All paths checked out */
		and
		(select COUNT(*) from @closurePaths cp where cp.currDepth is not null) <> 0 /* All that's left in @closurepaths is dead paths we can delete */ 
	BEGIN
		/* 1: Does our search reveal any closures that match the child-depth requirement on this loop? */
		/*	If so, we no longer have to check for this closure */

		delete from @closurePaths
		where closureChecking in
		(
			select cp.closureChecking 
			from @closurePaths cp
			inner join SvcNote_Hierarchy_Closure shc_iter 
				on shc_iter.Ancestor = cp.currDescendant 
				and shc_iter.Depth = 1
			left outer join SvcNote_Hierarchy_Closure shc_endCheck 
				on shc_endCheck.id = cp.closureChecking 
				and shc_endCheck.Descendant = shc_iter.Descendant
				and shc_endCheck.Depth = cp.topParentDepth + 1 
			where 
				shc_endCheck.id is not null 
				and shc_endCheck.id = cp.closureChecking
		)


		/* Push updated table into buffer */
		delete from @closurePathsBuffer
		insert into @closurePathsBuffer(closureChecking, topParent, topParentDepth, currAncestor, currDescendant, currDepth)
			select cp.closureChecking, cp.topParent, topParentDepth + 1 as newDepth, shc_iter.Ancestor, shc_iter.Descendant, shc_iter.Depth
			from @closurePaths cp
			left outer join SvcNote_Hierarchy_Closure shc_iter 
				on shc_iter.Ancestor = cp.currDescendant 
				and shc_iter.Depth = 1

		delete from @closurePaths
		insert into @closurePaths
		select * from @closurePathsBuffer

	END

	delete from SvcNote_Hierarchy_Closure where id in
	(select closureChecking from @closurePaths)

END
GO