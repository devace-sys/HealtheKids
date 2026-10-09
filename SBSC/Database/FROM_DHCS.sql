/***************************************************************************    
 * from-dhs.sql */    
/**    
 * Processes patient records that were returned from the
 * California Department of Health and Human Services 
 *
 * @param  fielpath        Path and filename of data
 * @param  istestrun       1 = Test extract, 0 = Actual extract
 * @return                 Status data

This query reads in a file that has been returned from DHS.
Processing is done on the contents of the file to:
	Update the BIC for the patient record referenced in the return file (and archive the old BIC)
	Update eligibility records (or create new where nonexistent) for patients returned in file
	Update/create eligibility records for the patients who were not returned in the file (marked as ineligible/All-N's)
	Mark the internal file record as completed (for tracking purposes)
	Report issues that arose during execution (see notes)
	
	
Notes:
	We will never modify the existing first/last name, SSN, DOB, or other identifying information we have sent over to DHCS, because
  they will never modify fields we send them.  They merely echo those fields back to us in the return file, as per their tapematch documentation.
***************************************************/

use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].FROM_DHCS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE FROM_DHCS
GO

CREATE PROCEDURE FROM_DHCS
(
	  @FilePath nvarchar(250)
	, @istestrun   bit
  , @MAA_templatepath nvarchar(250)
)
AS
BEGIN

LINENO 40

/*  RMTS & SMAA */
declare @MAA_templatefile varchar(300) = @MAA_templatepath + 'MAA-template_copy.xlsx'
declare @MAA_new_excel_filename varchar(300) = 'Medi-Cal Eligibility'

-- for some reason varchar(8000) is too small... and it won't let me specify a number greater than 8000

declare @excelsql nvarchar(max)=
'INSERT INTO OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',''Excel 12.0;Database=' + @MAA_templatefile + ';HDR=NO'',''SELECT * FROM [Sheet1$A3:CT3]'')

  SELECT
  ID,
    TO_DHCS_log_entry,
  	  B_FILE_ROW_NUM,
    	  CASE WHEN C_FILE_ROW_NUM IS NOT NULL THEN C_FILE_ROW_NUM ELSE 0 END C_FILE_ROW_NUM , 
      	  PatientID,
        	in_return_file,
          	  new_BIC,
            	  BIC_changed,
              	  BIC_noReturn,
                	  multiple_return,
                  	  NOTE,
                    	  SSN,
                      	  Last_Name_Sent,
                        	  First_Name_Sent,
                          	  MI_Sent,
                            	  DOB_Sent,
                              	  Sex_Sent,
                                	  Client_First_9_of_NPI,
                                  	  School_Name,
                                    	  File_Number,
                                      	  CASE WHEN Last_Pop > ''1899-01-01'' THEN Last_Pop ELSE NULL END Last_Pop ,'

                                          -- there are a small handful of rows with a last_Pop filling in with a date in 1753 or some such

                                        	+ 'County_Code,
                                          	  BIC,
                                            	  BIC_Issue_Date,
                                              	  Filler_01,
                                                	  Match_Indicator,
                                                  	  Eligibility_Indicator,
                                                    	  Filler_02,
                                                      	  Current_Month_Eligibility,
                                                        	  Current_Month_SOC_Amount,
                                                          	  Current_Month_Cert_Day,
                                                            	  Current_Month_OHC_Indicator,
                                                              	  JAN_Eligibility,
                                                                	  JAN_SOC_Amount,
                                                                  	  JAN_Cert_Day,
                                                                    	  JAN_OHC_Indicator,
                                                                      	  FEB_Eligibility,
                                                                        	  FEB_SOC_Amount,
                                                                          	  FEB_Cert_Day,
                                                                            	  FEB_OHC_Indicator,
                                                                              	  MAR_Eligibility,
                                                                                	  MAR_SOC_Amount,
                                                                                  	  MAR_Cert_Day,
                                                                                    	  MAR_OHC_Indicator,
                                                                                      	  APR_Eligibility,
                                                                                        	  APR_SOC_Amount,
                                                                                          	  APR_Cert_Day,
                                                                                            	  APR_OHC_Indicator,
                                                                                              	  MAY_Eligibility,
                                                                                                	  MAY_SOC_Amount,
                                                                                                  	  MAT_Cert_Day,
                                                                                                    	  MAY_OHC__Indicator,
                                                                                                      	  JUN_Eligibility,
                                                                                                        	  JUN_SOC_Amount,
                                                                                                          	  JUN_Cert_Day,
                                                                                                            	  JUN_OHC_Indicator,
                                                                                                              	  JUL_Eligibility,
                                                                                                                	  JUL_SOC_Amount,
                                                                                                                  	  JUL_Cert_Day,
                                                                                                                    	  JUL_OHC_Indicator,
                                                                                                                      	  AUG_Eligibility,
                                                                                                                        	  AUG_SOC_Amount,
                                                                                                                          	  AUG_Cert_Day,
                                                                                                                            	  AUG_OHC_Indicator,
                                                                                                                              	  SEP_Eligibility,
                                                                                                                                	  SEP_SOC_Amount,
                                                                                                                                  	  SEP_Cert_Day,
                                                                                                                                    	  SEP_OHC_Indicator,
                                                                                                                                      	  OCT_Eligibility,
                                                                                                                                        	  OCT_SOC_Amount,
                                                                                                                                          	  OCT_Cert_Day,
                                                                                                                                            	  OCT_OHC_Indicator,
                                                                                                                                              	  NOV_Eligibility,
                                                                                                                                                	  NOV_SOC_Amount,
                                                                                                                                                  	  NOV_Cert_Day,
                                                                                                                                                    	  NOV_OHC_Indicator,
                                                                                                                                                      	  DEC_Eligibility,
                                                                                                                                                        	  DEC_SOC_Amount,
                                                                                                                                                            DEC_Cert_Day,
                                                                                                                                                          	  DEC_OHC_Indicator,
                                                                                                                                                            	  Meds_Current_Date,
                                                                                                                                                                 CLIENT_CDS,
                                                                                                                                                                   CLIENT_NAME,
                                                                                                                                                                     CASE WHEN LASTPOP > ''1899-01-01'' THEN LASTPOP ELSE NULL END LASTPOP ,
                                                                                                                                                                       FFPqualified,
                                                                                                                                                                      	CurLeaBopElig,
                                                                                                                                                                        	  JanLeaBopElig,
                                                                                                                                                                          	  FebLeaBopElig,
                                                                                                                                                                            	  MarLeaBopElig,
                                                                                                                                                                              	  AprLeaBopElig,
                                                                                                                                                                                	  MayLeaBopElig,
                                                                                                                                                                                  	  JunLeaBopElig,
                                                                                                                                                                                    	  JulLeaBopElig,
                                                                                                                                                                                      	  AugLeaBopElig,
                                                                                                                                                                                        	SepLeaBopElig,
                                                                                                                                                                                          	OctLeaBopElig,
                                                                                                                                                                                            	NovLeaBopElig,
                                                                                                                                                                                              	DecLeaBopElig

  FROM [spedmon].[dbo].[View_RMTS_SMAA_Info_Unfiltered]
  WHERE 
    File_Number = @file_number
    and @Client_First_9_of_NPI = Client_First_9_of_NPI
  ORDER BY ID ASC'

