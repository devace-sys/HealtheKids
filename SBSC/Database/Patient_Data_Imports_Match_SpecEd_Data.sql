
/* Note: This is a refactor of the previous version of this sproc.  It has some unconventional
 * practices that have not been altered in this refactor to maximize compatibility with the 
 * calling routines.  The biggest change was to prematch rows BEFORE a transaction was open
 * AND to match only on SSID and DOB. 
 */

USE spedmon
GO

/*-------------------------------
 * Exists/Drop (cleanup)
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_SpecEd_Data_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Match_SpecEd_Data_Core
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Match_SpecEd_Data') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Match_SpecEd_Data
GO

/*-------------------------------
 * Create new
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Match_SpecEd_Data] (
    @userID                         bigint
  , @userGroup                      int
  , @userRank                       int
  , @clientID                       bigint
  , @patientDataImportID            bigint

  , @testMode                       bit
  , @isTestMode                     bit output
  , @requiresRollback               bit output

  , @importResultsJSON              varchar(max) output
  , @importErrorsJSON               varchar(max) output
  , @completedNormally              bit          output
)    
AS 

BEGIN


set nocount on

declare @tranOpen               as bit    = 0
declare @okToCommitData         as bit    = 0      /* TODO: If this value is 0 then rollback the changes at the end of this routine. */
declare @structuredDataImportID as bigint = null
declare @fromA5_import_id       as bigint = null
declare @committingChanges      as bit    = 0                                          

declare @incomingSpEdRows as table (
    ssid      nvarchar(50)
  , dob       datetime
  , id        bigint
  , patID     bigint  
)

set @isTestMode        = @testMode;
set @requiresRollback  = @testMode;
set @completedNormally = 0
set @importResultsJSON = '{}'
set @importErrorsJSON  = '{}'
set @tranOpen          = 0
set @okToCommitData    = 0

BEGIN TRY

/* Get required reference ids for the various tables we use for spEd data */

select top 1  
    @structuredDataImportID = pdi.structuredDataImportID
  , @fromA5_import_id       = pdi.importFromFileReferenceID
  , @okToCommitData         = pdi.okToCommitData
from dbo.Patient_Data_Imports as pdi
where ( 
      (pdi.id = @patientDataImportID)
  and (pdi.clientID = @clientID)
)

/* Make sure the import from a5 services file exists */

if not exists (
  select top 1
    t1.id
  FROM dbo.[Import_From_A.5_SERVICES_From_Client_Files] as t1
  WHERE 
      (t1.id                     = @fromA5_import_id)
  and (t1.structuredDataImportID = @structuredDataImportID)
  and (t1.patientDataImportID    = @patientDataImportID)
)
begin
  RAISERROR(N'Unknown error; cannot find or identify the import being processed', 11, 1)
end

/* Handle test mode logic */

if (@isTestMode = 0)
begin
  if (@okToCommitData = 0)
    set @isTestMode = 1
  else
    set @isTestMode = 0
end
  										 
/* Pull in a copy of the incoming rows and convert the data so we can match as quickly as possible */

insert into @incomingSpEdRows (ssid, dob, id)
select 
    ssid = convert(nvarchar(50),(trim(isnull(t2.[Student SSID],''))))  /* Match datatype and size of ssid field in patients_patient */
  , dob  = convert(datetime,t2.DOB)                                    /* Match datatype and size of dob field in patients_patient */
  , id   = t2.ID 
from dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as t2
where 
  (t2.File_import_log_entry = @fromA5_import_id)

/* Attempt to match against existing data.  We match against SSID and dob for existing patient 
 * records that are associated with the client.
 */

update t1
  set t1.patID = pap.PATIENT_ID
from @incomingSpEdRows as t1
join dbo.PATIENTS_PATIENT as  pap on  (pap.CSIS          = t1.SSID)
                                  and (pap.DATE_OF_BIRTH = t1.dob)
						          and (pap.ACTIVE        = N'y')

join dbo.PATIENTS_Client  as pc on  pc.PATIENT_ID = pap.PATIENT_ID
                                and pc.CLIENT_ID  = @clientID
where ( 
  (t1.SSID  !=  N'') /* Dont match against empty SSIDs */
)

/* TODO: We could add some reporting logic here */

/* Note we are "opening" a transaction */

UPDATE [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
SET
  opened_SQL_transaction = GETDATE()
WHERE (id = @fromA5_import_id)

/* If we are actually doing it */

if (@requiresRollback = 0)
begin

  /* Set a status flag we will use later */
  
  set @committingChanges = 1
  
  begin transaction
    set @tranOpen = 1

    UPDATE dfr
    SET
        dfr.Patient_ID               = t1.patID
      , dfr.Patient_ID_orig          = t1.patID
      , dfr.Matched_Pat_ID_timestamp = GETDATE()
    from @incomingSpEdRows as t1
    join dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] as dfr on dfr.id = t1.id
	where 
	  (t1.patID is not null)

  commit transaction
  set @tranOpen = 0
end
else
/* If we are NOT doing it */
begin
  set @committingChanges = 0 /* Set the status flag we will use later */
end

/* Note that we "closed" the transaction and if we actually committed the changes */

UPDATE [dbo].[Import_From_A.5_SERVICES_From_Client_Files]
SET
    closed_SQL_transaction = GETDATE()
  , committed_transaction  = @committingChanges
WHERE 
  (id = @fromA5_import_id)

set @completedNormally = 1
return (0)

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
     rollback transaction
     set @tranOpen = 0
   end

   set @completedNormally = 0
       
  return (0)      
    
END CATCH    

return (0)

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Match_SpecEd_Data] TO [webuser]
go


