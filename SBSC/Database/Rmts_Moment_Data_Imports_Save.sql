USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Moment_Data_Imports_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Rmts_Moment_Data_Imports_Save
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Rmts_Moment_Data_Imports_Save] (
    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
  , @clientID          bigint
  , @fyQuarterID       bigint
  , @importDataJSON    varchar(max)
  , @editDelReason     varchar(7000)
  , @validateRec       bit
  , @saveType          int
  , @recID             bigint
  , @MsgNoRec          Varchar(1000)
  , @MsgNoEdit         Varchar(1000)
  , @MsgDupRec         Varchar(1000)
  , @MsgDataError      Varchar(1000)
  , @MsgNotActive      Varchar(1000)
  , @spDetails         VARCHAR(8000) OUTPUT
  , @recordID          BIGINT        OUTPUT
  , @jsonData          varchar(max) output
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

declare @tranOpen as bit = 0

/*############################################################################
 *# Init
 *############################################################################*/

set @tranOpen = 0
set @spDetails  = ''
set @recordID = 0
set @jsonData = '{}'

/*############################################################################
 *# Save structured data import data
 *#
 *# Note: We save the import data in a seperate transaction block so we can
 *#
 *# 1. Show the file in the management screen and its status ASAP.
 *# 2. Process the import data in a seperate process 
 *############################################################################*/

/*-------------------------------    
 * If in validation mode, exit
 *------------------------------*/ 

if (@validateRec = 1)
begin
  return(0)
end

BEGIN TRANSACTION
set @tranOpen = 1

declare @structuredDataImportID as bigint

exec dbo.Structured_Data_Imports_Save_Core
    @userID
 ,  @userGroup
 ,  @userRank
 ,  @clientID
 ,  @importDataJSON
 , 0 /*@skipDupCheck*/
 ,  @editDelReason
 ,  @validateRec
 ,  @saveType
 ,  @recID
 ,  @MsgNoRec
 ,  @MsgNoEdit
 ,  @MsgDupRec
 ,  @MsgDataError
 ,  @MsgNotActive
 ,  @spDetails				OUTPUT
 ,  @structuredDataImportID OUTPUT

if (isnull(@structuredDataImportID, 0) = 0) RAISERROR('Something went wrong when saving the file', 11, 1)

COMMIT TRANSACTION
set @tranOpen = 0

/*############################################################################
 *# Save and parse import file
 *#
 *# Note: We use a seperate transaction block so we can
 *#
 *# 1. Show the file in the management screen and its status ASAP.
 *# 2. Process the import data in a seperate process 
 *############################################################################*/

BEGIN TRANSACTION
set @tranOpen = 1

declare @rmtsMomentDataImportID bigint

exec dbo.Rmts_Moment_Data_Imports_Save_Core
     @userID
   , @userGroup
   , @userRank
   , @clientID                
   , @fyQuarterID 
   , @structuredDataImportID 
   , @spDetails				   OUTPUT
   , @rmtsMomentDataImportID   OUTPUT

set @recordID = @rmtsMomentDataImportID

COMMIT TRANSACTION
set @tranOpen = 0

RETURN(0)
END TRY
BEGIN CATCH

  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end

  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

   if (@ErrorSeverity > 11)
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Rmts_Moment_Data_Imports_Save] TO [webuser]
GO
