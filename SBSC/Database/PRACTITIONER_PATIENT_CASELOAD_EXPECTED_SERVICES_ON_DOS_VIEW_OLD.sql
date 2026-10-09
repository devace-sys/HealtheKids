USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW_OLD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW_OLD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW_OLD] (
   @userID          BIGINT    
 , @userGroup       BIGINT    
 , @userRank        BIGINT
 , @clientID        BIGINT
 , @pracID          BIGINT
 , @dos             DATETIME 
 , @pracPatGroupID  BIGINT
)    

RETURNS 
@recs table (
    id                      bigint identity(1,1)
  , patID                   bigint  
  , patName                 nvarchar(100)
  , dos                     datetime
  , dosStr                  varchar(50)
  , numMins                 int
  , svcTypeID               int /* 2 */
  , svcSubTypeID            int /* 2000 = Individual, 2001 = Group */
  , planTypeSelectionID     int /* 1= IEP or IFSP,  2= Other */
  , internalPlanTypeID      int
  , planIsIEPIFSP           bit
  , serviceNameID           bigint
  , serviceName             nvarchar(100)
  , orpRequired             bit
  , orpDocumentID           bigint  
  , orpDocumentName         varchar(255)
  , orpDocTypeID            bigint /* This is a bigint not int */
  , orpDocSelectionRequired bit
  , pracID                  bigint
  , groupID                 bigint
  , svcTrackingClass        int
  , spEdServiceCode         int
)
BEGIN

 /***************************************************************************    
  * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW_OLD */    
 /**    
  * 
  * @return Table of expected service data   
  ***************************************************************************/     

/*============================================================
 * Exit if required parameters are not passed
 *============================================================*/

if (@clientID is null) return
if (@pracID   is null) return

declare @dow    as int
declare @dosStr as varchar(50)

declare @expectedSvcData as table (
    clientID                  bigint
  , pracID                    bigint
  , groupID                   bigint
  , patID                     bigint 
  , patName                   nvarchar(100) 
  , expectedMinsInd           int
  , expectedMinsGrp           int
  , isIEPorIFSP               bit
  , svcTrackingClass          int
  , spEdServiceCode           int
  , orpDocID                  bigint
  , planSelection             int
  , planTypeID                int
  , indSvcOnDOS               bit
  , grpSvcOnDOS               bit

  , ssIndSvcTypeId            int
  , ssIndSvcSubType1Id        int
  , ssGrpSvcTypeId            int
  , ssGrpSvcSubType1Id        int
  , viaTelehealth             bit default(0)
  , indSvcNameID              bigint
  , indSvcTypeID              int 
  , indSvcSubTypeID           int 
  , indSvcName                nvarchar(100)

  , grpSvcNameID              bigint
  , grpSvcTypeID              int 
  , grpSvcSubTypeID           int 
  , grpSvcName                nvarchar(100)
  
  , orpRequired               bit
  , orpDocumentID             bigint  
  , orpDocumentName           varchar(255)
  , orpDocTypeID              bigint /* This is a bigint not int */
  , orpDocSelectionRequired   bit
)


/*============================================================
 * Default to todays date
 *============================================================*/

if (@dos is null) set @dos = getdate()

/*============================================================
 * Standardize day of week number (insulating us against datefirst
 * changes).  Sunday will always be 0 and Saturday will always be 6
 * Days between will be 1-5. 
 * Courtesey of https://stackoverflow.com/a/1113891 see comment
 * by https://stackoverflow.com/users/196451/endy-tjahjono 
 *============================================================*/

set @dow = dbo.CALC_STANDARD_DAY_OF_WEEK_NUMBER(@dos)

/*============================================================
 * If day of week is Sunday or Saturday, exit
 *============================================================*/

if (@dow in (0,6)) return

/*============================================================
 * Generate HTML5 friendly string version of date 
 *============================================================*/

set @dosStr = dbo.RPT_DATE_FMT_YYYY_MM_DD(@dos)

/*============================================================
 * Get expected service data
 *============================================================*/

