USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_VIEW] (
    @userID              BIGINT    
  , @userGroup           BIGINT    
  , @userRank            INT
  , @clientID            bigint
  , @groupSvcClassNameID bigint
  , @rptGroupID          bigint
  , @supervisingPracID   bigint
  , @supervisedPracID    bigint
  , @active              bit
  , @recID               bigint  
)    
RETURNS 
TABLE
AS
RETURN
(
  with
  cte_p1
  as
  (

  select 
      id                  = ppdss.ID
	, [name]              = supervisedPrac.pracNameAndTitle  /* Kept for backwards compat */

	, clientID            = clc.CLIENT_ID
	, clientName          = clc.CLIENT_NAME
	
	, groupServiceClassNameID       = scn.GROUP_SERVICE_CLASS_NAME_ID
	, groupServiceClassName         = scn.GROUP_SERVICE_CLASS_NAME

	, supervisingPracID             = supervisingPrac.pracID
	, supervisingPracName           = supervisingPrac.pracName
	, supervisingPracDispGroupName  = supervisingPrac.dispGroupName
	, supervisingPracDispGroupID    = supervisingPrac.dispGroupID
	, supervisingPracNameAndTitle   = supervisingPrac.pracNameAndTitle
	, supervisingPracReptGroupID    = supervisingPrac.reptGroupID
	, supervisingPracReptGroupName  = supervisingPrac.reptGroupName

	, supervisedPracID              = supervisedPrac.pracID
	, supervisedPracName            = supervisedPrac.pracName
	, supervisedPracDispGroupName   = supervisedPrac.dispGroupName
	, supervisedPracDispGroupID     = supervisedPrac.dispGroupID
	, supervisedPracNameAndTitle    = supervisedPrac.pracNameAndTitle
	, supervisedPracReptGroupID     = supervisedPrac.reptGroupID
	, supervisedPracReptGroupName   = supervisedPrac.reptGroupName

	, startDate           = ppdss.START_DATE
	, startDateStrYMD     = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppdss.START_DATE)
	
	, endDate             = ppdss.END_DATE
	, endDateStrYMD       = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppdss.END_DATE)
	
	, shareNotes          = ppdss.SHARE_NOTES
	, relationshipTypeID  = ppdss.relationshipTypeID
	, requireSvcRecApprovalForNonProgCompRels = ppdss.requireSvcRecApprovalForNonProgCompRels
	, groupID             = supervisedPrac.dispGroupID      /* Kept for backwards compat */
	, groupName           = supervisedPrac.dispGroupName    /* Kept for backwards compat */
	, [active]            = ppdss.ACTIVE

  from  dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss  
  join  dbo.CLIENTS_Client                                         as clc  on clc.CLIENT_ID                   = ppdss.CLIENT_ID
  join  dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                        as scn  on scn.GROUP_SERVICE_CLASS_NAME_ID = ppdss.groupServiceClassNameID
  
  /* Supervised Prac */

  cross apply (
    select top 1  
        pracID        = prp.PRACTITIONER_ID
      , pracName      = prp.CONCAT_NAME
      , dispGroupID   = ggd.GROUP_ID
	  , dispGroupName = ggd.GROUP_NAME
	  , reptGroupID   = ggr.GROUP_ID
      , reptGroupName = ggr.GROUP_NAME
	  , pracNameAndTitle = prp.CONCAT_NAME + N' - ' + ggd.GROUP_NAME + N' - ' + ggr.GROUP_NAME
    from  dbo.PRACTITIONER_Practitioner  as prp  
    join  dbo.PRACTITIONER_GROUPS        as prgd  on ((prgd.PRACTITIONER_ID  = prp.PRACTITIONER_ID) and (prgd.GROUP_TYPE in (1,2)))
    join  dbo.GROUP_Group                as ggd   on ((ggd.GROUP_ID          = prgd.GROUP_ID)       and (ggd.GROUP_TYPE in (1,2)))
    join  dbo.PRACTITIONER_GROUPS        as prgr  on ((prgr.PRACTITIONER_ID  = prp.PRACTITIONER_ID) and (prgr.GROUP_TYPE in (3,5)))
    join  dbo.GROUP_Group                as ggr   on ((ggr.GROUP_ID          = prgr.GROUP_ID)       and (ggr.GROUP_TYPE in (3,5)))
    where 
	  (prp.PRACTITIONER_ID = ppdss.SUPERVISED_PRAC_ID)
  ) as supervisedPrac

  /* Supervising Prac */

  cross apply (
    
	select top 1  
        pracID           = prp.PRACTITIONER_ID
      , pracName         = prp.CONCAT_NAME
      , dispGroupID      = ggd.GROUP_ID
	  , dispGroupName    = ggd.GROUP_NAME
	  , reptGroupID      = ggr.GROUP_ID
      , reptGroupName    = ggr.GROUP_NAME
	  , pracNameAndTitle = prp.CONCAT_NAME + N' - ' + ggd.GROUP_NAME + N' - ' + ggr.GROUP_NAME

	from  dbo.PRACTITIONER_Practitioner  as prp  
    join  dbo.PRACTITIONER_GROUPS        as prgd  on ((prgd.PRACTITIONER_ID  = prp.PRACTITIONER_ID) and (prgd.GROUP_TYPE in (1,2)))
    join  dbo.GROUP_Group                as ggd   on ((ggd.GROUP_ID          = prgd.GROUP_ID)       and (ggd.GROUP_TYPE in (1,2)))
    join  dbo.PRACTITIONER_GROUPS        as prgr  on ((prgr.PRACTITIONER_ID  = prp.PRACTITIONER_ID) and (prgr.GROUP_TYPE in (3,5)))
    join  dbo.GROUP_Group                as ggr   on ((ggr.GROUP_ID          = prgr.GROUP_ID)       and (ggr.GROUP_TYPE in (3,5)))
    where 
	  (prp.PRACTITIONER_ID = ppdss.SUPERVISING_PRAC_ID )
  ) as supervisingPrac

