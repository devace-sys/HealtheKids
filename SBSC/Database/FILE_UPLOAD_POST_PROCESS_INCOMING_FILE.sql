USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_POST_PROCESS_INCOMING_FILE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_POST_PROCESS_INCOMING_FILE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_POST_PROCESS_INCOMING_FILE ( 
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @environmentID            bigint  
  , @uploadID                 bigint
)
AS
BEGIN


declare @fileClassID          as bigint = 1
declare @clientID             as bigint
declare @statusID             as bigint 
declare @today                as datetime
declare @review               as bit      = 0
declare @postProcess          as bit      = 0
declare @filedFileName        as varchar(1000)
declare @filedFileLocation    as varchar(1000)
declare @fileFileLocationName as varchar(8000)


set @today = getdate()  

/*###########################################################################
  # Get file class and file review state
  ###########################################################################*/       
  
select 

   @fileClassID          = fu.fileClassID
 , @review               = fu.reviewFile
 , @postProcess          = fu.postProcessFile
 , @filedFileName        = fu.filedName
 , @filedFileLocation    = fu.storeFiledPath
 , @fileFileLocationName = fu.storeFiledRootPathFilename 

from dbo.FILE_UPLOAD_VIEW (@userID,@userGroup,@userRank,@environmentID,@uploadID,null,null,null) as fu

/*###########################################################################
  # If the file is not flagged for review and it is flagged for post process
  # continue with class specific processing
  ###########################################################################*/       

if ((@review = 0) and (@postProcess = 1))
begin

  /*###########################################################################
    # Indicate post processing occurred
    # Note: This also sets postProcess flag to false
    ###########################################################################*/       

  exec dbo.FILE_UPLOAD_SET_STATUS @uploadID, @today, @userID, 850, null, null, null, @statusID output

  /*###########################################################################
    # Work batch
    ###########################################################################*/       

  if (@fileClassID = 1)
  begin

    /*============================================================
     * We need to create an input batch record with a status code
     * of 10
     *============================================================*/
   
    declare @statuscode      as int            = 10
    declare @dateSent        as datetime
    declare @dateReceived    as datetime
    declare @oldest_dos      as datetime
    declare @typeOfWork      as smallint
    declare @filename        as varchar(1000)
    declare @fileLocation    as varchar(1000)
    declare @partial         as bit           = 0
    declare @parentID        as bigint        = null
    declare @estmtedInpthrs  as decimal(18,2) = null
    declare @userID1         as bigint        = null
    declare @userID2         as bigint        = null
    declare @priorityNum     as smallint      = 0
    declare @degreeofdifcult as smallint      = 0 
    declare @batchRecordID   as bigint        = 0
	declare @spDetails       as varchar(8000) = ''
  
    /*============================================================
     * Retrieve data we need to create an input batch record
     *============================================================*/
   
    select top 1
        @clientID     = fu.clientID
      , @typeOfWork   = tow.TypeOfWorkID
      , @oldest_dos   = convert(datetime,fu.ReferenceDate1)
      , @dateSent     = fued.effectiveUploadedOnDateTime
      , @dateReceived = fu.fileUploaded
      , @filename     = @filedFileName
      , @fileLocation = @filedFileLocation

    from dbo.FILE_UPLOADS as fu 
    join dbo.FILE_UPLOAD_VIEW_FILE_CLASS_FILE_STORAGE_DATA ( @userID, @userGroup, @userRank, @environmentID, @fileClassID) as fsd on fsd.id = fu.fileClass
    cross apply ( select id as TypeOfWorkID from TYPE_OF_WORK as tw where fu.fileSubClass like tw.WorkCode+'%' ) as tow
    cross apply ( select effectiveUploadedOnDateTime from dbo.FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE(@userID, @userGroup, @userRank, fu.id) ) as fued

    where (fu.id = @uploadID)

    /*============================================================
     * Create input batch record
     *============================================================*/

    exec dbo.INPUT_BATCHES_Save
	    @userID   
	  , @userGroup
	  , @userRank 
      , @filename
      , @fileLocation
      , @clientID     
      , @dateSent
      , @dateReceived
      , @partial 
      , @parentID
      , @typeOfWork
      , @oldest_dos
      , @estmtedInpthrs
      , @userID1
      , @userID2
      , @priorityNum
      , @degreeofdifcult
      , @statuscode
      , ''    -- @note
      , ''    -- @editDelReason
      , 0     -- @validateRec     
      , 1     -- @saveType
      , null  -- @recID          
      , ''    -- @MsgNotActive    
      , ''    -- @MsgNoRec        
      , ''    -- @MsgNoEdit       
      , ''    -- @MsgDupRec       
      , ''    -- @MsgDataError 
	  , @spDetails     output   
      , @batchRecordID output  

   
   declare @note as varchar(8000)
   set @note = convert(varchar(50),@batchRecordID) + '|' + @fileLocation + '|' + @filename

   /*###########################################################################
     # Indicate work batch created
     ###########################################################################*/       

   exec dbo.FILE_UPLOAD_SET_STATUS @uploadID, @today, @userID, 2000, @fileFileLocationName, null, @note, @statusID output
  
  end
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
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_POST_PROCESS_INCOMING_FILE] TO [webuser]

GO