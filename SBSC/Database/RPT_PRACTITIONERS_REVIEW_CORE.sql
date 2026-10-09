/*###########################################################################
  # Note: This UDF performs additional access checks.
  #
  # Keep this in synch with MBA.Constants.ROLE_PRAC_DIR_SUP_ADMINS 
  # in the middleware.
  ###########################################################################*/  

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PRACTITIONERS_REVIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PRACTITIONERS_REVIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_PRACTITIONERS_REVIEW_CORE]  (
    @userID              as bigint
  , @userGroup           as int
  , @userRank            as int
  , @clientID            as bigint
  , @pracID              as bigint
  , @groupID             as bigint
  , @rptGroupID          as bigint
  , @groupSvcClassNameID as bigint
  , @deptHead            as bit
  , @includeInFinRepts   as bit
  , @active              as bit
)    

returns @recs table (
    clientID                   int
  , pracID                     int
  , pracName                   nvarchar(100)
  , dispGroupID                int
  , dispGroupName              nvarchar(max)
  , employeeRelationshipID     bigint
  , employmentRelationship     varchar(255)
  , reptGroupID                int
  , reptGroupName              nvarchar(max)
  , groupSvcClassNameID        bigint
  , practiceFamily             varchar(1000)
  , departmentHead             bit  
  , includeInFinRepts          bit
  , numPatsOnCaseload              int default(0)
  , dateAdded                      datetime
  , hasAssociatedUserAccount       bit default(0)
  , userID                         bigint
  , lastLoggedOnToSpEdCareOn       datetime
  , lastLoggedOntoSpEdCareOnStr    varchar(50) default ('')
  , initialPasswordChangeCompleted bit default(0)
  , active                         bit

)
as
begin

 /***************************************************************************    
  * RPT_PRACTITIONERS_REVIEW_CORE */    
 /**    
  ***************************************************************************/     

/*###########################################################################
  # Check for required parameters.  Exit if data is not provided.
  ###########################################################################*/  

if (@userID    is null) return
if (@userGroup is null) return

/*###########################################################################
  # Init
  ###########################################################################*/  

declare @checkUserAccess         as bit    = 1
declare @userClientID            as int    = -1
declare @userGroupID             as int    = -1
declare @roleID                  as bigint = -1
declare @pracReptGroupID         as bigint = -1
declare @pracGroupSvcClassNameID as bigint = -1
declare @pracIsDeptHead          as bit    = 0
declare @pracIsDeptHeadThatCanViewEntirePracFamInDeptReviewReports as bit = 0

/*###########################################################################
  # Determine if we need to perform an access check
  ###########################################################################*/  

/*------------------------------------*/
/* If this request is from a batch    */
/* task (such as ReptDist) then no    */
/* access check is needed.            */ 
/*------------------------------------*/  

if ((@userID = 0) and (@userGroup = 2)) set @checkUserAccess = 0

/*###########################################################################
  # Perform an access check
  #
  # Note : Keep this in synch with MBA.Constants.ROLE_PRAC_DIR_SUP_ADMINS 
  # in the middleware.
  ###########################################################################*/  

if (@checkUserAccess = 1)
begin
  
  /*------------------------------------*/
  /* Get user info                      */
  /*------------------------------------*/  

  select top 1    
      @userClientID            = ua.clientID
	, @userGroupID             = ua.userGroupID
    , @roleID                  = ua.roleID
    , @pracReptGroupID         = ua.pracReptGroupID
    , @pracGroupSvcClassNameID = ua.pracGroupSvcClassNameID
    , @pracIsDeptHead          = ua.pracIsDeptHead
    , @pracIsDeptHeadThatCanViewEntirePracFamInDeptReviewReports = ua.pracIsDeptHeadThatCanViewEntirePracFamInDeptReviewReports
  from users.dbo.USERS_ALL as ua
  where (
        (ua.userIDInt = @userID)
	and (ua.appName   = 'spedcare')
  )

  /*------------------------------------*/
  /* Only client and pcal staff can     */
  /* access data.                       */ 
  /*------------------------------------*/  
 
  if (@userGroupID not in (1,2)) return

  
  /*------------------------------------*/
  /* Client Users                       */ 
  /*------------------------------------*/  
 
  if (@userGroupID = 1)
  begin

    /*------------------------------------*/
    /* Only the following client users    */
	/* can access data :                  */
	/*                                    */
	/* - LEA coordinators                 */
	/* - LEA input staff                  */
	/* - Practitioner (Department Heads)  */
    /*------------------------------------*/  

    if (@roleID not in (5,10,7)) return

	/*------------------------------------*/
    /* Client users are limited to their  */
	/* associated Client ID               */
	/* Note: This enforcment may also be  */
	/* performed in the middleware        */ 
    /*------------------------------------*/  

	set @clientID = @userClientID

    /*------------------------------------*/
    /* LEA Coord - No futher restrictions */ 
    /*------------------------------------*/  

	/*------------------------------------*/
    /* LEA Input - No futher restrictions */ 
    /*------------------------------------*/  

	/*------------------------------------*/
    /* Practitioners                      */ 
    /*------------------------------------*/  

	if (@roleID = 7)
	begin

	  /* If the practitioner is a department head then */

	  if (@pracIsDeptHead = 1) 
	  begin
      
	    /* Department head is limited to their reporting group and group family */

	    set @rptGroupID          = @pracReptGroupID
		set @groupSvcClassNameID = @pracGroupSvcClassNameID
	    
		/* But if dept head is allowed they can view all reporting groups in their group family */

		if (@pracIsDeptHeadThatCanViewEntirePracFamInDeptReviewReports = 1)
		begin
		  set @rptGroupID = null
		end

	  end /* Is depthead */
	  
	  /* If the practitioner is NOT a department head then no data */
	  
	  else
	  begin
	    return
	  end /* Not dept head*/

	end /* prac */
  end /* client */
