USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Import_Save_Core') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Import_Save_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patient_Data_Import_Save_Core] (
    @userID                 bigint
 ,  @userGroup              int
 ,  @userRank               int
 ,  @clientID               bigint
 ,  @structuredDataImportID bigint


 -- ,  @testMode               bit
     -- NOTE: this param not being used? ??

 ,  @validateGradeDOBs      bit

 ,  @validateRec            bit
 ,  @spDetails              VARCHAR(8000) OUTPUT
 ,  @recordID               BIGINT        OUTPUT
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

declare @today                             as datetime
declare @importDataJSON                    as varchar(max) = ''

declare @numImportRecords                  as int = 0

declare @numRowsCSISMissing                as int = 0

declare @importFromFileReferenceID         as bigint
declare @countyCDS2                        as nchar(2)
declare @districtCDS5                      as nchar(5)
declare @fileSubClass                      as varchar(256) = ''
declare @fileName                          as varchar(256) = ''
declare @fileID                            as bigint = null
declare @preImportNumRowsSkipped           as int = 0
declare @preImportNumColsSkipped           as int = 0
declare @hasPreImportRowExceptions         as bit = 0
declare @preImportNumAdditionalRowsSkipped as int = 0
declare @additionalBadRowsJSON             as varchar(max) = ''
declare @hasAdditionalBadRowExceptions     as bit = 0

declare @additionalBadRows as table (
    idx    bigint identity(1,1)
  , rowNum bigint
  , reason varchar(512)
  unique clustered (rowNum,idx)
)

/*############################################################################
 *# Init and verify
 *############################################################################*/

/*-------------------------------
 * Init
 *------------------------------*/

set @today            = getdate()
set @spDetails        = ''
set @recordID         = 0
set @numImportRecords = 0

/*-------------------------------
 * Verify all parameters that
 * indicate what type of operation
 * to perform have been passed in
 * and any other parms that are
 * neccessary for proper operation
 *------------------------------*/

