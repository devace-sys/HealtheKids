USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core] (
    @clientID         bigint   = null
  , @patID            bigint   = null
  , @spEdSvcCode      int      = null
  , @startDate        datetime = null    /* Note: @startDate is for exact matches.  It is not a range. */
  , @importFileID     bigint   = null  
  , @importFileRowID  bigint   = null
  , @canUseRow        bit      = null
  , @minYear          int      = 1988
  , @maxYear          int      = 2100
) 

/***************************************************************************    
 * Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core */    
/**    
 *
 * This is the heart of parsing student data SpEd files into standardized    
 * data.  It returns sanitized and standardized data for each row in 
 * @importFileID.  
 *    
 ***************************************************************************/        

RETURNS TABLE
AS
RETURN
(

/*###########################################################################*/
/*# Pass 1                                                                  #*/
/*#                                                                         #*/
/*# - parse various raw fields                                              #*/
/*# - exclude rows for unmatched patients                                   #*/
/*# - exclude rows we marked as bad                                         #*/                                    
/*###########################################################################*/

with
cte_p1
as
(
  select     
	clientID            = a5f.client_id
  , fileID              = a5f.id
  , fileRowID           = a5fr.ID
  , patID               = a5fr.Patient_ID
  , spEdSvcCode         = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Code],               1)   /* Will be -1 if not found */
  , spEdFreqCode        = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Frequency],          2)   /* Will be -1 if not found */ 
  , spEdLocationCode    = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Location],           3)   /* Will be -1 if not found */ 
  , spEdProviderCode    = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Provider],           4)   /* Will be -1 if not found */ 
  , spEdDisabilityCode1 = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Disability 1 Code],  5)   /* Will be -1 if not found */ 
  , spEdDisabilityCode2 = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Disability 2 Code],  5)   /* Will be -1 if not found */ 
  , duration            = isnull(a5fr.[Total Minutes / Frequency],0)                                              /* 0 if null               */
  , startDate           = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[Start Date], @minYear, @maxYear)      /* Null if min or max value */
  , endDate             = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[End Date],   @minYear, @maxYear)      /* Null if min or max value */
  , deliveryCodes       = replace(upper(trim(isnull(a5fr.Delivery,'I'))),'|','')                                  /* Assume individual if nothing provided */
  , additionalInfo      = trim(trim(isnull(a5fr.CommentsOrAdditionalInfo1,'')) + ' ' + trim(isnull(a5fr.CommentsOrAdditionalInfo2,'')))
  , statusStr           = lower(trim(isnull(a5fr.[Status],'')))
  , doNotReport         = dbo.FLAG_STRING_TO_BIT(a5fr.[Marked DNR],1) 
  , lastEvalDate        = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[Date of Last Evaluation],@minYear,@maxYear)
  , lastAnnIEPDate      = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[Date of Last Annual IEP],@minYear,@maxYear)
  , nextAnnIEPDate      = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[Date of Next Annual IEP],@minYear,@maxYear)
  , spEdSpecTransport   = dbo.FLAG_STRING_TO_BIT(a5fr.[Special Transportation],1)
  , caseManagerName     = trim(isnull(a5fr.caseManagerName,''))
  , exitedSpEdDate      = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.exitedSpEdDate,@minYear,@maxYear)
  , dataFromSEIS        = convert(bit,(iif((isnull(a5fr.[SEIS ID],0) > 0),1,0)))

from [dbo].[Import_From_A.5_SERVICES_From_Client_Files]     as a5f
join [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] as a5fr on a5fr.File_import_log_entry = a5f.id
join dbo.PATIENTS_Patient                                   as pap  on pap.PATIENT_ID = a5fr.Patient_ID
join dbo.PATIENTS_Client                                    as pac  on ((pac.PATIENT_ID = pap.PATIENT_ID)
                                                                    and (pac.CLIENT_ID = @clientID))