end /* access check */

/*###########################################################################
  # Get basic data
  ###########################################################################*/  

insert into @recs (
    clientID
  , pracID  
  , pracName
  , dispGroupID
  , dispGroupName
  , employeeRelationshipID
  , employmentRelationship 
  , reptGroupID 
  , reptGroupName
  , groupSvcClassNameID
  , practiceFamily 
  , departmentHead 
  , includeInFinRepts 
  , dateAdded  
  , userID
  , active  
)
select 
    clientID                  = clc.CLIENT_ID
  , pracID                    = prp.PRACTITIONER_ID
  , pracName                  = prp.CONCAT_NAME
  , dispGroupID               = gd.GROUP_ID
  , dispGroupName             = gd.GROUP_NAME
  , prp.employeeRelationshipID
  , employmentRelationship    = er.[TYPE_NAME]
  , reptGroupID               = gr.GROUP_ID
  , reptGroupName             = gr.GROUP_NAME
  , groupSvcClassNameID       = scn.GROUP_SERVICE_CLASS_NAME_ID
  , practiceFamily            = scn.GROUP_SERVICE_CLASS_NAME
  , departmentHead            = prp.deptHead
  , prp.includeInFinRepts 
  , dateAdded                 = isnull(prc.DATE_START,prp.DATE_CREATED)
  , userID                    = prp.UserID
  , active                    = prp.ACTIVE

from dbo.CLIENTS_Client            as clc
join dbo.PRACTITIONER_Client       as prc  on (prc.CLIENT_ID        = clc.CLIENT_ID)
join dbo.PRACTITIONER_Practitioner as prp  on (prp.PRACTITIONER_ID  = prc.PRACTITIONER_ID)

/* Employment relationship */

join dbo.EMPLOYMENT_RELATIONSHIPS  as er   on (er.[TYPE_ID] = prp.employeeRelationshipID)

/* Discipine group */

join dbo.PRACTITIONER_GROUPS       as pgd  on ((pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID) and (pgd.GROUP_TYPE in (1,2)))
join dbo.PRACTITIONER_GROUPS       as pgr  on ((pgr.PRACTITIONER_ID = prp.PRACTITIONER_ID) and (pgr.GROUP_TYPE in (3,5)))

/* Reporting group */

join dbo.GROUP_Group               as gd   on (gd.GROUP_ID = pgd.GROUP_ID)
join dbo.GROUP_Group               as gr   on (gr.GROUP_ID = pgr.GROUP_ID)

/* Practice family */

join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on ((png.GROUP_ID = gd.GROUP_ID) and (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100))
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as scn on (scn.GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID)

where (

      (clc.CLIENT_ID = @clientID)

  and ((@pracID              is null) or (prp.PRACTITIONER_ID             = @pracID))  
  and ((@groupID             is null) or (pgd.GROUP_ID                    = @groupID))
  and ((@rptGroupID          is null) or (pgr.GROUP_ID                    = @rptGroupID))
  and ((@groupSvcClassNameID is null) or (scn.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
  and ((@deptHead            is null) or (prp.deptHead                    = @deptHead))
  and ((@includeInFinRepts   is null) or (prp.includeInFinRepts           = @includeInFinRepts))
  and (prp.ACTIVE              = 1)
  and (prp.currentlyWithClient = 1)
  
  /* Exclude practitioners with no employement relationship (ie third party orps) */

  and (prp.employeeRelationshipID != 30) 
)

/*###########################################################################
  # Get associated user account data
  ###########################################################################*/  

update t1
  set     
    t1.hasAssociatedUserAccount       = 1 
  , t1.lastLoggedOnToSpEdCareOn       = ua2.lastLoginDate
  , t1.initialPasswordChangeCompleted = ua2.initialPasswordChangeCompleted
  , t1.lastLoggedOntoSpEdCareOnStr    = iif ( (ua2.lastLoginDate = dbo.CONST_MIN_DATETIME_1900_01_01())
                                             , 'Never logged in'
											 , dbo.RPT_DATE_FMT(ua2.lastLoginDate))
from @recs as t1
cross apply (
  select top 1
      ua1.lastLoginDate 
	, ua1.initialPasswordChangeCompleted	
  from users.dbo.USERS_ALL as ua1
  where ( 
        (ua1.userIDInt = t1.userID)
    and (ua1.clientID  = t1.clientID)
    and (ua1.pracID    = t1.pracID)
  )
) as ua2


/*###########################################################################
  # Get caseload counts
  ###########################################################################*/  

update t1
  set t1.numPatsOnCaseload = ppc2.numPatsOnCaseload
from @recs as t1
cross apply (
  select 
    numPatsOnCaseload = count(ppc1.id)
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc1
  where (
          (ppc1.clientID = t1.clientID)
      and (ppc1.pracID   = t1.pracID)
  )
) as ppc2

/*###########################################################################
  # Done
  ###########################################################################*/  

return

end


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].RPT_PRACTITIONERS_REVIEW_CORE TO [webuser]
GO

  