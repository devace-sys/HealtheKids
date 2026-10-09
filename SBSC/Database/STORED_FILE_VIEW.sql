USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STORED_FILE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STORED_FILE_VIEW] (
    @userID             bigint
  , @userGroup          int
  , @userRank           int
  , @environmentID      int
  , @clientID           bigint
  , @pracID             bigint
  , @patID              bigint
  , @referencedEntityID bigint
  , @fileClass          bigint
  , @startDate          date
  , @endDate            date
  , @fileNameSpace      varchar(500)
  , @fileSource         varchar(500)
  , @recID              bigint
  , @assumeUserCanView  bit
) 

RETURNS @recs 

table (
   rowOrder          bigint
 , id                bigint
 , [name]            varchar(8000)
 , fileId            varchar(1000)
 , userID            bigint
 , userGroup         int
 , userRank          int
 , clientID          bigint
 , clientName        nvarchar(100)
 , pracID            bigint
 , pracName          nvarchar(100)
 , patID             bigint
 , patName           nvarchar(100)
 , groupIdDisp       bigint
 , groupDispName     nvarchar(100)
 , fileClassID       bigint
 , fileClassName     varchar(1000)
 , fileSubClass      varchar(1000)
 , label             varchar(8000)
 , [description]     varchar(500)
 , fileSymLinkRoot   varchar(4000)
 , fileActualRoot    varchar(8000)
 , fileRoot          varchar(4000)
 , filePath          varchar(4000)
 , [fileName]        varchar(8000)
 , fileUploadOn      datetime
 , fileUploadOnStr   varchar(50)
 , fileUploadByEmail varchar(4000)
 , fileSize          bigint
 , fileSizeHuman     varchar(100)
 , fileMimeType      varchar(8000)
 , ourFileName       varchar(8000)
 , isConfidentialPracticeFile         bit
 , isConfidentialPracticeFileStr      varchar(3)
 , okToShareFileWithParentGuardian    bit
 , okToShareFileWithParentGuardianStr varchar(3)
 , okToShareFileWithPatient           bit
 , okToShareFileWithPatientStr        varchar(3)
 , active                             bit
 , canView                       bit
)   

as
begin

 /***************************************************************************    
  * STORED_FILE_VIEW */    
 /**    
  * Returns file upload data
  *    
  * @return Table of upload data    
  ***************************************************************************/     

declare @storedFileServiceClassPartID       as bigint = 100 /* Use standard partitioning */
declare @userClientID                       as bigint
declare @userRole                           as bigint
declare @userGroupServiceClassNameID        as bigint
declare @userPracID                         as bigint

/*###########################################################################
  # Overrides for telecomm
  ###########################################################################*/  

if (@fileClass is not null)
begin
  if (@fileClass = 500)
  begin
    set @patID = null
  end
  else if (@fileClass = 501)
  begin
	set @pracID = null
  end
end

/*###########################################################################
  # Get user data for calling user
  ###########################################################################*/  

select top 1
    @userRole                    = gud.roleID
  , @userClientID                = gud.clientID
  , @userGroupServiceClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
  , @userPracID                  = gud.pracID
from      users.dbo.USERS_ALL                                        as gud
left join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS      as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = @storedFileServiceClassPartID) and (png.GROUP_ID = gud.pracDispGroupID)) /* Uses index */
where 
  (gud.id = @userID)
option (recompile)

;
with 

/*###########################################################################
  # Get stored file base data
  ###########################################################################*/  

cte_p1
as
(
select 
    fu.id
  , [name] = fu.originalName
  , fu.userID
  , fileUserPracID = fileUserPracID2.PRACTITIONER_ID
  , fu.userGroup
  , fu.userRank
  , fu.clientID
  , fu.pracID
  , fu.patID
  , fu.groupIdDisp
  , [fileClassID]       = fc.id
  , [fileClassName]     = fc.[name]
  , [fileSubClass]      = isnull(fu.fileSubClass,'')
  , [label]             = fu.originalName
  , [description]       = isnull(fu.[description],'')
  , [fileSymLinkRoot]   = vfsd.symLinkRoot
  , [fileActualRoot]    = vfsd.rootPath
  , [fileRoot]          = vfsd.symLinkRoot
  , [filePath]          = vfsd.[path]
  , [fileName]          = fu.savedName
  , [fileUploadOn]      = fu.fileUploaded                  
  , [fileUploadByEmail] = isnull(fu.fileUploaderContactEmail,'')
  , fu.fileSize
  , fu.fileMimeType
  , [ourFileName]       = fu.filedName
  , fu.isConfidentialPracticeFile
  , fu.okToShareFileWithParentGuardian
  , fu.okToShareFileWithPatient                                 
  , fu.active
from dbo.FILE_UPLOADS               as fu
join dbo.FILE_CLASSES               as fc   on fc.id   = fu.fileClass
join dbo.FILE_UPLOAD_FROM_SOURCES   as fufs on fufs.id = fu.fileUploadedFrom

join dbo.FILE_UPLOAD_VIEW_FILE_STORAGE_DATA (  @userID
                                             , @userGroup
                                             , @userRank
                                             , @environmentID ) as vfsd on vfsd.id = fc.fileStoragePathNameAddressArchiveOriginalID


outer apply (
  select top 1 
    fileUserPracID1.PRACTITIONER_ID
  from dbo.PRACTITIONER_Practitioner as fileUserPracID1
  where 
    (fileUserPracID1.UserID = fu.userID)
) as fileUserPracID2

where (
      (1=1)    
  and ((@recID     is null)  or (fu.id       = @recID))
  and ((@clientID  is null)  or (fu.clientID = @clientID))
  and ((@startDate is null and @endDate is null) or ((convert(date,fu.fileUploaded)) between @startDate and @endDate))
  and ((@fileClass is null)  or (fc.id       = @fileClass))
  and ((@pracID    is null)  or (fu.pracID   = @pracID))
  and ((@patID     is null)  or (fu.patID    = @patID))
  and (fu.active = 1)
  and ((@referencedEntityID is null) or (fu.referencedEntityID = @referencedEntityID)) 
)
)
,

