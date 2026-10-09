
/* Create Page of a Form */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_PAGE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_PAGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_PAGE (
  @formFormID			bigint,
  @formPageType			bigint,
  @pageDisplayOrder	bigint,
  @pageTitle			varchar(100),
  @pageInstructions		varchar(8000)
)


AS
BEGIN
	declare @closuretype   bigint = (select ct.id from CLOSURE_TYPES ct inner join FORM_FORM_CLOSURES ffc on ct.id = ffc.closureTypeID and ffc.formID = @formFormID)
	declare @pageFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPID')

	declare @pageID        bigint

	insert into FORM_PAGES (formID,formPageType, displayOrder, pageTitle,pageInstructions,active) 
	values (@formFormID,@formPageType, @pageDisplayOrder,@pageTitle,@pageInstructions,1)
	
	set @pageID = SCOPE_IDENTITY()
	
	exec CLOSURE_CREATE_IDENTITY @closuretype, @pagefieldtype, @pageID
	
	return @pageID

END
GO