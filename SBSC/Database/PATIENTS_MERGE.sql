USE SPEDMON
GO

 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_MERGE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PATIENTS_MERGE
GO

 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[PATIENTS_MERGE] (
    @userID              bigint
  , @userGroup           int
  , @userRank            int   
  , @clientID            bigint
  , @recIDToKeep         bigint
  , @recIDsToMerge       varchar(8000)
  , @validateRec         bit
  , @spDetails           varchar(8000) output
  , @recordID            bigint        output)

AS    
BEGIN     
 
/***************************************************************************    
 * PATIENTS_MERGE */    
/**    
 * Merge data
 ***************************************************************************/         
 
SET NOCOUNT ON

declare @TranOpen                       as bit
declare @today                          as datetime
declare @SSN                            as nvarchar(9)
declare @BIC                            as nvarchar(14)
declare @CSIS                           as varchar(50)
declare @ffpQualified                   as bit
declare @altFormat                      as varchar(50)

declare @dhcsLastName                   as nvarchar(50)
declare @dhcsFirstName                  as nvarchar(50)
declare @dhcsMiddleName                 as nvarchar(50)
declare @dhcsSex                        as char(1)
declare @dhcsDOB                        as date

declare @submitClaims                   as bit
declare @submitClaimsEffDate            as datetime
declare @parentConsentMCAL              as bit
declare @parentConsentMCALEffectiveDate as datetime
declare @parentConsentOHCI              as bit
declare @parentConsentOHCIEffectiveDate as datetime

declare @patientsToMerge as table (  
    IDX        bigint identity(1,1)
  , CLIENT_ID  bigint
  , PATIENT_ID bigint   
)

declare @redundantPatients as table (
  PATIENT_ID bigint 
)

declare @patsBasicData as table (
    CLIENT_ID      bigint
  , PATIENT_ID     bigint
  , LAST_NAME      nvarchar(50)
  , FIRST_NAME     nvarchar(50)
  , MIDDLE_NAME    nvarchar(50)
  , DATE_OF_BIRTH  datetime
  , SEX            nvarchar(1)
  , SSN            nvarchar(9)
  , BIC            nvarchar(14)
  , CSIS           nvarchar(50)
  , SUBMIT_CLAIMS                  bit
  , submitClaimsEffectiveDate      datetime
  , parentConsentMCAL              bit
  , parentConsentMCALEffectiveDate datetime
  , parentConsentOHCI              bit
  , parentConsentOHCIEffectiveDate datetime
  , ACTIVE                         nchar(1)
  , userID                         bigint
  , DATE_CREATED                   datetime
  , LAST_UPDATED                   datetime
  , LASTPOP                        datetime
  , DERIVED_EFFECTIVE_DATE         datetime
  , DHCS_LAST_NAME                 nvarchar(50)
  , DHCS_FIRST_NAME                nvarchar(50)
  , DHCS_MIDDLE_NAME               nvarchar(50)
  , DHCS_SEX                       char(1)
  , DHCS_DOB                       date
  , ffpQualified                   bit
  , altFormat                      varchar(50)
)

declare @patPlacesData as table (
    id          bigint
  , patID_Old   bigint
  , patID_New   bigint
  , placeID_Old varchar(1000)
  , placeID_New varchar(1000)  
)

declare @pracPatCaseloadRecs as table (
  pracID        bigint
, oldPatID      bigint
, newPatID      bigint
, recID         bigint
, permDelete    bit
)

declare @pracPatCaseloadGroupRecs as table (
    pracID         bigint
  , oldPatID       bigint
  , newPatID       bigint
  , pracPatGroupID bigint
  , recID          bigint
  , permDelete     bit
)

declare @pracPatCaseloadExpectedServices as table (
    pracID           bigint
  , oldPatID         bigint
  , newPatID         bigint
  , caseloadEntryID  bigint
  , recID            bigint
  , permDelete       bit
)


declare @patInsuranceCarriers as table (

    insCarrierID      bigint
  , oldPatID          bigint
  , newPatID          bigint

  , recID            bigint
  , deac       bit
  --, delete     bit
)


declare @sanityCheckCount1 as int = 0
declare @sanityCheckCount2 as int = 0
declare @dupRecSvcs        as int = 0
declare @dupSvcDescs       as int = 0

/*###########################################################################
  # Init
  ###########################################################################*/  
 
SET @spDetails  = ''
SET @recordID   = 0
SET @today      = GETDATE()
SET @TranOpen   = 0

BEGIN TRY    
  
/*###########################################################################
  # Verify required parms have been passed
  ###########################################################################*/  
 
IF (@userID        IS NULL) RAISERROR ('userID is required',               11, 1)      
IF (@userGroup     IS NULL) RAISERROR ('userGroup is required',            11, 1)    
IF (@userRank      IS NULL) RAISERROR ('userRank is required',             11, 1)    
IF (@validateRec   IS NULL) RAISERROR ('Validate flag required',           11, 1)    
IF (@clientID      IS NULL) RAISERROR ('Client ID is required',            11, 1)    
IF (@recIDsToMerge IS NULL) RAISERROR ('Record IDs to merge are required', 11, 1)

/*###########################################################################
  # Create list of patients
  ###########################################################################*/  

insert into @patientsToMerge
select distinct
    CLIENT_ID  = @clientID
  , PATIENT_ID = recID 
from dbo.MULTI_RECORD_ID_PARSE (@recIDsToMerge,',')

IF (@recIDToKeep IS NOT NULL AND (SELECT COUNT(*) FROM @patientsToMerge WHERE PATIENT_ID = @recIDToKeep) != 1)
  RAISERROR ('Patient ID to keep must be included in list', 11, 1)
  -- devs: make sure that the value of @recIDToKeep is included in the comma-delimited string @recIDsToMerge
  
/*###########################################################################
  # Check to see if these patients are all related to the client id provided
  ###########################################################################*/  

set @sanityCheckCount1 = 0
select @sanityCheckCount1 = count(t1.PATIENT_ID) from @patientsToMerge as t1

set @sanityCheckCount2 = 0
select 
  @sanityCheckCount2 = count(pap.PATIENT_ID)   
from   @patientsToMerge           as t1
join   dbo.PATIENTS_Client as pac on  pac.CLIENT_ID  = t1.CLIENT_ID
                                  and pac.PATIENT_ID = t1.PATIENT_ID
join dbo.PATIENTS_Patient  as pap on  pap.PATIENT_ID = pac.PATIENT_ID

if (@sanityCheckCount1 != @sanityCheckCount2) 
begin
  raiserror('One or more of the patient ids provided are not associated with the clientID provided', 11, 1) 
end
    
/*###########################################################################
  # If we get this far gather basic data about the patient records provided
  ###########################################################################*/  

insert into @patsBasicData (
    CLIENT_ID
  , PATIENT_ID
  , LAST_NAME
  , FIRST_NAME
  , MIDDLE_NAME
  , DATE_OF_BIRTH
  , SEX
  , SSN
  , BIC
  , CSIS
  , SUBMIT_CLAIMS
  , submitClaimsEffectiveDate
  , parentConsentMCAL
  , parentConsentMCALEffectiveDate
  , parentConsentOHCI
  , parentConsentOHCIEffectiveDate
  , ACTIVE
  , userID
  , DATE_CREATED
  , LAST_UPDATED
  , LASTPOP
  , DERIVED_EFFECTIVE_DATE
  , DHCS_LAST_NAME
  , DHCS_FIRST_NAME
  , DHCS_MIDDLE_NAME
  , DHCS_SEX
  , DHCS_DOB
  , ffpQualified
  , altFormat
)
select 
    mp.CLIENT_ID
  , mp.PATIENT_ID
  , pap.LAST_NAME
  , pap.FIRST_NAME
  , pap.MIDDLE_NAME
  , pap.DATE_OF_BIRTH
  , pap.SEX
  , SSN  = NULLIF(TRIM(pap.SSN) ,'')
  , BIC  = NULLIF(TRIM(pap.BIC) ,'')
  , CSIS = NULLIF(TRIM(pap.CSIS),'')
  , pap.SUBMIT_CLAIMS
  , submitClaimsEffectiveDate
  , pap.parentConsentMCAL
  , pap.parentConsentMCALEffectiveDate
  , pap.parentConsentOHCI
  , pap.parentConsentOHCIEffectiveDate    
  , ACTIVE = upper(isnull(pap.ACTIVE,'N'))
  , userID = isnull(pap.userID,0)
  , DATE_CREATED 
  , LAST_UPDATED
  , LASTPOP
  , DERIVED_EFFECTIVE_DATE = coalesce(LAST_UPDATED, LASTPOP, DATE_CREATED, @today)
  , DHCS_LAST_NAME    =  trim(isnull(pap.DHCS_LAST_NAME,   ''))
  , DHCS_FIRST_NAME   =  trim(isnull(pap.DHCS_FIRST_NAME,  ''))
  , DHCS_MIDDLE_NAME  =  trim(isnull(pap.DHCS_MIDDLE_NAME, ''))
  , DHCS_SEX          =  isnull(pap.DHCS_SEX,'')
  , DHCS_DOB          =  isnull(pap.DHCS_DOB,'')
  , pap.ffpQualified
  , pap.altFormat
