USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_Generate_Pre_Import_Rpt_Html') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Match_Generate_Pre_Import_Rpt_Html
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.Patient_Data_Imports_Match_Generate_Pre_Import_Rpt_Html (
    @preImportNumRowsSkipped            as int
  , @preImportNumColsSkipped            as int
  , @preImportNumAdditionalRowsSkipped  as int
  , @hasPreImportRowExceptions          as bit
  , @hasAdditionalBadRowExceptions      as bit
  , @importDataJSON                     as varchar(max)
  , @preImportAdditionalBadRowsJSONData as varchar(max)
)
     
RETURNS varchar(max)

AS 
BEGIN

set @importDataJSON = isnull(@importDataJson,'')
if (@importDataJSON = '') return ''

declare @basicStats                    as varchar(max) = ''
declare @exceptionsRpt                 as varchar(max) = ''
declare @preImportBadRowsRpt           as varchar(max) = ''
declare @preImportAdditionalBadRowsRpt as varchar(max) = ''

declare @headerRowStr   as varchar(max) = ''
declare @minIdx         as bigint
declare @maxIdx         as bigint
declare @curIdx         as bigint


declare @additionalBadRows as table (
    idx    bigint identity(1,1)
  , rowNum bigint
  , reason varchar(512)
  unique clustered (rowNum,idx)
)

declare @exceptionData as table (
    idx                bigint identity(1,1)
  , rowBad             bit
  , optionalRowDataBad bit
  , rowNum             int
  , rowData            nvarchar(max)
  , validationMessages nvarchar(max)
)

set @basicStats = '<details open><summary>Patient Data Excluded Prior To Import - Summary</summary>'
	   + '<table>' 
	   + '<tbody>'
       +  '<tr><th>Number of Rows Skipped for Data Formatting Issues:</th><td>' + convert(varchar(50),@preImportNumRowsSkipped) + '</td></tr>'
       +  '<tr><th>Number of Cols Skipped for Data Formatting Issues:</th><td>' + convert(varchar(50),@preImportNumColsSkipped) + '</td></tr>'
	   +  '<tr><th>Number of Row Skipped for Data Integrity Issues:</th><td>'   + convert(varchar(50), @preImportNumAdditionalRowsSkipped) + '</td></tr>'
       + '</tbody>'
	   + '</table>'                    
       + '</details>'

if (@hasPreImportRowExceptions = 1)
begin
  set @preImportBadRowsRpt = 
                           + '<details>'
						   + '<summary>Entire Rows or Individual Columns Skipped Prior To Import For Data Formatting Issues</summary>'  
                           + dbo.STRUCTURED_DATA_IMPORT_GENERATE_EXCEPTION_RPT_HTML(@importDataJSON)
						   + '</details>'
end /*hasPreImportRowExceptions*/

if (@hasAdditionalBadRowExceptions = 1)
begin

  set @preImportAdditionalBadRowsRpt = '<details><summary>Entire Rows Skipped Prior To Import For Data Integrity Issues</summary>'

  insert into @additionalBadRows (
      rowNum 
    , reason   
  )
  select
    t1.rowNum
  , t1.reason
  from OPENJSON( @preImportAdditionalBadRowsJSONData, '$' ) 
  with (
          [rowNum]                int               '$."rowNum"'
	    , [reason]                varchar(512)      '$."reason"'
  ) as t1


  insert into @exceptionData (
      rowBad             
    , optionalRowDataBad 
    , rowNum             
    , rowData            
    , validationMessages 
  )

  select
      rowBad = 1             
    , optionalRowDataBad = 0 
    , t1.rowNum             
    , t1.rowData            
    , validationMessages = t2.reason 

  FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' )
  WITH (
          [rowNum]                int               '$."rowNumIn"'
  	    , [rowData]               nvarchar(max)     '$."rowData"'            as JSON
  ) as t1
  join @additionalBadRows as t2 on t2.rowNum = t1.rowNum

  select @minIdx=min(t1.idx), @maxIdx=max(t1.idx) from @exceptionData as t1
  set @curIdx = @minIdx

  set @headerRowStr = '<tr><th>Row #</th><th>Row Skipped</th><th>Issues Detected</th>'

  select 
     @headerRowStr = @headerRowStr + '<th>' + t2.[key] + '</th>' 
  from @exceptionData as t1
  CROSS APPLY OPENJSON(t1.rowData) as t2
  where (t1.idx = 1)

  set @headerRowStr = @headerRowStr + '</tr>'

  set @preImportAdditionalBadRowsRpt = '<table><thead><tr>' + @headerRowStr + '</tr></thead><tbody>'

  while (@curIdx <= @maxIdx)
  begin  
  
    declare @rowNumStr          as varchar(50)  = ''
    declare @rowSkippedStr      as varchar(50)  = ''
    declare @issuesDetectedStr  as varchar(max) = ''
    declare @rowDataStr         as varchar(max) = ''
  
    select top 1 
        @rowNumStr          = '<td>' + convert(varchar(50),t1.rowNum) + '</td>'
      , @rowSkippedStr      = '<td>' + iif( (t1.rowBad=1),'Yes','No') + '</td>'  
    from @exceptionData as t1
    where (t1.idx = @curIdx)
  
    select 
       @issuesDetectedStr = @issuesDetectedStr + ' ' + t2.[issueDetected] 
    from @exceptionData as t1
       CROSS APPLY OPENJSON(t1.validationMessages)
    WITH (
         columnLabel   varchar(max) '$."columnLabelOriginal"'
       , issueDetected varchar(max) '$."message"'
    ) as t2
    where (t1.idx = @curIdx)
  
    set @issuesDetectedStr = '<td>' + @issuesDetectedStr + '</td>'

    select 
       @rowDataStr = @rowDataStr + '<td>' + t2.[value] + '</td>' 
    from @exceptionData as t1
    CROSS APPLY OPENJSON(t1.rowData) as t2
    where (t1.idx = @curIdx)

    set @preImportAdditionalBadRowsRpt = @preImportAdditionalBadRowsRpt + '<tr>' + @rowNumStr + @rowSkippedStr + @issuesDetectedStr + @rowDataStr + '</tr>'
    set @curIdx = @curIdx + 1
  end

  set @preImportAdditionalBadRowsRpt = @preImportAdditionalBadRowsRpt + '</tbody></table></details>'
end /* hasAdditionalBadRowExceptions */

set @exceptionsRpt =  @basicStats + @preImportBadRowsRpt + @preImportAdditionalBadRowsRpt

return @exceptionsRpt


END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match_Generate_Pre_Import_Rpt_Html] TO [webuser]
GO
