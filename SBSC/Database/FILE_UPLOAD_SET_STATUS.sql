USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_SET_STATUS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_SET_STATUS
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_SET_STATUS ( 
    @uploadID      bigint
  , @createdOn     datetime
  , @createdBy     bigint
  , @statusCode    bigint
  , @source        varchar(8000)
  , @destination   varchar(8000)
  , @note          varchar(8000)
  , @recordID      bigint  output
)
AS
BEGIN

/***************************************************************************    
 * FILE_UPLOAD_SET_STATUS */    
/**    
 * Creates file upload status record
 *
 ***************************************************************************/     

declare @id as bigint = null

/*###########################################################################
  # Exit if required values are not provided
  ###########################################################################*/  

if (@uploadID   is null) return(1)
if (@statusCode is null) return(1)

/*###########################################################################
  # Exit if parent upload record does not exist
  ###########################################################################*/  

set @id = null
select top 1 @id = fu.id from dbo.FILE_UPLOADS as fu where (id = @uploadID)
if (@id is null) return (1)

/*###########################################################################
  # Exit if status code does not exist
  ###########################################################################*/  

set @id = null
select top 1 @id = fusl.id from dbo.FILE_UPLOAD_STATUS_CODES as fusl where (id = @statusCode)
if (@id is null) return (1)


/*###########################################################################
  # Set optional values to their defaults
  ###########################################################################*/  
 
if (@createdOn   is null) set @createdOn   = GETDATE()
if (@createdBy   is null) set @createdBy   = 0
if (@source      is null) set @source      = ''
if (@destination is null) set @destination = ''
if (@note        is null) set @note        = ''

/*###########################################################################
  # Save status 
  ###########################################################################*/  

set @recordID = null

insert into dbo.FILE_UPLOAD_STATUS_LOG (
     uploadId
   , createdOn
   , createdBy
   , statusCode
   , [source]
   , destination
   , note ) 

values (
    @uploadID
  , @createdOn
  , @createdBy
  , @statusCode
  , @source
  , @destination
  , @note )

set @recordID = SCOPE_IDENTITY()   

/*###########################################################################
  # Update parent with current status
  ###########################################################################*/  

update dbo.FILE_UPLOADS set 
    currentStatusCode  = @statusCode
  , currentStatusLogID = @recordID
  , lastUpdatedOn      = @createdOn
  , lastUpdatedBy      = @createdBy 
where (id = @uploadID)


/*###########################################################################
  # Update state
  ###########################################################################*/  

-- New file uploaded

if (@statusCode = 100)
begin
  update dbo.FILE_UPLOADS set
     active          = 1
   , processFile     = 0
   , reviewFile      = 0
   , fileReadyForUse = 0
   , postProcessFile = 0
   , fileIsMissing   = 0
   , fileReplaced    = 0 
   , fileDeleted     = 0
   , fileDeactivated = 0
   , fileCancelled   = 0
   , fileAccepted    = 1
   , fileInfected    = 0
   , fileCorrupt     = 0 
  where (id = @uploadID)
  return (0) 
end

-- New file upload form canceled or reset 

else if (@statusCode = 110)
begin
  update dbo.FILE_UPLOADS set
      active          = 0
    , processFile     = 0
    , reviewFile      = 0
    , fileReadyForUse = 0
    , postProcessFile = 0
    , fileIsMissing   = 0
    , fileReplaced    = 0 
    , fileDeleted     = 0
    , fileDeactivated = 0
    , fileCancelled   = 1
    , fileAccepted    = 0
    , fileInfected    = 0
    , fileCorrupt     = 0
  where (id = @uploadID)
  return (0) 
end

-- New file upload ready for processing

else if (@statusCode = 120)
begin
  update dbo.FILE_UPLOADS set
      active          = 1
    , processFile     = 1
    , reviewFile      = 0
    , fileReadyForUse = 0
    , postProcessFile = 1
    , fileIsMissing   = 0
    , fileReplaced    = 0 
    , fileDeleted     = 0
    , fileDeactivated = 0
    , fileCancelled   = 0
    , fileAccepted    = 1
    , fileInfected    = 0
    , fileCorrupt     = 0
  where (id = @uploadID)
  return (0) 
end

-- Existing upload replaced and ready for reprocessing

else if (@statusCode = 130)
begin
  update dbo.FILE_UPLOADS set
      active          = 1
    , processFile     = 1
    , reviewFile      = 0
    , fileReadyForUse = 0
    , postProcessFile = 1
    , fileIsMissing   = 0
    , fileReplaced    = 1 
    , fileDeleted     = 0
    , fileDeactivated = 0
    , fileCancelled   = 0
    , fileAccepted    = 1
    , fileInfected    = 0
    , fileCorrupt     = 0
  where (id = @uploadID)
  return (0) 