from @patientsToMerge     as mp
join dbo.PATIENTS_PATIENT as pap on pap.PATIENT_ID = mp.PATIENT_ID 

/*###########################################################################
  # Determine patient id to keep
  ###########################################################################*/  

IF (@recIDToKeep IS NULL)
BEGIN

/* First look for latest active student data import */

select @recIDToKeep = max(PATIENT_ID) from @patsBasicData where ((userID = 0) and (active = 'Y'))

/* If that does not exist then use the latest active record */

if (@recIDToKeep is null) 
begin
  select @recIDToKeep = max(PATIENT_ID) from @patsBasicData where (active = 'Y')
end

/* If that does not exist then use the latest record */

if (@recIDToKeep is null) 
begin
  select @recIDToKeep = max(PATIENT_ID) from @patsBasicData
end

/* If we have not determined a record id by this point something is seriously wrong */

if (@recIDToKeep is null) 
begin
  raiserror('Could not auto select a patient record to keep', 11, 1) 
end

END

/*###########################################################################
  # Determine which school site and StudentID to keep
  ###########################################################################*/  

/*
  * As per Terry, 2/21/19, a client's patient/student is only at 1 school.
  * Thus, in the PATIENTS_School table, for each PATIENT_ID, we should have exactly 1 row "open",
  * END_DATE in the future, and 0 or more rows "closed", END_DATE in the past.

  * Unfortunately, we have not actually been doing that.  That changes now.
*/

declare @keeper_PATIENT_SCHOOL_ID bigint;
SELECT top 1 @keeper_PATIENT_SCHOOL_ID=PATIENT_SCHOOL_ID FROM
        dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID) AS ps WHERE ps.PATIENT_ID = @recIDToKeep
        --NOTE: This is the utility func that populates the site and STUDENT_ID on the merge screen.
        --If we use this function here, we know the merge sproc will pick the same row from the P_S table
        --as was rendered on the merge screen.  This will give us predictable behavior.

/*###########################################################################
  # Determine which email rec id and phone rec id to keep
  ###########################################################################*/  

declare @keeper_pat_email_id bigint, @keeper_pat_phoneno_id bigint;

SELECT
 @keeper_pat_email_id=pat_email_recid,
 @keeper_pat_phoneno_id=pat_phone_recid
FROM
(
SELECT
  pp.PATIENT_ID,
  ISNULL(e.Email,N'') [Email],
  e.ID [pat_email_recid],
  e.created_by [email_record_created_by],
  e.CREATED_ON [email_record_created_on],
  e.LAST_MODIFIED_BY [email_record_last_modified_by],
  e.LAST_MODIFIED_ON [email_record_last_modified_on],
  ISNULL(p.Phone,N'') [Phone],
  p.ID [pat_phone_recid],
  p.CREATED_BY [phone_record_created_by],
  p.CREATED_ON [phone_record_created_on],
  p.LAST_MODIFIED_BY [phone_record_last_modified_by],
  p.LAST_MODIFIED_ON [phone_record_last_modified_on]
FROM
PATIENTS_Patient pp
OUTER APPLY (
  select top 1 p.* FROM PATIENTS_Phone p
    WHERE pp.PATIENT_ID = p.PATIENT_ID AND p.ACTIVE = 1 --AND p.is_most_current = 1
    ORDER BY p.LAST_MODIFIED_ON DESC, p.ID DESC
  ) p
OUTER APPLY (
  select top 1 e.* FROM PATIENTS_Email e
    WHERE pp.PATIENT_ID = e.PATIENT_ID AND e.ACTIVE = 1 --AND e.is_most_current = 1
    ORDER BY e.LAST_MODIFIED_ON DESC, e.ID DESC
  ) e

WHERE p.ID IS NOT NULL OR e.ID IS NOT NULL

) VIEW_MOST_RECENT_PAT_EMAIL_AND_PHONE  --TODO: CREATE OR ALTER VIEW [dbo].[VIEW_MOST_RECENT_PAT_EMAIL_AND_PHONE] AS ...

 WHERE PATIENT_ID = @recIDToKeep

/*###########################################################################
  # Pass that record id back
  ###########################################################################*/  

set @recordID = @recIDToKeep

/*###########################################################################
  # Create list of patient ids we will deactivate when we are done merging
  ###########################################################################*/  
  
insert into @redundantPatients
select PATIENT_ID from @patientsToMerge where (PATIENT_ID != @recIDToKeep)
  
/*###########################################################################
  # Check for duplicate recurring service records. 
  # If any exist then the data has to be resolved before we can merge.
  ###########################################################################*/  
   
select 
  @dupRecSvcs = isnull(COUNT(fiscalYearID),0)
from
(
  select 
     rs.fiscalYearID
  from dbo.RECURRING_SERVICES as rs
  where (
        (rs.active = 1) 
    and (rs.patID in (select PATIENT_ID as patID from @patientsToMerge))
  )
  group by 
      rs.patID
    , rs.fiscalYearID
  having COUNT(id) > 1		
) as t1

 if (@dupRecSvcs > 0)
 begin
   raiserror('There are possible overlapping recurring service records.  Consolidate this data before continuing.', 11, 1)
 end

/*###########################################################################
  # Check for duplicate service descriptions
  # If any exist then the data has to be resolved before we can merge.
  ###########################################################################*/  

select 
  @dupSvcDescs = isnull(count(id),0)
from dbo.SvcJournal_Service_Descriptions as sd
join @patientsToMerge                    as pm on pm.CLIENT_ID = sd.clientID and pm.PATIENT_ID = sd.patID
where (
		(sd.patID = @recIDToKeep and sd.active != 1)
		or
		(sd.patID in (select PATIENT_ID from @patientsToMerge) and sd.active = 1)
	  )
group by
  effectiveDate
having (count(id) > 1)

if (@dupSvcDescs > 0)
 begin
   raiserror('There are overlapping service descriptions.  Consolidate this data before continuing.', 11, 1)
 end

/*###########################################################################
  # Determine SSN, BIC, and CSIS to put in the record we are keeping
  ###########################################################################*/  

 /*  For SSN, BIC, and CSIS, make sure we keep the non-blank, non-null values from the @recIDToKeep.
     If values from @recIDToKeep are blank or NULL, find the replacement values using SELECT TOP 1 ... ORDER BY PATIENT_ID DESC
     (this is pre-existing logic)
 */


select @SSN = pbd.SSN from @patsBasicData pbd where (PATIENT_ID = @recIDToKeep)
if (@SSN IS NULL) 
  select top 1 @SSN  = pbd.SSN   from @patsBasicData pbd where (SSN  IS NOT NULL AND TRIM(SSN)  != '') order by PATIENT_ID desc

select @BIC = pbd.BIC from @patsBasicData pbd where (PATIENT_ID = @recIDToKeep)
if (@BIC IS NULL)
  select top 1 @BIC  = pbd.BIC   from @patsBasicData pbd where (BIC  IS NOT NULL AND TRIM(BIC)  != '') order by PATIENT_ID desc

select @CSIS = pbd.CSIS from @patsBasicData pbd where (PATIENT_ID = @recIDToKeep)
if (@CSIS IS NULL)
  select top 1 @CSIS = pbd.CSIS  from @patsBasicData pbd where (CSIS IS NOT NULL AND TRIM(CSIS) != '') order by PATIENT_ID desc

select @ffpQualified = pbd.ffpQualified from @patsBasicData pbd where (PATIENT_ID = @recIDToKeep)
if (@ffpQualified IS NULL) 
  select top 1 @ffpQualified = pbd.ffpQualified from @patsBasicData pbd where (ffpQualified is not null) order by PATIENT_ID desc

select @altFormat = pbd.altFormat from @patsBasicData pbd where (PATIENT_ID = @recIDToKeep)
if (@altFormat IS NULL) 
  select top 1 @altFormat = pbd.altFormat from @patsBasicData pbd where (altFormat is not null) order by PATIENT_ID desc

select
    @dhcsLastName   = DHCS_LAST_NAME 
  , @dhcsFirstName  = DHCS_FIRST_NAME  
  , @dhcsMiddleName = DHCS_MIDDLE_NAME
  , @dhcsDOB        = DHCS_DOB
  , @dhcsSex        = DHCS_SEX
from @patsBasicData pbd where (PATIENT_ID = @recIDToKeep)
if (@dhcsLastName = '' OR @dhcsFirstName = '' )
select top 1 
    @dhcsLastName   = DHCS_LAST_NAME 
  , @dhcsFirstName  = DHCS_FIRST_NAME  
  , @dhcsMiddleName = DHCS_MIDDLE_NAME
  , @dhcsDOB        = DHCS_DOB
  , @dhcsSex        = DHCS_SEX
from @patsBasicData
where 
  ((DHCS_LAST_NAME != '') and (DHCS_FIRST_NAME != ''))