where (	                
      ((a5f.client_id = @clientID)
  and ((@importFileID is null) or (a5f.id = @importFileID))
  and (a5f.canUseData = 1))   

  and ((@importFileRowID is null) or (a5fr.id = @importFileRowID))
  and ((@patID is null) or (a5fr.Patient_ID = @patID))
  
  and (a5fr.Patient_ID is not null) /* Only include rows where the patient could be matched */
  and (a5fr.active    = 1)          /* Dont include rows from original data we have marked as bad */
)

)
,

/*###########################################################################*/
/*# Pass 2                                                                  #*/
/*#                                                                         #*/
/*# - Exclude rows with missing svc codes, freq codes & start dates         #*/
/*# - Exclude rows with missing or invalid durations                        #*/
/*# - Make a note of missing end data (if any)                              #*/ 
/*# - Calculate placeholder end date if one was not provided                #*/                                    
/*# - Parse delivery codes                                                  #*/
/*# - Parse status field                                                    #*/
/*# - Get client preferences for svc code                                   #*/
/*# - Apply optional spEdSvc code filter                                    #*/
/*# - Apply optional start date filter                                      #*/
/*###########################################################################*/

cte_p2
as
(
select 
      p1.clientID
    , p1.fileID
	, p1.fileRowID 	
	, p1.patID   
    , p1.spEdSvcCode  
    , p1.spEdFreqCode  
    , p1.duration  
	
    , individualSvc = convert(bit, case 
        when (p1.deliveryCodes  = 'G')      then 0
        when (p1.deliveryCodes  = '2')      then 0
		when (p1.deliveryCodes  = '4')      then 0
		when (p1.deliveryCodes  = 'I')      then 1
        when (p1.deliveryCodes  = '1')      then 1
        when (p1.deliveryCodes  = 'IG')     then 1
		when (p1.deliveryCodes  = '3')      then 1
		when (p1.deliveryCodes like '%In%') then 1
        else 0
      end)

    , groupSvc = convert(bit,case 
        when (p1.deliveryCodes  = 'I')      then 0
        when (p1.deliveryCodes  = '1')      then 0
		when (p1.deliveryCodes  = '4')      then 0
		when (p1.deliveryCodes  = 'G')      then 1
        when (p1.deliveryCodes  = '2')      then 1
        when (p1.deliveryCodes  = 'IG')     then 1
		when (p1.deliveryCodes  = '3')      then 1
		when (p1.deliveryCodes like '%Gr%') then 1
        else 0
      end)

	, p1.startDate 
    , endDate                    = isnull(p1.endDate,(dateadd(year,1,p1.startDate)))	
	, hasEndDate                 = convert(bit,(iif((p1.endDate is null),0,1)))
	, p1.additionalInfo	
    , p1.spEdLocationCode
	, p1.spEdProviderCode
	, p1.spEdDisabilityCode1
	, p1.spEdDisabilityCode2
	, svcAmended                 = convert(bit,iif(p1.statusStr = 'amended',     1,0))
	, svcDiscontinued            = convert(bit,iif(p1.statusStr = 'discontinued',1,0))        
	, p1.doNotReport
	, p1.lastEvalDate
    , p1.lastAnnIEPDate 
    , p1.nextAnnIEPDate
    , p1.spEdSpecTransport 
    , p1.caseManagerName
    , p1.exitedSpEdDate
    , includeServiceAmmended               = convert(bit,(isnull(scr.includeServiceAmmended,    0)))
	, includeServiceDiscontinued           = convert(bit,(isnull(scr.includeServiceDiscontinued,0)))
	, includeDoNotReport                   = convert(bit,(isnull(scr.includeDoNotReport,        1)))
	, identifyUniqueSvcContractUseDuration = convert(bit,(isnull(scr.identifyUniqueSvcContractUseDuration,   0)))
    , identifyUniqueSvcContractUseIndGrp   = convert(bit,(isnull(scr.identifyUniqueSvcContractUseIndGrp,     0)))
	, p1.dataFromSEIS

  from cte_p1                                              as p1
  left join Client_SpEd_Service_Specific_Data_Import_Rules as scr on ((scr.clientID = p1.clientID) and (scr.spEdSvcCode = p1.spEdSvcCode))
  where ( 
        (p1.spEdSvcCode  != -1)
    and (p1.spEdFreqCode != -1)
	and (p1.duration > 0)
	and (p1.startDate is not null)
	and ((@spEdSvcCode is null) or (p1.spEdSvcCode = @spEdSvcCode))
	and ((@startDate is null) or (p1.startDate = @startDate))
  ) 
)  
,

