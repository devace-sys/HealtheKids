USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_Generate_Manage_Sites_Rpt_Html') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Match_Generate_Manage_Sites_Rpt_Html
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION dbo.Patient_Data_Imports_Match_Generate_Manage_Sites_Rpt_Html (
    @manageSitesJSONData    as varchar(max)
)
     
RETURNS varchar(max)

AS 
BEGIN

declare @importStatistics as table (
    idx                bigint
  , label              varchar(512)
  , [name]             varchar(256)
  , [value]            varchar(max)
  , [returnStatus]     bigint
  , [forPCALStaffOnly] bit
)

declare @importExceptions as table (
    idx                bigint
  , label              varchar(512)
  , [name]             varchar(256)
  , [value]            varchar(max)
  , [returnStatus]     bigint
  , [forPCALStaffOnly] bit
)

insert into @importStatistics
select
    t1.idx
  , t1.label
  , t1.[name]
  , t1.[value]
  , t1.returnStatus
  , t1.forPCALStaffOnly
from OPENJSON( @manageSitesJSONData, '$.importStatistics' ) 
with (
          [idx]                bigint       '$."idx"'
	    , [label]              varchar(512) '$."label"'
	    , [name]               varchar(256) '$."name"'
	    , [value]              varchar(max) '$."value"'
	    , [returnStatus]       bigint       '$."returnStatus"'
		, [forPCALStaffOnly]   bit          '$."forPCALStaffOnly"'
) as t1

insert into @importExceptions
select
    t1.idx
  , t1.label
  , t1.[name]
  , t1.[value]
  , t1.returnStatus
  , t1.forPCALStaffOnly
from OPENJSON( @manageSitesJSONData, '$.importExceptions' ) 
with (
          [idx]                bigint       '$."idx"'
	    , [label]              varchar(512) '$."label"'
	    , [name]               varchar(256) '$."name"'
	    , [value]              varchar(max) '$."value"'
	    , [returnStatus]       bigint       '$."returnStatus"'
		, [forPCALStaffOnly]   bit          '$."forPCALStaffOnly"'
) as t1

declare @stats      as varchar(max) = ''
declare @exceptions as varchar(max) = ''

select 
  @stats = STRING_AGG (CONVERT(VARCHAR(max),('<tr><th>' + t1.label + '</th>' + '<td>' + t1.[value] + '</td></tr>')), '')  
from @importStatistics as t1

select 
  @exceptions = STRING_AGG (CONVERT(VARCHAR(max),('<tr><th>' + t1.label + '</th>' + '<td>' + t1.[value] + '</td></tr>')), '')  
from @importExceptions as t1

declare @rptHtml as varchar(max) = ''

set @rptHtml = '<details open><summary>Manage Sites - Statistics</summary>'
             + '<table><tbody>' + @stats + '</tbody></table></details>'
             + '<details><summary>Manage Sites - Exceptions</summary>'
			 + '<table><tbody>' + @exceptions + '</tbody></table></details>'

return @rptHtml

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match_Generate_Manage_Sites_Rpt_Html] TO [webuser]
GO
