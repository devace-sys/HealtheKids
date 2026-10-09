USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Save_Data_Received_Parse_Pivot]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse_Pivot]
GO

USE [spedmon]
GO

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Pivot */    
/**    
 * Pivots data stored in dbo.Claims_835_Data_Received_File_Content and
 * Claims_835_Data_Received_File_Content_Parsed into 
 *
 * Import_From_835_DS_001_Checks
 * Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates
 * Import_From_835_DS_003_Claim_Level_Adjustments
 * Import_From_835_DS_004_Service_Level_Payment_Info_Service_Dates
 * Import_From_835_DS_005_Service_Level_Adjustments
 * Import_From_835_DS_006_Service_Level_Health_Care_Remark_Codes
 * Import_From_835_DS_007_Provider_Level_Adjustments
 * Import_From_835_DS_00A_Patient_Data_Changes
 ***************************************************************************/   

CREATE PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse_Pivot] (
  @receivedFileContentRecID bigint
)
AS
BEGIN

SET NOCOUNT ON 
SET ANSI_WARNINGS OFF

declare @fileID                               as bigint
declare @fileName                             as nvarchar(256)
declare @fileContents                         as varchar(max)   
declare @content_parsed_assigned_line_numbers as bit
declare @content_parsed_pivoted               as bit

RAISERROR ('Parse 835 - Pivoting Data and Storing in Import Tables', 0, 1) WITH NOWAIT 

select top 1 
    @fileID                               = t1.id
  , @fileName                             = t1.file_name
  , @content_parsed_assigned_line_numbers = t1.content_parsed_assigned_line_numbers
  , @content_parsed_pivoted               = t1.content_parsed_pivoted
from dbo.Claims_835_Data_Received_File_Content as t1
where 
  (t1.id = @receivedFileContentRecID)
option(recompile)


if ( @fileID is null )
begin
    RAISERROR ('File record not found', 0, 1) WITH NOWAIT 
	return
end

print @fileName

if (@content_parsed_pivoted = 1) 
begin
  RAISERROR ('Data already pivoted', 0, 1) WITH NOWAIT 
  return
end

if (@content_parsed_assigned_line_numbers = 0)
begin
  RAISERROR ('Line numbers not yet assigned', 0, 1) WITH NOWAIT 
  return
end

RAISERROR ('Pivoting and storing data', 0, 1) WITH NOWAIT 

update dbo.Claims_835_Data_Received_File_Content 
set content_parsed_pivoted    = 0
  , content_parsed_pivoted_on = getdate()
where (id = @fileID)
option(recompile)

declare @tx_control_numbers as table (    
     idx               bigint identity(1,1)
   , file_id           bigint
   , tx_control_number varchar(255)
   unique clustered (file_id, tx_control_number)
)

declare @tx_control_number  as varchar(255)

insert into @tx_control_numbers
select
  *
from
(
  select distinct
      file_id
    , tx_control_number 
  from dbo.Claims_835_Data_Received_File_Content_Parsed as t1
  where (t1.file_id = @receivedFileContentRecID)
) as q1
order by 
  file_id
, tx_control_number
option(recompile)

declare @minControlNumberIdx as bigint
declare @maxControlNumberIdx as bigint
declare @curControlNumberIdx as bigint

select @minControlNumberIdx = min(idx) from @tx_control_numbers
select @maxControlNumberIdx = max(idx) from @tx_control_numbers
select @curControlNumberIdx = @minControlNumberIdx

while (@curControlNumberIdx <= @maxControlNumberIdx)
begin
  
  select top 1 
    @tx_control_number = tx_control_number 
  from @tx_control_numbers 
  where 
    (idx = @curControlNumberIdx)
  
  /* >>> IMPORTANT DO NOT CHANGE THE ORDER OF THE FOLLOWING INSERTS  <<<
   * >>> EACH ROUTINE DEPENDS ON DATA EXTRACTED FROM PREVIOUS CALLS. <<< */

  RAISERROR ('Parse 835 - Storing Checks', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_001_Checks
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check (@receivedFileContentRecID, @tx_control_number)
  option(recompile)
 
  RAISERROR ('Parse 835 - Storing Claim Level Payment Data', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Payment_Information_Patient_Name_Claim_Payment_Claim_Dates (@receivedFileContentRecID, @tx_control_number)
  option(recompile)
  
  RAISERROR ('Parse 835 - Storing Claim Level Adjustments', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_003_Claim_Level_Adjustments
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Adjustment (@receivedFileContentRecID, @tx_control_number) 
  option(recompile)

  RAISERROR ('Parse 835 - Storing Service Level Payment Data', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_004_Service_Level_Payment_Info_Service_Dates
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates (@receivedFileContentRecID, @tx_control_number) 
  option(recompile)

  RAISERROR ('Parse 835 - Storing Service Level Adjustments', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_005_Service_Level_Adjustments
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Adjustment (@receivedFileContentRecID, @tx_control_number)
  option(recompile)
  
  RAISERROR ('Parse 835 - Storing Service Level Health Care Remark Codes', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_006_Service_Level_Health_Care_Remark_Codes
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code (@receivedFileContentRecID, @tx_control_number)
  option(recompile)

  RAISERROR ('Parse 835 - Storing Provider Level Adjustments', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_007_Provider_Level_Adjustments
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments (@receivedFileContentRecID, @tx_control_number)
  option(recompile)

  RAISERROR ('Parse 835 - Storing Patient Data Changes', 0, 1) WITH NOWAIT 
  insert into dbo.Import_From_835_DS_00A_Patient_Data_Changes
  select * from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes (@receivedFileContentRecID, @tx_control_number)
  option(recompile)
    
  set @curControlNumberIdx = @curControlNumberIdx + 1

end


update dbo.Claims_835_Data_Received_File_Content 
set content_parsed_pivoted    = 1
  , content_parsed_pivoted_on = getdate()
where 
  (id = @fileID)
option(recompile)

RAISERROR ('Done', 0, 1) WITH NOWAIT 


return
END
GO


