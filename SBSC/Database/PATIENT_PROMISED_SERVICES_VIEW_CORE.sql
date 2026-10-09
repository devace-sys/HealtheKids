USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_VIEW_CORE] (
    @clientID              bigint     
  , @patID                 bigint
  , @spEdServiceCode       int
  , @term				   VARCHAR(50)
  , @refDate               date 
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
  , @today                 datetime
)
    
returns table     
as
 
return 
(    
with
cte_p0
as
(

  select 
      pps.*
    
	, clientID                 = pc.CLIENT_ID

    /* Service */

	, spEdServiceCodeStr       = (convert(varchar,pss.codeValue))
	, spEdServiceName          = pss.[name]

	/* Frequency */

	, spEdFreqCodeStr          = (convert(varchar,pssf.codeValue))
	, spEdFreqName             =  pssf.[name]
	, spEdFreqDef              =  pssf.[definition]

	/* Provider */

 	, spEdProviderCodeStr      = (convert(varchar,pssp.codeValue))
    , spEdProviderName         = (pssp.[name])

	/* Location */

	, spEdLocationCodeStr      = convert(varchar,pssl.codeValue)
	, spEdLocationName         = (pssl.[name])
    
	/* Dates */

    , startDateStr             = dbo.RPT_DATE_FMT(pps.startDate)
    , endDateStr               = dbo.RPT_DATE_FMT(pps.endDate)
	, startDateYYYYMMDD        = dbo.RPT_DATE_FMT_YYYY_MM_DD(pps.startDate)
	, endDateYYYYMMDD          = dbo.RPT_DATE_FMT_YYYY_MM_DD(pps.endDate)

	/* Ind / Group */

    , individualDeliveryStr    = dbo.RPT_BIT_TO_YN (pps.individualDelivery)
    , groupDeliveryStr         = dbo.RPT_BIT_TO_YN (pps.groupDelivery)	
	, deliverySummary          = dbo.RPT_DELIVERY_IND_GRP_FLAGS_TO_LABEL (pps.individualDelivery, pps.groupDelivery)
	
	/* Session based */     

    , sessionBasedStr          = dbo.RPT_BIT_TO_YN(pps.sessionBased)

    /* Duration */

	, minsPerFreqStr           = convert(varchar(50),pps.minsPerFreq)
  
    /* Svc lines */

    , hasSvcLinesDetailsStr = dbo.RPT_BIT_TO_YN(pps.hasSvcLinesDetails)
    , numSvcLinesStr        = convert(varchar(50),pps.numSvcLines)

	, startDateRelativeStr = dbo.CALC_HUMAN_FRIENDLY_RELATIVE_DATE(pps.startDate,@today)

  from  dbo.PATIENTS_Client              as pc   
  join  dbo.PATIENTS_Promised_Services   as pps  on  pps.patID      = pc.PATIENT_ID
  join  dbo.SpEd_Service                 as pss  on  pss.codeValue  = pps.spEdServiceCode
  join  dbo.SpEd_Service_Provider        as pssp on  pssp.codeValue = pps.spEdProviderCode
  join  dbo.SpEd_Service_Frequency       as pssf on  pssf.codeValue = pps.spEdFreqCode
  join  dbo.SpEd_Service_Location        as pssl on  pssl.codeValue = pps.spEdLocationCode

  where (
        (1=1)
    and ((@clientID is null) or (pc.CLIENT_ID  = @clientID))
    and ((@patID    is null) or (pc.PATIENT_ID = @patID))

    /* Uses [PAT_ID_IDX] index */
	and ((@patID           is null) or (pps.patID           = @patID))
    and ((@spEdServiceCode is null) or (pps.spEdServiceCode = @spEdServiceCode))
    and ((@active          is null) or (pps.active          = @active))
    and ((@recID           is null) or (pps.id              = @recID))

	and ((@refDate  is null) or (pps.endDate >= @refDate))
  )
)
,
cte_p1
as
(
select 
    p0.* 
 , [name]                   = (p0.spEdServiceCodeStr  + ' ' + p0.spEdServiceName)    
 , spEdServiceCodeAndName   = (p0.spEdServiceCodeStr  + ' ' + p0.spEdServiceName)
 , spEdProviderCodeAndName  = (p0.spEdProviderCodeStr + ' ' + p0.spEdProviderName)
 , spEdFreqCodeAndName      = (p0.spEdFreqCodeStr     + ' ' + p0.spEdFreqDef)
 , spEdFreqCodeAndNameShort = (p0.spEdFreqCodeStr     + ' ' + p0.spEdFreqName)    
 , spEdLocationCodeAndName  = (p0.spEdLocationCodeStr + ' ' + p0.spEdLocationName)
 
from cte_p0 as p0

)
,
cte_p2
as
(
  select 
      p1.* 
	, ppsecd2.* 

    , selContextHTML = p1.startDateStr  /* Date range*/+ 
					 + ' to ' 
					 + p1.endDateStr 
                     + ' - '

					 /* Group/Individual label (if available) */
					 
					 + p1.deliverySummary + ' - '
						   
					 /* Minutes for service or total minutes if this is a multi line svc */

					 + p1.minsPerFreqStr 
					 + ' '
					 + iif( (p1.numSvcLines = 1)
					       , 'Minutes'
						   , 'Combined Minutes')
					 + ' - '
                      
                     /* Frequency */

					 + p1.spEdFreqName
					 + ' - '
					 + 'Plan start date is approximately ' + startDateRelativeStr
					 					 
  from cte_p1 as p1

  outer apply (
    select top 1 
        replacementDataActive = ppsecd1.active
	  , ppsecd1.replacementSpEdServiceCode
	  , replacementSpEdServiceCodeAndName = ppsecss.[name]
      , ppsecd1.replacementSpEdFreqCode
	  , replacementSpEdFreqCodeAndName = ppsecsf.[name]
      , ppsecd1.replacementMinsPerFreq
    from      dbo.PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data as ppsecd1
	left join dbo.SpEd_Service                                               as ppsecss on ppsecss.codeValue = ppsecd1.replacementSpEdServiceCode
	left join dbo.SpEd_Service_Frequency                                     as ppsecsf on ppsecsf.codeValue = ppsecd1.replacementSpEdFreqCode

    where ( 
	      (ppsecd1.patID                   = p1.patID)
	  and (ppsecd1.originalSpEdServiceCode = p1.spEdServiceCode)
	  and (ppsecd1.originalStartDate       = p1.startDate)
	  and (ppsecd1.originalSpEdFreqCode    = p1.spEdFreqCode)
	  and (ppsecd1.originalMinsPerFreq     = p1.minsPerFreq)
	)
  ) as ppsecd2

  where ( 
        (1=1)
    and ((@term is null) or (p1.spEdServiceCodeAndName like '%' + @term + '%'))
  )

)
select 
    p2.*
from cte_p2 as p2 
 
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_VIEW_CORE] TO [webuser]
GO