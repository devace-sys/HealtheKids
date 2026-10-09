USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save_Or_Reprocess') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save_Or_Reprocess
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save_Or_Reprocess] (
    @userID                       int
  , @userGroup                    int
  , @userRank                     int
  , @clientID                     bigint
  , @importDataJSON               varchar(max)
  , @reprocessSavedImportData     bit = 0
  , @editDelReason                varchar(7000)
  , @validateRec                  bit
  , @saveType                 int
  , @recID                    bigint
  , @msgNoRec                 varchar(1000)
  , @msgNoEdit                varchar(1000)
  , @msgDupRec                varchar(1000)
  , @msgDataError             varchar(1000)
  , @msgNotActive             varchar(1000)
  , @recordID                 bigint        output
  , @spDetails                varchar(8000) output
  , @jsonData                 varchar(max)  output
)

AS
BEGIN

SET NOCOUNT ON


DECLARE @ErrorMessage                               as NVARCHAR(4000) = ''
DECLARE @ErrorSeverity                              as INT
DECLARE @ErrorState                                 as INT
declare @noIssues                                   as int = 1
declare @tranOpen                                   as bit = 0
declare @today                                      as datetime
declare @structuredDataImportID                     as bigint
declare @patientsPromisedServicesCDEAuditsCurrentID as bigint = null

declare @pats as table (
      IDX                               int identity(1,1)
    , ROW_NUM                           int
    , LAST_NAME                         varchar(255)
    , FIRST_NAME                        varchar(255)
    , SSID                              nvarchar(50)
    , STUDENT_ID                        nvarchar(50)
    , PATIENT_ID                        bigint    
    , PATIENT_FOUND                     bit         default(0)	
	, HAS_IMPORT_ISSUES                 bit         default(0)
	, IMPORT_ISSUES                    varchar(max) default(0)

  unique clustered (IDX)
)


declare @maxIdxPats                   as int           = 0
declare @currIdxPats                  as int           = 1
declare @currPatID                    as bigint        = null
declare @patFound                     as bit           = 0
declare @rowNum                       as int           = 0
declare @lastName                     as varchar(255)  = ''
declare @firstName                    as varchar(255)  = ''
declare @spDetailMsg                  as varchar(1000) = ''
declare @savesAttempted               as int           = 0
declare @savesOK                      as int           = 0
declare @spSaveDetails                as varchar(8000) = ''
declare @spSaveRecID                  as bigint        = 0
declare @spSaveType                   as int
declare @saveIssueCount               as int           = 0

/*############################################################################
 *# Init
 *############################################################################*/

set @spDetails  = ''
set @recordID   = 0
set @jsonData   = '{}'
set @tranOpen   = 0
set @today      = getdate()


BEGIN TRY

/*############################################################################
 *# Exit if key values are not passed
 *############################################################################*/

IF (@clientID IS NULL) RAISERROR ('clientID is required',   11, 1)

/*############################################################################
 *# Get current audit header record id and last structured data import id
 *############################################################################*/

set @patientsPromisedServicesCDEAuditsCurrentID = null

select top 1
   @patientsPromisedServicesCDEAuditsCurrentID = t1.id 
 , @structuredDataImportID                     = t1.lastStructuredDataImportID
from dbo.Patients_Promised_Services_CDE_Audits_Current as t1
where (
      (t1.clientID = @clientID)
  and (t1.active = 1)
)

if (@patientsPromisedServicesCDEAuditsCurrentID is null)
begin
  RAISERROR ('No audit period record found.  Please save the audit period prior to import.', 11, 1) 
end

/*############################################################################
 *# Load previous structured data import data if required
 *############################################################################*/

if (@reprocessSavedImportData = 1)
begin
  set @recordID = @structuredDataImportID
  if (@recordID is null)
  begin
    set @recordID = 0
    RAISERROR ('No previous import data found.  Please reupload file.', 11, 1) 
  end

  select top 1 
    @importDataJSON = sdi.importDataJSON 
  from dbo.Structured_Data_Imports as sdi
  where 
    (sdi.id = @structuredDataImportID)   
	
end

/*############################################################################
 *# Save structured data import data if required
 *############################################################################*/

if ( @validateRec = 0 )
BEGIN
  
  if (@reprocessSavedImportData = 0)
  begin

    BEGIN TRANSACTION

    set @tranOpen = 1

    exec dbo.Structured_Data_Imports_Save_Core
       @userID
    ,  @userGroup
    ,  @userRank
    ,  @clientID
    ,  @importDataJSON
    ,  1 /* @skipDupCheck*/
    ,  @editDelReason
    ,  @validateRec
    ,  @saveType
    ,  @recID
    ,  @msgNoRec
    ,  @msgNoEdit
    ,  @msgDupRec
    ,  @msgDataError
    ,  @msgNotActive
    ,  @spDetails				OUTPUT
    ,  @structuredDataImportID   OUTPUT

    COMMIT TRANSACTION

    set @tranOpen = 0
    set @recordID = @structuredDataImportID
  
  end

END

/*############################################################################
 *# Parse imported data
 *############################################################################*/