--***************************************************
--	1: Init tables for data and load
--***************************************************

set nocount on

/*
                We may now create a log entry                                 */

INSERT INTO dbo.[Import_From_C_from_dhcs_ToSPED_Files]("C_file_name",began_processing,test_mode)
 VALUES
 (@FilePath,SYSDATETIME(), @istestrun);
declare @log_num bigint = SCOPE_IDENTITY();

create table #FromDHCS_FileTable (row nvarchar(max))

--load rowstrings from file
print 'Loading file...'
SET QUOTED_IDENTIFIER OFF
declare @sql varchar(max) = 'bulk insert #FromDHCS_FileTable from "' + @FilePath + '"' 
EXEC (@sql)                                                                           
SET QUOTED_IDENTIFIER ON



--Init intermediary table.
print 'Initializing table for holding parsed file'
create table  
#ParsedDHCS_File
(

	ROW_NUM bigint identity(1,1), -- We need to have somebody manually add a line number to each line of the input file, and then do a slight modification in code to get it

	File_Sequence nvarchar(9),
    fileidnum_hex char(4),
	Patient_ID nvarchar(11),
	userdata_patientID_hex CHAR(7),
	is_hexcoded bit,
	
	[FROM_DHCS_LAST_NAME]  nvarchar(50),
	[FROM_DHCS_FIRST_NAME] nvarchar(50),
	[FROM_DHCS_MIDDLE_NAME] nchar(1),
	[FROM_DHCS_DOB]        nvarchar(8),
	[FROM_DHCS_SEX]        char(1),

	County_Code nvarchar(2),
	BIC char(14),
	BIC_Issue_Date char(8),
	FILL1 char(6),
	Match_Indicator char(1),
	HASELIG char(1),
	FILL2 char(2),
	CURRELIG char(1),
	SOC1 char(5),
	CD1 char(2),
	OIIND char(1),
	EIJAN char(1),SOCJAN char(5),CDJAN char(2),OIJAN char(1),
	EIFEB char(1),SOCFEB char(5),CDFEB char(2),OIFEB char(1),
	EIMAR char(1),SOCMAR char(5),CDMAR char(2),OIMAR char(1),
	EIAPR char(1),SOCAPR char(5),CDAPR char(2),OIAPR char(1),
	EIMAY char(1),SOCMAY char(5),CDMAY char(2),OIMAY char(1),
	EIJUN char(1),SOCJUN char(5),CDJUN char(2),OIJUN char(1),
	EIJUL char(1),SOCJUL char(5),CDJUL char(2),OIJUL char(1),
	EIAUG char(1),SOCAUG char(5),CDAUG char(2),OIAUG char(1),
	EISEP char(1),SOCSEP char(5),CDSEP char(2),OISEP char(1),
	EIOCT char(1),SOCOCT char(5),CDOCT char(2),OIOCT char(1),
	EINOV char(1),SOCNOV char(5),CDNOV char(2),OINOV char(1),
	EIDEC char(1),SOCDEC char(5),CDDEC char(2),OIDEC char(1),
	MEDSCURR char(8), 

  FFPqualified char(1),
  altFormat   char(42)

)

print 'Parsing file into table'

; with padded_row as (
  SELECT
    "row" +
    '          ' +
    '          ' +
    '          ' +
    '          ' +
    '          ' as "row"
    FROM
  	#FromDHCS_FileTable
)

