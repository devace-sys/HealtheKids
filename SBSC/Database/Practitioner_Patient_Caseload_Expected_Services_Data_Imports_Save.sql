USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Caseload_Expected_Services_Data_Imports_Save') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.Practitioner_Patient_Caseload_Expected_Services_Data_Imports_Save
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Practitioner_Patient_Caseload_Expected_Services_Data_Imports_Save] (
    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
  , @clientID          bigint
  , @pracID            bigint
  , @importDataJSON    varchar(max)
  , @editDelReason     varchar(7000)
  , @validateRec       bit
  , @saveType          int
  , @recID             bigint
  , @msgNoRec          varchar(1000)
  , @msgNoEdit         varchar(1000)
  , @msgDupRec         varchar(1000)
  , @msgDataError      varchar(1000)
  , @msgNotActive      varchar(1000)
  , @recordID          bigint        output
  , @spDetails         varchar(8000) output
  , @jsonData          varchar(max)  output
)
AS
BEGIN

SET NOCOUNT ON

declare @tranOpen               as bit = 0
declare @today                  as datetime
declare @structuredDataImportID as bigint
declare @hasNewSvcs             as bit          = 0
declare @newSvcsJSON            as varchar(max) = '[]'

declare @pats as table (
      IDX                               int identity(1,1)
    , ROW_NUM                           int
	, LAST_NAME                         varchar(255)
	, FIRST_NAME                        varchar(255)
	, SSID                              nvarchar(50)
    , STUDENT_ID                        nvarchar(50)
    , PATIENT_ID                        bigint    
	, PATIENT_FOUND                     bit            default(0)
--	, CASELOAD_SAVES_ATTEMPTED          int            default(0)
--	, CASELOAD_SAVES_OK                 int            default(0)
--	, CASELOAD_EXPECTED_SVCS_SP_DETAILS varchar(8000)  default ''
--    , CASELOAD_EXPECTED_SVCS_REC_ID     bigint         default 0
  unique clustered (IDX)
)

declare @patsCSV as varchar(max) = ''

declare @maxIdxPats                   as int           = 0
declare @currIdxPats                  as int           = 1

declare @patID                        as bigint        = null
declare @patFound                     as bit           = 0
declare @rowNum                       as int           = 0
declare @lastName                     as varchar(255)  = ''
declare @firstName                    as varchar(255)  = ''
declare @spDetailMsg                  as varchar(1000) = ''
declare @numPatsFound                 as int           = 0

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
IF (@pracID   IS NULL) RAISERROR ('pracID is required',     11, 1)

/*############################################################################
 *# Save structured data import data
 *############################################################################*/

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
 ,  @structuredDataImportID OUTPUT

COMMIT TRANSACTION
set @tranOpen = 0
set @recordID = @structuredDataImportID

/*############################################################################
 *# Parse imported data
 *############################################################################*/

insert into @pats (
    ROW_NUM
  , LAST_NAME
  , FIRST_NAME
  , SSID
  , STUDENT_ID
)
select
    t1.ROW_NUM
  , LAST_NAME  = trim(isnull(t1.LAST_NAME,''))
  , FIRST_NAME = trim(isnull(t1.FIRST_NAME,''))
  , SSID       = trim(isnull(t1.SSID,N''))
  , STUDENT_ID = trim(isnull(t1.STUDENT_ID,N''))    
