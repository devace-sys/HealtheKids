USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_NON_ORP_COMPLIANT_SVCS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_NON_ORP_COMPLIANT_SVCS
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_NON_ORP_COMPLIANT_SVCS] ( )
 
RETURNS TABLE
 
 /***************************************************************************    
  * RPT_NON_ORP_COMPLIANT_SVCS */    
 /**    
  * Returns a table of report rows
  *    
  ***************************************************************************/     
 
AS RETURN (

with
cte_p1
as
(
  select 
      isnull(ccr.first_name,'') 
    + ' ' 
    + isnull(ccr.last_name,'')                 as [Rep]
  , clc.CLIENT_NAME                            as [Client]  
  , dbo.RPT_DATE_FMT(sr.dos)                   as [Service Date]
  , gg.GROUP_BASE                              as [Group]
  , prp.CONCAT_NAME                            as [Practitioner]
  , pap.CONCAT_NAME                            as [Patient]    
  , vs.SERVICE_NAME                            as [Service]
  , sr.numMins                                 as [Mins]
  , u.UserName                                 as [Entered By]
  , dbo.RPT_DATE_FMT(coalesce( sr.lastmodified
                              ,sr.created))    as [Last Modified]
  
   , [Orp Compliance Status] = dbo.RPT_DETERMINE_ORP_STATUS (  sr.orpRequired
                                                             , sr.orpDocID
                                                             , sr.orpPracID
                                                             , sr.orpPracNPI
                                                             , sr.orpValidMcalOrp )

  , [DOS]                = sr.dos
  , [BIC]                = ltrim(rtrim(isnull(pap.BIC,'')))
  , [PPC_MCAL]           = isnull(pap.parentConsentMCAL,clc.parentConsentAgreement)
  , [SpEdCare Record ID] = sr.id

from dbo.CLIENTS_CLIENT             as clc 
join dbo.PRACTITIONER_Client        as prc on  prc.CLIENT_ID       = clc.CLIENT_ID
join dbo.PATIENTS_Client            as pac on  pac.CLIENT_ID       = clc.CLIENT_ID
join dbo.PRACTITIONER_Practitioner  as prp on  prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PATIENTS_Patient           as pap on  pap.PATIENT_ID      = pac.PATIENT_ID

join dbo.SERVICE_RECORDS            as sr  on  sr.clientID = pac.CLIENT_ID
                                           and sr.pracID   = prp.PRACTITIONER_ID
                                           and sr.patID    = pap.PATIENT_ID
                                           and sr.dos >= dbo.CONST_ORP_DOCUMENTATION_FOR_TREATMENT_REQUIRED_START_DATE()                                                 

join dbo.SERVICE_RECORD_CLAIMS      as src on src.svcRecID = sr.id
join dbo.GROUP_Group                as gg   on gg.GROUP_ID = sr.groupID
join users.dbo.Users                as  u   on u.userrid   = sr.userID

left join dbo.CLIENTS_Client_Reps	as  ccr on ccr.id = clc.ClientRepIDLEACurrent


cross apply (
    select top 1 * from dbo.SERVICE_NAME_LOOKUP (  sr.planType
                                                 , sr.svcType
                                                 , sr.nameID
                                                 , sr.nameIDAliasID
                                                 , sr.dos
                                                 , sr.groupID
                                                 , sr.hasSvcDetFlags
                                                 , sr.svcDetFlag1
                                                 , sr.svcDetFlag2
                                                 , sr.svcDetFlag3
                                                 , sr.svcDetFlag4 ) as vr 
) as vs  

where (
        (clc.CLIENT_ID != 112)
    and (clc.LEA = 1)
    and (prp.SUBMIT_CLAIMS = 1)
    and (pap.SUBMIT_CLAIMS = 1)       
    and (sr.svcType = 2)  
    and (sr.state not in (99,199))
    and (sr.patAbsent = 0)
    and (sr.orpRequired = 1)
    and ((sr.orpValidMcalOrp = 0) or (sr.orpValidMcalOrp is null))
  )
)
,
cte_p2
as
(
  select distinct * from cte_p1 where (([BIC] != '') and (PPC_MCAL = 1))
)

select top (5000)

    [Rep]
  , [Client]
  , [Service Date]
  , [Group]
  , [Practitioner]
  , [Patient]
  , [Service]
  , [Mins]
  , [Entered By]
  , [Last Modified]
  , [ORP Compliance Status]
  , [SpEdCare Record ID] 
from cte_p2

order by
    [Rep]
  , [Client]
  , [DOS]
  , [Group]
  , [Practitioner]
  , [Patient]

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_NON_ORP_COMPLIANT_SVCS] TO [webuser]
GO