insert into #ParsedDHCS_File
(

	File_Sequence,
	Patient_ID,
	fileidnum_hex,
  userdata_patientID_hex,
	is_hexcoded,  --let's rename this to B_file_export_version
	
	[FROM_DHCS_LAST_NAME],
	[FROM_DHCS_FIRST_NAME],
	[FROM_DHCS_MIDDLE_NAME],
	[FROM_DHCS_DOB],
	[FROM_DHCS_SEX],

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
	MEDSCURR , 

  FFPqualified ,
  altFormat
)
select

	LTRIM(RTRIM(SUBSTRING(row,84,9))) as File_Sequence,
	LTRIM(RTRIM(SUBSTRING(row,93,11))) as Patient_ID,
	
	LTRIM(RTRIM(SUBSTRING(row,84,4))) as fileidnum_hex,
    LTRIM(RTRIM(SUBSTRING(row,96,7))) as userdata_patientID_hex,
	
	CASE WHEN SUBSTRING(row,103,1) IN ('y', 'z') THEN 1 ELSE 0 END, --B_file_export_version
	
	TRIM(SUBSTRING(row,10,20)) as [FROM_DHCS_LAST_NAME],
	TRIM(SUBSTRING(row,30,15)) as [FROM_DHCS_FIRST_NAME],
	TRIM(SUBSTRING(row,45,1))  as [FROM_DHCS_MIDDLE_NAME],
	TRIM(SUBSTRING(row,46,8))  as [FROM_DHCS_DOB],
	TRIM(SUBSTRING(row,54,1))  as [FROM_DHCS_SEX],

	LTRIM(RTRIM(SUBSTRING(row,104,2))) as County_Code ,
	LTRIM(RTRIM(SUBSTRING(row,106,14))) as BIC ,
	LTRIM(RTRIM(SUBSTRING(row,120,8))) as BIC_Issue_Date ,
	LTRIM(RTRIM(SUBSTRING(row,128,6))) as FILL1 ,
	LTRIM(RTRIM(SUBSTRING(row,134,1))) as Match_Indicator ,		/* MATIND */
	LTRIM(RTRIM(SUBSTRING(row,135,1))) as HASELIG ,				/* Record_Eligibility_Indicator */
	LTRIM(RTRIM(SUBSTRING(row,136,1))) as FILL2 ,
	LTRIM(RTRIM(SUBSTRING(row,137,1))) as CURRELIG ,			/* Current Month Eligibility */
	LTRIM(RTRIM(SUBSTRING(row,138,5))) as SOC1 ,				/* Share of Cost Amount */
	LTRIM(RTRIM(SUBSTRING(row,143,2))) as CD1 ,					/* Certification Date */
	LTRIM(RTRIM(SUBSTRING(row,145,1))) as OIIND ,				/* OHC Indicator - Current Month */
	LTRIM(RTRIM(SUBSTRING(row,146,1))) as EIJAN ,				/* January Eligibility Indicator */
	LTRIM(RTRIM(SUBSTRING(row,147,5))) as SOCJAN ,				/* January Share of Cost Amount */
	LTRIM(RTRIM(SUBSTRING(row,152,2))) as CDJAN ,				/* January Certification Date */
	LTRIM(RTRIM(SUBSTRING(row,154,1))) as OIJAN ,				/* January OHC Indicator */
	LTRIM(RTRIM(SUBSTRING(row,155,1))) as EIFEB ,				
	LTRIM(RTRIM(SUBSTRING(row,156,5))) as SOCFEB ,				/* The above four-segment pattern */
	LTRIM(RTRIM(SUBSTRING(row,161,2))) as CDFEB ,				/* repeats for the other months	  */
	LTRIM(RTRIM(SUBSTRING(row,163,1))) as OIFEB ,				/* of the year.					  */
	LTRIM(RTRIM(SUBSTRING(row,164,1))) as EIMAR ,
	LTRIM(RTRIM(SUBSTRING(row,165,5))) as SOCMAR ,
	LTRIM(RTRIM(SUBSTRING(row,170,2))) as CDMAR ,
	LTRIM(RTRIM(SUBSTRING(row,172,1))) as OIMAR ,
	LTRIM(RTRIM(SUBSTRING(row,173,1))) as EIAPR ,
	LTRIM(RTRIM(SUBSTRING(row,174,5))) as SOCAPR ,
	LTRIM(RTRIM(SUBSTRING(row,179,2))) as CDAPR ,
	LTRIM(RTRIM(SUBSTRING(row,181,1))) as OIAPR ,
	LTRIM(RTRIM(SUBSTRING(row,182,1))) as EIMAY ,
	LTRIM(RTRIM(SUBSTRING(row,183,5))) as SOCMAY ,
	LTRIM(RTRIM(SUBSTRING(row,188,2))) as CDMAY ,
	LTRIM(RTRIM(SUBSTRING(row,190,1))) as OIMAY ,
	LTRIM(RTRIM(SUBSTRING(row,191,1))) as EIJUN ,
	LTRIM(RTRIM(SUBSTRING(row,192,5))) as SOCJUN ,
	LTRIM(RTRIM(SUBSTRING(row,197,2))) as CDJUN ,
	LTRIM(RTRIM(SUBSTRING(row,199,1))) as OIJUN ,
	LTRIM(RTRIM(SUBSTRING(row,200,1))) as EIJUL ,
	LTRIM(RTRIM(SUBSTRING(row,201,5))) as SOCJUL ,
	LTRIM(RTRIM(SUBSTRING(row,206,2))) as CDJUL ,
	LTRIM(RTRIM(SUBSTRING(row,208,1))) as OIJUL ,
	LTRIM(RTRIM(SUBSTRING(row,209,1))) as EIAUG ,
	LTRIM(RTRIM(SUBSTRING(row,210,5))) as SOCAUG ,
	LTRIM(RTRIM(SUBSTRING(row,215,2))) as CDAUG ,
	LTRIM(RTRIM(SUBSTRING(row,217,1))) as OIAUG ,
	LTRIM(RTRIM(SUBSTRING(row,218,1))) as EISEP ,
	LTRIM(RTRIM(SUBSTRING(row,219,5))) as SOCSEP ,
	LTRIM(RTRIM(SUBSTRING(row,224,2))) as CDSEP ,
	LTRIM(RTRIM(SUBSTRING(row,226,1))) as OISEP ,
	LTRIM(RTRIM(SUBSTRING(row,227,1))) as EIOCT ,
	LTRIM(RTRIM(SUBSTRING(row,228,5))) as SOCOCT ,
	LTRIM(RTRIM(SUBSTRING(row,233,2))) as CDOCT ,
	LTRIM(RTRIM(SUBSTRING(row,235,1))) as OIOCT ,
	LTRIM(RTRIM(SUBSTRING(row,236,1))) as EINOV ,
	LTRIM(RTRIM(SUBSTRING(row,237,5))) as SOCNOV ,
	LTRIM(RTRIM(SUBSTRING(row,242,2))) as CDNOV ,
	LTRIM(RTRIM(SUBSTRING(row,244,1))) as OINOV ,
	LTRIM(RTRIM(SUBSTRING(row,245,1))) as EIDEC ,
	LTRIM(RTRIM(SUBSTRING(row,246,5))) as SOCDEC ,
	LTRIM(RTRIM(SUBSTRING(row,251,2))) as CDDEC ,
	LTRIM(RTRIM(SUBSTRING(row,253,1))) as OIDEC ,
	LTRIM(RTRIM(SUBSTRING(row,254,8))) as MEDSCURR ,

  LTRIM(RTRIM(SUBSTRING(row,262,1)))  as FFPqualified ,
  LTRIM(RTRIM(SUBSTRING(row,263,41))) as altFormat
	
from 
	padded_row

UPDATE #ParsedDHCS_File
    SET
    File_Sequence = [dbo].[hexstr_2_bigint] (fileidnum_hex),
	  Patient_ID = [dbo].[hexstr_2_bigint] (userdata_patientID_hex)
WHERE is_hexcoded = 1

BEGIN TRY
  UPDATE #ParsedDHCS_File
    SET Patient_ID = CAST(SUBSTRING(pp.CONCAT_NAME, 8, 99) AS bigint)
  FROM [dbo].PATIENTS_Patient pp
  WHERE pp.PATIENT_ID = #ParsedDHCS_File.Patient_ID
  AND pp.CONCAT_NAME LIKE 'Merged|%'
END TRY
BEGIN CATCH -- I don't really anticipate ever hitting this catch, but just in case...
  SELECT
    pdhsf.is_hexcoded, pdhsf.fileidnum_hex "FileID in hex", pdhsf.userdata_patientID_hex "PatientID in hex",
	  pp.PATIENT_ID, pp.LAST_NAME, pp.FIRST_NAME, pp.CONCAT_NAME, pp.ACTIVE
  FROM #ParsedDHCS_File pdhsf JOIN [dbo].PATIENTS_Patient pp ON pp.PATIENT_ID = pdhsf.Patient_ID AND pp.CONCAT_NAME LIKE 'Merged|%'
	RAISERROR(N'', 0, 1) WITH NOWAIT
  RAISERROR ('Failed to parse the "merged" note in CONCAT_NAME, in one (or more) of the above records', -- Message text.
	  18, -- Severity.
	  1 -- State.
	);