/*###########################################################################
  # Determine who can view file
  ###########################################################################*/  

cte_p2
as
(
select 
    p1.*  

  , [canView]  = dbo.STORED_FILE_CAN_USER_VIEW (  @userID
                                                , @userGroup
                                                , @userRank
                                                , @userRole
                                                , @userClientID
                                                , @storedFileServiceClassPartID
                                                , @userGroupServiceClassNameID
												, @userPracID
                                                , p1.id
                                                , p1.userID
												, p1.fileUserPracID
                                                , p1.clientID
                                                , p1.pracID
                                                , p1.patID
                                                , p1.groupIdDisp
												, @assumeUserCanView
												, p1.fileClassID
												, p1.isConfidentialPracticeFile
												, p1.okToShareFileWithParentGuardian
												, p1.okToShareFileWithPatient )    
  from cte_p1 as p1

)
,

/*###########################################################################
  # Filter on who can view, get various entity names, calculate string reps
  # of values
  ###########################################################################*/  

cte_p3
as
(
  select 
       p2.*
    , [clientName]        = isnull(clc.CLIENT_NAME,N'')
	, [pracName]          = isnull(prp.CONCAT_NAME,N'')
	, [patName]           = isnull(pap.CONCAT_NAME,N'')
    , [groupDispName]     = isnull(ggd.GROUP_NAME, N'')
	, [rowOrder]                      = dense_rank() over(order by p2.fileUploadOn desc, p2.id desc)
	, [fileId]                        = convert(varchar(1000),p2.id)
	, [fileSizeHuman]                 = isnull(dbo.CALC_HUMAN_BYTE_SIZE(p2.fileSize,1),'') 
	, [isConfidentialPracticeFileStr]    = dbo.RPT_BIT_TO_YN(p2.isConfidentialPracticeFile)	 
    , okToShareFileWithParentGuardianStr = dbo.RPT_BIT_TO_YN(p2.okToShareFileWithParentGuardian)
    , okToShareFileWithPatientStr        = dbo.RPT_BIT_TO_YN(p2.okToShareFileWithPatient)
    , [fileUploadOnStr]                  = dbo.RPT_DATE_FMT(p2.fileUploadOn)

  from cte_p2 as p2 

  left join dbo.CLIENTS_Client                as clc on clc.CLIENT_ID       = p2.clientID
  left join dbo.PRACTITIONER_Practitioner     as prp on prp.PRACTITIONER_ID = p2.pracID
  left join dbo.PATIENTS_Patient              as pap on pap.PATIENT_ID      = p2.patID
  left join dbo.GROUP_GROUP                   as ggd on ggd.GROUP_ID        = p2.groupIDDisp

  where 
    (p2.canView = 1)
)

/*###########################################################################
  # Output, sorting by row order
  ###########################################################################*/  

insert into @recs (
    [rowOrder] 
  , id 
  , [name] 
  , fileId 
  , userID 
  , userGroup
  , userRank 
  , clientID
  , clientName 
  , pracID 
  , pracName 
  , patID 
  , patName    
  , groupIdDisp
  , groupDispName 
  , fileClassID 
  , fileClassName 
  , fileSubClass 
  , label 
  , [description] 
  , fileSymLinkRoot
  , fileActualRoot
  , fileRoot 
  , filePath 
  , [fileName] 
  , fileUploadOn 
  , fileUploadOnStr
  , fileUploadByEmail
  , fileSize
  , fileSizeHuman 
  , fileMimeType 
  , ourFileName
  , isConfidentialPracticeFile
  , isConfidentialPracticeFileStr
  , okToShareFileWithParentGuardian
  , okToShareFileWithParentGuardianStr
  , okToShareFileWithPatient
  , okToShareFileWithPatientStr
  , active 
  , canView 
)
select 
   p3.[rowOrder] 
 , p3.id 
 , p3.[name] 
 , p3.fileId 
 , p3.userID 
 , p3.userGroup
 , p3.userRank 
 , p3.clientID
 , p3.clientName 
 , p3.pracID 
 , p3.pracName 
 , p3.patID 
 , p3.patName    
 , p3.groupIdDisp
 , p3.groupDispName 
 , p3.fileClassID 
 , p3.fileClassName 
 , p3.fileSubClass 
 , p3.label 
 , p3.[description] 
 , p3.fileSymLinkRoot
 , p3.fileActualRoot
 , p3.fileRoot 
 , p3.filePath 
 , p3.[fileName] 
 , p3.fileUploadOn 
 , p3.fileUploadOnStr
 , p3.fileUploadByEmail
 , p3.fileSize
 , p3.fileSizeHuman 
 , p3.fileMimeType 
 , p3.ourFileName
 , p3.isConfidentialPracticeFile
 , p3.isConfidentialPracticeFileStr
 , p3.okToShareFileWithParentGuardian
 , p3.okToShareFileWithParentGuardianStr
 , p3.okToShareFileWithPatient
 , p3.okToShareFileWithPatientStr
 , p3.active 
 , p3.canView
from cte_p3 as p3
order by 
  rowOrder
option(recompile)

return
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[FILE_UPLOADS] TO [webuser]
GO

GRANT SELECT ON  [dbo].[STORED_FILE_VIEW] TO [webuser]
GO