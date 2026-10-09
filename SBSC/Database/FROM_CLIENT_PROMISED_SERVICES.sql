USE spedmon
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FROM_CLIENT_PROMISED_SERVICES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FROM_CLIENT_PROMISED_SERVICES
GO

CREATE PROCEDURE [dbo].[FROM_CLIENT_PROMISED_SERVICES] (
  @FilePath varchar(max),
  @istestrun_bit bit,
  @clientID bigint,
  @templatefile varchar(250)
)
AS

BEGIN

LINENO 17

drop table if exists #rawcsv
drop table if exists #parsedpopfile
--drop table if exists #rows_with_usable_matches
drop table if exists #usable_matches

drop table if exists ##allMatchesPSandPP
drop table if exists ##allPatientsForThisClient
drop table if exists ##candidates_for_matching
drop table if exists ##allCandidatesDetailedInfo
drop table if exists ##final_matches_active_and_inactive

drop table if exists #rafoUnmatched1
drop table if exists #rafoUnmatched2

BEGIN TRY

declare @countRecordsImported int
declare @countRecordsMatched  int
declare @begin_time datetime2 = SYSDATETIME()

declare @unmatchedOutput dbo.PatientDataImportExceptions

declare @optionalMerges dbo.PatientDataImportExceptions

create table #rawcsv (
  "SEIS ID" bigint,
  "lastname_imported" varchar(51),
  "firstname_imported" varchar(51),
  "ServiceID" bigint,
  "Code" varchar(256),
  "Service" varchar(85),
  "Marked DNR" char(3),
  "Status" char(21),
  "Start Date" date,
  "End Date" date,
  "Provider" varchar(85),
  "Delivery" varchar(256),
  "Session Based" char(10),
  "Minutes / Session" int,
  "Sessions / Frequency" int,
  "Total Minutes / Frequency" int,
  "Frequency" varchar(256),
  "Location" varchar(256),
  "Initial Start Date" date,
  "School of Attendance" varchar(101),
  "School CDS Code" char(14),
  "ImportedCSIS" char(10),
  "SCHSTUDID" char(12),
  "Special Transportation Text" varchar(MAX),
  "Special Transportation" varchar(180),
  "Date of Last Annual IEP" date,
  "Date of Last Evaluation" date,
  "Disability 1 Code" varchar(256),
  "Disability 2 Code" varchar(256),
  "Medi-cal billing" varchar(4),
  "Current IEP Services" varchar(51),
  "Date of Next Annual IEP" date,
  "Gender" char(6),
  "DOB" date
);

/* very important - flow control flags, millenial-style comments */

declare @open_trans        as bit = 0 -- because obvz
declare @requires_rollback as bit = @istestrun_bit -- neat, rite?
declare @unknown_problem   as bit = 0

declare @errorstr          as varchar(200)

--declare @batchdate datetime = GETDATE() -- TODO: eventually we want to include the DATE_UPLOADED in the filename, and then parse it in the A rtn

