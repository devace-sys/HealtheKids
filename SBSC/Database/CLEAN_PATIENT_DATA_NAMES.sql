USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLEAN_PATIENT_DATA_NAMES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLEAN_PATIENT_DATA_NAMES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLEAN_PATIENT_DATA_NAMES]
AS
BEGIN   
set nocount onRAISERROR ('Cleaning patient data - Patient Names', 0, 1) WITH NOWAIT
/* Note: Do NOT put an index on this table var */

declare @patients as table (PATIENT_ID bigint)
/*###########################################################################
  # Trim last and first name if neccessary and keep track of the patients that
  # we updated.
  #
  # Note: LAST_NAME and FIRST_NAME do NOT accept nulls so we don't need to
  # perform a null test here.
  ###########################################################################*/    
RAISERROR ('Cleaning patient data - Patient Names - Trimming names', 0, 1) WITH NOWAITupdate dbo.PATIENTS_Patientset 
    LAST_NAME  = TRIM(LAST_NAME)
  , FIRST_NAME = TRIM(FIRST_NAME)
output
  INSERTED.PATIENT_ID
into @patients
where ((dbo.IS_STRING_TRIMMABLE(LAST_NAME) = 1) or (dbo.IS_STRING_TRIMMABLE(FIRST_NAME) = 1))
/*###########################################################################
  # Update the concat name field for each patient we just updated
  # and skip those patients where concat name contains a pipe because those
  # are special cases (patient merge data is stored there)
  ###########################################################################*/    

RAISERROR ('Cleaning patient data - Patient Names - Updating concat names', 0, 1) WITH NOWAIT

update dbo.PATIENTS_Patient
set
  CONCAT_NAME = LAST_NAME + ', ' + FIRST_NAME
where ((PATIENT_ID in (select PATIENT_ID from @patients)) and (CONCAT_NAME not like '%|%'))
RAISERROR ('Cleaning patient data - Patient Names - Removing Single Quotes', 0, 1) WITH NOWAIT

declare @pats as table (
  patID bigint
)

insert into @pats (patID)
select 
  patID = pap.PATIENT_ID
from dbo.PATIENTS_Patient as pap
where (
   (pap.LAST_NAME         like ('%''%'))
or (pap.FIRST_NAME        like ('%''%'))
or (pap.preferredNickname like ('%''%'))
or (pap.MIDDLE_NAME       like ('%''%'))
)

update pap
set 
    pap.LAST_NAME          = REPLACE(pap.LAST_NAME                      ,N'''' ,N'`')
  , pap.FIRST_NAME         = REPLACE(pap.FIRST_NAME                     ,N'''' ,N'`')
  , pap.preferredNickname  = REPLACE(isnull(pap.preferredNickname ,N'') ,N'''' ,N'`')
  , pap.MIDDLE_NAME        = REPLACE(isnull(pap.MIDDLE_NAME       ,N'') ,N'''' ,N'`')
  , pap.CONCAT_NAME        = REPLACE(pap.CONCAT_NAME, '''' ,N'`')
from @pats                as p
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p.patID


RAISERROR ('Cleaning patient data - Patient Names - Done', 0, 1) WITH NOWAIT

RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLEAN_PATIENT_DATA_NAMES] TO [webuser]
GO
