USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Save_Data_Received_Parse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse]
GO

USE [spedmon]
GO

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse */    
/**    
 * Parses X12 data stored in dbo.Claims_835_Data_Received_File_Content into
 * Claims_835_Data_Received_File_Content_Parsed.
 * This is pass 1 of 2.
 ***************************************************************************/   

CREATE PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse] (
   @receivedFileContentRecID bigint
 , @findLoopAndSegmentDesc  bit
)

AS
BEGIN

SET NOCOUNT ON 

RAISERROR ('Parsing 835 1/2 - Initial Parsing and Mapping Segments, Elements and Loops', 0, 1) WITH NOWAIT 

declare @fileID                               as bigint
declare @fileName                             as nvarchar(256)
declare @fileContents                         as varchar(max)   
declare @content_parsed                       as bit
declare @x12GeneralSpec                       as xml
declare @x12TransactionSpec                   as xml

select top 1 
    @fileID                               = t1.id
  , @fileName                             = t1.file_name
  , @content_parsed                       = t1.content_parsed
  , @fileContents                         = t1.edi_file_text 
from dbo.Claims_835_Data_Received_File_Content as t1
where (t1.id = @receivedFileContentRecID)

if ( @fileID is null )
begin
    RAISERROR ('File record not found', 0, 1) WITH NOWAIT 
	return
end

print @fileName

if (@content_parsed = 1) 
begin
  RAISERROR ('Initial parsing and mapping already completed', 0, 1) WITH NOWAIT 
  return
end

if (@findLoopAndSegmentDesc = 1)
begin
  select top 1 @x12GeneralSpec = spec_document from dbo.X12_Transaction_Specs where spec_name = '5010'
  
  if ((@x12GeneralSpec is null) or (@x12GeneralSpec.exist('*') = 0))
  begin
    RAISERROR ('General specification data not found!', 0, 1) WITH NOWAIT 
	return
  end
end

select top 1 @x12TransactionSpec = spec_document from dbo.X12_Transaction_Specs where spec_name = '5010-835'

if ((@x12TransactionSpec is null) or (@x12TransactionSpec.exist('*') = 0))
begin
  RAISERROR ('Transaction specification data not found!', 0, 1) WITH NOWAIT 
  return
end
  
RAISERROR ('Parsing and mapping please wait', 0, 1) WITH NOWAIT 

update dbo.Claims_835_Data_Received_File_Content 
set content_parsed = 0
  , content_parsed_on = getdate()
where id = @fileID

insert into dbo.Claims_835_Data_Received_File_Content_Parsed
select  
    t1.*
  , line_number = null 
from dbo.X12ParseFileContents ( @x12GeneralSpec
                              , @x12TransactionSpec 
							  , @receivedFileContentRecID
							  , @fileContents
							  , @findLoopAndSegmentDesc) as t1

/* We need the order to be the same order as the file */

order by  
  segment_idx
, element_pos

update dbo.Claims_835_Data_Received_File_Content 
set content_parsed = 1 
  , content_parsed_on = getdate()
where id = @fileID


RAISERROR ('Done', 0, 1) WITH NOWAIT 

return
END
GO


