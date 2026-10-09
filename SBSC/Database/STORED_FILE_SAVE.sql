USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.STORED_FILE_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.STORED_FILE_SAVE (   
    @userID                     bigint
  , @userGroup                  int
  , @userRank                   int  
  , @clientID                   bigint
  , @pracID                     bigint
  , @patID                      bigint  
  , @referencedEntityID         bigint
  , @originalName               varchar(8000)
  , @savedName                  varchar(8000)  
  , @fileClass                  bigint
  , @fileSubClass               varchar(100)
  , @fileDescription            varchar(500)
  , @fileNameSpace              varchar(500)
  , @fileSource                 varchar(500)
  , @fileSize                   bigint
  , @fileMimeType               varchar(8000) 
  , @isConfidentialPracticeFile bit = 0
  , @referenceDate1             varchar(1000) /* Note: Stored as string in file uploads table*/ 
  , @editDelReason              VARCHAR(7000)    
  , @validateRec                BIT
  , @saveType                   INT    
  , @recID                      INT    
  
  , @MsgNoRec                 VARCHAR(1000)    
  , @MsgNoEdit                VARCHAR(1000) 
  , @MsgDupRec                VARCHAR(1000)     
  , @MsgDataError             VARCHAR(1000)
  , @MsgNotActive             VARCHAR(1000)
  
  , @spDetails                VARCHAR(8000) OUTPUT    
  , @recordID                 BIGINT  OUTPUT
)
AS
BEGIN

/***************************************************************************    
 * STORED_FILE_SAVE */    
/**    
 * 
 *
 ***************************************************************************/     

SET NOCOUNT ON  

BEGIN TRY   

declare @today                      as datetime
declare @TranOpen                   as bit  
declare @fileUploadedFromSource     as bigint

/*###########################################################################
  # Init
  ###########################################################################*/  

SET @spDetails  = ''    
SET @recordID = NULL 
SET @today    = GETDATE()
SET @fileUploadedFromSource = 0      
SET @TranOpen = 0

/*###########################################################################
  # Validation
  ###########################################################################*/  

IF (@validateRec = 1) 
BEGIN    
  SET @recordID = 0
  RETURN(0)    
END        

/*###########################################################################
  # Save
  ###########################################################################*/  
    
BEGIN TRANSACTION    
    
  SET @TranOpen = 1     

/*###########################################################################
  # Create new file upload record
  ###########################################################################*/  

  exec dbo.FILE_UPLOAD_SAVE 
  
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @pracID
  , null
  , @patID
  , @originalName
  , @savedName
  , @userID
  , null
  , @fileUploadedFromSource
  , @fileClass
  , @fileSubClass
  , @fileSize
  , @fileMimeType
  , @recordID output

/*###########################################################################
  # Update file upload record with extra fields
  # Note: This is here until we can refactor stored file save to insert into
  # the file table directly.
  ###########################################################################*/  

update dbo.FILE_UPLOADS

set   
    [description]              = @fileDescription
  , fileNameSpace              = @fileNameSpace
  , fileSource                 = @fileSource
  , referencedEntityID         = @referencedEntityID
  , isConfidentialPracticeFile = @isConfidentialPracticeFile
  , ReferenceDate1             = @referenceDate1
where (id = @recordID)

/*###########################################################################
  # Set status -- Form Complete
  ###########################################################################*/  

declare @statusCode as bigint = dbo.CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE()
declare @statusID   as bigint

exec dbo.FILE_UPLOAD_SET_STATUS 
    @recordID
  , @today
  , @userID
  , @statusCode
  , null
  , null
  , null
  , @statusID output
  
/*###########################################################################
  # Done
  ###########################################################################*/       
    
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
                         
GRANT EXECUTE ON  [dbo].[STORED_FILE_SAVE] TO [webuser]

GO