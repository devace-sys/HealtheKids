USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Save_Data_Received]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Claims_835_Save_Data_Received]
GO

USE [spedmon]
GO

/***************************************************************************    
 * Claims_835_Save_Data_Received */    
/**    
 * 
 * Saves content of @pathFileName
 ***************************************************************************/   

CREATE PROCEDURE [dbo].[Claims_835_Save_Data_Received] (
    @pathFileName     nvarchar(512)
  , @billingProgramID tinyint = 1  /* 1 = LEA BOP, 2 = CYBHI */
  , @recordID         bigint OUTPUT
)
AS
BEGIN

SET NOCOUNT ON 

RAISERROR ('Save 835 - Saving Data File Received', 0, 1) WITH NOWAIT 

declare @file as nvarchar(256)
declare @fileContents    as varchar(max)

set @file = dbo.GET_FILE_NAME_FROM_PATH_FILE_NAME(@pathFileName,'\')

if (@file = '')
begin
  RAISERROR ('Must provide a file name', 0, 1) WITH NOWAIT 
  return
end

print @file

select top 1 
  @recordID = t1.id 
from dbo.Claims_835_Data_Received_File_Content as t1
where 
  (t1.file_name = @file)

if (@recordID is not null) 
begin
  RAISERROR ('File has already been saved', 0, 1) WITH NOWAIT 
  return
end

exec dbo.ReadStringFromFile  @pathFileName, @fileContents OUTPUT
if (@fileContents is null) return

insert into dbo.Claims_835_Data_Received_File_Content 
(
    file_name
  , content_saved
  , content_parsed
  , content_parsed_assigned_line_numbers
  , content_parsed_pivoted
  , content_saved_on
  , edi_file_text 
  , billingProgramID
)
values 
(
    @file
  , 1
  , 0
  , 0
  , 0
  , getdate()
  , @fileContents 
  , @billingProgramID
)

set @recordID = SCOPE_IDENTITY()

return

END
GO


