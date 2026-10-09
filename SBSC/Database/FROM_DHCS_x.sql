USE SPEDMON 
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].FROM_DHCS_x') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE FROM_DHCS_x
GO

CREATE PROCEDURE FROM_DHCS_x
(
          @FilePath nvarchar(250)
        , @istestrun   bit
)
AS
BEGIN

--***************************************************
--      1: Init tables for data and load
--***************************************************

SET nocount ON

CREATE TABLE #FromDHS_FileTable (row nvarchar(max))

--load rowstrings from file
print 'Loading file...'
SET QUOTED_IDENTIFIER OFF
declare @sql varchar(max) = 'bulk insert #FromDHS_FileTable from "' + @FilePath + '"' -- NOTE: I had to make some tiny tweaks on the quoting syntax, vis-a-vis the original
EXEC (@sql)                                                                           -- JM 1 10 19
SET QUOTED_IDENTIFIER ON



--Init intermediary table.
print 'Initializing table for holding parsed file'
CREATE TABLE  
#ParsedDHS_File
(
        SSN nvarchar(9),
        LastName nvarchar(20),
        FirstName nvarchar(15),
        MiddleInitial nvarchar(1),
        DateofBirth date,
        Sex nvarchar(1),
        Client_NPI nvarchar(9),
        School_Name nvarchar(20),

        File_Sequence nvarchar(9),
    fileidnum_hex char(4),
        Patient_ID nvarchar(11),
        userdata_patientID_hex CHAR(7),
        is_hexcoded bit,

        County_Code nvarchar(2),
        BIC nvarchar(14),
        BIC_Issue_Date date,
        FILL1 nvarchar(6),
        Match_Indicator nvarchar(1),
        HASELIG nvarchar(1),
        FILL2 nvarchar(2),
        CURRELIG nvarchar(1),
        SOC1 nvarchar(5),
        CD1 nvarchar(2),
        OIIND nvarchar(1),
        EIJAN nvarchar(1),SOCJAN nvarchar(5),CDJAN nvarchar(2),OIJAN nvarchar(1),
        EIFEB nvarchar(1),SOCFEB nvarchar(5),CDFEB nvarchar(2),OIFEB nvarchar(1),
        EIMAR nvarchar(1),SOCMAR nvarchar(5),CDMAR nvarchar(2),OIMAR nvarchar(1),
        EIAPR nvarchar(1),SOCAPR nvarchar(5),CDAPR nvarchar(2),OIAPR nvarchar(1),
        EIMAY nvarchar(1),SOCMAY nvarchar(5),CDMAY nvarchar(2),OIMAY nvarchar(1),
        EIJUN nvarchar(1),SOCJUN nvarchar(5),CDJUN nvarchar(2),OIJUN nvarchar(1),
        EIJUL nvarchar(1),SOCJUL nvarchar(5),CDJUL nvarchar(2),OIJUL nvarchar(1),
        EIAUG nvarchar(1),SOCAUG nvarchar(5),CDAUG nvarchar(2),OIAUG nvarchar(1),
        EISEP nvarchar(1),SOCSEP nvarchar(5),CDSEP nvarchar(2),OISEP nvarchar(1),
        EIOCT nvarchar(1),SOCOCT nvarchar(5),CDOCT nvarchar(2),OIOCT nvarchar(1),
        EINOV nvarchar(1),SOCNOV nvarchar(5),CDNOV nvarchar(2),OINOV nvarchar(1),
        EIDEC nvarchar(1),SOCDEC nvarchar(5),CDDEC nvarchar(2),OIDEC nvarchar(1),
        MEDSCURR date, 
        FILL5 nvarchar(2),

)