/*###########################################################################
  # Determine Submit claims/effective date pair to put into the record we
  # are keeping
  ###########################################################################*/  
select 
      @submitClaims              = SUBMIT_CLAIMS
    , @submitClaimsEffDate = isnull(submitClaimsEffectiveDate,DERIVED_EFFECTIVE_DATE)
from @patsBasicData 
where (PATIENT_ID = @recIDToKeep)

if (@submitClaims IS NULL OR @submitClaimsEffDate = 0)
select top 1 
    @submitClaims        = submitClaims
  , @submitClaimsEffDate = submitClaimsEffectiveDate
from
(  
  select 
      submitClaims              = SUBMIT_CLAIMS
    , submitClaimsEffectiveDate = isnull(submitClaimsEffectiveDate,DERIVED_EFFECTIVE_DATE)
  from @patsBasicData 
  where (SUBMIT_CLAIMS is not null)
) as q1
order by q1.submitClaimsEffectiveDate desc

/*###########################################################################
  # Determine Parental Consent MCAL/effective date pair to put into the 
  # record we are keeping.
  ###########################################################################*/  

select 
      @parentConsentMCAL              = parentConsentMCAL
    , @parentConsentMCALEffectiveDate = isnull(parentConsentMCALEffectiveDate,DERIVED_EFFECTIVE_DATE)
from @patsBasicData 
where (PATIENT_ID = @recIDToKeep)

if (@parentConsentMCAL IS NULL OR @parentConsentMCALEffectiveDate = 0)
select top 1 
    @parentConsentMCAL              = parentConsentMCAL
  , @parentConsentMCALEffectiveDate = parentConsentMCALEffectiveDate
from
(  
  select 
      parentConsentMCAL              = parentConsentMCAL
    , parentConsentMCALEffectiveDate = isnull(parentConsentMCALEffectiveDate,DERIVED_EFFECTIVE_DATE)
  from @patsBasicData 
  where (parentConsentMCAL is not null)
) as q1
order by q1.parentConsentMCALEffectiveDate desc

/*###########################################################################
  # Determine Parental Consent OHCI/effective date pair to put into the 
  # record we are keeping.
  ###########################################################################*/  

select 
      @parentConsentOHCI              = parentConsentOHCI
    , @parentConsentOHCIEffectiveDate = isnull(parentConsentOHCIEffectiveDate,DERIVED_EFFECTIVE_DATE)
from @patsBasicData 
where (PATIENT_ID = @recIDToKeep)

if (@parentConsentOHCI IS NULL OR @parentConsentOHCIEffectiveDate = 0)
select top 1 
    @parentConsentOHCI              = parentConsentOHCI
  , @parentConsentOHCIEffectiveDate = parentConsentOHCIEffectiveDate
from
(  
  select 
      parentConsentOHCI              = parentConsentOHCI
    , parentConsentOHCIEffectiveDate = isnull(parentConsentOHCIEffectiveDate,DERIVED_EFFECTIVE_DATE)
  from @patsBasicData 
  where (parentConsentOHCI is not null)
) as q1
order by q1.parentConsentOHCIEffectiveDate desc

/*###########################################################################
  # Validation 
  ###########################################################################*/  
 
if (@validateRec = 1) 
begin

  IF (@recIDToKeep IS NULL) set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'You may flag one of the selected blue rows as the most trustworthy by double-clicking it.',dbo.CONST_RET_WARN())
  
  /* Look for different dates of birth */
  
  set @sanityCheckCount1 = 0   
  select @sanityCheckCount1 = sum(q1.ctr) from (select distinct ctr = 1, DATE_OF_BIRTH from @patsBasicData) as q1
  if (@sanityCheckCount1 != 1)
  begin
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'The patients do not all have the same date of birth',dbo.CONST_RET_WARN())       
  end
  
  /* Look for different sex */

  set @sanityCheckCount1 = 0
  select @sanityCheckCount1  = sum(q1.ctr) from (select distinct ctr = 1, SEX from @patsBasicData) as q1
  if (@sanityCheckCount1  != 1)
  begin
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'The patients do not all have the same sex',dbo.CONST_RET_WARN())
  end
   
  /* Look for different CSIS */
        
  set @sanityCheckCount1 = 0
  select @sanityCheckCount1  = sum(q1.ctr) from (select distinct ctr = 1, CSIS from @patsBasicData where (CSIS != '')) as q1
  if (@sanityCheckCount1  > 1)
  begin
    set @spDetails = dbo.UPDATE_DETAILS(@spDetails,'The patients do not all have the same CSIS',dbo.CONST_RET_WARN())
  end
  
  RETURN(0)

END

/*###########################################################################
  # Get places data
  ###########################################################################*/  

insert into @patPlacesData
select 
    id          = ppvc.id
  , patID_Old   = ppvc.patID 
  , patID_New   = @recIDToKeep
  , placeID_Old = ppvc.placeID
  , placeID_New = dbo.BUILD_PLACE_ID_STRING  ( dbo.CONST_PLACE_CLASS_PATIENT_ADDRESS()
                                              , @clientID
                                              , @recIDToKeep
                                              , ppvc.id
											  , 0 )
from dbo.PATIENT_PLACES_VIEW_CORE ( null, null, null, @clientID, null, null, null, null ) as ppvc
join (select PATIENT_ID from @patientsToMerge) as pm on pm.PATIENT_ID = ppvc.patID
join dbo.PATIENT_PLACES as pp on pp.ID = ppvc.id

/*###########################################################################
  # Get caseload and caseload group data
  #
  # Note: This is more practitioner than patient centric so we are collecting
  # additional data to allow us to "merge" practitioner caseload data
  # when we perform the patient merge.
  ###########################################################################*/  

/* Get prac pat caseload data */

insert into @pracPatCaseloadRecs (
    pracID        
  , oldPatID     
  , newPatID     
  , recID
  , permDelete   
)
select 
    ppc2.pracID
  , oldPatID   = ppc2.patID
  , newPatID   = @recIDToKeep
  , recID      = ppc2.caseloadRecID 
  , permDelete = iif((DENSE_RANK() over (partition by ppc2.pracID order by ppc2.caseloadRecID desc) >1),1,0)  /* Delete oldest duplicates */
from @patientsToMerge as ptm
cross apply (
  select 
      ppc1.pracID
	, ppc1.patID
	, caseloadRecID = ppc1.id
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc1
  where (
          (ppc1.clientID = ptm.CLIENT_ID)
      and (ppc1.patID = ptm.PATIENT_ID)
  )
) as ppc2

/* Get prac pat caseload group data */

insert into @pracPatCaseloadGroupRecs (
    pracID
  , oldPatID
  , newPatID
  , pracPatGroupID
  , recID
  , permDelete
)
select 
    ppgm2.pracID
  , oldPatID = ppgm2.patID
  , newPatID = @recIDToKeep
  , ppgm2.pracPatGroupID
  , recID      = ppgm2.pracPatGroupMembershipRecID 
  , permDelete = iif((DENSE_RANK() over (partition by ppgm2.pracID, ppgm2.pracPatGroupID order by ppgm2.pracPatGroupMembershipRecID desc) >1),1,0)
from @patientsToMerge as ptm
cross apply (
  select 
	  ppg1.pracID
	, ppgm1.patID
    , ppgm1.pracPatGroupID
	, pracPatGroupMembershipRecID = ppgm1.id
  from dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as ppgm1
  join dbo.PRACTITIONER_PATIENT_GROUP        as ppg1 on ppg1.id = ppgm1.pracPatGroupID
  where (
          (ppgm1.patID = ptm.PATIENT_ID)
  )
) as ppgm2

/* Get prac pat caseload expected services data */

insert into @pracPatCaseloadExpectedServices (
    pracID  
  , oldPatID 
  , newPatID
  , caseloadEntryID
  , recID 
  , permDelete
)
select 
    ppces2.pracID
  , oldPatID = ppces2.patID
  , newPatID = @recIDToKeep
  , ppces2.caseloadEntryID
  , recID      = ppces2.expectedServiceEntryRecID 
  , permDelete = ppces2.permDelete 
from @patientsToMerge as ptm
cross apply (
  select   
      ppces1.pracID
	, ppces1.patID
	, ppces1.caseloadEntryID
	, expectedServiceEntryRecID = ppces1.id
	, pcr.permDelete
  from dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc1 
  join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces1 on ppces1.caseloadEntryID = ppc1.id
  join @pracPatCaseloadRecs                                as pcr    on pcr.recID = ppces1.caseloadEntryID
  where (
      (ppc1.patID = ptm.PATIENT_ID)
  )
) as ppces2

insert into @patInsuranceCarriers (

    insCarrierID      
  , oldPatID          
  , newPatID          

  , recID            
  , deac   
  --, delete 
)
select 
    insCarrierID = p_ic.insuranceCarrierID
  , oldPatID     = p_ic.patID
  , newPatID     = @recIDToKeep
  , recID        = p_ic.[id]
  , deac         = CASE WHEN p_ic.active = 1 THEN 0 ELSE 1 END
  --, null
