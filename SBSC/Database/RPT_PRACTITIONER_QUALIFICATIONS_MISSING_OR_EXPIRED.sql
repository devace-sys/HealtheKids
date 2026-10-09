USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PRACTITIONER_QUALIFICATIONS_MISSING_OR_EXPIRED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PRACTITIONER_QUALIFICATIONS_MISSING_OR_EXPIRED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_PRACTITIONER_QUALIFICATIONS_MISSING_OR_EXPIRED] (
    @userID               bigint
  , @userGroup            int
  , @userRank             int 
  , @clientID             bigint
)
returns
table
as
return
(
with
cte_base
as
(
  select 
      pqvc.clientName
    , pqvc.lastName
    , pqvc.firstName
    , pqvc.dispGroupName
	, pqvc.npiNumber
    , employmentRelationship = er.TYPE_NAME
    , pqvc.hasQualificationsData
    , pqvc.primaryQualification
    , licenseOrCredentialName = gg.GROUP_NAME
    , pqvc.licenseNum
	, pqvc.pracCreatedOn
    , pqvc.clientID
    , pqvc.pracID
  from dbo.Practitioner_Qualifications_View_Core (@clientID,null,1,1,1) as pqvc
  join dbo.EMPLOYMENT_RELATIONSHIPS                                     as er on er.TYPE_ID  = pqvc.employeeRelationshipID
  join dbo.GROUP_Group                                                  as gg on gg.GROUP_ID = pqvc.pracTypeID
  where (
        (pqvc.dispGroupID  not in (8,12,52,28,54,274,275,276)) /* Exclude disps that dont have quals */  
    and (pqvc.ranking = 1)
    and (pqvc.expiresInDays < 15)
    and (pqvc.employeeRelationshipID != 30)
	and ((pqvc.leaBopSubmitClaims = 1) or (pqvc.cybhiSubmitClaims = 1))
	and (pqvc.clientID != 112)
  )
)
,
cte_combo
as
(

  select 
    b1.*
  from cte_base as b1 
  where 
    (b1.primaryQualification = 1)

  union all

  select 
    b2.* 
  from cte_base as b2 
  where (
        (b2.primaryQualification = 0)
    and (b2.dispGroupName           like ('%(PPS)%'))
    and (b2.licenseOrCredentialName like ('%(No PPS)%'))
  )

)
,
cte_agg
as
(
  select     
      t1.clientName
    , t1.lastName
    , t1.firstName
    , t1.dispGroupName
    , t1.npiNumber
	, t1.employmentRelationship
    , t1.hasQualificationsData
    , t1.pracCreatedOn
	, t1.clientID
    , t1.pracID
    , licenseNums = string_agg(t1.licenseNum,' | ')

  from cte_combo as t1
  group by 
      t1.clientName
    , t1.lastName
    , t1.firstName
    , t1.dispGroupName
    , t1.npiNumber
	, t1.employmentRelationship
    , t1.hasQualificationsData
    , t1.pracCreatedOn
	, t1.clientID
    , t1.pracID
)
select top (dbo.CONST_MAX_ROWS())
    t1.*
  , sr2.latestDOS
  , pracCreatedOnStr = dbo.RPT_DATE_FMT(t1.pracCreatedOn)
  , latestDosStr     = dbo.RPT_DATE_FMT(sr2.latestDOS)  
  , expiredStr       = dbo.BIT_TO_MSG(t1.hasQualificationsData,'Yes','No')
  , missingStr       = dbo.BIT_TO_MSG(t1.hasQualificationsData,'No','Yes')

from cte_agg as t1

outer apply (
  /* Uses [PRAC_DOS_W_STATE] index */
  select 
    latestDOS = max(sr1.dos)
  from dbo.SERVICE_RECORDS as sr1
  where 
    ((sr1.pracID = t1.pracID) and (sr1.dos is not null) and (sr1.id is not null))
) as sr2

order by 
    t1.clientName    asc
  , t1.lastName      asc
  , t1.firstName     asc
  , t1.dispGroupName asc

)
GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  dbo.RPT_PRACTITIONER_QUALIFICATIONS_MISSING_OR_EXPIRED TO [webuser]
GO