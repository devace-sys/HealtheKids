USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_FIND_RECORDS_TO_DEACTIVATE_DUE_TO_INACTIVITY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_FIND_RECORDS_TO_DEACTIVATE_DUE_TO_INACTIVITY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENT_FIND_RECORDS_TO_DEACTIVATE_DUE_TO_INACTIVITY_CORE] (
   @clientID                as bigint
 , @numOfMonthsOfInactivity as int      
)    

RETURNS @pats TABLE (
    PATIENT_ID                                             bigint
  , DATE_OF_BIRTH                                          datetime
  , PATIENT_CURRENT_AGE_IN_YEARS                           int
  , DATE_CREATED                                           datetime
  , LAST_UPDATED                                           datetime
  , LASTPOP                                                datetime
  , CREATED_MONTHS_AGO                                     int
  , LAST_POP_MONTHS_AGO                                    int
  , LATEST_PROMISED_SERVICE_DATA_START_DATE_MONTHS_AGO     int
  , LAST_SERVICE_RECORD_ENTRY_MONTHS_AGO                   int
  , NUM_OF_ACTIVE_CASELOAD_EXPECTED_SERVICE_ENTRIES        int default (0)
unique clustered (PATIENT_ID)
)     
AS    
BEGIN    

declare @refDate as datetime = getdate()

if (@clientID is null) return
if (@numOfMonthsOfInactivity is null) set @numOfMonthsOfInactivity = 15
if (@numOfMonthsOfInactivity < 15)    set @numOfMonthsOfInactivity = 15


/* Get active patients, add to list, and calculate last pop months ago*/

insert into @pats (
    PATIENT_ID
  , DATE_OF_BIRTH
  , PATIENT_CURRENT_AGE_IN_YEARS
  , DATE_CREATED
  , LAST_UPDATED
  , LASTPOP
  , CREATED_MONTHS_AGO
  , LAST_POP_MONTHS_AGO
)
select 
    pap.PATIENT_ID
  , pap.DATE_OF_BIRTH
  , PATIENT_CURRENT_AGE_IN_YEARS = datediff(year,pap.DATE_OF_BIRTH, @refDate)
  , pap.DATE_CREATED
  , pap.LAST_UPDATED
  , pap.LASTPOP
  , CREATED_MONTHS_AGO  = datediff(month,pap.DATE_CREATED, @refDate)
  , LAST_POP_MONTHS_AGO = datediff(month,pap.LASTPOP,      @refDate)
from dbo.PATIENTS_Client  as pac
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
where (
      (pac.CLIENT_ID = @clientID)
  and (pap.ACTIVE = N'Y')
)

/* Remove patients from list where they have been recently added and have not had a population file update */

delete from @pats 
where ( 
      (CREATED_MONTHS_AGO <= @numOfMonthsOfInactivity)
  and (isnull(LASTPOP,dbo.CONST_MIN_DATETIME_GREGORIAN()) = dbo.CONST_MIN_DATETIME_GREGORIAN())
)

/* Remove patients from list where we have received recent population file updates*/

delete from @pats where (LAST_POP_MONTHS_AGO <= @numOfMonthsOfInactivity)

/* Determine how many months since latest start date in promised services */

update pats
  set pats.LATEST_PROMISED_SERVICE_DATA_START_DATE_MONTHS_AGO = datediff(month,pps2.LATEST_START_DATE, @refDate)
from @pats as pats
outer apply (
  select 
    LATEST_START_DATE = max(pps1.startDate)
  from dbo.PATIENTS_Promised_Services as pps1
  where 
    (pps1.patID = pats.PATIENT_ID)
) as pps2

/* Remove patients from list where we have received recent sped service file updates*/

delete from @pats where (LATEST_PROMISED_SERVICE_DATA_START_DATE_MONTHS_AGO <= @numOfMonthsOfInactivity)

/* Determine how many months since the last service record for each patient has been entered */

update pats
  set pats.LAST_SERVICE_RECORD_ENTRY_MONTHS_AGO = datediff(month,sr2.LAST_SERVICE_RECORD_ENTRY_DATE, @refDate)
from @pats as pats
cross apply (
  -- Should hopefully use [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS]
  select 
    LAST_SERVICE_RECORD_ENTRY_DATE = max(sr1.created)
  from dbo.SERVICE_RECORDS as sr1
  where ( 
        (sr1.clientID = @clientID)
    and (sr1.patID = pats.PATIENT_ID)
  )
) as sr2

/* Remove patients from list where there have been recent service record entries */

delete from @pats where (LAST_SERVICE_RECORD_ENTRY_MONTHS_AGO <= @numOfMonthsOfInactivity)

/* Determine how many caseloads for active pracs still have these patients listed  */

update pats
  set pats.NUM_OF_ACTIVE_CASELOAD_EXPECTED_SERVICE_ENTRIES =  q1.NUM_OF_ACTIVE_CASELOAD_EXPECTED_SERVICE_ENTRIES
from @pats as pats 
cross apply (
  select 
    NUM_OF_ACTIVE_CASELOAD_EXPECTED_SERVICE_ENTRIES = count(ppces.id)
  from dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc 
  join dbo.PRACTITIONER_Practitioner                       as prp on prp.PRACTITIONER_ID = ppc.pracID
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ppces.caseloadEntryID = ppc.id
  where (
        (ppc.clientID = @clientID)
    and (ppc.pracID is not null)
    and (ppc.patID    = pats.PATIENT_ID)
    and (prp.ACTIVE   = 1)
    and (ppces.active = 1)
  )
) as q1

/* Remove patients from list where there is recent caseload activity */

delete @pats where (NUM_OF_ACTIVE_CASELOAD_EXPECTED_SERVICE_ENTRIES > 0)

/* Return what is left */

RETURN    
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENT_FIND_RECORDS_TO_DEACTIVATE_DUE_TO_INACTIVITY_CORE TO [webuser]
GO   

