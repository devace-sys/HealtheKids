USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STRUCTURED_DATA_IMPORT_GENERATE_EXCEPTION_RPT_HTML') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STRUCTURED_DATA_IMPORT_GENERATE_EXCEPTION_RPT_HTML
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.STRUCTURED_DATA_IMPORT_GENERATE_EXCEPTION_RPT_HTML (
  @importDataJSON as varchar(max)
)
     
RETURNS varchar(max)

AS 
BEGIN

set @importDataJSON = isnull(@importDataJson,'')
if (@importDataJSON = '') return ''

declare @exceptionsRpt  as varchar(max) = ''
declare @headerRowStr   as varchar(max) = ''
declare @minIdx         as bigint
declare @maxIdx         as bigint
declare @curIdx         as bigint

declare @exceptionData as table (
    idx                bigint identity(1,1)
  , rowBad             bit
  , optionalRowDataBad bit
  , rowNum             int
  , rowData            nvarchar(max)
  , validationMessages nvarchar(max)
)

insert into @exceptionData (
    rowBad             
  , optionalRowDataBad 
  , rowNum             
  , rowData            
  , validationMessages 
)

select
    t1.rowBad             
  , t1.optionalRowDataBad 
  , t1.rowNum             
  , t1.rowData            
  , t1.validationMessages 
FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' )
WITH (
        [rowBad]                bit               '$."rowBad"'
	  , [optionalRowDataBad]    bit               '$."optionalRowDataBad"'
      , [rowNum]                int               '$."rowNumIn"'
	  , [rowData]               nvarchar(max)     '$."rowData"'            as JSON
	  , [validationMessages]    nvarchar(max)     '$."validationMessages"' as JSON
) as t1
where ((t1.rowBad = 1) or (t1.optionalRowDataBad = 1))
  
select @minIdx=min(t1.idx), @maxIdx=max(t1.idx) from @exceptionData as t1
set @curIdx = @minIdx

set @headerRowStr = '<tr><th>Row #</th><th>Row Skipped</th><th>Issues Detected</th>'

select 
   @headerRowStr = @headerRowStr + '<th>' + t2.[key] + '</th>' 
from @exceptionData as t1
CROSS APPLY OPENJSON(t1.rowData) as t2
where (t1.idx = 1)

set @headerRowStr = @headerRowStr + '</tr>'

set @exceptionsRpt = '<table><thead><tr>' + @headerRowStr + '</tr></thead><tbody>'

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

  set @exceptionsRpt = @exceptionsRpt + '<tr>' + @rowNumStr + @rowSkippedStr + @issuesDetectedStr + @rowDataStr + '</tr>'
  set @curIdx = @curIdx + 1
end

set @exceptionsRpt = @exceptionsRpt + '</tbody></table>'

return @exceptionsRpt

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[STRUCTURED_DATA_IMPORT_GENERATE_EXCEPTION_RPT_HTML] TO [webuser]
GO
