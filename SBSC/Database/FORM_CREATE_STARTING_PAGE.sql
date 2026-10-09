
/* Create the Starting Page of a Form */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_STARTING_PAGE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_STARTING_PAGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_STARTING_PAGE (
  @formFormID	      bigint,
  @formPageType      bigint,
  @pageTitle	      varchar(100),
  @pageInstructions  varchar(8000)
)


AS
BEGIN

	declare @formpageid bigint

	EXEC @formpageid = FORM_CREATE_PAGE @formFormID, @formPageType, 1, @pageTitle, @pageInstructions	   
	
	update FORM_FORM set startFormPageID = @formpageid where id = @formFormID
	
	RETURN @FORMPAGEID

END
GO