print 'Parsing file into table'
INSERT INTO #ParsedDHS_File
(
        SSN,
        LastName,
        FirstName,
        MiddleInitial,
        DateofBirth,
        Sex,
        Client_NPI,
        School_Name,

        File_Sequence,
        Patient_ID,
        fileidnum_hex,
    userdata_patientID_hex,
        is_hexcoded,

        County_Code,   
        BIC,
        BIC_Issue_Date,
        FILL1,
        Match_Indicator,
        HASELIG,
        FILL2,
        CURRELIG,
        SOC1,
        CD1,
        OIIND,
        EIJAN,SOCJAN,CDJAN,OIJAN,
        EIFEB,SOCFEB,CDFEB,OIFEB,
        EIMAR,SOCMAR,CDMAR,OIMAR,
        EIAPR,SOCAPR,CDAPR,OIAPR,
        EIMAY,SOCMAY,CDMAY,OIMAY,
        EIJUN,SOCJUN,CDJUN,OIJUN,
        EIJUL,SOCJUL,CDJUL,OIJUL,
        EIAUG,SOCAUG,CDAUG,OIAUG,
        EISEP,SOCSEP,CDSEP,OISEP,
        EIOCT,SOCOCT,CDOCT,OIOCT,
        EINOV,SOCNOV,CDNOV,OINOV,
        EIDEC,SOCDEC,CDDEC,OIDEC,
        MEDSCURR,
        FILL5
)
SELECT
        LTRIM(RTRIM(SUBSTRING(row,1,9))) AS SSN ,
        LTRIM(RTRIM(SUBSTRING(row,10,20))) AS LastName ,
        LTRIM(RTRIM(SUBSTRING(row,30,15))) AS FirstName ,
        LTRIM(RTRIM(SUBSTRING(row,45,1))) AS MiddleInitial ,
        LTRIM(RTRIM(SUBSTRING(row,46,8))) AS DateofBirth ,
        LTRIM(RTRIM(SUBSTRING(row,54,1))) AS Sex ,
        LTRIM(RTRIM(SUBSTRING(row,55,9))) AS Client_NPI ,
        LTRIM(RTRIM(SUBSTRING(row,64,20))) AS School_Name ,

        LTRIM(RTRIM(SUBSTRING(row,84,9))) AS File_Sequence,
        LTRIM(RTRIM(SUBSTRING(row,93,11))) AS Patient_ID,
        
        LTRIM(RTRIM(SUBSTRING(row,84,4))) AS fileidnum_hex,
    LTRIM(RTRIM(SUBSTRING(row,96,7))) AS userdata_patientID_hex,
        
        CASE WHEN SUBSTRING(row,103,1) = 'x' THEN 1 ELSE 0 END,

        LTRIM(RTRIM(SUBSTRING(row,104,2))) AS County_Code ,
        LTRIM(RTRIM(SUBSTRING(row,106,14))) AS BIC ,
        LTRIM(RTRIM(SUBSTRING(row,120,8))) AS BIC_Issue_Date ,
        LTRIM(RTRIM(SUBSTRING(row,128,6))) AS FILL1 ,
        LTRIM(RTRIM(SUBSTRING(row,134,1))) AS Match_Indicator ,         /* MATIND */
        LTRIM(RTRIM(SUBSTRING(row,135,1))) AS HASELIG ,                         /* Record_Eligibility_Indicator */
        LTRIM(RTRIM(SUBSTRING(row,136,1))) AS FILL2 ,
        LTRIM(RTRIM(SUBSTRING(row,137,1))) AS CURRELIG ,                        /* Current Month Eligibility */
        LTRIM(RTRIM(SUBSTRING(row,138,5))) AS SOC1 ,                            /* Share of Cost Amount */
        LTRIM(RTRIM(SUBSTRING(row,143,2))) AS CD1 ,                                     /* Certification Date */
        LTRIM(RTRIM(SUBSTRING(row,145,1))) AS OIIND ,                           /* OHC Indicator - Current Month */
        LTRIM(RTRIM(SUBSTRING(row,146,1))) AS EIJAN ,                           /* January Eligibility Indicator */
        LTRIM(RTRIM(SUBSTRING(row,147,5))) AS SOCJAN ,                          /* January Share of Cost Amount */
        LTRIM(RTRIM(SUBSTRING(row,152,2))) AS CDJAN ,                           /* January Certification Date */
        LTRIM(RTRIM(SUBSTRING(row,154,1))) AS OIJAN ,                           /* January OHC Indicator */
        LTRIM(RTRIM(SUBSTRING(row,155,1))) AS EIFEB ,                           
        LTRIM(RTRIM(SUBSTRING(row,156,5))) AS SOCFEB ,                          /* The above four-segment pattern */
        LTRIM(RTRIM(SUBSTRING(row,161,2))) AS CDFEB ,                           /* repeats for the other months   */
        LTRIM(RTRIM(SUBSTRING(row,163,1))) AS OIFEB ,                           /* of the year.                                   */
        LTRIM(RTRIM(SUBSTRING(row,164,1))) AS EIMAR ,
        LTRIM(RTRIM(SUBSTRING(row,165,5))) AS SOCMAR ,
        LTRIM(RTRIM(SUBSTRING(row,170,2))) AS CDMAR ,
        LTRIM(RTRIM(SUBSTRING(row,172,1))) AS OIMAR ,
        LTRIM(RTRIM(SUBSTRING(row,173,1))) AS EIAPR ,
        LTRIM(RTRIM(SUBSTRING(row,174,5))) AS SOCAPR ,
        LTRIM(RTRIM(SUBSTRING(row,179,2))) AS CDAPR ,
        LTRIM(RTRIM(SUBSTRING(row,181,1))) AS OIAPR ,
        LTRIM(RTRIM(SUBSTRING(row,182,1))) AS EIMAY ,
        LTRIM(RTRIM(SUBSTRING(row,183,5))) AS SOCMAY ,
        LTRIM(RTRIM(SUBSTRING(row,188,2))) AS CDMAY ,
        LTRIM(RTRIM(SUBSTRING(row,190,1))) AS OIMAY ,
        LTRIM(RTRIM(SUBSTRING(row,191,1))) AS EIJUN ,
        LTRIM(RTRIM(SUBSTRING(row,192,5))) AS SOCJUN ,
        LTRIM(RTRIM(SUBSTRING(row,197,2))) AS CDJUN ,
        LTRIM(RTRIM(SUBSTRING(row,199,1))) AS OIJUN ,
        LTRIM(RTRIM(SUBSTRING(row,200,1))) AS EIJUL ,
        LTRIM(RTRIM(SUBSTRING(row,201,5))) AS SOCJUL ,
        LTRIM(RTRIM(SUBSTRING(row,206,2))) AS CDJUL ,
        LTRIM(RTRIM(SUBSTRING(row,208,1))) AS OIJUL ,
        LTRIM(RTRIM(SUBSTRING(row,209,1))) AS EIAUG ,
        LTRIM(RTRIM(SUBSTRING(row,210,5))) AS SOCAUG ,
        LTRIM(RTRIM(SUBSTRING(row,215,2))) AS CDAUG ,
        LTRIM(RTRIM(SUBSTRING(row,217,1))) AS OIAUG ,
        LTRIM(RTRIM(SUBSTRING(row,218,1))) AS EISEP ,
        LTRIM(RTRIM(SUBSTRING(row,219,5))) AS SOCSEP ,
        LTRIM(RTRIM(SUBSTRING(row,224,2))) AS CDSEP ,
        LTRIM(RTRIM(SUBSTRING(row,226,1))) AS OISEP ,
        LTRIM(RTRIM(SUBSTRING(row,227,1))) AS EIOCT ,
        LTRIM(RTRIM(SUBSTRING(row,228,5))) AS SOCOCT ,
        LTRIM(RTRIM(SUBSTRING(row,233,2))) AS CDOCT ,
        LTRIM(RTRIM(SUBSTRING(row,235,1))) AS OIOCT ,
        LTRIM(RTRIM(SUBSTRING(row,236,1))) AS EINOV ,
        LTRIM(RTRIM(SUBSTRING(row,237,5))) AS SOCNOV ,
        LTRIM(RTRIM(SUBSTRING(row,242,2))) AS CDNOV ,
        LTRIM(RTRIM(SUBSTRING(row,244,1))) AS OINOV ,
        LTRIM(RTRIM(SUBSTRING(row,245,1))) AS EIDEC ,
        LTRIM(RTRIM(SUBSTRING(row,246,5))) AS SOCDEC ,
        LTRIM(RTRIM(SUBSTRING(row,251,2))) AS CDDEC ,
        LTRIM(RTRIM(SUBSTRING(row,253,1))) AS OIDEC ,
        LTRIM(RTRIM(SUBSTRING(row,254,8))) AS MEDSCURR ,                        /* 'Download date' from DHCS - this is used to get the month/year info for the 'current' month. */
        LTRIM(RTRIM(SUBSTRING(row,262,2))) AS FILL5 
        