insert into @pats (
    ROW_NUM
  , LAST_NAME
  , FIRST_NAME
  , SSID
)
select
    t1.ROW_NUM
  , LAST_NAME  = trim(isnull(t1.LAST_NAME,''))
  , FIRST_NAME = trim(isnull(t1.FIRST_NAME,''))
  , SSID       = trim(isnull(t1.SSID,N''))
FROM OPENJSON( @importDataJSON, '$.structuredDataRows' )
WITH (
	  [ROW_NUM]     int           '$."rowNumIn"'
	, [LAST_NAME]   varchar(255)  '$."rowData"."lastName"'
	, [FIRST_NAME]  varchar(255)  '$."rowData"."firstName"'
	, [SSID]        nvarchar(50)  '$."rowData"."ssid"'
) as t1

/*############################################################################
 *# First match patient records by SSID
 *############################################################################*/

update pats
  set pats.PATIENT_ID = pap.PATIENT_ID
from @pats                as pats
join dbo.PATIENTS_Patient as pap on (pap.CSIS = pats.SSID) and (pap.ACTIVE = N'Y')
join dbo.PATIENTS_Client  as pac on (pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID)
where (
      (pats.PATIENT_ID is null)
  and (len(pats.SSID) > 0)
)

/*############################################################################
 *# Update flags
 *############################################################################*/

update @pats
  set PATIENT_FOUND = 1 
where (PATIENT_ID is not null)

update @pats
  set 
    HAS_IMPORT_ISSUES = 1
  , IMPORT_ISSUES = 'This student was not found in SpEdCare.'
where (PATIENT_ID is null)

/*############################################################################
 *# Get data needed for loops
 *############################################################################*/

set @currIdxPats = 1
select @maxIdxPats = MAX(IDX) FROM @pats
set @currIdxPats = 1

/*############################################################################
 *# For each patient found
 *############################################################################*/
 
while (@currIdxPats <= @maxIdxPats)
begin
  
  /*##################################
   *# Reset working vars
   *##################################*/

  set @currPatID                        = null

  /*##################################
   *# Get patient id and if its ok
   *# to add
   *##################################*/
  
  select top 1 
      @currPatID = pats.PATIENT_ID 
  from @pats as pats 
  where 
    (pats.IDX = @currIdxPats)

  /*##################################
   *# If OK to add patient
   *##################################*/

	set @savesAttempted = 0
	set @savesOK        = 0
    
  /*############################################################################
   *# Add 
   *############################################################################*/

  BEGIN TRY

    declare @currSSID nvarchar(50) = ''
    declare @currCSVRownum bigint
	   
    SELECT
      @currPatID = ISNULL( PATIENT_ID , 0 )  ,
      @currSSID  = ISNULL( SSID, '' )   ,
      @currCSVRowNum = ROW_NUM
    FROM   @pats
    WHERE  IDX = @currIdxPats

    if ( ISNULL( @currPatID, 0) = 0)
      RAISERROR (
          'Patient not found.'
        ,
        11,
        1
      )

    exec [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_Save]
        @userID 
      , @userGroup
      , @userRank
      , @clientID
      , @currPatID
      , @validateRec
      , @spSaveRecID                   OUTPUT
      , @spSaveDetails                 OUTPUT
      , @spSaveType                    OUTPUT

    
    END TRY
    BEGIN CATCH
    
      SET @ErrorMessage = ERROR_MESSAGE()
      SET @noIssues = 0    
      SET @ErrorMessage = REPLACE( @ErrorMessage, ',', '');
	
	  /*
      set @spDetails =
            dbo.UPDATE_DETAILS(
              @spDetails
              , 'Issue adding row number ' + CAST( @currCSVRowNum as varchar ) + ' ' + 'from your file (the student with SSID ' + CAST( ISNULL( @currSSID, '' ) as varchar ) + '). ' + @ErrorMessage
              , dbo.CONST_RET_WARN()
        ) ;
		*/
	
	    update @pats
	    set 
		    HAS_IMPORT_ISSUES = 1
		  , IMPORT_ISSUES     = @ErrorMessage
		where (IDX = @currIdxPats)
  
    END CATCH
    
  set @currIdxPats = @currIdxPats + 1

end /* pats*/

/*############################################################################
 *# Generate JSON for reporting/feedback purposes and exit
 *############################################################################*/

set @jsonData = convert(varchar(max),(select * from @pats FOR JSON AUTO))

declare @lastImportIssueCount as int = 0

select @lastImportIssueCount = count(idx) from @pats where (HAS_IMPORT_ISSUES = 1)

/*############################################################################
 *# Update audit header record
 *############################################################################*/

update dbo.Patients_Promised_Services_CDE_Audits_Current
set 
    lastImportIssueCount             = @lastImportIssueCount
  , lastStructuredDataImportID       = @structuredDataImportID
  , lastPatientDataImportResultsJSON = @jsonData
  , lastModified                     = @today
  , lastModifiedBy                   = @userID
where (id = @patientsPromisedServicesCDEAuditsCurrentID)

RETURN(0)

END TRY
BEGIN CATCH


  /*-------------------------------
   * If we end up here something
   * went wrong.  Cancel any pending
   * transactions and return any
   * error any error messages to
   * the caller
   *------------------------------*/

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end


  -- Error or raise error with severity 11 to 19 will be caught here

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

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_Data_Imports_Save_Or_Reprocess] TO [webuser]
GO
