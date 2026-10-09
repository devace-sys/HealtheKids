USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE] ( 
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @clientID              BIGINT
  , @patID                 BIGINT
  , @fileName              VARCHAR(256)
  , @profilePictureBase64  VARCHAR(MAX)
  
  , @recordID              BIGINT        OUTPUT
  , @spDetails             VARCHAR(8000) OUTPUT
  , @saveType              INT           OUTPUT
)    
AS    
BEGIN     
    
/***************************************************************************    
 * PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE */    
/**    
 * Creates a new or edits existing patient profile picture record.    
 * Compresses image data using SQL Server COMPRESS function
 *    
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
DECLARE @today              AS DATETIME       -- Current date/time stamp    
DECLARE @tranOpen           AS BIT            -- Is a transaction open    
DECLARE @compressedImgData  AS VARBINARY(MAX) -- Compressed image data
DECLARE @originalSize       AS INT            -- Original size in bytes
DECLARE @compressedSize     AS INT            -- Compressed size in bytes
    
BEGIN TRY    
    
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    

set @saveType   = 1    
set @recordID   = 0    
set @spDetails  = ''    
set @today      = GETDATE()    
set @tranOpen   = 0    

/*-------------------------------    
 * Make sure patient exists
 *------------------------------*/    
    
IF NOT EXISTS ( 
   SELECT top 1 
           pp.PATIENT_ID
   FROM PATIENTS_Client  as pc
   JOIN PATIENTS_Patient as pp ON pp.PATIENT_ID = pc.PATIENT_ID 
   WHERE (
         (pc.CLIENT_ID = @clientID)  
     and (pc.PATIENT_ID = @patID)
	 and (pp.PATIENT_ID = @patID)
   )
)
begin    
  RAISERROR('Requires valid patient and client', 11, 1)
end    
    
/*-------------------------------    
 * Make sure filename is passed
 *------------------------------*/    
     
SET @fileName = trim(isnull(@fileName, ''))
IF (@fileName = '') RAISERROR ('FileName cannot be empty', 11, 1)

/*-------------------------------    
 * Make sure image is passed
 *------------------------------*/    

SET @profilePictureBase64 = trim(ISNULL(@profilePictureBase64, ''))
IF (@profilePictureBase64 = '') RAISERROR ('ProfilePictureBase64 cannot be empty', 11, 1)

/*-------------------------------    
 * Determine save type
 *------------------------------*/    

set @recordID = -1

select top 1 
  @recordID = isnull(t1.id,-1)
from dbo.PATIENT_PROFILE_PICTURES as t1
where (   
        (t1.clientID = @clientID)
    and (t1.patID    = @patID)
    and (t1.active   = 1)
)

if (@recordID = -1) 
begin
  set @saveType = 1
  set @recordID = 0
end
else 
begin
  set @saveType = 2
end

/*-------------------------------    
 * Convert base64 to binary and 
 * compress using COMPRESS
 *------------------------------*/    

set @compressedImgData = compress   (@profilePictureBase64)
set @originalSize      = DATALENGTH (@profilePictureBase64)
set @compressedSize    = DATALENGTH (@compressedImgData)

/*-------------------------------    
 * Begin transaction    
 *------------------------------*/    
    
SET @tranOpen = 1
BEGIN TRANSACTION    
    
if (@saveType = 1)    
begin    
  
  INSERT INTO dbo.PATIENT_PROFILE_PICTURES ( 
      clientID     
    , patID     
    , [fileName]     
    , profilePictureImgData     
    , originalSize
    , compressedSize
    , created     
    , createdBy     
    , active
  )        
  VALUES ( 
      @clientID     
    , @patID     
    , @fileName     
    , @compressedImgData     
    , @originalSize
    , @compressedSize
    , @today     
    , @userID     
    , 1
  )  

  SET @recordID = SCOPE_IDENTITY()       
        
end       
else 
begin    
              
  UPDATE PATIENT_PROFILE_PICTURES
  SET 
      [fileName]             = @fileName
    , profilePictureImgData  = @compressedImgData
    , originalSize           = @originalSize
    , compressedSize         = @compressedSize
    , lastModified           = @today
    , lastModifiedBy         = @userID
  WHERE (id = @recordID)
end                          
    
COMMIT TRANSACTION
SET @tranOpen = 0    

END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error messages to the caller    
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

GRANT EXECUTE ON [dbo].[PATIENT_PROFILE_PICTURES_SAVE_OR_REPLACE] TO [webuser]
GO