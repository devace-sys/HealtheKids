USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW_CORE] (
     @userID            BIGINT   
   , @userGroup         INT  
   , @userRank          INT
   , @environmentID     BIGINT
   , @uploadID          BIGINT 
   , @processFile       BIT
   , @reviewFile        BIT
   , @active            BIT
)
RETURNS 

@recs table (
   id bigint
 , fileUploadedFromID bigint
 , fileUploadedFromName varchar(8000)
 , fileClassID bigint
 , fileClassName varchar(1000)
 , fileSubClass varchar(1000)
 , fileUploadedOn datetime
 , fileEffectiveUploadedOn date
 , referenceDate1 varchar(1000)
 , currentStatusID bigint
 , currentStatusName varchar(8000)
 , originalName varchar(8000)
 , savedName varchar(8000)
 , fileAsName nvarchar(max)
 , filedName varchar(8000)
 , receiveOriginalRoot varchar(4000)
 , receiveOriginalPath varchar(4000)
 , receiveOriginalRootPath varchar(8000)
 , storeFiledRoot varchar(4000)
 , storeFiledPath varchar(4000)
 , storeFiledRootPath varchar(8000)
 , archiveFiledRoot varchar(4000)
 , archiveFiledPath varchar(4000)
 , archiveFiledRootPath varchar(8000)
 , archiveOriginalRoot varchar(4000)
 , archiveOriginalPath varchar(4000)
 , archiveOriginalRootPath varchar(8000)
 , reviewFiledRoot varchar(4000)
 , reviewFiledPath varchar(4000)
 , reviewFiledRootPath varchar(8000)
 , deactivateOrReplaceRoot varchar(4000)
 , deactivateOrReplacePath varchar(4000)
 , deactivateOrReplaceRootPath varchar(8000)
 , fileUploaderContactEmail varchar(4000)
 , notifyStaffEmails varchar(max)
 , fileSize bigint
 , fileSizeHuman varchar(100)
 , fileMimeType varchar(8000)
 , fileAsMimeType varchar(8000)
 , possibleDuplicateFiles varchar(max)
 , processFile bit
 , reviewFile bit
 , postProcessFile bit
 , readyForUse bit
 , lastUpdatedOn datetime
 , active bit
 , clientID bigint
 , clientName nvarchar(max)
 , generalStatus varchar(max)
 , fileAsOrFiledName varchar(8000)
 , receiveOriginalRootPathFilename varchar(8000)
 , archiveOriginalRootPathFilename varchar(8000)
 , storeFiledRootPathFilename varchar(8000)
 , archiveFiledRootPathFilename varchar(8000)
 , reviewFiledRootPathFilename varchar(8000)
 , deactivateOrReplaceRootPathFilenameSavedName varchar(8000)
 , deactivateOrReplaceRootPathFilenameFileAsOrFiledName varchar(8000)
 , currentWorkingCopyRootPathFileName varchar(8000)
 , fileIsGenerated    bit
 , processingPriority int
 UNIQUE CLUSTERED (id)
)
AS
BEGIN

/***************************************************************************
 * FILE_UPLOAD_VIEW_CORE */
/**
 * Returns file upload data
 *
 * @return Table
 ***************************************************************************/ 

if (@uploadID is not null)
begin
  insert into @recs
  select top 1 
    fudrc1.* 
  from dbo.FILE_UPLOAD_DATA_RECORD_CORE (
     @userID 
   , @userGroup
   , @userRank 
   , @environmentID 
   , @uploadID
   , 0
   , 0
  ) as fudrc1
  return
end

else if (@processFile = 1)
begin
  insert into @recs
  select fupv.* from dbo.FILE_UPLOADS_PROCESSING_VIEW (@userID, @userGroup, @userRank, @environmentID) as fupv   
  return
end

else if (@reviewFile = 1)
begin

  insert into @recs
  select 
    fudrc2.*
  from dbo.FILE_UPLOADS as fu

  cross apply (
    select top 1 
      fudrc1.* 
    from dbo.FILE_UPLOAD_DATA_RECORD_CORE (@userID , @userGroup, @userRank , @environmentID , fu.id, 0, 0) as fudrc1  
) as fudrc2

where ((fu.reviewFile = 1) and (fu.active = 1))
end
else
begin

  insert into @recs
  select 
      fudrc2.*
    from dbo.FILE_UPLOADS as fu

    cross apply (
      select top 1 
        fudrc1.* 
      from dbo.FILE_UPLOAD_DATA_RECORD_CORE (@userID , @userGroup, @userRank , @environmentID , fu.id, 0, 0) as fudrc1  
  ) as fudrc2

  where ((fu.active = @active))
  return
end

return
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW_CORE] TO [webuser]
GO