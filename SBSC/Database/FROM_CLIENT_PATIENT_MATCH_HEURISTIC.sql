
USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FROM_CLIENT_PATIENT_MATCH_HEURISTIC') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.FROM_CLIENT_PATIENT_MATCH_HEURISTIC
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/

--CREATE PROCEDURE [dbo].[SPAGHETTI_PATIENT_MATCH] ( 
CREATE PROCEDURE [dbo].[FROM_CLIENT_PATIENT_MATCH_HEURISTIC] (
  @clientID bigint
  )

  /* This tragic SPROC is being un-ironically labelled SPAGHETTI_PATIENT_MATCH because it depends upon a temp-table that is defined and populated inside of another SPROC.
     It also creates and populates a number of global temp tables that need to be accessible in other SPROCS.

     SQL Server does not allow a SPROC to have read-write access to a table parameter, or even to have a table parameter that functions as an OUT parameter... So here we are. */

AS    
BEGIN

SELECT CAST(GETDATE() AS VARCHAR) + ' - file sanity checking complete - STARTING search' "- TIMESTAMP -";
RAISERROR ('Counting possible matches', 0, 1) WITH NOWAIT 


DROP TABLE if exists ##allMatchesPSandPP
DROP TABLE if exists ##allPatientsForThisClient
DROP TABLE if exists ##candidates_for_matching
DROP TABLE if exists ##final_matches_active_and_inactive

CREATE TABLE ##allMatchesPSandPP
(
  ROW_NUM int,
  MatchingPatientID bigint,
  StuID_on_file NVARCHAR(50),
  stuid_on_file_matching bit,
  stuid_on_file_conflicting bit,
);

-- Create a non-unique clustered index
CREATE CLUSTERED INDEX x_rown_and_patid
ON ##allMatchesPSandPP (ROW_NUM,MatchingPatientID);

CREATE TABLE ##allPatientsForThisClient
(
  MatchingPatientID bigint,
  CSIS_on_file NVARCHAR(50),
  BIC_on_file NVARCHAR(18),
  LASTNAME_on_file NVARCHAR(50),
  FIRSTNAME_on_file NVARCHAR(50),
  DATE_OF_BIRTH_on_file date,
  parentConsentMCAL bit,
  patient_active_status char,
  
  UNIQUE clustered (MatchingPatientID)
);
CREATE UNIQUE nonclustered INDEX csis_patid ON ##allPatientsForThisClient (CSIS_on_file,MatchingPatientID)

CREATE UNIQUE nonclustered INDEX dob_lname_fname ON ##allPatientsForThisClient (DATE_OF_BIRTH_on_file,LASTNAME_on_file,FIRSTNAME_on_file,MatchingPatientID)

CREATE TABLE ##candidates_for_matching
(
  txtfile_row_num bigint,
  patient_active_status char,
  MatchingPatientID bigint,
  StuID_on_file nvarchar(50),
  weak_match int,
  very_strong_match bit,
  invalid_match int,
  stuid_on_file_conflicting smallint, --regretably SQL server does not allow us to perform a MIN() or MAX() on a bit field
  stuid_on_file_matching bit,
  conflicting_CSIS_found bit,
  no_stuid_on_file bit,
  CSISNotUniqueInExistingActiveRecords smallint,
  CSISNotUniqueInExistingInactiveRecords bit,
  StuIDNotUniqueInExistingActiveRecords bit,
  StuIDNotUniqueInExistingInactiveRecords bit,
  last_name_mismatch bit,
  first_name_mismatch bit,
  lastname_exact_match bit,
  firstname_exact_match bit,
  FLapprox_DOB_match bit,
  CSIS_match_found smallint,
  StuID_not_matched bit,
  PossibleMatchOrMatchesFound int,
  decision_score int,
);
-- Create a non-unique clustered index
CREATE CLUSTERED INDEX cand_indx
ON ##candidates_for_matching (invalid_match, weak_match, txtfile_row_num, decision_score, patient_active_status, MatchingPatientID);

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 1 of 10                        #
  #                                                                           #
  #############################################################################*/


RAISERROR ('Loading all existing patients for clientID', 0, 1) WITH NOWAIT 

INSERT INTO ##allPatientsForThisClient 
  SELECT 
    pc.PATIENT_ID MatchingPatientID, --we join on this column in the next query, hence, "matching"
    pp.CSIS CSIS_on_file,
        pp.BIC,
    pp.LAST_NAME LASTNAME_on_file,
    pp.FIRST_NAME FIRSTNAME_on_file,
    pp.DATE_OF_BIRTH DATE_OF_BIRTH_on_file,
    pp.parentConsentMCAL,
    pp.ACTIVE patient_active_status
        FROM dbo.PATIENTS_Client  AS pc 
    JOIN dbo.PATIENTS_Patient AS pp ON pp.PATIENT_ID = pc.PATIENT_ID
    WHERE (pc.CLIENT_ID = @clientID)
        ORDER BY 
          pc.CLIENT_ID
          ,pc.PATIENT_ID
    
  RAISERROR ('Finding all relevant matches from PATIENTS_Patient table', 0, 1) WITH NOWAIT 

  INSERT INTO ##allMatchesPSandPP
  SELECT
      ROW_NUM,
      MatchingPatientID,
      STUDENT_ID StuID_on_file,
      stuid_on_file_matching,
      CASE WHEN SCHSTUDID != '' AND STUDENT_ID IS NOT NULL AND stuid_on_file_matching = 0 THEN 1 ELSE 0 END stuid_on_file_conflicting
  FROM
  (
        SELECT
      ROW_NUM,
      STUDENT_ID StuID_on_file,
      MatchingPatientID,
          CASE WHEN SCHSTUDID != '' AND SCHSTUDID = STUDENT_ID THEN 1 ELSE 0 END stuid_on_file_matching,
          SCHSTUDID,    
          STUDENT_ID
        FROM
        (
      SELECT

        ppf.ROW_NUM,
        ps.STUDENT_ID StuID_on_file,
        all_pp.MatchingPatientID,
                ppf.SCHSTUDID,    
                ps.STUDENT_ID

      FROM #parsedpopfile ppf
    
      INNER JOIN ##allPatientsForThisClient all_pp 
        ON
          (requiresAttention IS NULL OR requiresAttention = 0)
              AND
                (
                    all_pp.CSIS_on_file IS NOT NULL AND all_pp.CSIS_on_file = ppf.ImportedCSIS AND ppf.ImportedCSIS != ''
                )
                OR
                (
                    all_pp.DATE_OF_BIRTH_on_file IS NOT NULL AND all_pp.DATE_OF_BIRTH_on_file = ppf.DOB_imported --AND ppf.DOB_imported != ''
                    AND
                    all_pp.LASTNAME_on_file IS NOT NULL AND ppf.lastname_imported = all_pp.LASTNAME_on_file AND ppf.lastname_imported != ''
                    -- later, we are using levenstein distance to observe where first name matches approximately
                )
                OR
                (
                    all_pp.DATE_OF_BIRTH_on_file IS NOT NULL AND all_pp.DATE_OF_BIRTH_on_file = ppf.DOB_imported --AND ppf.DOB_imported != ''
                    AND
                    all_pp.FIRSTNAME_on_file IS NOT NULL AND ppf.firstname_imported = all_pp.FIRSTNAME_on_file AND ppf.firstname_imported != ''
                    -- later, we are using levenstein distance to observe where last name matches approximately
                )
                OR
                (
                    all_pp.LASTNAME_on_file IS NOT NULL AND ppf.lastname_imported = all_pp.LASTNAME_on_file AND ppf.lastname_imported != ''
                    AND
                    all_pp.FIRSTNAME_on_file IS NOT NULL AND ppf.firstname_imported = all_pp.FIRSTNAME_on_file AND ppf.firstname_imported != ''
                    )
          LEFT JOIN
      (
        SELECT DISTINCT PATIENT_ID, STUDENT_ID
        FROM PATIENTS_School
                                -- TODO: I originally intended for this query to grab all possible matches, both active and inactive.
                                -- However, an "active" patient can have both "active" and "inactive" (expired) studentIDs,
                                -- which could possibly get "in the way" so to speak.
                                
                                -- We scan through all possible matches twice; first for active matches only, then for inactive matches only,
                                -- if no suitable active match was found.  If I had this to do over again, I would be looking for active, then
                                -- expired StuIDs for active, and inactive matches; four scans total.

                                -- As it is now, we will be looking for active StuIDs only, for both active and inactive patients.
                                -- (That's a little bit silly, since ideally we wouldn't have any "active" StuIDs for inactive patients...
                                --  -- but we do!! )
        WHERE END_DATE IS NULL OR END_DATE > GETDATE()
      ) ps
            ON
                  all_pp.MatchingPatientID = ps.PATIENT_ID AND ISNULL(ps.STUDENT_ID,'') != ''
                  --( ppf.SCHSTUDID != '' AND ppf.SCHSTUDID = ps.STUDENT_ID )
    ) sel_dist
) sub_q_2_match_flagged
--ORDER BY ROW_NUM

    
RAISERROR ('Finding all relevant matches from PATIENTS_School table', 0, 1) WITH NOWAIT 

INSERT INTO ##allMatchesPSandPP
SELECT
ppf.ROW_NUM,
ps.PATIENT_ID,   
ps.STUDENT_ID,
1,
0
    
FROM #parsedpopfile ppf

/* TODO: Put the results of select distinct patient_id, student_id in a temp table or table variable and reference this instead of the subquery */

INNER JOIN (
      SELECT DISTINCT PATIENT_ID, STUDENT_ID  -- data in PATIENTS_School is denormalized; this cannot be fixed without Andy's (or Terry's) permission
      FROM dbo.PATIENTS_School
                                -- TODO: I originally intended for this query to grab all possible matches, both active and inactive.
                                -- However, an "active" patient can have both "active" and "inactive" (expired) studentIDs,
                                -- which could possibly get "in the way" so to speak.
                                
                                -- We scan through all possible matches twice; first for active matches only, then for inactive matches only,
                                -- if no suitable active match was found.  If I had this to do over again, I would be looking for active, then
                                -- expired StuIDs for active, and inactive matches; four scans total.

                                -- As it is now, we will be looking for active StuIDs only, for both active and inactive patients.
                                -- (That's a little bit silly, since ideally we wouldn't have any "active" StuIDs for inactive patients...
                                --  -- but we do!! )
      WHERE END_DATE IS NULL OR END_DATE > GETDATE() 
    ) ps
