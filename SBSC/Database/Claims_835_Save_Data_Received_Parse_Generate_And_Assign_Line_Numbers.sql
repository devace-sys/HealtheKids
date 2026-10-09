USE [spedmon]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers]') AND type in (N'P', N'PC'))
begin
  DROP PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers]
end
GO

USE [spedmon]
GO

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers */    
/**    
 * Works with data stored in dbo.Claims_835_Data_Received_File_Content_Parsed.
 * Generates and assigns line numbers.
 *
 * Line numbers are generated based on the CLM segments
 * All child segments and loops of loop 2100 are assigned the line number
 * This is pass 2 of 2.
 ***************************************************************************/   

CREATE PROCEDURE [dbo].[Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers] (
  @receivedFileContentRecID bigint
)
AS
BEGIN

SET NOCOUNT ON 

RAISERROR ('Parsing 835 2/2 - Assigning Transaction Detail Line Numbers', 0, 1) WITH NOWAIT 

declare @fileID                               as bigint
declare @fileName                             as nvarchar(256)
declare @content_parsed                       as bit
declare @content_parsed_assigned_line_numbers as bit

declare @lineNumberAssignments as table (
    segment_idx            bigint
  , content_parsed_id      bigint
  , line_number            bigint 
unique clustered (segment_idx, content_parsed_id)
)

declare @tx_claim_line_segments as table (
     idx               int     identity(1,1)
   , segment_idx       bigint   
   , content_parsed_id bigint
   , line_number       bigint
  unique clustered    (idx)    
, unique nonclustered (segment_idx, content_parsed_id)
, unique nonclustered (content_parsed_id)
)

/*----------------------------------------------------------------------------------*/

select top 1 
    @fileID                               = t1.id
  , @fileName                             = t1.file_name
  , @content_parsed                       = t1.content_parsed
  , @content_parsed_assigned_line_numbers = t1.content_parsed_assigned_line_numbers
from dbo.Claims_835_Data_Received_File_Content as t1
where 
  (t1.id = @receivedFileContentRecID)
option(recompile)

/*----------------------------------------------------------------------------------*/

if ( @fileID is null )
begin
    RAISERROR ('File record not found', 0, 1) WITH NOWAIT 
	return
end

/*----------------------------------------------------------------------------------*/

print @fileName

/*----------------------------------------------------------------------------------*/

if (@content_parsed_assigned_line_numbers = 1)
begin
  RAISERROR ('Line numbers already assigned', 0, 1) WITH NOWAIT 
  return
end

/*----------------------------------------------------------------------------------*/

if (@content_parsed = 0)
begin
  RAISERROR ('Content must be parsed first', 0, 1) WITH NOWAIT 
  return
end

/*----------------------------------------------------------------------------------*/

RAISERROR ('Setting all line numbers to null and saving', 0, 1) WITH NOWAIT 

update cp
  set cp.line_number = null
from [dbo].[Claims_835_Data_Received_File_Content_Parsed] as cp

/* Predicate uses index */

where (
        (cp.file_id = @fileID)
    and (cp.tx_control_number is not null)
	and (cp.loop_name    is not null)
	and (cp.segment_name is not null)
	and (cp.element_pos  is not null)
	and (cp.id           is not null)
)
option(recompile)

/*----------------------------------------------------------------------------------*/

RAISERROR ('Generating line numbers please wait', 0, 1) WITH NOWAIT 

update dbo.Claims_835_Data_Received_File_Content 
  set content_parsed_assigned_line_numbers    = 0
    , content_parsed_assigned_line_numbers_on = getdate() 
where 
  (id = @fileID)
option(recompile)

/*----------------------------------------------------------------------------------*/
                       
RAISERROR ('Get all CLP segments in loop 2100 and calculate line numbers for each', 0, 1) WITH NOWAIT 

insert into @lineNumberAssignments (segment_idx, content_parsed_id, line_number)
select 
     fcp.segment_idx
   , content_parsed_id = fcp.id
   , line_number       = DENSE_RANK() over (partition by fcp.tx_control_number 
                                            order by     fcp.segment_num) 
from [dbo].[Claims_835_Data_Received_File_Content_Parsed] as fcp

/* Predicate uses index */

where
       ((fcp.file_id           = @fileID)
    and (fcp.tx_control_number is not null)
	and (fcp.loop_name         = '2100')
	and (fcp.segment_name      = 'CLP')
	and (fcp.element_pos       = 2) /* we want the position right after the segment name */
    and (fcp.id is not null))	

/* This exact ordering is important */

order by 
    fcp.tx_control_number
  , fcp.segment_idx

option(recompile)

/*----------------------------------------------------------------------------------*/

RAISERROR ('Get all segments in loop 2100 and 2110', 0, 1) WITH NOWAIT 
  
insert into @tx_claim_line_segments (segment_idx, content_parsed_id, line_number)
select    
    cp.segment_idx  
  , content_parsed_id = cp.id   
  , line_number       = null
from dbo.Claims_835_Data_Received_File_Content_Parsed as cp 

/* Predicate uses index */

where      
     ((cp.file_id = @fileID) 
 and (cp.tx_control_number is not null)
 and (cp.loop_name    in ('2100','2110'))
 and (cp.segment_name is not null)
 and (cp.element_pos  > 1)
 and (cp.id is not null))

/* This exact ordering is important */

order by 
    cp.tx_control_number
  , cp.segment_idx
  , cp.id

option(recompile)

/*----------------------------------------------------------------------------------*/

/* Initial Assignment */
  
update t1
set 
  t1.line_number = t2.line_number
from @tx_claim_line_segments as t1
join @lineNumberAssignments  as t2 on t2.segment_idx        = t1.segment_idx
                                   and t2.content_parsed_id = t1.content_parsed_id
option(recompile)

/* Loop through and assign rest */

declare @curIdx as int = 1
declare @maxIdx as int = null
select @maxIdx = max(t1.idx) from @tx_claim_line_segments as t1 option(recompile)

declare @lastNotNullLineNum as bigint = 1
declare @curLineNum         as bigint = null

while (@curIdx <= @maxIdx)
begin
  
  select top 1 
    @curLineNum = t1.line_number 
  from @tx_claim_line_segments as t1
  where 
    (t1.idx = @curIdx)
  option(recompile)
  
  if (@curLineNum is not null) 
  begin
    set @lastNotNullLineNum = @curLineNum
  end
  else 
  begin
    update @tx_claim_line_segments set line_number = @lastNotNullLineNum where idx = @curIdx option(recompile)
  end
  set @curIdx = @curIdx + 1
end

/*----------------------------------------------------------------------------------*/

RAISERROR ('Save line number assignments', 0, 1) WITH NOWAIT 

update cp
  set cp.line_number = t1.line_number
from @tx_claim_line_segments as t1
join [dbo].[Claims_835_Data_Received_File_Content_Parsed] as cp on cp.id = t1.content_parsed_id
option(recompile)

/*----------------------------------------------------------------------------------*/

update dbo.Claims_835_Data_Received_File_Content 
  set content_parsed_assigned_line_numbers = 1
    , content_parsed_assigned_line_numbers_on = getdate() 
where id = @fileID
option(recompile)

/*----------------------------------------------------------------------------------*/

RAISERROR ('Done', 0, 1) WITH NOWAIT 

return
END
GO


