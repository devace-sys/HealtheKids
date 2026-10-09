
USE [SPEDMON]
GO

DROP function IF EXISTS dbo.TO_DHCS_ROWS
GO

CREATE FUNCTION dbo.TO_DHCS_ROWS
(
	  @clientID    bigint
  , @monthly_batch bit
  , @ignorePreviousNcountEligTransmissionsForThisClient int
  , @includePatientsAlreadyAwaitingEligMatchInfo bit

  , @patsFromImportID  bigint
  , @fileSubClass      varchar(256)

  , @importRecordLogID       bigint
  , @structuredDataImportID  bigint
  , @today                   date

)
RETURNS TABLE
AS
RETURN
(
  with previous_ncount_elig_transmissions_this_cli as (

    SELECT
      [FILE_NUMBER_ID] FILE_NUMBER_ID
    FROM [dbo].[PATIENTS_StudentData_FileID] psdf
    WHERE
      ISNULL(@ignorePreviousNcountEligTransmissionsForThisClient, 0) > 0
      AND
      psdf.Client_ID = @clientID

    ORDER BY FILE_NUMBER_ID desc OFFSET 0 ROWS FETCH next ISNULL(@ignorePreviousNcountEligTransmissionsForThisClient, 1) rows only
      -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.
),
patids_to_be_excluded as (

  SELECT 
    psdc.PATIENT_ID 
  FROM 
    dbo.PATIENTS_StudentData_Correlation AS psdc 
    JOIN dbo.PATIENTS_StudentData_FileID AS psdf ON psdc.FILE_ID = psdf.FILE_NUMBER_ID 
    AND psdf.NOTE = 'SENT' --TODO: Confirm that the C routine sets the [return_file_processed_completed] bit
    --in the table dbo.Import_From_B_to_dhcs_ToSPED_Files
    --We can refactor this subquery to look in dbo.[Import_From_B_and_C_File_rows] and
    --dbo.[Import_From_B_to_dhcs_ToSPED_Files].  Eventually,
    --dbo.PATIENTS_StudentData_Correlation and dbo.PATIENTS_StudentData_FileID can be dropped completely.
    AND (
      ISNULL(
        @ignorePreviousNcountEligTransmissionsForThisClient, 
        0
      ) = 0 
      OR psdf.FILE_NUMBER_ID NOT IN (
        SELECT 
          FILE_NUMBER_ID 
        FROM 
          previous_ncount_elig_transmissions_this_cli
      )
    )

  WHERE
    @includePatientsAlreadyAwaitingEligMatchInfo = 0
   
),
service_file_patids as (
  SELECT
    dfr.Patient_ID Matched_PatientID 
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] dfr
  JOIN dbo.[Import_From_A.5_SERVICES_From_Client_Files] i_f
      ON dfr.File_import_log_entry = i_f.id
     AND i_f.id = @importRecordLogID
  WHERE
  (
    (@patsFromImportID IS NOT NULL)
     AND
    (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS())
  )
),
tpop_file_patids as (
  SELECT
    dfr.Matched_PatientID Matched_PatientID
  from dbo.Import_From_A_From_Client_ToSPED_File_rows dfr
  JOIN dbo.Import_From_A_From_Client_ToSPED_Files as df ON df.structuredDataImportID = @structuredDataImportID
        and
        dfr.FROM_CLIENT_log_entry = df.id
  WHERE
  (
    (@patsFromImportID IS NOT NULL)
     AND
    (@fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP())
  )
)


SELECT
 DISTINCT 
 --top 15
  pp.PATIENT_ID,
  LEFT(isnull(pp.ssn,''),9) AS SSN,
  LEFT(COALESCE(NULLIF(TRIM(pp.DHCS_LAST_NAME),''),   TRIM(pp.LAST_NAME), '')  ,20)  DHCS_LAST_NAME,
  LEFT(COALESCE(NULLIF(TRIM(pp.DHCS_FIRST_NAME),''),  TRIM(pp.FIRST_NAME), '') ,15)  DHCS_FIRST_NAME,
  LEFT(COALESCE(NULLIF(TRIM(pp.DHCS_MIDDLE_NAME),''), TRIM(pp.MIDDLE_NAME), ''),1)   MI,
  COALESCE(pp.DHCS_DOB, pp.DATE_OF_BIRTH)                                            DATE_OF_BIRTH, 
  COALESCE(NULLIF(TRIM(pp.DHCS_SEX),''), pp.SEX, '')                                 SEX,
  pp.LASTPOP                                                                         LASTPOP