SET @errorstr = 'problem executing dynamic sql for file IO'
SET QUOTED_IDENTIFIER OFF
declare @sql varchar(max) = 'bulk insert #rawcsv from ''' + @FilePath +
 ''' WITH (FIRSTROW = 2, FORMAT=''CSV'');'
EXEC (@sql)
SET QUOTED_IDENTIFIER ON

declare @canUseData bit = 1;



SET @errorstr = 'problem logging'

INSERT INTO dbo.[Import_From_A.5_SERVICES_From_Client_Files]
  ("file_name",client_id,began_processing,test_mode,canUseData)
  VALUES
  (@FilePath,@clientID,@begin_time, @istestrun_bit,@canUseData);

declare @log_num bigint = SCOPE_IDENTITY();

SET @errorstr = 'problem iterating through dataset'
SELECT
 ROW_NUMBER () OVER (ORDER BY "lastname_imported", "firstname_imported") ROW_NUM,
 DOB DOB_imported,
 null requiresAttention,
 null uniqueIdentifierNotUniqueInExistingActiveRecords,
 *
  INTO #parsedpopfile
  FROM #rawcsv

/* a guaranteed insomnia cure or your money back: http://www.sommarskog.se/share_data.html */

SET @errorstr = 'problem with matching heuristic?'
exec FROM_CLIENT_PATIENT_MATCH_HEURISTIC @clientID

SET @errorstr = 'problem sorting/filtering heuristic output?'

SELECT
  *,
  null notifyInternalOnMCALConsentChange,
  null notifyClientOnMCALConsentChange
INTO #usable_matches
FROM ##final_matches_active_and_inactive finalists
WHERE patient_active_status = 'Y'

/* important: make sure that no two "SEIS ID"s are matched to the same patID */
print 'DELETEing #usable_matches that are double-matched'
;with students_from_file as (
  select distinct
    ppf."SEIS ID", m.MatchingPatientID FROM #parsedpopfile ppf JOIN #usable_matches m ON ppf.ROW_NUM = m.txtfile_row_num
), double_matched_patIDs as (
  SELECT
    MatchingPatientID, COUNT("SEIS ID") "count" from students_from_file GROUP BY MatchingPatientID HAVING COUNT("SEIS ID") > 1
)
DELETE FROM #usable_matches WHERE MatchingPatientID IN (SELECT MatchingPatientID FROM double_matched_patIDs)
print 'done DELETEing'

SELECT @countRecordsImported = COUNT(*) FROM #parsedpopfile
SELECT @countRecordsMatched  = COUNT(*) FROM #usable_matches

;with distinct_unmatched_patients as (
SELECT
"lastname_imported",
"firstname_imported",
"DOB_imported",
"ImportedCSIS",
"SCHSTUDID",
"SEIS ID",
MIN(ppf.ROW_NUM) ROW_NUM
FROM #parsedpopfile ppf
LEFT JOIN ##final_matches_active_and_inactive finalists
ON finalists.txtfile_row_num =ppf.ROW_NUM and finalists.patient_active_status = 'Y'
WHERE finalists.MatchingPatientID IS NULL
GROUP BY "SEIS ID", "lastname_imported", "firstname_imported", "ImportedCSIS", "DOB_imported", "SCHSTUDID"
)
SELECT
'FILE' "Source",
null colB,
"lastname_imported" + ', ' + "firstname_imported" "Patient_Name",
'' colD,
"DOB_imported",
"ImportedCSIS",
"SCHSTUDID",
"SEIS ID",
'' colI,
'' colJ,
'' colK,
'' colL,
'' colM,
'' colN,
'' colQ,
'' colR,
ROW_NUM
INTO #rafoUnmatched1
FROM distinct_unmatched_patients

;with all_candidates_detailed_info as (
SELECT
  'SQL' "Source",
  decision_score,
  LASTNAME_on_file + ', ' + FIRSTNAME_on_file "Patient Name",
  CSIS_on_file,
  stuid_on_file,
  MatchingPatientID,
  patient_active_status,
  txtfile_row_num ROW_NUM
FROM ##allCandidatesDetailedInfo
WHERE txtfile_row_num IN (SELECT ROW_NUM FROM #rafoUnmatched1)
)
SELECT
  all_candidates_detailed_info."Source",
  all_candidates_detailed_info.decision_score,
  all_candidates_detailed_info."Patient Name",
  ppsql.MIDDLE_NAME,
  ppsql.DATE_OF_BIRTH,
  all_candidates_detailed_info.CSIS_on_file,
  all_candidates_detailed_info.stuid_on_file,
  all_candidates_detailed_info.MatchingPatientID,
  ppsql."BIC",
  ps.GRADE,
  piep.IEP_IFSP_NONE,
  CASE WHEN ppsql.parentConsentMCAL IS NULL THEN 'unknown' ELSE CASE WHEN ppsql.parentConsentMCAL = 0 THEN 'no' ELSE 'yes' END END colL,
  ppsql.SEX,
  all_candidates_detailed_info.patient_active_status,
  ss.SITE_ID,
  ss.SITE_NAME,
  all_candidates_detailed_info.ROW_NUM
INTO #rafoUnmatched2
FROM
all_candidates_detailed_info
LEFT JOIN dbo.PATIENTS_IEP piep ON piep.PATIENT_ID = all_candidates_detailed_info.MatchingPatientID
OUTER APPLY (SELECT GRADE, SITE_ID FROM dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) WHERE PATIENT_ID=all_candidates_detailed_info.MatchingPatientID )ps
LEFT JOIN dbo.SITES_Site ss ON ps.SITE_ID = ss.SITE_ID
LEFT JOIN dbo.PATIENTS_Patient ppsql ON all_candidates_detailed_info.MatchingPatientID = ppsql.PATIENT_ID

INSERT INTO @unmatchedOutput ("Source", "Decision Score", "Patient_Name", "Middle", DOB, CSIS, StuID, PatID, BIC, GRADE, SPED, parentConsentMCAL, GENDER, active, siteid, SchName, RowID)
SELECT * FROM #rafoUnmatched1
UNION
SELECT * FROM #rafoUnmatched2

;with unmatched_all_candidates_detailed_info as (
SELECT
  'SQL' "Source",
  cand.decision_score,
  cand.LASTNAME_on_file + ', ' + cand.FIRSTNAME_on_file "Patient Name",
  cand.CSIS_on_file,
  cand.stuid_on_file,
  cand.MatchingPatientID,
  cand.patient_active_status,
  MIN(cand.txtfile_row_num) ROW_NUM
FROM ##allCandidatesDetailedInfo cand
JOIN #usable_matches m ON cand.txtfile_row_num = m.txtfile_row_num and (m.MatchingPatientID IS NULL OR m.MatchingPatientID != cand.MatchingPatientID)
WHERE cand.txtfile_row_num IS NOT NULL AND cand.MatchingPatientID IS NOT NULL -- I wish I knew why this was necessary
GROUP BY decision_score, cand.LASTNAME_on_file, cand.FIRSTNAME_on_file, CSIS_on_file, stuid_on_file, cand.MatchingPatientID, cand.patient_active_status
--HAVING COUNT(distinct cand.MatchingPatientID) > 1
),
all_candidates_detailed_info as (
  SELECT * FROM unmatched_all_candidates_detailed_info
  UNION ALL
SELECT
  'SQL' "Source",
  cand.decision_score,
  cand.LASTNAME_on_file + ', ' + cand.FIRSTNAME_on_file "Patient Name",
  cand.CSIS_on_file,
  cand.stuid_on_file,
  cand.MatchingPatientID,
  cand.patient_active_status,
  --MIN(cand.txtfile_row_num) ROW_NUM
  cand.txtfile_row_num ROW_NUM
FROM ##allCandidatesDetailedInfo cand
JOIN #usable_matches m ON cand.txtfile_row_num = m.txtfile_row_num AND m.MatchingPatientID = cand.MatchingPatientID
WHERE cand.txtfile_row_num IS NOT NULL AND cand.MatchingPatientID IS NOT NULL -- I wish I knew why this was necessary
  AND cand.txtfile_row_num IN (SELECT ROW_NUM FROM unmatched_all_candidates_detailed_info)
--GROUP BY decision_score, cand.LASTNAME_on_file, cand.FIRSTNAME_on_file, CSIS_on_file, stuid_on_file, cand.MatchingPatientID, cand.patient_active_status
)
SELECT
  all_candidates_detailed_info."Source",
  all_candidates_detailed_info.decision_score,
  all_candidates_detailed_info."Patient Name",
  ppsql.MIDDLE_NAME,
  ppsql.DATE_OF_BIRTH,
  all_candidates_detailed_info.CSIS_on_file,
  all_candidates_detailed_info.stuid_on_file,
  all_candidates_detailed_info.MatchingPatientID,
  ppsql."BIC",
  ps.GRADE,
  piep.IEP_IFSP_NONE,
  CASE WHEN ppsql.parentConsentMCAL IS NULL THEN 'unknown' ELSE CASE WHEN ppsql.parentConsentMCAL = 0 THEN 'no' ELSE 'yes' END END colL,
  ppsql.SEX,
  all_candidates_detailed_info.patient_active_status,
  ss.SITE_ID,
  ss.SITE_NAME,
  all_candidates_detailed_info.ROW_NUM
INTO #rafoMerges2
FROM
all_candidates_detailed_info
LEFT JOIN dbo.PATIENTS_IEP piep ON piep.PATIENT_ID = all_candidates_detailed_info.MatchingPatientID
OUTER APPLY (SELECT GRADE, SITE_ID FROM dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) WHERE PATIENT_ID=all_candidates_detailed_info.MatchingPatientID )ps
LEFT JOIN dbo.SITES_Site ss ON ps.SITE_ID = ss.SITE_ID
LEFT JOIN dbo.PATIENTS_Patient ppsql ON all_candidates_detailed_info.MatchingPatientID = ppsql.PATIENT_ID

;with distinct_patients_requiring_attention as (
SELECT
"lastname_imported",
"firstname_imported",
"DOB_imported",
"ImportedCSIS",
"SCHSTUDID",
"SEIS ID",
MIN(ppf.ROW_NUM) ROW_NUM
FROM #parsedpopfile ppf
--ON finalists.txtfile_row_num =ppf.ROW_NUM and finalists.patient_active_status = 'Y'
WHERE ppf.ROW_NUM IN (SELECT ROW_NUM FROM #rafoMerges2) --finalists.MatchingPatientID IS NULL
GROUP BY "SEIS ID", "lastname_imported", "firstname_imported", "ImportedCSIS", "DOB_imported", "SCHSTUDID"
)
SELECT
'FILE' "Source",
null colB,
"lastname_imported" + ', ' + "firstname_imported" "Patient_Name",
'' colD,
"DOB_imported",
"ImportedCSIS",
"SCHSTUDID",
"SEIS ID",
'' colI,
'' colJ,
'' colK,
'' colL,
'' colM,
'' colN,
'' colQ,
'' colR,
ROW_NUM
INTO #rafoMerges1
FROM distinct_patients_requiring_attention

INSERT INTO @optionalMerges ("Source", "Decision Score", "Patient_Name", "Middle", DOB, CSIS, StuID, PatID, BIC, GRADE, SPED, parentConsentMCAL, GENDER, active, siteid, SchName, RowID)
SELECT * FROM #rafoMerges1
UNION
SELECT * FROM #rafoMerges2

--SELECT * FROM @unmatchedOutput ORDER BY RowID ASC

declare @unmatchedRowsExcelSql nvarchar(2520)= 'INSERT INTO OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;Database='
+ REPLACE (@templatefile, '.xls', '.UNMATCHED.xls')
+ ';HDR=NO'',''SELECT * FROM [Sheet1$A3:W3]'')
SELECT
  "Source",
  "Decision Score",
  "Patient_Name",
  "Middle",
  DOB,
  CSIS,
  StuID,
  PatID,
  BIC,
  GRADE,
  SPED,
  parentConsentMCAL,
  GENDER,
  active,
  null colO,
  null colP,
  siteid,
  SchName,
  null colS,
  null colT,
  null colU,
  null colV,
  RowID
FROM @unmatchedOutput ORDER BY RowID ASC, Source ASC, "Decision Score" DESC'

EXEC sp_executesql @unmatchedRowsExcelSql, N'@unmatchedOutput PatientDataImportExceptions READONLY', @unmatchedOutput=@unmatchedOutput

declare @mergeRowsExcelSql nvarchar(2520)= 'INSERT INTO OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;Database='
+ REPLACE (@templatefile, '.xls', '.RECOMMENDED-MERGES.xls')
+ ';HDR=NO'',''SELECT * FROM [Sheet1$A3:W3]'')
SELECT
  "Source",
  "Decision Score",
  "Patient_Name",
  "Middle",
  DOB,
  CSIS,
  StuID,
  PatID,
  BIC,
  GRADE,
  SPED,
  parentConsentMCAL,
  GENDER,
  active,
  null colO,
  null colP,
  siteid,
  SchName,
  null colS,
  null colT,
  null colU,
  null colV,
  RowID
FROM @optionalMerges ORDER BY RowID ASC, Source ASC, "Decision Score" DESC'

EXEC sp_executesql @mergeRowsExcelSql, N'@optionalMerges PatientDataImportExceptions READONLY', @optionalMerges=@optionalMerges

--select * FROM #rafoMerges1
--select * FROM #rafoMerges2

declare @opened_SQL_transaction datetime2(7) = SYSDATETIME()

--SELECT * FROM #usable_matches
--SELECT CAST(GETDATE() AS VARCHAR) + ' - noting which parent-consent values are to be updated and must be logged' "- TIMESTAMP -";
;with consent_data_from_file as (
  SELECT DISTINCT
    u_m.MatchingPatientID,
    LEFT(ppf."Medi-cal billing",1) "mCalpConsent"
  FROM #parsedpopfile ppf
  JOIN #usable_matches u_m
  ON ppf.ROW_NUM = u_m.txtfile_row_num
),
patient_audit_logs_with_most_recent_MCALconsent_value AS (
  SELECT
    pp_log.id,
    max_mcaleff_date_per_pat_rec.*
  FROM dbo.PATIENTS_AUDIT_LOG pp_log
  INNER JOIN
  (
  SELECT
    patRecID,
    MAX(parentConsentMCALEffectiveDate) parentConsentMCALEffectiveDate
  FROM dbo.PATIENTS_AUDIT_LOG pp_log
  GROUP BY patRecID
  ) max_mcaleff_date_per_pat_rec
      ON    pp_log.patRecID = max_mcaleff_date_per_pat_rec.patRecID
     AND    pp_log.parentConsentMCALEffectiveDate = max_mcaleff_date_per_pat_rec.parentConsentMCALEffectiveDate
),
pp_earliest_audit_logs_with_most_recent_MCALconsent_value AS (
  SELECT
    pp_log.patRecID,
    pp_log.parentConsentMCAL,
    pp_log.parentConsentMCALEffectiveDate,
    pp_log.userID
  FROM dbo.PATIENTS_AUDIT_LOG pp_log
  INNER JOIN  -- TODO: Could we possibly use a HAVING instead of an INNER JOIN ??
  (
  SELECT
    MIN(id) id,
    patRecID
  FROM
  patient_audit_logs_with_most_recent_MCALconsent_value
  GROUP BY patRecID
  ) pp_earliest_audit_logs_with_most_recent_MCALconsent_value
      ON    pp_log.id = pp_earliest_audit_logs_with_most_recent_MCALconsent_value.id
)

UPDATE u_m
   /* Action required: we must modify the A routine to ensure that we send out an email announcement to Anton, et al,
                           whenever a Y consent value IS changed TO an N CHANGE TO parental consent flags IS attempted OR made.
                          */
  SET
      notifyInternalOnMCALConsentChange = CASE WHEN m.SBSC_Employee IS NULL THEN 1 ELSE 0 END,
      notifyClientOnMCALConsentChange = CASE WHEN m.SBSC_Employee = 0 THEN 1 ELSE 0 END
   --SELECT *
   FROM #usable_matches u_m

   JOIN consent_data_from_file f ON u_m.MatchingPatientID = f.MatchingPatientID

   JOIN PATIENTS_Patient pp ON pp.PATIENT_ID = u_m.MatchingPatientID

LEFT JOIN

pp_earliest_audit_logs_with_most_recent_MCALconsent_value

      pp_log ON pp_log.patRecID = u_m.MatchingPatientID

-- we notify only when the last update was NOT made by an SBSC user, or was made by an unknown user

LEFT JOIN
[users].[dbo].[Users]
      u ON u.userrid = pp_log.userID
LEFT JOIN
[users].[dbo].[Membership]
      m ON m.UserId = u.UserId
WHERE
  pp.parentConsentMCAL = 1 AND f.mCalpConsent = 'N'
    -- below: we notify only when the last update was NOT made by an SBSC user, or was made by an unknown user
     AND
  (m.SBSC_Employee IS NULL OR m.SBSC_Employee = 0)



declare @outfilecontents            as [dbo].[NumberedLinesOfText]

declare @outfiledir        as varchar (max)
declare @filename_inc      as varchar (max)
declare @filenamebuffer    as varchar (max)

SET @filenamebuffer = @filepath
/*-------------------------------
 * Get JUST the filename
 * from filepath
 *------------------------------*/
while CHARINDEX('\', @filenamebuffer,0) <> 0
BEGIN
  set @filenamebuffer = substring(@filenamebuffer,CHARINDEX('\', @filenamebuffer,0)+1,99999999)
END

/*-------------------------------
 * Get JUST the file directory
 *------------------------------*/
SELECT @outfiledir=SUBSTRING(@templatefile,1,CHARINDEX('\services-file', @templatefile) - 1)


if (SELECT COUNT(*) FROM #usable_matches WHERE notifyInternalOnMCALConsentChange = 1) > 0
BEGIN
  INSERT INTO @outfilecontents
  SELECT
    CAST(u_m.MatchingPatientID AS VARCHAR)  --+ ',' + CHAR(9) +
    --ppf.lastname_imported  + ',' + CHAR(9) +
    --ppf.firstname_imported + ',' + CHAR(9) +
    --ppf.ImportedCSIS
  FROM #usable_matches u_m
    WHERE u_m.notifyInternalOnMCALConsentChange = 1

  SET @filename_inc = @filenamebuffer + ' - MCAL consent change - NOTIFYINTERNAL.txt'

  exec [dbo].[AppendTableToTextfile] @outfilecontents, @outfiledir, @filename_inc, 1
  DELETE FROM @outfilecontents
END

if (SELECT COUNT(*) FROM #usable_matches WHERE notifyClientOnMCALConsentChange = 1) > 0
BEGIN
  INSERT INTO @outfilecontents
  SELECT
    CAST(u_m.MatchingPatientID AS VARCHAR)  --+ ',' + CHAR(9) +
    --ppf.lastname_imported  + ',' + CHAR(9) +
    --ppf.firstname_imported + ',' + CHAR(9) +
    --ppf.ImportedCSIS
  FROM #usable_matches u_m
    WHERE u_m.notifyClientOnMCALConsentChange = 1

  SET @filename_inc = @filenamebuffer + ' - MCAL consent change - NOTIFYCLIENT.txt'

  exec [dbo].[AppendTableToTextfile] @outfilecontents, @outfiledir, @filename_inc, 1
  DELETE FROM @outfilecontents
END

UPDATE dbo.[Import_From_A.5_SERVICES_From_Client_Files]
SET opened_SQL_transaction = @opened_SQL_transaction
WHERE id = @log_num

BEGIN TRANSACTION

SET @open_trans = 1;

SET @errorstr = 'problem inserting into Import dump table'

INSERT INTO dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] (
     [File_import_log_entry]
    ,[Patient_ID]
    ,[Matched_Pat_ID_timestamp]
    ,[Patient_ID_orig]
    ,[SEIS ID]
    ,[Last Name]
    ,[First Name]
    ,[ServiceID]
    ,[Code]
    ,[Service]
    ,[Marked DNR]
    ,[Status]
    ,[Start Date]
    ,[End Date]
    ,[Provider]
    ,[Delivery]
    ,[Session Based]
    ,[Minutes / Session]
    ,[Sessions / Frequency]
    ,[Total Minutes / Frequency]
    ,[Frequency]
    ,[Location]
    ,[Initial Start Date]
    ,[School of Attendance]
    ,[School CDS Code]
    ,[Student SSID]
    ,[Student ID (District SIS)]
    ,[Special Transportation Text]
    ,[Special Transportation]
    ,[Date of Last Annual IEP]
    ,[Date of Last Evaluation]
    ,[Disability 1 Code]
    ,[Disability 2 Code]
    ,[Medi-cal billing]
    ,[Current IEP Services]
    ,[Date of Next Annual IEP]
    ,[Gender]
    ,[DOB]
	/* These columns are not supported in this routine.  This is for forwards compatibility.*/
    , [caseManagerName]
    , [exitedSpEdDate]
)
SELECT
  @log_num,
  m.MatchingPatientID,
  @begin_time,
  m.MatchingPatientID,
--  DATEADD(day, -1,CAST(GETDATE() AS date)) "Date_Services_File_Received",
  ppf."SEIS ID",
  ppf."lastname_imported",
  ppf."firstname_imported",
  ppf."ServiceID",
  ppf.Code,
  ppf."Service",
  ppf."Marked DNR",

  ppf."Status",
  ppf."Start Date",
  ppf."End Date",
  ppf."Provider",
  ppf."Delivery",
  ppf."Session Based",
  ppf."Minutes / Session",
  ppf."Sessions / Frequency",
  ppf."Total Minutes / Frequency",
  ppf."Frequency",
  ppf."Location",
  ppf."Initial Start Date",
  ppf."School of Attendance",
  ppf."School CDS Code",
  ppf."ImportedCSIS",
  ppf."SCHSTUDID",
  ppf."Special Transportation Text",
  ppf."Special Transportation",
  ppf."Date of Last Annual IEP",
  ppf."Date of Last Evaluation",
  ppf."Disability 1 Code",
  ppf."Disability 2 Code",
  ppf."Medi-cal billing",
  ppf."Current IEP Services",
  ppf."Date of Next Annual IEP",
  ppf."Gender",
  ppf.DOB_imported
  /* These columns are not supported in this routine.  This is for forwards compatibility.*/
  , null
  , null
FROM #parsedpopfile ppf
LEFT JOIN #usable_matches m
ON ppf.ROW_NUM = m.txtfile_row_num

;with consent_data_from_file as (
SELECT DISTINCT
m.MatchingPatientID,
LEFT(ppf."Medi-cal billing",1) "mCalpConsent"
FROM #parsedpopfile ppf
JOIN #usable_matches m
ON ppf.ROW_NUM = m.txtfile_row_num
)
UPDATE pp
SET
  parentConsentMCAL = CASE WHEN mCalpConsent = 'Y' THEN 1 ELSE 0 END,
  parentConsentMCALEffectiveDate =
      CASE WHEN (pp.parentConsentMCAL IS NULL AND mCalpConsent IS NOT NULL)
      THEN
        @opened_SQL_transaction
      ELSE
        CASE WHEN  (
           mCalpConsent IS NOT NULL
                AND
            dbo.YN_TO_BIT(mCalpConsent) != pp.parentConsentMCAL
        )
        THEN @opened_SQL_transaction
        ELSE pp.parentConsentMCALEffectiveDate END
  END
FROM dbo.PATIENTS_Patient pp
JOIN consent_data_from_file f ON
pp.PATIENT_ID = f.MatchingPatientID AND
  ( mCalpConsent = 'Y' OR mCalpConsent = 'N' )

--SELECT * FROM #rows_with_usable_matches r
--SELECT * FROM ##candidates_for_matching
--SELECT * FROM ##allCandidatesDetailedInfo
--SELECT * FROM ##final_matches_active_and_inactive
--SELECT * FROM #usable_matches

END TRY
BEGIN CATCH
    RAISERROR(@errorStr, 0, 1)
    SELECT CAST(GETDATE() AS VARCHAR) + ' - unknown problem found -' "- TIMESTAMP -";
    SET @errorStr = ' - unknown problem found - ' + ERROR_MESSAGE() + 'line ' + CAST(ERROR_LINE() AS VARCHAR)
    print @errorStr
    SET @requires_rollback = 1
    SET @unknown_problem = 1
   --GOTO DEBUG_AND_FINISH
END CATCH

BEGIN TRY
if (@open_trans = 1)
begin
  if (@requires_rollback = 0)
  begin
    SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - committing transaction' "- TIMESTAMP -";
    commit transaction
    UPDATE dbo.[Import_From_A.5_SERVICES_From_Client_Files]
      SET
      --data_processed = @batchdate,
      closed_SQL_transaction = SYSDATETIME(),
      committed_transaction = 1,
      records_imported = @countRecordsImported,
      records_matched  = @countRecordsMatched,
      records_not_matched  = ( @countRecordsImported - @countRecordsMatched )
      WHERE id = @log_num
  end
  else
  begin
    SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - rolling back transaction' "- TIMESTAMP -";
	  rollback transaction
    UPDATE dbo.[Import_From_A.5_SERVICES_From_Client_Files]
      SET
      --data_processed = @batchdate,
      closed_SQL_transaction = SYSDATETIME(),
      committed_transaction = 0,
      records_imported = @countRecordsImported,
      records_matched  = @countRecordsMatched,
      records_not_matched  =  ( @countRecordsImported - @countRecordsMatched ),
      unknown_problem = @unknown_problem,
      error_str = @errorstr
      WHERE id = @log_num
  end
end
END TRY
BEGIN CATCH
  /* If we end up here something really really bad has happened that we did not anticipate*/
  if (@@TRANCOUNT > 0)
  begin
    rollback transaction
    set @requires_rollback = 1
    SET @unknown_problem = 1
    SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - UNEXPECTED, UNKNOWN ERROR; rolled back transaction' "- TIMESTAMP -";
    UPDATE dbo.[Import_From_A.5_SERVICES_From_Client_Files]
      SET
      --data_processed = @batchdate,
      closed_SQL_transaction = SYSDATETIME(),
      committed_transaction = 0,
      records_imported = @countRecordsImported,
      records_matched  = @countRecordsMatched,
      records_not_matched  =  ( @countRecordsImported - @countRecordsMatched ),
      unknown_problem = @unknown_problem,
      error_str = @errorstr
      WHERE id = @log_num
  end
END CATCH

drop table if exists #rawcsv
drop table if exists #parsedpopfile
--drop table if exists #rows_with_usable_matches
drop table if exists #usable_matches

drop table if exists ##allMatchesPSandPP
drop table if exists ##allPatientsForThisClient
drop table if exists ##candidates_for_matching
drop table if exists ##allCandidatesDetailedInfo
drop table if exists ##final_matches_active_and_inactive

drop table if exists #rafoUnmatched1
drop table if exists #rafoUnmatched2

UPDATE dbo.[Import_From_A.5_SERVICES_From_Client_Files]
SET done_processing = SYSDATETIME()
WHERE id = @log_num

if (@requires_rollback = 1)
BEGIN
  print 'Stopped.  No changes saved.'
  if (@unknown_problem = 0) BEGIN
    RAISERROR(@errorstr,21,1) WITH LOG;
    --RETURN 1
  END -- else:
    --RAISERROR(53003, 11, 127) WITH LOG;
    return 53003
END


/*============================================================
 * Update patient SpEd data and promised services
 *============================================================*/

/*-------------------------------
 * Make sure its OK to parse 
 * this latest file import
 *------------------------------*/

set  @canUseData = 0
declare @okToProcess as bit = 0
declare @okToParse   as bit = 1  

/* If file was imported */

if (@log_num is not null)
begin     
  select top 1
       @okToProcess = isnull(t0.[committed_transaction],0)
     , @canUseData  = isnull(t0.canUseData,0)
  from dbo.[Import_From_A.5_SERVICES_From_Client_Files] as t0
  where (t0.id = @log_num)

  if (@canUseData  = 0) set @okToParse = 0
  if (@okToProcess = 0) set @okToParse = 0

end

/* If file was not imported then we cannot continue*/
else
begin

  set @canUseData  = 0
  set @okToProcess = 0
  set @okToParse   = 0
end
 
/*-------------------------------
 * If it is OK to parse
 *------------------------------*/

if (@okToParse = 1)
begin
 
    /* Record stats */
	
	update [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
    set 
	    opened_SQL_transaction_2 = GETDATE()
	  , committed_transaction_2  = 0
	  , canUseData               = 1
    where (id = @log_num)

    /* Parse.  
	 * Note: This routine completely replaces all promised service data for the client.
	 * It also maintains its own transactions and will fail silently if there is an
	 * issue and roll back to the previous stored promised service data.
	 */
	
	declare @completedNormally as bit = 0
    exec dbo.Patient_Data_Imports_Parse_And_Update_SpEd_Data @clientID, @completedNormally output
	
	/* This routine updates delivery exceptions */
	exec dbo.Patient_Promised_Services_Delivery_Expections_Find_And_Update_Orphans @clientID, @completedNormally output

    /* Record stats 
	 * Note: If the parsing failed then we set a flag so we can detect this.
	 * The thought here is that this if this latest import causes issues in the parsing then this file is at fault so we flag it.
	 * The change to the promised service data will be rolled back so we can correct the issue with the file and try again possibly.
	 */

	update [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
    set
        closed_SQL_transaction_2 = GETDATE()
      , committed_transaction_2  = @completedNormally
	  , canUseData               = @completedNormally
    where (id = @log_num)

end /* okToParse*/



RETURN 0

SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - we''re done here ' "- TIMESTAMP -";

END
GO

--GRANT EXECUTE ON  [dbo].[FROM_CLIENT_PROMISED_SERVICES] TO [webuser]
--GO
