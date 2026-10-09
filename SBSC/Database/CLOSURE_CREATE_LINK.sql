
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/* This replaces stored procedure SVCNOTES_CREATE_CLOSURE_CHILD */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLOSURE_CREATE_LINK') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLOSURE_CREATE_LINK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.CLOSURE_CREATE_LINK 
(
	/* formatted note closure uses different args: */
	@closuretype bigint,
	
	@parentfieldtype bigint,
	@parentfieldvalue bigint,

	@childfieldtype bigint,
	@childfieldvalue bigint

)

/***************************************** 
	Creates a new parent-child relationship in closure table
	derives from http://stackoverflow.com/questions/18622698/closure-table-insert-statement-including-the-level-distance-column
******************************************/

AS
BEGIN
	/* Check to make sure that both the parent and the child values have existing closure identities */
	if 	dbo.CLOSURE_VERIFY_NODE_EXISTS(@closuretype, @parentfieldtype, @parentfieldvalue) = 1
	AND dbo.CLOSURE_VERIFY_NODE_EXISTS(@closuretype,@childfieldtype,@childfieldvalue) = 1
												
	/* Closure tables are for acyclic dirgraphs - make sure we're not creating a cycle for this treetype */
	and dbo.CLOSURE_CHECK_CYCLES(@closuretype, @parentfieldtype, @parentfieldvalue, @childfieldtype, @childfieldvalue) = 1 
	BEGIN
	
		INSERT INTO Closure_Table_Structure
		(
			closure_type,
			parent_type,
			parent,
			child_type,
			child,
			Depth
		)
		select closure_type, parent_type, parent, child_type, child, nuDepth
	    from
	    (
			SELECT closure_type, parent_type, parent, @childfieldtype as child_type, @childfieldvalue as child, Depth + 1 as nuDepth
			FROM Closure_Table_Structure fnc_insert
			WHERE child = @parentfieldvalue and child_type = @parentfieldtype and closure_type = @closuretype
			UNION
			SELECT closure_type, @parentfieldtype, @parentfieldvalue, child_type, child, Depth + 1 as nuDepth
			FROM Closure_Table_Structure fnc_insert
			WHERE parent = @childfieldvalue and parent_type = @childfieldtype and closure_type = @closuretype
		) insertSet
		
		
    END

END
GO