end

-- File missing

else if (@statusCode = 510)
begin 
  update dbo.FILE_UPLOADS set fileIsMissing = 1 where (id = @uploadID)
  return (0) 
end

-- File missing

else if (@statusCode = 210) 
begin
  update dbo.FILE_UPLOADS set fileIsMissing = 1 where (id = @uploadID)
  return (0) 
end

-- File found

else if (@statusCode = 220) 
begin
  update dbo.FILE_UPLOADS set fileIsMissing = 0 where (id = @uploadID)
  return (0) 
end

-- File infected

else if (@statusCode = 310) 
begin
  update dbo.FILE_UPLOADS set fileInfected = 1, fileAccepted = 0 where (id = @uploadID)
  return (0) 
end

-- File clean

else if (@statusCode = 320) 
begin
  update dbo.FILE_UPLOADS set fileInfected = 0 where (id = @uploadID)
  return (0) 
end

-- File corrupted

else if (@statusCode = 410) 
begin
  update dbo.FILE_UPLOADS set fileCorrupt = 1, fileAccepted = 0 where (id = @uploadID)
  return (0) 
end

-- File intact

else if (@statusCode = 420) 
begin
  update dbo.FILE_UPLOADS set fileCorrupt = 0 where (id = @uploadID)
  return (0) 
end

-- File rejected

else if (@statusCode = 510) 
begin
  update dbo.FILE_UPLOADS set fileAccepted = 0 where (id = @uploadID)
  return (0) 
end

-- File accepted

else if (@statusCode = 520) 
begin
  update dbo.FILE_UPLOADS set fileAccepted  = 1 where (id = @uploadID)
  return (0) 
end

-- File requires review and is not ready for use

else if (@statusCode = 810)      
begin
  update dbo.FILE_UPLOADS set reviewFile = 1, processFile = 0, fileReadyForUse = 0, postProcessFile = 0 where (id = @uploadID)
  return (0) 
end

-- File does not require review and is ready for use 

else if (@statusCode = 820)
begin
  update dbo.FILE_UPLOADS set reviewFile = 0, processFile = 1, fileReadyForUse = 1, postProcessFile = 1 where (id = @uploadID)
  return (0) 
end

-- File record updated

--if (@statusCode = 840)
--update FILE_UPLOADS set postProcessFile = 1 where id = @uploadID

-- File post processed

else if (@statusCode = 850)
begin
  update dbo.FILE_UPLOADS set postProcessFile = 0 where (id = @uploadID)
  return (0) 
end

-- Processing complete

else if (@statusCode = 900) 
begin
  update dbo.FILE_UPLOADS set processFile = 0 where (id = @uploadID)
  return (0) 
end

-- Physically deleted

else if (@statusCode = 1000)
begin
  update dbo.FILE_UPLOADS set active = 0, fileDeleted = 1 where (id = @uploadID)
  return (0) 
end

-- Deactivated 

else if (@statusCode = 1050)
begin
  update dbo.FILE_UPLOADS set active = 0, fileDeactivated = 1 where (id = @uploadID)
  return (0) 
end

-- Marked as confidential after initial upload

else if (@statusCode = 3000)
begin
  update dbo.FILE_UPLOADS set isConfidentialPracticeFile = 1 where (id = @uploadID)
  return (0) 
end

-- Marked as non confidential after initial upload

else if (@statusCode = 3010)
begin
  update dbo.FILE_UPLOADS set isConfidentialPracticeFile = 0 where (id = @uploadID)
  return (0) 
end

-- Marked as shared on with Patient 

else if (@statusCode = 3020)
begin
  update dbo.FILE_UPLOADS set okToShareFileWithPatient = 1 where (id = @uploadID)
  return (0) 
end

-- Marked as shared off with Patient

else if (@statusCode = 3025)
begin
  update dbo.FILE_UPLOADS set okToShareFileWithPatient = 0 where (id = @uploadID)
  return (0) 
end

-- Marked as shared on with Parent/Guardia

else if (@statusCode = 3030)
begin
  update dbo.FILE_UPLOADS set okToShareFileWithParentGuardian = 1 where (id = @uploadID)
  return (0) 
end

-- Marked as shared off with Parent/Guardia
else if (@statusCode = 3035)
begin
  update dbo.FILE_UPLOADS set okToShareFileWithParentGuardian = 0 where (id = @uploadID)
  return (0) 
end

-- Done

else
begin
  return(0)
end


/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_SET_STATUS] TO [webuser]
GO