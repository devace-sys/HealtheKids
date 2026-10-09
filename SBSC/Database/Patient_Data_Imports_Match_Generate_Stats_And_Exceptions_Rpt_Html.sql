USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html (
    @importDataJSON         as varchar(max)

    -- two unused params??  :(
  , @includeInternalInfo    as bit
  , @structuredDataImportID as bigint
)

RETURNS varchar(max)

AS
BEGIN

-- TODO: consider making a per-row breakdown of rows that have been rejected due to DOB and gradelevel validation

declare @rptHtml                                    as varchar(max) = ''
declare @basicStats                                 as varchar(max) = ''
declare @rowsSkippedTblStr                          as varchar(max) = ''
declare @unmatchedSiteRowDataTblStr                 as varchar(max) = ''
declare @existingPatientsMatchedToUnknownSiteTblStr as varchar(max) = ''
declare @newPatientsMatchedToUnknownSiteTblStr      as varchar(max) = ''

declare @existingPatSiteRecsDeacdTblStr             as varchar(max) = ''

declare @numRowsSkippedDuringImport                 as int = 0
declare @importExceptionsTblStr                     as varchar(max) = ''


declare @importRptOptionalMergesStr                    as varchar(max) = ''


declare @mergeHeuristicErrors as table
(
  "Name On File" nvarchar(102),
  "DOB" date,
  "CSIS" nvarchar(50),
  "BIC"  nvarchar(19),
  txtfile_row_num varchar(max), --bigint,
  patient_active_status char,
  MatchingPatientID varchar(max), --bigint,
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
  parentConsentMCAL bit ,

  reason varchar(max)
)

set @importDataJSON = isnull(@importDataJson,'')
if (@importDataJSON = '') return ''

insert into @mergeHeuristicErrors
select

  "Name On File" ,
  "DOB" ,
  "CSIS" ,
  "BIC"  ,
  txtfile_row_num ,
  patient_active_status ,
  MatchingPatientID ,
  StuID_on_file ,
  weak_match ,
  very_strong_match ,
  invalid_match ,
  stuid_on_file_conflicting ,
  stuid_on_file_matching ,
  conflicting_CSIS_found ,
  no_stuid_on_file ,
  CSISNotUniqueInExistingActiveRecords ,
  CSISNotUniqueInExistingInactiveRecords ,
  StuIDNotUniqueInExistingActiveRecords ,
  StuIDNotUniqueInExistingInactiveRecords ,
  last_name_mismatch ,
  first_name_mismatch ,
  lastname_exact_match ,
  firstname_exact_match ,
  FLapprox_DOB_match ,
  CSIS_match_found ,
  StuID_not_matched ,
  PossibleMatchOrMatchesFound ,
  decision_score ,
  SPED ,
  parentConsentMCAL,

  reason = CASE WHEN weak_match = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' weak match, '
           ELSE
             ''
           END
           +
           CASE WHEN very_strong_match = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' very strong match, '
           ELSE
             ''
           END
           +
           CASE WHEN invalid_match = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' invalid match, '
           ELSE
             ''
           END
           +
           CASE WHEN stuid_on_file_conflicting = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' conflicting StuID on file, '
           ELSE
             ''
           END
           +
           CASE WHEN conflicting_CSIS_found = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' conflicting CSIS on file, '
           ELSE
             ''
           END
           +
           CASE WHEN last_name_mismatch = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' mismatching last name on file, '
           ELSE
             ''
           END
           +
           CASE WHEN first_name_mismatch = 1 THEN
             'patid ' + CAST(MatchingPatientID as varchar) + ' mismatching first name on file, '
           ELSE
             ''
           END

FROM OPENJSON( @importDataJSON,'$."importErrors"."mergeHeuristicErrors"')
with (
  "Name On File" nvarchar(102) '$."Name On File"',
  "DOB" date  '$."DOB"',
  "CSIS" nvarchar(50)  '$."CSIS"',
  "BIC"  nvarchar(19)  '$."BIC"',
  txtfile_row_num varchar(max)  '$."txtfile_row_num"',
  patient_active_status char  '$."patient_active_status"',
  MatchingPatientID varchar(max)  '$."MatchingPatientID"',
  StuID_on_file nvarchar(50)  '$."StuID_on_file"',
  weak_match int  '$."weak_match"',
  very_strong_match bit  '$."very_strong_match"',
  invalid_match int  '$."invalid_match"',
  stuid_on_file_conflicting bit  '$."stuid_on_file_conflicting"',
  stuid_on_file_matching bit  '$."stuid_on_file_matching"',
  conflicting_CSIS_found bit  '$."conflicting_CSIS_found"',
  no_stuid_on_file bit  '$."no_stuid_on_file"',
  CSISNotUniqueInExistingActiveRecords bit  '$."CSISNotUniqueInExistingActiveRecords"',
  CSISNotUniqueInExistingInactiveRecords bit  '$."CSISNotUniqueInExistingInactiveRecords"',
  StuIDNotUniqueInExistingActiveRecords bit  '$."StuIDNotUniqueInExistingActiveRecords"',
  StuIDNotUniqueInExistingInactiveRecords bit  '$."StuIDNotUniqueInExistingInactiveRecords"',
  last_name_mismatch bit  '$."last_name_mismatch"',
  first_name_mismatch bit  '$."first_name_mismatch"',
  lastname_exact_match bit  '$."lastname_exact_match"',
  firstname_exact_match bit  '$."firstname_exact_match"',
  FLapprox_DOB_match bit  '$."FLapprox_DOB_match"',
  CSIS_match_found bit  '$."CSIS_match_found"',
  StuID_not_matched bit  '$."StuID_not_matched"',
  PossibleMatchOrMatchesFound int  '$."PossibleMatchOrMatchesFound"',
  decision_score int  '$."decision_score"',
  SPED char(1)  '$."SPED"',
  parentConsentMCAL bit '$."parentConsentMCAL"'
) as t1

select
  @numRowsSkippedDuringImport = count(DISTINCT t1.rowNum)
FROM OPENJSON( @importDataJSON, '$."importErrors"."mergeHeuristicErrors"')
with (
     [rowNum]  int '$."txtfile_row_num"'
) as t1

set @basicStats = '<details open><summary>Patient Data Imported - Summary</summary>'
	   + '<table>'
	   + '<tbody>'

       +  '<tr><th>Existing Patient Records Found &amp; Matched:</th><td>'                   + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsOutgoing"."numOfExistingPatRecsFound"')  ,  '0')                           + '</td></tr>'

       +  '<tr><th class="text-right pr-2">Existing Matched Patient Records Found<br/>W/ Blank CSIS, Populated Now:</th><td>'                   + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsOutgoing"."numBlankCsisValsPopulatedForExisting"')  ,  '0')                           + '</td></tr>'

       +  '<tr><th class="text-right pr-2">Existing Too-Old Patient Records,</br>Not-Matched &amp; Deac''d:</th><td>'                   + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsOutgoing"."numVeryOldPatRecsDeacd"')  ,  '0')                           + '</td></tr>'

       +  '<tr><th>New Patient Records Created:</th><td>'                      + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsOutgoing"."numOfNewPatRecsNeeded"')  ,  '0')                               + '</td></tr>'
       +  '<tr><th>Rows Skipped During Import</th><td>'                        + convert(varchar(256),@numRowsSkippedDuringImport) + '</td></tr>'
       +  '<tr><th style="background-color:#cecece" >Existing Patient Places Matched:</th><td>'                  + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numPatPlacesMatched"') ,  '0')                                  + '</td></tr>'
       +  '<tr><th style="background-color:#cecece">Patient Places Created (Existing Patients):</th><td>'       + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numPatPlaceMatchesNeededForExistingPatient"') ,  '0')           + '</td></tr>'
       +  '<tr><th style="background-color:#cecece">Patient Places Created (New Patients):</th><td>'            + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numNewPatPlaceNeededForNewPatient"') ,  '0')                    + '</td></tr>'

       --
       --
       
       +  '<tr><th>Existing Patient Contacts Matched:</th><td>'                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numPatContactsMatched"') ,  '0')                                + '</td></tr>'
       +  '<tr><th>Patient Contacts Created (Existing Patients):</th><td>'     + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numPatContactMatchesNeededForExistingPatient"') ,  '0')         + '</td></tr>'
       +  '<tr><th>Patient Contacts Created (New Patients):</th><td>'          + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numPatContactMatchesNeededForNewPatient"') ,  '0')              + '</td></tr>'

       --
       --

       +  '<tr><th style="background-color:#cecece">Patient Insurance Created (New Patients):</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numNewPatInsCreatedTot"') ,  '0') 
                + '</td></tr>'
 

       +  '<tr><th style="background-color:#cecece">Patient Insurance Created &amp; Matched W/ Carrier (New Patients):</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numNewPatInsCreatedWCarr"') ,  '0') 
                + '</td></tr>'

       +  '<tr><th style="background-color:#cecece">Patient Insurance Saved W/ Unknown Carrier (New Patients):</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numNewPatInsCreatedWUnk"') ,  '0') 
                + '</td></tr>'

       
       +  '<tr><th style="background-color:#cecece">Existing Patient Insurance Matched:</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExstPatInsMatchedTot"') ,  '0')  
                + '</td></tr>'


       +  '<tr><th style="background-color:#cecece">Existing Patient Insurance Matched &amp; Updated:</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExstPatInsMatchedUpdtd"') ,  '0') 
                + '</td></tr>'


       +  '<tr><th style="background-color:#cecece">Existing Patient Insurance Matched W/ No Changes:</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExstPatInsMatchedNoChng"') ,  '0')  
                + '</td></tr>'


       +  '<tr><th style="background-color:#cecece">Patient Insurance Created (Existing Patients):</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExstPatInsCreatedTot"') ,  '0')  
                + '</td></tr>'


       +  '<tr><th style="background-color:#cecece">Patient Insurance Created &amp; Match W/ Carrier (Existing Patients):</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExstPatInsCreatedWCarr"') ,  '0')  
                + '</td></tr>'


       +  '<tr><th style="background-color:#cecece">Patient Insurance Saved W/ Unknown Carrier (Existing Patients):</th><td>'
                + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExstPatInsCreatedWUnk"') ,  '0') 
                + '</td></tr>'



       --
       --

       +  '<tr><th>Existing Patient Sites Matched:</th><td>'                   + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numPatSiteMatched"') ,  '0')                                    + '</td></tr>'
       +  '<tr><th>Patient Site Matches Created (Existing Patients):</th><td>' + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numOfExistingPatSiteRecsNeededForExistingPatient"') ,  '0')     + '</td></tr>'
       +  '<tr><th>Patient Site Matches Created (New Patients):</th><td>'      + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numNewPatAndNewPatSiteMatchesNeeded"') ,  '0')                  + '</td></tr>'
       +  '<tr><th>PATIENTS_School Records ended:</th><td>'                      + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExistingPatSiteRecsToDeac"') ,  '0')                  + '</td></tr>'
       +  '<tr><th>Distinct PatIDs - PATIENTS_School Records ended</th><td>'     + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numDistinctPatIDsWExistingPatSiteRecsToDeac"') ,  '0')                 + '</td></tr>'

       +  '<tr><th>New Patients Matched With Unknown Sitecode</th><td>'     + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numNewPatientsMatchedToUnknownSite"') ,  '0')                  + '</td></tr>'

       +  '<tr><th>Existing Patients Matched With Unknown Sitecode</th><td>'     + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExistingPatientsMatchedToUnknownSite"') ,  '0')                  + '</td></tr>'
                                                                                                                                                                                                  -- TODO: not yet populating this field in the JSON blob

       +  '<tr><th>Existing Patient Data Entries W/ Unknown Site Unchanged During Import</th><td>'     + ISNULL(  JSON_VALUE(@importDataJSON,     '$."statsInternal"."numExistingPatsWSiteCodeUnknownAndUnchanged"') ,  '0')                  + '</td></tr>'

	   + '</tbody></table></details>'