;with
cte_p1
as
(
select
    clientID                     = ppc.clientID
  , pracID                       = ppc.pracID
  , groupID                      = pg.GROUP_ID
  , patID                        = ppc.patID
  , patName                      = pap.CONCAT_NAME
  , patDOB                       = pap.DATE_OF_BIRTH
  , expectedMinsInd              = isnull(ppces.expectedMinsInd,0)
  , expectedMinsGrp              = isnull(ppces.expectedMinsGrp,0)
  , isIEPorIFSP                  = iif((isnull(ppces.planType,1)=1),1,0)
  , daysOfWeekSvcProvidedJSON    = convert(nvarchar(max),isnull(ppces.daysOfWeekSvcProvidedJSON,'{}')) 
  , planSelection                = ppces.planType
  , ppces.svcTrackingClass
  , ppces.spEdServiceCode
  , ppces.orpDocID

  , ssIndSvcTypeId      = ssd.indSvcTypeId
  , ssIndSvcSubType1Id  = ssd.indSvcSubType1Id 
  , ssGrpSvcTypeId      = ssd.grpSvcTypeId 
  , ssGrpSvcSubType1Id  = ssd.grpSvcSubType1Id 
  
from dbo.PRACTITIONER_PATIENT_CASELOAD                     as ppc
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES   as ppces on ppces.caseloadEntryID = ppc.id
join dbo.PATIENTS_Patient                                  as pap   on pap.PATIENT_ID        = ppc.patID
join dbo.PRACTITIONER_GROUPS                               as pg    on ((pg.PRACTITIONER_ID  = ppc.pracID) and (pg.GROUP_TYPE in (1,2)))
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png   on  ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
                                                                    and (png.GROUP_ID = pg.GROUP_ID)
                                                                    and (png.GROUP_SERVICE_CLASS_NAME_ID is not null))

join dbo.PRACTITIONER_PATIENT_CASELOAD_DEFAULT_SCHEDULED_SERVICE_SELECTION_DATA as ssd on ssd.groupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID

where (
        (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
    and (ppc.patID is not null)
    and (ppc.id is not null)
	and (ppces.active = 1)
)
)
,
cte_p2
as
(
select 
    p1.* 
  , planTypeID  = dbo.DOS_DOB_IEP_TO_PLAN_TYPE (@dos, p1.patDOB, p1.isIEPorIFSP)  
  , indSvcOnDos = dbo.PRACTITIONER_CASELOAD_IS_SVC_SCHEDULED_ON_DOW(p1.daysOfWeekSvcProvidedJSON,2,2000,@dow)
  , grpSvcOnDos = dbo.PRACTITIONER_CASELOAD_IS_SVC_SCHEDULED_ON_DOW(p1.daysOfWeekSvcProvidedJSON,2,2001,@dow)
from cte_p1 as p1
)

insert into @expectedSvcData (
    clientID
  , pracID  
  , groupID 
  , patID   
  , patName
  , expectedMinsInd
  , expectedMinsGrp
  , isIEPorIFSP    
  , svcTrackingClass
  , spEdServiceCode 
  , orpDocID  
  , planSelection
  , planTypeID 
  , indSvcOnDOS
  , grpSvcOnDOS
  , ssIndSvcTypeId 
  , ssIndSvcSubType1Id
  , ssGrpSvcTypeId    
  , ssGrpSvcSubType1Id 
)

select 
    clientID
  , pracID  
  , groupID 
  , patID  
  , patName 
  , expectedMinsInd
  , expectedMinsGrp
  , isIEPorIFSP    
  , svcTrackingClass
  , spEdServiceCode 
  , orpDocID  
  , planSelection
  , planTypeID 
  , indSvcOnDos 
  , grpSvcOnDos 
  , ssIndSvcTypeId 
  , ssIndSvcSubType1Id
  , ssGrpSvcTypeId    
  , ssGrpSvcSubType1Id

from cte_p2 as p2
where (((@pracPatGroupID is null) or (exists (
  select 
    top 1 id 
  from PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW (@userID, @userGroup, @userRank, @clientID, @pracID, @pracPatGroupID, null, null, null, null, p2.patID) as t1
))))

/*============================================================
 * Determine pracs who are telehealth only
 *============================================================*/

update esd 
set 
  esd.viaTelehealth = 1 
from @expectedSvcData                                      as esd
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 500) and (png.GROUP_ID = esd.groupID))
where ((esd.indSvcOnDOS = 1) or (esd.grpSvcOnDOS = 1))

/*============================================================
 * Get service selection for individual
 * for tracking class 100
 *============================================================*/

update esd
set 
    esd.indSvcNameID    = sva2.SERVICE_NAME_ID 
  , esd.indSvcTypeID    = sva2.SERVICE_TYPE_ID
  , esd.indSvcSubTypeID = sva2.SERVICE_SUB_TYPE_1_ID
  , esd.indSvcName      = sva2.SERVICE_NAME_STANDARD
