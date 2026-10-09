USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_DATA_RECORD_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_DATA_RECORD_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_DATA_RECORD_CORE] (
     @userID            BIGINT   
   , @userGroup         INT  
   , @userRank          INT  
   , @environmentID     BIGINT
   , @uploadID          BIGINT 
   , @checkForDups      BIT
   , @extendedStatus    BIT
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
 * FILE_UPLOAD_DATA_RECORD_CORE */
/**
 * Returns file upload data
 *
 * @return Table
 ***************************************************************************/ 

if (@checkForDups   is null) set @checkForDups   = 0
IF (@extendedStatus is null) set @extendedStatus = 0

;
with

/*###########################################################################
  # File Upload
  ###########################################################################*/ 
  
cte_pass_1
as
(
select top 1
   fu.id                            as id
 , fufs.id                          as fileUploadedFromID
 , fufs.name                        as fileUploadedFromName
 , fc.id                            as fileClassID
 , fc.name                          as fileClassName 
 , fu.fileSubClass                  as fileSubClass
 , fu.fileUploaded                  as fileUploadedOn 
 , fued.effectiveUploadedOnDateTime as fileEffectiveUploadedOn 
 , fu.referenceDate1                as referenceDate1
 , fusc.id                          as currentStatusID
 , fusc.name                        as currentStatusName
 , fu.originalName                  as originalName
 , fu.savedName                     as savedName
 , gfn.fileAsName                   as fileAsName
 , fu.filedName                     as filedName
 , fsd.receiveOriginalRoot
 , fsd.receiveOriginalPath
 , fsd.receiveOriginalRootPath
 , fsd.storeFiledRoot
 , fsd.storeFiledPath
 , fsd.storeFiledRootPath
 , fsd.archiveFiledRoot
 , fsd.archiveFiledPath
 , fsd.archiveFiledRootPath
 , fsd.archiveOriginalRoot
 , fsd.archiveOriginalPath 
 , fsd.archiveOriginalRootPath
 , fsd.reviewFiledRoot
 , fsd.reviewFiledPath
 , fsd.reviewFiledRootPath
 , fsd.deactivateOrReplaceRoot
 , fsd.deactivateOrReplacePath
 , fsd.deactivateOrReplaceRootPath
 , fu.fileUploaderContactEmail  
 , snem.notifyStaffEmails
 , fu.fileSize
 , [fileSizeHuman] = isnull(dbo.CALC_HUMAN_BYTE_SIZE(fu.fileSize,1),'') 
 , fu.fileMimeType
 
 /*--------------------------------------
   * Determine if there is a prefered
   * mime type we want the file to be
   * filed in or the uploaded mime type
   * will do
   *-------------------------------------*/
 
 , coalesce(fc.fileAsMimeType,fu.fileMimeType) as fileAsMimeType
 
 , possibleDuplicateFiles = ''
 , isnull(fu.processFile,0)                    as processFile
 , isnull(fu.reviewFile,0)                     as reviewFile
 , isnull(fu.postProcessFile,0)                as postProcessFile
 , isnull(fu.fileReadyForUse,0)                as readyForUse
 
 , fu.lastUpdatedOn
 , fu.active
 , fu.clientID
 , cc.CLIENT_NAME                              as clientName

 , [generalStatus] = case                       
                   when (fu.fileReadyForUse = 1) then 
                     case 
                       when fu.fileClass = 1 then 'File In Workflow'
                       when fu.fileClass = 2 then 'File Sent To Staff to Process'
                                             else 'File Stored'
                     end

                   when fu.reviewFile       = 1  then 'File Requires Review'                      
                   when fu.fileCorrupt      = 1  then 'File Corrupt'
                   when fu.fileInfected     = 1  then 'File Infected'
                   when fu.fileIsMissing    = 1  then 'File Missing'
                   when fu.fileDeactivated  = 1  then 'File Deactivated'
                   when fu.fileDeleted      = 1  then 'File Deleted'
                   when fu.fileCancelled    = 1  then 'Upload Cancelled'
                   when    ((fu.postProcessFile  = 1)  
                         or (fu.processFile      = 1) 
                         or (fu.fileAccepted     = 1)) then 
                         case when DATEDIFF(day,fu.fileUploaded,getdate()) <= 1 then 'Upload in Progress' else 'Possible Problem With Upload' end
                    else isnull(fusc.name,'Unknown')
   end

from dbo.FILE_UPLOADS               as fu
join dbo.FILE_CLASSES               as fc   on fc.id   = fu.fileClass
join dbo.FILE_UPLOAD_STATUS_CODES   as fusc on fusc.id = fu.currentStatusCode
join dbo.FILE_UPLOAD_FROM_SOURCES   as fufs on fufs.id = fu.fileUploadedFrom

cross apply (
  select top 1 
    fsd1.* 
  from dbo.FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA (@userID,@userGroup,@userRank,@environmentID,fu.fileClass) as fsd1
) as fsd
 
cross apply (
  select top 1 
    gfn1.fileAsName 
  from dbo.FILE_UPLOAD_GENERATE_FILE_AS_NAME(@userID,@userGroup,@userRank,fu.id) as gfn1
) as gfn

cross apply (
  select top 1 isnull(notifyStaffEmails,'') as notifyStaffEmails 
  from (
    select notifyStaffEmails = stuff((select ';' + staffEmail 
	  from dbo.FILE_UPLOAD_REVIEW_STAFF_NOTIFICATION 
	  where (fileClassID = fu.fileClass) 
	  FOR XML PATH(''),TYPE).value('text()[1]','varchar(max)'),1,1,'')
   ) as q1
) as snem

cross apply (
  select top 1 
    effectiveUploadedOnDateTime 
  from dbo.FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE (@userID, @userGroup, @userRank, fu.id)
) as fued


outer apply (
  select top 1 
    CLIENT_NAME = isnull(cc1.CLIENT_NAME,'')
  from dbo.CLIENTS_CLIENT as cc1   
  where (cc1.CLIENT_ID = fu.clientID)
) as cc

where (fu.id = @uploadID)

)
,
cte_pass_2
as
(
  select top 1 
      p1.* 
    , [fileAsOrFiledName] = isnull(filedName,fileAsName) 
  from cte_pass_1 as p1
)
,
cte_pass_3
as
(
select top 1
    p2.* 
  , [receiveOriginalRootPathFilename]                      = receiveOriginalRootPath     + savedName
  , [archiveOriginalRootPathFilename]                      = archiveOriginalRootPath     + savedName  
  , [storeFiledRootPathFilename]                           = storeFiledRootPath          + fileAsOrFiledName
  , [archiveFiledRootPathFilename]                         = archiveFiledRootPath        + fileAsOrFiledName  
  , [reviewFiledRootPathFilename]                          = reviewFiledRootPath         + fileAsOrFiledName  
  , [deactivateOrReplaceRootPathFilenameSavedName]         = deactivateOrReplaceRootPath + savedName
  , [deactivateOrReplaceRootPathFilenameFileAsOrFiledName] = deactivateOrReplaceRootPath + fileAsOrFiledName
  
from cte_pass_2 as p2

)
,
cte_pass_4
as
(
select top 1
  p3.*    
  , [currentWorkingCopyRootPathFileName] = case    
    when ((processFile = 0) and (reviewFile = 0)) then [storeFiledRootPathFilename]
    when ((processFile = 1) and (reviewFile = 0)) then [receiveOriginalRootPathFilename]
    when ((processFile = 0) and (reviewFile = 1)) then [reviewFiledRootPathFilename] 
    when ((processFile = 1) and (reviewFile = 1)) then ''
    else                                               ''
  end
 , fileIsGenerated    =  0 --case when (p3.fileClassID in (500,501)) then 1 else 0 end
 , processingPriority = case  when (p3.fileClassID = 501) then 0 
                              when (p3.fileClassID = 500) then 1 
							  else 2
					     end
from cte_pass_3 as p3
)

insert into @recs
select top 1
  p4.* 
from cte_pass_4 as p4

if (@extendedStatus = 1)
begin
  update t1
  set t1.generalStatus = isnull((
    select top 1       
      t1.generalStatus + ' - ' + isnull(ibs1.Status,'') 
    from dbo.FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF(@uploadID) as fuib  
    join dbo.INPUT_BATCHES                        as ib    on ib.id           = fuib.inputBatchID
    join dbo.Input_Batches_Status                 as ibs1  on ibs1.Status_Code = ib.Current_status_Code
	where (fuib.uploadID = @uploadID)
  ),'')   
  from @recs as t1
  where ((t1.id = @uploadID) and (t1.readyForUse = 1))

end

if (@checkForDups = 1)
begin
  update t1
   set t1.possibleDuplicateFiles = stuff((select ',' + isnull(filedName,'') 
   from dbo.FILE_UPLOADS as dc
   where (
              (dc.clientID     = t1.clientID)
		  and (dc.fileClass    = t1.fileClassID)
          and (dc.fileSize     = t1.fileSize)
		  and (dc.id          != @uploadID) 
          and (dc.fileMimeType = t1.fileAsMimeType)
		  and (dc.filedName is not null)      
   )  
   FOR XML PATH(''),TYPE).value('text()[1]','varchar(max)'),1,1,'')
   from @recs as t1
   where (t1.id = @uploadID)
end

return

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_DATA_RECORD_CORE] TO [webuser]
GO