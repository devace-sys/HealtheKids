USE spedmon
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_Pop_Data_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Match_Pop_Data_Core
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_Pop_Data') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Match_Pop_Data
GO

/*-------------------------------
 * Create new
 *------------------------------*/


CREATE PROCEDURE [dbo].[Patient_Data_Imports_Match_Pop_Data] (
    @userID                         bigint
  , @userGroup                      int
  , @userRank                       int
  , @clientID                       bigint
  , @patientDataImportID            bigint

  , @testMode                       bit
  , @importResultsJSON              varchar(max) output
  , @requiresRollback               bit output
  , @requiresInternalFollowupNotif  bit output

  , @completedNormally              bit output

  , @isTestMode                    bit output
  , @earlyExit                     bit output

  , @rejectedValidateGradeDOBs     bit output

  , @unknown_problem               bit output


)
AS

BEGIN

set nocount on

/* Disable binary or truncated data errors
 * TODO: Factor this out once we have added min, max char size validation to structured data
 */


SET ANSI_WARNINGS OFF

declare @tranOpen                as bit = 0

set @unknown_problem             = 0;
set @earlyExit                   = 0;

SET @rejectedValidateGradeDOBs   = 0;

declare @startProcessingDateTime as datetime
declare @endProcessingDateTime   as datetime
declare @importErrorsJSON        as varchar(max) = '{}';
declare @unknownSiteID           as bigint = 0
declare @unknownSiteExistingIdx  as bigint

declare @validateGradeDOBs              bit;

declare @isOKToUpdateSiteDataForExistingPatients as bit = 0

declare @fuzzyMatchSitesByNameAndCode            as bit = 0

declare @totalPopFilesAreExpected                as bit = 0

set @startProcessingDateTime = getdate()
set @completedNormally = 0
set @tranOpen = 0

set @isTestMode       = @testMode;
set @requiresRollback = @testMode;

declare @possibleSiteIdsCSV varchar(max)

SELECT
@possibleSiteIdsCSV = STRING_AGG(convert(varchar(max),ss.SITE_ID),',') /* Note: the convert(varchar(max) is needed to make sure STRING_AGG does not trucate the results. */
FROM dbo.SITES_Site as ss
WHERE
(ss.SITE_CLIENT_ID = @clientID)

set @importResultsJSON = '{}';

declare @numOfIncomingPatDataRecords bigint;
declare @numNewPatRecsNeeded as bigint;
declare @numPatMatches as bigint

declare @okToCommitData as bit = 0

  /* debugs try-catch block */
  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

BEGIN TRY


/*############################################################################
 *# Load patient data import record
 *############################################################################*/

declare @structuredDataImportID bigint;
declare @fileUploadfileName     varchar(100);

declare @importRecordLogID      bigint;  -- it would have been less spaghetti-ish to pass this in as a param
                                         -- instead of looking it up with a select

declare @fileSubClass                        as varchar(256) = ''
declare @importFromFileReferenceID           as bigint       = 0


set @structuredDataImportID = null

select top 1
    @structuredDataImportID     = pdi.structuredDataImportID
  , @fileSubClass               = pdi.fileSubClass
  , @importFromFileReferenceID  = pdi.importFromFileReferenceID
  , @okToCommitData             = pdi.okToCommitData
  , @validateGradeDOBs          = pdi.validateGradeDOBs
FROM dbo.Patient_Data_Imports as pdi
WHERE (pdi.id = @patientDataImportID)

if (@isTestMode = 1)
begin

  if (@okToCommitData = 1)
    print 'Note: You are running in test mode, the value of OK to commit is ignored'
end

/* OK to commit value IS allowed to replace isTestMode value */
else
begin
  if (@okToCommitData = 0)
    set @isTestMode = 1
  else
    set @isTestMode = 0
end

set @requiresRollback = @isTestMode;


select top 1
  @fileUploadfileName = sdi."fileName"
FROM dbo.Structured_Data_Imports sdi
WHERE id = @structuredDataImportID

IF (@structuredDataImportID is null)
  RAISERROR(N'Unknown error; cannot find or identify the import being processed', 11, 1)

SELECT top 1
    @fuzzyMatchSitesByNameAndCode = fuzzyMatchSitesByNameAndCode
  FROM dbo.CLIENTS_Client AS clc
  WHERE (clc.CLIENT_ID = @clientID)

 -- SELECT
 --   @possibleSiteIdsCSV,
 --   @fuzzyMatchSitesByNameAndCode

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP() )
begin

  /* This is a total pop file so we allow it */
  set @isOkToUpdateSiteDataForExistingPatients = 1
  set @totalPopFilesAreExpected                = 1

end
else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS() )
begin

  /* This is a special ed file so we need to check if we are expecting total population files */
  SELECT top 1
    @totalPopFilesAreExpected = iif ((isnull(clc.COE,0)=1),0,1)
  FROM dbo.CLIENTS_Client AS clc
  WHERE (clc.CLIENT_ID = @clientID)

  if (@totalPopFilesAreExpected = 1)
  begin

    /* We are receiving a more reliable source of site data in the form of the total pop file so its is not ok to update*/
	set @isOKToUpdateSiteDataForExistingPatients = 0

  end
  else
  begin

    /* The only source of data we receive is the SpEdFile so we have no choice but to allow it */
	set @isOKToUpdateSiteDataForExistingPatients = 1

  end
end


set @unknownSiteID = dbo.GET_SITE_ID_UNKNOWN_SCHOOL ( @clientID )

/*-------------------------------
 * Incoming patients core data
 *
 * Note: This is for matching
 * purposes only.  Use the data
 * stored in the patient imports
 * record table for adding
 * new core patient data.
 *------------------------------*/

-- @incomingRecordsPatientData

declare @incomingRecordsPatientData as table (
    idx                       bigint identity(1,1)
  , patientDataImportRecordID bigint

  , lastName                  nvarchar(50)
  , lastNameMatchval          nvarchar(50)

  , firstName                 nvarchar(50)
  , firstNameMatchval         nvarchar(50)

  , preferredNickname         nvarchar(50)

  , middleName                nvarchar(50)
  , dateOfBirth               datetime
  , gender                    nvarchar(1)
  , ssid                      nvarchar(50)
  , studid                    nvarchar(50)
  , spEd                      char(1)

  , mCalConsent               bit

  --

  , [PrimaryInsuranceCompany]   [char](40)
  , [InsuranceMemberNumber]     [char](40)

  --

  , policyHolderName            varchar(512) null
  , policyGroupID               varchar(256) null

  , teacherOrCounselorName        varchar(256) null

  , requiresAttention         bit not null default(0)
  , requiresAttentionReason   varchar(MAX)
    unique clustered    (ssid,dateOfBirth,idx)
  , unique nonclustered (patientDataImportRecordID, idx)
)

/*-------------------------------
 * Existing patient core data
 * Note: This is for matching
 * purposes only.  Do not save
 * changes to this table.
 *------------------------------*/

declare @existingRecordsPatientData as table (
    idx                 bigint identity(1,1)
  , patientClientID     bigint

  , lastName                  nvarchar(50)
  , lastNameMatchval          nvarchar(50)

  , firstName                 nvarchar(50)
  , firstNameMatchval         nvarchar(50)

  , middleName          nvarchar(50)
  , dateOfBirth         datetime
  , gender              nvarchar(1)
  , ssid                nvarchar(50)
  , patID               bigint
  , requiresAttention   bit not null default(0)
  , requiresAttentionReason   varchar(MAX)
    unique clustered (ssid,dateOfBirth,idx)
  , unique nonclustered (patID, idx)
)

/*-------------------------------
 * Core patient data matches
 *------------------------------*/

declare @patMatches as table (
    idx               bigint identity(1,1)
  , incomingRecordIdx bigint
  , existingRecordIdx bigint
  , quality           int
  , patientDataImportRecordID bigint
  , patID             bigint
  , unique clustered (incomingRecordIdx, existingRecordIdx, idx)
  , unique nonclustered (patientDataImportRecordID, patID, idx)
)

/*-------------------------------
 * Incoming patients site
 * Note: This is for matching
 * purposes only.  Use the data
 * stored in the patient imports
 * record table for adding
 * new patient site data.
 *------------------------------*/

-- @incomingRecordsPatientSite

declare @incomingRecordsPatientSite as table (
    idx                       bigint identity(1,1)
  , patientDataImportRecordID bigint
  , cds7                      nvarchar(7)
  , siteName                  nvarchar(50)
  , studentID                 nvarchar(50)
  , grade                     nvarchar(20)

  , [attendanceTrackName]     varchar(256)

  , fuzzyMatchedSiteID        bigint null

    unique clustered (idx)
  , unique nonclustered (patientDataImportRecordID, idx)
)

/*-------------------------------
 * Existing patient site
 * Note: This is for matching
 * purposes only.  Do not save
 * changes to this table.
 *------------------------------*/

-- @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite

declare @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite as table (
    idx                       bigint identity(1,1)
  , patID                     bigint
  , patientSchoolID           bigint
  , siteID                    bigint
  , cds7                      nvarchar(7)
  , siteName                  nvarchar(50)
  , studentID                 nvarchar(50)
  , grade                     nvarchar(20)

  , [attendanceTrackName]     varchar(256)

    unique clustered (idx)
  , unique nonclustered (patientSchoolID, idx)
)

/*-------------------------------
 * Patient site matches
 *------------------------------*/

declare @patSite_PerfectMatches_inclNPSAndUnkSite as table (
    idx               bigint identity(1,1)
  , incomingSiteRecordIdx bigint
  , existingSiteRecordIdx bigint
  , patientDataImportRecordID bigint
  , unique clustered (incomingSiteRecordIdx, existingSiteRecordIdx, idx)
  , unique nonclustered (patientDataImportRecordID, idx)
)

declare @existingPatSiteRecsToDeac as table (
    idx                       bigint identity(1,1)
  , patID                     bigint
  , patientSchoolID           bigint
  , patientDataImportRecordID bigint

  , grade                     varchar(20)
  , studentID                 nvarchar(50)
  , startdate                 datetime

  , siteID                    bigint

)

-- @newSiteJoinRelationshipRequiredForExistingPatient

declare @newSiteJoinRelationshipRequiredForExistingPatient as table (
    idx               bigint identity(1,1)
  , incomingSiteRecordIdx bigint

  , patID bigint
  , siteID bigint
  , patientDataImportRecordID bigint

  , patientSchoolID           bigint

  , [attendanceTrackName]     varchar(256)

    unique clustered (idx)
  , unique nonclustered (incomingSiteRecordIdx, patientDataImportRecordID, idx)
)

-- @newSiteJoinRelationshipRequiredForNewPatient

declare @newSiteJoinRelationshipRequiredForNewPatient as table (
    idx               bigint identity(1,1)
  , incomingSiteRecordIdx bigint

  , newPatID bigint
  , existingSiteID bigint
  , patientDataImportRecordID bigint

  , patientSchoolID           bigint

  , [attendanceTrackName] varchar(256)

    unique clustered (idx)
  , unique nonclustered (incomingSiteRecordIdx, patientDataImportRecordID, idx)
)

/*-------------------------------
 * Incoming patients place
 * Note: This is for matching
 * purposes only.  Use the data
 * stored in the patient imports
 * record table for adding
 * new patient site data.
 *------------------------------*/

declare @incomingPatientsPlace as table (
    idx                       bigint identity(1,1)
  , patientDataImportRecordID bigint
  , address1                  varchar(1000)
  , address1MatchVal          varchar(1000)
  , address2                  varchar(1000)
  , city                      varchar(100)
  , cityMatchVal              varchar(100)
  , zip5                      varchar(5)

    unique clustered (idx)
  , unique nonclustered (patientDataImportRecordID, idx)
)

/*-------------------------------
 * Existing patient place
 * Note: This is for matching
 * purposes only.  Do not save
 * changes to this table.
 *------------------------------*/

declare @existingPatientsPlace as table (
    idx                       bigint identity(1,1)
  , patID                     bigint
  , patPlaceID                bigint
  , address1                  varchar(1000)
  , address1MatchVal          varchar(1000)
  , address2                  varchar(1000)
  , city                      varchar(100)
  , cityMatchVal              varchar(100)
  , state                     varchar(2)
  , zip5                      varchar(5)
)

/*-------------------------------
 * Patient place matches
 *------------------------------*/

declare @patPlaceMatches as table (
    idx               bigint identity(1,1)
  , incomingRecordIdx bigint
  , existingRecordIdx bigint
  , patientDataImportRecordID bigint
  , quality           int

    unique clustered (idx) ,
    unique nonclustered (incomingRecordIdx, existingRecordIdx, idx)
)

declare @newPlaceRequiredForExistingPatient as table (
    idx               bigint identity(1,1) ,
    incomingPlaceRecordIdx bigint,

    [PATIENT_ID] [bigint] NULL,
    [ADDRESS_1] [varchar](1000) NULL,
    [ADDRESS_2] [varchar](1000) NULL,
    [CITY] [varchar](100) NULL,
    [STATE] [varchar](2) NULL,
    [ZIP_5] [varchar](5) NULL,

    patientDataImportRecordID bigint ,

    patientPlaceID           bigint

    unique clustered (idx) ,
    unique nonclustered (incomingPlaceRecordIdx, idx)
)

declare @newPlaceRequiredForNewPatient as table (
    idx               bigint identity(1,1) ,
    incomingPlaceRecordIdx bigint ,

    [PATIENT_ID] [bigint] NULL,
    [ADDRESS_1] [varchar](1000) NULL,
    [ADDRESS_2] [varchar](1000) NULL,
    [CITY] [varchar](100) NULL,
    [STATE] [varchar](2) NULL,
    [ZIP_5] [varchar](5) NULL,

    patientDataImportRecordID bigint ,

    patientPlaceID           bigint ,

    newpatid                  bigint

    unique clustered (idx) ,
    unique nonclustered (incomingPlaceRecordIdx, idx)
)

/*############################################################################
 *# Person Contacts
 *############################################################################*/

/*
declare @incomingPatientsContacts as table (
    idx                       bigint identity(1,1)
  , patientDataImportRecordID bigint
  , [LAST_NAME] [varchar](255) NULL
  , [FIRST_NAME] [varchar](255) NULL
  , [PHONE] [varchar](255) NULL
  , [EMAIL] [varchar](255) NULL

    unique clustered (idx) ,
    unique nonclustered (patientDataImportRecordID, idx)
)
*/

/*
declare @existingPatientsContacts as table (
    idx                       bigint identity(1,1)
  , patID                     bigint
  , personID                  bigint
  , patientPersonID           bigint
  , [LAST_NAME] [varchar](255) NULL
  , [FIRST_NAME] [varchar](255) NULL
  , [PHONE] [varchar](255) NULL
  , [EMAIL] [varchar](255) NULL

    unique clustered (idx) ,
    unique nonclustered (personID, patientPersonID, idx)
)
*/

/*
declare @patContactsMatches as table (
    idx               bigint identity(1,1)
  , incomingRecordIdx bigint
  , existingRecordIdx bigint
  , patientDataImportRecordID bigint
  , quality           int

  unique clustered (idx) ,
  unique nonclustered (incomingRecordIdx, existingRecordIdx, idx)
)
*/


--

--NOTE: we are not following the pattern for
--      @newSiteJoinRelationshipRequiredForExistingPatient and
--      @newSiteJoinRelationshipRequiredForNewPatient,
--      because there will (for practical purposes) never be a new child added for an existing parent,
--      in the same way that new children are added for an existing school.
--      We don't care if there are duplicate entries for parents, when there are siblings with the same parent.

--

declare @newContactsRequiredForExistingPatient as table (
    idx               bigint identity(1,1) ,
    incomingPersonRecordIdx bigint,

  [LAST_NAME] [varchar](255) NULL,
  [FIRST_NAME] [varchar](255) NULL,

  [PHONE] [varchar](255) NULL,

  [EMAIL] [varchar](255) NULL,

  patientDataImportRecordID bigint ,
  personID                  bigint ,
  patientPersonID           bigint ,

  patid                  bigint

  unique clustered (idx) ,
  unique nonclustered (incomingPersonRecordIdx, idx)
)

declare @newContactsRequiredForNewPatient as table (
    idx               bigint identity(1,1) ,
    incomingPlaceRecordIdx bigint,

  [LAST_NAME] [varchar](255) NULL,
  [FIRST_NAME] [varchar](255) NULL,

  [PHONE] [varchar](255) NULL,

  [EMAIL] [varchar](255) NULL,


   patientDataImportRecordID bigint ,
   personID                  bigint ,
   patientPersonID           bigint ,
   newpatid                  bigint

  unique clustered (idx) ,
  unique nonclustered (incomingPlaceRecordIdx, idx)
)

