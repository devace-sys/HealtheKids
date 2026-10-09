USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_PARTICIPANTS_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[RMTS_PARTICIPANTS_SAVE] (
    @userID                       Bigint
  , @userGroup                    Int
  , @userRank                     Int 
  , @clientID                     Bigint 
  , @pracID                       Bigint
  , @rosterID					  Bigint
  , @startDate					  DateTime
  ,	@endDate					  DateTime
  , @reasonForStartDateChangeCode bigint
  , @reasonForEndDateChangeCode   bigint
  , @hasServiceRecords			  bit
  , @hasReimbursement             bit
  , @employeeRelationshipID       bigint -- if null, nothing will happen. value is only used if passed
  , @editDelReason                Varchar(7000)    
  , @validateRec                  Bit     -- this parameter is actually used so, see references to it in this file before using this SPROC
  , @saveType                     Int    
  , @recID                        Int    
  , @MsgNoRec                     Varchar(1000)    
  , @MsgNoEdit                    Varchar(1000) 
  , @MsgDupRec                    Varchar(1000)     
  , @MsgDataError                 Varchar(1000)
  , @MsgNotActive                 Varchar(1000)     
  , @spDetails                    Varchar(8000) OUTPUT   
  , @recordID                     BigInt        OUTPUT)    
AS    
BEGIN            
 
SET NOCOUNT ON    
 
DECLARE @TranOpen AS BIT = 0

/*-------------------------------    
 * Init
 *------------------------------*/    
 
SET @spDetails  = ''    
SET @recordID   = 0 
set @TranOpen = 0

BEGIN TRY    

 
BEGIN TRANSACTION    
SET @TranOpen = 1     

exec [dbo].[RMTS_PARTICIPANTS_SAVE_CORE]
    @userID  
  , @userGroup
  , @userRank 
  , @clientID 
  , @pracID   
  , @rosterID
  , @startDate
  ,	@endDate	
  , @reasonForStartDateChangeCode 
  , @reasonForEndDateChangeCode   
  , @hasServiceRecords			  
  , @hasReimbursement 
  , @employeeRelationshipID       
  , @editDelReason  
  , @validateRec     
  , @saveType
  , @recID  
  , @MsgNoRec 
  , @MsgNoEdit 
  , @MsgDupRec 
  , @MsgDataError 
  , @MsgNotActive    
  , @spDetails  OUTPUT   
  , @recordID  OUTPUT    
  
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
COMMIT TRANSACTION    
SET @TranOpen = 0    
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
 
GRANT EXECUTE ON  [dbo].[RMTS_PARTICIPANTS_SAVE] TO [webuser]
GO