ON
  (requiresAttention IS NULL OR requiresAttention = 0)
    AND
      ( ppf.SCHSTUDID != '' AND ppf.SCHSTUDID = ps.STUDENT_ID )

LEFT JOIN ##allMatchesPSandPP existing_matches
  ON
    ppf.ROW_NUM = existing_matches.ROW_NUM
      AND
        ps.PATIENT_ID = existing_matches.MatchingPatientID
    
WHERE existing_matches.MatchingPatientID IS NULL    
                                      -- for an existing patient, it is quite likely that we will find a row in both tables, with the same PATIENT_ID in both.
                                      -- however, it is also possible that we will find unwanted potential matches in both tables.
                                                                          -- here, we eliminate duplicates results, regardless of whether a particular results is eventually found to be desirable or undesirable.      

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above 

;with queried_results_as_possible_matches_containing_data AS (
    SELECT
        q2.ROW_NUM,
        q2.StuID_on_file,
        q2.stuid_on_file_conflicting,
        q2.stuid_on_file_matching,
        ppf.SCHSTUDID,
        ppf.ImportedCSIS,
        ppf.firstname_imported,
        ppf.lastname_imported,
        ppf.DOB_imported,
        all_pp.*
    FROM
        --queried_results_unioned_no_dups q2
        ##allMatchesPSandPP q2
        INNER JOIN
        ##allPatientsForThisClient all_pp
          ON q2.MatchingPatientID = all_pp.MatchingPatientID
        RIGHT JOIN
        #parsedpopfile ppf
          ON ppf.ROW_NUM = q2.ROW_NUM
          
     -- It would be trivially easy to use a WHERE clause here that removes invalid matches.
     -- For example, to eliminate matches where a pat rec was matched on FLDOB, but the CSIS on file is different than what was imported.
     -- Or, where the incoming CSIS points to one patient record, but the incoming StudentID points to a completely different patient record.
     -- Or, when both the CSIS and StudentID on file match the incoming data, but first-name and last-name on file are both completely unexpected values.
     -- we would say, 

        -- WHERE ( ps.PATIENT_ID IS NULL OR ps.PATIENT_ID = all_pp.PATIENT_ID )
        --  AND NOT ( pat_rec.x != data_file.x OR pat_rec.y != data_file.y OR ...)

     -- But we're not going to do that.
     -- Because, then the invalid row would be ignored completely; we would not even be able to detect it going forward.
     -- We *want* to notice weak matches, and we *want* to notice invalid matches.
     -- We want to be able to flag them later for human intervention, if we don't find exactly 1 good match.
     
     -- If there are no matching records pertaining to a row in the data file, we can freely create a new patient record based on that row.
     -- However, if there are patient records pertaining to an entry, but those records have duplicates, typos, or invalid relationships,
     -- then we are making the problem worse if we decide to create yet another patient record.
     
     WHERE requiresAttention IS NULL OR requiresAttention = 0             

)
SELECT * INTO #possibleMatchesUnfiltered
FROM queried_results_as_possible_matches_containing_data

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 2 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- queried all possible matches (good and bad) - beginning filtering & sorting - STEP 1 COMPLETE' "- TIMESTAMP -";

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

