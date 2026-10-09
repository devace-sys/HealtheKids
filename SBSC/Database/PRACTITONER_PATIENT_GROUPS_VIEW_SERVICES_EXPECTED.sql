USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED]    
(@clientID   INT,
 @pracID     INT,
 @groupID    INT,
 @dos        DATETIME,
 @isIEP      BIT)    

RETURNS TABLE

 /***************************************************************************    
  * PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client. 
  * @param  pracID          Required.  ID of practitioner.    
  * @param  patID           Required.  ID of patient.
  * @param  startDate       Start of month.
  * @param  endDate         End of month
  * @return                 Table of expected service data   
  ***************************************************************************/     
  
AS RETURN
(

with


/*============================================================
 * Limits to a particular practitioners active groups 
 * and brackets start and end dates
 *============================================================*/  
 
cte_pptg
as
(
  select *
  from PRACTITIONER_PATIENT_TREATMENT_GROUPS as pptg    
  where 

  /*-------------------------------    
   * Limit to applicable groups
   *------------------------------*/  

      (pptg.clientID = @clientID)
  and (pptg.pracID   = @pracID) 
  and (pptg.id       = @groupID)
  
  /*-------------------------------    
   * Limit to applicable dates
   *------------------------------*/  

  and (@dos between pptg.startDate and dbo.DATE_OR_MIN_MAX(pptg.endDate,1))
  and (pptg.active = 1)
)
,

/*============================================================
 * Brackets effective dates
 *============================================================*/  

cte_pptgs
as
(
  select top 1 * 
  from PRACTITIONER_PATIENT_TREATMENT_GROUP_SERVICE_SCHEDULE as pptgs
  where 
    pptgs.treatmentGroupID = @groupID
    and @dos >= pptgs.effectiveDate
  order by
    effectiveDate desc, 
    id            desc

)
,
/*============================================================
 * Retrieve patient ids and estimated number of minutes
 *============================================================*/  

cte_pass_1
as
(
select  
 
 /*-------------------------------    
  * All patients in the group
  * in a recIDs string
  *------------------------------*/  
 
 patIDsStr,
 
 /*-------------------------------    
  * Pick the right day of week
  * slot based on dos passed in 
  *------------------------------*/  
 numMins as [numMin]
 
from cte_pptg     as pptg
join cte_pptgs    as pptgs on pptgs.treatmentGroupID = pptg.id

  
)
,

/*============================================================
 * Normalize patient ids
 *============================================================*/  

cte_pass_2
as
(
select 
*
from cte_pass_1 as t1
cross apply (
  select 
    id, 
    recID
  from dbo.MULTI_RECORD_ID_PARSE(t1.patIDsStr,',')
) as t2
)
,

/*============================================================
 * Bring in other ids and constant values (from arguments)
 *============================================================*/  
 
cte_pass_3
as
(
select 
  id        as [idx],
  @clientID as [clientID],
  @pracID   as [pracID],
  @groupID  as [patGroupID],
  recid     as [patID],    
  @dos      as [dos],    
  numMin    as [numMin] 
from cte_pass_2         
)
,

/*============================================================
 * Bring in names and calculate plan types
 *============================================================*/  

cte_pass_4
as
(
select 
  pgr.*,
  clc.CLIENT_NAME   as [clientName],
  prp.CONCAT_NAME   as [pracName],
  pdg.GROUP_ID      as [pracDispGroupID],
  pdg.groupName     as [pracGroupName],
  ppg.name          as [patGroupName],
  pap.CONCAT_NAME   as [patName],
  pap.DATE_OF_BIRTH as [patDOB],    
  dbo.DOS_DOB_IEP_TO_PLAN_TYPE(@dos, pap.DATE_OF_BIRTH, @isIEP) as [PatientPlanType]

from cte_pass_3                              as pgr  
join CLIENTS_Client                          as clc on clc.CLIENT_ID       = pgr.clientID
join PRACTITIONER_Practitioner               as prp on prp.PRACTITIONER_ID = pgr.pracID
join PATIENTS_Patient                        as pap on pap.PATIENT_ID      = pgr.patID
join PRACTITIONER_PATIENT_TREATMENT_GROUPS   as ppg on ppg.id              = pgr.patGroupID
join PRACTITIONER_GROUPS_VIEW_DISP()         as pdg on pdg.PRACTITIONER_ID = pgr.pracID
)
,

/*============================================================
 * Bring in service data and limit it to group treatments
 *============================================================*/  
 
cte_pass_5
as
(
select 
* 
from cte_pass_4 as sd1
cross apply
(
  select 
    name_id, 
    proc_id,
    svc_name,
    proc_name,
    svc,
    svc_type
    
  from SERVICES_VIEW_ALL()
  where 
    prac_group_id    = sd1.pracDispGroupID
      and plan_type  = sd1.PatientPlanType
      and is22       = 0
      
      /* Limits to group service treatment */
      
      and svc_type   = dbo.CONST_SERVICES_TREATMENT()      
      and lower(svc_name) like '%group%'     
       
  ) as sd2
)
,

/*============================================================
 * Limit columns
 *============================================================*/  

cte_pass_6
as
(
  select 
    patID, 
    patName, 
    name_id  as nameID, 
    svc_name as svcName,
    numMin 
  from cte_pass_5
)

/*============================================================
 * Return rows
 *============================================================*/  
 
select * from cte_pass_6

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITONER_PATIENT_GROUPS_VIEW_SERVICES_EXPECTED] TO [webuser]
GO
