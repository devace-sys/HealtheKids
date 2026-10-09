USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITONERS_VIEW] (
    @userID      BIGINT
  , @userGroup   INT
  , @userRank    INT
  , @source      INT
  , @recID       BIGINT
  , @clientID    BIGINT
  , @patID       BIGINT
  , @groupID     BIGINT
  , @lname       NVARCHAR(50)
  , @fname       NVARCHAR(50)

  , @currentlyWithClient  bit

  , @dos         DATETIME
  , @active      BIT
  , @canEdit     BIT
  , @refPracGroupServiceClassNameID BIGINT
)

RETURNS TABLE

/***************************************************************************
 * PRACTITIONERS_VIEW */
/**
 * Returns a table of practitioners that match the given parameters.
 * Each client has one or more practitioners.
 *
 * @param  clientID        ID of client
 * @param  lname           All or part of practitioners last name
 * @param  fname           All or part of practitioners first name
 * @param  active          If practitioner is active
 * @param  canEdit         If practitioner can be edited by userID
 * @param  recID           Practitioner ID
 * @return                 Table of practitioner data
 ***************************************************************************/
AS RETURN(

/*-------------------------------
 * Retrieve records
 *------------------------------*/

  select top (dbo.CONST_MAX_ROWS())
      pv.*
    , oscn.groupServiceClassName as orpGroupServiceClassName
	, activeYN                     = dbo.RPT_BIT_TO_YN(active)
	, isRMTSPart1                  = dbo.RPT_BIT_TO_YN (dbo.RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR (clientID, id, 1, null))
	, isRMTSPart2                  = dbo.RPT_BIT_TO_YN (dbo.RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR (clientID, id, 2, null))
	, isRMTSPart3                  = dbo.RPT_BIT_TO_YN (dbo.RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR (clientID, id, 3, null))
	, isRMTSPart4                  = dbo.RPT_BIT_TO_YN (dbo.RMTS_PARTICIPATION_IS_PRAC_ON_ROSTER_FOR_CURRENT_FY_QTR (clientID, id, 4, null))
	, isValidMcalOrpYN             = dbo.RPT_BIT_TO_YNU (isValidMcalOrp)
	, includeInFinReptsYN          = dbo.RPT_BIT_TO_YN (includeInFinRepts)
	, submitClaimsYN               = dbo.RPT_BIT_TO_YN (submitClaims)
	, claim_TCMYN                  = dbo.RPT_BIT_TO_YNU (claim_TCM)
	, hasLoginYN                   = dbo.RPT_BIT_TO_YN (hasLogin)
	, isLockedOutYN                = dbo.RPT_BIT_TO_YN (isLockedOut)
	, startDateStr                 = dbo.RPT_DATE_FMT(startDate)
	, endDateStr                   = dbo.RPT_DATE_FMT(endDate)
	, submitClaimsEffectiveDateStr = dbo.RPT_DATE_FMT(submitClaimsEffectiveDate)
	, claim_TCMEffectiveDateStr     = dbo.RPT_DATE_FMT(claim_TCMEffectiveDate)

    , dbo.RPT_BIT_TO_YN ( participatesInLEABOP )  participatesInLEABOP_YN

    , dbo.RPT_BIT_TO_YN ( participatesInCYBHI  )  participatesInCYBHI_YN
	, isAParaProfessional	= convert(bit,isnull(paraProfs.isParaProf,0))
    , dbo.RPT_BIT_TO_YN ( participatesInRUHealth  )  participatesInRUHealth_YN

    , dbo.RPT_BIT_TO_YN ( currentlyWithClient )         currentlyWithClient_YN
	, dbo.RPT_BIT_TO_YN ( participatesInLEABOPNonSpEd)  participatesInLEABOPNonSpEd_YN
	, dbo.RPT_BIT_TO_YN ( cybhiTpaApproved)             cybhiTpaApproved_YN
	, cybhiTpaApprovedOnStr = dbo.RPT_DATE_FMT(cybhiTpaApprovedOn)
  from
  (

  select
    p.id,
    p.name,
    p.lastName,
    p.firstName,
    p.email                                     as email,
    p.phone                                     as phone,
    p.fax							        as fax,
    p.street1,
    p.street2,
    p.city,
    p.[state],
    p.zip5,
    p.zip4,
    [placeAddress] = dbo.BUILD_PLACE_ADDRESS_STRING(p.street1,p.street2,p.city,p.[state],p.zip5,p.zip4,0),
    p.groupNameDisp                             as groupName,
    p.groupIDDisp                               as groupID,
    isnull(p.groupNameRept,'')                  as groupNameRept,
    isnull(p.groupIDRept,'')                    as groupIDRept,
    p.includeInFinRepts,
    isnull(p.clientEmployeeID,'')               as clientEmployeeID,
    p.employeeRelationshipID,
    p.employeeRelationship,
    p.claim_TCM                                 as claim_TCM,
    p.claim_TCMEffectiveDate                    as claim_TCMEffectiveDate,
    p.npiNumber,
    p.isValidMcalOrp,
    p.isValidMcalOrpLastValidated,
    isnull(p.notes,'')                          as notes,
    p.clientID,
    p.clientName,
    p.startDate,
    p.endDate,
    dbo.STRING_HAS_VALUE(u.userName)            as hasLogin,
	isnull(u.accountIsLockedOut,0)              as isLockedOut,
    p.active,
    p.PRAC_ASP_ID                               as userIDUid,
    p.UserID                                    as userIDInt,
    dbo.INT_HAS_VALUE(pe.id)                    as canEdit,
    p.pracClientRecID,
    p.pracNoteRecID,
    p.pracGroupDispRecID,
    p.pracGroupReptRecID,
    p.submitClaims,
    p.submitClaimsEffectiveDate,
	p.earliestServiceDate,
    p.latestServiceDate,
    p.modifedOrCreatedOn,
    isnull (dbo.GET_PLAN_WRITER_SVC_CLASS_NAME_ID_FROM_GROUP_ID(p.groupIDDisp),0) as planWriterGroupID,
    isnull (dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_GROUP_ID(p.groupIDDisp),0)         as orpGroupServiceClassNameID,
	isnull (dbo.GET_STD_SVC_CLASS_NAME_ID_FROM_GROUP_ID(p.groupIDDisp),0)         as stdSvcClassNameID,
    coalesce (   convert(varchar,p.isValidMcalOrpLastValidated,101)
               , 'Never') as isValidMcalOrpLastValidatedStr,
    p.cprCertEffectiveDate,
	p.cprCertExpirationDate,
	p.qualificationsJSONData,
	p.deptHead,
	p.displayPercent,
	p.displayMoney,
	p.acesCertCompletedOn,

    p.participatesInLEABOP ,
    p.participatesInCYBHI,
	p.deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports,
	p.dob,
	p.ssn,
	p.gender,
	p.cybhiDegreeCode,
	p.cybhiDegreeCode2,
	p.cybhiDegreeCode3,
    p.cybhiSpecialtyCode,
	p.cybhiSpecialtyCode2,
	p.cybhiSpecialtyCode3,
	p.cybhiSpecialtyCode4,
	p.participatesInRUHealth ,
    p.currentlyWithClient,
	p.participatesInLEABOPNonSpEd,
	p.cybhiTpaApproved,
	p.cybhiTpaApprovedOn,
	p.cybhiTpaID,
	p.cybhiSubmitClaims


  from dbo.PRACTITONERS_VIEW_CORE (   @source
                                    , @clientID
                                    , @patID
                                    , @groupID
                                    , dbo.CREATE_NAME_PAT(@lname)
                                    , dbo.CREATE_NAME_PAT(@fname)

                                    , @currentlyWithClient
                                    
                                    , @active
                                    , @dos
                                    , @recID
								    , @refPracGroupServiceClassNameID) as p

  left join  dbo.PRACTITONERS_VIEW_EDITABLE (@clientID, @recID, @userID, @userGroup, @userRank)  as pe on pe.id    = p.id
  left join  users.dbo.USERS_DATA_CORE ('spedcare',null,null,null,null) as u on u.pracID = p.id and u.uid = p.PRAC_ASP_ID

  ) as pv


  outer apply (
    select top 1
      isnull(ggscn.GROUP_SERVICE_CLASS_NAME,'') as groupServiceClassName
    from dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as ggscn
    where (ggscn.GROUP_SERVICE_CLASS_NAME_ID = pv.orpGroupServiceClassNameID)
  ) as oscn

  /* Is Practitioner a ParaProfessional? */
   /* Note see :https://www.understood.org/en/school-learning/for-educators/learning-and-thinking-differences-basics/paraprofessionals-what-you-need-to-know */

  outer apply (
     select top 1
	   isParaProf = 1
     from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as g1
     where (
           (g1.GROUP_SERVICE_CLASS_PARTITION_ID = 400)
       and (g1.GROUP_ID = pv.groupID)
	   and (g1.GROUP_SERVICE_CLASS_NAME_ID is not null)
     )
  ) as paraProfs

  where (1=1) and ((@canEdit is null) or (pv.canEdit = @canEdit))
  order by pv.clientName, pv.lastName, pv.firstName
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRACTITONERS_VIEW] TO [webuser]
GO