;with possible_matches_with_logical_flags_added AS ( --adding logical flags
    SELECT
      psbl.ROW_NUM txtfile_row_num,
      psbl.PossibleMatchOrMatchesFound,
          --CASE WHEN psbl.MatchedStudentID IS NOT NULL THEN 1 ELSE 0 END StuID_match_found, -- boolean
          CASE WHEN psbl.SCHSTUDID != '' AND psbl.stuid_on_file_matching = 0 THEN 1 ELSE 0 END StuID_not_matched, -- boolean
          -- TODO: implement a logical flag MAY_HAVE_CHANGED_SCHOOLS.  --edit: nah, changed my mind.  not necessary at this time.
          --CASE WHEN psbl.SCHSTUDID != '' AND psbl.MatchedStudentID IS NOT NULL AND psbl.SCHSTUDID != psbl.MatchedStudentID THEN 1 ELSE 0 END StuID_match_conflicting, --boolean
      psbl.stuid_on_file_conflicting,
      psbl.stuid_on_file_matching,
      psbl.MatchingPatientID,
      psbl.StuID_on_file,
      psbl.CSIS_on_file,
      psbl.CSIS_match_found, -- boolean     
      psbl.LASTNAME_on_file,
      psbl.FIRSTNAME_on_file,
      psbl.lastname_imported,
      psbl.firstname_imported,
      psbl.lastname_exact_match,
      psbl.firstname_exact_match,
      psbl.DATE_OF_BIRTH_on_file,
          psbl.DOB_imported,
      psbl.patient_active_status,
      CASE WHEN
        psbl.DATE_OF_BIRTH_on_file IS NOT NULL AND psbl.DATE_OF_BIRTH_on_file = psbl.DOB_imported --AND psbl.DOB_imported != ''
        AND (psbl.lastname_exact_match = 1 OR psbl.firstname_exact_match = 1)
      THEN 1 ELSE 0 END FLapprox_DOB_match, -- boolean  
      psbl.conflicting_CSIS_found --boolean
    FROM
    ( SELECT
         psbl.*,
         CASE WHEN psbl.MatchingPatientID IS NOT NULL THEN 1 ELSE 0 END PossibleMatchOrMatchesFound,
                 CASE WHEN psbl.CSIS_on_file IS NOT NULL AND psbl.CSIS_on_file = psbl.ImportedCSIS AND psbl.ImportedCSIS != '' --this is a copy-paste from the all_pp join condition.  we want to avoid doing that, generally
                          THEN 1 ELSE 0 END CSIS_match_found,
             CASE WHEN
                  psbl.ImportedCSIS != '' AND
                  psbl.CSIS_on_file IS NOT NULL AND
                  psbl.CSIS_on_file != psbl.ImportedCSIS AND
                  psbl.CSIS_on_file != ''
                          THEN 1 ELSE 0 END conflicting_CSIS_found,
             CASE WHEN psbl.FIRSTNAME_on_file IS NOT NULL AND psbl.firstname_imported = psbl.FIRSTNAME_on_file AND psbl.firstname_imported != '' THEN 1 ELSE 0 END firstname_exact_match,
             CASE WHEN psbl.LASTNAME_on_file IS NOT NULL AND psbl.lastname_imported = psbl.LASTNAME_on_file AND psbl.lastname_imported != '' THEN 1 ELSE 0 END lastname_exact_match
      FROM #possibleMatchesUnfiltered psbl) psbl
),
per_row_likelihood_ranking_and_sanity_checking AS (  --four additional columns included in result set:
                                                        -- first_name_mismatch (boolean flag)
                                                        -- last_name_mismatch (boolean flag)
                                                        -- invalid_match (boolean flag)
                                                        -- decision_score (int)
    SELECT
      --psbl_logcl.*,    
      psbl_logcl.txtfile_row_num,
      psbl_logcl.PossibleMatchOrMatchesFound,
      --psbl_logcl.MatchedStudentID,
      --psbl_logcl.StuID_match_found,
      psbl_logcl.StuID_not_matched,
      psbl_logcl.stuid_on_file_conflicting,
      psbl_logcl.stuid_on_file_matching,
      psbl_logcl.MatchingPatientID,
      psbl_logcl.stuid_on_file,
      psbl_logcl.CSIS_on_file,
      psbl_logcl.CSIS_match_found,
      psbl_logcl.LASTNAME_on_file,
      psbl_logcl.lastname_exact_match,
      psbl_logcl.last_name_mismatch, -- sets an error flag when the Levenshtein distance to match the last name is over a desired threshhold
      psbl_logcl.FIRSTNAME_on_file,
      psbl_logcl.firstname_exact_match,
      psbl_logcl.first_name_mismatch, -- sets an error flag when the Levenshtein distance to match the first name is over a desired threshhold
      psbl_logcl.DATE_OF_BIRTH_on_file,
          psbl_logcl.DOB_mismatch,
      psbl_logcl.patient_active_status,
      psbl_logcl.FLapprox_DOB_match,
      psbl_logcl.conflicting_CSIS_found,
      
          -- below: this is basically the most important boolean flag, out of all of them
      psbl_logcl.invalid_match,
      
      -- the numerical decision_score is 0 by default, but we use bitwise arithmetic to calculate the final result.  like this:
      
      --   +8 if CSIS matches;
      --   +4 if StudID matches;
      --   +2 if first name or last name matches exactly, AND the other name matches exactly/approxly, AND the DOB matches exactly;
      --   +1 if both first and last names match exactly

              -- If we find patient records with the exact, matching first/last name, but no other matching criteria,
              -- and we do not find any stronger matches, then we flag those weak matches for human attention.
              -- FLapprox_DOB_match is also an example of a weak match, which we flag for human attention.
              
              -- If the decision_score is equal or greater than 3, then we potentially have a good match,
              -- which we can use automatically.
      
      -- arithmetic calculations are implemented below, in nested subqueries.
      -- the three boolean flags, mentioned above, are set in the innermost subquery.  
        
      --CASE WHEN psbl_logcl.invalid_match = 0
      --  THEN
          CASE WHEN psbl_logcl.CSIS_match_found = 1
            THEN decision_score3 + 8
            ELSE decision_score3
            END decision_score
      --  ELSE 0
      --END decision_score
    
    FROM  
    (
      SELECT
        psbl_logcl.*,
        --CASE WHEN psbl_logcl.invalid_match = 0
        --  THEN
            CASE WHEN psbl_logcl.stuid_on_file_matching = 1
              THEN decision_score2 + 4
              ELSE decision_score2
            END decision_score3
        --  ELSE 0
        --END decision_score3
      FROM  
      (
            SELECT
              psbl_logcl.*,
              --CASE WHEN psbl_logcl.invalid_match = 0
                  --  THEN
                      CASE WHEN psbl_logcl.FLapprox_DOB_match = 1
                      THEN decision_score1 + 2
                      ELSE decision_score1
                      END decision_score2
                  --  ELSE 0
              --END as decision_score2
            FROM
            (
          SELECT
            psbl_logcl.*,
                --CASE WHEN psbl_logcl.invalid_match = 0
                    --  THEN
                        CASE WHEN psbl_logcl.firstname_exact_match = 1 AND psbl_logcl.lastname_exact_match = 1
                        THEN 1
                        ELSE 0
                        END decision_score1
                    --  ELSE 0
                --END as decision_score1
              FROM
              (
                SELECT
                      psbl_logcl.*,
                      -- IDIOT CHECKING happens here --
                      CASE WHEN
                          psbl_logcl.conflicting_CSIS_found = 1
                           --OR --removing StuID idiot-checking, as per Anton
                          --psbl_logcl.StuID_match_conflicting = 1
                  --psbl_logcl.stuid_on_file_conflicting = 1
                           OR (
                            -- we will ignore it if either the first name mismatches, or the last name mismatches.
                            -- this could easily be an alternate spelling, or a typo that can easily be corrected; that is no reason to refuse to import B2B data.
                            -- however, if both the first name and the last name mismatch, it is very likely that the record we are looking at pertains to another patient.
                              psbl_logcl.first_name_mismatch = 1 AND psbl_logcl.last_name_mismatch = 1
                          ) OR psbl_logcl.DOB_mismatch = 1
                                    -- TODO: DOB_mismatch flag was added as an afterthought, as per Terry.
                                        -- If we ever need to refactor the reporting logic, consider adding the DOB_mismatch flag to the output.
                      THEN 1 ELSE 0 END invalid_match
                FROM
                (
                  SELECT
                    psbl_logcl.*,
                                CASE WHEN /* psbl_logcl.DOB_imported != '' AND */ psbl_logcl.DATE_OF_BIRTH_on_file IS NOT NULL AND psbl_logcl.DOB_imported != psbl_logcl.DATE_OF_BIRTH_on_file
                                  THEN 1 ELSE 0 END DOB_mismatch,
                    CASE WHEN psbl_logcl.lastname_imported != '' AND psbl_logcl.LASTNAME_on_file IS NOT NULL
                      THEN
                        CASE WHEN psbl_logcl.lastname_imported != psbl_logcl.LASTNAME_on_file
                          THEN
                            CASE WHEN LEN(psbl_logcl.lastname_imported) > 9 OR LEN(psbl_logcl.LASTNAME_on_file) > 9
                              THEN
                                CASE WHEN [dbo].[Levenshtein](psbl_logcl.lastname_imported, RTRIM(psbl_logcl.LASTNAME_on_file), 4) IS NULL
                                  THEN 1
                                  ELSE 0
                                END
                              ELSE
                                CASE WHEN [dbo].[Levenshtein](psbl_logcl.lastname_imported, RTRIM(psbl_logcl.LASTNAME_on_file), 3) IS NULL
                                  THEN 1
                                  ELSE 0
                                END
                            END
                          ELSE 0
                        END
                      ELSE 0
                    END last_name_mismatch,
                    CASE WHEN psbl_logcl.firstname_imported != '' AND psbl_logcl.FIRSTNAME_on_file IS NOT NULL
                      THEN
                        CASE WHEN psbl_logcl.firstname_imported != psbl_logcl.FIRSTNAME_on_file
                          THEN
                            CASE WHEN LEN(psbl_logcl.firstname_imported) > 9 OR LEN(psbl_logcl.FIRSTNAME_on_file) > 9
                              THEN
                                CASE WHEN [dbo].[Levenshtein](psbl_logcl.firstname_imported, RTRIM(psbl_logcl.FIRSTNAME_on_file), 4) IS NULL
                                  THEN 1
                                  ELSE 0
                                END
                              ELSE
                                CASE WHEN [dbo].[Levenshtein](psbl_logcl.firstname_imported, RTRIM(psbl_logcl.FIRSTNAME_on_file), 3) IS NULL
                                  THEN 1
                                  ELSE 0
                                END
                            END                   
                          ELSE 0
                        END
                      ELSE 0
                    END first_name_mismatch
                  FROM
                  possible_matches_with_logical_flags_added psbl_logcl
                ) psbl_logcl 
              ) psbl_logcl
        ) psbl_logcl
      ) psbl_logcl
    ) psbl_logcl
)

SELECT * INTO ##allCandidatesDetailedInfo FROM
per_row_likelihood_ranking_and_sanity_checking


/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 3 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- flagged each possible match as good or bad, & assigned numerical point score - STEP 2 COMPLETE' "- TIMESTAMP -";

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

;with scoring_information_only AS (
    SELECT
      rank_chek.txtfile_row_num,
      rank_chek.patient_active_status,
      rank_chek.MatchingPatientID,
      rank_chek.StuID_on_file,
      CASE WHEN rank_chek.decision_score = 1 OR rank_chek.decision_score = 2 THEN 1 ELSE 0 END weak_match,
      CASE WHEN rank_chek.decision_score > 5 THEN 1 ELSE 0 END "very_strong_match",
      rank_chek.invalid_match,
      rank_chek.stuid_on_file_conflicting,
      rank_chek.stuid_on_file_matching,
      rank_chek.conflicting_CSIS_found,
      CASE WHEN ISNULL(TRIM(rank_chek.StuID_on_file),'') IS NULL THEN 1 ELSE 0 END no_stuid_on_file, -- TODO: this isn't output to excel yet
      NULL CSISNotUniqueInExistingActiveRecords, -- will query & update, later  -- NOTE: I just realized how dumb it is to "query and update later" and not have the CSIS value in this table
      NULL CSISNotUniqueInExistingInactiveRecords, -- will query & update, later
      NULL StuIDNotUniqueInExistingActiveRecords, -- will query & update, later
      NULL StuIDNotUniqueInExistingInactiveRecords, -- will query & update, later  --NOTE: I just realized how dumb it is to "query and update later" without having the StuID value in this table
      rank_chek.last_name_mismatch,
      rank_chek.first_name_mismatch,
      rank_chek.lastname_exact_match,
      rank_chek.firstname_exact_match,
      rank_chek.FLapprox_DOB_match,
      rank_chek.CSIS_match_found,
      null "StuID_not_matched", --rank_chek.StuID_not_matched,
      rank_chek.PossibleMatchOrMatchesFound,
      rank_chek.decision_score
    FROM ##allCandidatesDetailedInfo rank_chek
)
INSERT INTO ##candidates_for_matching
SELECT * 
--INTO ##candidates_for_matching
FROM scoring_information_only
   -- if only weak matches are found, we will refuse to auto-import, and flag for human attention.
   -- if only invalid matches are found, we will refuse to auto-import, and flag for human attention.
   -- if the only matches found are both weak and invalid, then we should absolutely ignore those results, and auto-import.
WHERE NOT (invalid_match = 1 AND weak_match = 1)
ORDER BY txtfile_row_num, decision_score, patient_active_status, MatchingPatientID

-- for each candidate (potential matching record), flag whether unique identifiers are, in fact, unique
SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- Do any of the "good" match candidates have non-unique CSIS?  Checking all "good" candidates, regardless of active status or point value (starting step 3)' "- TIMESTAMP -";
  -- grammatical observation: this particular step, unlike the others, has two timestamp calls to announce that it has begun.
  -- that's because the previous two timestamp announcement are written in the past-tense, but this one and the ones after it are written in the present-tense.

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

SELECT
  CSIS_on_file, patient_active_status, COUNT(DISTINCT MatchingPatientID) "count"
INTO #csisCounts
FROM ##allPatientsForThisClient
WHERE ISNULL(CSIS_on_file,'') != '' -- NOTE: we should no longer be seeing "Warning: Null value is eliminated by an aggregate or other SET operation."
GROUP BY CSIS_on_file, patient_active_status
--HAVING COUNT(DISTINCT MatchingPatientID) > 1

;with active_dup_csis_counts as (
  SELECT * FROM #csisCounts WHERE patient_active_status != 'n' AND "count" > 1
), inactive_dup_csis_counts as (
  SELECT * FROM #csisCounts WHERE patient_active_status = 'n' AND "count" > 1
), all_dup_csis_counts as (
  SELECT a.CSIS_on_file, a."count" active_count, i."count" inactive_count
  FROM active_dup_csis_counts a FULL OUTER JOIN inactive_dup_csis_counts i -- believe it or not, this was harder than it looks
  ON a.CSIS_on_file = i.CSIS_on_file
)
UPDATE ##candidates_for_matching
  SET CSISNotUniqueInExistingActiveRecords = CASE WHEN dupcsis.active_count > 1 THEN 1 ELSE 0 END,
      CSISNotUniqueInExistingInactiveRecords = CASE WHEN dupcsis.inactive_count > 1 THEN 1 ELSE 0 END
  FROM
  all_dup_csis_counts dupcsis JOIN ##allCandidatesDetailedInfo details ON details.CSIS_on_file = dupcsis.CSIS_on_file
  WHERE ##candidates_for_matching.MatchingPatientID = details.MatchingPatientID

END    

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 4 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- For each of the active match candidates that require merging, flagging the corresponding input file row# for human attention - STEP 3 COMPLETE' "- TIMESTAMP -";

/* TODO: If we break down the steps into separate functions, consider consolidating step 3 and step 4 together.  */
           
RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

UPDATE #parsedpopfile
  SET requiresAttention = 1,
      uniqueIdentifierNotUniqueInExistingActiveRecords = 1
  FROM
  (
      SELECT
        DISTINCT txtfile_row_num
      FROM ##candidates_for_matching
      WHERE (
              (CSISNotUniqueInExistingActiveRecords = 1 AND CSIS_match_found = 1)
              --OR
              --(StuIDNotUniqueInExistingActiveRecords = 1 AND stuid_on_file_matching = 1 AND CSIS_match_found = 0)
                -- as per Chuck & Terry, we only care about matching by StuID, and checking for dup StuID, IF we are not matching by CSIS.  JM 5 14 19
            )
        AND
          (invalid_match IS NULL OR invalid_match = 0)
      --GROUP BY txtfile_row_num
      --  HAVING MAX(CSIS_match_found) = 0 OR MIN(CSISNotUniqueInExistingActiveRecords) = 1
  ) subq1
  WHERE #parsedpopfile.ROW_NUM = subq1.txtfile_row_num

/*#############################################################################
  #                                                                           #
  #                  Match Finding Heuristic - 5 of 10                        #
  #                                                                           #
  #############################################################################*/

SELECT CAST(GETDATE() AS VARCHAR) + ' -- SEARCHING, IN PROG -- For each input row, finding the best active match, and the best inactive match - STEP 4 COMPLETE' "- TIMESTAMP -";

RAISERROR (N'', 0, 1) WITH NOWAIT -- no text necessary; will flush output from timestamp above

SELECT *
INTO ##final_matches_active_and_inactive
FROM
(
  SELECT
    txtfile_row_num,
    CASE WHEN PossibleMatchOrMatchesFound = 0 THEN 1 ELSE 0 END no_possible_match_found,
    weak_matches_only,
    invalid_matches_only,
    CASE WHEN count_matches_with_max_score > 1 THEN 1 ELSE 0 END cannot_choose_from_multiple_recs,
    CASE WHEN count_matches_with_max_score = 1 THEN matching_pat_id_if_count_equals_one END MatchingPatientID,
    patient_active_status,
    0 "new_stuid_provided", --will populate with the next pass
    CASE WHEN max_score > 8 AND max_score % 2 = 1 THEN 1 ELSE 0 END matchedByCSISAndDOB, -- if we ever have to change how matches are ranked I'm going to be so mad
    --CASE WHEN max_score & 4 > 0 THEN 1 ELSE 0 END matchedByStuID,
    max_score score
  FROM  
  (
        SELECT -- for each data row, we need to find out if multiple active patient records are tied for highest score.
                   -- we also need to find out if multiple inactive patient records are tied for highest score.
          cand.txtfile_row_num,
          -- if the highest decision_score is 1 or 2, then we only have weak matches.  A human should look at them, but we cannot match them automatically
          CASE max_scores.max_score WHEN 1 THEN 1 WHEN 2 THEN 1 ELSE 0 END weak_matches_only, --TODO: maybe rewrite this to use the weak_match boolean flag
          max_scores.max_score, 
          COUNT( DISTINCT cand.MatchingPatientID ) count_matches_with_max_score, --the max_score could easily be zero.  However, fact that we are doing an INNER JOIN
                                                                              --necessarily means that count_matches_with_max_score will be equal or greater than 1.
          MAX( cand.MatchingPatientID ) matching_pat_id_if_count_equals_one, --if multiple pat recs are tied for max_score, this value is worthless.
                                                                     --we will neither update a record, nor create a new record, in that case;
                                                                     --instead, we will flag all corresponding possible matches for human attention.
          MAX(cand.PossibleMatchOrMatchesFound) PossibleMatchOrMatchesFound, --if there is at least one "1" in the group, the answer is 1.
                                                                             --if there are all 0's in the group, the answer is 0.
          MIN(cand.invalid_match) invalid_matches_only,
          
          cand.patient_active_status 
        FROM
        ##candidates_for_matching cand
        INNER JOIN -- TODO: instead of having a subquery that finds the MAX decision_score, and INNER JOINing to find all ##candidates_for_matching with the highest scores,
                   -- consider using a HAVING clause instead ???  ... hmmmmm,
        (
          SELECT -- for each data file row, get the highest decision score of all active records, and the highest decision score for inactive records, if applicable
                txtfile_row_num,
                MAX(decision_score) max_score, -- MAX(decision_score) ultimately tells us which match we are using.
                                               -- if MAX(decision_score) = 0, then all suggested matches have been found to be invalid.
                                               -- That means we either have only very-weak matches, or we have a significant data integrity problem with patient record(s) pertaining to a specific row in the data file.
                                               -- We flag those for human intervention, if necessary.
                                               -- However!  We flag neither weak matches, nor duplicates, nor those patient records(s) with possible integrity problems,
                                               -- if exactly one good match is found.
                patient_active_status
          FROM ##candidates_for_matching
          GROUP BY txtfile_row_num, patient_active_status 
        ) max_scores ON
                cand.txtfile_row_num = max_scores.txtfile_row_num
                 AND
                cand.patient_active_status = max_scores.patient_active_status
                 AND
                cand.decision_score = max_scores.max_score -- this is our filter condition        
        GROUP BY cand.txtfile_row_num, cand.patient_active_status, max_scores.max_score -- we group-by max_score so that we don't need an agg function.
                                                                                        -- we know that we will only see one max_score for each
                                                                                        -- row_num and active_status combination, in the result set.
  ) final_results_and_totals_active_and_inactive
) final  
 
GO