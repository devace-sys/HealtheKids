
/* Basic sproc to create new answers. Called from other stored procedures to produce cloned 'favorites' or multi=use practitioner custom answers */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTES_CREATE_CLOSURE_CHILD') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_CHILD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SVCNOTES_CREATE_CLOSURE_CHILD 
(
	@ancestor UniqueIdentifier,
	@descendant UniqueIdentifier
)

/***************************************** 
	Creates a new parent-child relationship in closure table
	derives from http://stackoverflow.com/questions/18622698/closure-table-insert-statement-including-the-level-distance-column
******************************************/

AS
BEGIN
	if @ancestor is not null AND @descendant is not null 
	and not exists (select 1 from SvcNote_Hierarchy_Closure where Ancestor = @descendant and Descendant = @ancestor) /* Closure tables are for acyclic dirgraphs - make sure we're not creating a loop */
	BEGIN
	
		INSERT INTO SvcNote_Hierarchy_Closure
		(
			Ancestor,
			Descendant,
			Depth
		)
		select Ancestor, Descendant, nuDepth
	    from
	    (
			SELECT Ancestor, @descendant as Descendant, Depth + 1 as nuDepth
			FROM SvcNote_Hierarchy_Closure shc_insert
			WHERE Descendant = @ancestor
		) insertSet
		CROSS APPLY (select COUNT(*) as numExists from SvcNote_Hierarchy_Closure dc where dc.Ancestor = insertSet.Ancestor and dc.Descendant = insertSet.Descendant and dc.Depth = insertSet.nuDepth) countCheck
		
		where numExists = 0
		
		
    END

END
GO