FROM 
        #FromDHS_FileTable

UPDATE #ParsedDHS_File
    SET
      File_Sequence = [dbo].[hexstr_2_bigint] (fileidnum_hex),
          Patient_ID = [dbo].[hexstr_2_bigint] (userdata_patientID_hex)
WHERE is_hexcoded = 1

--SELECT * FROM #ParsedDHS_File pdhsf
--RAISERROR(N'', 0, 0) WITH NOWAIT

BEGIN TRY


/******************************************************
        2:      Validate Incoming File
                
        There isn't much we can do to ensure the integrity 
        of a DHCS return file.
        
        One thing we can try is checking that the 
        file sequence ID in the DHCS file exists in
        our systems and is in SENT state.
        
*******************************************************/

declare @file_number int

IF (SELECT COUNT(DISTINCT file_sequence) FROM  #ParsedDHS_File) <> 1
        BEGIN
                /* Error: More than one file sequence ID in DHCS file */
                
                declare @patient_return_error_sequence_count nvarchar(2000) = 'This file contains more than one file sequence ID, suggesting that multiple files have been aggregated together in some unknown fashion. This routine only accepts DHCS return files that link to a single outgoing file.'
                    
                RAISERROR (@patient_return_error_sequence_count, -- Message text.
                               18, -- Severity.
                                   1 -- State.
                                        );
        END
else
        BEGIN 
                SET @file_number = (SELECT top 1 File_Sequence FROM #ParsedDHS_File)
                IF (SELECT COUNT(*) FROM PATIENTS_StudentData_FileID WHERE FILE_NUMBER_ID = @file_number AND NOTE = 'SENT') = 0
                        BEGIN
                                /* Error: this file is listed as already processed */
                                declare @patient_return_error_sequence_completion nvarchar(2000) = 'This file (' + convert(varchar(40), @file_number) + ') has already been processed or does not exist in our records.'
                                RAISERROR (     @patient_return_error_sequence_completion, -- Message text.
                                                        18, -- Severity.
                                                        1 -- State.
                                                   );
                        END     
        END



/* Additional fix options: */

/* Even though there aren't a lot of hard-verification options for this flatfile format, there are a couple of things we can check


1: the BIC is in a specific format of alphanumeric characters - 14 in total with one letter digit.

BIC field should contain either 14 characters or none (14 spaces get trimmed to 0)
If a BIC field is 14 characters, then it -should- have the format NNNNNNNNANNNNN - we can write a filter to check for this as well as the 14-char length.

        LOGIC:
                If (len(14) and fits NNNNNNNNANNNNN pattern) OR blank, allow; otherwise, this is probably a KIWF/full stop thing.
*/

declare @num_wrong_BIC_format bigint 


SET @num_wrong_BIC_format = 
(
        SELECT 
                COUNT(*) 
        FROM 
                #ParsedDHS_File pdhs 
        WHERE 
                pdhs.BIC NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z][0-9][0-9][0-9][0-9][0-9]'
                AND pdhs.BIC <> ''
)

IF @num_wrong_BIC_format <> 0
BEGIN
        declare @BIC_FORMAT_ERROR varchar(max)
        SET @BIC_FORMAT_ERROR = CONVERT(varchar(max), @num_wrong_BIC_format) + ' records from DHCS file ' + @FilePath + ' have values in their BIC field that do not match expected formats (blank or of form NNNNNNNNANNNNN). The field may have new formats or the file may have questionable integrity.'
        raiserror(@BIC_FORMAT_ERROR, 11, 1)
END

/* We can verify patient IDs. 

        Look at the correlation records we sent over to DHCS; if we have no record of sending this patient out, having them come back is suspicious.
        A patient ID should only appear in the file once. If it shows up more than once, something's suspicious here.
        
*/


declare @num_patient_ID_duplicates bigint


SET @num_patient_ID_duplicates = 
(
        SELECT COUNT(*)
        FROM
        (
                SELECT pdhs.Patient_ID 
                FROM #ParsedDHS_File pdhs

                GROUP BY pdhs.Patient_ID
                HAVING COUNT(pdhs.Patient_ID) > 1
        ) q
)

IF  @num_patient_ID_duplicates <> 0
BEGIN
        RAISERROR
        ( 
                'At least one patient ID in this file appears on multiple lines. Check against file records and review the data in the DHCS file.', 
                11, 
                1
        )
END



declare @num_patient_ID_not_recorded bigint

SET @num_patient_ID_not_recorded =
(
        SELECT count(*) 
        FROM #ParsedDHS_File pdhs
        WHERE pdhs.Patient_ID NOT IN
                (
                        SELECT Patient_ID 
                        FROM spedmon.dbo.patients_studentdata_correlation psdc 
                        WHERE psdc.FILE_ID = @file_number
                )
)

IF @num_patient_ID_not_recorded <> 0
BEGIN
        RAISERROR
        (
                'At least one patient ID in this file was not in the list of patient IDs that were originally sent to DHCS in this file.',
                11,
                1
        )
END





/* Validation as complete as we can get it! Now, time to aggregate some data and use frontloaded logic to setup some cached comparison sets */

/* Comparison set listing: */

/*
        Patients who HAVE a BIC and DID NOT return.
        
        Patients who will have their SSN and BIC updated
        Patients who will have only their SSN updated
        Patients who will have only their BIC updated
        Patients who will have their patient record cloned
        
        patients whose BIC and/or SSN will not be altered
        
        Patients whose BIC changed from one valid BIC to another
        
*/

declare @datetime_now datetime = getdate()
declare @patient_file_flags TABLE 
        (
                patient_id bigint, 
                in_return_file bit DEFAULT 0,
                BIC_noReturn bit DEFAULT 0, 
                up_BICSSN bit DEFAULT 0, 
                --up_BIC bit default 0, -- we don't need this flag.  there is no circumstance under which we won't update a BIC
                up_SSN bit DEFAULT 0, 
                --rec_clone bit default 0,  --there is no circumstance under which we will clone-and-deactivate a record.
                do_nothing bit DEFAULT 0,
                multiple_return bit DEFAULT 0
        )

INSERT INTO @patient_file_flags (patient_id)
        SELECT patient_id 
        FROM PATIENTS_StudentData_Correlation psdc 
        WHERE psdc.FILE_ID = @file_number


/* Patients who will have their BIC archived */

        INSERT INTO PATIENT_BIC_ARCHIVE (PATIENT_ID, ARCHIVED_BIC, LAST_MEDS_CURRENT, DATE_ARCHIVED, ARCHIVED_BY)
        SELECT
          patid.PATIENT_ID,
          patid.BIC,
          meds.lastMedsCurr,
          @datetime_now,
          0
        FROM (
        SELECT DISTINCT
          psdc.PATIENT_ID,
          pp.BIC
        FROM PATIENTS_StudentData_Correlation psdc
                INNER JOIN #ParsedDHS_File pdhsf 
                        ON psdc.FILE_ID = @file_number 
                        AND psdc.FILE_ID = pdhsf.File_Sequence
                        AND psdc.PATIENT_ID = pdhsf.Patient_ID
                INNER JOIN PATIENTS_Patient pp ON psdc.PATIENT_ID = pp.PATIENT_ID
        AND
                (
                        ISNULL(pp.BIC,'') <> ''
                        AND ISNULL(pdhsf.BIC,'') <> '' -- will not archive if BIC is missing from return file
                        AND ISNULL(pp.BIC,'') <> ISNULL(pdhsf.BIC,'')
                )
        ) patid
        OUTER APPLY
        (SELECT MAX(MEDS_CURRENT) lastMedsCurr FROM PATIENTS_Eligibility WHERE PATIENT_ID = patid.PATIENT_ID ) meds


/* Mark patients who returned in the file */

UPDATE @patient_file_flags
SET in_return_file = 1
WHERE patient_id IN (SELECT patient_id FROM #ParsedDHS_File)

/* Patients who HAVE a BIC and DID NOT return. */

UPDATE @patient_file_flags
SET BIC_noReturn = 1
WHERE patient_id IN
(
        SELECT psdc.PATIENT_ID FROM PATIENTS_StudentData_FileID psdf
                INNER JOIN PATIENTS_StudentData_Correlation psdc 
                        ON psdf.FILE_NUMBER_ID = @file_number 
                        AND psdf.FILE_NUMBER_ID = psdc.FILE_ID
                
                INNER JOIN PATIENTS_Patient pp ON pp.PATIENT_ID = psdc.PATIENT_ID AND BIC IS NOT NULL AND BIC <> '' AND LEN(BIC) = 14 
                
                LEFT OUTER JOIN #ParsedDHS_File pdhsf 
                        ON psdc.FILE_ID = pdhsf.File_Sequence 
                        AND pdhsf.Patient_ID = psdc.PATIENT_ID
                WHERE pdhsf.Patient_ID IS NULL /* did not return in state file */
)       
        
/* Patients who will have their SSN and BIC updated */
/* Only done if our SSN and BIC fields are both blank */

UPDATE @patient_file_flags
SET up_BICSSN = 1
WHERE patient_id IN
(
        SELECT psdc.PATIENT_ID FROM PATIENTS_StudentData_Correlation psdc
                INNER JOIN #ParsedDHS_File pdhsf 
                        ON psdc.FILE_ID = @file_number 
                        AND psdc.FILE_ID = pdhsf.File_Sequence
                        AND psdc.PATIENT_ID = pdhsf.Patient_ID
                        
                INNER JOIN PATIENTS_Patient pp 
                        ON psdc.PATIENT_ID = pp.PATIENT_ID
        WHERE
                        ISNULL(pp.ssn,'') = ''
                        AND ISNULL(pp.BIC,'') = ''
                        AND isnull(pdhsf.ssn,'') <> ''
                        AND isnull(pdhsf.BIC,'') <> ''
)               


/*      Patients who will have only their SSN updated */

UPDATE @patient_file_flags
SET up_SSN = 1
WHERE patient_id IN
(
        SELECT psdc.PATIENT_ID FROM PATIENTS_StudentData_Correlation psdc
                INNER JOIN #ParsedDHS_File pdhsf 
                        ON psdc.FILE_ID = @file_number 
                        AND psdc.FILE_ID = pdhsf.File_Sequence
                        AND psdc.PATIENT_ID = pdhsf.Patient_ID
                        
                INNER JOIN PATIENTS_Patient pp 
                        ON psdc.PATIENT_ID = pp.PATIENT_ID
        
        WHERE 
                (
                        ISNULL(pp.ssn,'') = ''
                        AND isnull(pdhsf.ssn,'') <> ''
                        AND ISNULL(pp.BIC,'') <> ''
                        AND isnull(pdhsf.BIC,'') = ''
                )
                OR
                (
                        ISNULL(pp.ssn,'') = ''
                        AND isnull(pdhsf.ssn,'') <> ''
                        AND ISNULL(pp.BIC,'') <> ''
                        AND ISNULL(pp.BIC,'') = ISNULL(pdhsf.BIC,'')                            
                )
)       


/* Patients whose BIC and/or SSN will not be altered */
/* At least, the ones we explicitly don't want to modify */


UPDATE @patient_file_flags
SET do_nothing = 1
WHERE patient_id IN
(
        SELECT psdc.PATIENT_ID FROM PATIENTS_StudentData_Correlation psdc
                INNER JOIN #ParsedDHS_File pdhsf 
                        ON psdc.FILE_ID = @file_number 
                        AND psdc.FILE_ID = pdhsf.File_Sequence
                        AND psdc.PATIENT_ID = pdhsf.Patient_ID
                        
                INNER JOIN PATIENTS_Patient pp 
                        ON psdc.PATIENT_ID = pp.PATIENT_ID
        
        WHERE 
                (
                        ISNULL(pdhsf.SSN,'') = ''
                        AND ISNULL(pdhsf.BIC,'') = ''
                )
                OR
                (
                        ISNULL(pp.SSN,'') = ISNULL(pdhsf.SSN,'')
                        AND ISNULL(pp.BIC,'') = ISNULL(pdhsf.BIC,'')
                )
                OR
                (
                        ISNULL(pp.ssn,'') <> ''
                        AND ISNULL(pdhsf.ssn,'') = ''
                        AND ISNULL(pp.BIC,'') = ISNULL(pdhsf.BIC,'')
                )
                OR
                (
                        ISNULL(pp.BIC,'') <> ''
                        AND ISNULL(pdhsf.BIC,'') = ''
                        AND ISNULL(pp.SSN,'') = ISNULL(pdhsf.SSN,'')
                )
)       

/* With the new DHCS format as of 12/2012, DHCS may return patient entries                              */
/* that have multiple matches in their system. These multiple-match patients                    */
/* are indicated with a MATIND of Y and completely blank eligibility information                */
/* In these cases, we want to leave the patient record alone - don't create                     */
/* eligibility info, or don't update what we already have. We also want to flag these   */
/* for later logging and review.                                                                                                                */

UPDATE @patient_file_flags
SET 
        BIC_noReturn =0,
        up_BICSSN = 0,
        --up_BIC = 0,
        up_SSN =0,
        --rec_clone = 0,
        do_nothing = 0,
        multiple_return = 1

WHERE patient_id IN
(
        SELECT psdc.PATIENT_ID FROM PATIENTS_StudentData_Correlation psdc
                INNER JOIN #ParsedDHS_File pdhsf 
                        ON psdc.FILE_ID = @file_number 
                        AND psdc.FILE_ID = pdhsf.File_Sequence
                        AND psdc.PATIENT_ID = pdhsf.Patient_ID
                        
                /* Look for records with a MATIND of Y and blank eligibility data */
                        AND pdhsf.Match_Indicator = 'Y'
                        AND pdhsf.HASELIG = ''
                        AND pdhsf.BIC = ''
                        AND pdhsf.CURRELIG = ''
)
                        
                        
                        
                        

/* Diagnostic: where stuff is at right now */
/*
select * from @patient_file_flags pff
left outer join #ParsedDHS_File pdhs on pff.patient_id = pdhs.Patient_ID
left outer join PATIENTS_Eligibility pe on pff.PATIENT_ID = pe.PATIENT_ID
*/

SELECT *, UPDATE_ELIGIBILITY+ INSERT_ELIGIBILITY+BIC_ERROR_COUNT - TOTAL_IN_TRANSMIT AS CHECKSUM_ZED FROM PATIENTS_StudentData_FileID psdf
CROSS apply 
        (
                SELECT COUNT(*) AS TOTAL_IN_TRANSMIT
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
        ) file_total

CROSS apply 
        (
                SELECT COUNT(*) AS IN_RETURN_FILE
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
                WHERE pdhs.Patient_ID IS NOT NULL
        ) return_file_total
        
CROSS apply 
        (
                SELECT COUNT(*) AS MISSING_FROM_RETURN_FILE
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
                WHERE pdhs.Patient_ID IS NULL
        ) return_file_missing_total
        
CROSS apply 
        (
                SELECT COUNT(*) AS UPDATE_ELIGIBILITY
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
                WHERE 
                        pe.Patient_ID IS NOT NULL
                        AND pff.BIC_noReturn <> 1
        ) return_file_update_total

CROSS apply 
        (
                SELECT COUNT(*) AS INSERT_ELIGIBILITY
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
                WHERE 
                        pe.Patient_ID IS NULL
                        AND pff.BIC_noReturn <> 1
        ) return_file_insert_total
        
CROSS apply 
        (
                SELECT COUNT(*) AS BIC_ERROR_COUNT
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
                WHERE pff.BIC_noReturn = 1
        ) BIC_ERROR_TOTAL
CROSS apply 
        (
                SELECT COUNT(*) AS DHCS_MULTIPLE_MATCHES
                FROM 
                        @patient_file_flags pff
                        LEFT OUTER JOIN #ParsedDHS_File pdhs 
                                ON pff.patient_id = pdhs.Patient_ID
                        LEFT OUTER JOIN PATIENTS_Eligibility pe 
                                ON pff.PATIENT_ID = pe.PATIENT_ID
                WHERE pff.multiple_return = 1
        ) MULTMATCH_COUNT
        

WHERE psdf.FILE_NUMBER_ID = @file_number


--***************************************************
--      2: Data Manipulation & Updates
--***************************************************

BEGIN TRANSACTION

/* Create MEDSCURR value for patients who didn't return in file */

declare @medscurr date
SET @medscurr = (SELECT top 1 MEDSCURR FROM #ParsedDHS_File)



print 'Creating new eligibility records'

/*  2a: Refresh patient eligibility from returned file data */

declare @inserted_ct bigint, @updated_ct bigint

/* Insert new records */ 

INSERT INTO PATIENTS_Eligibility
(
                [PATIENT_ID]
      ,[MEDS_CURRENT]
      ,[CURRENT_MONTH_ELIGIBILITY]
      ,[SHARE_OF_COST]
      ,[CERT_DAY]
      ,[OHC_INDICATOR]
      ,[JAN_ELIGIBILITY_INDICATOR]
      ,[JAN_SHARE_OF_COST]
      ,[JAN_CERT_DAY]
      ,[JAN_OHC_INDICATOR]
      ,[FEB_ELIGIBILITY_INDICATOR]
      ,[FEB_SHARE_OF_COST]
      ,[FEB_CERT_DAY]
      ,[FEB_OHC_INDICATOR]
      ,[MAR_ELIGIBILITY_INDICATOR]
      ,[MAR_SHARE_OF_COST]
      ,[MAR_CERT_DAY]
      ,[MAR_OHC_INDICATOR]
      ,[APR_ELIGIBILITY_INDICATOR]
      ,[APR_SHARE_OF_COST]
      ,[APR_CERT_DAY]
      ,[APR_OHC_INDICATOR]
      ,[MAY_ELIGIBILITY_INDICATOR]
      ,[MAY_SHARE_OF_COST]
      ,[MAY_CERT_DAY]
      ,[MAY_OHC_INDICATOR]
      ,[JUN_ELIGIBILITY_INDICATOR]
      ,[JUN_SHARE_OF_COST]
      ,[JUN_CERT_DAY]
      ,[JUN_OHC_INDICATOR]
      ,[JUL_ELIGIBILITY_INDICATOR]
      ,[JUL_SHARE_OF_COST]
      ,[JUL_CERT_DAY]
      ,[JUL_OHC_INDICATOR]
      ,[AUG_ELIGIBILITY_INDICATOR]
      ,[AUG_SHARE_OF_COST]
      ,[AUG_CERT_DAY]
      ,[AUG_OHC_INDICATOR]
      ,[SEP_ELIGIBILITY_INDICATOR]
      ,[SEP_SHARE_OF_COST]
      ,[SEP_CERT_DAY]
      ,[SEP_OHC_INDICATOR]
      ,[OCT_ELIGIBILITY_INDICATOR]
      ,[OCT_SHARE_OF_COST]
      ,[OCT_CERT_DAY]
      ,[OCT_OHC_INDICATOR]
      ,[NOV_ELIGIBILITY_INDICATOR]
      ,[NOV_SHARE_OF_COST]
      ,[NOV_CERT_DAY]
      ,[NOV_OHC_INDICATOR]
      ,[DEC_ELIGIBILITY_INDICATOR]
      ,[DEC_SHARE_OF_COST]
      ,[DEC_CERT_DAY]
      ,[DEC_OHC_INDICATOR]
)

SELECT
        ISNULL(pdhs.patient_id,psdc.PATIENT_ID),
        --current month data
                isnull(MEDSCURR,@medscurr),
                isnull(CURRELIG,'N'),
                isnull(SOC1,''),
                isnull(CD1,''),
                isnull(OIIND,'N'),
        --January month data
                isnull(EIJAN,'N'),
                isnull(SOCJAN,''),
                isnull(CDJAN,''),
                isnull(OIJAN,'N'),
                
        --Feb month data
                isnull(EIfeb,'N'),
                isnull(SOCfeb,''),
                isnull(CDfeb,''),
                isnull(OIfeb,'N'),
                
        --march
                isnull(EImar,'N'),
                isnull(SOCmar,''),
                isnull(CDmar,''),
                isnull(OImar,'N'),
        --april
                isnull(EIapr,'N'),
                isnull(SOCapr,''),
                isnull(CDapr,''),
                isnull(OIapr,'N'),
        --may
                isnull(EImay,'N'),
                isnull(SOCmay,''),
                isnull(CDmay,''),
                isnull(OImay,'N'),
        --june
                isnull(EIjun,'N'),
                isnull(SOCjun,''),
                isnull(CDjun,''),
                isnull(OIjun,'N'),
        --july
                isnull(EIjul,'N'),
                isnull(SOCjul,''),
                isnull(CDjul,''),
                isnull(OIjul,'N'),
        --august
                isnull(EIaug,'N'),
                isnull(SOCaug,''),
                isnull(CDaug,''),
                isnull(OIaug,'N'),
        --sept
                isnull(EIsep,'N'),
                isnull(SOCsep,''),
                isnull(CDsep,''),
                isnull(OIsep,'N'),
        --oct
                isnull(EIoct,'N'),
                isnull(SOCoct,''),
                isnull(CDoct,''),
                isnull(OIoct,'N'),
        --nov
                isnull(EInov,'N'),
                isnull(SOCnov,''),
                isnull(CDnov,''),
                isnull(OInov,'N'),
        --dec   
                isnull(EIdec,'N'),
                isnull(SOCdec,''),
                isnull(CDdec,''),
                isnull(OIdec,'N')
                
        FROM 
                PATIENTS_StudentData_Correlation psdc 
                INNER JOIN @patient_file_flags pff 
                        ON psdc.PATIENT_ID = pff.patient_id 
                        AND pff.BIC_noReturn <> 1
                LEFT OUTER JOIN #ParsedDHS_File pdhs 
                        ON psdc.PATIENT_ID = pdhs.Patient_ID 
                LEFT OUTER JOIN PATIENTS_Eligibility pe 
                        ON psdc.Patient_ID = pe.PATIENT_ID
        WHERE psdc.FILE_ID = @file_number 
                AND NOT EXISTS 
                        (
                                SELECT 1 
                                FROM PATIENTS_Eligibility pe 
                                WHERE pe.PATIENT_ID = psdc.PATIENT_ID
                        )



SET @inserted_ct = @@ROWCOUNT 

/* Update existing records */

print 'Updating current eligibility records'

UPDATE PATIENTS_Eligibility

        SET 
        --current month data
                meds_current = isnull(MEDSCURR,@medscurr),
                current_month_eligibility = isnull(CURRELIG,'N'),
                share_of_cost = isnull(SOC1,''),
                cert_day = isnull(CD1,''),
                OHC_indicator = isnull(OIIND,'N'),
        --January month data
                jan_eligibility_indicator = isnull(EIJAN,'N'),
                jan_share_of_cost = isnull(SOCJAN,''),
                jan_cert_day = isnull(CDJAN,''),
                jan_OHC_indicator = isnull(OIJAN,'N'),
                
        --Feb month data
                feb_eligibility_indicator = isnull(EIfeb,'N'),
                feb_share_of_cost = isnull(SOCfeb,''),
                feb_cert_day = isnull(CDfeb,''),
                feb_OHC_indicator = isnull(OIfeb,'N'),
                
        --march
                mar_eligibility_indicator = isnull(EImar,'N'),
                mar_share_of_cost = isnull(SOCmar,''),
                mar_cert_day = isnull(CDmar,''),
                mar_OHC_indicator = isnull(OImar,'N'),
        --april
                apr_eligibility_indicator = isnull(EIapr,'N'),
                apr_share_of_cost = isnull(SOCapr,''),
                apr_cert_day = isnull(CDapr,''),
                apr_OHC_indicator = isnull(OIapr,'N'),
        --may
                may_eligibility_indicator = isnull(EImay,'N'),
                may_share_of_cost = isnull(SOCmay,''),
                may_cert_day = isnull(CDmay,''),
                may_OHC_indicator = isnull(OImay,'N'),
        --june
                jun_eligibility_indicator = isnull(EIjun,'N'),
                jun_share_of_cost = isnull(SOCjun,''),
                jun_cert_day = isnull(CDjun,''),
                jun_OHC_indicator = isnull(OIjun,'N'),
        --july
                jul_eligibility_indicator = isnull(EIjul,'N'),
                jul_share_of_cost = isnull(SOCjul,''),
                jul_cert_day = isnull(CDjul,''),
                jul_OHC_indicator = isnull(OIjul,'N'),
        --august
                aug_eligibility_indicator = isnull(EIaug,'N'),
                aug_share_of_cost = isnull(SOCaug,''),
                aug_cert_day = isnull(CDaug,''),
                aug_OHC_indicator = isnull(OIaug,'N'),
        --sept
                sep_eligibility_indicator = isnull(EIsep,'N'),
                sep_share_of_cost = isnull(SOCsep,''),
                sep_cert_day = isnull(CDsep,''),
                sep_OHC_indicator = isnull(OIsep,'N'),
        --oct
                oct_eligibility_indicator = isnull(EIoct,'N'),
                oct_share_of_cost = isnull(SOCoct,''),
                oct_cert_day = isnull(CDoct,''),
                oct_OHC_indicator = isnull(OIoct,'N'),
        --nov
                nov_eligibility_indicator = isnull(EInov,'N'),
                nov_share_of_cost = isnull(SOCnov,''),
                nov_cert_day = isnull(CDnov,''),
                nov_OHC_indicator = isnull(OInov,'N'),
        --dec   
                dec_eligibility_indicator = isnull(EIdec,'N'),
                dec_share_of_cost = isnull(SOCdec,''),
                dec_cert_day = isnull(CDdec,''),
                dec_OHC_indicator = isnull(OIdec,'N')
                
FROM 
(
        SELECT 
                pff.patient_id AS patID,
                pdhs.* 
        FROM 
                @patient_file_flags pff 
                INNER JOIN PATIENTS_Eligibility pe 
                        ON pff.PATIENT_ID = pe.PATIENT_ID
                        AND pff.BIC_noReturn <> 1 /* If patient has a BIC and didn't return, we want to keep their previous eligibility results instead of potentially overwriting them with Ns. */
                LEFT OUTER JOIN #ParsedDHS_File pdhs 
                        ON pff.PATIENT_ID = pdhs.Patient_ID 

) AS output_elig
WHERE patients_eligibility.Patient_ID = output_elig.patID

SET @updated_ct = @@ROWCOUNT 


SELECT @inserted_ct AS INSERT_COUNT,  @updated_ct AS UPDATE_COUNT, @updated_ct - @inserted_ct AS ADJ_UPD_CT
/* DHCS identifiers */

/* Using precached flags, update BIC and SSN data, or clone the patient as necessary */

/* Fill both BIC and SSN fields */

UPDATE PATIENTS_Patient
SET patients_patient.SSN = SSNBIC.pdhsSSN--,
        --patients_patient.BIC = SSNBIC.pdhsBIC
FROM 
(
        SELECT 
                pdhs.SSN AS pdhsSSN, 
                pDHS.BIC AS pdhsBIC, 
                pDHS.Patient_ID 
        FROM 
                #ParsedDHS_File pDHS 
                INNER JOIN @patient_file_flags pff 
                        ON pff.patient_id = pDHS.Patient_ID 
                        AND pff.up_BICSSN = 1 
                        AND pff.BIC_noReturn <> 1
) AS SSNBIC
WHERE PATIENTS_Patient.PATIENT_ID = SSNBIC.Patient_ID


/* Fill just the SSN field */

UPDATE PATIENTS_Patient
SET patients_patient.SSN = SSN.pdhsSSN
FROM 
(
        SELECT 
                pdhs.SSN AS pdhsSSN, 
                pDHS.Patient_ID 
        FROM 
                #ParsedDHS_File pDHS 
                INNER JOIN @patient_file_flags pff 
                        ON pff.patient_id = pDHS.Patient_ID 
                        AND pff.up_SSN = 1 
                        AND pff.BIC_noReturn <> 1
) AS SSN
WHERE PATIENTS_Patient.PATIENT_ID = SSN.Patient_ID


/* Fill BIC field */

UPDATE PATIENTS_Patient
SET patients_patient.BIC = BIC.pdhsBIC 
FROM 
(
        SELECT 
                pdhs.BIC AS pdhsBIC, 
                pDHS.Patient_ID 
        FROM 
                #ParsedDHS_File pDHS 
                INNER JOIN @patient_file_flags pff 
                        ON pff.patient_id = pDHS.Patient_ID 
                        --and pff.up_BIC = 1 
                        AND pff.BIC_noReturn <> 1
) AS BIC
WHERE PATIENTS_Patient.PATIENT_ID = BIC.Patient_ID AND BIC.pdhsBIC != ''


/*******************/
/* Error Reporting */
/*******************/

/* Report out multiple matches */

declare @multiple_match_count bigint =  (SELECT COUNT(*) FROM @patient_file_flags pff WHERE pff.multiple_return = 1)

IF @multiple_match_count <> 0
BEGIN 

        declare @patient_multmatch_error_msg nvarchar(max)

        SET @patient_multmatch_error_msg = 
                convert (varchar(50),@multiple_match_count) + ' patient records in file '+ convert(varchar(50),@file_number) +' were returned with an indicator that DHCS could not find an accurate match:' +CHAR(13)+CHAR(10)
                + 'FILE_ID' + CHAR(9) +  'PATIENT_ID' + CHAR(9) +  'LAST_NAME' + CHAR(9) +   'FIRST_NAME' + CHAR(9) +  'DATE_OF_BIRTH' +  CHAR(9) +  'BIC' + CHAR(13)+CHAR(10)
        SELECT @patient_multmatch_error_msg  = coalesce(@patient_multmatch_error_msg + CHAR(13)+CHAR(10), '') + convert(varchar(500),patient_data) 
        FROM (
                SELECT 
                        convert(varchar(500),@file_number) + CHAR(9) +  
                        convert(varchar(500),pff.patient_id) + CHAR(9) +  
                        convert(varchar(500),pp.LAST_NAME) + CHAR(9) +  
                        convert(varchar(500),pp.FIRST_NAME) + CHAR(9)+  
                        convert(varchar(500),pp.DATE_OF_BIRTH, 112) + CHAR(9) +  
                        convert(varchar(500),pp.BIC) AS patient_data 
                FROM 
                        @patient_file_flags pff
                        INNER JOIN PATIENTS_Patient pp 
                                ON pp.PATIENT_ID = pff.patient_id 
                WHERE pff.multiple_return = 1
                ) top_pats


    RAISERROR ('Some patient records in this file could not be accurately matched by DHCS. See logs for details', -- Message text.
               1, -- Severity.
               1 -- State.
               );

        print @patient_multmatch_error_msg
        print ''

END
        
/* Report out cases where a BIC didn't return in file */

declare @no_return_count bigint =  (SELECT COUNT(*) FROM @patient_file_flags pff WHERE pff.BIC_noReturn = 1)

IF @no_return_count <> 0
BEGIN 

        declare @patient_return_error_msg nvarchar(max)

        SET @patient_return_error_msg = 
                convert (varchar(50),@no_return_count) + ' patient records in file '+ convert(varchar(50),@file_number) +' were expected to return and did not:' +CHAR(13)+CHAR(10)
                + 'FILE_ID' + CHAR(9) +  'PATIENT_ID' + CHAR(9) +  'LAST_NAME' + CHAR(9) +   'FIRST_NAME' + CHAR(9) +  'DATE_OF_BIRTH' +  CHAR(9) +  'BIC' + CHAR(13)+CHAR(10)
        SELECT @patient_return_error_msg  = coalesce(@patient_return_error_msg + CHAR(13)+CHAR(10), '') + convert(varchar(500),patient_id) FROM (
        SELECT 
                convert(varchar(500),@file_number) + CHAR(9) +  
                convert(varchar(500),pff.patient_id) + CHAR(9) +  
                convert(varchar(500),pp.LAST_NAME) + CHAR(9) +  
                convert(varchar(500),pp.FIRST_NAME) + CHAR(9)+  
                convert(varchar(500),pp.DATE_OF_BIRTH, 112) + CHAR(9) +  
                convert(varchar(500),pp.BIC) 
                
                AS patient_id 
        FROM 
                @patient_file_flags pff
                INNER JOIN PATIENTS_Patient pp 
                        ON pp.PATIENT_ID = pff.patient_id 
                WHERE pff.BIC_noReturn = 1

) top_pats


    RAISERROR ('Patient records in file did not return as expected. See individual file log.', -- Message text.
               1, -- Severity.
               1 -- State.
               );


print @patient_return_error_msg



END



/* Diagnostic: where stuff is at right now */
/*
select * from @patient_file_flags pff
inner join PATIENTS_Patient pp on pp.PATIENT_ID = pff.patient_id
left outer join PATIENTS_Eligibility pe on pp.PATIENT_ID = pe.PATIENT_ID
*/



/* File and correlation record cleanup */


--mark off returned patients as complete
print 'Marking students in file as complete'
UPDATE PATIENTS_StudentData_Correlation
SET NOTE = 'COMPLETED - IN FILE'
WHERE FILE_ID = @file_number
AND PATIENT_ID IN (SELECT PATIENT_ID FROM #ParsedDHS_File)



print 'Marking off "All-N" patients as complete'
--mark off not-returned students as complete
UPDATE PATIENTS_StudentData_Correlation
SET NOTE = 'COMPLETED - NOT IN FILE'
WHERE FILE_ID = @file_number
        AND PATIENT_ID NOT IN (SELECT PATIENT_ID FROM #ParsedDHS_File)
        
print 'Marking BIC-error patients for later reference and logging'

UPDATE PATIENTS_StudentData_Correlation
SET 
        NOTE = NOTE + ' - BIC NORETURN'
FROM
        PATIENTS_StudentData_Correlation psdc
        INNER JOIN @patient_file_flags pff
                ON pff.patient_id = psdc.PATIENT_ID 
                AND psdc.FILE_ID = @file_number
                AND pff.BIC_noReturn = 1
        
        
--mark file as done
print 'Marking file ' + CONVERT(varchar(max),@file_number) + ' as complete.'
UPDATE PATIENTS_StudentData_FileID
SET 
        NOTE = 'COMPLETED', 
        DATE_RETURNED = getdate()   --Added Date_Returned update 20111209 JV--
WHERE 
        FILE_NUMBER_ID = @file_number


/* Finished with run. Commit or rollback */



IF @istestrun = 1
        BEGIN
                print 'Test run - rolling back transaction.'
                ROLLBACK TRANSACTION
        END
ELSE
        BEGIN
                print 'Not a test run - committing transaction.'
                COMMIT TRANSACTION
        END
                




END TRY

BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

        IF @@TRANCOUNT = 1
        BEGIN
                ROLLBACK TRANSACTION
        END
        
    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

END CATCH




DROP TABLE #FromDHS_FileTable

DROP TABLE #parsedDHS_file


END
GO