from @expectedSvcData as esd
cross apply (
  select top 1 
      sva1.SERVICE_NAME_ID 
	, sva1.SERVICE_NAME_STANDARD
	, sva1.SERVICE_TYPE_ID
	, sva1.SERVICE_SUB_TYPE_1_ID
  from dbo.SERVICES_VIEW_ALL_CORE(null,esd.groupID,esd.planTypeID,esd.ssIndSvcTypeID,null,1,1,@dos,1) as sva1
  where 
        (sva1.SERVICE_IS_VIA_TELEHEALTH   = esd.viaTelehealth) 
    and (sva1.SERVICE_SUB_TYPE_1_ID       = esd.ssIndSvcSubType1Id)  /*Individual*/
    and (sva1.CALPADS_SPED_SVC_CODE_VALUE = esd.spEdServiceCode)
) as sva2
where ( 
      (esd.svcTrackingClass = 100)
  and (esd.indSvcOnDOS = 1)
)

/*============================================================
 * Get service selection for individual
 * for tracking class 200 and 300
 *============================================================*/

update esd
set 
    esd.indSvcNameID    = sva2.SERVICE_NAME_ID 
  , esd.indSvcTypeID    = sva2.SERVICE_TYPE_ID
  , esd.indSvcSubTypeID = sva2.SERVICE_SUB_TYPE_1_ID
  , esd.indSvcName      = sva2.SERVICE_NAME_STANDARD
from @expectedSvcData as esd
cross apply (
  select top 1 
      sva1.SERVICE_NAME_ID 
	, sva1.SERVICE_NAME_STANDARD
	, sva1.SERVICE_TYPE_ID
	, sva1.SERVICE_SUB_TYPE_1_ID
  from dbo.SERVICES_VIEW_ALL_CORE(null,esd.groupID,esd.planTypeID,esd.ssIndSvcTypeID,null,1,1,@dos,1) as sva1
  where 
        (sva1.SERVICE_IS_VIA_TELEHEALTH = esd.viaTelehealth) 
    and (sva1.SERVICE_SUB_TYPE_1_ID     = esd.ssIndSvcSubType1Id)  /*Individual*/
) as sva2
where ( 
      (esd.svcTrackingClass in (200,300))
  and (esd.indSvcOnDOS = 1)
)

/*============================================================
 * Get service selection for group
 * for tracking class 100
 *============================================================*/

update esd
set 
   esd.grpSvcNameID    = sva2.SERVICE_NAME_ID 
  ,esd.grpSvcTypeID    = sva2.SERVICE_TYPE_ID
  ,esd.grpSvcSubTypeID = sva2.SERVICE_SUB_TYPE_1_ID
  ,esd.grpSvcName      = sva2.SERVICE_NAME_STANDARD
from @expectedSvcData as esd
cross apply (
  select top 1
      sva1.SERVICE_NAME_ID 
	, sva1.SERVICE_NAME_STANDARD
	, sva1.SERVICE_TYPE_ID
	, sva1.SERVICE_SUB_TYPE_1_ID
  from dbo.SERVICES_VIEW_ALL_CORE(null,esd.groupID,esd.planTypeID,esd.ssGrpSvcTypeId,null,1,1,@dos,1) as sva1
  where 
        (sva1.SERVICE_IS_VIA_TELEHEALTH   = esd.viaTelehealth) 
    and (sva1.SERVICE_SUB_TYPE_1_ID       = esd.ssGrpSvcSubType1Id)  /* Group */
    and (sva1.CALPADS_SPED_SVC_CODE_VALUE = esd.spEdServiceCode)
) as sva2
where ( 
      (esd.svcTrackingClass = 100)
  and (esd.grpSvcOnDOS = 1)
)

/*============================================================
 * Get service selection for group
 * for tracking class 200 and 300
 *============================================================*/

update esd
set 
   esd.grpSvcNameID    = sva2.SERVICE_NAME_ID 
  ,esd.grpSvcTypeID    = sva2.SERVICE_TYPE_ID
  ,esd.grpSvcSubTypeID = sva2.SERVICE_SUB_TYPE_1_ID
  ,esd.grpSvcName      = sva2.SERVICE_NAME_STANDARD
from @expectedSvcData as esd
cross apply (
  select top 1
      sva1.SERVICE_NAME_ID 
	, sva1.SERVICE_NAME_STANDARD
	, sva1.SERVICE_TYPE_ID
	, sva1.SERVICE_SUB_TYPE_1_ID
  from dbo.SERVICES_VIEW_ALL_CORE(null,esd.groupID,esd.planTypeID,esd.ssGrpSvcTypeId,null,1,1,@dos,1) as sva1
  where 
        (sva1.SERVICE_IS_VIA_TELEHEALTH = esd.viaTelehealth) 
    and (sva1.SERVICE_SUB_TYPE_1_ID     = esd.ssGrpSvcSubType1Id)  /* Group */
) as sva2
where ( 
      (esd.svcTrackingClass in (200,300))
  and (esd.grpSvcOnDOS = 1)
)

