USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/    
    
CREATE FUNCTION [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE] (     
    @clientID            BIGINT
  , @planTypeID          BIGINT
  , @groupID             BIGINT
  , @nameID              BIGINT
  , @groupSvcClassNameID BIGINT
  , @hasClientID         BIT
  , @active              BIT 
  , @recID               BIGINT 
) 
RETURNS TABLE 
AS RETURN (      
with
cte_p1
as
(
select 
   csn.id
 , csn.planTypeID
 , planTypeName             = spt.PLAN_NAME
 , csn.groupID
 , groupName                = gg.GROUP_NAME
 , groupRequiresSupervision = dbo.IS_PRAC_GROUP_SUBJECT_TO_SUPERVISION(csn.groupID)
 , groupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
 , groupSvcClassName   = png.GROUP_SERVICE_CLASS_NAME
 , svcNameID           = csn.nameID
 , svcName             = coalesce(iep.NAME,npn.NAME,ccn.NAME,cru.NAME, N'Unknown')
 , csn.svcTypeId 
 , svcTypeName         = isnull(st1.SERVICE_TYPE_NAME,'')
 , csn.svcSubType1Id 
 , svcSubType1Name     = isnull(st2.SERVICE_TYPE_NAME,'')
 , csn.isStandard 
 , csn.hasFormData
 , csn.hasClientID
 , csn.formDataJson
 , csn.clientID
 , [clientName]        = isnull(clc.CLIENT_NAME,N'')
 , csn.active
 , csn.hasPatientGoalTracking
 , csn.hasSessionRatingTracking
 , spEdSvcCodeValue = isnull(csn.spEdSvcCodeValue,-1)
 , spEdSvcCodeName  = isnull(ss.name,'None')
 , fillablePdfSelectionsJSON = csn.fillablePdfSelectionsJSON

from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA                  as csn
join dbo.GROUP_Group                                            as gg  on gg.GROUP_ID      = csn.groupID
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100) 
                                                                       and (png.GROUP_ID = gg.GROUP_ID))

join dbo.CLAIM_PROCEDURES_SERVICE_PLAN_TYPES                    as spt on spt.PLAN_TYPE_ID = csn.planTypeID

left join dbo.CLAIM_Procedures_Service_Types   as st1  on st1.SERVICE_TYPE_ID = csn.svcTypeId
left join dbo.CLAIM_Procedures_Service_Types   as st2  on st2.SERVICE_TYPE_ID = csn.svcSubType1Id

left join dbo.CLAIM_IEPandIFSPNames            as iep  on  ((iep.IEP_IFSP_NAME_ID = csn.iepIfspNameId)
                                                       and  (csn.serviceNameIdIsInIfspIep = 1))
left join dbo.CLAIM_NoPlanNames                as npn  on  ((npn.NO_PLAN_NAME_ID = csn.noPlanNameID)
                                                       and  (csn.serviceNameIdIsInNoPlan = 1))

left join dbo.CLAIM_CYBHI_Names                as ccn  on ((ccn.CYBHI_NAME_ID = csn.cybhiNameId)
                                                       and (csn.serviceNameIdIsInCybhi = 1))

left join dbo.CLAIM_RU_HEALTH_NAMES            as cru on ((cru.RU_HEALTH_NAME_ID = csn.ruHealthNameID)
                                                      and (csn.serviceNameIdIsInRuHealth = 1))

left join dbo.CLIENTS_Client                   as clc on clc.CLIENT_ID = csn.clientID

left join dbo.SpEd_Service                     as ss  on ss.codeValue = csn.spEdSvcCodeValue

where (
      (1=1)
  and ((@recID               is null) or (csn.id                          = @recID))
  and ((@clientID            is null) or (csn.clientID                    = @clientID))
  and ((@planTypeID          is null) or (csn.planTypeID                  = @planTypeID))
  and ((@groupID             is null) or (csn.groupID                     = @groupID))
  and ((@nameID              is null) or (csn.nameID                      = @nameID))
  and ((@groupSvcClassNameID is null) or (png.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
  and ((@hasClientID         is null) or (csn.hasClientID                 = @hasClientID))
  and ((@active              is null) or (csn.active                      = @active))
)
)
select 
  p1.* 
, [svcNameWithCalpadsCode] = iif ( ((p1.svcName like '[0-9][0-9][0-9] - %') and (p1.spEdSvcCodeValue != -1))
                                    , p1.svcName
                                    , iif( (p1.spEdSvcCodeValue = -1)
					                , p1.svcName
					                , (convert(varchar(50),p1.spEdSvcCodeValue) + ' - ' + p1.svcName))
				               )
 , hasFillablePdfSelections = convert(bit,(iif (p1.fillablePdfSelectionsJSON != '[]',1,0)))

from cte_p1 as p1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA_VIEW_CORE] TO [webuser]
GO