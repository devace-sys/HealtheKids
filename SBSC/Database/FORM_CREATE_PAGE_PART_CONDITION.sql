
/* Create a Condition for a Form  */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_PAGE_PART_CONDITION') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_PAGE_PART_CONDITION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_PAGE_PART_CONDITION (
  @formFormID			bigint,
  @formPageID			bigint,
  @formPagePartID	    bigint,
  @conditionOperator	varchar(50),
  @conditionValue		varchar(max)
)


AS
BEGIN

	/* For a specific form-page-part specify a condition to be evaluated with an operator against that submitted part */
	
	/* TODO - additional integrity checks to make sure form-page-part combination submitted is valid */
	
	/* If a Part is specified, use the Page value of the existing Part record. */
	
	IF @formPagePartID is not null
	BEGIN
		declare @sourcedPageID bigint = (select fpp.formPageID from FORM_PAGES_PARTS fpp where fpp.id = @formPagePartID)	
		set @formPageID = @sourcedPageID
	END

	declare @conditionID bigint
	declare @closuretype bigint = (select ct.id from CLOSURE_TYPES ct inner join FORM_FORM_CLOSURES ffc on ct.id = ffc.closureTypeID and ffc.formID = @formFormID)
	declare @conditionalFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPPCON')
	
	insert into FORM_PAGES_PARTS_CONDITIONS (formID, formPageID, formPagePartID, conditionOperator,conditionValue)
VALUES (@formFormID,@formPageID,@formPagePartID, @conditionOperator, @conditionValue)

set @conditionID = SCOPE_IDENTITY()

exec CLOSURE_CREATE_IDENTITY @closuretype, @conditionalfieldtype, @conditionID

return @CONDITIONID


END
GO