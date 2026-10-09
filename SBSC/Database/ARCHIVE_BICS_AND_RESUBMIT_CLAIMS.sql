USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ARCHIVE_BICS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ARCHIVE_BICS

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ARCHIVE_BICS_AND_RESUBMIT_CLAIMS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ARCHIVE_BICS_AND_RESUBMIT_CLAIMS

IF type_id('[dbo].[ArchiveTheseBics]') IS NOT NULL DROP TYPE [dbo].[ArchiveTheseBics];

GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

create type ArchiveTheseBics AS TABLE
(
    id int identity(1,1) primary key /* creates clustered index */, clientID bigint, patID bigint, oldBIC char(14)
);

GO
/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[ARCHIVE_BICS_AND_RESUBMIT_CLAIMS] (
    @archivedBy          int
  , @toArchive           ArchiveTheseBics READONLY  -- I don't want to call this SPROC from inside a loop... because my typing fingers are lazy
  , @resubmit            bit
)

AS
BEGIN

LINENO 38

BEGIN TRY
BEGIN TRANSACTION

	insert into PATIENT_BIC_ARCHIVE (PATIENT_ID, ARCHIVED_BIC, LAST_MEDS_CURRENT, DATE_ARCHIVED, ARCHIVED_BY)
	SELECT
	  arg.patID,
	  arg.oldBIC,
	  meds.lastMedsCurr,
	  getdate(),
	  @archivedBy
	FROM (
    SELECT patID, oldBIC
    FROM @toArchive
	) arg
	OUTER APPLY
	(select MAX(MEDS_CURRENT) lastMedsCurr FROM PATIENTS_Eligibility WHERE PATIENT_ID = arg.patID ) meds

  declare @relevant_clients as table (
     IDX       bigint identity(1,1)
   , clientID  bigint
  )

  if (@resubmit = 1) begin

  declare @patIDs_relevant_client as BIGINT_TableType
  declare @relevant_client bigint

  declare @minIdx    as int = 1
  declare @maxIdx    as bigint
  SELECT @maxIdx=MAX(IDX) FROM @relevant_clients
  declare @curIdx    as bigint = 1 -- damn loop syntax... I hate it

  INSERT INTO @relevant_clients SELECT distinct clientID FROM @toArchive

  -- sigh!
  while (@curIdx <= @maxIdx)
  begin
    SELECT @relevant_client = clientID FROM @relevant_clients WHERE IDX = @curIdx
    INSERT INTO @patIDs_relevant_client SELECT patID FROM @toArchive arg WHERE arg.clientID = @relevant_client
    exec dbo.CLAIMS_RESUBMIT_FOR_PATIENTS @relevant_client, @patIDs_relevant_client
    if @@TRANCOUNT = 0 begin -- if our SPROC call failed, and rolled back back its transaction
      declare @XXXRRRRRRGAH as varchar(max) = 'Nope.  Could not resubmit claims for client ' + CAST(@relevant_client AS varchar) + ', for some reason.'
      RAISERROR(@XXXRRRRRRGAH, 16, 1)
    end
    DELETE FROM @patIDs_relevant_client
    set @curIdx = @curIdx + 1
  end

  end

COMMIT TRANSACTION

END TRY
BEGIN CATCH
  if @@TRANCOUNT > 0 rollback transaction

  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE() + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE())
  DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
  DECLARE @ErrorState    INT = ERROR_STATE()

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
RETURN (0)
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[ARCHIVE_BICS_AND_RESUBMIT_CLAIMS] TO [webuser]
GO
