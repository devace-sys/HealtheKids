
/* Create Page of a Form */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_NOTEBOX_PART') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_NOTEBOX_PART
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_NOTEBOX_PART (
	@displayOrder		int,
	@formID				bigint,
	@formPageID			bigint,
	@partTitle			varchar(max),
	@partInstructions	varchar(max),
	@label				varchar(max),
	@placeholder		varchar(max),
	@defaultValue		varchar(max),
	@required			bit,
	@minimumCharacters	varchar(max),
	@maximumCharacters	varchar(max)
)

AS
BEGIN
	declare @partID bigint
	BEGIN TRY
	exec @partID = FORM_CREATE_FLAT_PART @displayOrder, @formID, @formPageID, 2, @partTitle, @partInstructions, @label, @placeholder, @defaultValue, @required, @minimumCharacters, @maximumCharacters, NULL, 1
	END TRY
	
		BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
	
	return @partID
END
GO