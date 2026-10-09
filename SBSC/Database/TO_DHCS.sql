use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TO_DHCS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TO_DHCS
GO

CREATE PROCEDURE TO_DHCS
(
	  @clientIDCDS nchar(7)
	, @istestrun   bit
  , @outfilepath varchar(500)
  , @monthly_batch bit
  , @ignorePreviousNcountEligTransmissionsForThisClient int
  , @includePatientsAlreadyAwaitingEligMatchInfo bit

  , @patsFromImportID  bigint
  , @fileSubClass      varchar(256)

)

AS
BEGIN

LINENO 17

DROP TABLE if exists #patientselection
DROP TABLE if exists #outfile_info
DROP TABLE if exists #outfile_info_copy

if (@monthly_batch IS NULL) RAISERROR(N'running monthly TO_DHCS batch or not?  Specify 1 or 0 for yes or no; nulls not allowed', 18, 1)

declare @clientID                             as bigint  = NULL
declare @today                                as datetime
declare @istrans                              as bit     = 0

/* Field limits for patient and file IDs */

declare @userdata_fileID_length AS int = 4 --9
declare @userdata_patientID_length AS int = 7 --11
declare @fileidnum_hex   AS char(4)

declare @structuredDataImportID bigint;
declare @importRecordLogID      bigint;  -- it would have been less spaghetti-ish to pass this in as a param
declare @importFromFileReferenceID           as bigint

if ( @patsFromImportID IS NOT NULL
   )

  select top 1
    @structuredDataImportID     = pdi.structuredDataImportID
  , @importFromFileReferenceID  = pdi.importFromFileReferenceID
  FROM dbo.Patient_Data_Imports as pdi
  WHERE (pdi.id = @patsFromImportID)
         AND
        (@fileSubClass = pdi.fileSubClass)

if ( @patsFromImportID IS NOT NULL
     AND
     @fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_TOTAL_POP()
   )

  select top 1 @importRecordLogID=df.id
  FROM dbo.Import_From_A_From_Client_ToSPED_Files df
  where ( df.structuredDataImportID = @structuredDataImportID)

else if ( @patsFromImportID IS NOT NULL
          AND
          @fileSubClass = dbo.CONST_PATIENT_DATA_FILE_SUB_CLASS_SPEC_ED_SVCS()
        )

  select top 1 @importRecordLogID=df.id
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_Files] df
  where ( df.structuredDataImportID = @structuredDataImportID) 


BEGIN TRY  -- NOTE: unlike the A rtn, we don't have a "requires_rollback" error bit, to test on.
           -- As soon as we discover an error, we RAISERROR and go to the CATCH block immediately, without ever setting an error bit.

SET NOCOUNT ON


/*-------------------------------
 * Lookup clientID from CDS 
 * passed in and if the client
 * was not found, exit
 *------------------------------*/

if (@monthly_batch = 0) 
begin
  SELECT top 1 
      @clientID                             = c.CLIENT_ID 
  FROM dbo.clients_client AS c 
  WHERE (c.CLIENT_CDS = @clientIDCDS)
  IF (@clientID IS NULL)                         RAISERROR ('Client not found', 11, 1)   
end


/*-------------------------------
 * Get todays date and setup
 * a temp table to hold our 
 * patient selection
 *------------------------------*/

SET @today = GETDATE()
declare @rightnow datetime2 = SYSDATETIME()

/* We may now create a log entry */

INSERT INTO dbo.[Import_From_B_to_dhcs_ToSPED_Files](B_file_name,main_client_id,began_processing,test_mode)
 VALUES
 (@outfilepath,@clientID,@rightnow, @istestrun);
declare @log_num bigint = SCOPE_IDENTITY();


DROP TABLE if exists #patientselection

CREATE TABLE #patientselection( patient_id      bigint, 
                                client_id       bigint,  
                                patient_site_id bigint, 
                                site_id         bigint, 
                                SSN             nvarchar(11), 
                                lastname        nvarchar(30), 
                                firstname       nvarchar(17), 
                                mi              nvarchar(20), 
                                DOB             date, 
                                sex             nvarchar(1),  
                                student_id      nvarchar(20), 
                                grade           nvarchar(4),
                                userdata_patientID_hex CHAR(7),
                                lastpop date
)

