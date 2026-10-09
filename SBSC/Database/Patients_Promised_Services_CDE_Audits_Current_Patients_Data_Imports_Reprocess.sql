USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Reprocess') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Reprocess
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Reprocess] (
    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
  , @clientID          bigint
  , @editDelReason     varchar(7000)
  , @validateRec       bit
  , @saveType          int
  , @recID             bigint
  , @msgNoRec          varchar(1000)
  , @msgNoEdit         varchar(1000)
  , @msgDupRec         varchar(1000)
  , @msgDataError      varchar(1000)
  , @msgNotActive      varchar(1000)
  , @recordID          bigint        output
  , @spDetails         varchar(8000) output
  , @jsonData          varchar(max)  output
)

AS
BEGIN

SET NOCOUNT ON
DECLARE @ErrorMessage                               as NVARCHAR(4000) = ''
DECLARE @ErrorSeverity                              as INT
DECLARE @ErrorState                                 as INT
declare @importDataJSON                             as varchar(max) = '{}'

/*############################################################################
 *# Init
 *############################################################################*/

set @spDetails  = ''
set @recordID   = 0
set @jsonData   = '{}'

/*############################################################################
 *# Call core routine
 *############################################################################*/

BEGIN TRY

  exec dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save_Or_Reprocess 
      @userID 
    , @userGroup
    , @userRank 
    , @clientID 
    , @importDataJSON
    , 1 --@reprocessSavedImportData bit 
    , @editDelReason 
    , @validateRec 
    , @saveType  
    , @recID  
    , @msgNoRec 
    , @msgNoEdit
    , @msgDupRec 
    , @msgDataError
    , @msgNotActive
    , @recordID    output
    , @spDetails   output
    , @jsonData    output

  RETURN(0)

END TRY
BEGIN CATCH

  -- Error or raise error with severity 11 to 19 will be caught here

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

GRANT EXECUTE ON  [dbo].Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Reprocess TO [webuser]
GO
