USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED] (
    @clientID                bigint
  , @groupSvcClassNameID     bigint
  , @patID                   bigint
  , @orpDocID                bigint
  , @planInEffectStartDate   date
  , @planInEffectEndDate     date
  , @patHasBIC               bit
  , @patHasSSID              bit
  , @billableSvcs            bit
)   
RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS 
RETURN
(

/*============================================================
 * Prescribed Orders and Patient Profiles
 *===========================================================*/  

with
cte_p1
as
(
select 
    po.clientID
  , po.patID
  , orpDocID            = po.ORP_DOCUMENT_ID
  , groupSvcClassNameID = po.GROUP_SERVICE_CLASS_NAME_ID
  , spEdFreqCode        = po.frequency
  , minsPerFreq         = po.projectedMinutes
  , po.planStartDate
  , po.planEndDate

from dbo.SvcJournal_Prescribed_Orders as po
where ( 

      (1=1)
  
  /*[ORP_DOC_ID_IDX]*/
  
  and ((@orpDocID is null)            or (po.ORP_DOCUMENT_ID = @orpDocID))  
  
  /*[CLIENT_ID_PATID_EFF_DATE_IDX]*/
  
  and (((@clientID is null)           or (po.clientID = @clientID))
  and ((@groupSvcClassNameID is null) or (po.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
  and ((@patID is null)               or (po.patID = @patID)))   
  and (po.active = 1)
   /* (StartA <= EndB) and (EndA >= StartB) */
  and ((@planInEffectStartDate <= po.planEndDate) and (@planInEffectEndDate >= po.planStartDate))
)

union all

select 
    sd.clientID
  , sd.patID
  , orpDocID            = sd.ORP_DOCUMENT_ID
  , groupSvcClassNameID = sd.GROUP_SERVICE_CLASS_NAME_ID
  , spEdFreqCode        = sd.frequency
  , minsPerFreq         = sd.projectedMinutes
  , sd.planStartDate
  , sd.planEndDate
from dbo.SvcJournal_Service_Descriptions as sd
where ( 
  
      (1=1)
  
  /*[ORP_DOC_ID_IDX]*/
  
  and ((@orpDocID is null)            or (sd.ORP_DOCUMENT_ID = @orpDocID))  
  
  /*[CLIENT_ID_PATID_EFF_DATE_IDX]*/
  
  and (((@clientID is null)           or (sd.clientID = @clientID))
  and ((@groupSvcClassNameID is null) or (sd.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
  and ((@patID is null)               or (sd.patID = @patID))) 
  and (sd.active = 1)
   /* (StartA <= EndB) and (EndA >= StartB) */
  and ((@planInEffectStartDate <= sd.planEndDate) and (@planInEffectEndDate >= sd.planStartDate))
)
)
,
cte_p2
as
(
select 
    p1.* 
  , orpDocStandardSelectionNameID = ssn.ID
  , orpDocStandardSelectionName   = ssn.NAME
  , orpDocTypeID                  = od.ORP_DOCUMENT_TYPE_ID
  , orpDocRefID                   = od.REFERENCE_ID
  , patBIC                        = trim(isnull(pap.BIC,N''))
  , patSSID                       = trim(isnull(pap.CSIS,N''))
  , billableSvc                   = iif((pr.RATE_TMT > 0),1,0)
from cte_p1                                        as p1
join dbo.ORP_DOCUMENTS                             as od  on od.id = p1.orpDocID
join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES     as ssn on ssn.id = od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
join dbo.PATIENTS_Patient                          as pap on pap.PATIENT_ID = p1.patID
join dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr  on pr.GROUP_SERVICE_CLASS_NAME_ID = p1.groupSvcClassNameID

)
,
cte_p3
as
(
select
    p2.*
  , patHasBIC  = iif((p2.patBIC  !=N''),1,0)
  , patHasSSID = iif((p2.patSSID !=N''),1,0)
  , startDate             = p2.planStartDate
  , endDate               = p2.planEndDate
  , startDateTime         = convert(datetime,p2.planStartDate)
  , endDateTime           = convert(datetime,p2.planEndDate)
from cte_p2 as p2
)

select
    p3.clientID
  , p3.patID 
  , p3.patHasBIC
  , p3.patHasSSID
  , p3.groupSvcClassNameID  
  , p3.orpDocID
  , p3.orpDocStandardSelectionNameID 
  , p3.orpDocStandardSelectionName
  , p3.orpDocTypeID
  , p3.orpDocRefID
  , p3.spEdFreqCode
  , p3.minsPerFreq
  , p3.startDate
  , p3.endDate
  , p3.planStartDate
  , p3.planEndDate
  , p3.startDateTime
  , p3.endDateTime
  , p3.billableSvc
from cte_p3 as p3
where ( 
      (1=1)
  and ((@patHasBIC    is null) or (p3.patHasBIC   = @patHasBIC))
  and ((@patHasSSID   is null) or (p3.patHasSSID  = @patHasSSID))
  and ((@billableSvcs is null) or (p3.billableSvc = @billableSvcs))
)

)


GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_LATEST_DATA_NON_SPED] TO [webuser]
GO