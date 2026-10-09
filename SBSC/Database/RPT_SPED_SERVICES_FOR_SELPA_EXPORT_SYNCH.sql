USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH] (  
    @userID                bigint
  , @userGroup             int
  , @userRank              int
  , @clientID              int
  , @startDate             DATETIME  /* Pass current window start */
  , @endDate               DATETIME  /* Pass current window end */
  , @startEntryDate        DATETIME
  , @endEntryDate          DATETIME
)
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH */    
 /**    
  * Returns all active and deleted IEP/IFSP service records linked to CALPADS 
  * codes.  Also returns data that can be used to synch external databases to 
  * our data.  This is for cases where the SELPA wants to synch their records
  * with our records on a periodic basis.
  *    
  * @return                 Table of report rows
  ***************************************************************************/     
 
AS RETURN (

select top (dbo.CONST_MAX_ROWS())   
	  clientName       = clc.CLIENT_NAME
	, patSSID          = isnull(pap.CSIS,N'')
    , patNameLast      = trim(isnull(pap.LAST_NAME,N''))
	, patNameFirst     = trim(isnull(pap.FIRST_NAME,N''))
	, dos              = dbo.RPT_DATE_FMT(sr.dos)
	, pracNameLast     = trim(isnull(prc.LAST_NAME,N''))
	, pracNameFirst    = trim(isnull(prc.FIRST_NAME,N''))
	, svcName          = dbo.BUILD_FULL_SERVICE_NAME_STRING (snlds.id, cip.NAME, cnp.NAME, ccy.NAME, cru.NAME, null, null, null, null, sr.svcType, gg.GROUP_BASE, sr.hasSvcDetFlags, sr.svcDetFlag1, sr.svcDetFlag2, sr.svcDetFlag3 , sr.svcDetFlag4 )
	, calpadsCode      = calPads.calPadsCodeValueStr
    , minsSatisfied    = dbo.CALC_PROMISED_MINS_SATISFIED (sr.numMins, sr.patAbsent, sr.pracAbsent, sr.makeupSession, 1, sr.attendanceSelectionID)
    , attendanceStatus = sra2.attendanceStatusSelectionName 
	, svcRecID         = sr.id
	, svcRecStatus     = case 
	    when sr.state = 1         then 'New'
	    when sr.state in (99,199) then 'Deleted'
	    else 'Updated' 
	  end	
from      dbo.SERVICE_RECORDS            as sr    
join      dbo.CLIENTS_CLIENT             as clc   on clc.CLIENT_ID          = sr.clientID
join      dbo.PATIENTS_Patient           as pap   on pap.PATIENT_ID        = sr.patID     
join      dbo.PRACTITIONER_Practitioner  as prc   on prc.PRACTITIONER_ID   = sr.pracID  
join      dbo.GROUP_Group                as gg  on gg.GROUP_ID          = sr.groupID  

join      dbo.CLAIM_Svc_Names_List_Data_Sources as snlds on ((snlds.isIEPOrIFSP = sr.isIFSPorIEP) and (snlds.billingProgramID = sr.billingProgramID))

left join dbo.CLAIM_IEPandIFSPNames  as cip on cip.IEP_IFSP_NAME_ID  = sr.nameID
left join dbo.CLAIM_NoPlanNames      as cnp on cnp.NO_PLAN_NAME_ID   = sr.nameID 							 
left join dbo.CLAIM_CYBHI_Names      as ccy on ccy.CYBHI_NAME_ID     = sr.nameID
left join dbo.CLAIM_RU_HEALTH_NAMES  as cru on cru.RU_HEALTH_NAME_ID = sr.nameID

cross apply (
  select top 1 
    attendanceStatusSelectionName = sra1.[name] 
  from dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME (  sr.patAbsent, sr.pracAbsent, sr.makeupSession ) as sra1
) as sra2

cross apply (
  select top 1 
    calPadsCodeValueStr = iif(xref1.spEdSvcCodeValue=-1,'',convert(varchar(25),xref1.spEdSvcCodeValue)) 
  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as xref1
  where (
        (xref1.planTypeID  = sr.planType)
    and (xref1.groupID     = sr.groupID)
    and (xref1.nameID      = sr.nameID)
	and (xref1.hasClientID = 0)
    and (xref1.isStandard = 1)
	and (xref1.active = 1)
  )
) as calPads

/* Uses following index (that has had additional cols added) : [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS] */

where (    
      (sr.clientID = @clientID)
  and (sr.patID is not null)
  and (sr.pracGrpSvcClsNameID is not null)
  and (sr.svcType in (2,5))
  and (sr.dos between @startDate and @endDate)
  and (sr.id is not null)
  and (sr.isIFSPorIEP = 1)
  and ((sr.svcSubType1 is not null) and (sr.svcSubType1 not in (5000,5001)))
  and ((sr.created between @startEntryDate and @endEntryDate) or (sr.lastmodified between @startEntryDate and @endEntryDate))
)
order by 
    clc.CLIENT_NAME
  , pap.CSIS
  , pap.LAST_NAME
  , pap.FIRST_NAME
  , sr.dos

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_SPED_SERVICES_FOR_SELPA_EXPORT_SYNCH] TO [webuser]
GO