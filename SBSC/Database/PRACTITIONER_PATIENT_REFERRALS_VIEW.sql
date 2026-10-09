USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (
    SELECT *
    FROM sys.objects
    WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_REFERRALS_VIEW')
      AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT')
)
DROP FUNCTION dbo.PRACTITIONER_PATIENT_REFERRALS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_REFERRALS_VIEW] (
      @userID              BIGINT
    , @userGroup           INT
    , @userRank            INT
    , @clientID            BIGINT
    , @pracID              BIGINT
    , @referringByUserID   BIGINT
    , @patID               BIGINT
    , @filterAsComplete    BIT
    , @active              BIT
    , @recID               BIGINT
) 
RETURNS TABLE

/***************************************************************************
 * PRACTITIONER_PATIENT_REFERRALS_VIEW */
/**
 ***************************************************************************/
AS RETURN
(

WITH 
cte_p1
AS
(
    SELECT 
          ppr.*
        , patName                         = pap.CONCAT_NAME
        , startDateStr                    = dbo.RPT_DATE_FMT(ppr.startDate)
        , startDateStrYMD                 = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppr.startDate)
        , startTimeStr                    = dbo.RPT_TIME_FMT(ppr.startTime, 0)
        , startTimeHMS                    = dbo.RPT_TIME_FMT_HH_MM_SS(ppr.startTime, 0)
        , approvalRejectionDateStr        = dbo.RPT_DATE_FMT(ppr.approvalRejectionDate)
        , approvalRejectionDateStrYMD     = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppr.approvalRejectionDate)
        , approvalRejectionTimeStr        = dbo.RPT_TIME_FMT(ppr.approvalRejectionTime, 0)
        , approvalRejectionTimeHMS        = dbo.RPT_TIME_FMT_HH_MM_SS(ppr.approvalRejectionTime, 0)
        , expirationDateStr               = dbo.RPT_DATE_FMT(ppr.expirationDate)
        , expirationDateYMD               = dbo.RPT_DATE_FMT_YYYY_MM_DD(ppr.expirationDate)
        , expirationTimeStr               = dbo.RPT_TIME_FMT(ppr.expirationTime, 0)
        , expirationTimeYMD               = dbo.RPT_TIME_FMT_HH_MM_SS(ppr.expirationTime, 0)	
		, referredByPrivatePersonFirstLastName  = trim(isnull(m.FirstName,N'') + N' ' + isnull(m.LastName,N''))
		, isUsedStr                             = dbo.RPT_BIT_TO_YN(ppr.isUsed)
    FROM dbo.PRACTITIONER_PATIENT_REFERRALS AS ppr
    JOIN dbo.CLIENTS_Client                 AS clc  ON clc.CLIENT_ID       = ppr.clientID
    LEFT JOIN dbo.PATIENTS_Patient          AS pap  ON pap.PATIENT_ID      = ppr.patID
    LEFT JOIN dbo.PRACTITIONER_Practitioner AS prp  ON prp.PRACTITIONER_ID = ppr.pracID
    LEFT JOIN users.dbo.Users               AS u    ON u.userrid           = ppr.referringByUserID
	LEFT JOIN users.dbo.Membership          as m    on m.UserId            = u.UserId
    WHERE ((1 = 1)
        AND ((@clientID         IS NULL) OR (ppr.clientID = @clientID))
        --AND ((@pracID           IS NULL) OR (ppr.pracID = @pracID))
        --AND ((@referringByUserID IS NULL) OR (NULLIF(ppr.referringByUserID, 0) = NULLIF(@referringByUserID, 0)))
        AND ((@patID            IS NULL) OR (ppr.patID = @patID))
        AND ((@recID            IS NULL) OR (ppr.id = @recID))
        AND ((@active           IS NULL) OR (ppr.active = @active))
        AND ((@filterAsComplete IS NULL) OR (ppr.isUsed = @filterAsComplete))
    )
)
,
cte_p2
as
(
  SELECT 
      p1.*
    , referalIsFromPublicForm         = CONVERT(BIT, (IIF(pf2.id IS NULL, 0, 1)))
    , publicFormID                    = ISNULL(pf2.id, -1)
    , publicFormCreatedOnStr          = dbo.RPT_DATE_FMT(pf2.created)
    , publicFormPatientDOBStr         = dbo.RPT_DATE_FMT(pf2.patientDOB)
    , publicFormPatientFirstName      = ISNULL(pf2.patientFirstName, '')
    , publicFormPatientLastName       = ISNULL(pf2.patientLastName, '')
    , publicFormStudentID             = ISNULL(pf2.studentID, '')
    , publicFormTeacherName           = ISNULL(pf2.teacherName, '')
    , publicFormResponderRelationship = ISNULL(pf2.responderRelationship, '')
    , publicFormResponderFirstName    = ISNULL(pf2.responderFirstName, '')
    , publicFormResponderLastName     = ISNULL(pf2.responderLastName, '')
    , publicFormResponderEmail        = ISNULL(pf2.responderEmail, '')
    , publicFormResponderPhone        = ISNULL(pf2.responderPhone, '')
    , publicFormReferralDetailNote    = ISNULL(pf2.referralDetailNote, '')
	
FROM cte_p1 AS p1

OUTER APPLY (
    SELECT TOP 1
          pf1.id
        , pf1.patientDOB
        , pf1.patientFirstName
        , pf1.patientLastName
        , pf1.studentID
        , pf1.responderFirstName
        , pf1.responderLastName
        , pf1.responderEmail
        , pf1.responderPhone
        , pf1.responderRelationship
        , pf1.teacherName
        , pf1.referralDetailNote
        , pf1.created
    FROM dbo.PRACTITIONER_PATIENT_REFERRALS_PUBLIC_MENTAL_HEALTH_REQUEST_REFERRAL_FORM_RESPONSES AS pf1
    WHERE pf1.referralID = p1.id
) AS pf2
)
,
cte_p3
as
(
  select 
    p2.* 
  , referredByPublicPersonFirstLastName = trim(publicFormResponderFirstName + N' ' + publicFormResponderLastName)
  from cte_p2 as p2
)
select 
    p3.* 
  , referredByPersonFirstLastName = iif((p3.referalIsFromPublicForm = 1),p3.referredByPublicPersonFirstLastName,p3.referredByPrivatePersonFirstLastName)
from cte_p3 as p3
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[PRACTITIONER_PATIENT_REFERRALS_VIEW] TO [webuser]
GO