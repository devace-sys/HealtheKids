USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON (
   @svcLinesDetailsJSON varchar(max)
) 
RETURNS 
table
AS     
return
(
  select 
      t2.*
	, deliverySummary = dbo.RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL(t2.individualSvc, t2.groupSvc)
  from
  (
    select
       svcLineIdx          = convert(int,t1.svcLineIdx)
     , doNotReport         = dbo.YN_TO_BIT(t1.doNotReport)
     , fileID              = convert(bigint,t1.fileID)
     , fileRowID           = convert(bigint,t1.fileRowID)
     , hasEndDate          = dbo.YN_TO_BIT(t1.hasEndDate)
     , duration            = convert(int,t1.duration)
     , spEdLocationCode    = convert(int,t1.spEdLocationCode)
     , spEdLocationName    = t1.spEdLocationName
     , individualSvc       = dbo.YN_TO_BIT(t1.individualSvc)
     , groupSvc            = dbo.YN_TO_BIT(t1.groupSvc)
     , spEdProviderCode    = convert(int,t1.spEdProviderCode)
     , spEdProviderName    = t1.spEdProviderName
     
	 , spEdDisabilityCode1 = convert(int,t1.spEdDisabilityCode1)
     , spEdDisabilityName1 = t1.spEdDisabilityName1
	 , spEdDisabilityCode2 = convert(int,t1.spEdDisabilityCode2)
     , spEdDisabilityName2 = t1.spEdDisabilityName2
	 , spEdSpecTransport   = dbo.YN_TO_BIT(t1.spEdSpecTransport)
     , lastEvalDate        = dbo.RPT_DATE_FMT_STR_TO_DATE(t1.lastEvalDate)
	 , lastAnnIEPDate      = dbo.RPT_DATE_FMT_STR_TO_DATE(t1.lastAnnIEPDate)
	 , nextAnnIEPDate      = dbo.RPT_DATE_FMT_STR_TO_DATE(t1.nextAnnIEPDate)
	 , exitedSpEdDate      = dbo.RPT_DATE_FMT_STR_TO_DATE(t1.exitedSpEdDate)

	 , caseManagerName     = t1.caseManagerName
     , additionalInfo      = t1.additionalInfo
     , reportableToCDE     = dbo.YN_TO_BIT(t1.reportableToCDE)
	 , reportedStartDate   = dbo.RPT_DATE_FMT_STR_TO_DATE(t1.reportedStartDate)
	 , reportedEndDate     = dbo.RPT_DATE_FMT_STR_TO_DATE(t1.reportedEndDate)

    FROM OPENJSON(@svcLinesDetailsJSON) 
    WITH (
         svcLineIdx           varchar(50)  '$."svcLineIdx"'
	   , doNotReport          varchar(50)  '$."doNotReport"'
	   , fileID               varchar(50)  '$."fileID"'
	   , fileRowID            varchar(50)  '$."fileRowID"'
       , hasEndDate           varchar(50)  '$."hasEndDate"'
       , duration             varchar(50)  '$."duration"'
       , spEdLocationCode     varchar(50)  '$."spEdLocationCode"'
	   , spEdLocationName     varchar(256) '$."spEdLocationName"'
       , spEdProviderCode     varchar(50)  '$."spEdProviderCode"'
	   , spEdProviderName     varchar(256) '$."spEdProviderName"'
	   , individualSvc        varchar(50)  '$."individualSvc"'
	   , groupSvc             varchar(50)  '$."groupSvc"'

	   , spEdDisabilityCode1  varchar(50)  '$."spEdDisabilityCode1"'
       , spEdDisabilityName1  varchar(256) '$."spEdDisabilityName1"'
	   , spEdDisabilityCode2  varchar(50)  '$."spEdDisabilityCode2"'
       , spEdDisabilityName2  varchar(256) '$."spEdDisabilityName2"'
	   , spEdSpecTransport    varchar(50)  '$."spEdSpecTransport"'      
	   , lastEvalDate         varchar(50)  '$."lastEvalDate"'
	   , lastAnnIEPDate       varchar(50)  '$."lastAnnIEPDate"'
	   , nextAnnIEPDate       varchar(50)  '$."nextAnnIEPDate"'
	   , exitedSpEdDate       varchar(50)  '$."exitedSpEdDate"'

       , caseManagerName      varchar(256) '$."caseManagerName"'
       , additionalInfo       varchar(max) '$."additionalInfo"'   
       , reportableToCDE      varchar(50)  '$."reportableToCDE"'
	   , reportedStartDate    varchar(50)  '$."reportedStartDate"'
	   , reportedEndDate      varchar(50)  '$."reportedEndDate"'
    ) as t1
  ) as t2
)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT select ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON] TO [webuser]
GO