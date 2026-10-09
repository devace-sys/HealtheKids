USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITONERS_VIEW_CORE] (
     @source     INT
   , @clientID   BIGINT
   , @patID      BIGINT
   , @groupID    BIGINT
   , @lnamePat   NVARCHAR(50)
   , @fnamePat   NVARCHAR(50)

   , @currentlyWithClient  bit

   , @active     BIT
   , @refDate    DATETIME
   , @recID      BIGINT
   , @refPracGroupServiceClassNameID BIGINT
)

RETURNS TABLE

/***************************************************************************
 * PRACTITIONERS_VIEW_CORE */
/**
 * Returns a table of practitioners that match the given parameters.
 * Each client has one or more practitioners.
 *
 * @param  clientID        ID of client
 * @param  lnamepat        Last name pattern
 * @param  fnamepat        First name pattern
 * @param  recID           Practitioner ID
 * @param  active          If practitioner is active
 * @return                 Table of practitioner data
 ***************************************************************************/

AS RETURN(

select
    pc.SOURCE,
    p.PRACTITIONER_ID                         as id,
    isnull(p.LAST_NAME,'') + ', '
    + isnull(p.FIRST_NAME,'')                 as name,
    p.LAST_NAME                               as lastName,
    p.FIRST_NAME                              as firstName,
    p.EMAIL                                   as email,
    p.PHONE_NUMBER                            as phone,
    p.FAX_NUMBER                              as fax,
    p.street1,
    p.street2,
    p.city,
    p.usState                                 as [state],
    p.zip5,
    p.zip4,
    g1.GROUP_NAME                             as groupNameDisp,
    g1.GROUP_ID                               as groupIDDisp,
    g2.GROUP_NAME                             as groupNameRept,
    g2.GROUP_ID                               as groupIDRept,
    p.clientEmployeeID,
    p.claim_TCM,
    p.claim_TCMEffectiveDate,
    pn.note                                   as notes,
    pc.CLIENT_ID                              as clientID,
    c.CLIENT_NAME                             as clientName,
    c.CLIENT_CDS                              as clientCDS,
    pc.DATE_START                             as startDate,
    pc.DATE_END                               as endDate,
    p.ACTIVE                                  as active,
    p.DATE_CREATED,
    p.DATE_MODIFIED,
    p.createdByUserID,
    pn.id                                     as pracNoteRecID,
    gd.PRACTITIONER_GROUP                     as pracGroupDispRecID,
    gr.PRACTITIONER_GROUP                     as pracGroupReptRecID,
    pc.PRACCLIENT_ID                          as pracClientRecID,
    p.PRAC_ASP_ID,
    p.UserID,
    p.SUBMIT_CLAIMS                           as submitClaims,
    p.submitClaimsEffectiveDate               as submitClaimsEffectiveDate,
    p.npiNumber,
    p.isValidMcalOrp,
    p.isValidMcalOrpLastValidated,

    p.employeeRelationshipID,
    er.TYPE_NAME as employeeRelationship,
    p.includeInFinRepts,

    coalesce (   convert(varchar,sr.dos,101)
               , 'Never') as latestServiceDate,

    coalesce (   convert(varchar,sr.dosEarliest,101)
               , 'Never') as earliestServiceDate,

    coalesce (   convert (varchar, p.DATE_MODIFIED, 101)
               ,  convert (varchar, p.DATE_CREATED,  101)
               , 'Unknown') as modifedOrCreatedOn,

	p.cprCertEffectiveDate,
	p.cprCertExpirationDate,
	p.qualificationsJSONData,
	p.deptHead,
	p.displayPercent,
	p.displayMoney,
	p.acesCertCompletedOn ,

    p.participatesInLEABOP ,
    p.participatesInCYBHI,
	p.deptHeadCanSeeEntirePracticeFamilyInDeptReviewReports,
	p.dob,
	gender = isnull(p.gender,'U'),
	p.ssn,
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

  from
  (
    select pdc.*
    from dbo.PRACTITIONERS_DATA_CORE (isnull(@source,0), @clientID, @patID, @refDate, @refPracGroupServiceClassNameID) as pdc
  ) as pc

  join       dbo.PRACTITIONER_Practitioner          as p   on p.PRACTITIONER_ID  = pc.PRACTITIONER_ID
  join       dbo.EMPLOYMENT_RELATIONSHIPS           as er  on er.TYPE_ID         = p.employeeRelationshipID
  join       dbo.CLIENTS_CLIENT                     as c   on c.CLIENT_ID        = pc.CLIENT_ID
  join       dbo.PRACTITIONER_GROUPS_VIEW_DISP()    as gd  on gd.PRACTITIONER_ID = p.PRACTITIONER_ID
  join       dbo.GROUP_GROUP                        as g1  on g1.GROUP_ID        = gd.GROUP_ID
  left join  dbo.PRACTITIONER_GROUPS_VIEW_REPT()    as gr  on gr.PRACTITIONER_ID = p.PRACTITIONER_ID
  left join  dbo.GROUP_GROUP                        as g2  on g2.GROUP_ID        = gr.GROUP_ID
  left join  dbo.INPUT_NOTES_PRAC(@clientID,@recID) as pn  on pn.pracID          = p.PRACTITIONER_ID

  cross apply (
    select top 1
          max(sr1.dos) as dos
	    , min(sr1.dos) as dosEarliest
      from dbo.SERVICE_RECORDS as sr1
      where (
            (sr1.clientID = pc.CLIENT_ID)
        and (sr1.pracID   = pc.PRACTITIONER_ID)
	  )
   ) as sr

   /*cross apply (
     select top 1
      MAX(cc.SERVICE_DATE) as dos
      from dbo.CLAIM_Claim as cc
      where
            cc.CLIENT_ID       = pc.CLIENT_ID
        and cc.PRACTITIONER_ID = pc.PRACTITIONER_ID
    ) as cc
   */

  where (
   (1=1)
    and ((@clientID is null)  or (pc.CLIENT_ID       = @clientID))
    and ((@groupID  is null)  or (g1.GROUP_ID        = @groupID))
    and ((@active   is null)  or (p.ACTIVE           = @active))
    and ((@recID    is null)  or (p.PRACTITIONER_ID  = @recID))
    and ((@lnamepat is null)  or (p.LAST_NAME  like @lnamepat))
    and ((@fnamepat is null)  or (p.FIRST_NAME like @fnamepat))

    and (
      (@currentlyWithClient IS NULL ) or (@currentlyWithClient = p.currentlyWithClient)
    )
    
  )
 )

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRACTITONERS_VIEW_CORE] TO [webuser]
GO
