USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE] (
    @clientID               bigint     
  , @pracID                 bigint
  , @patID                  bigint  
  , @recID                  bigint    
)
    
returns table     
as
 
return 
(    

/*###########################################################################
 *#  Base Data                                                              #
 *#  Note: Must explicitly define columns that are needed (no tbl.*)        #
 *#  Also get and pass down current date                                    #
 *###########################################################################*/

with
cte_p1
as
(
  select 
     q1.*
   , currentDate = convert(date,q1.currentDateTime)
  from
  (
    select top 1  /*Note: Limited to just one row */
	    clientID            = @clientID
	  , pracID              = @pracID
      , groupID             = ggd.GROUP_ID
	  , groupBase           = ggd.GROUP_BASE
      , groupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID 	
	  , clientName          = clc.CLIENT_NAME
      , pracName            = prp.CONCAT_NAME
	  , pracLastName        = prp.LAST_NAME
	  , pracFirstName       = prp.FIRST_NAME
      , groupName           = ggd.GROUP_NAME
	  , currentDateTime     = getdate()
	  , maxEndDate          = convert(date,dbo.CONST_MAX_DATETIME())

    from dbo.PRACTITIONER_Practitioner as prp
    join dbo.PRACTITIONER_Client       as prc on  ((prc.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                              and (prc.CLIENT_ID        = @clientID))
    join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID          = prc.CLIENT_ID
    join dbo.PRACTITIONER_GROUPS                                as pgd    on ((pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID) and (pgd.GROUP_TYPE in (1,2)))
    join dbo.GROUP_Group                                        as ggd    on ggd.GROUP_ID = pgd.GROUP_ID
    join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS  as png    on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100) and (png.GROUP_SERVICE_CLASS_NAME_ID is not null) and (png.GROUP_ID = pgd.GROUP_ID))

    where (
         (prp.PRACTITIONER_ID = @pracID)
     and (clc.CLIENT_ID       = @clientID)
   )
 ) as q1
)
,
cte_p2
as
(
select 
    p1.*
  , ppces2.*
from cte_p1 as p1
cross apply (
  select 
      ppc.patID
    , ppces1.id
    , ppces1.caseloadEntryID
    , ppces1.svcTrackingClass
    , ppces1.planType
    , ppces1.spEdServiceCode
    , ppces1.orpDocID
    , ppces1.svcNamesListDataSourceID
    , ppces1.viaTeleHealth
    , ppces1.nameID
    , ppces1.altModalityNameID   
    , ppces1.planTypeID
    , ppces1.svcTypeID
    , ppces1.includeAltModalityInTracking
    , ppces1.minsAnn
    , ppces1.expectedMinsInd
    , ppces1.expectedMinsGrp
    , ppces1.daysOfWeekSvcProvidedJSON
    , ppces1.created
    , ppces1.createdBy
    , ppces1.lastModified
    , ppces1.lastModifiedBy
    , ppces1.active
    , startDateAssignedEntered   = ppces1.startDateAssigned
    , minsPerFreqAssignedEntered = ppces1.minsPerFreqAssigned
    , ppces1.hasSvcDetails
    , ppces1.svcDetailsJSON 

	, ppces1.spEdFreqCode
	, ppces1.minsPerFreq
	, ppces1.startDate
	, ppces1.endDate

  from dbo.PRACTITIONER_PATIENT_CASELOAD                    as ppc
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES  as ppces1 on ppces1.caseloadEntryID = ppc.id

  where (
        ((ppc.clientID = p1.clientID)
    and (ppc.pracID    = p1.pracID)
    and (ppc.patID is not null)
    and ((@patID is null) or (ppc.patID = @patID))
    and ((@recID is null) or (ppces1.id  = @recID)))  
    and (ppces1.active = 1)) 
  ) as ppces2
)
,
cte_p3
as
(
select 
    p2.* 
  , endDateOrCurrent    = dbo.DATE_VALUE_OR_REPLACEMENT_IF_GT_LT(p2.endDate,p2.currentDate, 1)
  , startDateAssigned   = isnull(p2.startDateAssignedEntered,  p2.startDate)
  , minsPerFreqAssigned = isnull(p2.minsPerFreqAssignedEntered,p2.minsPerFreq)
  , planRanking = case 
	  when p2.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_SPED()          then 
	    DENSE_RANK() 
          OVER (partition by p2.clientID, p2.pracID, p2.patID, p2.svcTrackingClass, p2.spEdServiceCode
	            order by p2.startDate desc, p2.id desc)

	  when p2.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_NON_SPED()      then 
	    DENSE_RANK() 
          OVER (partition by p2.clientID, p2.pracID, p2.patID, p2.svcTrackingClass, p2.orpDocID
	            order by p2.startDate desc, p2.id desc)

	  when p2.svcTrackingClass = dbo.CONST_SVC_TRACKING_CLASS_USER_PROVIDED() then 
	    DENSE_RANK() 
          OVER (partition by p2.clientID, p2.pracID, p2.patID, p2.svcTrackingClass, p2.svcNamesListDataSourceID, p2.nameID
	            order by p2.startDate desc, p2.id desc)
    end  

from cte_p2 as p2
)
,
cte_p4
as
(
select 
    p3.* 
  , numRelatedScheduledServices                  = ppssRelatedSS.numOf 
  , numRelatedScheduledServicesCurrentlyInEffect = ppssRelatedSSInEffect.numOf

from cte_p3 as p3

cross apply (
  select 
    numOf = count(ppss1.id)
  from dbo.Practitioner_Patient_Scheduled_Services as ppss1
  where ( 
        ((ppss1.practitionerPatientCaseloadExpectedServiceID = p3.id) and (ppss1.id is not null))
	and (ppss1.active = 1)
  )
) as ppssRelatedSS

cross apply (
  select 
    numOf = count(ppss1.id)
  from dbo.Practitioner_Patient_Scheduled_Services as ppss1
  where ( 
        ((ppss1.practitionerPatientCaseloadExpectedServiceID = p3.id) and (ppss1.id is not null))
    and (ppss1.active = 1)
	and ((dbo.DATE_IS_BEFORE_IN_OR_AFTER_DATE_RANGE(ppss1.startDate, isnull(ppss1.endDate,p3.maxEndDate), p3.currentDate) >= 0))	
  )
) as ppssRelatedSSInEffect
)
select 
  p4.*    
 , numOfSvcDetails =  isnull(svcDetails2.numOf,0)
 , schedulesExpired = convert(bit,(iif((p4.planRanking = 1)     /* Latest plan for this subset of rows*/
                     , (iif((p4.numRelatedScheduledServices > 0) /* Has related scheduled services */
		                    ,(iif((p4.numRelatedScheduledServicesCurrentlyInEffect != p4.numRelatedScheduledServices) /* One or more schedules have expired */
							      ,1
								  ,0))
			                ,0))
		             , 0)))
from cte_p4 as p4
outer apply (
  select 
    numOf = count(svcDetails1.svcLineIdx) 
  from OPENJSON(p4.svcDetailsJSON) 
    WITH (
         svcLineIdx  varchar(50)  '$."svcLineIdx"'
    ) as svcDetails1
) as svcDetails2

) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_CORE] TO [webuser]
GO