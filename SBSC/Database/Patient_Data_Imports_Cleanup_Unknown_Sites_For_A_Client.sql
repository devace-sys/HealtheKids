USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Cleanup_Unknown_Sites_For_A_Client') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Cleanup_Unknown_Sites_For_A_Client
GO


/*-------------------------------
 * Create new
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Cleanup_Unknown_Sites_For_A_Client] (
  @clientID  bigint
)
AS

BEGIN

set nocount on

declare @tranOpen                          as bit          = 0
declare @unknownSiteID                     as bigint       = -1
declare @numPatientsWithCurrentSiteUnknown as int          = 0
declare @numPatientsWithPreviousSiteKnown  as int          = 0
declare @msgStr                            as varchar(512) = ''

declare @patientSiteData as table (
    PATIENT_ID        bigint
  , RANKING           int
  , PATIENT_SCHOOL_ID bigint
  , SITE_ID           bigint
  , START_DATE        datetime
  , END_DATE          datetime
  , IS_UNKNOWN_SCHOOL bit
unique clustered (PATIENT_ID, RANKING, PATIENT_SCHOOL_ID)
)

declare @patientsWithCurrentSiteUnknown as table (
    PATIENT_ID                   bigint
  , PATIENT_SCHOOL_ID_UNKNOWN    bigint
  , HAS_PREVIOUS_KNOWN_SITE      bit default(0)
  , PATIENT_SCHOOL_ID_KNOWN      bigint
unique clustered (PATIENT_ID)
)

/*############################################################################
 *# Early exit if client is not provided
 *############################################################################*/

if (@clientID is null) return

select 
  @msgStr = 'Cleaning up patient / unknown site assocations for ' + clc.CLIENT_NAME 
from dbo.CLIENTS_Client as clc
where (clc.CLIENT_ID = @clientID)

exec dbo.PRINT_STATUS_MESSAGE @msgStr

BEGIN TRY

/*############################################################################
 *# Init
 *############################################################################*/

set @tranOpen          = 0
set @unknownSiteID     = isnull(dbo.GET_SITE_ID_UNKNOWN_SCHOOL(@clientID),-1)

/*############################################################################
 *# Early exit if no unknown site id is defined for client
 *############################################################################*/

if (@unknownSiteID = -1) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'No unknown site id setup for this client'
  return
end

/*############################################################################
 *# Get patient site data for given client along with ranking data 
 *# RANKING = 1 is current site for patient
 *############################################################################*/

insert into @patientSiteData (
    PATIENT_ID       
  , RANKING
  , PATIENT_SCHOOL_ID
  , SITE_ID   
  , START_DATE
  , END_DATE  
  , IS_UNKNOWN_SCHOOL
)
select    
    ps.PATIENT_ID
  , RANKING = RANK() over (PARTITION BY ps.PATIENT_ID ORDER BY ps.PATIENT_ID asc, isnull(ps.[END_DATE], dbo.CONST_MAX_DATETIME()) desc, ps.PATIENT_SCHOOL_ID desc)
  , ps.PATIENT_SCHOOL_ID
  , ps.SITE_ID
  , ps.START_DATE
  , ps.END_DATE
  , IS_UNKNOWN_SCHOOL = iif ((ps.SITE_ID = @unknownSiteID),1,0)

from dbo.CLIENTS_Client  as clc
join dbo.SITES_Site      as ss on ((ss.SITE_CLIENT_ID = clc.CLIENT_ID) and (ss.SITE_ID is not null))
join dbo.PATIENTS_School as ps on ((ps.SITE_ID = ss.SITE_ID) and (ps.PATIENT_ID is not null) and (ps.PATIENT_SCHOOL_ID is not null)) /* For index */
where 
  (clc.CLIENT_ID = @clientID)

/*############################################################################
 *# Find all patients in this set of data where their current site is 
 *# unknown
 *############################################################################*/

insert into @patientsWithCurrentSiteUnknown (
   PATIENT_ID
 , PATIENT_SCHOOL_ID_UNKNOWN
)
select distinct 
    psd.PATIENT_ID 
  , PATIENT_SCHOOL_ID_UNKNOWN = psd.PATIENT_SCHOOL_ID
from @patientSiteData as psd 
where ((psd.RANKING = 1) and (psd.IS_UNKNOWN_SCHOOL = 1))

/*############################################################################
 *# Out of these patients, find the ones where their previous site
 *# (RANKING = 2) was not unknown
 *############################################################################*/

update t1
set 
    t1.HAS_PREVIOUS_KNOWN_SITE = 1
  , t1.PATIENT_SCHOOL_ID_KNOWN = t2.PATIENT_SCHOOL_ID
from @patientsWithCurrentSiteUnknown as t1
join @patientSiteData                as t2 on t2.PATIENT_ID = t1.PATIENT_ID
where ((t2.RANKING = 2) and (t2.IS_UNKNOWN_SCHOOL = 0))

/*############################################################################
 *# Get counts
 *############################################################################*/

/*-------------------------------
 * Count of all patients where
 * current site is unknown
 *------------------------------*/

select @numPatientsWithCurrentSiteUnknown = count(t1.PATIENT_ID) from @patientsWithCurrentSiteUnknown as t1

/*-------------------------------
 * Count of these patients where
 * previous site is known
 *------------------------------*/

select @numPatientsWithPreviousSiteKnown  = count(t1.PATIENT_ID) from @patientsWithCurrentSiteUnknown as t1 where (t1.HAS_PREVIOUS_KNOWN_SITE = 1)

set @msgStr = 'Number of patients with current site unknown ' + convert(varchar(50),@numPatientsWithCurrentSiteUnknown)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Number of patients with previous site known ' + convert(varchar(50),@numPatientsWithPreviousSiteKnown)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*############################################################################
 *# If we can set the current site to a previously known site, then do it
 *############################################################################*/

if (@numPatientsWithPreviousSiteKnown > 0)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'There are patients where we can revert back to a previously known site'

  begin transaction
  set @tranOpen = 1

  /*-------------------------------
   * Delete current unknown
   *------------------------------*/
  
  exec dbo.PRINT_STATUS_MESSAGE 'Deleting unknown school code assocations'

  delete ps
  from @patientsWithCurrentSiteUnknown as t1
  join dbo.PATIENTS_School             as ps on ps.PATIENT_SCHOOL_ID = t1.PATIENT_SCHOOL_ID_UNKNOWN
  where (t1.HAS_PREVIOUS_KNOWN_SITE = 1)

  /*-------------------------------
   * Set previously known to
   * current
   *------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'Setting previously known school code assocations to current site'

  update ps
    set ps.END_DATE = null
  from @patientsWithCurrentSiteUnknown as t1
  join dbo.PATIENTS_School             as ps on ps.PATIENT_SCHOOL_ID = t1.PATIENT_SCHOOL_ID_KNOWN
  where (t1.HAS_PREVIOUS_KNOWN_SITE = 1)

  commit transaction
  set @tranOpen = 0

end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'There is nothing we can cleanup'
end

/*############################################################################
 *# Done
 *############################################################################*/

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

  DECLARE @ErrorMessage  AS NVARCHAR(4000)
  DECLARE @ErrorSeverity AS INT
  DECLARE @ErrorState    AS INT

  SELECT  @ErrorMessage  = ERROR_MESSAGE(),
          @ErrorSeverity = ERROR_SEVERITY(),
          @ErrorState    = ERROR_STATE()

  if (@ErrorSeverity > 11)
  set @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'

  -- Reraise the error so it returns back to the server

  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)

END CATCH
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Cleanup_Unknown_Sites_For_A_Client] TO [webuser]