/*-------------------------------
 * Select all patients who ...
 *------------------------------*/

INSERT INTO #patientselection (patient_id,SSN,lastname,firstname,mi,DOB,sex,lastpop)
SELECT * FROM
TO_DHCS_ROWS
(
	  @clientID
  , @monthly_batch
  , @ignorePreviousNcountEligTransmissionsForThisClient
  , @includePatientsAlreadyAwaitingEligMatchInfo

  , @patsFromImportID
  , @fileSubClass

  , @importRecordLogID
  , @structuredDataImportID
  , @today
)


/* Patient-level error checking */
/* Were -any- patients retrieved? If not, don't bother with a file. */

IF ((select COUNT(*) from #patientselection) = 0)
BEGIN
  RAISERROR ('No patients were available for insertion into this file.', 11, 1)
  RETURN
END

/*-------------------------------
 * Fix cases where we have
 * patients at multiple clients
 * by updating all patient
 * records in our selection to
 * use the patients most current
 * client.
 *------------------------------*/

UPDATE #patientselection 
SET client_id = 
(
  SELECT top 1 client_id 
  FROM dbo.PATIENTS_Client pc 
  WHERE 
    pc.PATIENT_ID = #patientselection.patient_id 
  ORDER BY start_date DESC
)

/*-------------------------------
 * Calculate hexidecimal values
 * for each patient_id
 *------------------------------*/

UPDATE #patientselection
SET userdata_patientID_hex = [dbo].[bigint_2_hexstr] (patient_id, 7)
FROM #patientselection
WHERE patient_id IS NOT NULL
                        
/*-------------------------------
 * Fix cases where we have
 * patients with multiple sites
 * by updating all patient
 * records in our selection to
 * use the patients most current
 * site.
 *------------------------------*/

UPDATE #patientselection 
SET     patient_site_id = 
(
  SELECT top 1 
    pschool.PATIENT_SCHOOL_ID
  FROM 
    PATIENTS_School        AS pschool 
    JOIN #patientselection as innerps on  innerps.patient_id = pschool.PATIENT_ID
    JOIN dbo.sites_site        AS s       ON  pschool.SITE_ID    = s.SITE_ID
                                                  AND s.SITE_CLIENT_ID   = innerps.client_id
  WHERE 
    innerps.patient_id = #patientselection.patient_id
  ORDER BY
    start_date DESC
) 
        
/*-------------------------------
 * Update our selection with
 * school site data
 *------------------------------*/
 
UPDATE #patientselection 
  SET site_id    = pschool.SITE_ID, 
      student_id = LEFT(rtrim(ltrim(isnull(pschool.STUDENT_ID,''))),10),
      grade      = LEFT(ltrim(rtrim(isnull(pschool.GRADE,''))),4)
  FROM PATIENTS_School   AS pschool
  JOIN #patientselection as ps on ps.patient_site_id = pschool.PATIENT_SCHOOL_ID
        
        
/* Patient-level error checking */

/* Were -any- patients retrieved? If not, don't bother with a file. */
IF ((SELECT COUNT(*) FROM #patientselection) = 0)
BEGIN
        RAISERROR ('No patients were available for insertion into this eligibility file.', 11, 1)
END             
        
        
/************************************************************
        The outgoing DHCS file only has a limited space for patient ID values. 
        If a patient ID is too long (and gets truncated), we won't be able to correctly identify that patient when the file returns. 
************************************************************/   
IF ((SELECT COUNT(*) FROM #patientselection where LEN(convert(varchar(max), patient_id)) > @userdata_patientID_length )<> 0)
BEGIN
        RAISERROR ('Some patient IDs that would have been included in this file are too long to be stored in the file.', 11, 1)
END

--SELECT * FROM #patientselection ORDER BY lastname, firstname
--RAISERROR(N'!!!', 18, 1) WITH NOWAIT             
     
UPDATE dbo.[Import_From_B_to_dhcs_ToSPED_Files]
SET opened_SQL_transaction = SYSDATETIME()
WHERE id = @log_num     

    /* we're basically home free - just a few more tweaks, initialize some variables, leading up to our transaction */

        declare @patient_batch_size         as int = 100000
        declare @number_batch_files         as bigint
        set @number_batch_files = (select CEILING(COUNT(*)/ convert(decimal(18,2),(@patient_batch_size))) from #patientselection) -- idk why this decimal precision is necessary....

        declare @outfilecontents            as [dbo].[NumberedLinesOfText]

        /*-------------------------------
         *  Decompose filepath to get 
         *  filename - this is for later
         *  table storage and use
         *------------------------------*/

        declare @outfiledir        as varchar (max)
        declare @filenamebuffer    as varchar (max) 
        declare @filename_inc      as varchar (max) =
          CASE WHEN @monthly_batch = 1
            THEN 'DHCSmonthly' + CONVERT(VARCHAR(8), @today, 112)
            ELSE '' END
         -- because, when you + a null with a varchar string, the result is a null.  gotta remember to initialize with empty quotes
        SET @filenamebuffer = @outfilepath

        /*-------------------------------
         * Get JUST the filename
         * from filepath
         *------------------------------*/

        while CHARINDEX('\', @filenamebuffer,0) <> 0
        BEGIN
          set @filenamebuffer = substring(@filenamebuffer,CHARINDEX('\', @filenamebuffer,0)+1,99999999)  -- would be nice if there was a decent utility library built-in to handle stuff like this... 
        END

        /*-------------------------------
         * Get JUST the file directory
         *------------------------------*/
        IF (LEN (@filenamebuffer) > 0)
        SELECT @outfiledir=SUBSTRING(@outfilepath,1,CHARINDEX(@filenamebuffer, @outfilepath) - 2)        -- ugh.  library!
        else
          SELECT @outfiledir=@outfilepath

        -- 



BEGIN TRANSACTION

SET @istrans = 1

/*-------------------------------
 * Create new file record 
 *------------------------------*/
 
 /* Link this match file to the most recent population file for that client (if possible) */
declare @Most_recent_population_file_id bigint

if (@monthly_batch = 0)

--begin


  SELECT 
                          top 1 @Most_recent_population_file_id =pf.File_ID 
                  FROM 
                          Population_Files pf

                  WHERE 
                          pf.Client_ID = @clientID 
                          AND pf.Is_Full_File = 1 
                  ORDER BY 
                          pf.Upload_Date DESC




  /* Throw a warning in the log if the client has no population/'A' records, but carry on with file generation */
  --IF @Most_recent_population_file_id IS NULL
  --  RAISERROR ('This DHCS match file is being generated for a client with no population file uploads.', 1, 1)
 
  -- Commenting this out because it probably isn't reliable anymore, for our purposes

--end

/* Create new DHCS file record */
INSERT INTO dbo.PATIENTS_StudentData_FileID (DATE_CREATED, NOTE, Client_ID, pdiID, Population_File_ID)
VALUES (@today, 'SENT', @clientID, @patsFromImportID, @Most_recent_population_file_id)

declare @fileidnum int = SCOPE_IDENTITY()

SET @fileidnum_hex = [dbo].[bigint_2_hexstr] (@fileidnum, 4)

  /*-------------------------------
    * Update our outgoing file
    * records by adding all records
    * from our selection
    *------------------------------*/

INSERT INTO dbo.PATIENTS_StudentData_Correlation (PATIENT_ID, FILE_ID)
SELECT 
  patient_id, 
  @fileidnum 
FROM
  #patientselection   as patsel
  JOIN dbo.clients_client AS cc ON cc.CLIENT_ID = patsel.client_id
  JOIN dbo.sites_site     AS ss ON ss.SITE_ID   = patsel.site_id

  /*-------------------------------
    * Output our patient selection
    * in a fixed width, fixed postion
    * format.  
    *
    * SSN (9)
    * Last Name (20)
    * First Name (15) 
    * Middle Initial (1)
    * Date of Birth (8)
    * Sex (1)
    * District NPI (9)
    * School Site Name (20)
    * File Number (9) -Assigned (create later)
    * Unique ID (11) -Assigned (PID)
    * Client County CDS/CDS2 (2)
    *------------------------------*/

  SELECT
    ROW_NUMBER() OVER(ORDER BY patient_id ASC) "ROW_NUM",
    patsel.patient_id,
    userdata_patientID_hex,
    LEFT (SSN       + SPACE(9) ,9) SSN,
    LEFT (lastname  + SPACE(20),20) lastname,
    LEFT (Firstname + SPACE(15),15) firstname,
    LEFT (MI        + SPACE(1) ,1) MI,
      /* Date of birth - YYYYMMDD, MM and DD require leading 0s */
      CAST (datepart(YEAR,DOB) AS nvarchar(4))                     +
      RIGHT( '00' + cast(datepart(MONTH,DOB) AS nvarchar(4)), 2)   +
      RIGHT( '00' + cast(datepart(DAY,  DOB) AS nvarchar(4)), 2) DOB,
    LEFT (SEX       + SPACE(1) ,1) SEX,
    LEFT(cc.NPI,9) NPI,
    LEFT(ss.site_name + SPACE(20), 20) site_name,
    convert(varchar, patsel.lastpop, 112) "8char_lastpop",
    LEFT(cc.client_CDS,2) cliCDS2char
  INTO #outfile_info
  FROM 
      #patientselection            AS patsel 
      JOIN dbo.clients_client      AS cc     ON cc.CLIENT_ID = patsel.client_id
      JOIN dbo.sites_site          AS ss     ON ss.SITE_ID   = patsel.site_id

  WHERE cc.NPI IS NOT NULL

  SELECT * INTO #outfile_info_copy FROM #outfile_info -- the way we're doing this, we DELETE from #outfile_info as we go through the loop
                                                   -- and generate the export file(s).  That's why we need a copy.

SET @filenamebuffer = @filename_inc + @filenamebuffer

declare @4hex_fileidnum_8char_lastpop char(12)

select top 1
  @4hex_fileidnum_8char_lastpop = @fileidnum_hex + "8char_lastpop"
  FROM #outfile_info WHERE "8char_lastpop" IS NOT NULL

SET @filenamebuffer += '_' + @4hex_fileidnum_8char_lastpop

WHILE @number_batch_files <> 0
BEGIN
  SET @number_batch_files = @number_batch_files - 1
  DELETE FROM @outfilecontents

  /* Doublecheck DHCS file ID# length to make sure it fits in the appropriate field in the file */
  /*
  IF (LEN(@fileidnum_hex)>@userdata_fileID_length)
  BEGIN
  RAISERROR ('Generated file ID# is too long to fit in ID field.', 11, 1)
  END     
  */

  INSERT INTO @outfilecontents
  SELECT top (@patient_batch_size)

    SSN + lastname + firstname + MI +
    DOB + SEX + NPI + site_name + 
    /* As of 20121201, the new DHCS studmat format gives us a 20-character block to hold whatever unique identification we care to store for the returning file. */  

    @4hex_fileidnum_8char_lastpop +

    userdata_patientID_hex + --7 characters in hex
    IIF( (@patsFromImportID IS NULL), 'y', 'z' ) --1 extra
    +
    cliCDS2char

  FROM #outfile_info
  ORDER BY ROW_NUM  -- tsk tsk.  I'd much rather be doing this with a cursor

  DELETE FROM #outfile_info WHERE ROW_NUM IN (SELECT top (@patient_batch_size) ROW_NUM FROM #outfile_info ORDER BY ROW_NUM)

  SET @filename_inc = 
    CASE WHEN @number_batch_files != 0
         THEN @filenamebuffer + '-' + CAST(@number_batch_files + 1 AS VARCHAR) + '.txt'
         ELSE @filenamebuffer + '.txt' END

  exec [dbo].[AppendTableToTextfile] @outfilecontents, @outfiledir, @filename_inc, 1
  
  if (@monthly_batch = 0) break; -- here, we assume that, other than during the monthly task, we will never output more than 1 file
                                   -- during a single run.  That's how we have been doing it thus far.  If we're wrong, we can comment this line.
END

  /*-------------------------------
    * If this was a test run
    * roll back all of our changes
    *------------------------------*/

  IF (@istestrun) = 1 begin
    ROLLBACK TRANSACTION
    UPDATE dbo.[Import_From_B_to_dhcs_ToSPED_Files]
      SET closed_SQL_transaction = SYSDATETIME(),
          committed_transaction = 0
      WHERE id = @log_num
    end

  /*-------------------------------
    * If this was not a test run
    * commit our changes and clean
    * up
    *------------------------------*/

  else begin
    INSERT INTO [dbo].[Import_From_B_and_C_File_rows]
      (
        [TO_DHCS_log_entry],
        [B_FILE_ROW_NUM],
        [PatientID],
        --[NOTE],
        [SSN],
        [Last_Name_Sent],
        [First_Name_Sent],
        [MI_Sent],
        [DOB_Sent],
        [Sex_Sent],
        [Client_First_9_of_NPI],
        [School_Name],
        [File_Number],
        [Last_Pop],
        [County_Code]
      )
    SELECT 
      @log_num,
      ROW_NUM,
      patient_id,
      --'SENT',
      SSN,
      lastname,
      firstname,
      mi,
        CAST (datepart(YEAR,DOB) AS nvarchar(4))                     +
        RIGHT( '00' + cast(datepart(MONTH,DOB) AS nvarchar(4)), 2)   +
        RIGHT( '00' + cast(datepart(DAY,  DOB) AS nvarchar(4)), 2),
      sex,
      npi,
      site_name,
      @fileidnum,
      [8char_lastpop],
      cliCDS2char
    FROM #outfile_info_copy
    ORDER BY ROW_NUM ASC

    commit transaction

    UPDATE dbo.[Import_From_B_to_dhcs_ToSPED_Files]
    SET closed_SQL_transaction = SYSDATETIME(),
        committed_transaction = 1,
        NOTE = 'SENT',
        [File_Number] = @fileidnum
    WHERE id = @log_num     
  end
SET @istrans = 0

DROP TABLE if exists #patientselection
DROP TABLE if exists #outfile_info
DROP TABLE if exists #outfile_info_copy

END TRY
BEGIN CATCH  -- NOTE: unlike the A rtn, we don't have a "requires_rollback" error bit, to test on.
             -- As soon as we discover an error, we RAISERROR and go to this CATCH block immediately, without ever setting an error bit.

  -- Rollback transaction (if any)
  
  DROP TABLE if exists #patientselection
  DROP TABLE if exists #outfile_info
  DROP TABLE if exists #outfile_info_copy

  IF (@istrans = 1) begin
    ROLLBACK TRANSACTION
    UPDATE dbo.[Import_From_B_to_dhcs_ToSPED_Files]
    SET closed_SQL_transaction = SYSDATETIME(),
        committed_transaction = 0
    WHERE id = @log_num
  end
  
  -- Error or raise error with severity 11 to 19 will be caught here

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT @ErrorMessage  = ERROR_MESSAGE() + ', line ' + CAST(ERROR_LINE() AS VARCHAR),
         @ErrorSeverity = ERROR_SEVERITY(),
         @ErrorState    = ERROR_STATE()

  UPDATE dbo.[Import_From_B_to_dhcs_ToSPED_Files]
    SET error_str = @ErrorMessage
    WHERE id = @log_num

  -- Reraise the error so it returns back to the client
  RAISERROR(N'',0,1) WITH NOWAIT
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH

UPDATE dbo.[Import_From_B_to_dhcs_ToSPED_Files]
  SET done_processing = SYSDATETIME()
  WHERE id = @log_num


END

GRANT EXECUTE ON  [dbo].[TO_DHCS] TO [webuser]
GO

GO