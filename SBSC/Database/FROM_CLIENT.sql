USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FROM_CLIENT') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FROM_CLIENT
GO

IF type_id('[dbo].[PatientDataImportExceptions]') IS NOT NULL DROP TYPE [dbo].[PatientDataImportExceptions];
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

create type PatientDataImportExceptions AS TABLE 
(
    id int identity(1,1), "Source" varchar(10), "Decision Score" int, "Patient_Name" nvarchar(102), "Middle" nvarchar(50), DOB date, CSIS nvarchar(50), StuID nvarchar(50),
      PatID varchar(9), BIC nvarchar(19), GRADE varchar(20), SPED char(5), parentConsentMCAL char(7), GENDER char(6), active varchar(5), CDS varchar(16), cliid varchar(6), siteid varchar(6), 
        SchName varchar(100), addy1 varchar(60), addy2 varchar(60),
          city varchar(100), zip5 char(6), RowID int, colX char(4), colY char(4), colZ char(4), colAA char(4), colAB char(4),
            colAC char(4), colAD char(4), colAE char(4), colAF char(4), colAG char(4), colAH char(4), colAI char(4), colAJ char(4), colAK char(4), colAL char(4), colAM char(4),
              colAN char(4), colAO char(4), colAP char(4), colAQ char(4)
);
GO

CREATE PROCEDURE [dbo].[FROM_CLIENT] (
	@FilePath varchar(max),
	@istestrun_bit bit,
	@destfolder varchar(max),
	@templatefile varchar(max)
)    
AS 

BEGIN

/***************************************************************************    
 * FROM_CLIENT */    
/**    
 * Parses a student data file from a client and imports this student data
 * into the appropriate tables.
 *
 * Please note:
 *
 *  - The incoming file MUST contain patients from ONE and ONLY ONE client
 *  - The database MUST have Ad Hoc Distributed Queries turned ON. You can do this by running the following :
 * 
 *    exec sp_configure 'show advanced options', 1
 *    GO
 *    RECONFIGURE
 *    GO
 *    exec sp_configure 'Ad Hoc Distributed Queries', 1
 *    GO
 *    RECONFIGURE
 *    GO
 *  
 * Additional Info (Please Keep This Updated As Code Is Changed)
 * 
 *
 * Flow-control overview (pseudocode)
 *
 
 * BEGIN TRY  -- data matching heuristic
 *   initial Data validation
 *   heuristic_block_1
 *   heuristic_block_2 
 *   heuristic_block_3
 *   heuristic_block_4
 *   heuristic_block_5
 *   heuristic_block_6  
 *   heuristic_block_7
 *   heuristic_block_8
 *   heuristic_block_9
 *   heuristic_block_10      
 * END TRY
 * BEGIN CATCH
 *   GOTO skip_my_transaction_and_report_out
 * END CATCH
 * 
 * flag_open_transaction = TRUE
 * BEGIN TRANSACTION
 *
 * BEGIN TRY
*	  INSERT INTO data_base SELECT my_records
*     UPDATE my_data
*  END TRY
*  BEGIN CATCH
*    flag_rollback_transaction = TRUE
*    GOTO report_out
*  END CATCH
*
*  REPORT_OUT:
*  BEGIN TRY
*    print stuff
*    SELECT SUM()s, COUNT()s FROM #temp_tabls
*    print more stuff
*    Write_some_files()
*  END TRY
*  BEGIN CATCH
*    flag_rollback_transaction = TRUE -- if the reporting failed, because it is unsafe to commit changes that can't be audited,
*                                     -- even if the changes themselves were successful, and nothing happened out of the ordinary
*    GOTO clean_up
*  END CATCH
*
*  CLEAN_UP:
*  DELETE #temp_tblz
*  IF (flag_open_transaction)
*    IF( !is_test AND !err_flag)
*      BEGIN TRY
*        INSERT INTO database_tablz SELECT information_about_file FROM #temp_tblz
*        COMMIT TRANSACTION
*      END TRY
*      BEGIN CATCH
*        err_flag
*        ROLLBACK TRANSACTION
*      END CATCH
*    ELSE
*      ROLLBACK TRANSACTION
*
*  BEGIN TRY
*    exec @excel_stuff
*  END TRY
*  BEGIN CATCH
*    print errors
*  END CATCH
*
*  IF( is_test OR err_flag)
*    RAISE err_flag_to_stop_B_routine_from_running
*
***************************************************************************/

LINENO 135

SET nocount ON

--set XACT_ABORT OFF

declare @begin_time datetime2 = SYSDATETIME()

/*#####################################################################################################################
  # Drop any temp tables that may have been left because of a failed run
  #####################################################################################################################*/

DROP TABLE if exists ##allMatchesPSandPP
DROP TABLE if exists #possibleMatchesUnfiltered
DROP TABLE if exists ##allCandidatesDetailedInfo
DROP TABLE if exists ##allPatientsForThisClient
DROP TABLE if exists #filevalidationerrors
DROP TABLE if exists ##candidates_for_matching
DROP TABLE if exists ##final_matches_active_and_inactive
DROP TABLE if exists #popfiletable
DROP TABLE if exists #numberedpopfiletable
DROP TABLE if exists #csisCounts
DROP TABLE if exists #stuidCounts
DROP TABLE if exists #requiresAttentionFinalOutput
DROP TABLE if exists #tmpExcel
DROP TABLE if exists #requiresAttentionFinalOutput2
DROP TABLE if exists #tmpExcel2
DROP TABLE if exists #parsedpopfile
DROP TABLE if exists #recommendedOptionalMerges

/*#####################################################################################################################
  # Setup our global variables
  #####################################################################################################################*/

declare @filenamebuffer    as varchar (max)
declare @tmp2Excel AS PatientDataImportExceptions;

declare @tmp2Excel2 AS PatientDataImportExceptions; -- for showing OPTIONAL fixes/merges

/* very important - flow control flags, millenial-style comments */

declare @open_trans        as bit = 0 -- because obvz
declare @requires_rollback as bit = @istestrun_bit -- neat, rite?
declare @unknown_problem as bit = 0
declare @errorstr          as varchar(MAX) = ''

create table #popfiletable (row nvarchar(max)) 
 
SELECT CAST(GETDATE() AS VARCHAR) + ' - starting import of patient data from client' "- TIMESTAMP -";
                           
/*#####################################################################################################################
  #                                             BLOCK 1 of 4                                                          
  # - Importing
  # - Parsing
  # - Validating
  # - Matching heuristics
  #
  # Note: A database transaction MAY be opened in this block.  
  #####################################################################################################################*/


BEGIN TRY 

/*#############################################################################
  #                                                                           #
  #              Setting Up File Path and File Name                           #
  #                                                                           #
  #############################################################################*/

RAISERROR ('Getting file name and path', 0, 1) WITH NOWAIT

/*-------------------------------
 *  Decompose filepath to get 
 *  filename - this is for later
 *  table storage and use
 *------------------------------*/
 
SET @filenamebuffer = @filepath

/*-------------------------------
 * Get JUST the filename
 * from filepath
 *------------------------------*/