IF (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',   11, 1)
IF (@userRank    IS NULL) RAISERROR ('userRank is required',    11, 1)
IF (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)

IF (@clientID               IS NULL) RAISERROR ('Client id is required',   11, 1)
IF (@structuredDataImportID IS NULL) RAISERROR ('Structured data import id is required', 11, 1)

/*############################################################################
 *# Load client data
 *############################################################################*/

select top 1
    @countyCDS2   = SUBSTRING(clc.CLIENT_CDS,1,2)
  , @districtCDS5 = SUBSTRING(clc.CLIENT_CDS,3,5)
from dbo.CLIENTS_Client as clc
where
  (clc.CLIENT_ID = @clientID)

/*############################################################################
 *# Load structured data import record
 *############################################################################*/

select top 1
    @fileID         = sdi.id
  , @importDataJSON = sdi.importDataJSON
  , @fileName       = sdi.[fileName]
  , @fileSubClass   = sdi.fileSubClass
from dbo.Structured_Data_Imports as sdi
where (
      (sdi.id = @structuredDataImportID)
  and (sdi.clientID = @clientID)
)

/*############################################################################
 *# Exit if structured data file not found or if we are validating
 *############################################################################*/

if (@fileID is null)  return(0)
if (@validateRec = 1) return(0)

/*############################################################################
 *# Extract pre import bad rows statistics from sdi data
 *############################################################################*/

select top 1
    @preImportNumRowsSkipped = t1.rowsBad
  , @preImportNumColsSkipped = t1.colsBad
FROM OPENJSON( @importDataJSON, '$' )
WITH (
    [rowsBad]      int                      '$."totNumBadRows"'
  , [colsBad]      int                      '$."totNumGoodRowsWithBadOptionalData"'
) as t1

set @hasPreImportRowExceptions = 0
if ((@preImportNumRowsSkipped != 0) or (@preImportNumColsSkipped != 0)) set @hasPreImportRowExceptions = 1

/*############################################################################
 *# Create a new patient data imports record
 *############################################################################*/

INSERT INTO dbo.Patient_Data_Imports (
    structuredDataImportID
  , clientID
  , fileSubClass
  , fileAccepted
  , fileAcceptedOn
  , fileProcessingStarted
  , fileProcessingCompleted
  , created
  , createdBy
  , active
  , hasPreImportRowExceptions
  , preImportNumRowsSkipped
  , preImportNumColsSkipped
  , generateEligibilityMatchFile
  , okToCommitData

  , validateGradeDOBs
)
values (
    @structuredDataImportID
  , @clientID
  , @fileSubClass
  , 1
  , @today
  , 0
  , 0
  , @today
  , @userID
  , 1
  , @hasPreImportRowExceptions
  , @preImportNumRowsSkipped
  , @preImportNumColsSkipped
  , 0
  , 0 /* Initially its not ok to commit until staff has reviewed */
      /* NOTE: the "testMode" field (actually okToCommitData) is hardcoded 0 here; @testMode param is being ignored entirely. */

  , @validateGradeDOBs
)

declare @patientDataImportID bigint = SCOPE_IDENTITY();
set @recordID = @patientDataImportID;

--TOTPOP	A file including ALL STUDENTS ENROLLED	1	A file including ALL STUDENTS ENROLLED	1	2
--SpEdPOP	A file including ONLY special education students (BUT IS NOT CASEMIS A&B files)	1	Service Report File (From SpEd Management System)	1	2

/* Disable binary or truncated data errors
 * TODO: Factor this out once we have added min, max char size validation to structured data
 */

SET ANSI_WARNINGS OFF

/*############################################################################
 *# Find additional bad rows
 *############################################################################*/

   -- ...
if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin

  /*-------------------------------
   * CDS code does not match
   * county/district for given
   * clientID.  This check is
   * mainly here to prevent imports
   * if PCAL staff selects the
   * wrong client ID for a file
   *------------------------------*/

  insert into @additionalBadRows (
      rowNum
    , reason
  )
  select
      rowNum
    , reason = 'County and district part of cds 14 do not match clients'
  FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' )
  WITH (
        [rowBad]      bit                     '$."rowBad"'
	  , [rowNum]      int                     '$."rowNumIn"'
	  , [cdsCode]     nvarchar(14)            '$."rowData"."cdsCode"'
  ) as t1
  where (
           (t1.rowBad = 0)
       and ISNULL(t1.cdsCode, '') != ''
       and (SUBSTRING(t1.cdsCode,1,2) != @countyCDS2)
  	   and (SUBSTRING(t1.cdsCode,3,5) != @districtCDS5)
  )
end

/*############################################################################
 *# Save total population file data
 *############################################################################*/

  -- ...
if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
begin


/*-------------------------------
 * Info about file
 *------------------------------*/

insert into dbo.Import_From_A_From_Client_ToSPED_Files (
     test_mode
   , [file_name]
   , client_id
   , began_processing
   , structuredDataImport
   , structuredDataImportID
   , patientDataImportID
)
values (
    0
  , @fileName
  , @clientID
  , getdate()
  , 1
  , @structuredDataImportID
  , @patientDataImportID
)

set @importFromFileReferenceID = SCOPE_IDENTITY()

/*-------------------------------
 * File rows
 *------------------------------*/

INSERT INTO [dbo].[Import_From_A_From_Client_ToSPED_File_rows] (
    [FROM_CLIENT_log_entry]
  , [ROW_NUM]
  , [Last_Name]
  , [First_Name]
  , [MI]
  , [Student_ID]
  , [Grade]
  , [CSIS_SSID]
  , [County_CDS2]
  , [District_CDS5]
  , [School_Site_CDS7]
  , [School_Site_Name]


  , [School_Site_CDS7_orig]
  , [School_Site_Name_orig]

  , [DistID]
  , [Address1]
  , [Address2]
  , [City]
  , [Zip5]
  , [DOB]
  , [Sex]
  , [SpEd_Marker]
  , [ParentalConsentMCAL]

  , primaryContactLastName
  , primaryContactFirstName
  , primaryContactEmail
  , primaryContactPhone

  , secondaryContactLastName
  , secondaryContactFirstName
  , secondaryContactEmail
  , secondaryContactPhone

  , primaryInsuranceCompany
  , insuranceMemberNumber

  , [attendanceTrackName]
  , [preferredNickname]


  , [beneficiaryID]

  , policyGroupID
  , insCarrierNameStr
  , policyHolderName

  , teacherOrCounselorName

)

select
    @importFromFileReferenceID
  , t1.rowNum
  , t1.lastName
  , t1.firstName
  , t1.middleName
  , t1.studentID
  , t1.grade
  , t1.ssid
  , iif((len(t1.cdsCode) >= 2), SUBSTRING(t1.cdsCode,1,2),'')
  , iif((len(t1.cdsCode) >= 7), SUBSTRING(t1.cdsCode,3,5),'')

  , iif((len(t1.cdsCode) = 14), SUBSTRING(t1.cdsCode,8,7),'')
  , t1.schoolName

  , iif((len(t1.cdsCode) = 14), SUBSTRING(t1.cdsCode,8,7),'')
  , t1.schoolName

  , ''
  , t1.studentStreetAddress1
  , t1.studentStreetAddress2
  , t1.studentCity
  , t1.studentZip5
  , replace(convert(varchar, t1.dateOfBirth, 23),'-','')
  , t1.gender
  , t1.isSpecialEd
  , t1.parentalConsentMCAL

  , t1.primaryContactLastName
  , t1.primaryContactFirstName
  , t1.primaryContactEmail
  , t1.primaryContactPhone

  , t1.secondaryContactLastName
  , t1.secondaryContactFirstName
  , t1.secondaryContactEmail
  , t1.secondaryContactPhone

  , t1.primaryInsuranceCompany
  , t1.insuranceMemberNumber

  , t1.[attendanceTrackName]
  , t1.[preferredNickname]

  , t1.[beneficiaryID]

  , t1.policyGroupID
  , t1.insCarrierNameStr
  , t1.policyHolderName

  , t1.teacherOrCounselorName

FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' )

WITH (
      [rowBad]      bit                     '$."rowBad"'
	, [rowNum]      int                     '$."rowNumIn"'
    , [lastName]    nvarchar(20)            '$."rowData"."lastName"'
	, [firstName]   nvarchar(15)            '$."rowData"."firstName"'
	, [middleName]  char(1)                 '$."rowData"."middleName"'
	, [studentID]   varchar (20)            '$."rowData"."studentID"'
	, [grade]       varchar(20)             '$."rowData"."grade"'
	, [ssid]        char(10)                '$."rowData"."ssid"'
	, [cdsCode]     nvarchar(14)            '$."rowData"."cdsCode"'
	, [schoolName]  varchar(75)             '$."rowData"."schoolName"'
	, [studentStreetAddress1] nvarchar(75)  '$."rowData"."studentStreetAddress1"'
	, [studentStreetAddress2] nvarchar(75)  '$."rowData"."studentStreetAddress2"'
    , [studentCity]           nvarchar(20)  '$."rowData"."studentCity"'
	, [studentZip5]           char(5)       '$."rowData"."studentZip5"'
	, [dateOfBirth]           date          '$."rowData"."dateOfBirth"'
	, [gender]                char(1)       '$."rowData"."gender"'
    , [isSpecialEd]           char(1)       '$."rowData"."isSpecialEd"'
	, [parentalConsentMCAL]   char(1)	    '$."rowData"."parentConsentMCAL"'

	/* New fields for 2022 requests */

    , primaryContactLastName	 varchar(40)    '$."rowData"."primaryContactLastName"'
    , primaryContactFirstName	 varchar(40)    '$."rowData"."primaryContactFirstName"'
    , primaryContactEmail 	     varchar(40)    '$."rowData"."primaryContactEmail"'
    , primaryContactPhone		 varchar(12)    '$."rowData"."primaryContactPhone"'

    , secondaryContactLastName	 varchar(40)    '$."rowData"."secondaryContactLastName"'
    , secondaryContactFirstName  varchar(40)    '$."rowData"."secondaryContactFirstName"'
    , secondaryContactEmail 	 varchar(40)    '$."rowData"."secondaryContactEmail"'
    , secondaryContactPhone	     varchar(12)    '$."rowData"."secondaryContactPhone"'

    , primaryInsuranceCompany	 varchar(40)    '$."rowData"."primaryInsuranceCompany"'
    , insuranceMemberNumber 	 varchar(40)    '$."rowData"."insuranceMemberNumber"'

    , [attendanceTrackName]      varchar(256)  '$."rowData"."attendanceTrackName"'
    , [preferredNickname]        nvarchar(50)  '$."rowData"."preferredNickname"'

  , [beneficiaryID]              varchar(80)   '$."rowData"."insuranceMemberNumber"'

  , policyGroupID                varchar(256)   '$."rowData"."policyGroupID"'

  , insCarrierNameStr            varchar(512)   '$."rowData"."primaryInsuranceCompany"'
  , policyHolderName             varchar(512)   '$."rowData"."policyHolderName"'

  , teacherOrCounselorName         varchar(512)  '$."rowData"."teacherCounselorName"'

) as t1

/* Skip additional bad rows */

outer apply (
  select top 1
      t2.rowNum
    , t2.idx
  from @additionalBadRows as t2
  where (t2.rowNum = t1.rowNum)
) as t3
where (
      (t1.rowBad = 0)
  and (t3.idx is null)
)

/*-------------------------------
 * Count records extracted
 *------------------------------*/

 -- ...

select
  @numImportRecords = count(fr.ID)
from dbo.[Import_From_A_From_Client_ToSPED_File_rows] as fr
where (fr.FROM_CLIENT_log_entry = @importFromFileReferenceID)

select
  @numRowsCSISMissing = count(fr.ID)
from dbo.[Import_From_A_From_Client_ToSPED_File_rows] as fr

where (fr.FROM_CLIENT_log_entry = @importFromFileReferenceID)
  AND ISNULL( [CSIS_SSID], '') = ''

end

/*############################################################################
 *# Save special ed file data
 *############################################################################*/

  -- ...
else if (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
begin

/*-------------------------------
 * Info about file
 *------------------------------*/

insert into dbo.[Import_From_A.5_SERVICES_From_Client_Files] (
     test_mode
   , [file_name]
   , client_id
   , began_processing
   , structuredDataImport
   , structuredDataImportID
   , patientDataImportID
)
values (
    0
  , @fileName
  , @clientID
  , getdate()
  , 1
  , @structuredDataImportID
  , @patientDataImportID
)

set @importFromFileReferenceID = SCOPE_IDENTITY()

/*-------------------------------
 * File rows
 *------------------------------*/

INSERT INTO dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] (
    [File_import_log_entry]
  , [SEIS ID]
  , [Last Name]
  , [First Name]
  , [ServiceID]
  , [Code]
  , [Service]
  , [Marked DNR]
  , [Status]
  , [Start Date]
  , [End Date]
  , [Provider]
  , [Delivery]
  , [Total Minutes / Frequency]
  , [Location]
  , [Frequency]

  , [School of Attendance]
  , [School CDS Code]

  , [School_of_Attendance_orig]
  , [School_CDS_Code_orig]

  , [Student SSID]
  , [Student ID (District SIS)]
  , [Special Transportation]
  , [Date of Last Annual IEP]
  , [Date of Last Evaluation]
  , [Disability 1 Code]
  , [Disability 2 Code]
  , [Medi-cal billing]
  , [Date of Next Annual IEP]
  , [Gender]
  , [DOB]
  , [Session Based]
  , [Minutes / Session]
  , [Sessions / Frequency]
  , [caseManagerName]
  , [exitedSpEdDate]
  , [CommentsOrAdditionalInfo1]
  , [CommentsOrAdditionalInfo2]
  , [Special Transportation Text]

  , [attendanceTrackName]
  , [preferredNickname]

)
select
    [File_import_log_entry] = @importFromFileReferenceID
  , t1.[SEIS ID]
  , t1.[Last Name]
  , t1.[First Name]
  , [ServiceID] = isnull(t1.[ServiceID],0)
  , t1.[Code]
  , t1.[Service]
  , t1.[Marked DNR]
  , t1.[Status]
  , t1.[Start Date]
  , t1.[End Date]
  , t1.[Provider]
  , t1.[Delivery]
  , t1.[Total Minutes / Frequency]
  , t1.[Location]
  , t1.[Frequency]

  , t1.[School of Attendance]
  , [School CDS Code] = (@countyCDS2 + @districtCDS5 + t1.[School CDS Code])

  , t1.[School of Attendance]
  , [School CDS Code] = (@countyCDS2 + @districtCDS5 + t1.[School CDS Code])

  , t1.[Student SSID]
  , t1.[Student ID (District SIS)]
  , t1.[Special Transportation]
  , t1.[Date of Last Annual IEP]
  , t1.[Date of Last Evaluation]
  , t1.[Disability 1 Code]
  , t1.[Disability 2 Code]
  , t1.[Medi-cal billing]
  , t1.[Date of Next Annual IEP]
  , t1.[Gender]
  , t1.[DOB]
  , t1.[Session Based]
  , t1.[Minutes / Session]
  , t1.[Sessions / Frequency]
  , t1.[caseManagerName]
  , t1.[exitedSpEdDate]
  , t1.[CommentsOrAdditionalInfo1]
  , t1.[CommentsOrAdditionalInfo2]
  , t1.[Special Transportation Text]


  , t1.[attendanceTrackName]
  , t1.[preferredNickname]


FROM OPENJSON( @importDataJSON, '$."structuredDataRows"' )

WITH (
      [rowBad]                      bit          '$."rowBad"'
	, [rowNum]                      int          '$."rowNumIn"'
	, [SEIS ID]                     bigint       '$."rowData"."specEdSystemStudentID"'
    , [Last Name]                   varchar(51)  '$."rowData"."lastName"'
	, [First Name]                  varchar(51)  '$."rowData"."firstName"'
	, [ServiceID]                   bigint       '$."rowData"."specEdSystemSvcID"'
	, [Code]                        varchar(256) '$."rowData"."serviceCode"'
	, [Service]                     varchar(85)  '$."rowData"."serviceName"'
	, [Marked DNR]                  char(3)      '$."rowData"."markedDNR"'
	, [Status]                      char(21)     '$."rowData"."svcStatus"'
	, [Start Date]                  date         '$."rowData"."svcStartDate"'
	, [End Date]                    date         '$."rowData"."svcEndDate"'
    , [Provider]                    varchar(256) '$."rowData"."svcProvider"'
    , [Delivery]                    varchar(256) '$."rowData"."svcDelivery"'
	, [Total Minutes / Frequency]   int          '$."rowData"."svcDuration"'
	, [Location]                    varchar(256) '$."rowData"."svcLocation"'
	, [Frequency]                   varchar(256) '$."rowData"."svcFrequency"'
	, [School of Attendance]        varchar(101) '$."rowData"."schoolName"'
	, [School CDS Code]             char(14)     '$."rowData"."schoolCdsCode"'
	, [Student SSID]                char(10)     '$."rowData"."ssid"'
	, [Student ID (District SIS)]   char(50)     '$."rowData"."studentID"'
    , [Special Transportation]      varchar(180) '$."rowData"."hasSpecialTransportation"'
	, [Date of Last Annual IEP]     date         '$."rowData"."lastAnnualIEPDate"'
    , [Date of Last Evaluation]     date         '$."rowData"."lastEvaluationDate"'
    , [Disability 1 Code]           varchar(256) '$."rowData"."disability1Code"'
    , [Disability 2 Code]           varchar(256) '$."rowData"."disability2Code"'
    , [Medi-cal billing]            varchar(51)  '$."rowData"."canBillMediCal"'
	, [Date of Next Annual IEP]     date         '$."rowData"."nextAnnualIEPDate"'
	, [Gender]                      char(6)      '$."rowData"."gender"'
	, [DOB]                         date         '$."rowData"."dateOfBirth"'
	, [Session Based]               char(10)     '$."rowData"."sessionBasedSvc"'
	, [Minutes / Session]           int          '$."rowData"."minsPerSession"'
	, [Sessions / Frequency]        int          '$."rowData"."sessionsPerFreq"'
    , [caseManagerName]             varchar(256) '$."rowData"."caseManagerName"'
	, [exitedSpEdDate]              date         '$."rowData"."exitedSpEdDate"'
	, [CommentsOrAdditionalInfo1]   varchar(max) '$."rowData"."commentsOrAdditionalInfo1"'
    , [CommentsOrAdditionalInfo2]   varchar(max) '$."rowData"."commentsOrAdditionalInfo2"'
    , [Special Transportation Text] varchar(max) '$."rowData"."specialTransportationNotes"'

    , [attendanceTrackName]         varchar(256)  '$."rowData"."attendanceTrackName"'
    , [preferredNickname]           nvarchar(50)  '$."rowData"."preferredNickname"'

) as t1

/* Skips additional bad rows */

outer apply (
  select top 1
      t2.rowNum
    , t2.idx
  from @additionalBadRows as t2
  where (t2.rowNum = t1.rowNum)
) as t3
where (
      (t1.rowBad = 0)
  and (t3.idx is null)
)

/*-------------------------------
 * Count records extracted
 *------------------------------*/

 -- ...

select
  @numImportRecords = count(fr.ID)
from dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as fr
where (fr. [File_import_log_entry]= @importFromFileReferenceID)

SELECT
  @numRowsCSISMissing = COUNT(*)
from dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as fr

where (fr. [File_import_log_entry]= @importFromFileReferenceID)
  AND  ISNULL( [Student SSID], '') = ''

end

/*############################################################################
 *# Unsupported file
 *############################################################################*/

else
begin
  RAISERROR ('Unsupported file', 11, 1)
end

/* Reenable binary or truncated data errors
 * TODO: Factor this out once we have added min, max char size validation to structured data
 */

SET ANSI_WARNINGS ON

/*############################################################################
 *# Save counts, additional data, and update status
 *############################################################################*/

set @preImportNumAdditionalRowsSkipped = 0
select @preImportNumAdditionalRowsSkipped = count(t1.idx) from @additionalBadRows as t1

set @hasAdditionalBadRowExceptions = 0
if (@preImportNumAdditionalRowsSkipped != 0) set @hasAdditionalBadRowExceptions = 1

set @additionalBadRowsJSON = CONVERT(VARCHAR(MAX),( select rowNum, reason from @additionalBadRows FOR JSON AUTO))

set @today = getdate()

update dbo.Patient_Data_Imports
  set
    lastModified                           = @today
  , lastModifiedBy                         = @userID

  , numOfIncomingPatDataRecords            = @numImportRecords
  , numRowsCSISMissing                     = @numRowsCSISMissing


  , importFromFileReferenceID              = @importFromFileReferenceID
  , preImportNumAdditionalRowsSkipped      = @preImportNumAdditionalRowsSkipped
  , preImportAdditionalBadRowsJSONData     = @additionalBadRowsJSON
  , hasPreImportAdditionalBadRowExceptions = @hasAdditionalBadRowExceptions
where (
      (id = @patientDataImportID)
  and (clientID = @clientID)
)

RETURN(0)
END TRY
BEGIN CATCH

/* Reenable binary or truncated data errors
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


  DECLARE @ErrorMessage  AS  NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

   if (@ErrorSeverity > 11)
     SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO
