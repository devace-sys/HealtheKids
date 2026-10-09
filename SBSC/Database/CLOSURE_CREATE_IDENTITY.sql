
/* Create generic identity value in closure table */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLOSURE_CREATE_IDENTITY') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLOSURE_CREATE_IDENTITY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.CLOSURE_CREATE_IDENTITY 
(
	@closuretype bigint,
	@fieldtype bigint,	
	@fieldvalue bigint
	
)

/***************************************** 
	Creates a new self-self relationship in closure table
******************************************/

AS
BEGIN

	if @closuretype is not null and @fieldtype is not null and @fieldvalue is not null
	BEGIN
		INSERT INTO Closure_Table_Structure 
		(closure_type, parent_type, parent, child_type, child, depth)
		VALUES (@closuretype, @fieldtype, @fieldvalue, @fieldtype, @fieldvalue, 0)
	END
	else RAISERROR('Cannot use NULL for closure types or values when creating identity.',12,1)
END
GO