/*###########################################################################*/
/*# Pass 3                                                                  #*/
/*#                                                                         #*/
/*# - Exclude rows with same start and end dates                            #*/
/*# - Exclude rows where end date is before the start date                  #*/                                    
/*# - Calculate if we can use a row based on status, DNR flag, and client   #*/
/*#   preference for status and DNR for svc code                            #*/
/*###########################################################################*/
  
cte_p3
as
(

select
    p2.*   
  , canUseRow = dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Determine_Can_Use (
      p2.includeServiceAmmended
	, p2.includeServiceDiscontinued
    , p2.includeDoNotReport
	, p2.svcAmended 
	, p2.svcDiscontinued
	, p2.doNotReport )
   
from cte_p2 as p2

where ( 
 (datediff(day,p2.startDate,p2.endDate) > 0) /* Eliminate same day svcs */  	  
)

)
,

/*###########################################################################*/
/*# Pass 4                                                                  #*/
/*#                                                                         #*/
/*# - Apply filter to exclude rows we cannot use                            #*/
/*# - Calc svcIDx (used for determining sub services)                       #*/
/*# - Calc svcLineIDx (used for determining sub services)                   #*/
/*###########################################################################*/

cte_p4
as
(
select 
  
    p3.*
  
  , svcIdx = DENSE_RANK() OVER   
      (PARTITION BY 
	      p3.clientID
		, p3.fileID
        , p3.patID
      ORDER BY 
          p3.spEdSvcCode
        , p3.startDate
        , p3.endDate
        , p3.spEdFreqCode
        --, iif((p3.identifyUniqueSvcContractUseDuration = 1), p3.duration,      0)
	    --, iif((p3.identifyUniqueSvcContractUseIndGrp   = 1), p3.individualSvc, 0)
		--, iif((p3.identifyUniqueSvcContractUseIndGrp   = 1), p3.groupSvc,      0)
	)

  , svcLineIdx = DENSE_RANK() OVER   
      (PARTITION BY 
	      p3.clientID
		, p3.fileID
        , p3.patID
        , p3.spEdSvcCode
        , p3.startDate
        , p3.endDate
        , p3.spEdFreqCode
		--, iif((p3.identifyUniqueSvcContractUseDuration = 1), p3.duration,      0)
	    --, iif((p3.identifyUniqueSvcContractUseIndGrp   = 1), p3.individualSvc, 0)
		--, iif((p3.identifyUniqueSvcContractUseIndGrp   = 1), p3.groupSvc,      0)
		
      ORDER BY 
	      p3.doNotReport asc
	    , p3.fileRowID   asc
	  )   
	
from cte_p3 as p3
where (     
      (1=1)
  and ((@canUseRow is null) or (p3.canUseRow = @canUseRow))
)
)

/*###########################################################################*/
/*# Output Pass                                                             #*/
/*# - Create reportableToCDE flag                                           #*/
/*###########################################################################*/

select 
   p4.*
 , reportableToCDE = convert(bit,(
                       iif ( (p4.dataFromSEIS = 1)
                            , 1 /* Per meeting with SpEd director from Alvord on 10/30/2023.  SEIS reports on DNR and non DNR */
                            , (iif((p4.doNotReport = 0),1,0)
					  ))))
from cte_p4 as p4

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Into_Detail_Rows_Core] TO [webuser]
GO   