/*
declare @incomingInsDataForExistingPatient as table (
    idx                  bigint identity(1,1)
  , patMatchIdx          bigint

  , carrierID                    bigint
  , carrierStr                   [char](40)

  , [InsuranceMemberNumber]     [char](40)

  , policyHolderName             varchar(512)
  , policyGroupID                varchar(256)

  , isExistingEntrySetDeac       bit not null default(0)
  , isExistingEntryNoChanges     bit not null default(0)

  --  unique clustered (idx)
  --, unique nonclustered (incomingSiteRecordIdx, patientDataImportRecordID, idx)
)

declare @incomingInsDataForNewPatient as table (
    idx                  bigint identity(1,1)

  , incomingIdx          bigint

  , newPatID             bigint

  , carrierID                    bigint
  , carrierStr                   [char](40)

  , [InsuranceMemberNumber]     [char](40)

  , policyHolderName             varchar(512)
  , policyGroupID                varchar(256)

  --  unique clustered (idx)
  --, unique nonclustered (incomingSiteRecordIdx, patientDataImportRecordID, idx)
)

*/

/*############################################################################
 *# Start processing file
 *############################################################################*/

declare @disqualifiedNonUniqueCsisIncomingData table( duppedCSISvalue nvarchar(max) )
  /* was nvarchar(50); certain outlier entries could cause a problem */
declare @disqualifiedNonUniqueCsisExistingData table( duppedCSISvalue nvarchar(max) )


/*-------------------------------
 * Existing patient core data
 *------------------------------*/

-- we need to know existing before we know about disqualified CSIS;
-- we need to know about disqualified CSIS before we start looking at places and contacts

 insert into @existingRecordsPatientData (
   patientClientID
 , lastName
 , firstName
 , middleName
 , dateOfBirth
 , gender
 , ssid
 , patID
)

select
    patientClientID     = pac.PATIENT_CLIENT_ID
  , lastName            = upper(trim(isnull(pap.LAST_NAME,N'')))
  , firstName           = upper(trim(isnull(pap.FIRST_NAME,N'')))
  , middleName          = upper(trim(isnull(pap.MIDDLE_NAME,N'')))
  , dateOfBirth         = pap.DATE_OF_BIRTH
  , gender              = trim(isnull(pap.SEX,N''))
  , ssid                = trim(isnull(pap.CSIS,N''))
  , patID               = pap.PATIENT_ID
from dbo.PATIENTS_CLIENT  as pac
join dbo.PATIENTS_PATIENT as pap on pap.PATIENT_ID = pac.PATIENT_ID
where (
      (pac.CLIENT_ID = @clientID)
  and (pap.ACTIVE != 'N')
)

/*############################################################################
 *# Load incoming core patient data
 *############################################################################*/

/*-------------------------------
 * From total pop
 *------------------------------*/

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

select @importRecordLogID=df.id
FROM dbo.Import_From_A_From_Client_ToSPED_Files df
where ( df.structuredDataImportID = @structuredDataImportID)

insert into @incomingRecordsPatientData
(
    patientDataImportRecordID

  , lastName

  , firstName

  , preferredNickname

  , middleName

  , dateOfBirth
  , gender
  , ssid
  , studid
  , spEd
  , mCalConsent

  , [PrimaryInsuranceCompany]
  , [InsuranceMemberNumber]

  , policyHolderName
  , policyGroupID

  , teacherOrCounselorName

)

