USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRAC_REC_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRAC_REC_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
 -- TODO: This needs to be part of the users refator
 -- TODO: Factor this udf out and replace in the middleware with a load method

CREATE FUNCTION [dbo].[PRAC_REC_VIEW] ( @pracID BIGINT)    
RETURNS TABLE 
AS RETURN (     
with 
cte_p1
as
(
   select top 1
       prp.CONCAT_NAME        as name
     , ggd.GROUP_ID           as groupID
     , ggd.GROUP_NAME         as groupName
     , ggr.GROUP_ID           as groupIDRept
     , ggr.GROUP_NAME         as groupNameRept
     , prp.ACTIVE             as active
     , prp.FIRST_NAME         as firstName
     , prp.LAST_NAME          as lastName
	 , isnull(prp.deptHead,0) as deptHead
	 , prp.displayMoney       as displayMoney
     , clc.CLIENT_ID          as clientID   
     , clc.CLIENT_NAME        as clientName     
     , clc.CLIENT_CDS         as clientCDS

     , isnull(srao.approvalSystem,0) as svcRecPracApprovalSystem
     , vgs.supervisesGroupCount
     , vsbg.supervisedByGroupCount
     , vhr.svcsHeldFromAllCount    
     , vsr.svcsToReviewFromAllCount     
     , supervisorsAssignedCount                 = isnull(ppssrd.pracsAssigned,0)
     , supervisedAssignedCount                  = ppssdr.pracsAssignedToSuperviseDirectlyCount
	 , pracsAsDeptHeadAllowedToViewSvcRecsCount = pdsfdhvc2.pracsAsDeptHeadAllowedToViewSvcRecsCount
     , svcsToReviewFromAssignedCount = vsrda.svcsToReviewFromAssignedCount  

	 , ggdss2.groupsThatPracCanSuperviseDirectlyCount
     , ppssdr.pracsAssignedToSuperviseDirectlyCount 
     , sarRspReq.serviceAuthorizationRequestsPendingCount
     , sarAuthToView.serviceAuthorizationRequestsAuthToViewCount
	 
	 , pwgscd.planWriterGroupID
     , isnull(dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID(pgd.GROUP_ID),0) as orpGroupServiceClassNameID
     , isnull(stdSvcClass.stdSvcClassNameID,0)                             as stdSvcClassNameID
	 , convert(bit,isnull(paraProfs.isParaProf,0))                         as isAParaProfessional
	 , id = prp.PRACTITIONER_ID     
	 , prp.participatesInLEABOP
	 , prp.participatesInCYBHI
	 , prp.participatesInRUHealth 
	 , prp.participatesInLEABOPNonSpEd
	  
     , pracsAssignedForCybhiOrpSvcRecReview = isnull (cybhiClinicalSupAssignments.numOf, 0) 
     , pracsAssignedForInternalSvcRecReview = isnull (internalSvcSupAssignments.numOf,   0) 
	 , svcRecsWaitingForReviewCybhiOrp      = isnull (srCybhiOrpWaitingForReview.numOf,  0)
	 , svcRecsWaitingForReviewInternal      = isnull (srirWaitingForReview.numOf,        0)

   from dbo.PRACTITIONER_Practitioner as prp
   join dbo.PRACTITIONER_Client       as prc on  prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
   join dbo.CLIENTS_Client            as clc on  clc.CLIENT_ID       = prc.CLIENT_ID
   
   join      dbo.PRACTITIONER_GROUPS       as pgd on  pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                  and pgd.GROUP_TYPE in (1,2,4)
   
   join      dbo.GROUP_GROUP               as ggd on  ggd.GROUP_ID = pgd.GROUP_ID                                                  
                                                  and ggd.GROUP_TYPE in (1,2,4)
   
   left join dbo.PRACTITIONER_GROUPS       as pgr on  pgr.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                  and pgr.GROUP_TYPE in (3,5)
   
   left join dbo.GROUP_GROUP               as ggr on  ggr.GROUP_ID = pgr.GROUP_ID                                                   
                                                  and ggr.GROUP_TYPE in (3,5)
   
   /*============================================================
    * Supervision Relationships - General and Direct - Groups 
    *============================================================*/  
  
   /* Supervises group count (TODO: This needs to be refactored out)*/

   cross apply (
     select count (g1.GROUP_ID) as supervisesGroupCount   
     from dbo.GROUPS_SUPERVISED_BY_GROUP_ID_VIEW (pgd.GROUP_ID) as g1
   ) as vgs    
   
   /* Supervised by group count (TODO: This needs to be refactored out) */

   cross apply (
     select count (g1.GROUP_ID) as supervisedByGroupCount 
     from dbo.GROUPS_SUPERVISING_GROUP_ID_VIEW   (pgd.GROUP_ID) as g1
   ) as vsbg
   

   /*============================================================
    * Service Record Approval 
    *============================================================*/  
  
   /* Options */

   outer apply (
     select top 1 sro.approvalSystem 
     from dbo.SERVICE_RECORDS_APPROVAL_OPTIONS as sro 
	 where (sro.clientID = prc.CLIENT_ID)
   ) as srao         
   
   /* General supervision - Services held for this supervised practitioners CORRECTION*/
   
   cross apply (
     select 
       count(sra.id) as svcsHeldFromAllCount
     from dbo.SERVICE_RECORDS_APPROVAL as sra   
     join dbo.SERVICE_RECORDS          as sr on (sr.id = sra.svcRecID
                                             and ((sr.state <> 99) and (sr.state <> 199)))
     where (
           (sra.clientID   = clc.CLIENT_ID)
       and (sra.groupID    = ggd.GROUP_ID)
       and (sra.pracID     = prp.PRACTITIONER_ID)
       and (sra.reviewed   = 1)
       and (sra.approved   = 0)
     )
   )  as vhr
   
   /* General supervision - Services for this supervising practioners review (prac does not have to be assigned, just qualified) */
   
   cross apply (
     select 
       count (sra.id) as svcsToReviewFromAllCount
     from  dbo.GROUPS_SUPERVISED_BY_GROUP_ID_VIEW (ggd.GROUP_ID)  as  gs
     join  dbo.SERVICE_RECORDS_APPROVAL                           as  sra  on  sra.clientID = clc.CLIENT_ID
                                                                           and sra.groupID  = gs.GROUP_ID
                                                                           and sra.reviewed = 0
                                                                           and sra.active   = 1  
     /* Uses [ID_STATE_IS_NOT_99_199] index */
	 join dbo.SERVICE_RECORDS                                     as sr on (
	                                                                          (sr.id = sra.svcRecID
                                                                          and ((sr.state <> 99) and (sr.state <> 199)))
																		  and (sr.dos >= dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,getdate())))
																		)
   ) as vsr
  

   /* General supervision - Services from assigned pracs for this supervising practioners review (uses index [CLIENT_ID_SUPERVISING_PRAC_ACTIVE]) */
   
  cross apply (

    select 
       count (sra.id) as svcsToReviewFromAssignedCount 
     from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as g1
	 join  dbo.SERVICE_RECORDS_APPROVAL                              as sra  on  sra.clientID = g1.CLIENT_ID
                                                                             and sra.pracID = g1.SUPERVISED_PRAC_ID
                                                                             and sra.reviewed = 0
                                                                             and sra.active   = 1  
     /* Uses [ID_STATE_IS_NOT_99_199] index */
	 join dbo.SERVICE_RECORDS                                     as sr on (
	                                                                          (sr.id = sra.svcRecID
                                                                          and ((sr.state <> 99) and (sr.state <> 199)))
																		  and (sr.dos >= dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,getdate())))
																		)     
     where (
           ((g1.CLIENT_ID           = prc.CLIENT_ID)
       and (g1.SUPERVISING_PRAC_ID = prp.PRACTITIONER_ID)
       and (g1.ACTIVE              = 1)
	   and (g1.ID > 0))
	   and (g1.SHARE_NOTES         = 0)
	   and (g1.relationshipTypeID = 10)
     )
     
   ) as vsrda

   /* Direct supervison - Num of groups this prac can directly supervise pracs in */

   cross apply ( 
    select 
      groupsThatPracCanSuperviseDirectlyCount = COUNT(ggdss1.id) 
    from [dbo].[GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR] as ggdss1
    where (ggdss1.SUPERVISING_GROUP_ID = pgd.GROUP_ID)
   ) as ggdss2
   
   /* Direct supervision - Num of pracs assigned to supervise (uses index [CLIENT_ID_SUPERVISING_PRAC_ACTIVE]) */     
  
   cross apply (
     select 
       pracsAssignedToSuperviseDirectlyCount = COUNT(g1.id) 
     from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as g1
     where (
           ((g1.CLIENT_ID           = prc.CLIENT_ID)
       and (g1.SUPERVISING_PRAC_ID = prp.PRACTITIONER_ID)
       and (g1.ACTIVE              = 1)
	   and (g1.ID > 0))
	   and (g1.SHARE_NOTES         = 0)
	   and (g1.relationshipTypeID = 10)
     )
   ) as ppssdr
  

   /* As department head num of pracs allowed to view svc recs */     
  
  cross apply (
     select  
	   pracsAsDeptHeadAllowedToViewSvcRecsCount = count(pdsfdhvc1.SUPERVISED_PRAC_ID)
	 from dbo.PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE (prc.CLIENT_ID, prp.PRACTITIONER_ID,null) as pdsfdhvc1
	 where ( 
	      (pdsfdhvc1.departmentHeadsCanViewSupervisedPracsSvcRecs = 1)
	   or (pdsfdhvc1.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1)
	 )
   ) as pdsfdhvc2

  /* Direct supervision - Num of supervising pracs assigned (uses index [ACTIVE_SUPERVISED_START_END_IDX])*/     
  /* TODO: See if we can remove */

  outer apply (
     select 
       pracsAssigned = COUNT(ppds1.id) 
     from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppds1
     where (
           (ppds1.ACTIVE              = 1)
	   and (ppds1.SUPERVISED_PRAC_ID = prp.PRACTITIONER_ID)
	   and (ppds1.SHARE_NOTES        = 0)	   
	   and (ppds1.relationshipTypeID = 10)
     )
	 group by 
	   ppds1.SUPERVISING_PRAC_ID
   ) as ppssrd
   
   /*============================================================
    * Service Authorization for ORPs
    *============================================================*/  
   
   /* Service authorizations waiting for approval by this practitioner (based on pracs user id) */

   outer apply (
     select 
	   serviceAuthorizationRequestsPendingCount = count (sar.id)
     from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS        as sarau 
	 join dbo.SERVICE_AUTHORIZATION_REQUESTS                        as sar on sar.id = sarau.requestID

	 where (
	       (sarau.userID           = prp.UserID)
	   and (sarau.responseRequired = 1)
	   and (sar.currentResponseCode = 2000) /* Pending */
	   and (sar.closed = 0)
	   and (sar.active = 1)
	 )
   ) as sarRspReq


   /* Service authorizations authorized to view (based on pracs user id) */

   outer apply (
     select 
	   serviceAuthorizationRequestsAuthToViewCount = count (sar.id)
     from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS        as sarau  
	 join dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES               as saprc  on saprc.code = sarau.serviceAuthorizationPersonRoleCode
	 join dbo.SERVICE_AUTHORIZATION_REQUESTS                        as sar on sar.id = sarau.requestID
	 
	 where (
	       (sarau.userID = prp.UserID)
	  and ((saprc.isOrp = 1) or (saprc.isRdp = 1))
	  and (sar.active = 1)
	 )
   ) as sarAuthToView
  
   /*============================================================
    * Service Class Name (Group Families)
    *============================================================*/  

   /* Standard service name class id (group family) */

   outer apply (
     select top 1
	   stdSvcClassNameID = g1.GROUP_SERVICE_CLASS_NAME_ID
     from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as g1
     where (
           (g1.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
       and (g1.GROUP_ID = pgd.GROUP_ID)
     )
   ) as stdSvcClass
   
   /* Plan writer group service name id */
   
   outer apply (
     select top 1
       planWriterGroupID = g1.GROUP_SERVICE_CLASS_NAME_ID
     from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as g1
     where (
           (g1.GROUP_SERVICE_CLASS_PARTITION_ID = dbo.CONST_GROUP_SERVICE_CLASS_PARTITION_PLAN_WRITER())
       and (g1.GROUP_ID = pgd.GROUP_ID)
     )
   
   ) as pwgscd

   /*============================================================
    * Other meta data
    *============================================================*/  
  
   /* Is Practitioner a ParaProfessional? */
   /* Note see :https://www.understood.org/en/school-learning/for-educators/learning-and-thinking-differences-basics/paraprofessionals-what-you-need-to-know */

  outer apply (
     select top 1
	   isParaProf = 1
     from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as g1
     where (
           (g1.GROUP_SERVICE_CLASS_PARTITION_ID = 400)
       and (g1.GROUP_ID = pgd.GROUP_ID)
     )
  ) as paraProfs
    
  /*============================================================
    * CYBHI Clinical Supervisor/ORP
	* Pracs Assigned
    *============================================================*/  
  
  outer apply (
    
	/* Uses index [CLIENT_ID_SUPERVISING_PRAC_ACTIVE] */

     select 
       numOf = count(ppdss.ID)
     from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
	 where ( 
	       ((ppdss.CLIENT_ID = prc.CLIENT_ID) and (ppdss.SUPERVISING_PRAC_ID = prp.PRACTITIONER_ID) and (ppdss.ACTIVE = 1) and (ppdss.ID > 0))
	   and (ppdss.SHARE_NOTES        = 0)
	   and (ppdss.relationshipTypeID = 20)
	 )
  ) as cybhiClinicalSupAssignments

  /*============================================================
   * CYBHI Clinical Supervisor
   * Service Records Waiting for Review
   *============================================================*/  
  
  outer apply (
    select 
	  numOf = count(srir.id)
	from dbo.CYBHI_SERVICE_RECORDS_ORP_REVIEWS as srir	
	where ( 
	      ((srir.clientID = prc.CLIENT_ID) and (srir.assignedToPracID = prp.PRACTITIONER_ID))
	  and (srir.reviewed = 0)
	  and (srir.active   = 1)	
    )
  ) as srCybhiOrpWaitingForReview

   /*============================================================
    * Internal Service Record Review
	* Pracs Assigned
    *============================================================*/  
	  
  outer apply (
    
	/* Uses index [CLIENT_ID_SUPERVISING_PRAC_ACTIVE] */

     select 
       numOf = count(ppdss.ID)
     from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
	 where ( 
	       ((ppdss.CLIENT_ID = prc.CLIENT_ID) and (ppdss.SUPERVISING_PRAC_ID = prp.PRACTITIONER_ID) and (ppdss.ACTIVE = 1) and (ppdss.ID > 0))
	   and (ppdss.SHARE_NOTES        = 0)
	   and (ppdss.relationshipTypeID = 30)
	 )
  ) as internalSvcSupAssignments

   /*============================================================
    * Internal Service Record Review
	* Service Records Waiting For Review 	
    *============================================================*/  
  
  outer apply (
    select 
	  numOf = count(srir.id)
	from dbo.SERVICE_RECORDS_INTERNAL_REVIEWS as srir	
	where ( 
	      ((srir.clientID = prc.CLIENT_ID) and (srir.assignedToPracID = prp.PRACTITIONER_ID))
	  and (srir.reviewed = 0)
	  and (srir.active   = 1)	  
    )
  ) as srirWaitingForReview

 
  where 
    (prp.PRACTITIONER_ID = @pracID)
)
,
cte_p2
as
(
  select 
      p1.* 
      /* Note: If a new group family is added and the data is not updated we need this logic as a fallback */
	, departmentHeadsCanViewSupervisedPracsPrivateNotes        = isnull(psr2.departmentHeadsCanViewSupervisedPracsPrivateNotes,0)
	, departmentHeadsCanViewSupervisedPracsStoredFiles         = isnull(psr2.departmentHeadsCanViewSupervisedPracsStoredFiles,0)
	, departmentHeadsCanViewSupervisedPracsSvcRecs             = isnull(psr2.departmentHeadsCanViewSupervisedPracsSvcRecs,0)
	, onlyDepartmentHeadsCanManageDirectSupervisionAssignments = isnull(psr2.onlyDepartmentHeadsCanManageDirectSupervisionAssignments,0)
    , departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup            = isnull(psr2.departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup,0)
    , departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup = isnull(psr2.departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup,0)

  from cte_p1 as p1

  outer apply (

    select top 1 

	    psr1.departmentHeadsCanViewSupervisedPracsPrivateNotes
	  , psr1.departmentHeadsCanViewSupervisedPracsStoredFiles
	  , psr1.departmentHeadsCanViewSupervisedPracsSvcRecs
	  , psr1.onlyDepartmentHeadsCanManageDirectSupervisionAssignments
	  , psr1.departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup
      , psr1.departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup
	 
	from dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as psr1
	where ( 
	       (psr1.clientID = p1.clientID)
      and (psr1.groupServiceClassNameID = p1.stdSvcClassNameID)
	)
  ) as psr2
) 
select 
    p2.* 
  , isPracSomeoneWhoCanManageDirectSupervisionTracking = convert(bit,
    (case when (p2.onlyDepartmentHeadsCanManageDirectSupervisionAssignments = 1) 
    then
	  iif((p2.deptHead = 1),1,0)
	else
	  iif((p2.groupsThatPracCanSuperviseDirectlyCount > 0),1,0)
	end))
  
  , pracIsLimitedToTheirReportingGroupForManagingDirectSupervisionTracking = convert(bit,
    (case when (p2.departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup = 1) 
    then
	  iif((p2.deptHead = 1),1,0)
	else
	  0
	end))
    
from cte_p2 as p2  
)   
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRAC_REC_VIEW] TO [webuser]
GO