FROM OPENJSON( @importDataJSON, '$.structuredDataRows' )
WITH (
	  [ROW_NUM]     int           '$."rowNumIn"'
	, [LAST_NAME]   varchar(255)  '$."rowData"."lastName"'
	, [FIRST_NAME]  varchar(255)  '$."rowData"."firstName"'
	, [SSID]        nvarchar(50)  '$."rowData"."ssid"'
	, [STUDENT_ID]  nvarchar(50)  '$."rowData"."studentID"'
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
 *# If we could not find by SSID then attempt to find by student id
 *############################################################################*/

update pats
  set pats.PATIENT_ID = pap.PATIENT_ID
from @pats                as pats
join dbo.PATIENTS_School  as pas on (pas.STUDENT_ID = pats.STUDENT_ID)
join dbo.PATIENTS_Patient as pap on (pas.PATIENT_ID = pas.PATIENT_ID) and (pap.ACTIVE = N'Y')
join dbo.PATIENTS_Client  as pac on (pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pap.PATIENT_ID)
where (
      (pats.PATIENT_ID is null)
  and (len(pats.STUDENT_ID) > 0)
  and (pats.LAST_NAME  = pap.LAST_NAME)
  and (pats.FIRST_NAME = pap.FIRST_NAME)
)

/*############################################################################
 *# Update flags
 *############################################################################*/

update @pats
  set PATIENT_FOUND = 1 
where (PATIENT_ID is not null)

/*############################################################################
 *# Get number of pats found
 *############################################################################*/

select @numPatsFound = count(p.IDX) from @pats as p where (p.PATIENT_FOUND = 1)

/*############################################################################
 *# Get data needed for loops
 *############################################################################*/

set @currIdxPats = 1
select @maxIdxPats = MAX(IDX) FROM @pats

/*############################################################################
 *# Report out on patients that will not be added to caseload because
 *# no active record was found in spEdCare 
 *############################################################################*/

set @currIdxPats = 1

while (@currIdxPats <= @maxIdxPats)
begin
  
  set @patFound = 0

  select top 1 
	  @patFound              = pats.PATIENT_FOUND     
	, @lastName              = pats.LAST_NAME
	, @firstName             = pats.FIRST_NAME
	, @rowNum                = pats.ROW_NUM
  from @pats as pats 
  where 
    (pats.IDX = @currIdxPats)
  
  if (@patFound = 0)
  begin
     set @spDetailMsg = 'Row ' + convert(varchar(50),@rowNum) + ' ' + @firstName + ' ' + @lastName + ' will not be added to your caseload'
     set @spDetailMsg = @spDetailMsg + ' because there is no active matching student record in SpEdCare.'	
	 set @spDetails = dbo.UPDATE_DETAILS (@spDetails,@spDetailMsg,[dbo].[CONST_RET_WARN]())	 
  end

  set @currIdxPats = @currIdxPats + 1
  
end

/*############################################################################
 *# If we are validating go ahead and exit
 *############################################################################*/

if (@validateRec = 1)
begin

  /*------------------------------*/
  /* Generate JSON for reporting  */
  /* and feedback and exit        */
  /*------------------------------*/

  set @jsonData = convert(varchar(max),(select * from @pats FOR JSON AUTO))
  return(0)
end

/*############################################################################
 *# If there is nothing to do 
 *############################################################################*/

if (@numPatsFound = 0)
begin

  /*############################################################################
   *# Generate JSON for reporting/feedback purposes and exit
   *############################################################################*/

  set @jsonData = convert(varchar(max),(select * from @pats FOR JSON AUTO))
  return(0)
end

/*############################################################################
 *# Generate CSV of incoming patients
 *############################################################################*/

select 
  @patsCSV = STRING_AGG(CONVERT(varchar(max),p.PATIENT_ID),',')
from @pats as p
where 
  (p.PATIENT_FOUND = 1)

/*############################################################################
 *# Add any pats found and possible svcs to caseload 
 *############################################################################*/

begin transaction 
set @tranOpen = 1

 
/*############################################################################
 *# Update existing caseload services.  We do this so we can have accurate
 *# matching in the possible new svcs routine.
 *############################################################################*/

exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_UPDATE_PLAN_INFO_ALL_CORE 
    @userID
  , @clientID
  , @pracID
  , null --@patID
  , null -- @spEdSvcCode 
  , 0    --@updateToNewerPlan
  , 0 --@validateRec 
  , @spDetails     OUTPUT
  , @recordID      OUTPUT 

/*############################################################################
 *# Find possible new svcs
 *############################################################################*/

set @hasNewSvcs = 0
set @newSvcsJSON = '[]'

exec dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_GET_JSON_CORE
    @userID
  , @userGroup
  , @userRank 
  , @clientID 
  , @pracID 
  , @patsCSV
  , 0 -- @loadCurrentCaseload 
  , @hasNewSvcs OUTPUT
  , @newSvcsJSON OUTPUT

/*############################################################################
 *# If there is anything to add. Note: It is possible that there may be nothing
 *# to add for example if caseload was not cleared and has exact same data 
 *# currently as what is being imported then there can be nothing to add.
 *############################################################################*/

if (@hasNewSvcs = 1)
begin

declare @hasDataPPCES  as bit          = 0
declare @jsonDataPPCES as varchar(max) = '[]'

  /*############################################################################
   *# Call save multiple caseload entries routine 
   *# Note: We save EVERYTHING including cases were row was NOT preselected
   *############################################################################*/

   exec dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SAVE_MULTIPLE_CORE 
      @userID
    , @userGroup
    , @userRank 
    , @clientID 
    , @pracID 
    , 0 --@saveSelectedOnly
    , @newSvcsJSON 
    , @editDelReason 
    , 0 --@validateRec 
    , @saveType 
    , @recID 
    , @MsgNoRec 
    , @MsgNoEdit 
    , @MsgDupRec 
    , @MsgDataError
    , @MsgNotActive
    , @spDetails     OUTPUT
    , @recordID      OUTPUT
	, @hasDataPPCES  OUTPUT 
	, @jsonDataPPCES OUTPUT

end /* There are new svcs to add*/
 
commit transaction
set @tranOpen = 0
 
/*############################################################################
 *# Generate JSON for reporting/feedback purposes and exit
 *############################################################################*/

set @jsonData = convert(varchar(max),(select * from @pats FOR JSON AUTO))
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

  DECLARE @ErrorMessage  AS NVARCHAR(4000) = ''
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

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

GRANT EXECUTE ON  [dbo].[Practitioner_Patient_Caseload_Expected_Services_Data_Imports_Save] TO [webuser]
GO
