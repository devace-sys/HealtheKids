USE SPEDMON
GO

/*-------------------------------
 * Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_HOURS_FY_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_PRAC_HOURS_FY_SAVE
GO

/*-------------------------------
 * Create
 *------------------------------*/

CREATE PROCEDURE [dbo].[CRCS_PRAC_HOURS_FY_SAVE] (
    @userID                            BIGINT
  , @userGroup                         INT
  , @userRank                          INT

  , @clientID                          BIGINT
  , @pracID                            BIGINT
  , @fiscalYearID                      BIGINT

  , @hoursWorked                       int

  , @recID                             BIGINT

  , @editDelReason         VARCHAR(7000)

  , @saveType              int
  , @validateRec           BIT

  , @MsgNoRec              VARCHAR(1000)
  , @MsgNoEdit             VARCHAR(1000)
  , @MsgDupRec             VARCHAR(1000)
  , @MsgDataError          VARCHAR(1000)
  , @MsgNotActive          VARCHAR(1000)
  , @recordID              BIGINT        OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT )
AS
BEGIN

/***************************************************************************
 * CRCS_PRAC_HOURS_FY_SAVE */
/**
 *
 ***************************************************************************/

SET NOCOUNT ON

/*============================================================
 * Init
 *============================================================*/

set @spDetails = ''
set @recordID  = 0

--declare @saveType int

BEGIN TRY

--  SET @saveType = iif( @recID = 0
--    , dbo.CONST_SAVE_TYPE_EDIT(), dbo.CONST_SAVE_TYPE_NEW())

  IF ( @saveType = dbo.CONST_SAVE_TYPE_EDIT() )
  BEGIN
    SELECT @recordID=id  FROM [dbo].[CRCS_PRAC_HOURS_FY]
         WHERE  clientID = @clientID  AND  fiscalYearID = @fiscalYearID  AND  pracID = @pracID
    IF  ( ISNULL(@recordID, 0) = 0)
    BEGIN
      RAISERROR (@MsgNoRec,  11, 1) 
    END

  END

  set @spDetails = ''

  IF ( @saveType = dbo.CONST_SAVE_TYPE_EDIT() )
  BEGIN

    UPDATE  [dbo].[CRCS_PRAC_HOURS_FY]
       SET
            hoursWorked = @hoursWorked
     WHERE  id = @recordID

  END

  ELSE
  BEGIN

    INSERT INTO
    [dbo].[CRCS_PRAC_HOURS_FY]
    
    SELECT
    @clientID, @fiscalYearID, @pracID , @hoursWorked 

    set @recordID = SCOPE_IDENTITY()

  END


  /*============================================================
   * All done
   *============================================================*/


RETURN(0)
END TRY

/*============================================================
 * Exception handling
 *============================================================*/

BEGIN CATCH

  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  -- Error or raise error with severity 11 to 19 will be caught here


  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

  -- Only send really bad exceptions back with sp details

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

GRANT EXECUTE ON  [dbo].[CRCS_PRAC_HOURS_FY_SAVE] TO [webuser]
GO