from @patientsToMerge as ptm
JOIN
  dbo.PATIENT_INSURANCE_CARRIERS as p_ic ON (p_ic.patID = ptm.PATIENT_ID)

WHERE (p_ic.patID != @recIDToKeep)  -- patient insurerer records already assoc
                                    -- with the keeper don't need to be updated or deleted

    -- don't care; let the end user manually delete dupd insurer records for the keeper
/*
; with pat_insurers_may_violate_uniq as (
  SELECT var_p_ic.* FROM
  @patInsuranceCarriers var_p_ic

  JOIN [dbo].[PATIENT_INSURANCE_CARRIERS] keepers_p_ic
    ON var_p_ic.newPatID   = keepers_p_ic.patID
   AND          @clientID  = keepers_p_ic.cliID

  JOIN [dbo].[PATIENT_INSURANCE_CARRIERS] tomerge_p_ic
    ON var_p_ic.newPatID   != tomerge_p_ic.patID
   AND var_p_ic.oldPatID   = tomerge_p_ic.patID
   AND          @clientID  = tomerge_p_ic.cliID
   AND keepers_p_ic.insuranceCarrierID = tomerge_p_ic.insuranceCarrierID

WHERE
  keepers_p_ic.active = 1
  AND
  tomerge_p_ic.active = 1
  
)
*/

BEGIN TRANSACTION

  SET @TranOpen = 1

