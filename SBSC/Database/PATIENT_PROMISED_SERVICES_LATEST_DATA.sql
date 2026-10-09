USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_LATEST_DATA] (
    @clientID                bigint /* Required */
  , @patID                   bigint 
  , @spEdServiceCode         int    /* Original sped service code */
  , @startDate               date   /* Exact date not range */
  , @endDate                 date   /* Exact date not range */
  , @spEdFreqCode            int    /* Original or replacement freq code */
  , @minsPerFreq             int    /* Original or replacement mins per freq */
  , @planInEffectStartDate   date   /* Date range */
  , @planInEffectEndDate     date   /* Date range */
  , @patHasBIC               bit
  , @patHasSSID              bit
)   
RETURNS TABLE

 /***************************************************************************    
  * PATIENT_PROMISED_SERVICES_LATEST_DATA */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
RETURN
(

with
cte_p1
as
(
  select  
      patID              = pap.PATIENT_ID    
	, patHasBic          = ppe2.isElig
	, patHasSSID         = convert(bit,(iif(trim(isnull(pap.CSIS,N'')) = N'',0,1)))	
	, spEdExitedSpEdDate = pap.spEdExitedSpEdDate    /* If this data ia not correct, reprocess the promised service data by replacing min max with null */
  from dbo.PATIENTS_Client            as pc
  join dbo.PATIENTS_Patient           as pap on pap.PATIENT_ID = pc.PATIENT_ID
  
  cross apply (
	select top 1 
	  ppe1.isElig 
	from dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG_AS_ROW (pap.BIC, pap.ffpQualified) as ppe1 /* This is the results of a calculation returned as a row */
  ) as ppe2

  where ( 
        (pc.CLIENT_ID = @clientID)
    and ((@patID is null) or (pap.PATIENT_ID = @patID))
  )
)
,
cte_p2
as
(
  select  
      pps.patID
	, p1.patHasBIC
	, p1.patHasSSID
	, p1.spEdExitedSpEdDate
    , spEdServiceCode  = coalesce(ppsecd1.replacementSpEdServiceCode, pps.spEdServiceCode)
    , spEdFreqCode     = coalesce(ppsecd1.replacementSpEdFreqCode,    pps.spEdFreqCode)
	, minsPerFreq      = coalesce(ppsecd1.replacementMinsPerFreq,     pps.minsPerFreq)
	, pps.startDate
    , pps.endDate
    , ppsID = pps.id
    , pps.latestFileRowID
	, pps.numSvcLines
    , pps.hasSvcLinesDetails
	, pps.svcLinesDetailsJSON
  
  from cte_p1                         as p1
  
  join dbo.PATIENTS_Promised_Services as pps on (
      (pps.patID = p1.patID) 
  and (pps.spEdServiceCode > 0) 
  and (pps.active = 1) 
  and (pps.id > 0)
  ) /* Uses index [PAT_ID_IDX]*/
  
  /* Use replacement values to correct data entry error in imported spEd data if applicable */

  outer apply (

    select top 1 
	    ppsecd1.replacementSpEdServiceCode
      , ppsecd1.replacementSpEdFreqCode
      , ppsecd1.replacementMinsPerFreq

    from dbo.PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data as ppsecd1
	
	where ( 
	      (ppsecd1.patID                   = pps.patID)
	  and (ppsecd1.originalSpEdServiceCode = pps.spEdServiceCode)
	  and (ppsecd1.originalStartDate       = pps.startDate)
	  and (ppsecd1.originalSpEdFreqCode    = pps.spEdFreqCode)
	  and (ppsecd1.originalMinsPerFreq     = pps.minsPerFreq)
	  and (ppsecd1.active = 1)
	)
  ) as ppsecd1
  
  where (
        (1=1)
    and ((@patHasBIC       is null) or (p1.patHasBIC        = @patHasBIC))
    and ((@patHasSSID      is null) or (p1.patHasSSID       = @patHasSSID))	
    and ((@spEdServiceCode is null) or (pps.spEdServiceCode = @spEdServiceCode))
	and ((@startDate       is null) or (pps.startDate       = @startDate))
	and ((@endDate         is null) or (pps.endDate         = @endDate))

    /* (StartA <= EndB) and (EndA >= StartB) */	
	and ((@planInEffectStartDate <= pps.endDate) and (@planInEffectEndDate >= pps.startDate))

  )
)
select 
    clientID = @clientID
  , p2.patID
  , p2.patHasBIC
  , p2.patHasSSID
  , p2.spEdExitedSpEdDate
  , p2.spEdServiceCode
  , p2.spEdFreqCode
  , p2.minsPerFreq
  , p2.startDate
  , p2.endDate
  , p2.ppsID
  , p2.latestFileRowID
  , p2.numSvcLines
  , p2.hasSvcLinesDetails
  , p2.svcLinesDetailsJSON
  , isNonPeriodicPlan = convert(bit,iif((p2.spEdFreqCode not in (10,20,30)),1,0))
from cte_p2 as p2
where (
        (1=1) 
   
   /* These filters are here so we can use the replacement data if neccessary */
   
   and ((@spEdFreqCode    is null) or (p2.spEdFreqCode    = @spEdFreqCode))
   and ((@minsPerFreq     is null) or (p2.minsPerFreq     = @minsPerFreq))
)
)

GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_LATEST_DATA] TO [webuser]
GO