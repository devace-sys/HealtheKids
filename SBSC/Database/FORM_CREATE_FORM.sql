
/* Create Page of a Form */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_FORM') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_FORM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_FORM 
(
	@formTitle varchar(100),
	@formInstructions varchar(max),
	/* /* appended after form and pages are created */
	--@startFormPageID bigint, 
	--@endformPageID bigint, */
	@fileUploadFromSource bigint,
	@openInNewWindow bit,
	@deactivateIncompleteForms bit,
	@active bit
)


AS
BEGIN

	/* TODO: Precheck fileUploadFromSource arg */
	/* If NULL, default it to 0 */
	/* If not null, check it against existing entries in [FILE_UPLOAD_FROM_SOURCES] and throw an error if no match */

	/* 1: Create raw form entry */
	insert into FORM_FORM (formTitle, formInstructions, startFormPageID, endFormPageID, fileUploadFromSource, openInNewWindow, deactivateIncompleteForms, active)
					VALUES(@formTitle, @formInstructions, 0,				0,			@fileUploadFromSource, @openInNewWindow, @deactivateIncompleteForms, @active)
					
	declare @formID bigint = SCOPE_IDENTITY()
	
	
	/* 2: ID closure type for datadriven forms */
				
	declare @closureTypeID bigint = (select id from CLOSURE_TYPES where name = 'DataDrivenWebForm')
	
	/* 3: Setup link in [FORM_FORM_CLOSURES] to link form to closure type */
	
	insert into FORM_FORM_CLOSURES (formID, closureTypeID)
		VALUES(@formID, @closureTypeID)
		
		
	RETURN @formID

END
GO