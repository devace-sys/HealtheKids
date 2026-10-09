USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Import_From_Patient_Goal_Records_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Import_From_Patient_Goal_Records_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Import_From_Patient_Goal_Records_View_Core] (
    @clientID  bigint
  , @patID     bigint
  , @dos	   date
  , @term      varchar(256) /* Possible future use*/
  , @active    bit
  , @recID     bigint
)

RETURNS TABLE

 /***************************************************************************
  * Import_From_Patient_Goal_Records_View_Core */
 /**
  * Returns imported patient goal records.
  *
  * @return table
  ***************************************************************************/

AS RETURN

select 
	  ipgr.id
    , ipgr.clientID
    , ipgr.patID
    , [name] = ipgr.goalText
    , ipgr.ssid
    , ipgr.schoolCDSCode
    , ipgr.startDate
    , ipgr.endDate
	, startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(ipgr.startDate)
	, endDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(ipgr.endDate)
    , ipgr.seisID
    , ipgr.districtID
    , ipgr.lastName
    , ipgr.firstName
    , ipgr.birthdate
    , ipgr.grade
    , ipgr.schoolOfAttendance
    , ipgr.districtOfService
    , ipgr.caseManager
    , ipgr.iepDate
    , ipgr.eligibilityStatus
    , ipgr.areaOfNeed
    , ipgr.goalNumber
    , ipgr.baseline
    , ipgr.goalText
    , ipgr.purposeOfGoal
    , ipgr.[standard]
    , ipgr.personResponsible
    , ipgr.objective1
    , ipgr.objective1Met
    , ipgr.objective1DateMet
	, objective1MetOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(ipgr.objective1DateMet)
    , ipgr.objective2
    , ipgr.objective2Met
    , ipgr.objective2DateMet
	, objective2MetOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(ipgr.objective2DateMet)
    , ipgr.objective3
    , ipgr.objective3Met
    , ipgr.objective3DateMet	
	, objective3MetOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(ipgr.objective3DateMet)
    , ipgr.annualReview
    , ipgr.comments
    , ipgr.goalMet
    , ipgr.addedOn
    , ipgr.addedBy
    , ipgr.updatedBy
    , ipgr.updatedOn
    , ipgr.lastAffirmedPR
    , ipgr.created
    , ipgr.createdBy
    , ipgr.lastModified
    , ipgr.lastModifiedBy
    , ipgr.active
from dbo.Import_From_Patient_Goal_Records as ipgr
where
(
	  (1=1)
  and ((@recID    is null) or (ipgr.id       = @recID))
  and ((@clientID is null) or (ipgr.clientID = @clientID))
  and ((@patID    is null) or (ipgr.patID    = @patID))
  and ((@active   is null) or (ipgr.active   = @active))
  and (@dos between ipgr.startDate and ipgr.endDate)
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[Import_From_Patient_Goal_Records_View_Core] TO [webuser]
GO