declare @importErrorsMatchCandidatesJSON varchar(max) = '[]'
declare @importErrorsMatchRowsJSON varchar(max) = '[]'


declare @importErrorsOptionalMergeCandidatesJSON varchar(max) = '[]'
declare @importErrorsOptionalMergeRowsJSON varchar(max) = '[]'


--BEGIN TRY

SET @importErrorsMatchCandidatesJSON =
  JSON_QUERY ( @importDataJSON, '$."importErrors"."importErrorsMatchCandidatesJSON"')
SET @importErrorsMatchRowsJSON =
  JSON_QUERY ( @importDataJSON, '$."importErrors"."importErrorsMatchRowsJSON"')


SET @importErrorsOptionalMergeCandidatesJSON =
  JSON_QUERY ( @importDataJSON, '$."importErrors"."importErrorsOptionalMergeCandidatesJSON"')
SET @importErrorsOptionalMergeRowsJSON = 
  JSON_QUERY ( @importDataJSON, '$."importErrors"."importErrorsOptionalMergeRowsJSON"')


--END TRY
--BEGIN CATCH
--END CATCH


if ( LEN(@importErrorsMatchCandidatesJSON) > 2 OR LEN(@importErrorsMatchRowsJSON) > 2 )
begin


  ; with ir_indiv_row_strings as (

  SELECT
    ROW_NUM txtfile_row_num ,
    'input file' "Source" ,
    cast(

    '<tr>' +

    '<td style="background-color:#00ee00">' + CAST( ROW_NUM as varchar ) + '</td>' +

    '<td style="background-color:#00ee00">' + 'input file' + '</td>' + -- "Source" ,

    '<td style="background-color:#00ee00"></td>' +

    '<td style="background-color:#00ee00">' + ISNULL( lastname_imported ,'')  + '</td>' + -- lname_col
    '<td style="background-color:#00ee00">' + ISNULL( firstname_imported ,'')  + '</td>' + -- fname_col
    '<td style="background-color:#00ee00">' + ISNULL( cast( DOB_imported as varchar) ,'')  + '</td>' + -- DOB_col
    '<td style="background-color:#00ee00">' + ISNULL( ImportedCSIS ,'')  + '</td>' + -- CSIS_col
    '<td style="background-color:#00ee00">' + ISNULL( SCHSTUDID ,'') + '</td>' + -- Stuid_col

    '<td style="background-color:#00ee00">' + ''  + '</td>' +

    -- new cell (empty)
    '<td style="background-color:#00ee00">' + ''  + '</td>' + -- patID_col

    '<td style="background-color:#00ee00">' + ISNULL( cast ( multipleActiveMatches as varchar) ,'') + '</td>' + -- --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( multipleInactiveMatches as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( rowConflictsWithAnotherRow as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( uniqueIdentifierNotUniqueInExistingActiveRecords as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( uniqueIdentifierNotUniqueInExistingInactiveRecords as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( weakMatchesOnlyFromActivePatientRecords as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( invalidMatchesOnlyFromActivePatientRecords as varchar) ,'') + '</td>' + 
    '<td style="background-color:#00ee00">'   + '</td>' + -- patID_col
    '</tr>'
     as varchar(max) ) rstr

    from OPENJSON( @importErrorsMatchRowsJSON )
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

                                                        DOB_imported /* date */ nvarchar(12) '$."DOB_imported"',
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
                                                        siteid int '$."siteid"' )

  ) ,

  cand_indiv_row_strings as (
    SELECT
    txtfile_row_num ,
    'match candidate' "source" ,
    cast(


    '<tr>' +

    '<td style="background-color:#eeee00">' + cast( txtfile_row_num as varchar) + '</td>' +

    '<td style="background-color:#eeee00">' + 'match candidate' + '</td>' + -- "Source" ,

    '<td style="background-color:#eeee00">' + decision_score + '</td>' +

    '<td style="background-color:#eeee00">' + ISNULL( cast ( pp.LAST_NAME   as varchar) ,'') + '</td>' + -- lname_col
    '<td style="background-color:#eeee00">' + ISNULL( cast ( pp.FIRST_NAME   as varchar) ,'') + '</td>' + -- fname_col
    '<td style="background-color:#eeee00">' + ISNULL( cast( cast ( pp.DATE_OF_BIRTH as date ) as varchar ) , '')  + '</td>' + -- DOB_col
    '<td style="background-color:#eeee00">' + ISNULL( cast ( CSIS   as varchar) ,'') + '</td>' + -- CSIS_col
    '<td style="background-color:#eeee00"></td>' + -- Stuid_col

    '<td style="background-color:#eeee00">' + patient_active_status + '</td>' +

    -- new cell (value: BIC)
    '<td style="background-color:#eeee00">' + ISNULL( pp.BIC, '' )  + '</td>'  + -- patID_col


    '<td style="background-color:#eeee00">' +  ISNULL( cast ( stuid_on_file_matching  as varchar) ,'') + '</td>' + -- --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( conflicting_CSIS_found  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( CSISNotUniqueInExistingActiveRecords  as varchar) ,'') + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( StuIDNotUniqueInExistingActiveRecords  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( StuIDNotUniqueInExistingInactiveRecords  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( last_name_mismatch  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( first_name_mismatch  as varchar) ,'') + '</td>' +
    '<td style="background-color:#eeee00">' + ISNULL( cast ( MatchingPatientID as varchar), '' )  + '</td>'  + -- patID_col
    '</tr>'

    as varchar(max) ) rstr


    FROM OPENJSON( @importErrorsMatchCandidatesJSON )
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
    decision_score varchar(2)  '$."decision_score"'
  ) cand
    JOIN dbo.PATIENTS_PATient pp ON pp.PATIENT_ID = cand.MatchingPatientID

  ),

  combined_rows as (
    SELECT * FROM ir_indiv_row_strings
    UNION ALL
    SELECT * FROM cand_indiv_row_strings
  ),
  combined_rows_ordered as (
    SELECT top 100000
   * FROM combined_rows
    ORDER BY txtfile_row_num ASC, "Source" asc
  )

  select @importExceptionsTblStr = '<details><summary>Patient Data Excluded During Import</summary>'
	                           + '<table>' -- <thead><tr><th>rowNum</th><th>patientIDs</th><th>Names</th><th>Reasons</th></tr></thead>

                               + '<thead>' +

    '<tr>' +

    '<td style="background-color:#00ee00">' + 'Input Row #' + '</td>' +
    '<td style="background-color:#00ee00">' + 'input file' + '</td>' + -- "Source" ,

    '<td style="background-color:#00ee00"></td>' +

    '<td style="background-color:#00ee00">lastname_imported</td>' + -- lname_col
    '<td style="background-color:#00ee00">firstname_imported</td>' + -- fname_col
    '<td style="background-color:#00ee00">DOB_imported</td>' + -- DOB_col
    '<td style="background-color:#00ee00">ImportedCSIS</td>' + -- CSIS_col
    '<td style="background-color:#00ee00">SCHSTUDID</td>' + -- Stuid_col

    '<td style="background-color:#00ee00">' + ''  + '</td>' +

    -- new empty cell 
    '<td style="background-color:#00ee00">' + ''  + '</td>' + -- patID_col

    '<td style="background-color:#00ee00">multipleActiveMatches</td>' + -- --
    '<td style="background-color:#00ee00">multipleInactiveMatches</td>' + --
    '<td style="background-color:#00ee00">rowConflictsWithAnotherRow</td>' + --
    '<td style="background-color:#00ee00">uniqueIdentifierNotUniqueInExistingActiveRecords</td>' + --
    '<td style="background-color:#00ee00">uniqueIdentifierNotUniqueInExistingInactiveRecords</td>' + --
    '<td style="background-color:#00ee00">weakMatchesOnlyFromActivePatientRecords</td>' + --
    '<td style="background-color:#00ee00">invalidMatchesOnlyFromActivePatientRecords</td>' +

    '<td style="background-color:#00ee00">'   + '</td>' + -- patID_col

    '</tr><tr>' +

    '<td style="background-color:#eeee00"></td>' + -- "Source" ,
    '<td style="background-color:#eeee00">' + 'match candidate' + '</td>' + -- "Source" ,

    '<td style="background-color:#eeee00">decision score</td>' +

    '<td style="background-color:#eeee00">last name on file</td>' + -- lname_col
    '<td style="background-color:#eeee00">first name</td>' + -- fname_col
    '<td style="background-color:#eeee00">DOB</td>' + -- DOB_col
    '<td style="background-color:#eeee00">CSIS</td>' + -- CSIS_col
    '<td style="background-color:#eeee00"></td>' + -- Stuid_col


    '<td style="background-color:#eeee00">active?</td>' +

    -- new header cell (label: BIC)

    '<td style="background-color:#eeee00">BIC</td>' + -- patID_col


    '<td style="background-color:#eeee00">stuid_on_file_matching</td>' + -- --
    '<td style="background-color:#eeee00">conflicting_CSIS_found</td>' + --
    '<td style="background-color:#eeee00">CSISNotUniqueInExistingActiveRecords</td>' + --
    '<td style="background-color:#eeee00">StuIDNotUniqueInExistingActiveRecords</td>' + --
    '<td style="background-color:#eeee00">StuIDNotUniqueInExistingInactiveRecords</td>' + --
    '<td style="background-color:#eeee00">last_name_mismatch</td>' + --
    '<td style="background-color:#eeee00">first_name_mismatch</td>' +

    '<td style="background-color:#eeee00">MatchingPatientID</td></tr>'


                               + '</thead>'

                               + '<tbody>'

                               + STRING_AGG (
                                 rstr
                                 ,
                                 '')
							   + '</tbody></table></details>'
  from combined_rows_ordered

end
else
begin
  ; with indiv_row_vals as (
    SELECT
          t1.txtfile_row_num,

					STRING_AGG( CAST( t1.[MatchingPatientID] as varchar), ', ' ) patIDs,
					pp.CONCAT_NAME ppCONCAT_NAME ,

					STRING_AGG( t1.reason, ', ') reasons

--					dbo.RPT_DATE_FMT(pp.DATE_OF_BIRTH),
--					isnull(pp.CSIS,'')

  from @mergeHeuristicErrors as t1
  join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = t1.MatchingPatientID
  GROUP BY t1.txtfile_row_num, pp.CONCAT_NAME
  ),
  indiv_row_strings as (
    SELECT
    '<tr><td>' + txtfile_row_num + '</td>'
							 + '<td>' + patIDs + '</td>'
					     + '<td>' + ppCONCAT_NAME + '</td>'
					     + '<td>' + reasons  + '</td>'
						   + '</tr>' row_str
    FROM indiv_row_vals
  )

  select @importExceptionsTblStr = '<details><summary>Patient Data Excluded During Import</summary>'
	                           + '<table><thead><tr><th>rowNum</th><th>patientIDs</th><th>Names</th><th>Reasons</th></tr></thead><tbody>'




                               + STRING_AGG (
                                 row_str
                                 ,
                                 '')
							   + '</tbody></table></details>'
  from indiv_row_strings



end


if ( LEN(@importErrorsOptionalMergeCandidatesJSON) > 2 OR LEN(@importErrorsOptionalMergeRowsJSON) > 2 )
begin


  ; with ir_indiv_row_strings as (

  SELECT
    ROW_NUM txtfile_row_num ,
    'input file' "Source" ,
    cast(

    '<tr>' +

    '<td style="background-color:#00ee00">' + CAST( ROW_NUM as varchar ) + '</td>' +

    '<td style="background-color:#00ee00">' + 'input file' + '</td>' + -- "Source" ,

    '<td style="background-color:#00ee00"></td>' +

    '<td style="background-color:#00ee00">' + ISNULL( lastname_imported ,'')  + '</td>' + -- lname_col
    '<td style="background-color:#00ee00">' + ISNULL( firstname_imported ,'')  + '</td>' + -- fname_col
    '<td style="background-color:#00ee00">' + ISNULL( cast( DOB_imported as varchar) ,'')  + '</td>' + -- DOB_col
    '<td style="background-color:#00ee00">' + ISNULL( ImportedCSIS ,'')  + '</td>' + -- CSIS_col
    '<td style="background-color:#00ee00">' + ISNULL( SCHSTUDID ,'') + '</td>' + -- Stuid_col

    '<td style="background-color:#00ee00">' + ''  + '</td>' +

    '<td style="background-color:#00ee00">' + ''  + '</td>' + -- patID_col

    '<td style="background-color:#00ee00">' + ISNULL( cast ( multipleActiveMatches as varchar) ,'') + '</td>' + -- --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( multipleInactiveMatches as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( rowConflictsWithAnotherRow as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( uniqueIdentifierNotUniqueInExistingActiveRecords as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( uniqueIdentifierNotUniqueInExistingInactiveRecords as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( weakMatchesOnlyFromActivePatientRecords as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#00ee00">' + ISNULL( cast ( invalidMatchesOnlyFromActivePatientRecords as varchar) ,'') + '</td></tr>'
     as varchar(max) ) rstr

    from OPENJSON( @importErrorsOptionalMergeRowsJSON )
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

                                                        DOB_imported /* date */ nvarchar(12) '$."DOB_imported"',
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
                                                        siteid int '$."siteid"' )

  ) ,

  cand_indiv_row_strings as (
    SELECT
    txtfile_row_num ,
    'match candidate' "source" ,
    cast(


    '<tr>' +

    '<td style="background-color:#eeee00">' + cast( txtfile_row_num as varchar) + '</td>' +

    '<td style="background-color:#eeee00">' + 'match candidate' + '</td>' + -- "Source" ,

    '<td style="background-color:#eeee00">' + decision_score + '</td>' +

    '<td style="background-color:#eeee00">' + ISNULL( cast ( pp.LAST_NAME   as varchar) ,'') + '</td>' + -- lname_col
    '<td style="background-color:#eeee00">' + ISNULL( cast ( pp.FIRST_NAME   as varchar) ,'') + '</td>' + -- fname_col
    '<td style="background-color:#eeee00">' + ISNULL( cast( cast ( pp.DATE_OF_BIRTH as date ) as varchar ) , '')  + '</td>' + -- DOB_col
    '<td style="background-color:#eeee00">' + ISNULL( cast ( CSIS   as varchar) ,'') + '</td>' + -- CSIS_col
    '<td style="background-color:#eeee00"></td>' + -- Stuid_col

    '<td style="background-color:#eeee00">' + patient_active_status + '</td>' +

    '<td style="background-color:#eeee00">' + ISNULL( cast ( MatchingPatientID as varchar), '' )  + '</td>'  + -- patID_col


    '<td style="background-color:#eeee00">' +  ISNULL( cast ( stuid_on_file_matching  as varchar) ,'') + '</td>' + -- --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( conflicting_CSIS_found  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( CSISNotUniqueInExistingActiveRecords  as varchar) ,'') + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( StuIDNotUniqueInExistingActiveRecords  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( StuIDNotUniqueInExistingInactiveRecords  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( last_name_mismatch  as varchar) ,'')  + '</td>' + --
    '<td style="background-color:#eeee00">' +  ISNULL( cast ( first_name_mismatch  as varchar) ,'') + '</td></tr>'

    as varchar(max) ) rstr


    FROM OPENJSON( @importErrorsOptionalMergeCandidatesJSON )
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
    decision_score varchar(2)  '$."decision_score"'
  ) cand
    JOIN dbo.PATIENTS_PATient pp ON pp.PATIENT_ID = cand.MatchingPatientID

  ),

  combined_rows as (
    SELECT * FROM ir_indiv_row_strings
    UNION ALL
    SELECT * FROM cand_indiv_row_strings
  ),
  combined_rows_ordered as (
    SELECT top 100000
   * FROM combined_rows
    ORDER BY txtfile_row_num ASC, "Source" asc
  )

  select @importRptOptionalMergesStr = '<details><summary>Optional Patient Merges Suggested</summary>'
	                           + '<table>' -- <thead><tr><th>rowNum</th><th>patientIDs</th><th>Names</th><th>Reasons</th></tr></thead>

                               + '<thead>' +

    '<tr>' +

    '<td style="background-color:#00ee00">' + 'Input Row #' + '</td>' +
    '<td style="background-color:#00ee00">' + 'input file' + '</td>' + -- "Source" ,

    '<td style="background-color:#00ee00"></td>' +

    '<td style="background-color:#00ee00">lastname_imported</td>' + -- lname_col
    '<td style="background-color:#00ee00">firstname_imported</td>' + -- fname_col
    '<td style="background-color:#00ee00">DOB_imported</td>' + -- DOB_col
    '<td style="background-color:#00ee00">ImportedCSIS</td>' + -- CSIS_col
    '<td style="background-color:#00ee00">SCHSTUDID</td>' + -- Stuid_col

    '<td style="background-color:#00ee00">' + ''  + '</td>' +
    '<td style="background-color:#00ee00">' + ''  + '</td>' + -- patID_col

    '<td style="background-color:#00ee00">multipleActiveMatches</td>' + -- --
    '<td style="background-color:#00ee00">multipleInactiveMatches</td>' + --
    '<td style="background-color:#00ee00">rowConflictsWithAnotherRow</td>' + --
    '<td style="background-color:#00ee00">uniqueIdentifierNotUniqueInExistingActiveRecords</td>' + --
    '<td style="background-color:#00ee00">uniqueIdentifierNotUniqueInExistingInactiveRecords</td>' + --
    '<td style="background-color:#00ee00">weakMatchesOnlyFromActivePatientRecords</td>' + --
    '<td style="background-color:#00ee00">invalidMatchesOnlyFromActivePatientRecords</td></tr>' +


    '<tr>' +

    '<td style="background-color:#eeee00"></td>' + -- "Source" ,
    '<td style="background-color:#eeee00">' + 'match candidate' + '</td>' + -- "Source" ,

    '<td style="background-color:#eeee00">decision score</td>' +

    '<td style="background-color:#eeee00">last name on file</td>' + -- lname_col
    '<td style="background-color:#eeee00">first name</td>' + -- fname_col
    '<td style="background-color:#eeee00">DOB</td>' + -- DOB_col
    '<td style="background-color:#eeee00">CSIS</td>' + -- CSIS_col
    '<td style="background-color:#eeee00"></td>' + -- Stuid_col


    '<td style="background-color:#eeee00">active?</td>' +
    '<td style="background-color:#eeee00">MatchingPatientID</td>' + -- patID_col


    '<td style="background-color:#eeee00">stuid_on_file_matching</td>' + -- --
    '<td style="background-color:#eeee00">conflicting_CSIS_found</td>' + --
    '<td style="background-color:#eeee00">CSISNotUniqueInExistingActiveRecords</td>' + --
    '<td style="background-color:#eeee00">StuIDNotUniqueInExistingActiveRecords</td>' + --
    '<td style="background-color:#eeee00">StuIDNotUniqueInExistingInactiveRecords</td>' + --
    '<td style="background-color:#eeee00">last_name_mismatch</td>' + --
    '<td style="background-color:#eeee00">first_name_mismatch</td></tr>'


                               + '</thead>'

                               + '<tbody>'

                               + STRING_AGG (
                                 rstr
                                 ,
                                 '')
							   + '</tbody></table></details>'
  from combined_rows_ordered

end


select @unmatchedSiteRowDataTblStr = '<details><summary>Rows with Patient Site Information Not Found</summary>'
                                   + '<table><thead><tr><th>patientDataImportRecordID</th><th>cds7</th><th>siteName</th><th>studentID</th><th>grade</th></thead></tr><tbody>'
                                   + STRING_AGG( convert(varchar(max),('<tr><td>'
      + ISNULL(patientDataImportRecordID,'')
     + '</td><td>'
     + ISNULL(cds7 ,'')
     + '</td><td>' +
     + ISNULL(siteName ,'')
     + '</td><td>'
     + ISNULL(studentID ,'')
     + '</td><td>' +
     + ISNULL(grade ,'')+
     + '</td></tr>')), '')
	 + '</tbody></table></summary></details>'
FROM OPENJSON ( @importDataJSON, '$."importErrors"."unmatchedSiteRowData"')
WITH
(
  patientDataImportRecordID varchar(max) '$.patientDataImportRecordID' ,
  siteName varchar(max) '$.siteName' ,
  studentID varchar(max) '$.studentID' ,
  grade varchar(max) '$.grade' ,
  cds7 varchar(max) '$.cds7'
)

SELECT @existingPatientsMatchedToUnknownSiteTblStr = '<details><summary>Rows with Patients Assigned to Unknown Site</summary>'
  + '<table><thead><tr><th>patientDataImportRecordID</th><th>patID</th></thead></tr><tbody>'
  + STRING_AGG( convert(varchar(max), '<tr><td>' + ISNULL(patientDataImportRecordID,'') + '</td><td>' + ISNULL(patID ,'')+ '</td></tr><tr>'),'')
  + '</tbody></table></details>'
FROM OPENJSON ( @importDataJSON, '$."importErrors"."existingPatientsMatchedToUnknownSite"')
WITH
(
  patientDataImportRecordID varchar(max) '$.patientDataImportRecordID' ,
  unknownSiteID varchar(max) '$.unknownSiteID' ,
  patID varchar(max) '$.patID'
)

SELECT
  @newPatientsMatchedToUnknownSiteTblStr =  '<details><summary>Rows with Site Information Not Found - New Patients</summary>'

  + '<table><thead><tr><th>patientDataImportRecordID</th><th>unknownSiteID</th></tr></thead><tbody>'
  + STRING_AGG('<tr><td>' + ISNULL(patientDataImportRecordID,'') + '</td><td>' + ISNULL(unknownSiteID ,'') + '</td></tr>', '') + '</tbody></table></details>'
FROM OPENJSON ( @importDataJSON, '$."importErrors"."newPatientsMatchedToUnknownSite"')
WITH
(
    patientDataImportRecordID varchar(max) '$.patientDataImportRecordID' ,
    unknownSiteID varchar(max) '$.unknownSiteID'
)

-- BEGIN TRY
-- it appears we can't use try/catch inside a scalar UDF;
-- would be nice if we had a way to safely ignore possible JSON parsing errors

SELECT
  @existingPatSiteRecsDeacdTblStr = '<details><summary>PATIENTS_School records ended</summary>' +
    '<table><thead><tr>' +
      '<th>patientDataImportRecordID</th><th>patID</th><th>siteID</th><th>patientSchoolID</th><th>grade</th></thead></tr><tbody>' +
       '<tr>' +
    STRING_AGG(
     CONVERT ( varchar(max) ,
     '<td>'   + ISNULL( CAST( patientDataImportRecordID as varchar ) , '') + '</td>' +
     '<td>'   + ISNULL( CAST( patID as varchar ) , '') + '</td>' +
     '<td>'   + ISNULL( CAST( siteID as varchar ) , '') + '</td>' +
     '<td>'   + ISNULL( CAST( patientSchoolID as varchar ) , '') + '</td>' +
     '<td>'   + ISNULL( grade , '' ) + '</td>' --+
--     '<td>' + ISNULL( studentID , '' ) + '</td>' --+
--     '<td>' + ISNULL( CAST( startdate as varchar ) , '' ) + '</td>'
     )
     ,
     '</tr><tr>'

    ) +
    + '</tr></tbody></table></details>'
FROM OPENJSON ( @importDataJSON, '$."importErrors"."existingPatSiteRecsToDeac"' )
WITH
(
    patientDataImportRecordID bigint

  , patID                     bigint
  , siteID                    bigint
  , patientSchoolID           bigint

  , grade                     varchar(20)

  /*
  , studentID                 nvarchar(50)
  , startdate                 datetime
  */
)

--ORDER BY patientSchoolID ASC

--END TRY
--BEGIN CATCH
  --
--END CATCH


set @rptHtml = @basicStats
             + isnull(@importExceptionsTblStr,'')
             + isnull(@importRptOptionalMergesStr, '')
			 + isnull(@unmatchedSiteRowDataTblStr,'')
			 + isnull(@existingPatientsMatchedToUnknownSiteTblStr,'')
			 + isnull(@newPatientsMatchedToUnknownSiteTblStr,'')
			 + isnull(@existingPatSiteRecsDeacdTblStr,'')

return @rptHtml


END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match_Generate_Stats_And_Exceptions_Rpt_Html] TO [webuser]
GO
