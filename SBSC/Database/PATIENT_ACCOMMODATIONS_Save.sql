USE SPEDMON
GO
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ACCOMMODATIONS_Save') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_ACCOMMODATIONS_Save
GO
 
CREATE PROCEDURE dbo.PATIENT_ACCOMMODATIONS_Save (
    @userID                 BIGINT
  , @userGroup              INT
  , @userRank               INT
  , @patID                  bigint
  , @recordType             int
  , @category               int
  , @categoryName           VARCHAR(256)
  , @accommodation          VARCHAR(512)
  , @accomDetails           VARCHAR(MAX)
  , @appliesTo              VARCHAR(MAX)
  , @appliesToNames         VARCHAR(MAX)
  , @startDate              date
  , @endDate                date
  , @frequency              int
  , @frequencyName          VARCHAR(256)
  , @duration               VARCHAR(512)
  , @location               int
  , @locationName           VARCHAR(256)
  , @locationOther          VARCHAR(512)
  , @linkedAreaOfNeed       VARCHAR(MAX)
  , @linkedAreaOfNeedNames  VARCHAR(MAX)
  , @alignedGoal            VARCHAR(MAX)
  , @alignedGoalNames       VARCHAR(MAX)
  , @staffResponsible       VARCHAR(MAX)
  , @staffResponsibleNames  VARCHAR(MAX)
  , @accomStatus            int
  , @discontinueReason      VARCHAR(7000)
  , @editDelReason       VARCHAR(7000)
  , @validateRec         BIT    
  , @recID               BIGINT
  , @MsgNoRec            VARCHAR(1000)   
  , @MsgDupRec           VARCHAR(1000)
  , @MsgNoEdit           VARCHAR(1000)
  , @MsgNotActive        VARCHAR(1000)
  , @MsgDataError        VARCHAR(1000)
  , @saveType            smallint
  , @spDetails           VARCHAR(8000) OUTPUT    
  , @recordID            BIGINT        OUTPUT)   
AS    
BEGIN    
     
SET NOCOUNT ON    
   
DECLARE @tranOpen AS BIT = 0 
BEGIN TRY    
   
/*-------------------------------    
 * Init 
 *------------------------------*/    
   
SET @recordID  = 0    
SET @spDetails = '' 
set @tranOpen  = 0
begin transaction
set @tranOpen = 1
  exec dbo.PATIENT_ACCOMMODATIONS_Save_Core 
      @userID
    , @userGroup 
    , @userRank 
    , @patID 
    , @recordType 
    , @category 
    , @categoryName
    , @accommodation 
    , @accomDetails 
    , @appliesTo 
    , @appliesToNames 
    , @startDate 
    , @endDate 
    , @frequency 
    , @frequencyName 
    , @duration 
    , @location 
    , @locationName 
    , @locationOther 
    , @linkedAreaOfNeed 
    , @linkedAreaOfNeedNames 
    , @alignedGoal 
    , @alignedGoalNames 
    , @staffResponsible 
    , @staffResponsibleNames 
    , @accomStatus 
    , @discontinueReason 
    , @editDelReason  
    , @validateRec 
    , @recID  
    , @MsgNoRec 
    , @MsgDupRec
    , @MsgNoEdit
    , @MsgNotActive 
    , @MsgDataError 
    , @saveType 
    , @spDetails OUTPUT    
    , @recordID  OUTPUT
       
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
   
commit transaction   
set @tranOpen = 0    
return(0)
    
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
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ''    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
   
END CATCH    
END      
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  dbo.PATIENT_ACCOMMODATIONS_Save TO webuser
GO