where (
      (1=1)
  and (ppdss.CLIENT_ID = @clientID)
  and ((@supervisingPracID   is null) or (ppdss.SUPERVISING_PRAC_ID     = @supervisingPracID))
  and ((@supervisedPracID    is null) or (ppdss.SUPERVISED_PRAC_ID      = @supervisedPracID))
  and ((@groupSvcClassNameID is null) or (ppdss.groupServiceClassNameID = @groupSvcClassNameID))
  and (ppdss.ACTIVE = @active)
  and ((@recID is null) or (ppdss.ID = @recID))
  and (ppdss.SHARE_NOTES = 0)                   /* We are removing share notes feature */
)  
)
,
cte_p2
as
(

select 
    p1.*
  , supervisionRelationshipIsCurrentlyValid              = convert(bit,(iif( (p1.relationshipTypeID = 10)
                                                                            , isnull(ggdss2.canSupervise,0)
															                , 1)))
  , supervisedAndSupervisorAreInDifferentReportingGroups = convert(bit,(iif((p1.supervisedPracReptGroupID != p1.supervisingPracReptGroupID),1,0)))

  , relationshipTypeName = case 
      when (p1.relationshipTypeID = 10) then 'Program Compliance'
      when (p1.relationshipTypeID = 20) then 'CYBHI ORP'
	  when (p1.relationshipTypeID = 30) then 'Internal Administration'
	  else ''
	end

from cte_p1 as p1

outer apply (
  select top 1 
    canSupervise = 1 
  from dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as ggdss1
  where (
    (ggdss1.SUPERVISED_GROUP_ID = p1.supervisedPracDispGroupID) and (ggdss1.SUPERVISING_GROUP_ID = p1.supervisingPracDispGroupID)
  )
) as ggdss2

where (
      (1=1)
  and ((@rptGroupID is null) or ((p1.supervisedPracReptGroupID = @rptGroupID) or (p1.supervisingPracReptGroupID = @rptGroupID)))
)

)
select top (dbo.CONST_MAX_ROWS()) 
  p2.* 
from cte_p2 as p2
order by 
    p2.[name] asc
  , p2.id     desc
)
GO

GRANT SELECT ON  [dbo].[PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR_VIEW] TO [webuser]
GO
