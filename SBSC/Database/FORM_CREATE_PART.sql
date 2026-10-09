
/* Create Page of a Form */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_PART') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_PART
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_PART (
	@displayOrder		int,
	@formID				bigint,
	@formPageID			bigint,
	@formPagePartType	bigint,
	@partTitle			varchar(max),
	@partInstructions	varchar(max),
	@label				varchar(max),
	@placeholder		varchar(max),
	@value				varchar(max),
	@required			bit,
	@multiple			bit,
	@min				varchar(max),
	@max				varchar(max),
	@step				varchar(max),
	@selectFrom			varchar(max),
	@selectWhat			varchar(max),
	@selectAuto			bit,
	@selectReqEntID1	bigint,
	@selectReqEntID2	bigint,
	@selectSourceURL	varchar(max),
	@active				bit
)

AS
BEGIN
	declare @partID bigint
	
	BEGIN TRY

	insert into FORM_PAGES_PARTS (displayOrder, formID, formPageID, formPagePartType, partTitle, partInstructions, label, placeholder, value, required, multiple, min, max, step, selectFrom, selectWhat, selectAuto, selectReqEntId1, selectReqEntId2, selectSourceURL, active)
		VALUES (@displayOrder, @formID, @formPageID, @formPagePartType, @partTitle, @partInstructions, @label, @placeholder, @value, @required, @multiple, @min, @max, @step, @selectFrom, @selectWhat, @selectAuto, @selectReqEntID1, @selectReqEntID2, @selectSourceURL, @active)
	set @partID = SCOPE_IDENTITY()
	
	END TRY
	
	BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE() + ' *** Part Label: ' +@label,
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