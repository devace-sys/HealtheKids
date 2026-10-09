USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON (
      @svcLineIdx                 int
	, @doNotReport                bit
    , @fileID                     bigint
	, @fileRowID                  bigint
	, @hasEndDate                 bit
	, @duration                   int
	, @spEdLocationCode           int
	, @spEdProviderCode           int	
	, @individualSvc              bit
	, @groupSvc                   bit

	, @spEdDisabilityCode1        int
	, @spEdDisabilityCode2        int
	, @spEdSpecTransport          bit
	, @lastEvalDate               date
    , @lastAnnIEPDate             date
    , @nextAnnIEPDate             date
    , @exitedSpEdDate             date

	, @caseManagerName            varchar(256)
	, @additionalInfo             varchar(max)
    , @reportableToCDE            bit
	
	, @reportedStartDate          date
	, @reportedEndDate            date
) 
RETURNS varchar(max)

AS     
BEGIN 

declare @spEdLocationName     as varchar(256) = ''
declare @spEdProviderName     as varchar(256) = ''
declare @spEdDisabilityName1  as varchar(256) = ''
declare @spEdDisabilityName2  as varchar(256) = ''

select top 1 @spEdLocationName    = isnull([ssl].[name],'') from dbo.SpEd_Service_Location as [ssl] where ([ssl].codeValue = @spEdLocationCode)    option(recompile)
select top 1 @spEdProviderName    = isnull(ssp.[name],  '') from dbo.SpEd_Service_Provider as ssp   where (ssp.codeValue   = @spEdProviderCode)    option(recompile)
select top 1 @spEdDisabilityName1 = isnull(sdc.[name],  '') from dbo.SpEd_Disability_Codes as sdc   where (sdc.codeValue   = @spEdDisabilityCode1) option(recompile)
select top 1 @spEdDisabilityName2 = isnull(sdc.[name],  '') from dbo.SpEd_Disability_Codes as sdc   where (sdc.codeValue   = @spEdDisabilityCode2) option(recompile)

return
     '{'    
   + '"svcLineIdx":"'               + convert(varchar(50),@svcLineIdx)          + '"'
   + ',"doNotReport":"'             + dbo.BIT_TO_YN(@doNotReport)               + '"'  
   + ',"fileID":"'                  + convert(varchar(50),@fileID)              + '"'
   + ',"fileRowID":"'               + convert(varchar(50),@fileRowID)           + '"'
   + ',"hasEndDate":"'              + dbo.BIT_TO_YN(@hasEndDate)                + '"'
   + ',"duration":"'                + convert(varchar(50),@duration)            + '"'
   + ',"spEdLocationCode":"'        + convert(varchar(50),@spEdLocationCode)    + '"'
   + ',"spEdLocationName":"'        + STRING_ESCAPE(@spEdLocationName,'json')   + '"'
   + ',"spEdProviderCode":"'        + convert(varchar(50),@spEdProviderCode)    + '"'
   + ',"spEdProviderName":"'        + STRING_ESCAPE(@spEdProviderName,'json')   + '"'
   + ',"individualSvc":"'           + dbo.BIT_TO_YN(@individualSvc)             + '"'
   + ',"groupSvc":"'                + dbo.BIT_TO_YN(@groupSvc)                  + '"'

   + ',"spEdDisabilityCode1":"'     + convert(varchar(50),@spEdDisabilityCode1)   + '"'
   + ',"spEdDisabilityName1":"'     + STRING_ESCAPE(@spEdDisabilityName1,'json')  + '"'
   + ',"spEdDisabilityCode2":"'     + convert(varchar(50),@spEdDisabilityCode2)   + '"'
   + ',"spEdDisabilityName2":"'     + STRING_ESCAPE(@spEdDisabilityName2,'json')  + '"'
   + ',"spEdSpecTransport":"'       + dbo.BIT_TO_YN(@spEdSpecTransport)           + '"'
   + ',"lastEvalDate":"'            + dbo.RPT_DATE_FMT(@lastEvalDate)             + '"'
   + ',"lastAnnIEPDate":"'          + dbo.RPT_DATE_FMT(@lastAnnIEPDate)           + '"'
   + ',"nextAnnIEPDate":"'          + dbo.RPT_DATE_FMT(@nextAnnIEPDate)           + '"'
   + ',"exitedSpEdDate":"'          + dbo.RPT_DATE_FMT(@exitedSpEdDate)           + '"'

   + ',"caseManagerName":"'         + STRING_ESCAPE(@caseManagerName,'json')    + '"'
   + ',"additionalInfo":"'          + STRING_ESCAPE(@additionalInfo,'json')     + '"'
   + ',"reportableToCDE":"'         + dbo.BIT_TO_YN(@reportableToCDE)           + '"'   

   + ',"reportedStartDate":"'       + dbo.RPT_DATE_FMT(@reportedStartDate)      + '"'
   + ',"reportedEndDate":"'         + dbo.RPT_DATE_FMT(@reportedEndDate)        + '"'
  
   + '}'

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON] TO [webuser]
GO