/*###########################################################################
  # Create merge archive record for merge history and unmerge
  ###########################################################################*/  
  
  insert into dbo.PATIENTS_MERGE_HISTORY (
             [CLIENT_ID]
           , [PATIENT_ID_TO_KEEP]
           , [MERGED_BY]
           , [MERGED_ON]
           , [PATIENTS_IDS_TO_MERGE]
           , [REDUNDANT_PATIENTS]
           , [PATS_BASIC_DATA]
           , [PAT_PLACES_DATA]
           , [PATIENTS_CLIENT]
           , [PATIENTS_PATIENT]
           , [PATIENTS_BIC_ARCHIVE]
           , [PATIENTS_AUDIT_LOG]
           , [PATIENTS_SCHOOL]
           , [PATIENTS_Eligibility]
           , [PATIENTS_ELIGIBILITY_NORMALIZED]
           , [PATIENTS_EXPECTED_SERVICES]
           , [FILE_UPLOADS]
           , [NOTE_LIBRARY_SAVED_NOTES]
           , [SvcJournal_Prescribed_Orders]
           , [SvcJournal_Service_Descriptions]
           , [SvcJournals]
           , [SvcJournals_Revisions]
           , [SvcNote_Notes]
           , [RECURRING_SERVICES]
           , [PRACTITIONER_PATIENT_GROUP_MEMBER]
           , [PRACTITIONER_PATIENT_CASELOAD]
           , [SERVICE_RECORDS]
           , [SERVICE_RECORD_NOTES_AUDIT_DATA]
           , [CLAIM_Claim]
           , [PATIENTS_PERSON]
           , [PLAN_WRITER_PLANS]
           , [PATIENT_PLACES]
           , [TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_PROCESSING_TRIP_DETAILS]
           , [TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED]
           , [PATIENTS_NOTES]
           , [TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS]
           , [TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS]
           , [TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS]
           , [TRANSPORTATION_MGMT_TRIP_CALCULATIONS_ORIG]
           , [TRANSPORTATION_MGMT_TRIP_CALCULATIONS_DEST]
           , [TRANSPORTATION_MGMT_TRIP_CALCULATIONS_ARCHIVE_ORIG]
           , [TRANSPORTATION_MGMT_TRIP_CALCULATIONS_ARCHIVE_DEST]
           , [SERVICE_AUTHORIZATION_REQUESTS]
           , [SERVICE_AUTHORIZATION_STATUS_CONFIRMATION]
           , [SERVICE_AUTHORIZATION_DIRECT_AUTHORIZATIONS]
           , [PATIENTS_Email]
           , [PATIENTS_Phone]
           , [TELECOMM_SESSIONS]
           , [TELECOMM_SESSIONS_PARTICIPANTS]
           , [TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA]
           , [TELECOMM_SESSIONS_FORM_DATA]
           , [PATIENT_GOALS]
           , [PATIENT_GOALS_PROGRESS]
           , [PATIENTS_Promised_Services]
           , [PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES]
           , [Patients_Promised_Services_CDE_Audits_Current_Patients]
           , [PATIENTS_Promised_Services_Delivery_Exceptions]
           , [PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data]
           , [Patients_Insurance_Carriers]
		   , [Practitioner_Patient_Scheduled_Services]
		   , [PRACTICE_OFFICE_VISITS]
		   , [PATIENT_VITALS_MEASUREMENTS]		   
           , [PATIENT_KNOWN_HEALTH_PROBLEMS]
           , [PATIENT_ALLERGIES]
           , [PATIENT_DIAGNOSES]
		   , [PATIENT_INFO_REQUESTS_RESPONSES]
  )
  values (

    @clientID
  , @recIDToKeep 
  , @userID
  , @today 
  
  , (select * from @patientsToMerge FOR JSON AUTO, INCLUDE_NULL_VALUES)
  , (select * from @redundantPatients FOR JSON AUTO, INCLUDE_NULL_VALUES)
  , (select * from @patsBasicData FOR JSON AUTO, INCLUDE_NULL_VALUES)
  , (select * from @patPlacesData FOR JSON AUTO, INCLUDE_NULL_VALUES)

  , (select t1.* from dbo.PATIENTS_Client as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)  
  
  , (select t1.* from dbo.PATIENTS_Patient as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

  , (select t1.* from dbo.PATIENT_BIC_ARCHIVE as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

  , (select t1.* from dbo.PATIENTS_AUDIT_LOG as t1
     where t1.patRecID in (select patRecID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
  
   , (select t1.* from dbo.PATIENTS_School as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	, (select t1.* from dbo.PATIENTS_Eligibility as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	, (select t1.* from dbo.PATIENTS_ELIGIBILITY_NORMALIZED as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
			
	, (select t1.* from dbo.PATIENTS_EXPECTED_SERVICES as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	
	, (select t1.* from dbo.FILE_UPLOADS as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.NOTE_LIBRARY_SAVED_NOTES as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.SvcJournal_Prescribed_Orders as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.SvcJournal_Service_Descriptions as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.SvcJournals as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.SvcJournals_Revisions as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	 
	 , (select t1.* from dbo.SvcNote_Notes as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.RECURRING_SERVICES as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.PRACTITIONER_PATIENT_CASELOAD as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.SERVICE_RECORDS as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.SERVICE_RECORD_NOTES_AUDIT_DATA as t1
     where t1.patID in (select patID = PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	 
	 , (select t1.* from dbo.CLAIM_Claim as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.PATIENTS_PERSON as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.PLAN_WRITER_PLANS as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

	 , (select t1.* from dbo.PATIENT_PLACES as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	 
	 , (select t1.* from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_PROCESSING_TRIP_DETAILS as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	  
	 , (select t1.* from dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	  
     , (select t1.* from dbo.PATIENTS_NOTES as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
		  	  	 
     , (select t1.* from dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 

     , (select t1.* from dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS  as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
	 	 
     , (select t1.* from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS  as t1
     where t1.PATIENT_ID in (select PATIENT_ID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES) 
		  
     ,(select t1.* from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS as t1
       where t1.ORIG_PLACE_ID in (select ORIG_PLACE_ID = placeID_Old from @patPlacesData) FOR JSON AUTO, INCLUDE_NULL_VALUES)
       
     ,(select t1.* from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS as t1
       where t1.DEST_PLACE_ID in (select DEST_PLACE_ID = placeID_Old from @patPlacesData) FOR JSON AUTO, INCLUDE_NULL_VALUES)

     ,(select t1.* from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_DATA as t1
       where t1.ORIG_PLACE_ID in (select ORIG_PLACE_ID = placeID_Old from @patPlacesData) FOR JSON AUTO, INCLUDE_NULL_VALUES)
            
	 ,(select t1.* from dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_DATA as t1
       where t1.DEST_PLACE_ID in (select DEST_PLACE_ID = placeID_Old from @patPlacesData) FOR JSON AUTO, INCLUDE_NULL_VALUES)

	 ,(select t1.* from dbo.SERVICE_AUTHORIZATION_REQUESTS as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)

	 ,(select t1.* from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)

	 ,(select t1.* from dbo.SERVICE_AUTHORIZATION_DIRECT_AUTHORIZATIONS as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)		

	 ,(select t1.* from dbo.PATIENTS_Email as t1
		where t1.PATIENT_ID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)

	 ,(select t1.* from dbo.PATIENTS_Phone as t1
		where t1.PATIENT_ID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)

	, (select t1.* from users.dbo.TELECOMM_SESSIONS as t1
	    CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') js
		where JSON_VALUE(t1.purposeSpecificData, '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
		      OR JSON_VALUE(js.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
			  FOR JSON AUTO, INCLUDE_NULL_VALUES)

	, (select p.* from [users].[dbo].[TELECOMM_SESSIONS_PARTICIPANTS] as p
	   Inner JOIN (
			select t1.* from users.dbo.TELECOMM_SESSIONS as t1
			CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') js
			where JSON_VALUE(t1.purposeSpecificData, '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
		       OR JSON_VALUE(js.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
	   ) as s
	   on  p.telecommSessionID = s.id
	   where p.roleID = '99'
	     and p.entityID in (select PATIENT_ID as patID from @patientsToMerge)
	   FOR JSON AUTO, INCLUDE_NULL_VALUES)
	
	, (select p.* from [spedmon].[dbo].[TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA] as p
	   Inner JOIN (
			select t1.* from users.dbo.TELECOMM_SESSIONS as t1
			CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') js
			where JSON_VALUE(t1.purposeSpecificData, '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
		       OR JSON_VALUE(js.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
	   ) As s
	   on  p.telecommSessionID = s.id
	   where p.patID in (select PATIENT_ID as patID from @patientsToMerge)
	   FOR JSON AUTO, INCLUDE_NULL_VALUES)

	, (select s.* from users.dbo.TELECOMM_SESSIONS_FORM_DATA s
  	   CROSS APPLY OPENJSON([formData], '$') j1	
  	   CROSS APPLY OPENJSON(j1.[value], '$.svcDetails') j2
       Inner JOIN (
       		select t1.* from users.dbo.TELECOMM_SESSIONS as t1
			CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') js
			where JSON_VALUE(t1.purposeSpecificData, '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
		       OR JSON_VALUE(js.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
       ) As sess
       on telecommSessionID = sess.id
       where trim(isnull(j1.[value],'')) != ''
  	     and formID = 'frmSvcRecords'	          
         and JSON_VALUE(j2.[value], '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
	   FOR JSON AUTO, INCLUDE_NULL_VALUES)

	,(select t1.* from dbo.PATIENT_GOALS as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)		

	,(select t1.* from dbo.PATIENT_GOALS_PROGRESS as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)		

	,(select t1.* from dbo.PATIENTS_Promised_Services as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)		

	,(select t1.* from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)
	
	,(select t1.* from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)		

	,(select t1.* from dbo.PATIENTS_Promised_Services_Delivery_Exceptions as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)		

	,(select t1.* from dbo.PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)

	,(select t1.* from [dbo].[PATIENT_INSURANCE_CARRIERS] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	

	,(select t1.* from [dbo].[Practitioner_Patient_Scheduled_Services] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	

	,(select t1.* from [dbo].[PRACTICE_OFFICE_VISITS] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	

	,(select t1.* from [dbo].[PATIENT_VITALS_MEASUREMENTS] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	
  
	,(select t1.* from [dbo].[PATIENT_KNOWN_HEALTH_PROBLEMS] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	

	,(select t1.* from [dbo].[PATIENT_ALLERGIES] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	

	,(select t1.* from [dbo].[PATIENT_DIAGNOSES] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	
    
	,(select t1.* from [dbo].[PATIENT_INFO_REQUESTS_RESPONSES] as t1
		where t1.patID in (select PATIENT_ID as patID from @patientsToMerge) FOR JSON AUTO, INCLUDE_NULL_VALUES)	
    
  )
  
  /*###########################################################################
    # BIC Archive data
    ###########################################################################*/  

  /* Check to see if the merged patient records will have BICs we want to archive */
  
  if exists (
    select 1 from dbo.PATIENTS_Patient as toKeep
    inner join dbo.PATIENTS_Patient as toMerge 
    on toKeep.PATIENT_ID = @recIDToKeep
    and toMerge.PATIENT_ID in (select PATIENT_ID from @redundantPatients)
    and toKeep.BIC <> toMerge.BIC
    and LEN(toMerge.BIC) = 14
    and LEN(toKeep.BIC) = 14
   )  -- I don't like how this is done.  We keep doing "if exists (SELECT ..." and then doing that exact same SELECT under the if.
      -- SELECTs already have conditionals built-in in the form of WHEREs and HAVINGs and INNER JOINs.  This is a waste.
      -- We should fix that.  Also, look for unused variables, things of that nature.
   BEGIN
	
	insert into dbo.PATIENT_BIC_ARCHIVE (PATIENT_ID ,ARCHIVED_BIC ,LAST_MEDS_CURRENT ,DATE_ARCHIVED ,ARCHIVED_BY)
	select	 toKeep.PATIENT_ID
			,toMerge.BIC 
			,pe.MEDS_CURRENT
			,@today
			,@userID
	from dbo.PATIENTS_Patient as toKeep
		inner join dbo.PATIENTS_Patient as toMerge 
			on toKeep.PATIENT_ID = @recIDToKeep
			and toMerge.PATIENT_ID in (select PATIENT_ID from @redundantPatients)
			and toKeep.BIC <> toMerge.BIC
			and LEN(toMerge.BIC) = 14
			and LEN(toKeep.BIC) = 14
		left outer join PATIENTS_Eligibility pe on toMerge.PATIENT_ID = pe.PATIENT_ID

	END	--TODO: at some point, we're going to have to replace this with a SPROC call, like we're going in the FROM_DHCS routine, to take care of claim resubmissions.	

  /*###########################################################################
    # Update the patient record we are keeping with the various data elements
    # we want to put into it
    ###########################################################################*/  

  update dbo.PATIENTS_Patient 
  set
      SSN                            = @SSN
    , BIC                            = @BIC
    , CSIS                           = @CSIS      
    , SUBMIT_CLAIMS                  = @submitClaims
    , submitClaimsEffectiveDate      = @submitClaimsEffDate
    , parentConsentMCAL              = @parentConsentMCAL
    , parentConsentMCALEffectiveDate = @parentConsentMCALEffectiveDate
    , parentConsentOHCI              = @parentConsentOHCI
    , parentConsentOHCIEffectiveDate = @parentConsentOHCIEffectiveDate
    , DHCS_LAST_NAME                 = NULLIF(@dhcsLastName,'')
    , DHCS_FIRST_NAME                = NULLIF(@dhcsFirstName,'')
    , DHCS_MIDDLE_NAME               = NULLIF(@dhcsMiddleName,'')
    , DHCS_SEX                       = NULLIF(@dhcsSex,'')
    , DHCS_DOB                       = NULLIF(@dhcsDOB,'')
    , ACTIVE                         = 'Y'
	, ffpQualified                   = @ffpQualified
	, altFormat                      = @altFormat
    , LAST_UPDATED                   = @today      
  where (PATIENT_ID = @recIDToKeep)

  /*###########################################################################
    # Update patients email
    ###########################################################################*/  

  UPDATE PATIENTS_Email
  SET PATIENT_ID = @recIDToKeep
  FROM @redundantPatients old
  WHERE PATIENTS_Email.PATIENT_ID = old.PATIENT_ID

  UPDATE PATIENTS_Email
  SET --is_most_current = 1,
      ACTIVE = 1
  WHERE id = @keeper_pat_email_id

  /*###########################################################################
    # Update patients phone
    ###########################################################################*/  

  UPDATE PATIENTS_Phone
  SET PATIENT_ID = @recIDToKeep
  FROM @redundantPatients old
  WHERE PATIENTS_Phone.PATIENT_ID = old.PATIENT_ID

  UPDATE PATIENTS_Phone
  SET --is_most_current = 1,
      ACTIVE = 1
  WHERE id = @keeper_pat_phoneno_id


  /*###########################################################################
    # Patient school merges
    ###########################################################################*/  

  drop table if exists #correctedPS

  SELECT
    old.PATIENT_SCHOOL_ID,
    @recIDToKeep PATIENT_ID,
    old.SITE_ID,
    old.GRADE,
    old.STUDENT_ID,
    old."START_DATE",
    old."END_DATE"
  INTO #correctedPS
  FROM dbo.PATIENTS_School old JOIN @redundantPatients m ON old.PATIENT_ID = m.PATIENT_ID

  UPDATE dbo.PATIENTS_School
   SET --PATIENT_ID = @recIDToKeep,                   --NOTE: As per Terry, on 2/21/19, we will no longer be associating the old rows in the P_S table with the keeper recID.
                                                      --We will simply "close" the older rows in the P_S table by setting the END_DATE.        
         END_DATE = CASE WHEN GETDATE() < "END_DATE" THEN GETDATE() ELSE COALESCE(END_DATE, GETDATE()) END
  FROM @redundantPatients old
  WHERE dbo.PATIENTS_School.PATIENT_ID = old.PATIENT_ID

  /* for the latest P_S entry for the current Site and STUDENT_ID, set the START_DATE and END_DATE correctly */

  ;with 
   latest_info as (
    SELECT
      MAX(PATIENT_SCHOOL_ID) idx,
      STUDENT_ID,
      SITE_ID
    FROM dbo.PATIENTS_School
    WHERE PATIENT_ID = @recIDToKeep
    GROUP BY STUDENT_ID, SITE_ID
  ),
   earliest_info as (
    SELECT
      MIN("START_DATE") "start_date",
      STUDENT_ID,
      SITE_ID
    FROM #correctedPS
    --WHERE PATIENT_ID = @recIDToKeep
    GROUP BY STUDENT_ID, SITE_ID
  )
  UPDATE dbo.PATIENTS_School
    SET "START_DATE" = earliest_info."start_date",
        "END_DATE" = COALESCE(dbo.PATIENTS_School."END_DATE", DATEADD(YEAR, 5, GETDATE()))
  FROM latest_info JOIN earliest_info ON latest_info.SITE_ID = earliest_info.SITE_ID AND latest_info.STUDENT_ID = earliest_info.STUDENT_ID
  WHERE dbo.PATIENTS_School.PATIENT_SCHOOL_ID = latest_info.idx
  drop table #correctedPS

  /* If, in the P_S table, there are multiple rows that
       -- ALREADY have the PATIENT_ID = @recIDToKeep, and
       -- have identical SITE_IDs and STUDENT_IDs
     then DELETE all but the last from each group,
     GROUPing BY SITE_ID and STUDENT_ID
   */
  ;with
   latest_info as (
    SELECT
      MAX(PATIENT_SCHOOL_ID) idx
    FROM dbo.PATIENTS_School
    WHERE PATIENT_ID = @recIDToKeep
    GROUP BY STUDENT_ID, SITE_ID
  )
  DELETE FROM
  dbo.PATIENTS_School
  WHERE PATIENT_ID = @recIDToKeep AND
  PATIENT_SCHOOL_ID NOT IN
  (SELECT idx FROM latest_info)

  /* Additionally, we must "close" all the P_S rows except the one we are keeping - the current school */
  UPDATE dbo.PATIENTS_School
    SET "END_DATE" = DATEADD(DAY, -1, GETDATE())
  WHERE PATIENT_ID = @recIDToKeep AND PATIENT_SCHOOL_ID != @keeper_PATIENT_SCHOOL_ID AND
    ("END_DATE" IS NULL OR "END_DATE" > GETDATE())
  
/* Removing the a5 file rows merge. */
/*
  UPDATE r
  SET Patient_ID = @recIDToKeep
  FROM [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] r
  JOIN [dbo].[Import_From_A.5_SERVICES_From_Client_Files] f ON r.File_import_log_entry = f.id AND f.client_id = @clientID
  WHERE Patient_ID in (select PATIENT_ID from @patientsToMerge)
    OR Patient_ID_orig in (select PATIENT_ID Patient_ID_orig from @patientsToMerge)
    OR Patient_ID IS NULL AND (
      [Student SSID] = @CSIS
    )
 */

 /*###########################################################################
   # Simple record merges for related tables 
   ###########################################################################*/  

  UPDATE dbo.PATIENTS_EXPECTED_SERVICES
  SET PATIENT_ID = @recIDToKeep
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)

  UPDATE dbo.FILE_UPLOADS
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.NOTE_LIBRARY_SAVED_NOTES
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.SvcJournal_Prescribed_Orders
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.SvcJournal_Service_Descriptions
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)
   
  UPDATE dbo.SvcJournals
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.SvcJournals_Revisions
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)
  
  UPDATE dbo.SvcNote_Notes
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)
  	    
  UPDATE dbo.RECURRING_SERVICES
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)
			
  UPDATE dbo.SERVICE_RECORDS
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)
	
  UPDATE dbo.SERVICE_RECORD_NOTES_AUDIT_DATA
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.CLAIM_Claim
  SET PATIENT_ID = @recIDToKeep  
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)
  
  UPDATE dbo.PATIENTS_PERSON
  SET PATIENT_ID = @recIDToKeep  
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)

  UPDATE dbo.PLAN_WRITER_PLANS
  SET PATIENT_ID = @recIDToKeep  
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)

  UPDATE dbo.PATIENT_PLACES
  SET PATIENT_ID = @recIDToKeep  
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)
  
  UPDATE dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS_PROCESSING_TRIP_DETAILS
  SET PATIENT_ID = @recIDToKeep  
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)

  UPDATE dbo.TRANSPORTATION_MGMT_SERVICE_RECORDS_REVIEWED
  SET PATIENT_ID = @recIDToKeep  
  WHERE PATIENT_ID in (select PATIENT_ID from @patientsToMerge)

  UPDATE dbo.SERVICE_AUTHORIZATION_REQUESTS
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION  
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.SERVICE_AUTHORIZATION_DIRECT_AUTHORIZATIONS  
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE users.dbo.TELECOMM_SESSIONS
  SET purposeSpecificData = JSON_MODIFY([purposeSpecificData], '$.patID', @recIDToKeep)
  WHERE purposeID = 3 and 
  		JSON_VALUE([purposeSpecificData], '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.PATIENT_GOALS  
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.PATIENT_GOALS_PROGRESS  
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  UPDATE dbo.PATIENTS_Promised_Services  
  SET patID = @recIDToKeep
  WHERE patID in (select PATIENT_ID as patID from @patientsToMerge)

  /* Delete all except keeper */
  delete dbo.Patients_Promised_Services_CDE_Audits_Current_Patients
  where patID in (select PATIENT_ID as patID from @patientsToMerge where (PATIENT_ID != @recIDToKeep))

  update dbo.[PATIENTS_Promised_Services_Delivery_Exceptions]
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.[PATIENTS_Promised_Services_SpEd_Data_Error_Correction_Data]
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.Practitioner_Patient_Scheduled_Services
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.PRACTICE_OFFICE_VISITS
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.PATIENT_VITALS_MEASUREMENTS
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.PATIENT_KNOWN_HEALTH_PROBLEMS
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.PATIENT_ALLERGIES
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.PATIENT_DIAGNOSES
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

  update dbo.PATIENT_INFO_REQUESTS_RESPONSES
  set patID = @recIDToKeep
  where patID in (select PATIENT_ID as patID from @patientsToMerge)

/*###########################################################################
  # Complex record merges
  ###########################################################################*/  

/* Caseload Groups -- Records to Update */

update t2
set 
    t2.patID          = t1.newPatID
  , t2.lastModified   = @today
  , t2.lastModifiedBy = @userID
from @pracPatCaseloadGroupRecs             as t1
join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as t2 on ((t2.id = t1.recID)
											     and (t2.patID = t1.oldPatID))
join dbo.PRACTITIONER_PATIENT_GROUP        as t3 on  ((t3.id = t2.pracPatGroupID)
                                                 and (t3.pracID = t1.pracID)
												 and (t3.clientID = @clientID))
where (t1.permDelete = 0)

/* Caseload Groups -- Records to delete */

delete t2 
from @pracPatCaseloadGroupRecs             as t1
join dbo.PRACTITIONER_PATIENT_GROUP_MEMBER as t2 on ((t2.id = t1.recID)
											     and (t2.patID = t1.oldPatID))
join dbo.PRACTITIONER_PATIENT_GROUP        as t3 on  ((t3.id = t2.pracPatGroupID)
                                                 and (t3.pracID = t1.pracID)
												 and (t3.clientID = @clientID))
where (t1.permDelete = 1)

/* Caseload Expected Services -- Records to Update */

update t2
set 
    t2.patID          = t1.newPatID
  , t2.lastModified   = @today
  , t2.lastModifiedBy = @userID
from @pracPatCaseloadExpectedServices                    as t1
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as t2 on ((t2.id = t1.recID)
														       and (t2.clientID = @clientID)
											                   and (t2.pracID = t1.pracID)
									                           and (t2.patID = t1.oldPatID))


where (t1.permDelete = 0)

/* Patient insurance carriers */

update t2
set 
    t2.patID          = t1.newPatID
  , t2.lastModified   = @today
  , t2.lastModifiedBy = @userID
from @patInsuranceCarriers                    as t1
join [dbo].[PATIENT_INSURANCE_CARRIERS]       as t2 on ((t2.id = t1.recID)
											     and (t2.clientID = @clientID)
									             and (t2.patID    = t1.oldPatID))






/* Caseload Expected Services -- Records to Delete */

delete t2
from @pracPatCaseloadExpectedServices                    as t1
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as t2 on ((t2.id = t1.recID)
														       and (t2.clientID = @clientID)
											                   and (t2.pracID = t1.pracID)
									                           and (t2.patID = t1.oldPatID))
where (t1.permDelete = 1)


/* Caseload promised services & orp docs -- Delete only*/

delete t2
from @pracPatCaseloadRecs                                as t1
join dbo.PRACTITIONER_PATIENT_CASELOAD_PROMISED_SERVICES as t2 on t2.caseloadEntryID = t1.recID
where (t1.permDelete = 1)

delete t2
from @pracPatCaseloadRecs                                as t1
join dbo.PRACTITIONER_PATIENT_CASELOAD_ORP_DOCUMENTS     as t2 on t2.caseloadEntryID = t1.recID
where (t1.permDelete = 1)

/* Caseload -- Records to update */

update t2
set   
    t2.patID          = t1.newPatID
  , t2.lastModified   = @today
  , t2.lastModifiedBy = @userID
from @pracPatCaseloadRecs              as t1
join dbo.PRACTITIONER_PATIENT_CASELOAD as t2 on  ((t2.id = t1.recID)
                                             and (t2.clientID = @clientID)
											 and (t2.pracID = t1.pracID)
									         and (t2.patID = t1.oldPatID))
where (t1.permDelete = 0)

/* Caseload -- Records to delete */

delete t2
from @pracPatCaseloadRecs              as t1
join dbo.PRACTITIONER_PATIENT_CASELOAD as t2 on  ((t2.id = t1.recID)
                                             and (t2.clientID = @clientID)
											 and (t2.pracID = t1.pracID)
									         and (t2.patID = t1.oldPatID))
where (t1.permDelete = 1)
  
/* Patient notes */
  
  declare @patNotes      as nvarchar(max) = N''
  declare @patNotesRecID as bigint        = null
  
  SELECT TOP 1 @patNotesRecID = NOTE_ID FROM dbo.PATIENTS_NOTES
  WHERE (PATIENT_ID = @recIDToKeep)
        
  select 
    @patNotes = STUFF((
        SELECT + char(13) + q1.NOTE from
        (
          SELECT
            isnull(NOTE,N'') as NOTE
          FROM dbo.PATIENTS_NOTES as t1
          JOIN @patientsToMerge   as t2 on t2.PATIENT_ID = t1.PATIENT_ID
        ) as q1
  FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')
  
  select @patNotes = isnull(@patNotes,'')
  
  if (@patNotesRecID is null)
  begin
    INSERT INTO dbo.PATIENTS_NOTES (
        PATIENT_ID
      , NOTE
      , DATE_CREATED
      , DATE_MODIFIED )
    VALUES (
        @recIDToKeep
      , @patNotes
      , @today
      , @today)
  end
  else
  begin
    UPDATE dbo.PATIENTS_NOTES
    SET
        PATIENT_ID    = @recIDToKeep
      , NOTE          = @patNotes
      , DATE_MODIFIED = @today
    WHERE (NOTE_ID = @patNotesRecID)
  end
  
  /*----------------------------------------------------------*/

  /* Trans Mgmt Authorized Patients */

  UPDATE
     tmap
  SET
     tmap.PATIENT_ID    = ppd.patID_New
    ,tmap.HOME_PLACE_ID = ppd.placeID_New
  FROM
      dbo.TRANSPORTATION_MGMT_AUTHORIZED_PATIENTS  AS tmap
      INNER JOIN @patPlacesData AS ppd ON  tmap.PATIENT_ID    = ppd.patID_Old
                                     AND tmap.HOME_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* Trans Mgmt Authorized Route Members Part 1/3 */

  UPDATE
   tm
  SET
    tm.ORIG_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS  AS tm
    INNER JOIN @patPlacesData AS ppd ON  tm.PATIENT_ID    = ppd.patID_Old
                                     AND tm.ORIG_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* Trans Mgmt Authorized Route Members Part 2/3 */

  UPDATE
   tm
  SET  
    tm.DEST_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS  AS tm
    INNER JOIN @patPlacesData AS ppd ON  tm.PATIENT_ID    = ppd.patID_Old
                                     AND tm.DEST_PLACE_ID = ppd.placeID_Old  
  WHERE (1=1)    

  /* Trans Mgmt Authorized Route Members Part 3/3 */

  UPDATE
    tm
  SET
    tm.PATIENT_ID = ppd.patID_New  
  FROM
    dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTE_MEMBERS  AS tm
    INNER JOIN @patPlacesData AS ppd ON tm.PATIENT_ID = ppd.patID_Old                                   
  WHERE (1=1)    

  /* Trans Mgmt Route Sheet Members Part 1/3 */
 
  UPDATE
    tm
  SET
    tm.ORIG_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS  AS tm
    INNER JOIN @patPlacesData AS ppd ON  tm.PATIENT_ID    = ppd.patID_Old
                                     AND tm.ORIG_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* Trans Mgmt Route Sheet Members Part 2/3 */
 
  UPDATE
    tm
  SET  
    tm.DEST_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS  AS tm
    INNER JOIN @patPlacesData AS ppd ON  tm.PATIENT_ID    = ppd.patID_Old
                                     AND tm.DEST_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)

  /* Trans Mgmt Route Sheet Members Part 3/3 */
 
  UPDATE
    tm
  SET
   tm.PATIENT_ID = ppd.patID_New  
  FROM
    dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS  AS tm
    INNER JOIN @patPlacesData AS ppd ON tm.PATIENT_ID = ppd.patID_Old
  WHERE (1=1)    

  /* Trans Mgmt Trip Calculations Part 1/2 */

  UPDATE
    tm
  SET
    tm.ORIG_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS  AS tm
    INNER JOIN @patPlacesData AS ppd ON tm.ORIG_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* Trans Mgmt Trip Calculations Part 2/2 */

  UPDATE
    tm
  SET
    tm.DEST_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS  AS tm
    INNER JOIN @patPlacesData AS ppd ON tm.DEST_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* Trans Mgmt Trip Calculations Audit Data Part 1/2 */

  UPDATE
    tm
  SET
    tm.ORIG_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_DATA  AS tm
    INNER JOIN @patPlacesData AS ppd ON tm.ORIG_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* Trans Mgmt Trip Calculations Audit Data Part 2/2 */

  UPDATE
    tm
  SET
    tm.DEST_PLACE_ID = ppd.placeID_New
  FROM
    dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_DATA  AS tm
    INNER JOIN @patPlacesData AS ppd ON tm.DEST_PLACE_ID = ppd.placeID_Old
  WHERE (1=1)    

  /* TELECOMM_SESSIONS for individual health */

  ;WITH parts_details_json_for_individual AS (
	SELECT *
	FROM users.dbo.TELECOMM_SESSIONS
	CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') s
	WHERE purposeID = 2 
	    and JSON_VALUE([purposeSpecificData], '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
		and	(JSON_VALUE([purposeSpecificData], '$.patGroupID') IS NULL or JSON_VALUE([purposeSpecificData], '$.patGroupID') = '')
		and JSON_VALUE(s.value, '$.roleID') = '99'
		and	JSON_VALUE(s.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
  )


  UPDATE parts_details_json_for_individual
  SET purposeSpecificData = JSON_MODIFY([purposeSpecificData], '$.patID', @recIDToKeep),
      participantDetailsEnteredJSON = 
		  JSON_MODIFY([participantDetailsEnteredJSON], '$.participantdetails[' + parts_details_json_for_individual.[key] + '].entityID'
		, @recIDToKeep)
  
  /* TELECOMM_SESSIONS_PARTICIPANTS for individual health */

  UPDATE p
  SET entityID = @recIDToKeep
  FROM [users].[dbo].[TELECOMM_SESSIONS_PARTICIPANTS] As p
     Inner JOIN (
  		select * from [users].[dbo].[TELECOMM_SESSIONS] as t1
  		where t1.purposeID = 2
  			and JSON_VALUE(t1.purposeSpecificData, '$.patID')  IS NOT NULL --in (select PATIENT_ID as patID from @patientsToMerge)
  			and JSON_VALUE(t1.purposeSpecificData, '$.patID') != ''
			and (JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NULL
  			or JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') = '')
    
     ) As s
   on  p.telecommSessionID = s.id
   where p.roleID = '99'
     and p.entityID in (select PATIENT_ID as patID from @patientsToMerge)

  /* TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA for individual health */

  UPDATE p
  SET patID = @recIDToKeep
  FROM [dbo].[TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA] As p
     Inner JOIN (
  		select * from [users].[dbo].[TELECOMM_SESSIONS] as t1
  		where t1.purposeID = 2
  			and JSON_VALUE(t1.purposeSpecificData, '$.patID')  IS NOT NULL --in (select PATIENT_ID as patID from @patientsToMerge)
  			and JSON_VALUE(t1.purposeSpecificData, '$.patID') != ''
			and (JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NULL
  			or JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') = '')
    
     ) As s
     ON  p.telecommSessionID = s.id
	 WHERE p.patID in (select PATIENT_ID as patID from @patientsToMerge)


  /* TELECOMM_SESSIONS_FORM_DATA for individual health */

  /* Form data contaims a JSON string that represents the serialized form of obj.details 
   * details is a string that can contain any valid string....in this case it contains ESCAPED json 
  */
  declare @formData as varchar(max)
  
  /* Unescape json stored in $.details */
  declare @detailsValue as varchar(max)
  
  /* Modify particular record */
  declare @newDetailsValue as varchar(max)
  
  /* Escape json and put back in formData */
  declare @newFormData as varchar(max)

  -- set variables to be used to null
  set @formData = null
  set @detailsValue = null
  set @newDetailsValue = null
  set @newFormData = null
  
  
  ;WITH form_data_json_for_individual AS (
        select s.*, j2.* from users.dbo.TELECOMM_SESSIONS_FORM_DATA s
  		CROSS APPLY OPENJSON([formData], '$') j1	
  	    CROSS APPLY OPENJSON(j1.[value], '$.svcDetails') j2
    		Inner JOIN (
    			select * from [users].[dbo].[TELECOMM_SESSIONS] as t1
    			where t1.purposeID = 2
    				and JSON_VALUE(t1.purposeSpecificData, '$.patID') IS NOT NULL--in (select PATIENT_ID as patID from @patientsToMerge)
    				and JSON_VALUE(t1.purposeSpecificData, '$.patID') != ''
					and (JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NULL
    				or JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') = '')
      
    	   ) As sess
    	   on telecommSessionID = sess.id
    	   where trim(isnull(j1.[value],'')) != ''
  		     and formID = 'frmSvcRecords'	          
    	     and JSON_VALUE(j2.[value], '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
    )
  
    UPDATE form_data_json_for_individual
    SET @formData = [formData],
  
        /* Unescape json stored in $.details */
        @detailsValue = JSON_VALUE (@formData,'$.details'),
  
        /* Modify particular record */
        @newDetailsValue = JSON_MODIFY(@detailsValue,'$.svcDetails[' + form_data_json_for_individual.[key] + '].patID', @recIDToKeep),
  
        /* Escape json and put back in formData */
        @newFormData = JSON_MODIFY(@formData,'$.details', @newDetailsValue),
  
        [formData] = @newFormData
  
  /* TELECOMM_SESSIONS for group health */

  ;WITH parts_details_json_for_group As (
  SELECT *
  FROM users.dbo.TELECOMM_SESSIONS t1
	CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') s
	WHERE purposeID = 2 
		and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NOT NULL
		and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') != ''
		and (JSON_VALUE(t1.purposeSpecificData, '$.patID') IS NULL 
   			 or JSON_VALUE(t1.purposeSpecificData, '$.patID') = '')
		and JSON_VALUE(s.value, '$.roleID') = '99'
		and	JSON_VALUE(s.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
  )

  UPDATE parts_details_json_for_group
  SET participantDetailsEnteredJSON = 
		  JSON_MODIFY([participantDetailsEnteredJSON], '$.participantdetails[' + parts_details_json_for_group.[key] + '].entityID'
		, @recIDToKeep)

  /* TELECOMM_SESSIONS_PARTICIPANTS for group health */

  UPDATE p 
  SET entityID = @recIDToKeep
  FROM [users].[dbo].[TELECOMM_SESSIONS_PARTICIPANTS] as p
	   Inner JOIN (
			select * from [users].[dbo].[TELECOMM_SESSIONS] as t1
			CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') s
			where purposeID = 2 
			and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NOT NULL
			and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') != ''
			and (JSON_VALUE(t1.purposeSpecificData, '$.patID') IS NULL 
	   			 or JSON_VALUE(t1.purposeSpecificData, '$.patID') = '')
			and JSON_VALUE(s.value, '$.roleID') = '99'
			--and	JSON_VALUE(s.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
		) as ss
		on p.telecommSessionID = ss.id 
		and p.entityID in (select PATIENT_ID as patID from @patientsToMerge) --JSON_VALUE(ss.value, '$.entityID')

  /* TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA for group health */

  UPDATE p 
  SET patID = @recIDToKeep
  FROM [spedmon].[dbo].[TELECOMM_HEALTH_SERVICE_RECORD_ENTRY_DATA] as p
	   Inner JOIN (
			select * from [users].[dbo].[TELECOMM_SESSIONS] as t1
			CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') s
			where purposeID = 2 
			and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NOT NULL
			and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') != ''
			and (JSON_VALUE(t1.purposeSpecificData, '$.patID') IS NULL 
	   			 or JSON_VALUE(t1.purposeSpecificData, '$.patID') = '')
			and JSON_VALUE(s.value, '$.roleID') = '99'
			--and	JSON_VALUE(s.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
		) as ss
		on p.telecommSessionID = ss.id 
		and p.patID in (select PATIENT_ID as patID from @patientsToMerge) -- = JSON_VALUE(ss.value, '$.entityID')

  /* TELECOMM_SESSIONS_FORM_DATA for group health */

  -- set variables to be used to null
  set @formData = null
  set @detailsValue = null
  set @newDetailsValue = null
  set @newFormData = null

  ;WITH form_data_json_for_group AS (
  	    select s.*, j2.* from users.dbo.TELECOMM_SESSIONS_FORM_DATA s
    	CROSS APPLY OPENJSON([formData], '$') j1	
    	CROSS APPLY OPENJSON(j1.[value], '$.svcDetails') j2
      	Inner JOIN (
      		select * from [users].[dbo].[TELECOMM_SESSIONS] as t1
  	   		CROSS APPLY OPENJSON([participantDetailsEnteredJSON], '$.participantdetails') s
  	   		where t1.purposeID = 2
  	   		and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') IS NOT NULL
  	   		and JSON_VALUE(t1.purposeSpecificData, '$.patGroupID') != ''
  	   		and (JSON_VALUE(t1.purposeSpecificData, '$.patID') IS NULL 
  	      				or JSON_VALUE(t1.purposeSpecificData, '$.patID') = '')
  	   		and JSON_VALUE(s.value, '$.roleID') = '99'
  	   		--and	JSON_VALUE(s.value, '$.entityID') in (select PATIENT_ID as patID from @patientsToMerge)
        
      	) As sess
      	on telecommSessionID = sess.id
      	where trim(isnull(j1.[value],'')) != ''
    	  and formID = 'frmSvcRecords'	          
      	  and JSON_VALUE(j2.[value], '$.patID') in (select PATIENT_ID as patID from @patientsToMerge)
  )

  UPDATE form_data_json_for_group
  SET @formData = [formData],

      /* Unescape json stored in $.details */
      @detailsValue = JSON_VALUE (@formData,'$.details'),

      /* Modify particular record */
      @newDetailsValue = JSON_MODIFY(@detailsValue,'$.svcDetails[' + form_data_json_for_group.[key] + '].patID', @recIDToKeep),

      /* Escape json and put back in formData */
      @newFormData = JSON_MODIFY(@formData,'$.details', @newDetailsValue),

      [formData] = @newFormData

  /*###########################################################################
    # Delete redundant records
    ###########################################################################*/  
  
  DELETE FROM dbo.PATIENTS_NOTES
  WHERE PATIENT_ID in (select PATIENT_ID from @redundantPatients)

  DELETE FROM dbo.PATIENTS_Eligibility
  WHERE PATIENT_ID in (select PATIENT_ID from @redundantPatients)

  DELETE FROM dbo.PATIENTS_Client
  WHERE PATIENT_ID in (select PATIENT_ID from @redundantPatients)

  /*###########################################################################
    # Deactivate redundant records
    ###########################################################################*/  

  UPDATE dbo.PATIENTS_Patient
  SET 
      ACTIVE = 'N'
    , CONCAT_NAME  = 'Merged|' + convert(nvarchar(93),@recIDToKeep)
    , LAST_UPDATED = @today
  WHERE PATIENT_ID in (select PATIENT_ID from @redundantPatients)

  /*###########################################################################
    # Update audit logs
    ###########################################################################*/  

  insert into dbo.PATIENTS_AUDIT_LOG (patRecID, loggedOn, userID, saveType, reason)
  select 
	 rp.PATIENT_ID
    , @today
    , @userID
    , dbo.CONST_REC_STATE_DEL()
    , 'Deleted this patient as part of merge into record # ' + CONVERT(varchar(80),@recIDToKeep) + '.'
  from @redundantPatients as rp
   
  insert into dbo.PATIENTS_AUDIT_LOG (patRecID, loggedOn, userID, saveType, reason)
  select 
      @recIDToKeep
    , @today
    , @userID
    , dbo.CONST_REC_STATE_MOD()
    , 'Merged patient ID# ' + convert(varchar(80),rp.PATIENT_ID) + ' into this record.'
   from @redundantPatients as rp
 
/*###########################################################################
  # If we reach this point everything went well.  Commit the changes and get
  # out
  ###########################################################################*/  

COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    

END TRY    
BEGIN CATCH    
 
/*###########################################################################
  # If we end up here something went wrong.  Rollback any pending transactions
  # and return any error messages to the caller
  ###########################################################################*/  
 
  -- Error or raise error with severity 11 to 19 will be caught here    
 
  IF @tranOpen = 1 ROLLBACK TRANSACTION
 
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
 
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
 
USE SPEDMON
GO

GRANT EXECUTE ON  [dbo].[PATIENTS_MERGE] TO [webuser]
GO

USE users
GO

GRANT UPDATE ON users.dbo.TELECOMM_SESSIONS_PARTICIPANTS to [webuser]
GO

USE users
GO

GRANT UPDATE ON users.dbo.TELECOMM_SESSIONS to [webuser]
GO

USE users
GO

GRANT UPDATE ON users.dbo.TELECOMM_SESSIONS_FORM_DATA to [webuser]
GO   
 
USE SPEDMON
GO