while CHARINDEX('\', @filenamebuffer,0) <> 0
BEGIN
  set @filenamebuffer = substring(@filenamebuffer,CHARINDEX('\', @filenamebuffer,0)+1,99999999) 
END
 
RAISERROR ('Loading file...', 0, 1) WITH NOWAIT

/*#############################################################################
  #                                                                           #
  #                        Import Raw Data Pass 1 of 1                        #
  #                                                                           #
  #############################################################################*/

/*-------------------------------
 * Bulk insert raw data from 
 * client file into a temp table
 *------------------------------*/

/* IMPORTANT NOTE: 
 *
 * ROW_NUM will not actually work as one might expect with bulk imports.
 * Sure, it will assign a unique identifier for each row, which is vital for assigning relationships between these temp tables,
 * but the ROW_NUM will not consistently be in the same order as the input file.  Rows from input files will not be in the same order
 * as the original file for very-large data sets. 
 *
 * See IT Wiki for more details (http://sbscitdev.help4schools.com/dokuwiki/doku.php?id=mssql:bulkimportcaveats)
 */

SET QUOTED_IDENTIFIER OFF
declare @sql varchar(max) = 'bulk insert #popfiletable from "' + @FilePath + '"' -- NOTE: I had to make some tiny tweaks on the quoting syntax, vis-a-vis the original  -- JM 1 11 19
EXEC (@sql)          
SET QUOTED_IDENTIFIER ON

/*#############################################################################
  #                                                                           #
  #                        Import Raw Data Pass 1 of 2                        #
  #                                                                           #
  #############################################################################*/

/*-------------------------------
 * Create another temp table to
 * hold the results of parsing
 * the bulk inserted lines
 *------------------------------*/

CREATE TABLE #numberedpopfiletable (ROW_NUM bigint identity(1,1), row nvarchar(max)) --TODO: not sure why I created this table,
                                                                                     --Instead of creating the ROW_NUM field in the #ppf table

INSERT INTO #numberedpopfiletable
SELECT row FROM #popfiletable

/*#############################################################################
  #                                                                           #
  #                       Parsing Raw Data Pass 1 of 2                        #
  #                                                                           #
  #############################################################################*/

create table #parsedpopfile ( 

                                                        ROW_NUM bigint,

                                                        lastname_imported nvarchar(20), 
                                                        firstname_imported nvarchar(15),
                                                        STUDMI nvarchar (1),
                                                        
                                                        SCHSTUDID nvarchar(20),
                                                        GRADE nvarchar(20),
                                                        ImportedCSIS nvarchar(10),

                                                        SCHCDS nvarchar(14), 
                                                        SCHDISTID nvarchar(20),
                                                        SCHNAME nvarchar(75),

                                                        STU_ADDR_1 nvarchar(75),
                                                        STU_ADDR_2 nvarchar(75),
                                                        STU_ADDR_CIT nvarchar(20),
                                                        STU_ADDR_ZIP5 nvarchar(5),

                                                        DOB_imported date, 
                                                        GENDER nvarchar(1),
                                                        SPED nvarchar (1),
                                                        parentConsentMCAL char(1),

                                                        requiresAttention bit,
                                                        --requiresAttentionReason VARCHAR(40),          
                                                        
                                                        inputGenderInfoFailedValidation bit,
                                                        --cannotOverwriteParentalConsentValue bit,
                                                                                                                                                                        
                                                        isActiveMatch bit,
                                                        isInactiveMatch bit,
                                                        
                                                        multipleActiveMatches bit,
                                                        multipleInactiveMatches bit,
                                                        
                                                        rowConflictsWithAnotherRow bit,
                                                        secondaryAddressListed bit,
                                                        uniqueIdentifierNotUniqueInExistingActiveRecords bit,
                                                        uniqueIdentifierNotUniqueInExistingInactiveRecords bit,
                                                        
                                                        weakMatchesOnlyFromActivePatientRecords bit,
                                                        --weakMatchesOnlyFromInactivePatientRecords bit, -- we don't care, we will create a new record anyway
                                                        
                                                        invalidMatchesOnlyFromActivePatientRecords bit,
                                                        --invalidMatchesOnlyFromInactivePatientRecords bit,  -- we don't care, we will create a new record anyway                                       
                                                        
                                                        notifyInternalOnMCALConsentChange bit,
                                                        notifyClientOnMCALConsentChange bit,
                                                                                                
                                                        MatchingPatientID bigint,

                                                        matchedByCSISAndDOB bit, --TODO: this isn't on the excel output yet.
                                                        newStuIDProvided bit,
                                                        cannotSaveNewStuID bit,
                                                        
                                                        newRecordSuccess bit,
                                                        
                                                        unique_lookup_code_patient_school_enrollment_info bigint,

                                                        noSiteFound bit,
                                                        
                                                        clientid int,
                                                        siteid int,
                                                        
                                                        UNIQUE clustered (ROW_NUM),
                                                        UNIQUE nonclustered (GENDER, requiresAttention, ROW_NUM),                                               
                                                        UNIQUE nonclustered (requiresAttention, rowConflictsWithAnotherRow, ROW_NUM), --TODO: I added these indexes later, after finishing everything else,
                                                        UNIQUE nonclustered (requiresAttention, MatchingPatientID, ROW_NUM), --so that means they probably aren't being used in an ideal way.
                                                        UNIQUE nonclustered (requiresAttention, STU_ADDR_ZIP5, STU_ADDR_CIT, STU_ADDR_1, STU_ADDR_2, ROW_NUM)
                                                        --The queries in the heuristic were written in a very stream-of-consciousness way; that's why it's called a heuristic.
                                                        )


  
/*-------------------------------
 * Parse the bulk inserted lines
 * Parse string into fields
 *------------------------------*/

 INSERT INTO #parsedpopfile (ROW_NUM,lastname_imported, firstname_imported, STUDMI, SCHSTUDID, GRADE, ImportedCSIS /* aka SSID */, SCHCDS, SCHNAME, SCHDISTID, STU_ADDR_1, STU_ADDR_2, STU_ADDR_CIT, STU_ADDR_ZIP5 , DOB_imported, GENDER, SPED, parentConsentMCAL)

 SELECT
    ROW_NUM,
        RTRIM(LTRIM(SUBSTRING(ROW,      1       ,       20      ))) AS  lastname_imported       ,
        RTRIM(Ltrim(SUBSTRING(ROW,      21      ,       15      ))) AS  firstname_imported      ,
        RTRIM(LTRIM(SUBSTRING(ROW,      36      ,       1       ))) AS  STUDMI  ,
        RTRIM(lTRIM(SUBSTRING(ROW,      37      ,       20      ))) AS  SCHSTUDID       ,
        RTRIM(LTRIM(SUBSTRING(ROW,      57      ,       20      ))) AS  GRADE   ,
        RTRIM(LTRIM(SUBSTRING(ROW,      77      ,       10      ))) AS  SSID    ,
        RTRIM(LTRIM(SUBSTRING(ROW,      87      ,       14      ))) AS  SCHCDS  ,
        RTRIM(LTRIM(SUBSTRING(ROW,      101     ,       75      ))) AS  SCHNAME ,
        RTRIM(LTRIM(SUBSTRING(ROW,      176     ,       20      ))) AS  SCHDISTID       ,
        RTRIM(LTRIM(SUBSTRING(ROW,      196     ,       75      ))) AS  STU_ADDR_1      ,
        RTRIM(LTRIM(SUBSTRING(ROW,      271     ,       25      ))) AS  STU_ADDR_2      ,
        RTRIM(LTRIM(SUBSTRING(ROW,      296     ,       20      ))) AS  STU_ADDR_CIT    ,
        RTRIM(LTRIM(SUBSTRING(ROW,      316     ,       5       ))) AS  STU_ADDR_ZIP5   ,
        RTRIM(LTRIM(SUBSTRING(ROW,      321     ,       8       ))) AS  DOB_imported    ,
        RTRIM(LTRIM(SUBSTRING(ROW,      329     ,       1       ))) AS  GENDER  ,
        RTRIM(LTRIM(SUBSTRING(ROW,      330     ,       1       ))) AS  SPED  ,
        CASE RTRIM(LTRIM(UPPER(SUBSTRING(ROW,   331     ,       1       ))))
          WHEN 'Y' THEN '1'
          WHEN 'N' THEN '0'
          WHEN '1' THEN '1'
          WHEN '0' THEN '0'
          WHEN ' ' THEN NULL
          ELSE 'X' -- this is the error condition
          END
          AS    parentConsentMCAL   
FROM #numberedpopfiletable

/*#############################################################################
  #                                                                           #
  #                       Parsing Raw Data Pass 2 of 2                        #
  #                                                                           #
  #############################################################################*/

/*-------------------------------
 * Remove EOF row
 *
 *------------------------------*/

if ((SELECT COUNT(*) FROM #parsedpopfile WHERE lastname_imported NOT LIKE '%[a-zA-Z]%') > 1)
BEGIN
  SET @errorstr += ' - found 2 or more lastnames with no alpha characters'
  SET @requires_rollback = 1
  RAISERROR (@errorstr,   11, 1)
END
else
BEGIN
  DELETE FROM #parsedpopfile where lastname_imported = (
  SELECT top 1 lastname_imported FROM #parsedpopfile WHERE lastname_imported NOT LIKE '%[a-zA-Z]%'
  ) -- see https://stackoverflow.com/a/687040
END
                                                        
/*#############################################################################
  #                                                                           #
  #                       Validate Parsed Data                                #
  #                                                                           #
  #############################################################################*/

 SELECT 
  SPED, parentConsentMCAL, --columns we are validating
  firstname_imported, lastname_imported, ROW_NUM --columns we output to debugging string, for diagnostics purposes
 INTO #filevalidationerrors 
 FROM
 #parsedpopfile
 WHERE -- THIS SUBQUERY GETS ALL THE ROWS WITH INVALID, PROBLEMATIC VALUES  --TODO: add more validation conditions here, to validate more columns
  parentConsentMCAL = 'X' 
  OR
  SPED NOT IN ('y','n')

SELECT
@errorstr += ' - problem: invalid parentConsentMCAL flag, row ' + CAST(ROW_NUM AS VARCHAR) + ', for ' + firstname_imported + ' ' + SUBSTRING(lastname_imported,1,1) + ' '     
FROM (SELECT * FROM #filevalidationerrors
WHERE
  parentConsentMCAL = 'X') s1

SELECT
@errorstr += ' - problem: SPED column contains non-Y/N value, row ' + CAST(ROW_NUM AS VARCHAR) + ', for ' + firstname_imported + ' ' + SUBSTRING(lastname_imported,1,1) + ' '  
FROM (SELECT * FROM #filevalidationerrors  
 WHERE
  SPED NOT IN ('y','n') ) s1
  
/*#############################################################################
  #                                                                           #
  #   If there are any problems detected with parsed data we get out!         #
  #                                                                           #
  #############################################################################*/

IF (LEN(@errorstr)) > 0
BEGIN
  print @errorstr 
  SET @requires_rollback = 1
  RAISERROR (@errorstr,   11, 1)
  -- GOTO DEBUG_AND_FINISH
END

/*#############################################################################
  #                                                                           #
  #      Determine client ID from CDE number in parsed data                   #
  #                                                                           #
  #############################################################################*/

/*-------------------------------
 * Sanity check
 * Determine if clientID can be
 * found with given CDS
 * Note: This assumes that first 7
 * digits of the CDS code are the
 * same for every incoming record
 *------------------------------*/

RAISERROR ('Looking up client', 0, 1) WITH NOWAIT 

declare @clientID  AS int
declare @clientCDS AS nchar(7) = ''

declare @matching_client_count int = 0
declare @shortname    char(10) = ''

SELECT @shortname = SUBSTRING(
         @filenamebuffer,
         3,
         CHARINDEX(
           '_',
           @filenamebuffer,
           3
         ) - 3
       ) /* we can't use STRING_SPLIT() because the results could appear in a table in any unspecified, random order. */

SELECT top 1 @clientCDS = SUBSTRING(ppf.SCHCDS,1,7) FROM #parsedpopfile as ppf


SELECT
  @clientID = CLIENT_ID,
  @matching_client_count = matching_client_count
FROM (
SELECT top 1 CLIENT_ID, ROW_NUMBER() OVER (ORDER BY CLIENT_ID) matching_client_count
FROM dbo.CLIENTS_Client AS cc 
WHERE CLIENT_CDS = @clientCDS AND cc.ShortName = @shortname
ORDER BY matching_client_count DESC ) s1

/*#############################################################################
  #                                                                           #
  #               If we cant find clientID we get out!                        #
  #                                                                           #
  #############################################################################*/

IF (@clientID IS NULL)
BEGIN   
  SET @errorstr += ' - Cannot find the relevant client.  File rejected; no changes have been saved.'
  SET @requires_rollback = 1
  SET @unknown_problem = 1
  --RAISERROR (@errorstr,   11, 1)
  GOTO CLEANUP_AND_EXIT
END

IF (@matching_client_count != 1)
BEGIN   
  SET @errorstr += CAST(@matching_client_count AS varchar) + ' clients found, with shortname ' + @shortname + ' and CDS ' + @clientCDS
  SET @requires_rollback = 1
  SET @unknown_problem = 1
  --RAISERROR (@errorstr,   11, 1)
  GOTO CLEANUP_AND_EXIT
END

/*#############################################################################
  #                                                                           #
  #             Otherwise update parsed data with clientID                    #
  #                                                                           #
  #############################################################################*/

/* Populate client id field */

RAISERROR ('Remembering client', 0, 1) WITH NOWAIT
UPDATE #parsedpopfile set clientid = @clientID

/*#############################################################################
  #                                                                           #
  #             We may now create a log entry                                 #
  #                                                                           #
  #############################################################################*/

INSERT INTO dbo.[Import_From_A_From_Client_ToSPED_Files]("file_name",client_id,began_processing,test_mode)
 VALUES
 (@filenamebuffer,@clientID,@begin_time, @istestrun_bit);
declare @log_num bigint = SCOPE_IDENTITY();

/*#############################################################################
  #                                                                           #
  #      Parsed Data Cleanup and Default Field Value Assignments              #
  #                                                                           #
  #############################################################################*/

/*-------------------------------
 * Patient gender 
 *------------------------------*/

RAISERROR ('Validating gender info', 0, 1) WITH NOWAIT 

/* We can potentially output in report if we converted BG to MF or we assumed M for unspecified gender */
/* TODO: create a separate gender-breakdown report for statistical purposes, for each SUCCESSFUL run.
    x % 'M'
	x % 'F'
	x % 'B'
	x % 'G'
	x % unspecified, assumed M

	list out each of the unspecified
*/

UPDATE #parsedpopfile
SET inputGenderInfoFailedValidation = 1
WHERE GENDER NOT IN ('M','F', 'G', 'B')

/* This boolean flag will be shown in the report that comes out after an unsuccessful run.
   We need a separate report that will output the relevent subset after a successful run.
*/

UPDATE #parsedpopfile
SET GENDER =
        ( CASE  
                when GENDER = 'B' then 'M'      --Boy = Male
                when GENDER = 'G' then 'F'      --Girl = Female
                else 'M' -- This is because we start with a M for claim transmission if gender is unknown
				END
        )
WHERE GENDER NOT IN ('M','F')

/*-------------------------------
 * Populate siteid
 *------------------------------*/

RAISERROR ('Identifying site locations', 0, 1) WITH NOWAIT 

UPDATE t1
  SET t1.siteid = t2.SITE_ID
FROM #parsedpopfile as t1
JOIN dbo.SITES_Site AS t2 ON t2.SITE_CLIENT_ID = t1.clientid
WHERE (
        (t2.SITE_CDS = SUBSTRING(t1.SCHCDS,8,7))
    AND (t2.ACTIVE = 1)
)

SET @errorstr += ' - heuristic problem.  No changes saved.'

/* a guaranteed insomnia cure or your money back: http://www.sommarskog.se/share_data.html */

exec [dbo].[FROM_CLIENT_PATIENT_MATCH_HEURISTIC] @clientID


  -- this was harder than it looks! :D
;with all_new_stuids as (
  SELECT txtfile_row_num, cand.MatchingPatientID -- if a PATIENT_ID has more than one StuID on file, it will be found more than once, and matched to a row more than once.
  FROM ##candidates_for_matching cand             -- that is why we must have this spaghetti-ish GROUP BY logic.  TODO: refactor to remove dups earlier in the process
  JOIN #parsedpopfile ppf ON ppf.ROW_NUM = cand.txtfile_row_num
  WHERE cand.no_stuid_on_file = 0 OR (cand.no_stuid_on_file = 1 AND ppf.SCHSTUDID != '')
  GROUP BY txtfile_row_num, cand.MatchingPatientID
  HAVING MIN(stuid_on_file_conflicting + cand.no_stuid_on_file) > 0 -- if a MatchingPatientID has even 1 StuID that is not blank and not conflicting with the incoming,
)                                                                   -- that MatchingPatientID will not appear in this list (from this CTE)

  -- it's difficult when we fundamentally change the logic... first, a mismatched StuID was an idiot-check, now it isn't; so then we honored incoming mismatched StuIDs after dup-checking them.
  -- thus, instead of calling mismatched StuIDs "conflicting StuIDs", we're calling them "new StuIDs" because that sounds better.
  -- but now we don't want mandatory dup-checking on "new" StuIDs.
  -- we can't really change the ranking and scoring heuristic, because the laws of arithmetic still hold.
  -- also, we can't simply erase the StuID out of the temp table to ignore it, because then we can't output it during the debugging at the end of the program.
  -- we need to use our logical flags very carefully to decide when to ignore the incoming StuID.
UPDATE ##final_matches_active_and_inactive
  SET new_stuid_provided = 1
FROM all_new_stuids b
WHERE ##final_matches_active_and_inactive.txtfile_row_num = b.txtfile_row_num AND ##final_matches_active_and_inactive.MatchingPatientID = b.MatchingPatientID


--SELECT *
--FROM ##final_matches_active_and_inactive

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 6 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- For each input row, assigning the best active match, or flagging as unsuccessful - STEP 5 COMPLETE' "- TIMESTAMP -";

-- Update ppf with the ID of the matching active patient record, or, if none found, then set the logical flags

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

UPDATE #parsedpopfile
  SET
   isActiveMatch = CASE WHEN matches.MatchingPatientID IS NULL THEN 0 ELSE 1 END,
   MatchingPatientID = matches.MatchingPatientID,
   newStuIDProvided = new_stuid_provided,
   multipleActiveMatches = matches.cannot_choose_from_multiple_recs,
   weakMatchesOnlyFromActivePatientRecords = matches.weak_matches_only, -- notice that this assignment is not done in the other UPDATE, below
   invalidMatchesOnlyFromActivePatientRecords = matches.invalid_matches_only, -- ditto
   requiresAttention = CASE WHEN matches.cannot_choose_from_multiple_recs + matches.weak_matches_only + matches.invalid_matches_only != 0 THEN 1 ELSE 0 END,
   matchedByCSISAndDOB = matches.matchedByCSISAndDOB
  FROM ##final_matches_active_and_inactive matches
  WHERE #parsedpopfile.ROW_NUM = matches.txtfile_row_num AND matches.patient_active_status != 'N' -- active
    AND
  (#parsedpopfile.requiresAttention IS NULL OR #parsedpopfile.requiresAttention = 0)

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 7 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- For each of the currently-inactive match candidates that require merging, flagging the corresponding input file row# for human attention, if that row does not have a good, active match - STEP 6 COMPLETE' "- TIMESTAMP -";

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

UPDATE #parsedpopfile
  SET requiresAttention = 1,
      uniqueIdentifierNotUniqueInExistingInactiveRecords = 1
  FROM
  (
      SELECT
        DISTINCT txtfile_row_num
      FROM ##candidates_for_matching
      WHERE (
              (CSISNotUniqueInExistingInactiveRecords = 1 AND CSIS_match_found = 1)
              --OR
              --(StuIDNotUniqueInExistingInactiveRecords = 1 AND stuid_on_file_matching = 1 AND CSIS_match_found = 0)
            )
        AND
          (invalid_match IS NULL OR invalid_match = 0)
  ) subq1
  WHERE
    (#parsedpopfile.isActiveMatch IS NULL OR #parsedpopfile.isActiveMatch = 0) AND
    #parsedpopfile.ROW_NUM = subq1.txtfile_row_num
    -- notice we are not checking requiresAttention here.
    -- even if we know we can't process a row, there's no reason we can't check to see if the unique identifiers are, in fact, unique.

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 8 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- For each input row without any active match candidates (good or bad), assigning the best inactive match, or flagging as duplicates are found - STEP 7 COMPLETE' "- TIMESTAMP -";

-- For each incoming data row with no matching active patient record, find the matching inactive patient record, or, if none found, then set the logical flags

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

UPDATE #parsedpopfile
  SET
   isInactiveMatch = CASE WHEN matches.MatchingPatientID IS NULL THEN 0 ELSE 1 END,
   MatchingPatientID = matches.MatchingPatientID,
   newStuIDProvided = matches.new_stuid_provided,
   multipleInactiveMatches = matches.cannot_choose_from_multiple_recs,
   requiresAttention = matches.cannot_choose_from_multiple_recs -- notice that the requireAttention criteria is different than the other UPDATE, above
  FROM ##final_matches_active_and_inactive matches
  WHERE
    (#parsedpopfile.isActiveMatch IS NULL OR #parsedpopfile.isActiveMatch = 0) AND -- notice that this WHERE criteria is different than the other UPDATE, above
    #parsedpopfile.ROW_NUM = matches.txtfile_row_num AND
    matches.patient_active_status = 'N' AND -- inactive
    (#parsedpopfile.requiresAttention IS NULL OR #parsedpopfile.requiresAttention = 0) AND
    matches.weak_matches_only = 0 AND matches.invalid_matches_only = 0 -- notice that this WHERE criteria is different than the other UPDATE, above
    
                                  -- ! that's because when we iterate through ACTIVE matches for each row in the file, we if only find weak/invalid matches,
                                  -- we flag those matches for human attention.
                                  -- but when we iterate through INACTIVE matches for each row in the file, if there are only weak/invalid matches,
                                  -- we are supposed to completely ignore them and create a new patient record.

-- we must make sure that we don't have any patient records that have successfully matched to more than one row,
-- or any two rows that are competing for the same match

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 9 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- Are any two rows from the input file matched with the same patient record?  Let''s find out - STEP 8 COMPLETE' "- TIMESTAMP -";

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

UPDATE #parsedpopfile
  SET
   requiresAttention = 1,
   rowConflictsWithAnotherRow = 1
  FROM
  (
   SELECT
   MatchingPatientID
   FROM
   #parsedpopfile ppf2
   WHERE    ppf2.MatchingPatientID IS NOT NULL
           AND (requiresAttention IS NULL OR requiresAttention = 0)
   GROUP BY MatchingPatientID
   HAVING COUNT(DISTINCT ROW_NUM) > 1
  ) ppf2  
WHERE
      (#parsedpopfile.requiresAttention IS NULL OR #parsedpopfile.requiresAttention = 0)
          AND #parsedpopfile.MatchingPatientID = ppf2.MatchingPatientID

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 10 of 10                       #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- scanning input file for multiple address for the same patient - STEP 9 COMPLETE' "- TIMESTAMP -";
  
/* scan the multi-address entries, and set the multi-address flag = true.  set the requiresAttention flag off, for exactly one row from each grouping */

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

UPDATE #parsedpopfile
SET
  secondaryAddressListed = 1,
  requiresAttention = CASE WHEN ROW_NUM = first_listing_in_dup_set THEN 0 ELSE 1 END
FROM
--##candidates_for_matching cand
--INNER JOIN
(
  SELECT
    ppf2.MatchingPatientID,
    MIN(ROW_NUM) first_listing_in_dup_set--,
    --MAX(decision_score) highest_score
  FROM
    #parsedpopfile ppf2
    --JOIN
    --##candidates_for_matching cand
    --ON
    --  ppf2.ROW_NUM = cand.txtfile_row_num AND ppf2.MatchingPatientID = cand.MatchingPatientID
  WHERE
    isActiveMatch = 1
    AND
    rowConflictsWithAnotherRow = 1
    /*
        AND
    (cand.invalid_match IS NULL OR cand.invalid_match = 0)
    AND
    (cand.weak_match IS NULL OR cand.weak_match = 0)*/
  GROUP BY ppf2.MatchingPatientID
  HAVING
    COUNT(DISTINCT STU_ADDR_ZIP5) > 1
        OR
    COUNT(DISTINCT STU_ADDR_CIT) > 1
        OR
    COUNT(DISTINCT STU_ADDR_1) > 1
    OR
    COUNT(DISTINCT STU_ADDR_2) > 1
) double_tapped_records
--ON
--  double_tapped_records.MatchingPatientID = cand.MatchingPatientID --AND double_tapped_records.highest_score = cand.decision_score
WHERE
  /* #parsedpopfile.ROW_NUM = cand.txtfile_row_num AND */ #parsedpopfile.MatchingPatientID = double_tapped_records.MatchingPatientID

-- test buffer-overflow behavior.... not that we should have any of those!
--declare @var1 as TABLE (myint char(6))
--INSERT INTO @var1 values ('1234567')

SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - finished match-finding, duplicate-checking heuristic - STEP 10 COMPLETE' "- TIMESTAMP -";
RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above
--set @errorstr = ''

--END TRY
--BEGIN CATCH
--  RAISERROR('Ooops - heuristic problem',0,1)
--  SET @requires_rollback=1
--  SET @errorstr = 'heuristic problem.  No changes saved.'
--  GOTO DEBUG_AND_FINISH  -- IMPORTANT: This goto MUST be here, because we want the reports, but we don't want to modify data.
--END CATCH
      
/*#####################################################################################################################
  #                                             BLOCK 2 of 5                                                          #
  #####################################################################################################################*/


-- This is the second of 3 big TRY-CATCH blocks.  It contains the insert & updates to our patient data

 -- NOTE: the table below is a copy-paste of the custom table type, above.
 -- apparently SQL Server doesn't allow us to directly create temp tables from custom table types.
 -- This workaround, see https://stackoverflow.com/a/21127996, doesn't work for us,
 -- because it doesn't preserve the identity-column incrementing logic.

 -- TODO: It might someday be useful to put some indexes on these temp tables, and, ya know, use them
CREATE TABLE #tmpExcel
(
  "Source" varchar(10),
  "Decision Score" int,
  "Patient_Name" nvarchar(102),
  "Middle" nvarchar(50),
  DOB date,
  CSIS nvarchar(50),
  StuID nvarchar(50),
  PatID varchar(9),
  BIC nvarchar(19),
  GRADE varchar(20),
  SPED char(5),
  parentConsentMCAL char(7),
  GENDER char(6),
  ACTIVE varchar(5),
  CDS varchar(16),
  cliid varchar(6),
  siteid varchar(6),
  SchName varchar(100),
  addy1 varchar(60),
  addy2 varchar(60),
  city varchar(100),
  zip5 char(6),
  rowID int,
  colX char(4),
  colY char(4),
  colZ char(4),
  colAA char(4),
  colAB char(4),
  colAC char(4),
  colAD char(4),
  colAE char(4),
  colAF char(4),
  colAG char(4),
  colAH char(4),
  colAI char(4),
  colAJ char(4),
  colAK char(4),
  colAL char(4),
  colAM char(4),
  colAN char(4),
  colAO char(4),
  colAP char(4),
  colAQ char(4)
)

CREATE TABLE #tmpExcel2
(
  "Source" varchar(10),
  "Decision Score" int,
  "Patient_Name" nvarchar(102),
  "Middle" nvarchar(50),
  DOB date,
  CSIS nvarchar(50),
  StuID nvarchar(50),
  PatID varchar(9),
  BIC nvarchar(19),
  GRADE varchar(20),
  SPED char(5),
  parentConsentMCAL char(7),
  GENDER char(6),
  ACTIVE varchar(5),
  CDS varchar(16),
  cliid varchar(6),
  siteid varchar(6),
  SchName varchar(100),
  addy1 varchar(60),
  addy2 varchar(60),
  city varchar(100),
  zip5 char(6),
  rowID int,
  colX char(4),
  colY char(4),
  colZ char(4),
  colAA char(4),
  colAB char(4),
  colAC char(4),
  colAD char(4),
  colAE char(4),
  colAF char(4),
  colAG char(4),
  colAH char(4),
  colAI char(4),
  colAJ char(4),
  colAK char(4),
  colAL char(4),
  colAM char(4),
  colAN char(4),
  colAO char(4),
  colAP char(4),
  colAQ char(4)
)  -- spaghetti... it's what for dinner!

CREATE TABLE #requiresAttentionFinalOutput  --NOTE: I don't remember why I did a CREATE TABLE, instead of SELECT INTO syntax...
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

/*#####################################################################################################################
  #                                                                                                                   #
  #                                           START OF OUR TRANSACTION                                                #
  #                                                                                                                   #
  #####################################################################################################################*/

UPDATE dbo.[Import_From_A_From_Client_ToSPED_Files]
SET opened_SQL_transaction = SYSDATETIME()
WHERE id = @log_num

BEGIN TRANSACTION
SET @open_trans = 1

/*-------------------------------
 * Pass 6
 * Create a new patient record for every
 * row in the data file where no match candidates
 * were found, and the error flag was not set.
 *------------------------------*/

declare @tempfilepatcorr TABLE (patient_id bigint, file_row_num bigint) --TODO: you know, there's not reason we couldn't have put these columns inside the #parsedpopfile temp table
                                                                        --this isn't a many-to-many relationship, after all
                                                                        
                                                                        --Edit: this second table is unfortunately necessary because of an idiosyncracy in the "OUTPUT"
                                                                        --directive.  OUTPUT can only insert the outputed information into a table; it (apparently) cannot update
                                                                        --existing rows in a table.  I wish we could simply redirect the OUTPUTed info into the correct cells in #ppf,
                                                                        --but we cannot.

declare @batchdate datetime = GETDATE() -- TODO: eventually we want to include the DATE_UPLOADED in the filename, and then parse it in the A rtn

RAISERROR ('Creating base patient records if needed', 0, 1) WITH NOWAIT 

INSERT INTO dbo.PATIENTS_Patient (created_from_ROW_NUM,LAST_NAME,FIRST_NAME,MIDDLE_NAME,DATE_OF_BIRTH, SEX, CSIS, DATE_CREATED, LAST_UPDATED, LASTPOP, ACTIVE, CONCAT_NAME, SUBMIT_CLAIMS, parentConsentMCAL, parentConsentMCALEffectiveDate)
output inserted.PATIENT_ID, inserted.created_from_ROW_NUM AS FILE_ROW_NUM INTO @tempfilepatcorr
SELECT ROW_NUM, lastname_imported, firstname_imported, STUDMI, DOB_imported, GENDER, ImportedCSIS, @batchdate , @batchdate , @batchdate , 'Y', lastname_imported  + ', ' + firstname_imported,  1,
 CAST(parentConsentMCAL AS int), -- since we are inserting a brand-new database record, we don't have to care about comparing against an existing database record
 @batchdate -- ditto
FROM #parsedpopfile ppf
WHERE
    (ppf.isActiveMatch IS NULL OR ppf.isActiveMatch = 0) AND
    (ppf.isInactiveMatch IS NULL OR ppf.isInactiveMatch = 0) AND
    (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0)

RAISERROR ('Update parsed pop file with new patient ids', 0, 1) WITH NOWAIT 

UPDATE #parsedpopfile
SET MatchingPatientID = tfpc.patient_id,
    newRecordSuccess = 1
FROM @tempfilepatcorr tfpc  --TODO: here, we take the real, newly-created PATIENT_ID from the PATIENT_Patient table, temporarily stored in @tempfilepatcorr, and place it
                            --into #parsedpopfile; we could have inserted it directly into #parsedpopfile in the above query, if we wanted to
                            --EDIT: no we can't, due to the limitations of the OUTPUT directive, mentioned above
WHERE tfpc.file_row_num = #parsedpopfile.ROW_NUM

--and then create client and site data

RAISERROR ('Create client and site data', 0, 1) WITH NOWAIT 


INSERT INTO dbo.PATIENTS_Client (CLIENT_ID, PATIENT_ID, START_DATE,END_DATE)
--output inserted.PATIENT_ID as newclients
SELECT clientid, MatchingPatientID, @batchdate, DATEADD(year, 5, getdate())
FROM #parsedpopfile ppf
WHERE ppf.newRecordSuccess = 1

/*-------------------------------
 * Pass 7
 * Update existing patient records
 * and linked data tables, if exactly 1 match
 * was found, and the error flag was not set.
 *------------------------------*/

--new patients have been created, woot woot! Next, update already-existing patients:

-- but first, we flag ppf entries where we cannot overwrite the parent consent value.
-- we must try to find the relevant audit logs, as per Terry.

SELECT CAST(GETDATE() AS VARCHAR) + ' - noting which parent-consent values are to be updated and must be logged' "- TIMESTAMP -";
;with patient_audit_logs_with_most_recent_MCALconsent_value AS (
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

UPDATE #parsedpopfile   /* Action required: we must modify the A routine to ensure that we send out an email announcement to Anton, et al,
                           whenever a Y consent value IS changed TO an N CHANGE TO parental consent flags IS attempted OR made.
        */
  SET --requiresAttention = 1,
      --cannotOverwriteParentalConsentValue = 1,
      notifyInternalOnMCALConsentChange = CASE WHEN m.SBSC_Employee IS NULL THEN 1 ELSE 0 END,
          notifyClientOnMCALConsentChange = CASE WHEN m.SBSC_Employee = 0 THEN 1 ELSE 0 END

   FROM ##allPatientsForThisClient pp

LEFT JOIN                              

pp_earliest_audit_logs_with_most_recent_MCALconsent_value

      pp_log ON pp_log.patRecID = pp.MatchingPatientID --AND pp_log.parentConsentMCAL = pp.parentConsentMCAL

-- we notify only when the last update was NOT made by an SBSC user, or was made by an unknown user      
LEFT JOIN
[users].[dbo].[Users]
      u ON u.userrid = pp_log.userID      
LEFT JOIN
[users].[dbo].[Membership]
      m ON m.UserId = u.UserId

WHERE
 (#parsedpopfile.isActiveMatch = 1 OR #parsedpopfile.isInactiveMatch = 1)
     AND
 (#parsedpopfile.requiresAttention IS NULL OR #parsedpopfile.requiresAttention = 0)
     AND
  #parsedpopfile.MatchingPatientID = pp.MatchingPatientID
     AND
    -- below: we notify only when the consent-value on file is Y and the incoming value is N
  pp.parentConsentMCAL = 1 AND #parsedpopfile.parentConsentMCAL = '0'
    -- below: we notify only when the last update was NOT made by an SBSC user, or was made by an unknown user
     AND
  (m.SBSC_Employee IS NULL OR m.SBSC_Employee = 0) 
    
RAISERROR ('Update pre-existing patient records as needed', 0, 1) WITH NOWAIT 

SELECT CAST(GETDATE() AS VARCHAR) + ' - updating patient recs' "- TIMESTAMP -";
UPDATE dbo.PATIENTS_Patient 
SET LAST_NAME = lastname_imported, 
        FIRST_NAME = firstname_imported,
        CSIS = CASE WHEN ppf.ImportedCSIS = '' THEN PATIENTS_Patient.CSIS ELSE ppf.ImportedCSIS END, -- here, we need only make sure that the incoming CSIS is not empty or blank.
                                    -- the matching-finding queries above make sure that a match is marked invalid if an imported CSIS is different from a CSIS on file.
        MIDDLE_NAME = CASE WHEN MIDDLE_NAME IS NOT NULL AND LEN(MIDDLE_NAME) > LEN (STUDMI) THEN MIDDLE_NAME ELSE STUDMI END, -- if we have the full middle name on file, we don't want to overwrite it
                                                                                                  -- with just the initial 
        DATE_OF_BIRTH = CASE WHEN ppf.DOB_imported = '' THEN PATIENTS_Patient.DATE_OF_BIRTH ELSE ppf.DOB_imported END,
        SEX = CASE ppf.GENDER WHEN 'M' THEN 'M' WHEN 'F' THEN 'F' ELSE PATIENTS_Patient.SEX END, 
        CONCAT_NAME = lastname_imported  + ', ' + firstname_imported, 
        LAST_UPDATED= @batchdate, 
        LASTPOP = @batchdate,
        ACTIVE = 'Y',
        parentConsentMCALEffectiveDate = 
            CASE WHEN (PATIENTS_Patient.parentConsentMCAL IS NULL AND ppf.parentConsentMCAL IS NOT NULL)
            THEN
              @batchdate
            ELSE
              CASE WHEN  (
                 ppf.parentConsentMCAL IS NOT NULL
                      AND
                  CAST(ppf.parentConsentMCAL AS bit) != PATIENTS_Patient.parentConsentMCAL
              )
              THEN @batchdate
              ELSE PATIENTS_Patient.parentConsentMCALEffectiveDate END
        END,
        parentConsentMCAL =
            CASE WHEN (PATIENTS_Patient.parentConsentMCAL IS NULL AND ppf.parentConsentMCAL IS NOT NULL)
            THEN
              CAST(ppf.parentConsentMCAL AS bit)
            ELSE
              CASE WHEN  ( 
                 ppf.parentConsentMCAL IS NOT NULL
                      AND
                  CAST(ppf.parentConsentMCAL AS bit) != PATIENTS_Patient.parentConsentMCAL
              )
              THEN CAST(ppf.parentConsentMCAL AS bit)
              ELSE PATIENTS_Patient.parentConsentMCAL END
        END,
        updated_from_ROW_NUM = ppf.ROW_NUM
FROM #parsedpopfile ppf
WHERE
  ppf.MatchingPatientID = PATIENTS_Patient.PATIENT_ID
     AND
 (ppf.isActiveMatch = 1 OR ppf.isInactiveMatch = 1)
     AND
 (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0)
 
SELECT CAST(GETDATE() AS VARCHAR) + ' - finished updating patient recs; saving audit logs for pat recs created and modified' "- TIMESTAMP -";

RAISERROR ('Creating audit log records', 0, 1) WITH NOWAIT 

--declare @first_row_must_log as int = null
declare @must_log AS TABLE (
    idx bigint identity(1,1)
  , rown  bigint
 UNIQUE CLUSTERED (idx,rown)
)

INSERT INTO @must_log
SELECT ROW_NUM
FROM #parsedpopfile ppf
WHERE
 (ppf.isActiveMatch = 1 OR ppf.isInactiveMatch = 1 OR ppf.newRecordSuccess = 1)
     AND
 (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0)
 
declare @last_row_must_log AS int
SELECT @last_row_must_log = MAX(idx) FROM @must_log
declare @row_must_log_iter AS int  = 1
declare @rowid AS int

declare @ipatRecID AS bigint
declare @isaveType AS int
declare @istate AS int
declare @IGNORE AS bigint = NULL

while (@row_must_log_iter <= @last_row_must_log)
begin
  SELECT top 1 @rowid = rown FROM @must_log WHERE (idx = @row_must_log_iter)

  SELECT
  @ipatRecID=MatchingPatientID,
  @isaveType=CASE WHEN ppf.isInactiveMatch = 1 THEN dbo.CONST_SAVE_TYPE_REACTIVATE() ELSE
    CASE WHEN ppf.newRecordSuccess = 1 THEN dbo.CONST_SAVE_TYPE_NEW() ELSE dbo.CONST_SAVE_TYPE_EDIT() END
  END,
  @istate=CASE WHEN ppf.newRecordSuccess = 1 THEN dbo.CONST_REC_STATE_NEW() ELSE dbo.CONST_REC_STATE_MOD() END
FROM #parsedpopfile ppf
WHERE
 ROW_NUM = @rowid
 
  EXEC dbo.PATIENT_Audit @ipatRecID, @batchdate, 0, @isaveType, @istate, 'automated import via A routine', @IGNORE OUTPUT
 
  SET @row_must_log_iter = @row_must_log_iter + 1
  
end

SELECT CAST(GETDATE() AS VARCHAR) + ' - finished saving audit logs to audit table' "- TIMESTAMP -";
RAISERROR ('create IEP records for the pre-existing patients who do not have them already.', 0, 1) WITH NOWAIT 

INSERT INTO dbo.PATIENTS_IEP (PATIENT_ID, IEP_IFSP_NONE)
SELECT
  ppf.MatchingPatientID,
  '-' -- it is not actually necessary to specify the correct value here, since we immediately follow this up with an UPDATE.
      -- the UPDATE handles all three cases: new-patients, patient-rec-exists-but-IEP-entry-doesn't, and existing-patient-and-IEP-entry.
      -- all in all, we used to have three INSERTs and six UPDATEs in the A routine, for table PATIENTS_IEP; now we have one INSERT and one UPDATE for that table.
FROM #parsedpopfile ppf
LEFT JOIN dbo.PATIENTS_IEP piep ON ppf.MatchingPatientID = piep.PATIENT_ID
WHERE
  piep.PATIENT_ID IS NULL
    AND
 (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0)


--update IEP/IFSP/NONE data
--BEGIN TRY -- this TRY-CATCH is pre-existing.  It is nested inside the 2nd TRY-CATCH, of the big 3.  It is part of the TRANSACTION block

SET @errorstr += ' - Could not UPDATE PATIENTS_IEP with valid information; please make sure that the Special Ed field and DOB field are both valid, for all rows.  File rejected; no changes have been saved.  Contact your IT helpdesk if problems persist'

UPDATE dbo.PATIENTS_IEP
SET IEP_IFSP_NONE =
    CASE WHEN SPED = 'N'
      THEN 'NONE'
      ELSE
        CASE WHEN SPED = 'Y' THEN
          CASE WHEN DATEADD(year, 3, ppf.DOB_imported) > GETDATE()
            THEN 'IFSP' -- if younger than 3
            ELSE 'IEP'  -- if exactly 3 or older.  --the specific edge case where the patient was exactly 3 was previously unhandled, until I noticed it -- JM
          END
        END  -- if SPED != 'Y' and SPED != 'N', then this UPDATE will fail, because the CASE statement doesn't handle it.
             -- we would be putting a NULL in a non-null column.
    END
FROM #parsedpopfile ppf
WHERE ppf.MatchingPatientID = PATIENTS_IEP.PATIENT_ID   
  AND (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0)
--SET @errorstr = ''  

--END TRY

--BEGIN CATCH
  --UPDATE @IsTestRun SET FailedImportMustBeRolledBack =1, errorstr = 'Could not UPDATE PATIENTS_IEP with valid information; please make sure that the Special Ed field and DOB field are both valid, for all rows.  File rejected; no changes have been saved.  Contact your IT helpdesk if problems persist'
--  SET @requires_rollback = 1
--  SET @errorstr = 'Could not UPDATE PATIENTS_IEP with valid information; please make sure that the Special Ed field and DOB field are both valid, for all rows.  File rejected; no changes have been saved.  Contact your IT helpdesk if problems persist'
--  GOTO DEBUG_AND_FINISH
--END CATCH

--locate current site entry for current client and link it in temp table

RAISERROR ('linking site entry to file patient', 0, 1) WITH NOWAIT 

UPDATE #parsedpopfile
SET unique_lookup_code_patient_school_enrollment_info = ps.PATIENT_SCHOOL_ID
FROM dbo.PATIENTS_School ps
INNER JOIN dbo.SITES_Site ss ON ps.SITE_ID = ss.SITE_ID  -- site_id referenced in the P_S table must actually exist
WHERE #parsedpopfile.MatchingPatientID = ps.PATIENT_ID
     AND
 (#parsedpopfile.requiresAttention IS NULL OR #parsedpopfile.requiresAttention = 0) --TODO: maybe the requiresAttention bit should be NOT NULL and default zero ?  Easier to query that way
     AND
  #parsedpopfile.siteid = ps.SITE_ID  -- we only want to UPDATE the P_S entry if the kid is in the same school; otherwise we have to INSERT a new one
     AND
  ss.SITE_CLIENT_ID = #parsedpopfile.clientid  --I'm not super sure this JOIN condition is even necesssary
     AND
  (#parsedpopfile.newStuIDProvided IS NULL OR #parsedpopfile.newStuIDProvided = 0) --otherwise close existing and INSERT a new one

--and flag any that come up with that issue
UPDATE #parsedpopfile
SET
  noSiteFound = 1,
  requiresAttention = CASE WHEN siteid IS NULL THEN 1 ELSE requiresAttention END -- if the siteID could not be determined from the CDS14 in the input file
WHERE
  unique_lookup_code_patient_school_enrollment_info IS NULL
     AND
  MatchingPatientID IS NOT NULL
     AND
 (#parsedpopfile.requiresAttention IS NULL OR #parsedpopfile.requiresAttention = 0)

 IF (SELECT COUNT (*) FROM #parsedpopfile where requiresAttention = 1 AND noSiteFound = 1) > 0
BEGIN
  --SELECT * FROM #parsedpopfile
  -- the previous A routine implementation would fail if even one siteID lookup failed, for even one row.
  -- we will preserve that part of the logic, here.
  SET @requires_rollback = 1
  SET @errorstr += ' - Could not lookup site information for one or more patients.  File rejected; no changes have been saved.'
  -- RAISERROR (@errorStr,   11, 1)
  GOTO DEBUG_AND_FINISH   
END

RAISERROR ('create site link data for new patient records, if any', 0, 1) WITH NOWAIT 

declare @newlyinserted_PS as table (unique_enrollment bigint, patid bigint)
BEGIN TRY
  INSERT INTO dbo.patients_school (SITE_ID, PATIENT_ID, STUDENT_ID, GRADE, "START_DATE", "END_DATE")
    OUTPUT inserted.PATIENT_SCHOOL_ID, inserted.PATIENT_ID INTO @newlyinserted_PS  -- I don't like the OUTPUT syntax... it won't let me OUTPUT INTO a #temptable on the fly
  SELECT siteid, MatchingPatientID, SCHSTUDID, GRADE, @batchdate, DATEADD(year, 5, @batchdate)
  FROM #parsedpopfile ppf
  WHERE (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0) 
     AND (
          ppf.noSiteFound = 1
          OR
          ppf.newStuIDProvided = 1
         )
END TRY
BEGIN CATCH
  --SELECT * FROM #parsedpopfile
  SET @errorstr += ' - Ooops; one or more of the newly-created records does not include a valid site ID.  Will rollback changes' + ERROR_MESSAGE() 
  RAISERROR(@errorstr, 0, 1)
  SET @requires_rollback = 1
  UPDATE #parsedpopfile
  SET newRecordSuccess = 0,
      noSiteFound = 1,
      requiresAttention = 1
  WHERE newRecordSuccess = 1 AND siteid IS NULL
END CATCH


UPDATE #parsedpopfile
SET unique_lookup_code_patient_school_enrollment_info = n.unique_enrollment
FROM @newlyinserted_PS n
WHERE #parsedpopfile.MatchingPatientID = n.patid

RAISERROR ('Updating school enrollment information, as needed', 0, 1) WITH NOWAIT 

--UPDATE our "good" existing enrollment entry
UPDATE dbo.PATIENTS_School
SET --SITE_ID = ppf.siteid,
        GRADE = CASE WHEN ppf.GRADE = '' THEN PATIENTS_School.GRADE ELSE ppf.GRADE END,
        "end_date" = DATEADD(year, 5, @batchdate)--,
        --STUDENT_ID = ppf.SCHSTUDID  -- we NEVER overwrite old StuIDs with new StuIDs; instead we deactivate the row in P_S and create a new one.
FROM #parsedpopfile ppf --inner join dbo.SITES_Site on siteid = SITE_ID
WHERE PATIENTS_School.PATIENT_SCHOOL_ID = unique_lookup_code_patient_school_enrollment_info
     AND
 (ppf.requiresAttention IS NULL OR ppf.requiresAttention = 0)

--close-out our "bad" enrollment entries (if any)

UPDATE dbo.PATIENTS_School
SET "END_DATE" = DATEADD(day, -1, @batchdate)
FROM #parsedpopfile ppf
WHERE dbo.PATIENTS_School.PATIENT_ID = ppf.MatchingPatientID AND
  dbo.PATIENTS_School.PATIENT_SCHOOL_ID != ppf.unique_lookup_code_patient_school_enrollment_info
  AND ("END_DATE" IS NULL OR "END_DATE" > @batchdate)


RAISERROR ('Handling patient places, as needed', 0, 1) WITH NOWAIT 

/* Pass 1: Insert all 'new' (no match to an active address) for both created and updated patients */

INSERT INTO dbo.PATIENT_PLACES (
      CLIENT_ID
    , PATIENT_ID    
    , NAME
    , PATIENT_PLACE_TYPE
    , PLACE_FORMAT_TYPE
    , PLACE_SOURCE_TYPE
    , ADDRESS_1
    , ADDRESS_2
    , CITY
    , STATE
    , ZIP_5
    , ZIP_4
    , LATITUDE
    , LONGITUDE
    , START_DATE
    , CREATED_BY
    , CREATED_ON
    , LAST_MODIFIED_BY
    , LAST_MODIFIED_ON
    , ACTIVE
  )    
SELECT             
      clientID
    , MatchingPatientID
    , 'Primary Home'
    , dbo.CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY()
    , dbo.CONST_PLACE_FORMAT_TYPE_USPS_ADDRESS()
    , dbo.CONST_PLACE_SOURCE_TYPE_STUDENT_DATA()
 
    , STU_ADDR_1     /* Street address 1 */
    , STU_ADDR_2     /* Street address 2 if available */
    , STU_ADDR_CIT          /* City */
    , 'CA'         /* State */
    , STU_ADDR_ZIP5         /* First 5 of zip */
    , NULL         /* Last 4 of zip if available */
 
    , NULL
    , NULL
 
    ,  @batchdate                                       /* Populate using same approach we use for patient sites */
    , 0              /* User id of system*/
    , @batchdate
    , NULL
    , NULL
    , 1 

FROM #parsedpopfile ppf
WHERE
    (requiresAttention IS NULL OR requiresAttention = 0 OR secondaryAddressListed = 1)
    AND
        (
          ppf.STU_ADDR_1 <> ''
          OR ppf.STU_ADDR_2 <> ''
          OR ppf.STU_ADDR_CIT <> ''
          OR ppf.STU_ADDR_ZIP5 <> ''
        ) AND NOT EXISTS (
        SELECT 1 
        FROM dbo.PATIENT_PLACES pp 
        WHERE 
                pp.PATIENT_ID = ppf.MatchingPatientID 
                AND pp.CLIENT_ID = ppf.clientid
                AND pp.PATIENT_PLACE_TYPE = dbo.CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY()
                AND pp.PLACE_SOURCE_TYPE = dbo.CONST_PLACE_SOURCE_TYPE_STUDENT_DATA()
                AND pp.ADDRESS_1 = ppf.STU_ADDR_1
                AND pp.ADDRESS_2 = ppf.STU_ADDR_2
                AND pp.CITY = ppf.STU_ADDR_CIT
                AND pp.ZIP_5 = ppf.STU_ADDR_ZIP5
                AND pp.ACTIVE = 1
        )


UPDATE #parsedpopfile
SET
  requiresAttention = 0
WHERE
  isActiveMatch = 1
  AND
  secondaryAddressListed = 1
  AND
  #parsedpopfile.MatchingPatientID IS NOT NULL
  AND
  (weakMatchesOnlyFromActivePatientRecords IS NULL OR weakMatchesOnlyFromActivePatientRecords = 0)
  AND
  (invalidMatchesOnlyFromActivePatientRecords IS NULL OR invalidMatchesOnlyFromActivePatientRecords = 0)

    --below: we're not doing this any more, as per Terry

/* Pass 2: For the cases where the patient HAD a place or places already:
        a: find the place we added right now (new, and the place the kid had before that (old)
                only patient IDs from this file
        b: make the end date of the old entry = start date of new entry
                
*/

/*
; with updateablePlaces as
(
        select pp.* from #parsedpopfile ppf
        inner join PATIENT_PLACES pp 
                on ppf.MatchingPatientID = pp.PATIENT_ID 
                and pp.PATIENT_PLACE_TYPE = dbo.CONST_PATIENT_PLACE_TYPE_HOME_PRIMARY()
                --and pp.PLACE_SOURCE_TYPE = dbo.CONST_PLACE_SOURCE_TYPE_STUDENT_DATA()
                and pp.ACTIVE = 1
)

update PATIENT_PLACES
set
  END_DATE = q.START_DATE,
  ACTIVE = 0 -- we previously were not setting ACTIVE = 0 for the previous address.  If we are going to set the END_DATE to the current date,

             -- we should also be setting ACTIVE = 0, I think  - JM

from -- TODO: I'm not super confident that a subquery with two CROSS APPLYs in it is the best way to do this - JM
(
select old.ID as oldID, new.START_DATE from #parsedpopfile ppf
cross apply (select top 1 * from updateablePlaces pp1 where ppf.MatchingPatientID = pp1.PATIENT_ID order by pp1.START_DATE desc) new
cross apply (select top 1 * from updateablePlaces pp2 where ppf.MatchingPatientID = pp2.PATIENT_ID and pp2.START_DATE < new.START_DATE order by pp2.START_DATE desc) old
) q
where ID = oldID
*/


		declare @isFull bit
        declare @parChar char 

        SET @parChar = SUBSTRING(@filenamebuffer,1,1)
        SET     @isFull = case @parChar
                        when 'F' then 1
                        else 0
                END

        INSERT INTO dbo.population_files (file_name, client_ID, upload_date, is_full_file)
        SELECT 
                @filenamebuffer,
                (SELECT top 1 clientid FROM #parsedpopfile),
                @batchdate,
                @isFull

        declare @file_ID bigint = scope_identity()

        /* We have a new record.*/
		
		INSERT INTO dbo.population_file_patients (file_id, patient_id)
        SELECT
                @file_ID,
                MatchingPatientID
        FROM #parsedpopfile
        WHERE newRecordSuccess = 1

        /* We have an existing record.*/
		
		INSERT INTO dbo.population_file_patients (file_id, patient_id)
        SELECT
                @file_ID,
                MatchingPatientID
        FROM #parsedpopfile 
        WHERE MatchingPatientID IS NOT NULL AND (newRecordSuccess IS NULL OR newRecordSuccess = 0) 

-- WE'RE DONE!  :)

              -- TODO:
              -- Once we get to the point where we really, really, really trust the information in PATIENTS_Schools,
              -- and we believe that the START_DATE and END_DATE information is correct, and that there are no dup
              -- rows (for active patients)...

              -- I want to consider adding logic HERE that would deactivate all patients for THIS client,
              -- who do not have a current site association.  Patients whose site associations have all passed
              -- their END_DATEs.  Let's deactivate them.

END TRY
BEGIN CATCH
    RAISERROR(@errorStr, 0, 1)
    SELECT CAST(GETDATE() AS VARCHAR) + ' - unknown problem found -' "- TIMESTAMP -";
    SET @errorStr += ' - unknown problem found - ' + ERROR_MESSAGE() + 'line ' + CAST(ERROR_LINE() AS VARCHAR)
    print @errorStr
    SET @requires_rollback = 1
    SET @unknown_problem = 1  -- TODO: we're setting the @unknown_problem flag, here in the A rtn and probs also the B rtn, C rtn... but we're not actually logging it in the log tables.
                              -- PLEAZ FIX
   --GOTO DEBUG_AND_FINISH
END CATCH

/*#####################################################################################################################
  #                                             BLOCK 2 of 4                                                          
  # - Generating results data
  # - Outputing all results data that we write out as text files
  # - Saving any data needed for outputing results data to Excel files because we cannot write to Excel
  #   from withing a transaction block using our current methods
  #
  #  Note: A database transaction MAY be open at this point.  It will be committed or rolled back in block x
  #####################################################################################################################*/

DEBUG_AND_FINISH:

BEGIN TRY

print '__________________________________________________'
print 'NOTE: for very-large data inputs, the ROW_NUMs shown below are probably wrong.'  --TODO: fix this and remove
print 'SQL Server BULK INSERT and OPENROWSET are not intended to read rows from a file in their physical order.'
print 'There must be a ROW_NUM field included in the inputted flat file, itself.  -JM'
print '----------------------------------------------------'

SELECT
  ppf.SPED "SpEd student?",
  /* 'PatientID #' + */ CAST(other_candidates.MatchingPatientID AS VARCHAR) "non-primary match - MERGE & DEACTIVATE",
  other_candidates.patient_active_status "non-primary active?",
  other_candidates.CSIS_on_file,
  /* 'PatientID #' + */ CAST(ppf.MatchingPatientID AS VARCHAR) "primary match - MERGE TO",
  other_candidates.LASTNAME_on_file "Last Name (non-primary match)",
  other_candidates.FIRSTNAME_on_file "First Name (non-primary match)", 
  other_candidates.CSIS_match_found "CSIS matches input?",
  other_candidates.stuid_on_file_matching "StuID matches input?",
  CASE WHEN other_candidates.invalid_match = 1 THEN 'n' ELSE 'y' END "valid?",
  other_candidates.invalid_match,
  ppf.ROW_NUM "Input File Row#",
  --CASE WHEN ppf.requiresAttention = 1 THEN 'n' ELSE 'y' END "Row processing successful?",
  other_candidates.decision_score "matchability score (non-primary)"
INTO #recommendedOptionalMerges
FROM
  #parsedpopfile ppf
RIGHT JOIN ##allCandidatesDetailedInfo other_candidates  
ON
  other_candidates.txtfile_row_num = ppf.ROW_NUM AND other_candidates.MatchingPatientID != ppf.MatchingPatientID
  AND  ( other_candidates.patient_active_status != 'n' AND other_candidates.decision_score > 3 )
WHERE
  requiresAttention = 0

--SELECT * FROM #recommendedOptionalMerges

INSERT INTO #tmpExcel 
SELECT
  'FILE' "Source",
  NULL "Decision Score",
  lastname_imported + ', ' + firstname_imported "Patient Name",
  STUDMI,
  DOB_imported,
  ImportedCSIS,                                                                                 
  SCHSTUDID,
  NULL MatchingPatientID,
  NULL "BIC",
  GRADE,
  SPED,
  parentConsentMCAL,
  GENDER,
  NULL active,
  SCHCDS,
  NULL cliid,
  NULL siteid,
  SCHNAME,
  STU_ADDR_1,  --TODO: we don't need to populate the address into this temp table; we're no longer exporting it to excel
  STU_ADDR_2,
  STU_ADDR_CIT,
  STU_ADDR_ZIP5,
  ROW_NUM,                      
  CASE WHEN requiresAttention IS NULL THEN 'NULL' ELSE CASE WHEN requiresAttention = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  inputGenderInfoFailedValidation IS NULL THEN 'NULL' ELSE CASE WHEN inputGenderInfoFailedValidation = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  isActiveMatch IS NULL THEN 'NULL' ELSE CASE WHEN isActiveMatch = 1 THEN 'Y' ELSE 'N' END END,                                                                                                              
  CASE WHEN  isInactiveMatch IS NULL THEN 'NULL' ELSE CASE WHEN isInactiveMatch = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  multipleActiveMatches IS NULL THEN 'NULL' ELSE CASE WHEN multipleActiveMatches = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  multipleInactiveMatches IS NULL THEN 'NULL' ELSE CASE WHEN multipleInactiveMatches = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rowConflictsWithAnotherRow IS NULL THEN 'NULL' ELSE CASE WHEN rowConflictsWithAnotherRow = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  secondaryAddressListed IS NULL THEN 'NULL' ELSE CASE WHEN secondaryAddressListed = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  uniqueIdentifierNotUniqueInExistingActiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN uniqueIdentifierNotUniqueInExistingActiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  uniqueIdentifierNotUniqueInExistingInactiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN uniqueIdentifierNotUniqueInExistingInactiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  weakMatchesOnlyFromActivePatientRecords IS NULL THEN 'NULL' ELSE CASE WHEN weakMatchesOnlyFromActivePatientRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  invalidMatchesOnlyFromActivePatientRecords IS NULL THEN 'NULL' ELSE CASE WHEN invalidMatchesOnlyFromActivePatientRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  notifyInternalOnMCALConsentChange IS NULL THEN 'NULL' ELSE CASE WHEN notifyInternalOnMCALConsentChange = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  notifyClientOnMCALConsentChange IS NULL THEN 'NULL' ELSE CASE WHEN notifyClientOnMCALConsentChange = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  newRecordSuccess IS NULL THEN 'NULL' ELSE CASE WHEN newRecordSuccess = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  unique_lookup_code_patient_school_enrollment_info IS NULL THEN 'NULL' ELSE CASE WHEN unique_lookup_code_patient_school_enrollment_info = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  newStuIDProvided IS NULL THEN 'NULL' ELSE CASE WHEN newStuIDProvided = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  cannotSaveNewStuID IS NULL THEN 'NULL' ELSE CASE WHEN cannotSaveNewStuID = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  noSiteFound IS NULL THEN 'NULL' ELSE CASE WHEN noSiteFound = 1 THEN 'Y' ELSE 'N' END END,
  null
FROM #parsedpopfile ppf
WHERE requiresAttention = 1
ORDER BY ROW_NUM ASC

;with keepers as (
  SELECT DISTINCT "primary match - MERGE TO" patid, "Input File Row#" ROW_NUM FROM #recommendedOptionalMerges
)
INSERT INTO #tmpExcel2
SELECT
  'KEEPER' "Source",
  null "Decision Score", --cand.decision_score "Decision Score",
  lastname_imported + ', ' + firstname_imported "Patient Name",
  STUDMI,
  DOB_imported,
  ImportedCSIS,                                                                                 
  SCHSTUDID,
  cand.MatchingPatientID,
  pp."BIC",
  GRADE,
  SPED,
  ppf.parentConsentMCAL,
  GENDER,
  pp.active,
  SCHCDS,
  NULL cliid,
  NULL siteid,
  SCHNAME,
  STU_ADDR_1,  --TODO: we don't need to populate the address into this temp table; we're no longer exporting it to excel
  STU_ADDR_2,
  STU_ADDR_CIT,
  STU_ADDR_ZIP5,
  ppf.ROW_NUM,                      
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  null
FROM #parsedpopfile ppf
JOIN keepers ON ppf.MatchingPatientID = keepers.patid AND ppf.ROW_NUM = keepers.ROW_NUM
OUTER APPLY (SELECT top 1 * FROM ##allCandidatesDetailedInfo cand WHERE cand.MatchingPatientID = keepers.patid) cand
JOIN dbo.PATIENTS_Patient pp ON cand.MatchingPatientID = pp.PATIENT_ID
ORDER BY ROW_NUM ASC  -- This is really not the best way to populate patient data into excel; most of these columns won't even be looked at.
                      -- The only reason we're doing this is because we've already defined an excel template and a table type, and it's not worth it to do it all again.

INSERT INTO #requiresAttentionFinalOutput
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
FROM ##candidates_for_matching cand
INNER JOIN #parsedpopfile ppf ON cand.txtfile_row_num = ppf.ROW_NUM AND ppf.requiresAttention = 1  --we're only using the ppf table here for two things: for SpEd marker,
                                                                                                   -- and filtering on requiresAttention
LEFT JOIN ##allPatientsForThisClient pp ON pp.MatchingPatientID = cand.MatchingPatientID

SELECT
  pp.LASTNAME_on_file + ', ' + pp.FIRSTNAME_on_file "Name On File",
  pp.DATE_OF_BIRTH_on_file "DOB",
  pp.CSIS_on_file "CSIS",
  pp.BIC_on_file "BIC",
  cand.[Input File Row#] txtfile_row_num,
  cand.[non-primary active?] patient_active_status,
  cand.[non-primary match - MERGE & DEACTIVATE] MatchingPatientID,
  cand.[matchability score (non-primary)] "decision_score",
  ps.StuID_on_file,
  null weak_match,
  null very_strong_match,
  null CSISNotUniqueInExistingActiveRecords,
  null CSISNotUniqueInExistingInactiveRecords,
  null StuIDNotUniqueInExistingActiveRecords,
  null StuIDNotUniqueInExistingInactiveRecords,
  null last_name_mismatch,
  null first_name_mismatch,
  null lastname_exact_match,
  null firstname_exact_match,
  null FLapprox_DOB_match,
  null CSIS_match_found,
  null StuID_not_matched,
  cand.invalid_match,
  CASE WHEN cand.[StuID matches input?] IS NOT NULL THEN 1 - cand.[StuID matches input?] ELSE NULL END stuid_on_file_conflicting,
  cand.[StuID matches input?] stuid_on_file_matching,
  CASE WHEN cand.[CSIS matches input?] IS NOT NULL THEN 1 - cand.[CSIS matches input?] ELSE NULL END conflicting_CSIS_found,
  pp.parentConsentMCAL
INTO #requiresAttentionFinalOutput2
FROM #recommendedOptionalMerges cand
JOIN ##allPatientsForThisClient pp ON pp.MatchingPatientID = cand."non-primary match - MERGE & DEACTIVATE"
JOIN ##allMatchesPSandPP ps ON ps.MatchingPatientID = pp.MatchingPatientID


INSERT INTO #tmpExcel
SELECT
  'SQL',
  rafo.decision_score,
  rafo."Name On File",
  ppsql.MIDDLE_NAME,
  rafo."DOB",
  rafo."CSIS",
  rafo.StuID_on_file,
  rafo.MatchingPatientID,
  rafo."BIC",
  ps.GRADE,
  piep.IEP_IFSP_NONE,
  CASE WHEN rafo.parentConsentMCAL IS NULL THEN 'unknown' ELSE CASE WHEN rafo.parentConsentMCAL = 0 THEN 'no' ELSE 'yes' END END,
  ppsql.SEX,
  CASE WHEN  rafo.patient_active_status IS NULL THEN 'NULL' ELSE rafo.patient_active_status END active,
  CAST( @clientCDS AS VARCHAR) + CAST( ss.SITE_CDS AS VARCHAR),
  @clientID clliid,
  ss.SITE_ID,
  ss.SITE_NAME,
  NULL, --ppl.ADDRESS_1,    --TODO: we don't need to populate the address into this temp table; we're no longer exporting it to excel.
  NULL, --ppl.ADDRESS_2,    --Ideally these columns would be removed from the definition of the table we are INSERTing to (if applicable)
  NULL, --ppl.CITY,
  NULL, --ppl.ZIP_5,
  rafo.txtfile_row_num,
  CASE WHEN  rafo.weak_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.weak_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.very_strong_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.very_strong_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.invalid_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.invalid_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.stuid_on_file_conflicting IS NULL THEN 'NULL' ELSE CASE WHEN rafo.stuid_on_file_conflicting = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.stuid_on_file_matching IS NULL THEN 'NULL' ELSE CASE WHEN rafo.stuid_on_file_matching = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.conflicting_CSIS_found IS NULL THEN 'NULL' ELSE CASE WHEN rafo.conflicting_CSIS_found = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.CSISNotUniqueInExistingActiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.CSISNotUniqueInExistingActiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.CSISNotUniqueInExistingInactiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.CSISNotUniqueInExistingInactiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.StuIDNotUniqueInExistingActiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.StuIDNotUniqueInExistingActiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.StuIDNotUniqueInExistingInactiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.StuIDNotUniqueInExistingInactiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.last_name_mismatch IS NULL THEN 'NULL' ELSE CASE WHEN rafo.last_name_mismatch = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.first_name_mismatch IS NULL THEN 'NULL' ELSE CASE WHEN rafo.first_name_mismatch = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.lastname_exact_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.lastname_exact_match= 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.firstname_exact_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.firstname_exact_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.FLapprox_DOB_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.FLapprox_DOB_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.CSIS_match_found IS NULL THEN 'NULL' ELSE CASE WHEN rafo.CSIS_match_found = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.StuID_not_matched IS NULL THEN 'NULL' ELSE CASE WHEN rafo.StuID_not_matched = 1 THEN 'Y' ELSE 'N' END END,
  '',
  '',
  null
FROM #requiresAttentionFinalOutput rafo
LEFT JOIN dbo.PATIENTS_IEP piep ON piep.PATIENT_ID = rafo.MatchingPatientID
OUTER APPLY (SELECT GRADE, SITE_ID FROM dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) WHERE PATIENT_ID=rafo.MatchingPatientID )ps
LEFT JOIN dbo.SITES_Site ss ON ps.SITE_ID = ss.SITE_ID
LEFT JOIN dbo.PATIENTS_Patient ppsql ON rafo.MatchingPatientID = ppsql.PATIENT_ID -- here we're LEFT JOINing just to get the middle name and gender;
                                                                            -- we apparently forgot to look that up/store it in a temp table,
                                                                            -- earlier on in the heuristic/process.

INSERT INTO #tmpExcel2
SELECT
  'TO MERGE',
  null decision_score, --rafo.decision_score,
  rafo."Name On File",
  ppsql.MIDDLE_NAME,
  rafo."DOB",
  rafo."CSIS",
  rafo.StuID_on_file,
  rafo.MatchingPatientID,
  rafo."BIC",
  ps.GRADE,
  piep.IEP_IFSP_NONE,
  CASE WHEN rafo.parentConsentMCAL IS NULL THEN 'unknown' ELSE CASE WHEN rafo.parentConsentMCAL = 0 THEN 'no' ELSE 'yes' END END,
  ppsql.SEX,
  CASE WHEN  rafo.patient_active_status IS NULL THEN 'NULL' ELSE rafo.patient_active_status END active,
  CAST( @clientCDS AS VARCHAR) + CAST( ss.SITE_CDS AS VARCHAR), --implicit casting
  @clientID clliid,
  ss.SITE_ID,
  ss.SITE_NAME,
  NULL, --ppl.ADDRESS_1,    --TODO: we don't need to populate the address into this temp table; we're no longer exporting it to excel.
  NULL, --ppl.ADDRESS_2,    --Ideally these columns would be removed from the definition of the table we are INSERTing to (if applicable)
  NULL, --ppl.CITY,
  NULL, --ppl.ZIP_5,
  rafo.txtfile_row_num,
  CASE WHEN  rafo.weak_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.weak_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.very_strong_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.very_strong_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.invalid_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.invalid_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.stuid_on_file_conflicting IS NULL THEN 'NULL' ELSE CASE WHEN rafo.stuid_on_file_conflicting = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.stuid_on_file_matching IS NULL THEN 'NULL' ELSE CASE WHEN rafo.stuid_on_file_matching = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.conflicting_CSIS_found IS NULL THEN 'NULL' ELSE CASE WHEN rafo.conflicting_CSIS_found = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.CSISNotUniqueInExistingActiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.CSISNotUniqueInExistingActiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.CSISNotUniqueInExistingInactiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.CSISNotUniqueInExistingInactiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.StuIDNotUniqueInExistingActiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.StuIDNotUniqueInExistingActiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.StuIDNotUniqueInExistingInactiveRecords IS NULL THEN 'NULL' ELSE CASE WHEN rafo.StuIDNotUniqueInExistingInactiveRecords = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.last_name_mismatch IS NULL THEN 'NULL' ELSE CASE WHEN rafo.last_name_mismatch = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.first_name_mismatch IS NULL THEN 'NULL' ELSE CASE WHEN rafo.first_name_mismatch = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.lastname_exact_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.lastname_exact_match= 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.firstname_exact_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.firstname_exact_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.FLapprox_DOB_match IS NULL THEN 'NULL' ELSE CASE WHEN rafo.FLapprox_DOB_match = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.CSIS_match_found IS NULL THEN 'NULL' ELSE CASE WHEN rafo.CSIS_match_found = 1 THEN 'Y' ELSE 'N' END END,
  CASE WHEN  rafo.StuID_not_matched IS NULL THEN 'NULL' ELSE CASE WHEN rafo.StuID_not_matched = 1 THEN 'Y' ELSE 'N' END END,
  '',
  '',
  null
FROM #requiresAttentionFinalOutput2 rafo
LEFT JOIN dbo.PATIENTS_IEP piep ON piep.PATIENT_ID = rafo.MatchingPatientID
OUTER APPLY (SELECT GRADE, SITE_ID FROM dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) WHERE PATIENT_ID=rafo.MatchingPatientID )ps
LEFT JOIN dbo.SITES_Site ss ON ps.SITE_ID = ss.SITE_ID
LEFT JOIN dbo.PATIENTS_Patient ppsql ON rafo.MatchingPatientID = ppsql.PATIENT_ID


INSERT INTO @tmp2Excel
SELECT tmpxl.* FROM #tmpExcel tmpxl
ORDER BY
  rowID ASC,
  "Source" ASC,
  [Decision Score] DESC

INSERT INTO @tmp2Excel2
SELECT top 50000 tmpxl.* FROM #tmpExcel2 tmpxl
ORDER BY
  rowID ASC,
  "Source" ASC,
  [Decision Score] DESC

--declare @maxexcelrow int
--SELECT @maxexcelrow=COUNT(*) FROM @tmp2Excel
--print @maxexcelrow

 -- I do not like this at all.

   -- SQL Server does not allow you to pass in a filename into OPENROWSET; you have to EXECUTE it as dynamic sql.
   -- The INSERT INTO OPENROWSET cannot be run or EXECUTEd from inside a TRANSACTION block.
   -- Temp table INSERTs are rolled back with a transaction rollback; a table variable must be used
   -- Dynamic SQL is its own scope; cannot (easily) read table variables from outside itself
   -- We cannot pass a table param without first defining a table type
   -- We cannot create a table variable of a user-defined table type; we have to copy-paste the table type definition into the table variable definition

-- ! abbiamo molto spaghetti per mangiare stasera!

                      -- my bad: it turns out you can, in fact, make a table variable from a user-defined table type.  I don't know why I said you couldn't.
                      -- Maybe I meant to say that you cannot make a temp table from a user-defined table type.
                      -- TODO: refactor, eventually?
declare @excelsql nvarchar(2520)= 'INSERT INTO OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;Database=' + @templatefile + ';HDR=NO'',''SELECT * FROM [Sheet1$A3:AP3]'')
SELECT 
    "Source", "Decision Score", "Patient_Name", "Middle", DOB, CSIS, StuID, PatID, BIC,
      GRADE, SPED, parentConsentMCAL, GENDER, active, CDS, cliid, siteid, SchName, addy1, addy2,
        city, zip5, RowID, colX, colY, colZ, colAA, colAB,
          colAC, colAD, colAE, colAF, colAG, colAH, colAI, colAJ, colAK, colAL, colAM, colAN, colAO, colAP
FROM @tmp2Excel ORDER BY id ASC'  -- TODO: I wonder if this would work with SELECT * syntax?

declare @templatefile2 varchar(max) = REPLACE(@templatefile, '.xls', '-OPTIONAL-merges-fixes.xls')

declare @excelsql2 nvarchar(2520)= 'INSERT INTO OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;Database=' + @templatefile2 + ';HDR=NO'',''SELECT * FROM [Sheet1$A3:W3]'')
SELECT 
    "Source", "Decision Score", "Patient_Name", "Middle", DOB, CSIS, StuID, PatID, BIC,
      GRADE, SPED, parentConsentMCAL, GENDER, active, CDS, cliid, siteid, SchName, addy1, addy2,
        city, zip5, RowID
FROM @tmp2Excel ORDER BY id ASC'  -- TODO: I wonder if this would work with SELECT * syntax?

--print @excelsql
--EXECUTE (@excelsql)

print '- analysis'
                                        /* calc grand totals */
                                        /* these are printed out at the end */
                                        declare @countProblematicRecords VARCHAR(9);
                                        SELECT @countProblematicRecords=CAST(COUNT(DISTINCT MatchingPatientID) AS VARCHAR)
                                        FROM #requiresAttentionFinalOutput rafo

                                        declare @countFileRowsRequiringAttention VARCHAR(9);
                                        SELECT @countFileRowsRequiringAttention=CAST(COUNT(ppf.ROW_NUM) AS VARCHAR)
                                        FROM #parsedpopfile ppf
                                        WHERE
                                         requiresAttention = 1
                                         
                                        declare @countRecordsUpdated VARCHAR(9);
                                        SELECT @countRecordsUpdated=CAST(COUNT(ppf.ROW_NUM) AS VARCHAR)
                                        FROM #parsedpopfile ppf
                                        WHERE
                                        (
                                          isActiveMatch = 1
                                                  OR
                                          isInactiveMatch = 1 ) AND
                                                                           ( requiresAttention IS NULL OR requiresAttention = 0 ) 
                                                                                                  AND
                                                                                  ( newRecordSuccess IS NULL OR newRecordSuccess = 0 )
                                                              
                                        
										if ( @countRecordsUpdated = 0 AND @@TRANCOUNT != 0 )
										BEGIN
											RAISERROR('Ooops - no updates',0,1)
											SET @requires_rollback = 1
											SET @unknown_problem = 1
									    END
										
										declare @countRecordsCreated VARCHAR(9);
                                        SELECT @countRecordsCreated=CAST(COUNT(ppf.ROW_NUM) AS VARCHAR)
                                        FROM #parsedpopfile ppf
                                        WHERE newRecordSuccess = 1

                                        declare @countFileRowsRead VARCHAR(9);
                                        SELECT @countFileRowsRead=CAST(COUNT(ppf.ROW_NUM) AS VARCHAR)
                                        FROM #parsedpopfile ppf
                                        /* subtotals for active, inactive */
                                        declare @countRaRecWeakI int;
                                        SELECT @countRaRecWeakI=COUNT(DISTINCT rafo.MatchingPatientID)
                                        FROM #requiresAttentionFinalOutput rafo
                                        WHERE weak_match = 1
                                                AND (patient_active_status IS NULL OR patient_active_status = 'N')

                                        declare @countRaRecWeakA int;
                                        SELECT @countRaRecWeakA=COUNT(DISTINCT rafo.MatchingPatientID)
                                        FROM #requiresAttentionFinalOutput rafo
                                        WHERE weak_match = 1
                                                AND patient_active_status != 'N'

                                        declare @countRaRecInvI int;
                                        SELECT @countRaRecInvI=COUNT(DISTINCT rafo.MatchingPatientID)
                                        FROM #requiresAttentionFinalOutput rafo
                                        WHERE invalid_match = 1 AND weak_match = 0
                                                AND (patient_active_status IS NULL OR patient_active_status = 'N')

                                        declare @countRaRecInvA int;
                                        SELECT @countRaRecInvA=COUNT(DISTINCT rafo.MatchingPatientID)
                                        FROM #requiresAttentionFinalOutput rafo
                                        WHERE invalid_match = 1 AND weak_match = 0
                                                AND patient_active_status != 'N'
                                            
                                        declare @countRaRecDupI int;
                                        SELECT @countRaRecDupI=COUNT(DISTINCT rafo.MatchingPatientID)
                                          FROM #requiresAttentionFinalOutput rafo
                                          INNER JOIN #parsedpopfile ppf ON ppf.ROW_NUM = rafo.txtfile_row_num
                                                AND (ppf.multipleActiveMatches = 1 OR ppf.multipleInactiveMatches = 1)
                                                  AND (patient_active_status IS NULL OR patient_active_status = 'N')
                                            
                                        declare @countRaRecDupA int;
                                        SELECT @countRaRecDupA=COUNT(DISTINCT rafo.MatchingPatientID)
                                          FROM #requiresAttentionFinalOutput rafo
                                          INNER JOIN #parsedpopfile ppf ON ppf.ROW_NUM = rafo.txtfile_row_num
                                                AND (ppf.multipleActiveMatches = 1 OR ppf.multipleInactiveMatches = 1)
                                                  AND patient_active_status != 'N'

                                        declare @countRaRowDupI int;
                                        SELECT @countRaRowDupI=COUNT(DISTINCT ppf.ROW_NUM)
                                          FROM #requiresAttentionFinalOutput rafo
                                          INNER JOIN #parsedpopfile ppf ON ppf.ROW_NUM = rafo.txtfile_row_num
                                                AND (ppf.multipleActiveMatches = 1 OR ppf.multipleInactiveMatches = 1)
                                                  AND (patient_active_status IS NULL OR patient_active_status = 'N')

                                        declare @countRaRowDupA int;
                                        SELECT @countRaRowDupA=COUNT(DISTINCT ppf.ROW_NUM)
                                          FROM #requiresAttentionFinalOutput rafo
                                          INNER JOIN #parsedpopfile ppf ON ppf.ROW_NUM = rafo.txtfile_row_num
                                                AND (ppf.multipleActiveMatches = 1 OR ppf.multipleInactiveMatches = 1)
                                                  AND patient_active_status != 'N'

                                        declare @countRaRowDupTot int;
                                        SELECT @countRaRowDupTot=COUNT(DISTINCT ppf.ROW_NUM)
                                          FROM #parsedpopfile ppf
                                          WHERE (ppf.multipleActiveMatches = 1 OR ppf.multipleInactiveMatches = 1)
                                                  
print 'totals & statistics - successful:'

SELECT
  CAST(COUNT(*) AS VARCHAR) + ' patient records created' "record counts - SUCCESSFULLY CREATED",
  SPED "special needs?"
FROM #parsedpopfile ppf
WHERE newRecordSuccess = 1 AND
                   ( requiresAttention IS NULL OR requiresAttention = 0 )
GROUP BY SPED
ORDER BY SPED DESC /* Y then N */
print @countRecordsCreated +' - TOTAL'
print '------------------'

SELECT
  CAST(COUNT(*) AS VARCHAR) + ' records updated' "record counts - SUCCESSFULLY UPDATED",
  CASE WHEN isActiveMatch IS NULL OR isActiveMatch = 0 THEN ' - from matching inactive patient records found, reactivated' ELSE ' - from matching active patient records found ' END "active/inactive ?",
  SPED "special needs?"
FROM #parsedpopfile ppf
WHERE (
  isActiveMatch = 1
      OR
  isInactiveMatch = 1 ) AND
                   ( requiresAttention IS NULL OR requiresAttention = 0 ) 
                              AND
                      ( newRecordSuccess IS NULL OR newRecordSuccess = 0 )  
GROUP BY isActiveMatch, SPED
ORDER BY isActiveMatch DESC /* 1 then 0 */, SPED DESC /* Y then N */
print @countRecordsUpdated +' - TOTAL'
print '------------------'

print 'totals & statistics - ' + @countProblematicRecords + ' records requiring attention:'
print 'weakly-matched patient records'
SELECT
  CAST(COUNT(DISTINCT rafo.MatchingPatientID) AS VARCHAR) + ' weak matches' "# of patient records REQUIRING ATTENTION",
  CASE WHEN patient_active_status IS NULL OR patient_active_status = 'N' THEN ' - from patient recs currently inactive' ELSE ' - from patient recs currently active' END "active/inactive ?",
  SPED "special needs?",
  'PatientID #' + CAST(MIN(rafo.MatchingPatientID) AS VARCHAR) "Example #1",
  'PatientID #' + CAST(MAX(rafo.MatchingPatientID) AS VARCHAR) "Example #2"
FROM #requiresAttentionFinalOutput rafo
WHERE weak_match = 1
GROUP BY patient_active_status, SPED
ORDER BY patient_active_status DESC /* Y then N */, SPED DESC /* Y then N */
print CAST(@countRaRecWeakI + @countRaRecWeakA AS VARCHAR) + ' - TOTAL (' + CAST(@countRaRecWeakA AS VARCHAR) + ' active, ' + + CAST(@countRaRecWeakI AS VARCHAR) + ' inactive)'
print '----------'
print ' - NOTE: Inactive patient records that are flagged as "weak" match candidates do not affect the match-finding heuristic, in any way.'
print '   Their presence does not prevent the script from creating a brand-new patient record.'
print '   They are flagged for informational purposes only.  The corresponding rows in the input file were not handled, for some other reason.'
print '----------'

print 'possible matches with unexpected data conflicts - "idiot check"d and flagged for mismatch on vital data fields'
SELECT
  CAST(COUNT(DISTINCT rafo.MatchingPatientID) AS VARCHAR) + ' invalid matches' "# of patient records REQUIRING ATTENTION",
  CASE WHEN patient_active_status IS NULL OR patient_active_status = 'N' THEN ' - from patient recs currently inactive' ELSE ' - from patient recs currently active' END "active/inactive ?",
  SPED "special needs?",
  CASE WHEN very_strong_match = 1 THEN ' - very strong' ELSE ' - strong-ish' END + ' matches' "probability",
  'PatientID #' + CAST(MIN(rafo.MatchingPatientID) AS VARCHAR) "Example #1",
  'PatientID #' + CAST(MAX(rafo.MatchingPatientID) AS VARCHAR) "Example #2"  
FROM #requiresAttentionFinalOutput rafo
WHERE invalid_match = 1 AND weak_match = 0
GROUP BY patient_active_status, SPED, very_strong_match
ORDER BY very_strong_match DESC/* 1 then 0 */, patient_active_status DESC /* Y then N */, SPED DESC /* Y then N */
print CAST(@countRaRecInvI + @countRaRecInvA AS VARCHAR) + ' - TOTAL (' + CAST(@countRaRecInvA AS VARCHAR) + ' active, ' + + CAST(@countRaRecInvI AS VARCHAR) + ' inactive)'
print '----------'
print ' - NOTE: Inactive patient records that are flagged as "invalid" match candidates do not affect the match-finding heuristic, in any way.'
print '   Their presence does not prevent the script from creating a brand-new patient record.'
print '   They are flagged for informational purposes only.  The corresponding rows in the input file were not handled, for some other reason.'
print '----------'

print 'competing/conflicting patient records on-file, possibly referring to the same natural person - UNPROCESSED IN THIS BATCH'

SELECT
  CAST(COUNT(DISTINCT rafo.MatchingPatientID) AS VARCHAR) + ' competing/conflicting matches' "# of patient records REQUIRING ATTENTION",
  CASE WHEN rafo.patient_active_status IS NULL OR rafo.patient_active_status = 'N' THEN ' - from patient recs currently inactive' ELSE ' - from patient recs currently active' END "active/inactive ?",
  ppf.SPED "special needs? (input file)",
  piep.IEP_IFSP_NONE "special needs? (from patient record)",
  CASE WHEN rafo.very_strong_match = 1 THEN ' - very strong' ELSE ' - strong-ish' END + ' matches' "probability",
  'PatientID #' + CAST(MIN(rafo.MatchingPatientID) AS VARCHAR) "Example #1",
  'PatientID #' + CAST(MAX(rafo.MatchingPatientID) AS VARCHAR) "Example #2"   
FROM
  #requiresAttentionFinalOutput rafo
  INNER JOIN #parsedpopfile ppf ON ppf.ROW_NUM = rafo.txtfile_row_num
    AND (ppf.multipleActiveMatches = 1 OR ppf.multipleInactiveMatches = 1)
  LEFT JOIN PATIENTS_IEP piep ON rafo.MatchingPatientID = piep.PATIENT_ID
GROUP BY patient_active_status, ppf.SPED, IEP_IFSP_NONE, very_strong_match
ORDER BY  very_strong_match /* 1 then 0 */ DESC, patient_active_status DESC /* Y then N */, ppf.SPED DESC /* Y then N */
print CAST(@countRaRecDupI + @countRaRecDupA AS VARCHAR) + ' - TOTAL (' + CAST(@countRaRecDupA AS VARCHAR) + ' active, ' + + CAST(@countRaRecDupI AS VARCHAR) + ' inactive)'
print ' - NOTE: These COUNTs from this table may be wrong, if any of these match candidates have more than one entry in the PATIENTS_IEP table.'
print ' - In theory, it is a 1-to-1 table relationship; the LEFT JOIN that populates the report above should not affect the COUNTs.'
print ' - However, there are multiple entries in the PATIENTS_IEP table for many PATIENT_IDs; this is a data integrity problem.'
print '------------------'
print 'SPED/non-SPED breakdown of students, natural persons affected by competing/conflicting records - UNPROCESSED IN THIS BATCH'
SELECT
  CAST( COUNT( DISTINCT ppf.ROW_NUM) AS VARCHAR ) + ' persons, listed in pop file, unprocessed' "# of affected students",
  ppf.SPED
FROM #parsedpopfile ppf
WHERE
        (multipleActiveMatches = 1 OR multipleInactiveMatches = 1)
GROUP BY ppf.SPED
print CAST(@countRaRowDupTot AS VARCHAR) + ' - TOTAL (' + CAST(@countRaRowDupA AS VARCHAR) + ' w/ active match candidates, ' + + CAST(@countRaRowDupI AS VARCHAR) + ' w/ inactive match candidates)'
print ' - NOTE: For this category, calculated totals may exceed count of result set - due to Venn overlap'
print '------------------'
print '- total of unhandled input rows, numerical breakdown, by reason'
SELECT
  CAST( COUNT( DISTINCT ppf.ROW_NUM) AS VARCHAR ) + ' rows' "# of affected rows",
  multipleActiveMatches,
  multipleInactiveMatches,
  rowConflictsWithAnotherRow,
  secondaryAddressListed,
  uniqueIdentifierNotUniqueInExistingActiveRecords,
  uniqueIdentifierNotUniqueInExistingInactiveRecords,
  weakMatchesOnlyFromActivePatientRecords,
  invalidMatchesOnlyFromActivePatientRecords,
  inputGenderInfoFailedValidation,
  --cannotOverwriteParentalConsentValue,
  noSiteFound,
  requiresAttention,
  'Row #' + CAST(MIN(ppf.ROW_NUM) AS VARCHAR) "Example #1",
  'Row #' + CAST(MAX(ppf.ROW_NUM) AS VARCHAR) "Example #2" 
FROM #parsedpopfile ppf
WHERE
        (requiresAttention = 1)
            OR
                (MatchingPatientID IS NULL)
                    OR
                    (
                        (isActiveMatch IS NULL OR isActiveMatch = 0)
                            AND
                        (isInactiveMatch IS NULL OR isInactiveMatch = 0)
                            AND
                        (newRecordSuccess IS NULL OR newRecordSuccess = 0)
                    )
              
GROUP BY
  multipleActiveMatches,
  multipleInactiveMatches,
  rowConflictsWithAnotherRow,
  secondaryAddressListed,
  uniqueIdentifierNotUniqueInExistingActiveRecords,
  uniqueIdentifierNotUniqueInExistingInactiveRecords,
  weakMatchesOnlyFromActivePatientRecords,
  invalidMatchesOnlyFromActivePatientRecords,
  inputGenderInfoFailedValidation,
  --cannotOverwriteParentalConsentValue,
  noSiteFound,
  requiresAttention
print '------------------'
print '- summary'
print 'grand totals:'
SELECT @countFileRowsRead + ' rows read from file import' "Batch Size"

SELECT @countRecordsCreated + ' patient data records created from this file' "Records Created"

SELECT @countRecordsUpdated + ' patient data records updated from this file' "Records Updated"
                      
SELECT @countFileRowsRequiringAttention + ' rows from input file requiring attention' "Rows Requiring Attention"

SELECT @countProblematicRecords + ' confusing & problematic records in existing data - determined as possible matches for the unhandled file rows, counted above' "Existing Patient Records Requiring Attention"

print '------------------'


print '- recommended action'

SELECT * FROM #recommendedOptionalMerges
ORDER BY
  "SpEd student?" DESC,
  "primary match - MERGE TO" ASC,
  "matchability score (non-primary)" DESC,
  "valid?" ASC,
  "non-primary active?" DESC,
  "Last Name (non-primary match)" ASC,
  "First Name (non-primary match)" ASC,
  "non-primary match - MERGE & DEACTIVATE" ASC


declare @output_str VARCHAR(MAX) = ''
declare @exportable_rows AS TABLE (
idx bigint identity(1,1)
, row_str  varchar(400)
UNIQUE CLUSTERED (idx,row_str)
)

declare @exp_iter int = 1;
declare @exp_max int;
declare @problem_file_export_filename varchar(max)

if (SELECT COUNT(ROW_NUM) FROM #parsedpopfile WHERE requiresAttention = 1) > 0
BEGIN
  INSERT INTO @exportable_rows
  SELECT pft.row
  FROM #numberedpopfiletable pft
  INNER JOIN #parsedpopfile ppf
    ON ppf.requiresAttention = 1 AND pft.ROW_NUM = ppf.ROW_NUM

  SELECT @exp_max=MAX(idx) FROM @exportable_rows
  
  while (@exp_iter <= @exp_max)
  BEGIN
    SELECT @output_str=@output_str + row_str + CHAR(13) + CHAR(10) FROM @exportable_rows WHERE idx=@exp_iter    
    SET @exp_iter = @exp_iter + 1
  END
  
  SET @problem_file_export_filename = @filenamebuffer + '-problem-rows-TESTONLY.txt'
   
  exec WriteStringToFile @output_str, @destfolder, @problem_file_export_filename
  DELETE FROM @exportable_rows
END

if (SELECT COUNT(ROW_NUM) FROM #parsedpopfile WHERE notifyInternalOnMCALConsentChange = 1) > 0
BEGIN
  INSERT INTO @exportable_rows
  SELECT
    CAST(ppf.MatchingPatientID AS VARCHAR)  + ',' + CHAR(9) +
    ppf.lastname_imported  + ',' + CHAR(9) +
    ppf.firstname_imported + ',' + CHAR(9) +
    ppf.ImportedCSIS
  FROM #parsedpopfile ppf
    WHERE ppf.notifyInternalOnMCALConsentChange = 1 --AND pft.ROW_NUM = ppf.ROW_NUM

  SET @output_str=''
  SELECT @exp_max=MAX(idx) FROM @exportable_rows
  SELECT @exp_iter=MIN(idx) FROM @exportable_rows
  
  while (@exp_iter <= @exp_max)
  BEGIN
    SELECT @output_str=@output_str + row_str + CHAR(13) + CHAR(10) FROM @exportable_rows WHERE idx=@exp_iter    
    SET @exp_iter = @exp_iter + 1
  END
  
  SET @problem_file_export_filename = @filenamebuffer + ' - MCAL consent change - NOTIFYINTERNAL.txt'
   
  exec WriteStringToFile @output_str, @destfolder, @problem_file_export_filename
  DELETE FROM @exportable_rows
END

if (SELECT COUNT(ROW_NUM) FROM #parsedpopfile WHERE notifyClientOnMCALConsentChange = 1) > 0
BEGIN
  INSERT INTO @exportable_rows
  SELECT
    CAST(ppf.MatchingPatientID AS VARCHAR)  + ',' + CHAR(9) +
    ppf.lastname_imported  + ',' + CHAR(9) +
    ppf.firstname_imported + ',' + CHAR(9) +
    ppf.ImportedCSIS
  FROM #parsedpopfile ppf
    WHERE ppf.notifyClientOnMCALConsentChange = 1 --AND pft.ROW_NUM = ppf.ROW_NUM

  SET @output_str=''
  SELECT @exp_max=MAX(idx) FROM @exportable_rows
  SELECT @exp_iter=MIN(idx) FROM @exportable_rows
  
  while (@exp_iter <= @exp_max)
  BEGIN
    SELECT @output_str=@output_str + row_str + CHAR(13) + CHAR(10) FROM @exportable_rows WHERE idx=@exp_iter    
    SET @exp_iter = @exp_iter + 1
  END
  
  SET @problem_file_export_filename = @filenamebuffer + ' - MCAL consent change - NOTIFYCLIENT.txt'
   
  exec WriteStringToFile @output_str, @destfolder, @problem_file_export_filename
  DELETE FROM @exportable_rows

END

if (SELECT COUNT(ROW_NUM) FROM #parsedpopfile WHERE requiresAttention = 1) > 0
  SET @requires_rollback = 1
else if (@requires_rollback = 0) 

INSERT INTO [dbo].[Import_From_A_From_Client_ToSPED_File_rows] (
   [FROM_CLIENT_log_entry] 
  ,[ROW_NUM]
  ,[Last_Name]
  ,[First_Name]
  ,[MI]
  ,[Student_ID]
  ,[Grade]
  ,[CSIS_SSID]
  ,[County_CDS2]
  ,[District_CDS5]
  ,[School_Site_CDS7]
  ,[School_Site_Name]
  ,[DistID]
  ,[Address1]
  ,[Address2]
  ,[City]
  ,[Zip5]
  ,[DOB]
  ,[Sex]
  ,[SpEd_Marker]
  ,[ParentalConsentMCAL]
)


    SELECT
      @log_num,
      ROW_NUM,
      lastname_imported,
      firstname_imported,
      STUDMI,
      SCHSTUDID,
      GRADE,
      ImportedCSIS,
      SUBSTRING(SCHCDS,1,2),
      SUBSTRING(SCHCDS,3,5),
      SUBSTRING(SCHCDS,8,7),
      SCHNAME,
      SCHDISTID,
      STU_ADDR_1,
      STU_ADDR_2,
      STU_ADDR_CIT,
      STU_ADDR_ZIP5,
      CONVERT(char, DOB_imported, 112),
      GENDER,
      SPED,
      parentConsentMCAL
    FROM #parsedpopfile

END TRY
BEGIN CATCH
  SET @requires_rollback = 1
  SET @unknown_problem = 1
  RAISERROR('Ooops; unknown problem with reporting out', 0, 1)
  print ERROR_MESSAGE()
  print 'line ' + CAST(ERROR_LINE() AS VARCHAR)
  SELECT CAST(GETDATE() AS VARCHAR) + ' - unknown problem with reporting out -' "- TIMESTAMP -";
END CATCH

/*#####################################################################################################################
  # Drop all of our temp tables we no longer need at this point
  #####################################################################################################################*/

CLEANUP_AND_EXIT:

DROP TABLE if exists ##allMatchesPSandPP
DROP TABLE if exists #possibleMatchesUnfiltered
DROP TABLE if exists ##allCandidatesDetailedInfo
DROP TABLE if exists ##allPatientsForThisClient
DROP TABLE if exists #filevalidationerrors
DROP TABLE if exists ##candidates_for_matching
DROP TABLE if exists ##final_matches_active_and_inactive
DROP TABLE if exists #popfiletable
DROP TABLE if exists #numberedpopfiletable
DROP TABLE if exists #csisCounts
DROP TABLE if exists #stuidCounts
DROP TABLE if exists #requiresAttentionFinalOutput
DROP TABLE if exists #tmpExcel
DROP TABLE if exists #requiresAttentionFinalOutput2
DROP TABLE if exists #tmpExcel2
DROP TABLE if exists #parsedpopfile
DROP TABLE if exists #recommendedOptionalMerges

/*#####################################################################################################################
  #                                             BLOCK 3 of 4                                                          
  #
  # - Commit or rollback transactions if they are open
  #####################################################################################################################*/

BEGIN TRY
if (@@TRANCOUNT > 0) 
begin
  if (@open_trans = 1 AND @requires_rollback = 0) 
  begin
    SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - committing transaction' "- TIMESTAMP -";
    commit transaction
    UPDATE dbo.[Import_From_A_From_Client_ToSPED_Files]
      SET
      last_pop = @batchdate,
      closed_SQL_transaction = SYSDATETIME(),
      committed_transaction = 1,
      records_created = @countRecordsCreated,
      records_updated = @countRecordsUpdated,
      SQL_records_requiring_attention = @countProblematicRecords,
      input_rows_requiring_attention = @countFileRowsRequiringAttention
      WHERE id = @log_num
  end
  else
  begin 
    SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - rolling back transaction' "- TIMESTAMP -";
	  rollback transaction
    UPDATE dbo.[Import_From_A_From_Client_ToSPED_Files]
      SET
      last_pop = @batchdate,
      closed_SQL_transaction = SYSDATETIME(),
      committed_transaction = 0,
      records_created = @countRecordsCreated,
      records_updated = @countRecordsUpdated,
      SQL_records_requiring_attention = @countProblematicRecords,
      input_rows_requiring_attention = @countFileRowsRequiringAttention,
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
    UPDATE dbo.[Import_From_A_From_Client_ToSPED_Files]
    SET last_pop = @batchdate,
      closed_SQL_transaction = SYSDATETIME(),
      committed_transaction = 0,
      --records_created = @countRecordsCreated,
      --records_updated = @countRecordsUpdated,
      --SQL_records_requiring_attention = @countProblematicRecords,
      --input_rows_requiring_attention = @countFileRowsRequiringAttention,
      error_str = @errorstr
    WHERE id = @log_num
  end
END CATCH				        

/*#####################################################################################################################
  #                                             BLOCK 4 of 4                                                          #
  # NOTE: The open row set insert does not seem to like being inside a transaction.  Therefore we are doing it here.  #
  #####################################################################################################################*/

BEGIN TRY
  if (@requires_rollback = 1) -- The excel report will be populated only if the A routine did not process
	  EXEC sp_executesql @excelsql, N'@tmp2Excel PatientDataImportExceptions READONLY', @tmp2Excel=@tmp2Excel

  EXEC sp_executesql @excelsql2, N'@tmp2Excel PatientDataImportExceptions READONLY', @tmp2Excel=@tmp2Excel2

END TRY
BEGIN CATCH
  RAISERROR('Ooops; excel problem', 0, 1)
  SET @errorstr += ' - Ooops; excel problem - ' + ERROR_MESSAGE() + 'line ' + CAST(ERROR_LINE() AS VARCHAR)
  print @errorstr
  UPDATE dbo.[Import_From_A_From_Client_ToSPED_Files]
    SET error_str = ISNULL(error_str,'') + @errorstr
    WHERE id = @log_num
END CATCH

/*#####################################################################################################################
  #                        Done.  Report back to caller if there was a problem.
  #####################################################################################################################*/

UPDATE dbo.[Import_From_A_From_Client_ToSPED_Files]
SET done_processing = SYSDATETIME()
WHERE id = @log_num

SELECT format(getdate(), 'ddd, MMM dd yyyy, HH:mm:ss.ffff') + ' - we''re done here ' "- TIMESTAMP -";
if (@requires_rollback = 1)
BEGIN
  print 'Stopped.  No changes saved.'
  if (@unknown_problem = 1) BEGIN
    print @errorstr
    RAISERROR(@errorstr,21,1) WITH LOG;
    RETURN 1
  END -- else:
    return 53003
END
RETURN 0

END
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON TYPE::PatientDataImportExceptions TO [webuser]
GO

--GRANT EXECUTE ON  [dbo].[FROM_CLIENT] TO [webuser]
--GO