/*============================================================
  * Attempt autoselection of ORP document and determines if
  * user needs to select a document.  
  *
  * Note: The selection required logic is also performed in
  * SERVICES_VIEW_BY_PRAC_PAT_PLAN.sql and the logic needs to be
  * kept in synch with any changes to that files logic.
  *============================================================*/

update esd
  set 
      esd.orpRequired             = t3.OrpRequired
    , esd.orpDocumentID           = t3.OrpDocumentID
    , esd.orpDocumentName         = t3.OrpDocumentName
	, esd.orpDocTypeID            = t3.OrpDocTypeID
	, esd.orpDocSelectionRequired = case when (t3.OrpDocumentID is not null) then 0 else 1 end
from @expectedSvcData as esd
cross apply (
  select top 1
      t2.OrpRequired
    , t2.OrpDocumentID
    , t2.OrpDocumentName
	, t2.OrpDocTypeID
  from dbo.GET_ORP_PRAC_NPI_DATA (0, 2, @dos, esd.clientID, esd.groupID, null, esd.patID,1/*@procedureBillingProgramID*/) as t2 
) as t3
where ( 
        ((esd.indSvcTypeID = 2) or (esd.grpSvcTypeID = 2))
  and   ((esd.indSvcOnDOS = 1)  or (esd.grpSvcOnDOS = 1))
)

/*============================================================
 * Break out and output individual and group service selections
 *============================================================*/

insert into @recs (
    patID     
  , patName   
  , dos       
  , dosStr    
  , numMins   
  , svcTypeID 
  , svcSubTypeID 
  , planTypeSelectionID 
  , internalPlanTypeID  
  , planIsIEPIFSP  
  , serviceNameID 
  , serviceName   
  , orpRequired   
  , orpDocumentID 
  , orpDocumentName
  , orpDocTypeID   
  , orpDocSelectionRequired 
  , pracID
  , groupID 
  , svcTrackingClass
  , spEdServiceCode
)
select 
  q1.*
from 
(

/*-------------------------------
 * Individual
 *------------------------------*/

select
    t1.patID             
  , patName              = t1.patName
  , dos                  = @dos
  , dosStr               = @dosStr
  , numMins              = t1.expectedMinsInd   
  , svcTypeID            = t1.indSvcTypeID 
  , svcSubTypeID         = t1.indSvcSubTypeID
  , planTypeSelectionID  = t1.planSelection
  , internalPlanTypeID   = t1.planTypeID
  , planIsIEPIFSP        = t1.isIEPorIFSP
  , serviceNameID        = t1.indSvcNameID
  , serviceName          = t1.indSvcName
  , t1.orpRequired   
  , t1.orpDocumentID 
  , t1.orpDocumentName
  , t1.orpDocTypeID   
  , t1.orpDocSelectionRequired  
  , t1.pracID
  , t1.groupID 
  , t1.svcTrackingClass
  , t1.spEdServiceCode

from @expectedSvcData as t1 
where (t1.indSvcOnDOS = 1)

union all

/*-------------------------------
 * Group
 *------------------------------*/

select
    t1.patID             
  , patName              = t1.patName
  , dos                  = @dos
  , dosStr               = @dosStr
  , numMins              = t1.expectedMinsGrp  
  , svcTypeID            = t1.grpSvcTypeID 
  , svcSubTypeID         = t1.grpSvcSubTypeID
  , planTypeSelectionID  = t1.planSelection
  , internalPlanTypeID   = t1.planTypeID
  , planIsIEPIFSP        = t1.isIEPorIFSP
  , serviceNameID        = t1.grpSvcNameID
  , serviceName          = t1.grpSvcName
  , t1.orpRequired   
  , t1.orpDocumentID 
  , t1.orpDocumentName
  , t1.orpDocTypeID   
  , t1.orpDocSelectionRequired  
  , t1.pracID
  , t1.groupID 
  , t1.svcTrackingClass
  , t1.spEdServiceCode
from @expectedSvcData as t1 
where (t1.grpSvcOnDOS = 1)
) as q1

/*-------------------------------
 * Puts services with patients
 *------------------------------*/

order by 
    q1.patName
  , q1.svcTypeID


return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_ON_DOS_VIEW_OLD] TO [webuser]
GO