END CATCH

--SELECT * FROM #ParsedDHCS_File pdhsf
--RAISERROR(N'', 0, 0) WITH NOWAIT

BEGIN TRY


/******************************************************
	2:	Validate Incoming File
		
	There isn't much we can do to ensure the integrity 
	of a DHCS return file.
	
	One thing we can try is checking that the 
	file sequence ID in the DHCS file exists in
	our systems and is in SENT state.
	
*******************************************************/

declare @file_number int
declare @log_B int

declare @main_client_id bigint
declare @Client_First_9_of_NPI char(9)


    -- declare @desired_lastpop date

-- NOTE: the lastpop field in PATIENTS_Patient is not a reliable way
-- to narrow down the result set to all the patients in a particular
-- A routine run.  If we re-run an import file, for example, while
-- awaiting a DHCS return file, the lastpop fields fields for those patients
-- will be overwritten.

-- The WHERE implemented upon the MAA-RMTS report return only the
-- patients included in a particular TO-DHCS file.  So filtering by
-- LASTPOP timestamps is unnecessary.


if (select COUNT(distinct file_sequence) from  #ParsedDHCS_File) <> 1
	BEGIN
		/* Error: More than one file sequence ID in DHCS file */
		
		declare @patient_return_error_sequence_count nvarchar(2000) = 'This file contains more than one file sequence ID, suggesting that multiple files have been aggregated together in some unknown fashion. This routine only accepts DHCS return files that link to a single outgoing file.'
		  
      --NOTE: this is a tad confusing, as this error will also show if COUNT(distinct file_sequence) = 0 ...
      --in other words, if not exactly 1 file_sequence was successfully decoded
        
		RAISERROR (@patient_return_error_sequence_count, -- Message text.
			       18, -- Severity.
				   1 -- State.
					);
	END
else
	BEGIN 
		set @file_number = (select top 1 File_Sequence from #ParsedDHCS_File)  -- expected to match primary key from [dbo].[PATIENTS_StudentData_FileID]
    SELECT top 1 @log_B=id,
                 @main_client_id=main_client_id
    FROM [dbo].[Import_From_B_to_dhcs_ToSPED_Files] WHERE [File_Number] = @file_number  -- spaghetti!  yum!

                                                  -- In all seriousness, we have to do this because each file row has
                                                  -- two unique IDs instead of one.  Each file row has an entry in [dbo].[PATIENTS_StudentData_Correlation]
                                                  -- and [dbo].[Import_From_B_and_C_File_rows].  Likewise, each file has two unique IDs instead of one.
                                                  -- Each file has an entry in [dbo].[PATIENTS_StudentData_Correlation] and [dbo].[Import_From_B_and_C_File_rows].
                                                  -- So it's inevitable that this will be somewhat spaghetti-ish.
    
    /*  RMTS & SMAA  */
    SELECT
      @Client_First_9_of_NPI = SUBSTRING(NPI,1,9),
      @MAA_new_excel_filename = CLIENT_NAME + ' ' + @MAA_new_excel_filename + ' as of '
    FROM CLIENTS_Client WHERE CLIENT_ID = @main_client_id
    
    UPDATE [dbo].[Import_From_C_from_dhcs_ToSPED_Files]
    SET TO_DHCS_log_entry = @log_B
    WHERE id = @log_num

		if (select COUNT(*) from PATIENTS_StudentData_FileID where FILE_NUMBER_ID = @file_number and NOTE = 'SENT') = 0
			BEGIN
				/* Error: this file is listed as already processed */
				declare @patient_return_error_sequence_completion nvarchar(2000) = 'This file (' + convert(varchar(40), @file_number) + ') has already been processed or does not exist in our records.'
				RAISERROR (	@patient_return_error_sequence_completion, -- Message text.
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
		If (len(14) and fits NNNNNNNNANNNNN pattern) OR blank, allow; otherwise, this is probably a KIWF/full stop thing.  -- def a millenial wrote this (not me tho)
*/

declare @num_wrong_BIC_format bigint 


set @num_wrong_BIC_format = 
(
	select 
		COUNT(*) 
	from 
		#ParsedDHCS_File pdhs 
	where 
		pdhs.BIC not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z][0-9][0-9][0-9][0-9][0-9]'
		and pdhs.BIC <> ''
)

if @num_wrong_BIC_format <> 0
BEGIN
	declare @BIC_FORMAT_ERROR varchar(max)
	set @BIC_FORMAT_ERROR = CONVERT(varchar(max), @num_wrong_BIC_format) + ' records from DHCS file ' + @FilePath + ' have values in their BIC field that do not match expected formats (blank or of form NNNNNNNNANNNNN). The field may have new formats or the file may have questionable integrity.'
	raiserror(@BIC_FORMAT_ERROR, 11, 1)
END



/* Validation as complete as we can get it! Now, time to aggregate some data and use frontloaded logic to setup some cached comparison sets */

declare @datetime_now datetime = getdate()

-- NOTE: in the previous (non-JM) iteration of the C routine these logical flags did not actually control-switch any logic below;
-- they were simply counted up for statistical reporting.

-- In this iteration, we are using different flags, which will be used occasionally for control logic.  For better or worse.
declare @patient_file_flags table 
	(
		ROW_NUM bigint,
    client_id bigint,
		patient_id bigint, 
		in_return_file bit default 0,
    old_BIC char(14),
	  new_BIC bit default 0,
    BIC_changed bit default 0,
		BIC_noReturn bit default 0, 
		multiple_return bit default 0
    --TODO: eventually we should add a record_was_merged flag in the log table, and log this information permanently
	)

insert into @patient_file_flags (client_id, patient_id /* old_BIC, */)
	select pc.client_id, psdc.patient_id --, pp.BIC 
	from dbo.PATIENTS_StudentData_Correlation psdc 
	JOIN dbo.PATIENTS_Client pc ON psdc.FILE_ID = @file_number AND pc.PATIENT_ID = psdc.PATIENT_ID
	-- I'd like to also eventually JOIN on Client_NPI (from the return file) and make sure it matches to the same client.
	-- RAISERROR if it does not.

	--JOIN dbo.PATIENTS_Patient pp ON pp.PATIENT_ID = psdc.PATIENT_ID /* = pc.PATIENT_ID would also work */

UPDATE @patient_file_flags
  SET ROW_NUM = pdhsf.ROW_NUM
FROM @patient_file_flags pff
  JOIN #ParsedDHCS_File pdhsf
  ON pdhsf.Patient_ID = pff.patient_id

/* Patients who will have their BIC archived */
;with needs_BIC_change as (
	select distinct
	  psdc.PATIENT_ID p_id,
	  pp.BIC
	from PATIENTS_StudentData_Correlation psdc
  -- TODO: not sure that querying psdc is necessary; we've already established that all the patients in #ParsedDHCS_File were included in the transmittal
		inner join #ParsedDHCS_File pdhsf 
			on psdc.FILE_ID = @file_number 
			and psdc.FILE_ID = pdhsf.File_Sequence
			and psdc.PATIENT_ID = pdhsf.Patient_ID
		inner join PATIENTS_Patient pp ON psdc.PATIENT_ID = pp.PATIENT_ID
	and
		(
			ISNULL(pp.BIC,'') <> ''
			and ISNULL(pdhsf.BIC,'') <> '' -- will not archive if BIC is missing from return file
			and ISNULL(pp.BIC,'') <> ISNULL(pdhsf.BIC,'')
		)
)
update @patient_file_flags
SET BIC_changed = 1,
    old_BIC = changed.BIC
FROM needs_BIC_change changed
WHERE patient_id = p_id

/* Mark patients who returned in the file */

update @patient_file_flags
set in_return_file = 1
where patient_id in (select patient_id from #ParsedDHCS_File)

/* Patients who HAVE a BIC and DID NOT return. */

update f
set BIC_noReturn = 1
FROM @patient_file_flags f JOIN PATIENTS_Patient pp
ON f.patient_id = pp.PATIENT_ID AND pp.BIC IS NOT NULL AND LEN(pp.BIC) = 14 AND f.in_return_file = 0

-- NOTE: the "do_nothing" code, which was here, does nothing, so it has been removed.  bye bye!

/* With the new DHCS format as of 12/2012, DHCS may return patient entries 				*/
/* that have multiple matches in their system. These multiple-match patients  			*/
/* are indicated with a MATIND of Y and completely blank eligibility information 		*/
/* In these cases, we want to leave the patient record alone - don't create 			*/
/* eligibility info, or don't update what we already have. We also want to flag these 	*/
/* for later logging and review. 														*/

update @patient_file_flags
set 
	BIC_noReturn =0,  -- this field is already zero, but ok!
	--up_BICSSN = 0,
	--up_BIC = 0,
	--up_SSN =0,
	--rec_clone = 0,
	--do_nothing = 0,
	multiple_return = 1

where patient_id in
(
	select psdc.PATIENT_ID from PATIENTS_StudentData_Correlation psdc
		inner join #ParsedDHCS_File pdhsf 
			on psdc.FILE_ID = @file_number 
			and psdc.FILE_ID = pdhsf.File_Sequence
			and psdc.PATIENT_ID = pdhsf.Patient_ID
			
		/* Look for records with a MATIND of Y and blank eligibility data */
			and pdhsf.Match_Indicator = 'Y'
			and pdhsf.HASELIG = ''
			and pdhsf.BIC = ''
			and pdhsf.CURRELIG = ''
)
			
UPDATE f
  SET new_BIC = 1
FROM @patient_file_flags f JOIN dbo.PATIENTS_Patient pp
ON f.patient_id = pp.PATIENT_ID AND (pp.BIC IS NULL OR BIC = '' )
 AND f.in_return_file = 1	
 AND f.BIC_changed = 0
 AND f.multiple_return = 0

/* Diagnostic: where stuff is at right now */
/*
select * from @patient_file_flags pff
left outer join #ParsedDHCS_File pdhs on pff.patient_id = pdhs.Patient_ID
left outer join PATIENTS_Eligibility pe on pff.PATIENT_ID = pe.PATIENT_ID
*/

-- NOTE: this query was going very slow
select *, UPDATE_ELIGIBILITY+ INSERT_ELIGIBILITY+BIC_ERROR_COUNT - TOTAL_IN_TRANSMIT as CHECKSUM_ZED -- ??? what is "CHECKSUM_ZED" ? ???
from PATIENTS_StudentData_FileID psdf
cross apply 
	(
		select COUNT(*) as TOTAL_IN_TRANSMIT
		from 
			@patient_file_flags pff
	) file_total

cross apply 
	(
		select COUNT(*) as IN_RETURN_FILE
		from 
			@patient_file_flags pff
			left outer join #ParsedDHCS_File pdhs 
				on pff.patient_id = pdhs.Patient_ID
		where pdhs.Patient_ID is not null
	) return_file_total
	
cross apply 
	(
		select COUNT(*) as MISSING_FROM_RETURN_FILE
		from 
			@patient_file_flags pff
			left outer join #ParsedDHCS_File pdhs 
				on pff.patient_id = pdhs.Patient_ID
		where pdhs.Patient_ID is null
	) return_file_missing_total

cross apply 
	(
		select COUNT(*) as UPDATE_ELIGIBILITY
		from 
			@patient_file_flags pff
			left outer join PATIENTS_Eligibility pe 
				on pff.PATIENT_ID = pe.PATIENT_ID
		where 
			pe.Patient_ID is not null
			and pff.BIC_noReturn <> 1
	) return_file_update_total

cross apply 
	(
		select COUNT(*) as INSERT_ELIGIBILITY
		from 
			@patient_file_flags pff
			left outer join PATIENTS_Eligibility pe 
				on pff.PATIENT_ID = pe.PATIENT_ID
		where 
			pe.Patient_ID is null
			and pff.BIC_noReturn <> 1
	) return_file_insert_total
	
cross apply 
	(
		select COUNT(*) as BIC_ERROR_COUNT
		from 
			@patient_file_flags pff
			left outer join PATIENTS_Eligibility pe 
				on pff.PATIENT_ID = pe.PATIENT_ID
		where pff.BIC_noReturn = 1
	) BIC_ERROR_TOTAL
cross apply 
	(
		select COUNT(*) as DHCS_MULTIPLE_MATCHES
		from 
			@patient_file_flags pff
		where pff.multiple_return = 1
	) MULTMATCH_COUNT

where psdf.FILE_NUMBER_ID = @file_number

-- Ultimately, we're doing these error flags outside of the transaction so the import logs won't be lost if the transaction fails.
-- We don't want to lose our logs.  If the transaction fails, we *want to know why* !

UPDATE [dbo].[Import_From_C_from_dhcs_ToSPED_Files]
  SET opened_SQL_transaction = SYSDATETIME()
  WHERE id = @log_num

--***************************************************
--	2: Data Manipulation & Updates
--***************************************************

BEGIN TRANSACTION

UPDATE [dbo].[Import_From_B_and_C_File_rows]
  SET C_FILE_ROW_NUM = pff.ROW_NUM,
      in_return_file = pff.in_return_file,
      new_BIC = pff.new_BIC,
      BIC_changed = pff.BIC_changed,
      BIC_noReturn = pff.BIC_noReturn,
      multiple_return = pff.multiple_return
FROM @patient_file_flags pff
WHERE [Import_From_B_and_C_File_rows].PatientID = pff.patient_id
  AND [Import_From_B_and_C_File_rows].TO_DHCS_log_entry = @log_B


update pap
set 
    pap.ACTIVE       = N'y'
  , pap.ffpQualified = [dbo].[FLAG_STRING_TO_BIT]( pdhf.FFPqualified, 0)
  , pap.altFormat    = pdhf.altFormat
from #ParsedDHCS_File     as pdhf
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pdhf.Patient_ID

UPDATE [dbo].[Import_From_B_and_C_File_rows]
   SET [BIC] = f_in.BIC
      ,[BIC_Issue_Date] = f_in.BIC_Issue_Date
      ,[Filler_01] = f_in.FILL1
      ,[Match_Indicator] = f_in.Match_Indicator
      ,[Eligibility_Indicator] = f_in.HASELIG
      ,[Filler_02] = f_in.FILL2
      ,[Current_Month_Eligibility] = f_in.CURRELIG
      ,[Current_Month_SOC_Amount] = f_in.SOC1
      ,[Current_Month_Cert_Day] = f_in.CD1
      ,[Current_Month_OHC_Indicator] = f_in.OIIND
      ,[JAN_Eligibility] = f_in.EIJAN
      ,[JAN_SOC_Amount] = f_in.SOCJAN
      ,[JAN_Cert_Day] = f_in.CDJAN
      ,[JAN_OHC_Indicator] = f_in.OIJAN
      ,[FEB_Eligibility] = f_in.EIFEB
      ,[FEB_SOC_Amount] = f_in.SOCFEB
      ,[FEB_Cert_Day] = f_in.CDFEB
      ,[FEB_OHC_Indicator] = f_in.OIFEB
      ,[MAR_Eligibility] = f_in.EIMAR
      ,[MAR_SOC_Amount] = f_in.SOCMAR
      ,[MAR_Cert_Day] = f_in.CDMAR
      ,[MAR_OHC_Indicator] = f_in.OIMAR
      ,[APR_Eligibility] = f_in.EIAPR
      ,[APR_SOC_Amount] = f_in.SOCAPR
      ,[APR_Cert_Day] = f_in.CDAPR
      ,[APR_OHC_Indicator] = f_in.OIAPR
      ,[MAY_Eligibility] = f_in.EIMAY
      ,[MAY_SOC_Amount] = f_in.SOCMAY
      ,[MAT_Cert_Day] = f_in.CDMAY
      ,[MAY_OHC__Indicator] = f_in.OIMAY
      ,[JUN_Eligibility] = f_in.EIJUN
      ,[JUN_SOC_Amount] = f_in.SOCJUN
      ,[JUN_Cert_Day] = f_in.CDJUN
      ,[JUN_OHC_Indicator] = f_in.OIJUN
      ,[JUL_Eligibility] = f_in.EIJUL
      ,[JUL_SOC_Amount] = f_in.SOCJUL
      ,[JUL_Cert_Day] = f_in.CDJUL
      ,[JUL_OHC_Indicator] = f_in.OIJUL
      ,[AUG_Eligibility] = f_in.EIAUG
      ,[AUG_SOC_Amount] = f_in.SOCAUG
      ,[AUG_Cert_Day] = f_in.CDAUG
      ,[AUG_OHC_Indicator] = f_in.OIAUG
      ,[SEP_Eligibility] = f_in.EISEP
      ,[SEP_SOC_Amount] = f_in.SOCSEP
      ,[SEP_Cert_Day] = f_in.CDSEP
      ,[SEP_OHC_Indicator] = f_in.OISEP
      ,[OCT_Eligibility] = f_in.EIOCT
      ,[OCT_SOC_Amount] = f_in.SOCOCT
      ,[OCT_Cert_Day] = f_in.CDOCT
      ,[OCT_OHC_Indicator] = f_in.OIOCT
      ,[NOV_Eligibility] = f_in.EINOV
      ,[NOV_SOC_Amount] = f_in.SOCNOV
      ,[NOV_Cert_Day] = f_in.CDNOV
      ,[NOV_OHC_Indicator] = f_in.OINOV
      ,[DEC_Eligibility] = f_in.EIDEC
      ,[DEC_SOC_Amount] = f_in.SOCDEC
      ,[DEC_Cert_Day] = f_in.CDDEC
      ,[DEC_OHC_Indicator] = f_in.OIDEC
      ,[Meds_Current_Date] = f_in.MEDSCURR

      , FFPqualified = [dbo].[FLAG_STRING_TO_BIT]( f_in.FFPqualified, 0)
      , altFormat = f_in.altFormat

FROM #ParsedDHCS_File f_in
WHERE f_in.Patient_ID = [dbo].[Import_From_B_and_C_File_rows].PatientID
    AND
        TO_DHCS_log_entry = @log_B

print 'Archiving old BIC information in the BIC archive'

  declare @toArchive as ArchiveTheseBics;
  insert into @toArchive SELECT client_id, PATIENT_ID, old_BIC FROM @patient_file_flags
    WHERE BIC_changed = 1

  exec [dbo].[ARCHIVE_BICS_AND_RESUBMIT_CLAIMS] /* archivedBy */ 0, @toArchive, 1

/*
	insert into PATIENT_BIC_ARCHIVE (PATIENT_ID, ARCHIVED_BIC, LAST_MEDS_CURRENT, DATE_ARCHIVED, ARCHIVED_BY)
	SELECT
	  patid.PATIENT_ID,
	  patid.old_BIC,
	  meds.lastMedsCurr,
	  @datetime_now,
	  0
	FROM (
    SELECT patient_id, old_BIC
    FROM @patient_file_flags
    WHERE BIC_changed = 1  -- here, this flag from @patient_file_flags actually controls which BICs get archived. -JM
	) patid
	OUTER APPLY
	(select MAX(MEDS_CURRENT) lastMedsCurr FROM PATIENTS_Eligibility WHERE PATIENT_ID = patid.PATIENT_ID ) meds
*/
print 'Persisting personally-identifying data values that DHCS honors'

update p
set   
   p.DHCS_FIRST_NAME   = case when (trim(isnull(p.DHCS_FIRST_NAME,  N'')) = N'') then  pdhsf.FROM_DHCS_FIRST_NAME        else p.DHCS_FIRST_NAME  end
 , p.DHCS_LAST_NAME   = case when (trim(isnull(p.DHCS_LAST_NAME   ,N'')) = N'') then  pdhsf.FROM_DHCS_LAST_NAME         else p.DHCS_LAST_NAME   end
 , p.DHCS_MIDDLE_NAME = case when (trim(isnull(p.DHCS_MIDDLE_NAME ,N'')) = N'') then  pdhsf.FROM_DHCS_MIDDLE_NAME       else p.DHCS_MIDDLE_NAME end
 , p.DHCS_SEX         = case when (trim(isnull(p.DHCS_SEX         ,N'')) = N'') then  pdhsf.FROM_DHCS_SEX               else p.DHCS_SEX         end
 , p.DHCS_DOB         = case when (p.DHCS_DOB is null)                          then  convert(date,pdhsf.FROM_DHCS_DOB) else p.DHCS_DOB         end

from @patient_file_flags  as f     
join #ParsedDHCS_File     as pdhsf on pdhsf.Patient_ID = f.patient_id
join dbo.PATIENTS_Patient as p     on p.PATIENT_ID     = f.patient_id

where (
      (f.multiple_return = 0)   
  and (pdhsf.BIC != '') -- DHCS sometimes sends us rows with the eligibility info all N's, and where the BIC is blank.
                        -- As per Terry and Anton, we will save the DHCS name and info fields only when DHCS recognizes the submitted info and responds with a BIC.
                        -- JM 05 13 2019
)

/* Create MEDSCURR value for patients who didn't return in file */

declare @medscurr char(8)
set @medscurr = (select top 1 MEDSCURR from #ParsedDHCS_File)

SET @MAA_new_excel_filename += CONVERT(varchar,CONVERT(datetime,@medscurr,112), 102) + ' MAA-RMTS.xlsx'

print 'Creating new eligibility records'

/*  2a: Refresh patient eligibility from returned file data */

declare @inserted_ct bigint, @updated_ct bigint

/* Insert new records */ 

insert into PATIENTS_Eligibility
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

select
	ISNULL(pdhs.patient_id,psdc.PATIENT_ID), -- ???? ?
	--current month data
		isnull(MEDSCURR,@medscurr),
     --TODO: None of these ISNULLS need to be here!  These fields will never be null because they are populated by TRIMmed SUBSTRings from the raw file
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
		
	from 
		PATIENTS_StudentData_Correlation psdc 
		inner join @patient_file_flags pff 
			on psdc.PATIENT_ID = pff.patient_id 
			and pff.BIC_noReturn <> 1
		left outer join #ParsedDHCS_File pdhs 
			on psdc.PATIENT_ID = pdhs.Patient_ID 
		--left outer join PATIENTS_Eligibility pe -- TODO: does this need to be here??? 
			--on psdc.Patient_ID = pe.PATIENT_ID
	where psdc.FILE_ID = @file_number 
		and not exists 
			(
				select 1 
				from PATIENTS_Eligibility pe 
				where pe.PATIENT_ID = psdc.PATIENT_ID
			) -- TODO: there are better ways to do this...



set @inserted_ct = @@ROWCOUNT 

/* Update existing records */

print 'Updating current eligibility records'

update PATIENTS_Eligibility

	set 
	--current month data
		meds_current = isnull(CONVERT(datetime,MEDSCURR,112),@medscurr),
  --TODO: None of these ISNULLS need to be here!  These fields will never be null because they are populated by TRIMmed SUBSTRings from the raw file
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
		
from 
(
	select 
		pff.patient_id as patID,
		pdhs.* 
	from 
		@patient_file_flags pff 
		--inner join PATIENTS_Eligibility pe   -- TODO: does this need to be here???
		--	on pff.PATIENT_ID = pe.PATIENT_ID
		--	and pff.BIC_noReturn <> 1 /* If patient has a BIC and didn't return, we want to keep their previous eligibility results instead of potentially overwriting them with Ns. */
		left outer join #ParsedDHCS_File pdhs 
			on pff.PATIENT_ID = pdhs.Patient_ID where pff.BIC_noReturn <> 1

) as output_elig
where patients_eligibility.Patient_ID = output_elig.patID

set @updated_ct = @@ROWCOUNT 


select @inserted_ct as INSERT_COUNT,  @updated_ct as UPDATE_COUNT, @updated_ct - @inserted_ct as ADJ_UPD_CT
/* DHCS identifiers */

/* Fill BIC field */

update PATIENTS_Patient
set 
  patients_patient.BIC = BIC.pdhsBIC 
from 
(
	select 
		pdhs.BIC as pdhsBIC, 
		pDHS.Patient_ID 
	from 
		#ParsedDHCS_File pDHS 
		inner join @patient_file_flags pff 
			on pff.patient_id = pDHS.Patient_ID 
			--and pff.up_BIC = 1 
			and pff.BIC_noReturn <> 1
) as BIC
where PATIENTS_Patient.PATIENT_ID = BIC.Patient_ID AND BIC.pdhsBIC != ''


/*******************/
/* Error Reporting */
/*******************/

/* Report out multiple matches */

declare @multiple_match_count bigint =  (select COUNT(*) from @patient_file_flags pff where pff.multiple_return = 1)

if @multiple_match_count <> 0
BEGIN 

	declare @patient_multmatch_error_msg nvarchar(max)

	set @patient_multmatch_error_msg = 
		convert (varchar(50),@multiple_match_count) + ' patient records in file '+ convert(varchar(50),@file_number) +' were returned with an indicator that DHCS could not find an accurate match:' +CHAR(13)+CHAR(10)
		+ 'FILE_ID' + CHAR(9) +  'PATIENT_ID' + CHAR(9) +  'LAST_NAME' + CHAR(9) +   'FIRST_NAME' + CHAR(9) +  'DATE_OF_BIRTH' +  CHAR(9) +  'BIC' + CHAR(13)+CHAR(10)
	select @patient_multmatch_error_msg  = coalesce(@patient_multmatch_error_msg + CHAR(13)+CHAR(10), '') + convert(varchar(500),patient_data) 
	from (
		select 
			convert(varchar(500),@file_number) + CHAR(9) +  
			convert(varchar(500),pff.patient_id) + CHAR(9) +  
			convert(varchar(500),pp.LAST_NAME) + CHAR(9) +  
			convert(varchar(500),pp.FIRST_NAME) + CHAR(9)+  
			convert(varchar(500),pp.DATE_OF_BIRTH, 112) + CHAR(9) +  
			convert(varchar(500),pp.BIC) as patient_data 
		from 
			@patient_file_flags pff
			inner join PATIENTS_Patient pp 
				on pp.PATIENT_ID = pff.patient_id 
		where pff.multiple_return = 1
		) top_pats


    RAISERROR ('Some patient records in this file could not be accurately matched by DHCS. See logs for details', -- Message text.
               1, -- Severity.
               1 -- State.
               );

	print @patient_multmatch_error_msg
	print ''

END
	
/* Report out cases where a BIC didn't return in file */

declare @no_return_count bigint =  (select COUNT(*) from @patient_file_flags pff where pff.BIC_noReturn = 1)

if @no_return_count <> 0
BEGIN 

    RAISERROR ('Patient records in file did not return as expected. See individual file log.', -- Message text.
               1, -- Severity.
               1 -- State.
               );

    select *
	from 
		@patient_file_flags pff
		inner join PATIENTS_Patient pp 
			on pp.PATIENT_ID = pff.patient_id 
		where pff.BIC_noReturn = 1

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
update PATIENTS_StudentData_Correlation
set NOTE = 'COMPLETED - IN FILE'
where FILE_ID = @file_number
and PATIENT_ID in (select PATIENT_ID from #ParsedDHCS_File)



print 'Marking off "All-N" patients as complete'
--mark off not-returned students as complete
update PATIENTS_StudentData_Correlation
set NOTE = 'COMPLETED - NOT IN FILE'
where FILE_ID = @file_number
	and PATIENT_ID not in (select PATIENT_ID from #ParsedDHCS_File)
	
print 'Marking BIC-error patients for later reference and logging'

update PATIENTS_StudentData_Correlation
set 
	NOTE = NOTE + ' - BIC NORETURN'
from
	PATIENTS_StudentData_Correlation psdc
	inner join @patient_file_flags pff
		on pff.patient_id = psdc.PATIENT_ID 
		and psdc.FILE_ID = @file_number
		and pff.BIC_noReturn = 1
	
	
--mark file as done
print 'Marking file ' + CONVERT(varchar(max),@file_number) + ' as complete.'
update PATIENTS_StudentData_FileID
set 
	NOTE = 'COMPLETED', 
	DATE_RETURNED = getdate()   --Added Date_Returned update 20111209 JV--
where 
	FILE_NUMBER_ID = @file_number


declare @pdiID bigint=null;

--if ( 
--     (SELECT top 1 SUBSTRING(row,103,1) /* B_file_export_version */ FROM #FromDHCS_skim) = 'z'
--  ) begin

  SELECT top 1
  @pdiID = pdiID
  FROM PATIENTS_StudentData_FileID
  where 
	FILE_NUMBER_ID = @file_number

  IF ( @pdiID IS NOT NULL )
  begin
    UPDATE [dbo].[Patient_Data_Imports]
      SET
        [eligibilityMatchReturnFileReceived] = 1,
        [eligibilityMatchReturnFileReceivedOn] = GETDATE()
    WHERE id = @pdiID
  end

--end

/* Finished with run. Commit or rollback */



if @istestrun = 1
	BEGIN
		print 'Test run - rolling back transaction.'
		ROLLBACK TRANSACTION

    UPDATE [dbo].[Import_From_C_from_dhcs_ToSPED_Files]
    SET closed_SQL_transaction = SYSDATETIME(),
        committed_transaction = 0

    WHERE id = @log_num

       -- just now realized that this WHERE condition has been missing for quite some time.
       -- so every time there is a failed commit then it sets the logstamps to 0
       -- for all prior FROM-DHCS imports, going back to the dawn of time

       -- fortunately that flag isn't used for anything except manual diagnostics

	END
ELSE
	BEGIN
		print 'Not a test run - committing transaction.'
		
    COMMIT TRANSACTION
    
    UPDATE [dbo].[Import_From_C_from_dhcs_ToSPED_Files]
    SET closed_SQL_transaction = SYSDATETIME(),
        committed_transaction = 1
    WHERE id = @log_num

    /*  RMTS & SMAA  */

    EXEC sp_executesql @excelsql, N'@file_number bigint, @Client_First_9_of_NPI char(9)', @file_number=@file_number, @Client_First_9_of_NPI=@Client_First_9_of_NPI

    SET @MAA_new_excel_filename = @MAA_templatepath + @MAA_new_excel_filename
    EXEC [dbo].CopyFile null, @MAA_templatefile, @MAA_new_excel_filename

	END
		

UPDATE [dbo].[Import_From_C_from_dhcs_ToSPED_Files]
  SET done_processing = SYSDATETIME(),
      COUNT_in_return_file = s.in_return,
      COUNT_new_BIC = s.new_BIC,
      COUNT_BIC_changed = s.BIC_changed,
      COUNT_BIC_noReturn = s.no_return,
      COUNT_multiple_return = s.mult_return
FROM
  ( SELECT
      SUM(CASE WHEN in_return_file = 1 THEN 1 ELSE 0 END) in_return, -- you can't use SUM() on a bit field!  #spaghetti #yum
      SUM(CASE WHEN new_BIC = 1 THEN 1 ELSE 0 END) new_BIC,
      SUM(CASE WHEN BIC_changed = 1 THEN 1 ELSE 0 END) BIC_changed,
      SUM(CASE WHEN BIC_noReturn = 1 THEN 1 ELSE 0 END) no_return,
      SUM(CASE WHEN multiple_return = 1 THEN 1 ELSE 0 END) mult_return
    FROM @patient_file_flags) s
WHERE id = @log_num

END TRY

BEGIN CATCH

	 DECLARE @ErrorMessage NVARCHAR(4000);
   DECLARE @ErrorSeverity INT;
   DECLARE @ErrorState INT;

   SELECT 
        @ErrorMessage = ERROR_MESSAGE() + ', line ' + CAST(ERROR_LINE() AS varchar),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	if @@TRANCOUNT = 1  -- interesting... maybe we can use this syntax in the A routine, instead of the @open_trans bit
	BEGIN
		ROLLBACK TRANSACTION

    UPDATE [dbo].[Import_From_C_from_dhcs_ToSPED_Files]
    SET closed_SQL_transaction = SYSDATETIME(),
        committed_transaction = 0,
        error_str = @ErrorMessage
	END

  DROP TABLE if exists #FromDHCS_FileTable

  drop table if exists #ParsedDHCS_file
	
    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

END CATCH




DROP TABLE if exists #FromDHCS_FileTable

drop table if exists #ParsedDHCS_file

END
GO

GRANT EXECUTE ON  [dbo].[FROM_DHCS] TO [webuser]
GO