FROM       dbo.Clients_Client       AS cc
JOIN       dbo.PATIENTS_Client      AS pc  ON cc.CLIENT_ID  = pc.CLIENT_ID
JOIN       dbo.PATIENTS_Patient     AS pp  ON pp.PATIENT_ID = pc.PATIENT_ID
LEFT JOIN  dbo.PATIENTS_Eligibility AS pe  ON pp.PATIENT_ID = pe.PATIENT_ID
LEFT JOIN  patids_to_be_excluded           ON pp.PATIENT_ID = patids_to_be_excluded.PATIENT_ID

LEFT JOIN  tpop_file_patids  tpop_p        ON ( patids_to_be_excluded.PATIENT_ID IS NULL
                                               AND tpop_p.Matched_PatientID = pp.PATIENT_ID )
                                               
LEFT JOIN  service_file_patids  svcfile_p  ON ( patids_to_be_excluded.PATIENT_ID IS NULL
                                               AND svcfile_p.Matched_PatientID = pp.PATIENT_ID )

/* Is mcal datamatch enabled globally for LEA BOP */

cross apply (

  select top 1 
    appSet.id 
  from users.dbo.APP_SETTINGS as appSet
  where (
        (appSet.appName     = 'spedcare') 
    and (appSet.[namespace] = 'dhcs') 
    and (appSet.class       = 'mcal-elig-data') 
    and (appSet.subClass1   = 'match-requests')
    and (appSet.subClass2   = 'lea-bop')
    and (appSet.[name]      = 'enabled')
	and (appSet.[value]     = '1')
	and (appSet.active      = 1)
  )
) as dMatchEnabled

WHERE

-- ( @fileSubClass IS NULL OR @fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP() )
-- TO_DHCS export from services file not yet implemented
  
/*------------------------------------------------
   * Patients from active LEA clients only and
   * from clients who are allowed to send match 
   * requests (Data Use Agreement compliance, etc)
 *------------------------------------------------*/

 --AND
--(cc.LEA = 1) 
 
-- and

(cc.sendElibilityDataMatchRequestsToDHCS = 1)

 and

(cc.CLIENT_ID != 112) 
  
  /*------------------------------------------------
   * And who are active, and of the appropriate age
   *------------------------------------------------*/

and

(pp.ACTIVE = N'Y')

/* Compliance with new rules effective 7/1/2026 */

and ( 
     (isnull(pp.parentConsentMCAL,0) = 1) /*Must have explicit parent consent */ 
  or (isnull(pp.ferpaConsent,0)      = 1) /* Must have FERPA consent*/
)

and (
    @patsFromImportID IS NOT NULL
    OR
    dbo.CALC_AGE(pp.DATE_OF_BIRTH, @today) < 23
    -- when we're generating an elig file from a particular import, we don't filter-out the patients that have aged out
) 

  /*-------------------------------
    * Are not in a file that was sent
    * to dhs and hasn?t come back yet.
    *------------------------------*/
AND patids_to_be_excluded.PATIENT_ID IS NULL




AND  (

  ( @patsFromImportID IS NOT NULL
    AND
    COALESCE( tpop_p.Matched_PatientID, svcfile_p.Matched_PatientID) IS NOT NULL
  )

  OR (
        @monthly_batch = 1

        OR (
        
          @patsFromImportID IS NULL
        -- when we're generating an elig file from a particular import, we don't filter-out the patients that have aged out
        -- and we don't filter-out patients that have (or don't have) recent eligibility data


          AND (
          
          /*-------------------------------
                     * And who either
                     * do not have eligibility data
                     *------------------------------*/
            ( @patsFromImportID IS NULL  AND  pe.ELIGIBILITY_ID IS NULL )
          /*-------------------------------
                     * Or are
                     *
                     *   - in the given client
                     *   - and have a lastpop or
                     *     meds_current within the
                     *     last 15 months
                     *
                     * Note: Date diff is based on
                     *       the 1st day of the month
                     *------------------------------*/
            OR (

              @patsFromImportID IS NULL
              AND
              (
              pc.CLIENT_ID = @clientID 
              AND (
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
                OR pe.MEDS_CURRENT >= DATEADD (
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

              )
            )
          )
        )
      )
    )

)


GO


GRANT select ON dbo.TO_DHCS_ROWS  TO [webuser]
GO
