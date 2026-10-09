USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF] (@uploadID bigint) 

RETURNS @recs TABLE (  
                       inputBatchID            bigint                     
                     , uploadID                bigint                  
                     , uploadLogEntryID        bigint
                     , batchedFileName         varchar(256)
                     , batchedFileIsPDF        bit
                     , uploadLogEntryCreatedOn datetime
                     , uploadLogEntryCreatedBy bigint
                     , uploadLogEntryNote      varchar(8000)

UNIQUE CLUSTERED (inputBatchID)
)
AS     
BEGIN
    

/*-------------------------------
 * Setup 
 *------------------------------*/

declare @statusLogEntries as table (
    logEntryID   bigint
  , uploadID     bigint
  , createdOn    datetime
  , createdBy    bigint
  , note         varchar(8000)
UNIQUE CLUSTERED (logEntryID)
)

declare @statusLogEntryNoteParts as table (
    logEntryID bigint
  , id         int
  , part       varchar(256)  
  UNIQUE CLUSTERED (logEntryID,id)
)

/*-------------------------------
 * Get all log entries that
 * indicate a batch of work
 * sent to us via file upload
 * was sent to the workflow
 * system by the file upload 
 * system
 *------------------------------*/

if (@uploadID is null)
begin
  insert into @statusLogEntries
  select     
      logEntryID = t1.id
    , t1.uploadID  
    , t1.createdOn
    , t1.createdBy
    , t1.note
  from dbo.FILE_UPLOAD_STATUS_LOG as t1
  where (t1.statusCode = 2000)
end
else
begin
  insert into @statusLogEntries
  select     
      logEntryID = t1.id
    , t1.uploadID  
    , t1.createdOn
    , t1.createdBy
    , t1.note
  from dbo.FILE_UPLOAD_STATUS_LOG as t1
  where (
        (t1.uploadId = @uploadID)
    and (t1.statusCode = 2000)
  )
end

/*-------------------------------
 * Parse the note field
 *------------------------------*/

insert into @statusLogEntryNoteParts
select     
    t1.logEntryID
  , t2.id
  , t2.part
from @statusLogEntries as t1
cross apply ( select * from dbo.STRING_SPLIT (t1.note,'|',1)) as t2

/*-------------------------------
 * Generate results
 *------------------------------*/

insert into @recs
select 
  inputBatchID     = (convert(bigint,p1.part))
, uploadID         = le.uploadID
, uploadLogEntryID = le.logEntryID
, batchedFileName  = p3.part
, batchedFileIsPDF = (convert(bit,(case when (p3.part like '%.pdf') then 1 else 0 end)))
, uploadLogEntryCreatedOn = le.createdOn
, uploadLogEntryCreatedBy = le.createdBy
, uploadLogEntryNote      = le.note

from @statusLogEntries        as le
join @statusLogEntryNoteParts as p1 on p1.logEntryID = le.logEntryID and p1.id = 1
join @statusLogEntryNoteParts as p3 on p3.logEntryID = le.logEntryID and p3.id = 3


/*-------------------------------
 * All done, exit
 *------------------------------*/
  
return
end 

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF] TO [webuser]
GO