---
select
    patientDataImportRecordID = dfr.ROW_NUM --pdi.id

  , lastName           = REPLACE(
                           trim(isnull(dfr.Last_Name,N'')) ,
                           '''', '`'

                         )

  , firstName          = REPLACE(
                           trim(isnull(dfr.First_Name,N'')) ,
                           '''', '`'
                         )

  , preferredNickname  = REPLACE(
                           trim(isnull(dfr.preferredNickname,N'')) ,
                           '''', '`'
                         )

  , middleName       = upper(trim(isnull(dfr.MI,N'')))
  , dateOfBirth      = CAST( dfr.DOB  as date )
  , gender           = trim(isnull(dfr.Sex,N''))
  , ssid             = trim(isnull(dfr.CSIS_SSID,N''))
  , studid           = trim(dfr.Student_ID)
  , sped             = dfr.SpEd_Marker
  , mCalConsent      = dbo.FLAG_STRING_TO_BIT( dfr.ParentalConsentMCAL, 0 )

  , insCarrierNameStr
  , beneficiaryID

  , policyHolderName
  , policyGroupID

  , teacherOrCounselorName = REPLACE(
                           trim(isnull(dfr.teacherOrCounselorName,N'')) ,
                           '''', '`'
                         )

from dbo.Import_From_A_From_Client_ToSPED_Files as df
JOIN dbo.Import_From_A_From_Client_ToSPED_File_rows dfr ON dfr.FROM_CLIENT_log_entry = df.id
where ( df.structuredDataImportID = @structuredDataImportID)
---

insert into @incomingRecordsPatientSite (
    patientDataImportRecordID
  , siteName
  , studentID
  , grade
  , cds7

  , attendanceTrackName
)

  select
    patientDataImportRecordID = dfr.ROW_NUM

    , siteName  = REPLACE(
                    dfr.School_Site_Name ,
                    '''', '`'
                  )

    , studentID = dfr.Student_ID
    , grade     = dfr.Grade
    , cds7      = dfr.School_Site_CDS7

    , attendanceTrackName = trim(isnull( dfr.attendanceTrackName , ''))

  from dbo.Import_From_A_From_Client_ToSPED_Files as df
  JOIN dbo.Import_From_A_From_Client_ToSPED_File_rows dfr ON dfr.FROM_CLIENT_log_entry = df.id
  where (
    df.structuredDataImportID = @structuredDataImportID
    AND
    (df.patientDataImportID = @patientDataImportID)
  )

end

/*-------------------------------
 * From SpEd file
 *------------------------------*/

else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
begin

select @importRecordLogID=df.id
FROM dbo.[Import_From_A.5_SERVICES_From_Client_Files] df
where ( df.structuredDataImportID = @structuredDataImportID)

insert into @incomingRecordsPatientData
(
    patientDataImportRecordID

  , lastName

  , firstName

  , preferredNickname

  , middleName
  , dateOfBirth
  , gender
  , ssid
  , studid
  , spEd
  , mCalConsent
)
    select
      patientDataImportRecordID = MIN(t2.id)


  , lastName          = trim(isnull(t2.[Last Name],N''))

  , firstName         = trim(isnull(t2.[First Name],N''))

  , preferredNickname  = trim(isnull(t2.preferredNickname , N''))

    , middleName       = N''
    , dateOfBirth      = CAST( t2.DOB  as date )
    , gender           = trim(isnull(t2.Gender,N''))
    , ssid             = trim(isnull(t2.[Student SSID],N''))
    , studid           = trim(isnull(t2.[Student ID (District SIS)],N''))
    , sped             = N'Y'
    , mCalConsent      = dbo.FLAG_STRING_TO_BIT( t2.[Medi-cal billing], 0)

  from dbo.[Import_From_A.5_SERVICES_From_Client_Files]     as t1

  -- note: I broke the pattern used above, aliasing these as t1 and t2
  -- instead of df and dfr

  join dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as t2 on t2.File_import_log_entry = t1.id
  where
    (t1.id = @importFromFileReferenceID)
     -- TODO: if I run into any problems, this is the first place I'd look.
  GROUP BY
    t2.[Last Name],
    t2.[First Name],
    t2.DOB,
    t2.Gender,
    t2.[Student SSID],
    t2.[Student ID (District SIS)],
    t2.[Medi-cal billing] ,
    t2.preferredNickname


insert into @incomingRecordsPatientSite (
    patientDataImportRecordID
  , siteName
  , attendanceTrackName
  , studentID
  , grade
  , cds7
)
select
    t2.id
  , t2.[School of Attendance]
  , trim(isnull( t2.attendanceTrackName , ''))
  , t2.[Student ID (District SIS)]
  , null
  , RIGHT(
      t2.[School CDS Code]
      , 7)

  from @incomingRecordsPatientData ipd
  CROSS APPLY (
  SELECT TOP 1 t2.*
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as t2
  JOIN dbo.[Import_From_A.5_SERVICES_From_Client_Files]     as t1 on t2.File_import_log_entry = t1.id
  WHERE ipd.patientDataImportRecordID = t2.id
  ) t2

end

IF ( @fuzzyMatchSitesByNameAndCode = 1 )
BEGIN

  ;with distinct_schools as (
    SELECT DISTINCT
        siteName
      , cds7
    FROM
     @incomingRecordsPatientSite
  ),
  fuzzys as (
    SELECT
      *,
      [dbo].[SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE] (
        @clientID                 ,
        @possibleSiteIdsCSV       ,
        d_s.siteName              ,
        d_s.cds7 ) fuzzySiteID
    FROM
      distinct_schools d_s
    /*
    OUTER APPLY [dbo].[SITE_ATTEMPT_MATCHES_BY_NAME_AND_CODE] (
        @clientID                 ,
        @possibleSiteIdsCSV       ,
        d_s.siteName              ,
        d_s.cds7
    ) o1 */
  )
  UPDATE t1
    SET fuzzyMatchedSiteID = fuzzySiteID
  FROM @incomingRecordsPatientSite t1
  JOIN fuzzys fz ON fz.siteName = t1.siteName AND fz.cds7 = t1.cds7

END

--SELECT * FROM @incomingRecordsPatientData

  -- SELECT * FROM  @incomingRecordsPatientSite

INSERT INTO @disqualifiedNonUniqueCsisExistingData
select CSIS from
(
  SELECT
  ssid CSIS, COUNT(DISTINCT e_p.patID) "count"
FROM
@existingRecordsPatientData e_p
WHERE ISNULL(ssid,'') != ''
GROUP BY ssid
) s1 where "count" > 1

UPDATE @incomingRecordsPatientData
  SET requiresAttention = 1,
      requiresAttentionReason = 'Cannot use this CSIS for matching; is non-unique in existing data for this client. '
WHERE SSID IN (
          SELECT duppedCSISvalue from @disqualifiedNonUniqueCsisExistingData
      )

UPDATE @existingRecordsPatientData
  SET requiresAttention = 1,
      requiresAttentionReason = 'Cannot use this CSIS for matching; is non-unique in existing data for this client. '
WHERE SSID IN (
          SELECT duppedCSISvalue from @disqualifiedNonUniqueCsisExistingData
      )

INSERT INTO @disqualifiedNonUniqueCsisIncomingData
select CSIS from
(
  SELECT
  ssid CSIS, COUNT(DISTINCT i_p.patientDataImportRecordID) "count"
FROM
@incomingRecordsPatientData i_p
WHERE ISNULL(ssid,'') != ''
GROUP BY ssid
) s1 where "count" > 1

UPDATE @incomingRecordsPatientData
  SET requiresAttention = 1,
      requiresAttentionReason = ISNULL( requiresAttentionReason, '') + 'Cannot use this CSIS for matching; is non-unique in incoming data from this upload.'
WHERE SSID IN (
          SELECT duppedCSISvalue from @disqualifiedNonUniqueCsisIncomingData
      )

declare @invalidDOBs TABLE
(
  ID bigint
  ,[log_entry] bigint

  ,[Last_Name] varchar(75)
  ,[First_Name] varchar(75)

  ,calcAge      int
  ,[Grade]      varchar(10)

  ,isTooYoung   int
  ,isTooOld     int

  ,[Student_ID] varchar(25)
  ,[CSIS_SSID]  varchar(12)

  ,[DOB]        varchar(10)
  ,[Sex]        char(1)
)

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin


  if (@validateGradeDOBs = 1)
  begin

    -- not a decimal; extreme precision is not needed here
    declare @maxInvalidDOBsAllowed bigint =
      (SELECT COUNT(*) / 5 FROM @incomingRecordsPatientData)

    INSERT INTO @invalidDOBs
    SELECT * FROM [dbo].[Patient_Data_Imports_Totpop_Invalid_DOB_Ages_View] (
      @importRecordLogID
    )

    if ( ( SELECT COUNT(*) FROM @invalidDOBs ) > @maxInvalidDOBsAllowed )
    begin

      -- NOTE: Earlier I didn't bother to implement any human-readable error messages for this condition as it is a rare case;
      --       I figured it wouldn't be impossible to troubleshoot should we ever encounter it

      SET @requiresRollback = 1
      SET @completedNormally = 0

      SET @earlyExit = 1
          -- @earlyExit only set 1 due to the age/grade validation, but we might invent other early exits later

      SET @rejectedValidateGradeDOBs = 1

      GOTO REPORT_OUT_AND_CLEANUP


    end

  end


  insert into @incomingPatientsPlace
  (
    patientDataImportRecordID
  , address1
  , address2
  , city
  , zip5
)
select

    patientDataImportRecordID = dfr.ROW_NUM

  , address1 = REPLACE(
                 dfr.Address1 ,
                 '''', '`'
               )

  , address2 = REPLACE(
                 dfr.Address2 ,
                 '''', '`'
               )

  , city     = REPLACE(
                 dfr.City ,
                 '''', '`'
               )

  , zip5     = dfr.Zip5

FROM dbo.Import_From_A_From_Client_ToSPED_Files as df
JOIN dbo.Import_From_A_From_Client_ToSPED_File_rows dfr ON dfr.FROM_CLIENT_log_entry = df.id

where (
      (df.patientDataImportID = @patientDataImportID)
   AND df.structuredDataImportID = @structuredDataImportID
)

end
  -- no else; we only care about places and contacts for TPOP files


/*-------------------------------
 * Existing patient site data
 *------------------------------*/

insert into @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite
(
    patID
  , patientSchoolID

)

select
    er.patID
  , patientSchoolID = MAX(ps.PATIENT_SCHOOL_ID)

from @existingRecordsPatientData as er
join dbo.PATIENTS_School         as ps on ps.PATIENT_ID = er.patID


  -- NOTE: We're assuming here that the SITES_Site will always exist, but the PATIENTS_School entry may not.
  --       We're only interested in finding and using the PATIENTS_School join entry, or creating one if necessary
  --       We won't be INSERTing UPDATEing the SITES_Site in any way.

  --       Also, since the PATIENTS_School has an END_DATE, we will not be UPDATEing the PATIENTS_School table
  --       if we get a new student ID.
  --       Instead of an UPDATEing student ID, we will close out an existing row by populating the END_DATE
  --       and INSERTing a new row.  By orders of Terry, a while back.

WHERE
  er.requiresAttention != 1
  AND
  (
    ps.END_DATE IS NULL
    OR
    cast(ps.END_DATE as date) >= cast(@startProcessingDateTime as date)
  -- NOTE: In existing data, the PATIENTS_School END_DATE is a future date, in the vast majority of cases, not null.
  --       I'm not aware that we're asking the kiddos' graduation dates, or have an option to enter it in a screen,
  --       so this is being filled in with some probably buggy guesswork, in code, somewhere behind the scenes.

           -- TODO ????
  )

GROUP BY
    er.patID


  -- SELECT * FROM  @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite

/* Having found the MAX(PATIENTS_SCHOOL_ID) for each patID,
   get the grade, stuID, siteID...
 */

UPDATE ex_s
--
SET
 ex_s.studentID = p_s.STUDENT_ID,
 ex_s.grade     = p_s.grade,
 ex_s.siteID    = p_s.SITE_ID,
 ex_s.cds7      = ss.SITE_CDS,
 ex_s.siteName  = ss.SITE_NAME ,

 ex_s.attendanceTrackName = TRIM( ISNULL( p_s.attendanceTrackName, '' ))

FROM @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite ex_s
JOIN dbo.PATIENTS_School p_s ON ex_s.patientSchoolID = p_s.PATIENT_SCHOOL_ID
join dbo.SITES_Site              as ss on ss.SITE_ID    = p_s.SITE_ID

  --  SELECT * FROM  @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite

/*-------------------------------
 * Incoming patient place
 *------------------------------*/


--SELECT @structuredDataImportID structuredDataImportID, @patientDataImportID patientDataImportID

/*
SELECT * FROM @incomingRecordsPatientData ORDER BY patientDataImportRecordID ASC
SELECT * FROM @existingRecordsPatientData ORDER BY lastName ASC
*/


/*-------------------------------
 * Existing patient Place Data
 *------------------------------*/

INSERT INTO @existingPatientsPlace (
    patID
  , patPlaceID
  , address1
  , address2
  , city
  , "state"
  , zip5
)
select
    er.patID
  , patPlaceID = p_pl.ID
  , address1   = p_pl.ADDRESS_1
  , address2   = p_pl.ADDRESS_2
  , city       = p_pl.CITY
  , "state"    = p_pl."STATE"
  , zip5       = p_pl.ZIP_5
from @existingRecordsPatientData as er
JOIN dbo.PATIENT_PLACES p_pl ON er.patID = p_pl.PATIENT_ID
WHERE
  er.requiresAttention != 1


/*############################################################################
 *# Further modify data in working table to modify some of the
 *# values to make matching easier
 *############################################################################*/

update ir
set
  ir.firstNameMatchval = UPPER(
                           REPLACE(
                             REPLACE(
                               REPLACE( ir.firstName, N' ', N'' ) ,
                               N'-' ,
                               N''
                             ) ,
                             N'''' ,
                             N''
                           )
                         )

, ir.lastNameMatchval  = UPPER(
                           REPLACE(
                             REPLACE(
                               REPLACE( ir.lastName, N' ', N'' ) ,
                               N'-' ,
                               N''
                             ) ,
                             N'''' ,
                             N''
                           )
                         )

from @incomingRecordsPatientData as ir

update er
set
  er.firstNameMatchval = UPPER(
                           REPLACE(
                             REPLACE(
                               REPLACE( er.firstName, N' ', N'' ) ,
                               N'-' ,
                               N''
                             ) ,
                             N'''' ,
                             N''
                           )
                         )

, er.lastNameMatchval  = UPPER(
                           REPLACE(
                             REPLACE(
                               REPLACE( er.lastName, N' ', N'' ) ,
                               N'-' ,
                               N''
                             ) ,
                             N'''' ,
                             N''
                           )
                         )
from @existingRecordsPatientData as er

update i_pl
set
    cityMatchVal = REPLACE(REPLACE(i_pl.city,N' ',N''),N'-',N'')
  , address1MatchVal = REPLACE(
                 REPLACE(
                   REPLACE(
                     REPLACE( REPLACE( REPLACE(REPLACE(i_pl.address1,N' ',N''),N'-',N''), 'Street', N''), 'Drive', N'')
                     , 'Dr'
                     , N''
                   )
                   , 'Avenue'
                   , N''
                 )
                 , 'Ave'
                 , N''
              )

from @incomingPatientsPlace i_pl

update e_pl
set
    cityMatchVal = REPLACE(REPLACE(e_pl.city,N' ',N''),N'-',N'')
  , address1MatchVal = REPLACE(
                 REPLACE(
                   REPLACE(
                     REPLACE( REPLACE( REPLACE(REPLACE(e_pl.address1,N' ',N''),N'-',N''), 'Street', N''), 'Drive', N'')
                     , 'Dr'
                     , N''
                   )
                   , 'Avenue'
                   , N''
                 )
                 , 'Ave'
                 , N''
              )

from @existingPatientsPlace e_pl

/*############################################################################
 *#  Match Existing Patient Core Data
 *############################################################################*/

/*-------------------------------
 * Pass 1
 * Exact matches for ssid, dob
 * and name
 *------------------------------*/

insert into @patMatches
(
    incomingRecordIdx
  , existingRecordIdx
  , quality
  , patientDataImportRecordID
  , patID
)
  select
     incomingRecordIdx  = ir.idx
   , existingRecordsIdx = er.idx
   , quality            = 7
   , patientDataImportRecordID = ir.patientDataImportRecordID
   , patID              = er.patID
  from @existingRecordsPatientData  as er
  join @incomingRecordsPatientData  as ir on ((ir.ssid = er.ssid) and (ir.ssid != '') and (er.ssid !=''))
  where
  (
      (er.ssid        = ir.ssid)
    and (er.dateOfBirth = ir.dateOfBirth)

    and (er.lastNameMatchval    = ir.lastNameMatchval)
    and (er.firstNameMatchval   = ir.firstNameMatchval)

    and (ir.requiresAttention != 1)
    and (er.requiresAttention != 1)

  )

/*-------------------------------
 * Pass 2
 * Exact matches for ssid, dob
 * and up to 15 char diff in name
 *------------------------------*/

insert into @patMatches
(
    incomingRecordIdx
  , existingRecordIdx
  , quality
  , patientDataImportRecordID
  , patID
)
select
     incomingRecordIdx  = ir.idx
   , existingRecordsIdx = er.idx
   , quality            = 5
   , patientDataImportRecordID = ir.patientDataImportRecordID
   , patID              = er.patID
from @existingRecordsPatientData  as er
join @incomingRecordsPatientData  as ir on ((ir.ssid = er.ssid) and (ir.ssid != '') and (er.ssid !=''))
left join @patMatches                as m  on --(
                                           (m.incomingRecordIdx = ir.idx) --and (m.existingRecordIdx = er.idx))
where
(
      (er.ssid = ir.ssid)
  and (er.dateOfBirth = ir.dateOfBirth)
  and (dbo.Levenshtein(er.firstNameMatchval, ir.firstNameMatchval, 50)  <= 15)
  and (dbo.Levenshtein(er.lastNameMatchval,  ir.lastNameMatchval , 50)  <= 15)

    and (ir.requiresAttention != 1)
    and (er.requiresAttention != 1)

  and (m.idx is null)
)

/*-------------------------------
 * Pass 3
 * Exact matches on just ssid, dob
 *------------------------------*/

insert into @patMatches
(
    incomingRecordIdx
  , existingRecordIdx
  , quality
  , patientDataImportRecordID
  , patID
)
select
     incomingRecordIdx  = ir.idx
   , existingRecordsIdx = er.idx
   , quality            = 4
   , patientDataImportRecordID = ir.patientDataImportRecordID
   , patID              = er.patID
from @existingRecordsPatientData  as er
join @incomingRecordsPatientData  as ir on ir.ssid = er.ssid and ir.ssid != '' and er.ssid !=''
left join @patMatches                as m on  m.incomingRecordIdx = ir.idx
                                       --and m.existingRecordIdx = er.idx
where
(
        (er.ssid        = ir.ssid)
    and (er.dateOfBirth = ir.dateOfBirth)

    and (ir.requiresAttention != 1)
    and (er.requiresAttention != 1)

  and  (m.idx is null)
)


declare @parsedpop parsedpop;
declare @all_results nvarchar(max)

declare @allMatchesPSandPP allMatchesPSandPP,
    @allPatientsForThisClient allPatientsForThisClient,
    @candidates_for_matching candidates_for_matching,
    @final_matches_active_and_inactive finalMatchesActiveAndInactive;

--declare @incomingPrimaryAndSecondaryContactsPerExistingPatient incomingPrimaryAndSecondaryContactsPerExistingPatient
--declare @allKnownExistingContactsForTheseExistingPatients allKnownExistingContactsForTheseExistingPatients;
--declare @mustInsertThesePersonsForExistingPatients mustInsertThesePersons;



INSERT INTO @parsedpop
 (
  ROW_NUM,
  lastname_imported, firstname_imported, STUDMI,
  SCHSTUDID,
  DOB_imported,
  GENDER,
  ImportedCSIS
 )
select
    patientDataImportRecordID = ipd.patientDataImportRecordID
  , lastName         = upper(trim(isnull(lastName,N'')))
  , firstName        = upper(trim(isnull(firstName,N'')))
  , middleName       = upper(trim(isnull(middleName,N'')))

  , SCHSTUDID        = TRIM(studid)

  , dateOfBirth      = dateOfBirth
  , gender           = gender
  , ssid             = ssid


  --

from @incomingRecordsPatientData ipd
LEFT JOIN @patMatches pat_m ON ipd.patientDataImportRecordID = pat_m.patientDataImportRecordID
WHERE pat_m.idx IS NULL


UPDATE t1
  SET t1.siteid = t2.SITE_ID
FROM @parsedpop AS t1
JOIN dbo.SITES_Site AS t2 ON t2.SITE_CLIENT_ID = t1.clientid
WHERE (
        (t2.SITE_CDS = SUBSTRING(t1.SCHCDS,8,7))
    AND (t2.ACTIVE = 1)
)

  --  SELECT * FROM @parsedpop


-- if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
-- begin


  exec dbo.Patient_Data_Imports_Match_Core_Heuristic @clientID, @parsedpop, @all_results output

  DELETE FROM @parsedpop;


  INSERT INTO @parsedpop
  SELECT *
  FROM OPENJSON(

    JSON_QUERY(
      @all_results, '$[0]'
    )
  ,
  '$."parsedPopOut"'

  )
  WITH (
        ROW_NUM bigint '$."ROW_NUM"',

        lastname_imported nvarchar(20) '$."lastname_imported"',
        firstname_imported nvarchar(15) '$."firstname_imported"',
        STUDMI nvarchar (1) '$."STUDMI"',

        SCHSTUDID nvarchar(20) '$."SCHSTUDID"',
        GRADE nvarchar(20) '$."GRADE"',
        ImportedCSIS nvarchar(10) '$."ImportedCSIS"',

        SCHCDS nvarchar(14) '$."SCHCDS"',
        SCHDISTID nvarchar(20) '$."SCHDISTID"',
        SCHNAME nvarchar(75) '$."SCHNAME"',

        STU_ADDR_1 nvarchar(75) '$."STU_ADDR_1"',
        STU_ADDR_2 nvarchar(75) '$."STU_ADDR_2"',
        STU_ADDR_CIT nvarchar(20) '$."STU_ADDR_CIT"',
        STU_ADDR_ZIP5 nvarchar(5) '$."STU_ADDR_ZIP5"',

        DOB_imported date '$."DOB_imported"',
        GENDER nvarchar(1) '$."GENDER"',
        SPED nvarchar (1) '$."SPED"',
        parentConsentMCAL char(1) '$."parentConsentMCAL"',

        requiresAttention bit '$."requiresAttention"',
        --requiresAttentionReason VARCHAR(40),

        inputGenderInfoFailedValidation bit '$."inputGenderInfoFailedValidation"',
        --cannotOverwriteParentalConsentValue bit,

        isActiveMatch bit '$."isActiveMatch"',
        isInactiveMatch bit '$."isInactiveMatch"',

        multipleActiveMatches bit '$."multipleActiveMatches"',
        multipleInactiveMatches bit '$."multipleInactiveMatches"',

        rowConflictsWithAnotherRow bit '$."rowConflictsWithAnotherRow"',
        secondaryAddressListed bit '$."secondaryAddressListed"',
        uniqueIdentifierNotUniqueInExistingActiveRecords bit '$."uniqueIdentifierNotUniqueInExistingActiveRecords"',
        uniqueIdentifierNotUniqueInExistingInactiveRecords bit '$."uniqueIdentifierNotUniqueInExistingInactiveRecords"',

        weakMatchesOnlyFromActivePatientRecords bit '$."weakMatchesOnlyFromActivePatientRecords"',
        --weakMatchesOnlyFromInactivePatientRecords bit, -- we don't care, we will create a new record anyway

        invalidMatchesOnlyFromActivePatientRecords bit '$."invalidMatchesOnlyFromActivePatientRecords"',
        --invalidMatchesOnlyFromInactivePatientRecords bit,  -- we don't care, we will create a new record anyway

        notifyInternalOnMCALConsentChange bit '$."notifyInternalOnMCALConsentChange"',
        notifyClientOnMCALConsentChange bit '$."notifyClientOnMCALConsentChange"',

        MatchingPatientID bigint '$."MatchingPatientID"',

        matchedByCSISAndDOB bit '$."matchedByCSISAndDOB"',--TODO: this isn't on the excel output yet.
        newStuIDProvided bit '$."newStuIDProvided"',
        cannotSaveNewStuID bit '$."cannotSaveNewStuID"',

        newRecordSuccess bit '$."newRecordSuccess"',

        unique_lookup_code_patient_school_enrollment_info bigint '$."unique_lookup_code_patient_school_enrollment_info"',

        noSiteFound bit '$."noSiteFound"',

        clientid int '$."clientid"',
        siteid int '$."siteid"',

        [PrimaryContactLastName] [nchar](40) '$."PrimaryContactLastName"',
        [PrimaryContactFirstName] [nchar](40) '$."PrimaryContactFirstName"',
        [PrimaryContactEmail] [nchar](40) '$."PrimaryContactEmail"',
        [PrimaryContactPhone] [nchar](12) '$."PrimaryContactPhone"',

        [SecondaryContactLastName] [nchar](40) '$."SecondaryContactLastName"',
        [SecondaryContactFirstName] [nchar](40) '$."SecondaryContactFirstName"',
        [SecondaryContactEmail] [nchar](40) '$."SecondaryContactEmail"',
        [SecondaryContactPhone] [nchar](12) '$."SecondaryContactPhone"'
  )

  SELECT * FROM @parsedpop

  INSERT INTO @final_matches_active_and_inactive
  SELECT *
   FROM OPENJSON(

    JSON_QUERY(
      @all_results, '$[0]'
    )
  ,
  '$."finalMatchesActiveAndInactive"'

  )
  WITH (
    txtfile_row_num bigint '$."txtfile_row_num"',
    no_possible_match_found int '$."no_possible_match_found"',
    weak_matches_only int '$."weak_matches_only"',
    invalid_matches_only int '$."invalid_matches_only"',
    cannot_choose_from_multiple_recs int '$."cannot_choose_from_multiple_recs"',
    MatchingPatientID int '$."MatchingPatientID"',
    patient_active_status char(1) '$."patient_active_status"',
    new_stuid_provided int '$."new_stuid_provided"',
    matchedByCSISAndDOB int '$."matchedByCSISAndDOB"',
    score int '$."score"'
  )


  INSERT INTO @candidates_for_matching
  SELECT *
  FROM OPENJSON(

    JSON_QUERY(
      @all_results, '$[0]'
    )
  ,
  '$."candidates_for_matching"'

  )
  WITH (

  txtfile_row_num bigint  '$."txtfile_row_num"',
  patient_active_status char  '$."patient_active_status"',
  MatchingPatientID bigint  '$."MatchingPatientID"',
  StuID_on_file nvarchar(50)  '$."StuID_on_file"',
  weak_match int  '$."weak_match"',
  very_strong_match bit  '$."very_strong_match"',
  invalid_match int  '$."invalid_match"',
  stuid_on_file_conflicting smallint  '$."stuid_on_file_conflicting"', --regretably SQL server does not allow us to perform a MIN() or MAX() on a bit field
  stuid_on_file_matching bit  '$."stuid_on_file_matching"',
  conflicting_CSIS_found bit  '$."conflicting_CSIS_found"',
  no_stuid_on_file bit  '$."no_stuid_on_file"',
  CSISNotUniqueInExistingActiveRecords smallint  '$."CSISNotUniqueInExistingActiveRecords"',
  CSISNotUniqueInExistingInactiveRecords bit  '$."CSISNotUniqueInExistingInactiveRecords"',
  StuIDNotUniqueInExistingActiveRecords bit  '$."StuIDNotUniqueInExistingActiveRecords"',
  StuIDNotUniqueInExistingInactiveRecords bit  '$."StuIDNotUniqueInExistingInactiveRecords"',
  last_name_mismatch bit  '$."last_name_mismatch"',
  first_name_mismatch bit  '$."first_name_mismatch"',
  lastname_exact_match bit  '$."lastname_exact_match"',
  firstname_exact_match bit  '$."firstname_exact_match"',
  FLapprox_DOB_match bit  '$."FLapprox_DOB_match"',
  CSIS_match_found smallint  '$."CSIS_match_found"',
  StuID_not_matched bit  '$."StuID_not_matched"',
  PossibleMatchOrMatchesFound int  '$."PossibleMatchOrMatchesFound"',
  decision_score int  '$."decision_score"'

  )


  INSERT INTO @patMatches (patID, incomingRecordIdx, existingRecordIdx, patientDataImportRecordID)
  SELECT ppf.MatchingPatientID, ipd.idx, epd.idx, ppf.ROW_NUM
  FROM @parsedpop ppf
  JOIN @incomingRecordsPatientData ipd ON ipd.patientDataImportRecordID = ppf.ROW_NUM
  JOIN @existingRecordsPatientData epd ON epd.patID = ppf.MatchingPatientID
  WHERE ppf.requiresAttention = 0 OR ppf.requiresAttention IS NULL


  UPDATE ipd
  SET
    requiresAttention = 0
  FROM @incomingRecordsPatientData ipd
  JOIN @parsedpop ppf
    ON ipd.patientDataImportRecordID = ppf.ROW_NUM
    AND ( ppf.requiresAttention = 0 OR ppf.requiresAttention IS NULL )

-- end



/*-------------------------------
 * Count core pat data matches
 * We will put this in the
 * table later
 *------------------------------*/



select
  @numPatMatches = count(m.idx)
from @patMatches                 as m

/*############################################################################
 *#  Match Existing Patient Site Data
 *############################################################################*/

/*-------------------------------
 * Match Pass 1
 *------------------------------*/

-- populating a table var for matches where the relevant row in PATIENTS_Patient exists,
-- and the relevant entry in PATIENTS_School also exists

-- find perfect matches; these are the ones that don't need to be deactivated or edited
-- (with add new and deactivate old)

INSERT INTO @patSite_PerfectMatches_inclNPSAndUnkSite (incomingSiteRecordIdx, existingSiteRecordIdx, patientDataImportRecordID)
  select
    i_s.idx, ex_s.idx, i_s.patientDataImportRecordID
  FROM @incomingRecordsPatientSite i_s

  JOIN @patMatches pat_m ON pat_m.patientDataImportRecordID = i_s.patientDataImportRecordID
    -- looking up the Patient_ID so we can narrow down to the correct row in PATIENTS_School
    -- No need to check requiresAttention != 1; if there is a patMatch then requiresAttention != 1

  JOIN @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite ex_s ON (
         (
          ( @fuzzyMatchSitesByNameAndCode = 0 AND i_s.cds7 = ex_s.cds7 )
          OR
          ( @fuzzyMatchSitesByNameAndCode = 1 AND i_s.fuzzyMatchedSiteID = ex_s.siteID )
         )
         AND
         ex_s.patID = pat_m.patID
         AND
         ex_s.grade = i_s.grade
         AND
         ex_s.studentID = i_s.studentID

         AND
         (
           TRIM( ISNULL(ex_s.attendanceTrackName, '' )) =  TRIM( ISNULL(i_s.attendanceTrackName, '' ))

             -- NOTE: we are not doing similar matching on preferredNickname in student data because we are not looking for
             --       "perfect matches" in the PATIENTS_Patient table like we are looking for in the PATIENTS_Schools table.
             --       In the p_s table, if we find a perfect match we leave it alone; but in PATIENTS_Patient we update the LASTPOP
             --       field even when we find a perfect match.
         )
      )

-- populating a table var for matches where the relevant row in PATIENTS_Patient exists,
-- and the relevant entry in PATIENTS_School does NOT yet exist


  --  SELECT * FROM  @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite
  --  SELECT * FROM  @patSite_PerfectMatches_inclNPSAndUnkSite

 -- ...
IF (
   @isOkToUpdateSiteDataForExistingPatients = 1
)

  --

  INSERT INTO @existingPatSiteRecsToDeac(
    patID
  , patientSchoolID
  , patientDataImportRecordID

  , grade
  , studentID
  , startdate

  , siteID

    -- not populating attendanceTrackName here because we are populating the unique identifier patientSchoolID
    -- and the extra cols are probably unnnecessary; just here for debugging and report-out mostly
  )
  SELECT
  p_s.PATIENT_ID, p_s.PATIENT_SCHOOL_ID, pat_m.patientDataImportRecordID,
  p_s.GRADE, p_s.STUDENT_ID, p_s."START_DATE", p_s.SITE_ID


  FROM dbo.PATIENTS_School p_s

-- NOTE:
-- we are looking for p_s records for PATIENT_IDs that have site matches
--  -BUT- the p_s in question is not the one being used,
--  probably because its unique ID isn't the MAX(PATIENT_SCHOOL_ID)

  JOIN @patMatches pat_m ON p_s.PATIENT_ID = pat_m.patID
  JOIN @patSite_PerfectMatches_inclNPSAndUnkSite ps_m
       ON (
             pat_m.patientDataImportRecordID = ps_m.patientDataImportRecordID
          )
LEFT JOIN @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite ex_sr
       ON (
              ex_sr.patientSchoolID = p_s.PATIENT_SCHOOL_ID
          )

WHERE ex_sr.patientSchoolID IS NULL

  -- SELECT  * FROM  @existingPatSiteRecsToDeac

-- TODO: maybe this needs to go in the stats JSON
-- SELECT * FROM @existingPatSiteRecsToDeac


--
--  finding existing patients that need new entries in the p_s table

INSERT INTO @newSiteJoinRelationshipRequiredForExistingPatient (incomingSiteRecordIdx, patID, siteID, patientDataImportRecordID)
---
  select
    i_s.idx, pat_m.patID, ss.SITE_ID, i_s.patientDataImportRecordID
  FROM @incomingRecordsPatientSite i_s

  JOIN @patMatches pat_m ON i_s.patientDataImportRecordID = pat_m.patientDataImportRecordID
    -- looking up the Patient_ID so we can INSERT the correct value PATIENTS_School

  LEFT JOIN @incomingRecordsPatientData ipd
    ON i_s.patientDataImportRecordID = ipd.patientDataImportRecordID
    -- looking for the requiresAttention bit;
    -- don't try to match site information for rows where the patient itself is un-matchable and un-creatable; otherwise
    -- we're likely to create all sorts of absurd edge cases

  LEFT JOIN @patSite_PerfectMatches_inclNPSAndUnkSite ps_m
  ON        ps_m.patientDataImportRecordID = i_s.patientDataImportRecordID

    -- looking up and and excluding existing p_s entries

  CROSS APPLY
    ( select top 1 *
      FROM
        SITES_Site ss
      WHERE
        ss.SITE_CLIENT_ID = @clientID
        AND

        -- ss.SITE_CDS = i_s.cds7

        (
          ( @fuzzyMatchSitesByNameAndCode = 0 AND i_s.cds7 = ss.SITE_CDS )
          OR
          ( @fuzzyMatchSitesByNameAndCode = 1 AND i_s.fuzzyMatchedSiteID = ss.SITE_ID )
        )

    ) ss

  WHERE
    ipd.requiresAttention != 1
    AND
    ps_m.idx IS NULL

 -- ...


  -- SELECT  * FROM  @newSiteJoinRelationshipRequiredForExistingPatient

IF (
   --
   @isOkToUpdateSiteDataForExistingPatients = 1
)

  INSERT INTO @existingPatSiteRecsToDeac(
    patID
  , patientSchoolID

  , grade
  , studentID
  , startdate

  , siteID
  )

  SELECT DISTINCT

  --
  --

  ex_ps.patID, p_s.PATIENT_SCHOOL_ID, --ns_ex.patientDataImportRecordID,
  p_s.GRADE, p_s.STUDENT_ID, p_s."START_DATE", p_s.SITE_ID

  --

  FROM @newSiteJoinRelationshipRequiredForExistingPatient ns_ex
--  NOTE:
--  we are looking for p_s records for existing PATIENT_IDs
--  -BUT- the p_s in question is not the one being used,
--  because the site, grade, or StuID is different than the incoming

  JOIN @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite ex_ps ON ns_ex.patID = ex_ps.patID
  JOIN dbo.PATIENTS_School p_s ON p_s.PATIENT_SCHOOL_ID = ex_ps.patientSchoolID




--if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
--begin

/*
INSERT INTO   @incomingInsDataForExistingPatient (

    patMatchIdx

  , carrierID

  , carrierStr
  , [InsuranceMemberNumber]

  , policyHolderName
  , policyGroupID

)

SELECT

  pat_m.idx,

  dbo.INSURANCE_CARRIER_ATTEMPT_MATCH_BY_NAME (
      ipd.PrimaryInsuranceCompany  -- TODO: the naming here implies we will eventually implement secondary
    , 1
    , 'CA'    -- TODO: pass @usState in as a called param, if we ever implement multiple states
  )
  ,

  ipd.PrimaryInsuranceCompany ,

  ipd.InsuranceMemberNumber ,
  ipd.policyHolderName ,
  ipd.policyGroupID

FROM  @patMatches pat_m
JOIN  @incomingRecordsPatientData ipd  ON  pat_m.incomingRecordIdx  =  ipd.idx
                                     AND   ipd.requiresAttention != 1

                                     AND LEN( ipd.PrimaryInsuranceCompany ) > 0
*/

-- NOTE: diagnostic code commented; uncomment during debugging

-- SELECT  *
--  FROM  @patMatches pat_m
--  JOIN  @incomingRecordsPatientData ipd  ON  pat_m.incomingRecordIdx  =  ipd.idx
--                                     AND   ipd.requiresAttention != 1

--                                     AND LEN( ipd.PrimaryInsuranceCompany ) > 0

/*
INSERT INTO   @incomingInsDataForNewPatient (

    incomingIdx
  , newPatID

  , carrierID

  , carrierStr
  , [InsuranceMemberNumber]

  , policyHolderName
  , policyGroupID

)


SELECT

  ipd.idx ,
  null ,

  dbo.INSURANCE_CARRIER_ATTEMPT_MATCH_BY_NAME (
      ipd.PrimaryInsuranceCompany  -- TODO: the naming here implies we will eventually implement secondary
    , 1
    , 'CA'    -- TODO: pass @usState in as a called param, if we ever implement multiple states
  )
  ,

  ipd.PrimaryInsuranceCompany ,

  ipd.InsuranceMemberNumber ,
  ipd.policyHolderName ,
  ipd.policyGroupID


FROM   @incomingRecordsPatientData ipd
LEFT JOIN   @patMatches pat_m
  ON  pat_m.incomingRecordIdx  =  ipd.idx

WHERE  ipd.requiresAttention != 1
       AND pat_m.incomingRecordIdx IS NULL
       AND LEN( ipd.PrimaryInsuranceCompany ) > 0
*/

-- NOTE: diagnostic code commented; uncomment during debugging
/*
SELECT  *
FROM   @incomingRecordsPatientData ipd
LEFT JOIN   @patMatches pat_m
  ON  pat_m.incomingRecordIdx  =  ipd.idx

WHERE  ipd.requiresAttention != 1
       AND pat_m.incomingRecordIdx IS NULL
       AND LEN( ipd.PrimaryInsuranceCompany ) > 0

*/


--end


declare @unknownSitesExistingPatientsJsonArr varchar(max) = '[]';
declare @unknownSitesNewPatientsJsonArr varchar(max) = '[]';

declare @numNewPatientsMatchedToUnknownSite bigint;

declare @numExistingPatsWSiteCodeUnknownAndUnchanged bigint;
-- renamed from @numUnknownSitesExistingPatients

declare @numExistingPatSiteRecsToDeac bigint = 0
declare @numDistinctPatIDsWExistingPatSiteRecsToDeac bigint = 0

declare @existingPatSiteRecsToDeacJsonArr varchar(max) = '[]';

declare @numVeryOldPatRecsDeacd bigint = 0
declare @numBlankCsisValsPopulatedForExisting bigint = 0

 -- ...
IF (
   @isOkToUpdateSiteDataForExistingPatients = 1
)

BEGIN

  SELECT @numExistingPatSiteRecsToDeac = COUNT(*)
  FROM   @existingPatSiteRecsToDeac

  SELECT @numDistinctPatIDsWExistingPatSiteRecsToDeac = COUNT( DISTINCT patID)
  FROM   @existingPatSiteRecsToDeac

  SET @existingPatSiteRecsToDeacJsonArr =
    CONVERT(
      VARCHAR(MAX)
      ,
      (
      select
      *    FROM @existingPatSiteRecsToDeac
      FOR JSON AUTO)
    )

END

SET @existingPatSiteRecsToDeacJsonArr = ISNULL( @existingPatSiteRecsToDeacJsonArr, '[]' )

/* TODO: this looks complicated and maybe wrong. This should be the first place we look
         if the student data handler people tell us that the stats and numbers don't add up */
SELECT
  @numExistingPatsWSiteCodeUnknownAndUnchanged = COUNT(*)
FROM @patMatches pat_m
WHERE
     patientDataImportRecordID NOT IN
       (select patientDataImportRecordID FROM @patSite_PerfectMatches_inclNPSAndUnkSite)
     AND
     patientDataImportRecordID NOT IN
      (select patientDataImportRecordID FROM @newSiteJoinRelationshipRequiredForExistingPatient)

SET @unknownSitesExistingPatientsJsonArr =
 CONVERT(
  VARCHAR(MAX)
  ,
  (
   select
    @unknownSiteExistingIdx unknownSiteExistingIdx, patID, @unknownSiteID unknownSiteID, patientDataImportRecordID
   FROM @patMatches pat_m
   WHERE
     patientDataImportRecordID NOT IN
       (select patientDataImportRecordID FROM @patSite_PerfectMatches_inclNPSAndUnkSite)
     AND
     patientDataImportRecordID NOT IN
      (select patientDataImportRecordID FROM @newSiteJoinRelationshipRequiredForExistingPatient)
  FOR JSON AUTO)
)

--
-- NOTE: I do not know right now why this code here is inserting into
-- @newSiteJoinRelationshipRequiredForExistingPatient a second time;
-- I'm assuming this is correct

INSERT INTO @newSiteJoinRelationshipRequiredForExistingPatient (incomingSiteRecordIdx, patID, siteID, patientDataImportRecordID)
select

  --

  @unknownSiteExistingIdx, patID, @unknownSiteID, patientDataImportRecordID
 FROM @patMatches pat_m
 WHERE
   patientDataImportRecordID NOT IN
     (select patientDataImportRecordID FROM @patSite_PerfectMatches_inclNPSAndUnkSite)
   AND
   patientDataImportRecordID NOT IN
    (select patientDataImportRecordID FROM @newSiteJoinRelationshipRequiredForExistingPatient)


-- TODO:  ugh.  I'm going to assume this is correct for now

INSERT INTO @newSiteJoinRelationshipRequiredForNewPatient (
    incomingSiteRecordIdx
  , existingSiteID
  , patientDataImportRecordID
)
   --
  select
    --
    i_s.idx, o1.siteID, i_s.patientDataImportRecordID
  FROM @incomingRecordsPatientSite i_s

  LEFT JOIN @incomingRecordsPatientData ipd
    ON i_s.patientDataImportRecordID = ipd.patientDataImportRecordID
    -- looking for the requiresAttention bit;
    -- don't try to match site information for rows where the patient itself is un-matchable and un-creatable; otherwise
    -- we're likely to create all sorts of absurd edge cases

  LEFT JOIN @patMatches pat_m ON i_s.patientDataImportRecordID = pat_m.patientDataImportRecordID
    -- looking up and and excluding existing pat_m entries
  LEFT JOIN @patSite_PerfectMatches_inclNPSAndUnkSite ps_m ON ps_m.patientDataImportRecordID = i_s.patientDataImportRecordID
    -- looking up and and excluding existing p_s entries
  LEFT JOIN @newSiteJoinRelationshipRequiredForExistingPatient nsr_ep ON nsr_ep.patientDataImportRecordID = i_s.patientDataImportRecordID
    -- looking up and and excluding existing...

  CROSS APPLY
  --

    ( select top 1 *
     FROM @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite ex_s
     WHERE  -- i_s.cds7 = ex_s.cds7

          ( @fuzzyMatchSitesByNameAndCode = 0 AND i_s.cds7 = ex_s.cds7 )
          OR
          ( @fuzzyMatchSitesByNameAndCode = 1 AND i_s.fuzzyMatchedSiteID = ex_s.siteID )

     ) o1
      -- NOTE: since we're querying @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite instead of SITES_Site,
      --       we will (in theory) fail to get results in the rare edge case that we are looking for an existing Site
      --       that doesn't have any patients associated with it in this file.  In practice that will never happen

  WHERE
    ipd.requiresAttention != 1
    AND
    (
      pat_m.idx IS NULL
      OR
      (
        ps_m.idx IS NULL
        AND
        nsr_ep.idx IS NULL
      )
    )  -- note: I think under normal conditions, we can filter out by making sure the pat_m isn't left joined;
       -- but when it comes to finding unexpected error conditions it doesn't hurt to cast the net wide


SET @unknownSitesNewPatientsJsonArr =
  CONVERT(
  VARCHAR(MAX)
  ,
  (
    select
      @unknownSiteExistingIdx unknownSiteExistingIdx, @unknownSiteID unknownSiteID, patientDataImportRecordID
    FROM @incomingRecordsPatientData
    WHERE
      patientDataImportRecordID NOT IN
     (select patientDataImportRecordID FROM @patMatches)
      AND
      patientDataImportRecordID NOT IN
     (select patientDataImportRecordID FROM @newSiteJoinRelationshipRequiredForNewPatient)
  FOR JSON AUTO)
)

-- this looks correct
select
  @numNewPatientsMatchedToUnknownSite = COUNT(patientDataImportRecordID)
FROM @incomingRecordsPatientData
WHERE
  patientDataImportRecordID NOT IN
  (select patientDataImportRecordID FROM @patMatches)
  AND
  patientDataImportRecordID NOT IN
  (select patientDataImportRecordID FROM @newSiteJoinRelationshipRequiredForNewPatient)


INSERT INTO @newSiteJoinRelationshipRequiredForNewPatient (incomingSiteRecordIdx, existingSiteID, patientDataImportRecordID)
select

  --

  @unknownSiteExistingIdx, @unknownSiteID, patientDataImportRecordID
FROM @incomingRecordsPatientData
WHERE
  patientDataImportRecordID NOT IN
 (select patientDataImportRecordID FROM @patMatches)
  AND
  patientDataImportRecordID NOT IN
 (select patientDataImportRecordID FROM @newSiteJoinRelationshipRequiredForNewPatient)
   AND
  requiresAttention != 1



declare @numPatSiteMatched as int = 0
declare @numPatSiteMatchesNeededForExisting as int = 0
  -- these two numbers, once counted/calculated, should total the number of existing patients matched;
  -- otherwise there's an unknown error condition

declare @numNewPatAndNewPatSiteMatchesNeeded as int = 0
  -- this number, once counted/calculated, should equal the number of new patients needed;
  -- otherwise there's an unknown error condition


select @numPatSiteMatched=COUNT(idx) from @patSite_PerfectMatches_inclNPSAndUnkSite

 -- ...

IF (
   @isOkToUpdateSiteDataForExistingPatients = 1
)
  select @numPatSiteMatchesNeededForExisting=COUNT(idx) from @newSiteJoinRelationshipRequiredForExistingPatient


select @numNewPatAndNewPatSiteMatchesNeeded=COUNT(idx)  from @newSiteJoinRelationshipRequiredForNewPatient


--SELECT * FROM @incomingRecordsPatientData



/*############################################################################
 *#  Match Existing Patient Place Data
 *############################################################################*/

/*-------------------------------
 * Match Pass 1
 *------------------------------*/

INSERT INTO @patPlaceMatches (
    incomingRecordIdx
  , existingRecordIdx
  , patientDataImportRecordID
  --, quality           int  -- TODO: will we need this?
)

select
  in_p.idx, ex_p.idx, in_p.patientDataImportRecordID
FROM
  @incomingPatientsPlace in_p
  JOIN @patMatches pat_m ON in_p.patientDataImportRecordID = pat_m.patientDataImportRecordID
  CROSS APPLY
  (
    SELECT top 1 * FROM @existingPatientsPlace ex_p
    WHERE
      pat_m.patID = ex_p.patID
      AND
      in_p.zip5 = ex_p.zip5
      AND
      in_p.address1MatchVal = ex_p.address1MatchVal
      AND
      ISNULL(in_p.address2,'') = ISNULL(ex_p.address2,'')
  ) ex_p

INSERT INTO @newPlaceRequiredForExistingPatient (
    incomingPlaceRecordIdx ,
    [PATIENT_ID] ,
    [ADDRESS_1] ,
    [ADDRESS_2] ,
    [CITY] ,
    [ZIP_5] ,
    patientDataImportRecordID
)
  SELECT
    in_p.idx,
    pat_m.patID,
    in_p.address1, in_p.address2, in_p.city, in_p.zip5, in_p.patientDataImportRecordID

  FROM
    @incomingPatientsPlace in_p

  JOIN @incomingRecordsPatientData ipd ON in_p.patientDataImportRecordID = ipd.patientDataImportRecordID
  JOIN @patMatches pat_m ON in_p.patientDataImportRecordID = pat_m.patientDataImportRecordID
  LEFT JOIN @patPlaceMatches pl_m ON pl_m.patientDataImportRecordID = in_p.patientDataImportRecordID

  WHERE
    ipd.requiresAttention != 1
    AND
    pl_m.idx IS NULL


INSERT INTO @newPlaceRequiredForNewPatient (
    incomingPlaceRecordIdx ,
    [PATIENT_ID] ,
    [ADDRESS_1] ,
    [ADDRESS_2] ,
    [CITY] ,
    [ZIP_5] ,
    patientDataImportRecordID
)
  SELECT
    in_p.idx,
    pat_m.patID,
    in_p.address1, in_p.address2, in_p.city, in_p.zip5, in_p.patientDataImportRecordID
  FROM
    @incomingPatientsPlace in_p
  JOIN @incomingRecordsPatientData ipd ON in_p.patientDataImportRecordID = ipd.patientDataImportRecordID
  LEFT
   JOIN @patMatches pat_m ON in_p.patientDataImportRecordID = pat_m.patientDataImportRecordID

  WHERE
    ipd.requiresAttention != 1
    AND
    (
      pat_m.idx IS NULL
    )

declare @numPatPlacesMatched as int = 0
declare @numPatPlaceMatchesNeededForExistingPatient as int = 0
declare @numNewPatPlaceNeededForNewPatient as int = 0

SELECT @numPatPlacesMatched=COUNT(idx) FROM @patPlaceMatches
SELECT @numPatPlaceMatchesNeededForExistingPatient=COUNT(idx) FROM @newPlaceRequiredForExistingPatient
SELECT @numNewPatPlaceNeededForNewPatient=COUNT(idx) FROM @newPlaceRequiredForNewPatient

/*############################################################################
 *#  Match Existing Patient Contacts
 *############################################################################*/


--select * from @newContactsRequiredForNewPatient

declare @numPatContactsMatched as bigint = 0
declare @numPatContactMatchesNeededForExistingPatient as bigint = 0
declare @numPatContactMatchesNeededForNewPatient as bigint = 0


--SELECT * FROM @patMatches

declare @numNewPatInsCreatedTot       as bigint = 0
declare @numNewPatInsCreatedWCarr     as bigint = 0
declare @numNewPatInsCreatedWUnk     as bigint = 0

declare @numExstPatInsMatchedTot        as bigint = 0
declare @numExstPatInsMatchedUpdtd      as bigint = 0
declare @numExstPatInsMatchedNoChng     as bigint = 0

declare @numExstPatInsCreatedTot        as bigint = 0
declare @numExstPatInsCreatedWCarr      as bigint = 0
declare @numExstPatInsCreatedWUnk     as bigint = 0

/*############################################################################
 *# Complile Report Results
 *############################################################################*/

/*###########################################################################################################################
 *# Persist data
 *#
 *#            NOTE: The goal is to keep the transaction(s) open for the least amount of time possible
 *#
 *###########################################################################################################################*/

/*############################################################################
 *# Update Existing Patient Core Data
 *# Name changes
 *############################################################################*/


if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
  UPDATE [dbo].[Import_From_A_From_Client_ToSPED_Files]
  SET
    opened_SQL_transaction = GETDATE()
  WHERE id = @importRecordLogID

else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())

  UPDATE [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
  SET
    opened_SQL_pop_transaction = GETDATE()
  WHERE id = @importRecordLogID


SELECT
  @numBlankCsisValsPopulatedForExisting = COUNT(*)
FROM   dbo.PATIENTS_Patient p_p
JOIN   @patMatches pat_m ON pat_m.patID = p_p.PATIENT_ID
JOIN   @incomingRecordsPatientData ipd ON ipd.patientDataImportRecordID = pat_m.patientDataImportRecordID

WHERE  ISNULL( p_p.CSIS, '' ) = ''
       AND
       ISNULL( ipd.ssid, '') != ''


begin transaction
set @tranOpen = 1

--

UPDATE p_p
  SET
    p_p.LAST_NAME = ipd.lastName,
    p_p.FIRST_NAME = ipd.firstName,

    p_p.preferredNickname  = ipd.preferredNickname ,

    p_p.DATE_OF_BIRTH = ipd.dateOfBirth,

    p_p.CSIS = CASE WHEN ISNULL( ipd.ssid, '') != '' THEN ipd.ssid else p_p.CSIS END ,

    p_p.MIDDLE_NAME = CASE WHEN LEN(ISNULL(ipd.middleName,'')) > LEN(ISNULL(p_p.MIDDLE_NAME,'')) THEN ipd.middleName ELSE p_p.MIDDLE_NAME END ,

    p_p.parentConsentMCAL = isnull(ipd.mCalConsent,p_p.parentConsentMCAL),

    p_p.teacherOrCounselorName  = ipd.teacherOrCounselorName ,

    p_p.parentConsentMCALEffectiveDate = getdate(),

	--...

    -- TODO: figure out where we're putting the "primary insurance company" and "insurance member number"
    -- fields.  Do those fields exist somewhere or do they need to be created?
    --          TODO: we probably still need to do this... eventually... yeah?


    p_p.CONCAT_NAME = ipd.lastName + ', ' + ipd.firstName,

    p_p.LASTPOP = GETDATE(),

    p_p.updated_from_ROW_NUM = ipd.patientDataImportRecordID



FROM dbo.PATIENTS_Patient p_p
JOIN @patMatches pat_m ON pat_m.patID = p_p.PATIENT_ID
JOIN @incomingRecordsPatientData ipd ON ipd.patientDataImportRecordID = pat_m.patientDataImportRecordID

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())

  UPDATE dfr
    SET
      dfr.Matched_PatientID = pat_m.patID,
      dfr.Matched_PatientID_orig = pat_m.patID,
      dfr.Matched_Pat_ID_timestamp = GETDATE()
  from dbo.Import_From_A_From_Client_ToSPED_File_rows dfr
  JOIN dbo.Import_From_A_From_Client_ToSPED_Files as df ON df.structuredDataImportID = @structuredDataImportID
        and
        dfr.FROM_CLIENT_log_entry = df.id

  JOIN @patMatches pat_m
    ON pat_m.patientDataImportRecordID = dfr.ROW_NUM


else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())

  UPDATE dfr
    SET
      dfr.Patient_ID = pat_m.patID,
      dfr.Patient_ID_orig = pat_m.patID,
      dfr.Matched_Pat_ID_timestamp = GETDATE()
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] dfr
  JOIN dbo.[Import_From_A.5_SERVICES_From_Client_Files] i_f
      ON dfr.File_import_log_entry = i_f.id
     AND i_f.id = @importRecordLogID

  JOIN @patMatches pat_m
     ON pat_m.patientDataImportRecordID = dfr.id;

declare @population_files_file_ID bigint;

INSERT INTO dbo.population_files (file_name, client_ID, upload_date, is_full_file)
SELECT
    @fileUploadfileName,
    @clientID,
    GETDATE(),
    1

set @population_files_file_ID = scope_identity()


-- We have existing records.


INSERT INTO dbo.population_file_patients (file_id, patient_id)
  SELECT
      @population_files_file_ID,
      patID
  FROM @patMatches




UPDATE p_iep
  SET IEP_IFSP_NONE =
    CASE WHEN ipd.spEd  = 'N' OR ipd.spEd  = '0' OR NULLIF(SPED,'') IS NULL
      THEN 'NONE'
      ELSE
        CASE WHEN ipd.spEd = 'Y' OR ipd.spEd = '1' THEN
          CASE WHEN DATEADD(year, 3, ipd.dateOfBirth) > GETDATE()
            THEN 'IFSP' -- if younger than 3
            ELSE 'IEP'  -- if exactly 3 or older.  --the specific edge case where the patient was exactly 3 was previously unhandled, until I noticed it -- JM
          END
        END  -- if SPED != 'Y' and SPED != 'N', then this UPDATE will fail, because the CASE statement doesn't handle it.
             -- we would be putting a NULL in a non-null column.
    END
  FROM dbo.PATIENTS_IEP p_iep
  JOIN @patMatches pat_m ON pat_m.patID = p_iep.PATIENT_ID
  JOIN @incomingRecordsPatientData ipd ON ipd.patientDataImportRecordID = pat_m.patientDataImportRecordID

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

/*############################################################################
 *# Update Existing Patient Place Data
 *# Changes in home address
 *# Make sure to set start and end dates
 *############################################################################*/

 UPDATE p_pl
  SET
    p_pl.ADDRESS_1 = ipl.address1,
    p_pl.ADDRESS_2 = ipl.address2,
    p_pl.CITY      = ipl.city,
    p_pl.ZIP_5     = ipl.zip5
  FROM dbo.PATIENT_PLACES p_pl
  JOIN @patMatches pat_m ON pat_m.patID = p_pl.PATIENT_ID
  JOIN @patPlaceMatches pl_m ON pl_m.patientDataImportRecordID = pat_m.patientDataImportRecordID
  JOIN @incomingPatientsPlace ipl ON ipl.patientDataImportRecordID = pat_m.patientDataImportRecordID

/*############################################################################
 *# Update Existing Patient Person (Contact) Data
 *############################################################################*/


end -- //if @fileSubClass

/*############################################################################
 *# Add New Patient Core Data
 *# These are brand new patients
 *############################################################################*/

declare @newPatRecsNeeded as table (
    idx               bigint identity(1,1)
  , incomingRecordIdx bigint
  , patientDataImportRecordID bigint
  , newPatID bigint
)
      -- this should have been one of the first table variables we created and filled in; this
      -- would have saved a lot of work and a lot of JOINs

INSERT INTO @newPatRecsNeeded
  (incomingRecordIdx, patientDataImportRecordID)
SELECT ipd.idx, ipd.patientDataImportRecordID
FROM
@incomingRecordsPatientData ipd
 LEFT JOIN @patMatches pat_m ON ipd.patientDataImportRecordID = pat_m.patientDataImportRecordID
WHERE
  pat_m.idx IS NULL
  AND
  ipd.requiresAttention != 1


declare @newPatRecsCreated TABLE (newpatid bigint, patientDataImportRecordID bigint)

SELECT  @numNewPatRecsNeeded = MAX(idx) from @newPatRecsNeeded  -- COUNT(*) would also work I think







INSERT INTO dbo.PATIENTS_Patient
(
  --
  created_from_ROW_NUM,
  LAST_NAME, FIRST_NAME, MIDDLE_NAME, preferredNickname ,
  DATE_OF_BIRTH, SEX, CSIS,
  DATE_CREATED, LAST_UPDATED, LASTPOP, ACTIVE,
  CONCAT_NAME, SUBMIT_CLAIMS,
  parentConsentMCAL,
  parentConsentMCALEffectiveDate
  , teacherOrCounselorName
        -- TODO: figure out where we're putting the "primary insurance company" and "insurance member number"
        -- fields.  Do those fields exist somewhere or do they need to be created?
  --
)

output inserted.PATIENT_ID, inserted.created_from_ROW_NUM AS patientDataImportRecordID

INTO @newPatRecsCreated

  select --TOP 1
  ipd.patientDataImportRecordID,
  ipd.lastName, ipd.firstName, ipd.middleName, ipd.preferredNickname , ipd.dateOfBirth, ipd.gender, ipd.ssid,
  GETDATE(), null, GETDATE(), 'Y',
  ipd.lastName + ', ' + ipd.firstName, 1,

  ipd.mCalConsent,
  GETDATE() ,

  teacherOrCounselorName

  FROM @incomingRecordsPatientData ipd JOIN @newPatRecsNeeded npn
    ON ipd.patientDataImportRecordID = npn.patientDataImportRecordID

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
begin

  UPDATE dfr
    SET
      dfr.Patient_ID = new_.newpatid,
      dfr.Patient_ID_orig = new_.newpatid,
      dfr.Matched_Pat_ID_timestamp = GETDATE()
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] dfr
  JOIN dbo.[Import_From_A.5_SERVICES_From_Client_Files] i_f
      ON dfr.File_import_log_entry = i_f.id
     AND i_f.id = @importRecordLogID
  JOIN @newPatRecsCreated new_
    ON new_.patientDataImportRecordID = dfr.ID

end




-- We have new records.

INSERT INTO dbo.population_file_patients (file_id, patient_id)
SELECT
  @population_files_file_ID,
  newpatid
FROM @newPatRecsCreated


UPDATE n_n
  SET newPatID = n_c.newpatid
FROM @newPatRecsNeeded n_n
JOIN @newPatRecsCreated n_c ON n_n.patientDataImportRecordID = n_c.patientDataImportRecordID


INSERT INTO [dbo].[PATIENTS_Client]
(  [CLIENT_ID], [PATIENT_ID], [START_DATE] )
  SELECT @clientID, newpatid, GETDATE()
  FROM @newPatRecsCreated


INSERT INTO dbo.PATIENTS_IEP (PATIENT_ID, IEP_IFSP_NONE)
  select
  npn.newpatid,
      CASE WHEN ipd.spEd  = 'N' OR ipd.spEd  = '0' OR NULLIF(SPED,'') IS NULL
      THEN 'NONE'
      ELSE
        CASE WHEN ipd.spEd = 'Y' OR ipd.spEd = '1' THEN
          CASE WHEN DATEADD(year, 3, ipd.dateOfBirth) > GETDATE()
            THEN 'IFSP' -- if younger than 3
            ELSE 'IEP'  -- if exactly 3 or older.  --the specific edge case where the patient was exactly 3 was previously unhandled, until I noticed it -- JM
          END
        END  -- if SPED != 'Y' and SPED != 'N', then this UPDATE will fail, because the CASE statement doesn't handle it.
             -- we would be putting a NULL in a non-null column.
    END
  FROM @incomingRecordsPatientData ipd JOIN @newPatRecsNeeded npn
    ON ipd.patientDataImportRecordID = npn.patientDataImportRecordID
    AND npn.newPatID IS NOT NULL


UPDATE new_
  SET new_.newpatid = added_.newPatID
FROM @newContactsRequiredForNewPatient new_
JOIN @newPatRecsNeeded added_ ON new_.patientDataImportRecordID = added_.patientDataImportRecordID


/*############################################################################
 *# Add New Patient Site Data
 *# Brand new patients site data
 *############################################################################*/


UPDATE new_

  --

  SET new_.newpatid = added_.newPatID

  --
  --

FROM @newSiteJoinRelationshipRequiredForNewPatient new_

JOIN @newPatRecsNeeded added_ ON new_.patientDataImportRecordID = added_.patientDataImportRecordID



  --select * from @newPatRecsNeeded
  --select * from @newSiteJoinRelationshipRequiredForNewPatient

  --select * from @incomingRecordsPatientSite
  --select * from @existingMostValidRecordsPatientSitePerPatID_includesNPSAndUnkSite


/*
if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())

  UPDATE new_

  SET new_.newPatID = added_.newPatID
  FROM @incomingInsDataForNewPatient new_
  JOIN @newPatRecsNeeded added_ ON new_.incomingIdx = added_.incomingRecordIdx
*/

INSERT INTO dbo.PATIENTS_School
(PATIENT_ID, SITE_ID, STUDENT_ID, GRADE, "START_DATE", [attendanceTrackName])

SELECT
  --
  --

  n_s.newPatID, n_s.existingSiteID, ips.studentID, ips.grade, GETDATE(), ips.[attendanceTrackName]
FROM @newSiteJoinRelationshipRequiredForNewPatient n_s
JOIN @incomingRecordsPatientSite ips ON ips.patientDataImportRecordID = n_s.patientDataImportRecordID
                                     AND n_s.existingSiteID IS NOT NULL  -- NOTE:  and condition is unnecessary because it will "never happen"
                                                                           --        ... or will it  ?

 -- ...

IF (
   @isOkToUpdateSiteDataForExistingPatients = 1
)

BEGIN

  INSERT INTO dbo.PATIENTS_School
  --
  (PATIENT_ID, SITE_ID, STUDENT_ID, GRADE, "START_DATE", [attendanceTrackName])

  --

  SELECT
    n_s.patID, n_s.siteID, ips.studentID, ips.grade, GETDATE(), ips.[attendanceTrackName]
  FROM @newSiteJoinRelationshipRequiredForExistingPatient n_s
  JOIN @incomingRecordsPatientSite ips ON ips.patientDataImportRecordID = n_s.patientDataImportRecordID

  UPDATE p_s
  SET

  --

    p_s.END_DATE = GETDATE()
  FROM dbo.PATIENTS_School p_s
  JOIN @existingPatSiteRecsToDeac ex_deac ON p_s.PATIENT_SCHOOL_ID = ex_deac.patientSchoolID

END


/*############################################################################
 *# Add New Patient Place Data
 *# Brand new patients place data
 *############################################################################*/

UPDATE new_
  SET new_.newpatid = added_.newPatID
FROM @newPlaceRequiredForNewPatient new_
JOIN @newPatRecsNeeded added_ ON new_.patientDataImportRecordID = added_.patientDataImportRecordID


INSERT INTO dbo.PATIENT_PLACES
(CLIENT_ID, PATIENT_ID, [NAME], PATIENT_PLACE_TYPE, PLACE_FORMAT_TYPE, PLACE_SOURCE_TYPE,
 ADDRESS_1, ADDRESS_2, CITY, "STATE", ZIP_5,
 CREATED_BY, CREATED_ON, ACTIVE)
SELECT
  @clientID, n_r.newpatid, 'Primary Home Address from District Student Data', 1, 1, 1,
  n_r.ADDRESS_1, n_r.ADDRESS_2, n_r.CITY, 'CA', n_r.ZIP_5,
  @userID, GETDATE(), 1
FROM @newPlaceRequiredForNewPatient n_r
JOIN @incomingPatientsPlace ip ON ip.patientDataImportRecordID = n_r.patientDataImportRecordID

INSERT INTO dbo.PATIENT_PLACES
(CLIENT_ID, PATIENT_ID, [NAME], PATIENT_PLACE_TYPE, PLACE_FORMAT_TYPE, PLACE_SOURCE_TYPE,
 ADDRESS_1, ADDRESS_2, CITY, "STATE", ZIP_5,
 CREATED_BY, CREATED_ON, ACTIVE)
SELECT
  @clientID, n_r.PATIENT_ID, 'Primary Home Address from District Student Data', 1, 1, 1,
  n_r.ADDRESS_1, n_r.ADDRESS_2, n_r.CITY, 'CA', n_r.ZIP_5,
  @userID, GETDATE(), 1
FROM @newPlaceRequiredForExistingPatient n_r
JOIN @incomingPatientsPlace ip ON ip.patientDataImportRecordID = n_r.patientDataImportRecordID


declare @today date
SET @today = CAST( GETDATE() as date )

if (
      @fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP()
      OR
      @totalPopFilesAreExpected = 0
   )
begin

  SELECT
    @numVeryOldPatRecsDeacd = COUNT(*)
  FROM       dbo.PATIENTS_Patient pp
  JOIN       @existingRecordsPatientData ex
         ON  ex.patID = pp.PATIENT_ID
  LEFT JOIN  dbo.PATIENTS_Eligibility AS pe
         ON  pp.PATIENT_ID = pe.PATIENT_ID

  WHERE  (
           pp.LASTPOP >= DATEADD (
             month,
             -15,
             convert(
               datetime,
               convert (
                 varchar(5),
                 year(@today)
                 ) + '-' + convert (
                   varchar(5),
                   month(@today)
                 ) + '-1'
             )
            )
          )
          AND
          (
            pe.MEDS_CURRENT >= DATEADD (
              month,
              -15,
              convert(
                datetime,
                convert (
                  varchar(5),
                  year(@today)
                ) + '-' + convert (
                  varchar(5),
                    month(@today)
                    )   + '-1'
                )
              )
           )



end



--  NOTE: this probably should be inside an IF statement that switches between
--       Import_From_A_From_Client_ToSPED_File_rows
--       and
--       [Import_From_A.5_SERVICES_From_Client_Files];

-- it seems like an oversight that it hasn't been corrected thus far (Apr 12 2023)

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())

  UPDATE dfr
    SET

    dfr.Matched_PatientID       = new_.newpatid,
    dfr.Matched_PatientID_orig  = new_.newpatid,
    dfr.Matched_Pat_ID_timestamp = GETDATE()

    FROM dbo.Import_From_A_From_Client_ToSPED_File_rows dfr
    JOIN dbo.Import_From_A_From_Client_ToSPED_Files as df
    ON
    df.id = dfr.FROM_CLIENT_log_entry
    AND
    df.patientDataImportID = @patientDataImportID
    AND
    df.structuredDataImportID = @structuredDataImportID
    JOIN @newPatRecsCreated new_
    ON
    new_.patientDataImportRecordID = dfr.ROW_NUM
    WHERE
    dfr.Matched_PatientID IS NULL

else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())

  UPDATE dfr
    SET

    dfr.Patient_ID       = new_.newpatid,
    dfr.Patient_ID_orig  = new_.newpatid,
    dfr.Matched_Pat_ID_timestamp = GETDATE()

    FROM dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] dfr
    JOIN dbo.[Import_From_A.5_SERVICES_From_Client_Files] i_f
    ON
    dfr.File_import_log_entry = i_f.id
    AND
    i_f.patientDataImportID = @patientDataImportID
    AND
    i_f.structuredDataImportID = @structuredDataImportID
    JOIN @newPatRecsCreated new_
    ON
    new_.patientDataImportRecordID = i_f.patientDataImportID
    WHERE
    dfr.Patient_ID IS NOT NULL

/* ##########################
   Dealing with contacts here
   ##########################
*/


if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

  declare
    @pgLastName  varchar(256)
  , @pgFirstName varchar(256)
  , @pgEmail     varchar(256)
  , @pgPhone     varchar(256)
  , @pgRowNum    int
  , @pgPatID     bigint
  , @pgPersonID  bigint

  declare @pgClassID1       as bigint = 1
  declare @pgClassID2       as bigint = 1002  -- don't know what the 1002 here represents
  declare @curIdx_patcon as int
  declare @maxIdx_patcon as int
  declare @exitingPatPerID_patcon as bigint = null

  declare @personsRaw as table (
    idx                 int identity(1,1)
  , importFromRowID     bigint
  , importFromRowNum    int
  , firstName           varchar(255)
  , lastName            varchar(255)
  , email               varchar(255)
  , phone               varchar(255)
  , patID               bigint
  unique clustered (idx)
  )

  --exec dbo.PRINT_STATUS_MESSAGE 'Get primary contact data'

  insert into @personsRaw (
    importFromRowID
  , importFromRowNum
  , firstName
  , lastName
  , email
  , phone
  , patID
  )
  select
    importFromRowID   = dfr.ID
  , importFromRowNum  = dfr.ROW_NUM
  , firstName         = dfr.primaryContactFirstName
  , lastName          = dfr.primaryContactLastName
  , email             = dfr.primaryContactEmail
  , phone             = dfr.primaryContactPhone
  , patID             = dfr.Matched_PatientID

  from dbo.Import_From_A_From_Client_ToSPED_File_rows as dfr
  JOIN dbo.Import_From_A_From_Client_ToSPED_Files as df

  ON
    df.id = dfr.FROM_CLIENT_log_entry
    AND
    df.patientDataImportID = @patientDataImportID
    AND
    df.structuredDataImportID = @structuredDataImportID

  JOIN @incomingRecordsPatientData ipd ON ipd.patientDataImportRecordID = dfr.ROW_NUM

  where (
   (dfr.Matched_PatientID is not null)

   AND

   ipd.requiresAttention != 1
  )

  --exec dbo.PRINT_STATUS_MESSAGE 'Get secondary contact data'

  insert into @personsRaw (
    importFromRowID
  , importFromRowNum
  , firstName
  , lastName
  , email
  , phone
  , patID
  )
  select
    importFromRowID  = dfr.ID
  , importFromRowNum = dfr.ROW_NUM
  , firstName        = dfr.secondaryContactFirstName
  , lastName         = dfr.secondaryContactLastName
  , email            = dfr.secondaryContactEmail
  , phone            = dfr.secondaryContactPhone
  , patID            = dfr.Matched_PatientID

  from dbo.Import_From_A_From_Client_ToSPED_File_rows as dfr
  JOIN dbo.Import_From_A_From_Client_ToSPED_Files as df

  ON
    df.id = dfr.FROM_CLIENT_log_entry
    AND
    df.patientDataImportID = @patientDataImportID
    AND
    df.structuredDataImportID = @structuredDataImportID

  JOIN @incomingRecordsPatientData ipd ON ipd.patientDataImportRecordID = dfr.ROW_NUM

  where (
   (dfr.Matched_PatientID is not null)

   AND

   ipd.requiresAttention != 1
  )

  select @curIdx_patcon = min(pr.idx), @maxIdx_patcon = max(pr.idx) from @personsRaw as pr

  while (@curIdx_patcon <= @maxIdx_patcon)
  begin

    select top 1
     @pgLastName  = t1.lastName
   , @pgFirstName = t1.firstName
   , @pgEmail     = t1.email
   , @pgPhone     = t1.phone
   , @pgRowNum    = t1.importFromRowNum
      , @pgPatID     = t1.patID
    from @personsRaw as t1
    where (t1.idx = @curIdx_patcon)

    --exec dbo.PRINT_STATUS_MESSAGE 'Searching for existing person record'

    set @pgPersonID = dbo.PERSONS_FIND_EXISTING (@pgLastName, @pgFirstName, @pgEmail, @pgPhone, @pgClassID1, @pgClassID2)

    if (@pgPersonID is null)
    begin

      --exec dbo.PRINT_STATUS_MESSAGE 'No person record found so we need to create a new one'

      INSERT INTO dbo.PERSONS_PERSON (
        CLASS_ID_1
      , CLASS_ID_2
      , LAST_NAME
      , FIRST_NAME
      , PHONE
      , EMAIL
      , CREATED_BY
      , CREATED_ON
      , ACTIVE
      , created_from_ROW_NUM)
      values (
        @pgClassID1
      , @pgClassID2

      , REPLACE(
          @pgLastName  ,
          '''', '`'
        )

      , REPLACE(
          @pgFirstName ,
          '''', '`'
        )

      , @pgPhone
      , @pgEmail
      , 0
      , getdate()
      , 1
      , @pgRowNum)

      set @pgPersonID = SCOPE_IDENTITY()

    end
    else
    begin

      if (@pgPersonID = -99)
      begin

        --exec dbo.PRINT_STATUS_MESSAGE 'Blank so we are skipping creating patient person'

        set @curIdx_patcon = @curIdx_patcon + 1
        continue

      end

   --exec dbo.PRINT_STATUS_MESSAGE 'Found existing person record so reusing'
    end

    --exec dbo.PRINT_STATUS_MESSAGE 'Search for existing patient person record'

    set @exitingPatPerID_patcon = null

    select top 1
      @exitingPatPerID_patcon = t1.ID
    from dbo.PATIENTS_PERSON as t1
    where (
        (t1.CLIENT_ID  = @clientID)
    and (t1.PATIENT_ID = @pgPatID)
    and (t1.PERSON_ID  = @pgPersonID)
    and (t1.ACTIVE = 1)
    )

    if (@exitingPatPerID_patcon is null)
    begin

      --exec dbo.PRINT_STATUS_MESSAGE 'No existing patient person record found so we are creating a new one'

      INSERT INTO dbo.PATIENTS_PERSON (
        CLIENT_ID
      , PATIENT_ID
      , PERSON_ID
      , [START_DATE]
      , CREATED_BY
      , CREATED_ON
      , ACTIVE )
       values (
       @clientID
      , @pgPatID
      , @pgPersonID
      , getdate()
      ,0
      ,getdate()
      ,1)

      set @exitingPatPerID_patcon = SCOPE_IDENTITY()

      IF ( ( SELECT COUNT(*) FROM @patMatches WHERE patID = @pgPatID ) != 0)
        SET @numPatContactMatchesNeededForExistingPatient = @numPatContactMatchesNeededForExistingPatient + 1
      else
        SET @numPatContactMatchesNeededForNewPatient = @numPatContactMatchesNeededForNewPatient + 1

    end
    else
    begin

      --exec dbo.PRINT_STATUS_MESSAGE 'Updating patient person data'

      update dbo.PATIENTS_Person
      set
       LAST_MODIFIED_ON = getdate()
     , LAST_MODIFIED_BY = 0
     where (ID = @exitingPatPerID_patcon)

     SET @numPatContactsMatched = @numPatContactsMatched + 1

    end

    set @curIdx_patcon = @curIdx_patcon + 1

  end

/*
  ; with existing_pat_ins_matches as (

      SELECT

        new_ins.idx           ,
        -- new_ins.patMatchIdx   ,

        new_ins.carrierID     ,
        new_ins.carrierStr    ,

        new_ins.[InsuranceMemberNumber]  ,

        new_ins.policyHolderName         ,
        new_ins.policyGroupID            ,

        ex_.id    ex_pic_ID

        --isExistingEntrySetDeac   ,
        --isExistingEntryNoChanges ,


      FROM
              @incomingInsDataForExistingPatient    new_ins
      JOIN    @patMatches                           pat_m
        ON    pat_m.idx = new_ins.patMatchIdx

      JOIN  dbo.PATIENT_INSURANCE_CARRIERS    ex_
                                        ON    pat_m.patID = ex_.patID
                                              AND
                                              ex_.clientID = @clientID
                                              AND
                                              ( ISNULL(new_ins.carrierID, 0)  = ISNULL(ex_.insuranceCarrierID, 0)
                                                OR
                                                (
                                                   ISNULL(new_ins.carrierID, 0)        =  0
                                                   AND
                                                   ISNULL(ex_.insuranceCarrierID, 0)   = 0
                                                   AND
                                                   new_ins.carrierStr  =  ex_.insCarrierNameStr
                                                )
                                              )

  ) ,
  calcd_flags_4_incoming_ins as (
    SELECT
      ex_m.idx   ,
      isExistingEntryNoChanges =
        CASE WHEN
            ISNULL(ex_m.[InsuranceMemberNumber], '') = ISNULL(pic_orig.beneficiaryID , '')
            AND
            ISNULL(ex_m.policyHolderName, '')        = ISNULL(pic_orig.policyHolderName, '')
            AND
            ISNULL(ex_m.policyGroupID , '')          = ISNULL(pic_orig.policyGroupID, '')
          THEN 1
          ELSE 0
        END
    FROM
      existing_pat_ins_matches               ex_m
      JOIN  dbo.PATIENT_INSURANCE_CARRIERS   pic_orig
                                        ON   ex_m.ex_pic_ID = pic_orig.id
                                             AND
                                             pic_orig.clientID = @clientID
  )
  UPDATE t1
    SET
        t1.isExistingEntryNoChanges = flagged_in_.isExistingEntryNoChanges ,
        t1.isExistingEntrySetDeac   = 1 - flagged_in_.isExistingEntryNoChanges
  FROM  @incomingInsDataForExistingPatient t1
  JOIN  calcd_flags_4_incoming_ins         flagged_in_
                                ON         flagged_in_.idx = t1.idx
*/

/*

  UPDATE  ex_
    SET
        lastModified     = GETDATE()  ,
        lastModifiedBy   = @userID    ,
        expiredOrInvalid   =  isExistingEntrySetDeac
  FROM  dbo.PATIENT_INSURANCE_CARRIERS  ex_
  JOIN  @patMatches                     pat_m
     ON  pat_m.patID  =  ex_.patID
         AND ex_.clientID  =  @clientID
         AND ex_.active = 1 AND ex_.expiredOrInvalid = 0
  JOIN  @incomingInsDataForExistingPatient  flagged_in
     ON  flagged_in.patMatchIdx = pat_m.idx

  WHERE  flagged_in.isExistingEntryNoChanges = 1  OR  flagged_in.isExistingEntrySetDeac = 1

*/



  --
/*
  INSERT INTO dbo.PATIENT_INSURANCE_CARRIERS (
   patID              ,
   clientID           ,

   insCarrierNameStr  ,
   insuranceCarrierID ,

   policyHolderName   ,
   policyGroupID      ,

   beneficiaryFirstName ,
   beneficiaryLastName  ,
   beneficiaryID        ,

   expiredOrInvalid     ,

   created         ,
   createdBy
  )
  SELECT
    npc.newpatid          ,
    @clientID             ,
    new_ins.carrierStr        ,

    CASE WHEN LEN( new_ins.carrierID ) > 0
      THEN  new_ins.carrierID
      ELSE  null
      END   ,

    new_ins.policyHolderName  ,
    new_ins.policyGroupID     ,

    ipd.firstName             ,
    ipd.lastName              ,
    new_ins.InsuranceMemberNumber ,

    CASE WHEN  new_ins.carrierID  > 0
              AND (
                LEN( new_ins.policyGroupID ) > 0   OR   LEN( new_ins.InsuranceMemberNumber ) > 0
              )
      THEN  0
      ELSE  1
      END ,

    GETDATE() ,

    ISNULL( @userID , 0)  -- can't insert NULL.
                          -- TODO: fix the service and call stack for data imports,
                          -- to use the userID of whoever made the import


  FROM  @incomingInsDataForNewPatient new_ins
  JOIN  @incomingRecordsPatientData  ipd
    ON   new_ins.incomingIdx  =  ipd.idx

  --JOIN @newPatRecsNeeded npn
  --  ON ipd.patientDataImportRecordID = npn.patientDataImportRecordID

  -- @newPatRecsCreated

  JOIN @newPatRecsCreated npc
    ON ipd.patientDataImportRecordID = npc.patientDataImportRecordID


    select  *
      FROM  @incomingInsDataForExistingPatient new_ins
  JOIN  @patMatches pat_m  ON  pat_m.idx = new_ins.patMatchIdx
  JOIN  @incomingRecordsPatientData  ipd  ON  pat_m.incomingRecordIdx  =  ipd.idx


  AND
    new_ins.isExistingEntryNoChanges = 0
*/

/*
  INSERT INTO dbo.PATIENT_INSURANCE_CARRIERS (
   patID              ,
   clientID           ,
   insCarrierNameStr  ,
   insuranceCarrierID ,

   policyHolderName   ,
   policyGroupID      ,

   beneficiaryFirstName ,
   beneficiaryLastName  ,
   beneficiaryID        ,

   expiredOrInvalid     ,

   created         ,
   createdBy
  )
  SELECT
    pat_m.patID               ,
    @clientID                 ,
    new_ins.carrierStr        ,

    CASE WHEN LEN( new_ins.carrierID ) > 0
      THEN  new_ins.carrierID
      ELSE  null
      END   ,

    new_ins.policyHolderName  ,
    new_ins.policyGroupID     ,

    ipd.firstName             ,
    ipd.lastName              ,
    new_ins.InsuranceMemberNumber ,

    CASE WHEN  new_ins.carrierID  > 0
              AND (
                LEN( new_ins.policyGroupID ) > 0   OR   LEN( new_ins.InsuranceMemberNumber ) > 0
              )
      THEN  0
      ELSE  1
      END ,

    GETDATE() ,

    ISNULL( @userID , 0)  -- can't insert NULL.
                          -- TODO: fix the service and call stack for data imports,
                          -- to use the userID of whoever made the import

  FROM  @incomingInsDataForExistingPatient new_ins
  JOIN  @patMatches pat_m  ON  pat_m.idx = new_ins.patMatchIdx
  JOIN  @incomingRecordsPatientData  ipd  ON  pat_m.incomingRecordIdx  =  ipd.idx


  AND
    new_ins.isExistingEntryNoChanges = 0
    --AND
    --new_ins.isExistingEntrySetDeac   = 0
*/


/*
  SELECT
    @numNewPatInsCreatedTot = COUNT(*)
  FROM
  @incomingInsDataForNewPatient
*/

  SELECT
    @numNewPatInsCreatedTot = 0

/*
  SELECT
    @numNewPatInsCreatedWCarr = COUNT(*)
  FROM
  @incomingInsDataForNewPatient
  WHERE  LEN( carrierID ) > 0
*/

  SELECT
    @numNewPatInsCreatedWCarr = 0

/*
  SELECT
    @numNewPatInsCreatedWUnk = COUNT(*)
  FROM
  @incomingInsDataForNewPatient
  WHERE  ISNULL( carrierID , 0) = 0
*/
  SELECT
    @numNewPatInsCreatedWUnk = 0

  --

/*
  SELECT
    @numExstPatInsMatchedTot = COUNT(*)
  FROM  @incomingInsDataForExistingPatient new_ins
  WHERE
     new_ins.isExistingEntryNoChanges = 1
     OR
     new_ins.isExistingEntrySetDeac   = 1
*/

  SELECT
    @numExstPatInsMatchedTot = 0


/*
  SELECT
    @numExstPatInsMatchedUpdtd = COUNT(*)
  FROM  @incomingInsDataForExistingPatient new_ins
  WHERE

     --new_ins.isExistingEntryNoChanges = 1
     --OR

     new_ins.isExistingEntrySetDeac   = 1
    -- TODO: the num deacd should be equal to the num inserted w/ corresponding entries
    --       already on file.  I haven't implemented counting logic, counting both separately
*/

  SELECT
    @numExstPatInsMatchedUpdtd = 0

/*
  SELECT
    @numExstPatInsMatchedNoChng = COUNT(*)
  FROM  @incomingInsDataForExistingPatient new_ins
  WHERE
     new_ins.isExistingEntryNoChanges = 1
*/

  SELECT
    @numExstPatInsMatchedNoChng = 0

/*
  SELECT
    @numExstPatInsCreatedTot = COUNT(*)
  FROM  @incomingInsDataForExistingPatient
  WHERE
     isExistingEntryNoChanges = 0
     AND
     isExistingEntrySetDeac   = 0
*/

  SELECT
    @numExstPatInsCreatedTot = 0

/*
  SELECT
    @numExstPatInsCreatedWCarr = COUNT(*)
  FROM  @incomingInsDataForExistingPatient new_ins
  WHERE
     new_ins.isExistingEntryNoChanges = 0
     AND
     new_ins.isExistingEntrySetDeac   = 0
     AND
     LEN( carrierID ) > 0
*/

  SELECT
    @numExstPatInsCreatedWCarr = 0


/*
  SELECT
    @numExstPatInsCreatedWUnk = COUNT(*)
  FROM  @incomingInsDataForExistingPatient new_ins
  WHERE
     new_ins.isExistingEntryNoChanges = 0
     AND
     new_ins.isExistingEntrySetDeac   = 0
     AND
     ISNULL( carrierID, 0) = 0
*/

  SELECT
    @numExstPatInsCreatedWUnk = 0 
    

 --



end  -- if type = pop


REPORT_OUT_AND_CLEANUP:


/*-------------------------------
 * Update status
 *------------------------------*/

set @endProcessingDateTime = getdate()

-- TODO: double-check that these timestamps are being populated correctly;
-- these were intended for pop matches only, not for running pop matches before sped matches

update dbo.Patient_Data_Imports
set
    fileProcessingCompleted        = 1

  , numOfExistingPatRecsFound      = @numPatMatches
  , numOfNewPatRecsNeeded          = @numNewPatRecsNeeded

  , numPatPlacesMatched  = @numPatPlacesMatched
  , numPatPlaceMatchesNeededForExistingPatient  = @numPatPlaceMatchesNeededForExistingPatient
  , numNewPatPlaceNeededForNewPatient           = @numNewPatPlaceNeededForNewPatient

  , numPatContactsMatched                         = @numPatContactsMatched
  , numPatContactMatchesNeededForExistingPatient  = @numPatContactMatchesNeededForExistingPatient
  , numPatContactMatchesNeededForNewPatient       = @numPatContactMatchesNeededForNewPatient
                                                        -- a bit of a misnomer; because of how the tables are structured,
                                                        -- we need new contacts and new "matches" (joins) for the new patients

  , numPatSiteMatched                                 = @numPatSiteMatched
  , numOfExistingPatSiteRecsNeededForExistingPatient  = @numPatSiteMatchesNeededForExisting

  , numNewPatAndNewPatSiteMatchesNeeded               = @numNewPatAndNewPatSiteMatchesNeeded

  , numExistingPatSiteRecsToDeac                      = @numExistingPatSiteRecsToDeac
  , numDistinctPatIDsWExistingPatSiteRecsToDeac       = @numDistinctPatIDsWExistingPatSiteRecsToDeac

  , numNewPatientsMatchedToUnknownSite = @numNewPatientsMatchedToUnknownSite
  , numExistingPatsWSiteCodeUnknownAndUnchanged = @numExistingPatsWSiteCodeUnknownAndUnchanged

  , numVeryOldPatRecsDeacd                = @numVeryOldPatRecsDeacd
  , numBlankCsisValsPopulatedForExisting  = @numBlankCsisValsPopulatedForExisting

  , fileProcessingStartDateTime    = @startProcessingDateTime
  , fileProcessingEndDateTime      = @endProcessingDateTime
  , lastModified                   = @endProcessingDateTime
  , lastModifiedBy                 = @userID

  --, generateEligibilityMatchFile   = iif( (@requiresRollBack = 0), 1, 0)

  , generateEligibilityMatchFile   = 0  -- will be triggering the TO_DHCS manually from now on

  , eligibilityMatchFileGenerated  = 0

  /*
  , numNewPatInsCreatedTot         = @numNewPatInsCreatedTot
  , numNewPatInsCreatedWCarr       = @numNewPatInsCreatedWCarr
  , numNewPatInsCreatedWUnk        = @numNewPatInsCreatedWUnk
  , numExstPatInsMatchedTot        = @numExstPatInsMatchedTot
  , numExstPatInsMatchedUpdtd      = @numExstPatInsMatchedUpdtd
  , numExstPatInsMatchedNoChng     = @numExstPatInsMatchedNoChng
  , numExstPatInsCreatedTot        = @numExstPatInsCreatedTot
  , numExstPatInsCreatedWCarr      = @numExstPatInsCreatedWCarr
  , numExstPatInsCreatedWUnk       = @numExstPatInsCreatedWUnk
  */

where ((id = @patientDataImportID) and (clientID = @clientID))

if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

SELECT
       @numOfIncomingPatDataRecords = numOfIncomingPatDataRecords
FROM dbo.Patient_Data_Imports
where ((id = @patientDataImportID) and (clientID = @clientID))


-----------------
if ( @numPatMatches != @numPatPlacesMatched + @numPatPlaceMatchesNeededForExistingPatient )
begin
  set @requiresInternalFollowupNotif = 1
end

if ( @numPatMatches < ( @numPatPlacesMatched + @numPatPlaceMatchesNeededForExistingPatient ) )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end
-----------------

-----------------
if ( @numNewPatRecsNeeded != @numNewPatPlaceNeededForNewPatient )
begin
  set @requiresInternalFollowupNotif = 1
end

if ( @numNewPatRecsNeeded < @numNewPatPlaceNeededForNewPatient )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end
-----------------

-----------------
/*
if ( @numPatMatches != ( @numPatContactsMatched + @numPatContactMatchesNeededForExistingPatient ) )
begin
  set @requiresInternalFollowupNotif = 1
end
*/

if ( @numPatMatches * 2 < ( @numPatContactsMatched + @numPatContactMatchesNeededForExistingPatient ) )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end
-----------------

-----------------
/*
if ( @numNewPatRecsNeeded != @numPatContactMatchesNeededForNewPatient )
begin
  set @requiresInternalFollowupNotif = 1
end
*/

if ( @numNewPatRecsNeeded * 2 < @numPatContactMatchesNeededForNewPatient )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end
-----------------

-----------------


if ( @numPatMatches != (@numPatSiteMatched + @numPatSiteMatchesNeededForExisting) )
begin
  set @requiresInternalFollowupNotif = 1
end

if ( @numPatMatches < (@numPatSiteMatched + @numPatSiteMatchesNeededForExisting) )
begin

    set @requiresRollback = 1;
    set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this

end
-----------------

-----------------
if ( @numNewPatRecsNeeded != @numNewPatAndNewPatSiteMatchesNeeded )
begin
  set @requiresInternalFollowupNotif = 1
end

if ( @numNewPatRecsNeeded < @numNewPatAndNewPatSiteMatchesNeeded )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end
-----------------


if ( @numNewPatRecsNeeded < @numNewPatInsCreatedTot )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end


if ( @numNewPatInsCreatedTot !=  @numNewPatInsCreatedWCarr + @numNewPatInsCreatedWUnk )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end


if ( @numPatMatches < @numExstPatInsMatchedTot )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end


if ( @numExstPatInsMatchedTot < @numExstPatInsMatchedUpdtd + @numExstPatInsMatchedNoChng )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end


if ( @numExstPatInsCreatedTot > @numPatMatches - @numExstPatInsMatchedTot )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end


if ( @numExstPatInsCreatedTot != @numExstPatInsCreatedWCarr + @numExstPatInsCreatedWUnk )
begin
  set @requiresRollback = 1;
  set @unknown_problem  = 1;  -- should be impossible for this to happen; I can't really implement a usable and intelligible error message for this
end

----------------

-- it seems like an oversight that it hasn't been corrected thus far (Apr 12 2023)

-----------------

end



declare @importErrorsMatchCandidatesJSON varchar(max)
declare @importErrorsMatchRowsJSON varchar(max)

if (SELECT COUNT(*) FROM @parsedpop WHERE requiresAttention = 1) > 0
begin


  if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
    SET @requiresInternalFollowupNotif = 1


  declare @requiresAttentionFinalOutput as table
  (
  "Name On File" nvarchar(102),
  "DOB" date,
  "CSIS" nvarchar(50),
  "BIC"  nvarchar(19),
  txtfile_row_num bigint,
  patient_active_status char,
  MatchingPatientID bigint,
  StuID_on_file nvarchar(50),
  weak_match int,
  very_strong_match bit,
  invalid_match int,
  stuid_on_file_conflicting bit,
  stuid_on_file_matching bit,
  conflicting_CSIS_found bit,
  no_stuid_on_file bit,
  CSISNotUniqueInExistingActiveRecords bit,
  CSISNotUniqueInExistingInactiveRecords bit,
  StuIDNotUniqueInExistingActiveRecords bit,
  StuIDNotUniqueInExistingInactiveRecords bit,
  last_name_mismatch bit,
  first_name_mismatch bit,
  lastname_exact_match bit,
  firstname_exact_match bit,
  FLapprox_DOB_match bit,
  CSIS_match_found bit,
  StuID_not_matched bit,
  PossibleMatchOrMatchesFound int,
  decision_score int,
  SPED char(1),
  parentConsentMCAL bit
  )

  INSERT INTO @requiresAttentionFinalOutput
  SELECT
  pp.LASTNAME_on_file + ', ' + pp.FIRSTNAME_on_file "Name On File",
  pp.DATE_OF_BIRTH_on_file "DOB",
  pp.CSIS_on_file "CSIS",
  pp.BIC_on_file "BIC",
  cand.*,
  ppf.SPED,  --TODO: It's kinda convoluted, looking at the FILE SpEd marker when we're analyzing the problematic SQL records.
             --The reason I did that originally was so that whoever reads the text logs can prioritize the problematic SQL records by spEd value (for revenue),
             --and I believed that the spEd marker in the file was more accurate, to give us better prioritization decisions.

             --HOWEVER, we're not using the text log very much; we're using the excel file.  So that rationale is gone.
             --We're not really prioritizing anything anymore.  The policy is that the entire file has to be valid.
  pp.parentConsentMCAL
  FROM @candidates_for_matching cand
  INNER JOIN @parsedpop ppf ON
             (
             cand.txtfile_row_num = ppf.ROW_NUM
             --OR ppf.MatchingPatientID = cand.MatchingPatientID
             )
             AND ppf.requiresAttention = 1  --we're only using the ppf table here for two things: for SpEd marker,

  LEFT JOIN @patMatches pat_m ON cand.MatchingPatientID = pat_m.patID
                                                                                                    -- and filtering on requiresAttention
  LEFT JOIN @allPatientsForThisClient pp ON pp.MatchingPatientID = cand.MatchingPatientID

  WHERE pat_m.patID IS NULL

 /* SELECT * FROM @requiresAttentionFinalOutput
         WHERE
           MatchingPatientID NOT IN
           ( SELECT patID FROM @patMatches )
           AND
           txtfile_row_num NOT IN
           ( SELECT patientDataImportRecordID FROM @patMatches )
*/



  SET @importErrorsJSON = CONVERT(
      VARCHAR(MAX),
      (SELECT * FROM @requiresAttentionFinalOutput

       FOR JSON AUTO )
    )

  SET @importErrorsMatchRowsJSON = CONVERT(
      VARCHAR(MAX),
      (

         SELECT
           ppf.* FROM @parsedpop ppf
         WHERE
           ppf.requiresAttention = 1

       FOR JSON AUTO
       )
    )

  SET @importErrorsMatchCandidatesJSON = CONVERT(
      VARCHAR(MAX),
      (

         SELECT
          c.* FROM @candidates_for_matching c
         WHERE
           MatchingPatientID NOT IN
           ( SELECT patID FROM @patMatches )

           OR

           txtfile_row_num NOT IN
           ( SELECT patientDataImportRecordID FROM @patMatches )

       FOR JSON AUTO
       )
    )

end


declare @importErrorsOptionalMergeCandidatesJSON varchar(max) = '[]'
declare @importErrorsOptionalMergeRowsJSON varchar(max) = '[]'


declare @requiresAttentionFinalOutput2 as table
(
  "Name On File" nvarchar(102),
  "DOB" date,
  "CSIS" nvarchar(50),
  "BIC"  nvarchar(19),
  txtfile_row_num bigint,
  patient_active_status char,
  MatchingPatientID bigint,
  StuID_on_file nvarchar(50),
  weak_match int,
  very_strong_match bit,
  invalid_match int,
  stuid_on_file_conflicting bit,
  stuid_on_file_matching bit,
  conflicting_CSIS_found bit,
  no_stuid_on_file bit,
  CSISNotUniqueInExistingActiveRecords bit,
  CSISNotUniqueInExistingInactiveRecords bit,
  StuIDNotUniqueInExistingActiveRecords bit,
  StuIDNotUniqueInExistingInactiveRecords bit,
  last_name_mismatch bit,
  first_name_mismatch bit,
  lastname_exact_match bit,
  firstname_exact_match bit,
  FLapprox_DOB_match bit,
  CSIS_match_found bit,
  StuID_not_matched bit,
  PossibleMatchOrMatchesFound int,
  decision_score int,
  SPED char(1),
  parentConsentMCAL bit
)

INSERT INTO @requiresAttentionFinalOutput2
SELECT
  pp.LASTNAME_on_file + ', ' + pp.FIRSTNAME_on_file "Name On File",
  pp.DATE_OF_BIRTH_on_file "DOB",
  pp.CSIS_on_file "CSIS",
  pp.BIC_on_file "BIC",
  cand.*,
  ppf.SPED,  --TODO: It's kinda convoluted, looking at the FILE SpEd marker when we're analyzing the problematic SQL records.
             --The reason I did that originally was so that whoever reads the text logs can prioritize the problematic SQL records by spEd value (for revenue),
             --and I believed that the spEd marker in the file was more accurate, to give us better prioritization decisions.

             --HOWEVER, we're not using the text log very much; we're using the excel file.  So that rationale is gone.
             --We're not really prioritizing anything anymore.  The policy is that the entire file has to be valid.
  pp.parentConsentMCAL
  FROM @candidates_for_matching cand
  INNER JOIN @parsedpop ppf ON
             (
             cand.txtfile_row_num = ppf.ROW_NUM
             --OR ppf.MatchingPatientID = cand.MatchingPatientID
             )
             --AND ppf.requiresAttention = 1  --we're only using the ppf table here for two things: for SpEd marker,

  --LEFT JOIN @patMatches pat_m ON cand.MatchingPatientID = pat_m.patID
                                                                                                    -- and filtering on requiresAttention
  CROSS APPLY (
    SELECT COUNT(*) "count"
    FROM @candidates_for_matching cand
    WHERE cand.txtfile_row_num = ppf.ROW_NUM
    HAVING COUNT(*) > 1
  ) count_cands

  LEFT JOIN @allPatientsForThisClient pp ON pp.MatchingPatientID = cand.MatchingPatientID

  --WHERE pat_m.patID IS NULL

SET @importErrorsOptionalMergeRowsJSON = CONVERT(
    VARCHAR(MAX),
    (

    SELECT
     ppf.* FROM @parsedpop ppf

    CROSS APPLY (
    SELECT COUNT(*) "count"
    FROM @candidates_for_matching cand
    WHERE cand.txtfile_row_num = ppf.ROW_NUM
    HAVING COUNT(*) > 1
    ) count_cands

       FOR JSON AUTO
       )
  )

SET @importErrorsOptionalMergeCandidatesJSON = CONVERT(
      VARCHAR(MAX),
      (

         SELECT
          c.* FROM @candidates_for_matching c

    CROSS APPLY (
    SELECT COUNT(*) "count"
    FROM @candidates_for_matching cand2
    WHERE c.txtfile_row_num = cand2.txtfile_row_num
    HAVING COUNT(*) > 1

    ) count_cands

       FOR JSON AUTO
       )
    )


-- if @importErrorsJSON is not null, nest its contents inside the "mergeHeuristicErrors" field of a JSON object
-- and assign that object to the variable @importErrorsJSON
SET @importErrorsJSON =
    '"mergeHeuristicErrors": ' + @importErrorsJSON + ' ,';

-- otherwise, set @importErrorsJSON as an empty string
SET @importErrorsJSON = ISNULL(@importErrorsJSON, '');

declare @unmatchedIncomingSitesJsonArr varchar(max);
SET @unmatchedIncomingSitesJsonArr =  CONVERT(
     VARCHAR(MAX),
     ( select * from @incomingRecordsPatientSite
       WHERE idx NOT IN (select incomingSiteRecordIdx from @patSite_PerfectMatches_inclNPSAndUnkSite)
       FOR JSON AUTO
     )
  )

declare @patsInvalidDOBsJsonArr varchar(max);
SET @patsInvalidDOBsJsonArr =  CONVERT(
     VARCHAR(MAX),

     ( select
       [Last_Name]
      ,[First_Name]

      ,calcAge
      ,[Grade]

      ,isTooYoung
      ,isTooOld

      ,[Student_ID]
      ,[CSIS_SSID]

      ,[DOB]
      ,[Sex]
       from @invalidDOBs

       FOR JSON AUTO
     )
  )


-- ugh... need some logic to dynamically prepend or not-prepend a comma character!
-- we're building out this JSON the hard way


SET @importErrorsJSON +=
    --STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "importErrorsMatchCandidatesJSON": '
      +
    IIF( LEN( @importErrorsMatchCandidatesJSON ) > 2,
        @importErrorsMatchCandidatesJSON,
        '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'

SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "importErrorsMatchRowsJSON": '
      +
    IIF( LEN( @importErrorsMatchRowsJSON ) > 2,
          @importErrorsMatchRowsJSON,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'

SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "importErrorsOptionalMergeRowsJSON": '
      +
    IIF( LEN( @importErrorsOptionalMergeRowsJSON ) > 2,
          @importErrorsOptionalMergeRowsJSON,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'

SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "importErrorsOptionalMergeCandidatesJSON": '
      +
    IIF( LEN( @importErrorsOptionalMergeCandidatesJSON ) > 2,
          @importErrorsOptionalMergeCandidatesJSON,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'


SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "newPatientsMatchedToUnknownSite": '
      +
    IIF( LEN( @unknownSitesNewPatientsJsonArr ) > 2,
          @unknownSitesNewPatientsJsonArr,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'


SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "existingPatientsMatchedToUnknownSite": '
      +
    IIF( LEN( @unknownSitesExistingPatientsJsonArr ) > 2,
          @unknownSitesExistingPatientsJsonArr,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'


SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "unmatchedSiteRowData": '
      +
    IIF( LEN( @unmatchedIncomingSitesJsonArr ) > 2,
          @unmatchedIncomingSitesJsonArr,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'


SET @importErrorsJSON +=
    -- STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "incomingRecordsWithIncorrectAgeGradeInfo": '
      +
    IIF( LEN( @patsInvalidDOBsJsonArr ) > 2,
          @patsInvalidDOBsJsonArr,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]
  + ' ,'


SET @importErrorsJSON +=
    --STUFF( @importErrorsJSON, 1, 1,   -- replace the the leading bracket

    ' "existingPatSiteRecsToDeac": '
      +
    IIF( LEN( @existingPatSiteRecsToDeacJsonArr ) > 2,
          @existingPatSiteRecsToDeacJsonArr,
          '[]'
    )    -- the variable here is already a JSON array, with the [ and ]


SET @importErrorsJSON = '{ ' + @importErrorsJSON + ' }'

-- DONE_BUILDING_REPORT_BLOB:

if (@requiresRollback = 0)
begin

  /* Looks like everything worked  */

  if (@tranOpen = 1)
  begin

    commit transaction
    set @tranOpen = 0

  end

  set @completedNormally = 1
    -- NOTE - this is the only place in code where @completedNormally is set 1.
    --        This bit becomes 1 only for successful completions in Live Mode;
    --        does not become 1 for succesful, good Test runs.

  if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
    UPDATE [dbo].[Import_From_A_From_Client_ToSPED_Files]
    SET
      closed_SQL_transaction = GETDATE(),
      committed_transaction  = 1,
      error_str              = @importErrorsJSON
    WHERE id = @importRecordLogID

  else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())

    UPDATE [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
    SET
      closed_SQL_pop_transaction = GETDATE(),
      committed_pop_transaction  = 1,
      error_str_pop_transaction  = @importErrorsJSON
    WHERE id = @importRecordLogID


  declare @numRowsToBeSentInOutgoingElig bigint;

  SELECT
    @numRowsToBeSentInOutgoingElig =
   COUNT(*)
    FROM
      dbo.TO_DHCS_ROWS
      (
	    @clientID

    , 0 -- @monthly_batch bit
    , null -- @ignorePreviousNcountEligTransmissionsForThisClient int
    , 1 --@includePatientsAlreadyAwaitingEligMatchInfo bit

    -- NOTE: must change these params that populate the count column
    --       if we ever change the params of exec dbo.PATIENT_DATA_IMPORT_TO_DHCS
    --       in the batch scripting

    , @patientDataImportID
    , @fileSubClass

    , @importRecordLogID
    , @structuredDataImportID
    , GETDATE()

    )

  UPDATE dbo.Patient_Data_Imports
    SET numRowsToBeSentInOutgoingElig = @numRowsToBeSentInOutgoingElig
  WHERE id = @patientDataImportID

end
else
begin

  /* Had problems */

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION

    set @tranOpen = 0
    set @completedNormally = 0
  end



  if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
    UPDATE [dbo].[Import_From_A_From_Client_ToSPED_Files]
    SET
      closed_SQL_transaction = GETDATE(),
      committed_transaction  = 0,
      error_str              = @importErrorsJSON

    WHERE id = @importRecordLogID

  else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())

    UPDATE [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
    SET
      closed_SQL_pop_transaction = GETDATE(),
      committed_pop_transaction  = 0,
      unknown_problem       = @unknown_problem ,  -- NOTE: we've until now been neglecting to set this bit in this table,
                                                   -- basically ever since we moved to the webupload and watcher based system
                                                   -- and decommed the batch-task based imports.  FIXING now

                                                   -- NOTE: this field does not exist for the corresponding table for tpop,
                                                   --      [Import_From_A_From_Client_ToSPED_Files]
                                                   --      This is a small inconsistency, since we built this table later and decided
                                                   --      an unknown_problem bitfield would be useful  
      error_str_pop_transaction              = @importErrorsJSON
    WHERE id = @importRecordLogID

end


-- prepend comma, or not
IF ( LEN(@importResultsJSON) > 2 AND LEN(@importErrorsJSON) > 2 )
  SET @importResultsJSON =
        STUFF( @importResultsJSON, 1, 1,   -- replace the the leading bracket
               '{ ,'
              )

IF ( LEN(@importErrorsJSON) > 2 )
    SET @importResultsJSON =
      STUFF( @importResultsJSON, 1, 1,   -- replace the the leading bracket
      '{ "importErrors": '
       +
      @importErrorsJSON    -- the variable here is already a JSON blob, with the { and }
    )

declare @statsOutgoingJSON varchar(max) = '[]';
declare @statsInternalJSON varchar(max) = '[]';


SET @statsOutgoingJSON =
  CONVERT(
    VARCHAR(MAX)
    ,
    (
      SELECT
        @numOfIncomingPatDataRecords numOfIncomingPatDataRecords,
        @numPatMatches numOfExistingPatRecsFound,
        @numNewPatRecsNeeded numOfNewPatRecsNeeded
      FOR JSON PATH
    )
  )

SET @statsOutgoingJSON = CONVERT(varchar(max), JSON_QUERY(@statsOutgoingJSON, '$[0]') )

SET @importResultsJSON =
      STUFF( @importResultsJSON, 1, 1,   -- replace the the leading bracket
      '{ "statsOutgoing": '
       +
      @statsOutgoingJSON    -- the variable here is already a JSON blob, with the { and }
      +
      ', '
    )

begin try

SET @statsInternalJSON =
  CONVERT(
    VARCHAR(MAX)
    ,
    (
      SELECT
        @numPatPlacesMatched                        numPatPlacesMatched,
        @numPatPlaceMatchesNeededForExistingPatient numPatPlaceMatchesNeededForExistingPatient,
        @numNewPatPlaceNeededForNewPatient          numNewPatPlaceNeededForNewPatient,

        /*
        @numCountPersonsAdded                         numCountPersonsAdded,
        @numCountForPatientsPersonsAdded              numCountForPatientsPersonsAdded,
        */

        @numPatContactsMatched                        numPatContactsMatched,
        @numPatContactMatchesNeededForExistingPatient numPatContactMatchesNeededForExistingPatient,
        @numPatContactMatchesNeededForNewPatient      numPatContactMatchesNeededForNewPatient,

        @numPatSiteMatched                                numPatSiteMatched,
        @numPatSiteMatchesNeededForExisting numOfExistingPatSiteRecsNeededForExistingPatient,
        @numNewPatAndNewPatSiteMatchesNeeded              numNewPatAndNewPatSiteMatchesNeeded,

        @numExistingPatSiteRecsToDeac  numExistingPatSiteRecsToDeac,
        @numDistinctPatIDsWExistingPatSiteRecsToDeac numDistinctPatIDsWExistingPatSiteRecsToDeac,

        @numNewPatientsMatchedToUnknownSite  numNewPatientsMatchedToUnknownSite,
        @numExistingPatsWSiteCodeUnknownAndUnchanged numExistingPatsWSiteCodeUnknownAndUnchanged ,

        @numVeryOldPatRecsDeacd               numVeryOldPatRecsDeacd ,
        @numBlankCsisValsPopulatedForExisting numBlankCsisValsPopulatedForExisting

          , numNewPatInsCreatedTot         = @numNewPatInsCreatedTot
          , numNewPatInsCreatedWCarr       = @numNewPatInsCreatedWCarr
          , numNewPatInsCreatedWUnk        = @numNewPatInsCreatedWUnk
          , numExstPatInsMatchedTot        = @numExstPatInsMatchedTot
          , numExstPatInsMatchedUpdtd      = @numExstPatInsMatchedUpdtd
          , numExstPatInsMatchedNoChng     = @numExstPatInsMatchedNoChng
          , numExstPatInsCreatedTot        = @numExstPatInsCreatedTot
          , numExstPatInsCreatedWCarr      = @numExstPatInsCreatedWCarr
          , numExstPatInsCreatedWUnk       = @numExstPatInsCreatedWUnk

      FOR JSON PATH
    )
  )
SET @statsInternalJSON = CONVERT(varchar(max), JSON_QUERY(@statsInternalJSON, '$[0]') )


SET @importResultsJSON =
      STUFF( @importResultsJSON, 1, 1,   -- replace the the leading bracket
      '{ "statsInternal": '
       +
      @statsInternalJSON    -- the variable here is already a JSON blob, with the { and }
      +
      ', '
    )

end try
begin catch
end catch


/* Renable binary or truncated data errors
 * TODO: Factor this out once we have added min, max char size validation to structured data
 */

SET ANSI_WARNINGS ON

RETURN(0)

END TRY
BEGIN CATCH

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()
  /* Renable binary or truncated data errors
   * TODO: Factor this out once we have added min, max char size validation to structured data
   */

  SET ANSI_WARNINGS ON

  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  -- Error or raise error with severity 11 to 19 will be caught here

  if (@tranOpen = 1)

  begin

    ROLLBACK TRANSACTION
  	set @tranOpen = 0

    if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())

      UPDATE [dbo].[Import_From_A_From_Client_ToSPED_Files]
      SET
        closed_SQL_transaction = GETDATE(),
        committed_transaction  = 0,
        error_str              = @importErrorsJSON
      WHERE id = @importRecordLogID

    else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())

      UPDATE [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
      SET
        closed_SQL_pop_transaction = GETDATE(),
        committed_pop_transaction  = 0,
        error_str_pop_transaction              = @importErrorsJSON
      WHERE id = @importRecordLogID


    set @requiresRollback = 1


    SET @unknown_problem = 1

  end
  set @completedNormally = 0
  return (0)

END CATCH
return (0)
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match_Pop_Data] TO [webuser]
go
