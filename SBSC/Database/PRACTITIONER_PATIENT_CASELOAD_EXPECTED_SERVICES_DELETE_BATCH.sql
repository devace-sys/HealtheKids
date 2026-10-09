USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH] (
    @userID        BIGINT
  , @userGroup     INT   
  , @userRank      INT
  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @clientID      bigint
  , @pracID        bigint
  , @recIDMulti    varchar(8000)
  , @MsgNoRec      VARCHAR(1000)
  , @MsgNoEdit     VARCHAR(1000)
  , @spDetails     VARCHAR(8000) OUTPUT
  , @recordID      BIGINT        OUTPUT )    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    
   
declare @tranOpen        as bit           = 0
declare @maxIdx          as int           = 0
declare @curIdx          as int           = 0
declare @recID           as bigint        = 0
declare @recordIDOut     as bigint        = 0
declare @spDetailsOut    as varchar(8000) = ''
declare @recIDVals       as table([id] int, [recid] bigint) 

/*-------------------------------    
 * Init 
 *------------------------------*/    
   
set @recordID   = 0    
set @spDetails  = ''    
set @tranOpen   = 0   

BEGIN TRY    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 *------------------------------*/    
   
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',        11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',         11, 1)    
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',       11, 1)    
IF (@clientID    IS NULL) RAISERROR ('Client id is required',        11, 1)    
IF (@pracID      IS NULL) RAISERROR ('Practitioner id is required',  11, 1)    
   
/*-------------------------------    
 * Parse multirec value into
 * individual record ids
 *------------------------------*/

insert into @recIDVals (id,recid)
select t0.[id],t0.[recid] from MULTI_RECORD_ID_PARSE(@recIDMulti,',') as t0

/*-------------------------------    
 * Setup loop
 *------------------------------*/    

select @maxIdx = COUNT(t1.id) from @recIDVals as t1
set @curIdx = 1

/*-------------------------------    
 * If there is nothing to delete
 * get out
 *------------------------------*/    

if (@maxIdx = 0) return 0

/*-------------------------------    
 * If we are just validating    
 * get out
 *------------------------------*/    
     
if (@validateRec = 1) return (0)    
   
/*-------------------------------    
 * Write changes to the data    
 *------------------------------*/    
   
BEGIN TRANSACTION    
   
  set @TranOpen = 1    
  
  while (@curIdx <= @maxIdx)
  begin

	select top 1 
	  @recID = t1.recid
	from @recIDVals as t1 
	where (t1.id = @curIdx)
    
	/* Delete caseload entry for this patient */

	exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_CORE
        @userID 
      , @userGroup
      , @userRank 
      , @editDelReason
      , @validateRec
      , @clientID   
      , @pracID
      , @recID 
      , @MsgNoRec
      , @MsgNoEdit
      , @spDetailsOut OUTPUT
      , @recordIDOut  OUTPUT     

	set @curIdx = @curIdx + 1
  end
  
  set @recordID = @maxIdx

/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
     
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
   
  -- Error or raise error with severity 11 to 19 will be caught here    
   
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
   
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  SET @ErrorMessage = @ErrorMessage
   
  -- Reraise the error so it returns back to the server    
   
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_DELETE_BATCH] TO [webuser]
GO
