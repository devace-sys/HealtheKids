USE SPEDMON
GO

/* This sproc must be called within a transaction block */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Structured_Data_Imports_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Structured_Data_Imports_Save_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[Structured_Data_Imports_Save_Core] (
    @userID            BIGINT
 ,  @userGroup         INT
 ,  @userRank          INT      
 ,  @clientID          bigint
 ,  @importDataJSON    varchar(max)
 ,  @skipDupCheck      bit = 0
 ,  @editDelReason     varchar(7000)   
 ,  @validateRec       bit
 ,  @saveType          int  
 ,  @recID                        bigint   
 ,  @MsgNoRec                     varchar(1000)   
 ,  @MsgNoEdit                    varchar(1000)
 ,  @MsgDupRec                    varchar(1000)    
 ,  @MsgDataError                 varchar(1000)
 ,  @MsgNotActive                 varchar(1000)    
 ,  @spDetails         VARCHAR(8000) OUTPUT    
 ,  @recordID          BIGINT        OUTPUT
)    
AS    
BEGIN     
    
SET NOCOUNT ON    

BEGIN TRY    

/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    

declare @today as datetime
set @spDetails  = ''    
set @recordID = 0 
set @today    = GETDATE()
    
   
/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    

if (@userID         is null) RAISERROR ('userID is required',   11, 1)      
if (@userGroup      is null) RAISERROR ('userGroup is required',   11, 1)    
if (@userRank       is null) RAISERROR ('userRank is required',    11, 1)    
if (@validateRec    is null) RAISERROR ('Validate flag required',  11, 1)    
if (@saveType       is null) RAISERROR ('Save type is required',   11, 1)
if (@clientID       is null) RAISERROR ('Client ID is required',   11, 1)
if (@importDataJSON is null) RAISERROR ('Import data JSON is required',   11, 1)
 
declare @fileProfileID   as varchar(256)
declare @fileProfileName as varchar(256)
declare @fileClass       as varchar(256)
declare @fileSubClass    as varchar(256)
declare @fileName        as varchar(256)
declare @fileSize        as bigint
declare @fileMimeType    as varchar(256)

/*-------------------------------    
 * Extract file profile data
 *------------------------------*/    

select top 1
    @fileProfileID      = t1.[id]
  , @fileProfileName    = t1.[name]
  , @fileClass          = t1.[fileClass]
  , @fileSubClass       = t1.[fileSubClass]  
from openjson ( @importDataJSON, '$."fileProfile"' ) 
with (
     [id]            varchar(256) '$.id'
   , [name]          varchar(256) '$.name'
   , [fileClass]     varchar(256) '$.fileClass'  
   , [fileSubClass]  varchar(256) '$.fileSubClass'
) as t1

/*-------------------------------    
 * Extract file info
 *------------------------------*/    

select top 1
    @fileName     = t1.[fileName]
  , @fileSize     = t1.size
  , @fileMimeType = t1.mimeType
from openjson ( @importDataJSON, '$."fileInfo"' ) 
with (
    [fileName] varchar(256) '$.name'
  , [mimeType] varchar(256) '$.mimeType'  
  , [size]     bigint       '$.size'
) as t1


/*-------------------------------    
 * Check for duplicate
 *------------------------------*/ 

if (@skipDupCheck = 0)
begin

  set @recordID = null
    
  select top 1 
    @recordID = sdi.id
  from dbo.Structured_Data_Imports as sdi
  where (
        (sdi.clientID = @clientID)
    and (sdi.fileName = @fileName)
    and (sdi.fileSize = @fileSize)
  )

  /*-------------------------------    
   * If duplicate exists, exit
   *------------------------------*/ 

  if (@recordID is not null)
  begin
    RAISERROR ('A file with this same name and size has been imported or is in the process of being imported already', 11, 1)      
  end
end


set @recordID = 0

/*-------------------------------    
 * If in validation mode, exit
 *------------------------------*/ 

if (@validateRec = 1)
begin
  return(0)
end

/*-------------------------------    
 * Save imported data    
 *------------------------------*/    

INSERT INTO dbo.Structured_Data_Imports (
    clientID
  , fileProfileID
  , fileProfileName
  , fileClass
  , fileSubClass
  , [fileName]
  , fileSize
  , fileMimeType
  , importDataJSON
  , created
  , createdBy
  , active
) 
values (
    @clientID
  , @fileProfileID
  , @fileProfileName
  , @fileClass
  , @fileSubClass
  , @fileName
  , @fileSize
  , @fileMimeType
  , @importDataJSON
  , @today
  , @userID
  , 1
)

set @recordID = SCOPE_IDENTITY()

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
      
      
  DECLARE @ErrorMessage  AS  NVARCHAR(4000)    
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




