USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_SLOTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_SLOTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICE_SLOTS_VIEW_CORE] (
    @clientID        bigint
  , @oldestDOS       datetime
  , @newestDOS       datetime
)
 
/***************************************************************************    
 * SERVICE_SLOTS_VIEW_CORE */    
/**    
 * Returns a table of service record and claim "slots" for services 
 * that have not been submitted yet.
 * 
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 *
 ***************************************************************************/ 
      
RETURNS 

@recs table (

 svcRecID bigint
,claimID1 bigint
,claimID2 bigint
,svcRecIDStr varchar(50)
,claimID1Str varchar(50)
,claimID2Str varchar(50)
,minBased bit
,mileBased bit
,enteredBySBSC bit
,enteredByClient bit
,clientID bigint
,CLIENT_NAME varchar(500)
,patID bigint
,PATIENT_NAME varchar(500)
,dos datetime
,created datetime
,svcType int
,numMins int
,trip1start decimal (7,1)
,trip1end decimal (7,1)
,trip2start decimal (7,1)
,trip2end decimal (7,1)
,trip3start decimal (7,1)
,trip3end decimal (7,1)
,trip4start decimal (7,1)
,trip4end decimal (7,1)
,ProcMod1 varchar(50)
,procID1 bigint
,claimUnits1 int
,claimStatus1 char(10)
,hold1 bit
,min_units_1 int
,max_units_1 int
,max_svc_units_1 int
,service_fee_1 numeric(18,2)
,PartOfProxy1 bit
,ProcMod2 varchar(50)
,procID2 bigint
,claimUnits2 int
,claimStatus2 char(10)
,hold2 bit
,min_units_2 int
,max_units_2 int
,max_svc_units_2 int
,service_fee_2 numeric(18,2)
,PartOfProxy2 bit
,state int 
,ValidBIC bit
,SubmitClaims bit
,numTrips int
,numMiles int
,assocWithJournal bit
,journalID bigint
,journalStateOK bit
,assocWithSvcRecApproval bit
,svcRecApprovalSystem bigint
,svcRecApprovalID bigint
,svcRecApprovalStateOK int
,orpRequired bit
,claimIsOrpCompliant bit
,waitingForPracSupApproval bit
,waitingForJournal bit
,waitingForValidOrp bit
,unitType_1 varchar(50)
,unitType_2 varchar(50)

UNIQUE CLUSTERED (
   svcRecID 
)

)

AS     

BEGIN

/*###########################################################################
  # Setup table to hold claims to submit data
  ###########################################################################*/    

declare @claimsToSubmit as table (
  CLIENT_NAME varchar(500)
, PATIENT_NAME varchar(500)
, PRACTITIONER_NAME varchar(500)
, CLIENT_ID bigint
, PATIENT_ID bigint
, SERVICE_DATE datetime
, SERVICE_TYPE_ID int
, PROC_MOD_COMBO varchar(50)
, SERVICE_RECORD_ID bigint
, SERVICE_RECORD_CLAIM_ID_1 bigint
, SERVICE_RECORD_CLAIM_ID_2 bigint
, SERVICE_RECORD_CLAIM_ID_3 bigint
, SERVICE_RECORD_CLAIM_ID_4 bigint
, SERVICE_RECORD_STATE int
, PRACTITIONER_ID bigint
, LINE_NUMBER int
, CLAIM_ID bigint
, PROCEDURE_ID bigint
, SERVICE_UNITS int
, NUM_MINS int
, NUM_TRIPS int
, NUM_MILES int
, TRIP_1_START decimal (7,1)
, TRIP_1_END decimal (7,1)
, TRIP_2_START decimal (7,1)
, TRIP_2_END decimal (7,1)
, TRIP_3_START decimal (7,1)
, TRIP_3_END decimal (7,1)
, TRIP_4_START decimal (7,1)
, TRIP_4_END decimal (7,1)
, PATIENT_VALID_BIC bit
--, PATIENT_ELIG_MONTH_DATE datetime
--, PATIENT_ELIG bit
, PROCEDURE_UNITS_MIN int
, PROCEDURE_UNITS_MAX int
, PROCEDURE_UNITS_MAX_SVC int
, PROCEDURE_UNIT_TYPE varchar(50)
, PROCEDURE_SERVICE_FEE numeric(18,2)
, CLAIM_STATUS char(10)
, CLAIM_HOLD bit
, CLAIM_PROXY_PART_OF bit
, CLAIM_HAS_PROXY bit
, CLAIM_IS_PROXY bit
, ENTERED_ON datetime
, ENTERED_BY_USER_ID bigint
, ENTERED_BY_USER_NAME varchar(200)
, ENTERED_BY_SBSC bit
, ENTERED_BY_CLIENT bit
, SUBMIT_CLAIMS bit
, ORP_REQUIRED       bit
, SVC_IS_ORP_COMPLIANT bit
, JOURNAL_ASSOC bit
, JOURNAL_ID bigint
, JOURNAL_STATE_OK bit
, SVC_REC_APPROVAL_ASSOC bit
, SVC_REC_APPROVAL_SYSTEM bigint
, SVC_REC_APPROVAL_ID bigint
, SVC_REC_APPROVAL_OK bit
, NUM_OF_SAME_PROC_MOD_COMBO_NON_ORP_COMPLIANT_SVCS bit
, WAITING_FOR_JOURNAL bit
, WAITING_FOR_SVC_REC_APPROVAL bit
, WAITING_FOR_VALID_ORP        bit 

UNIQUE CLUSTERED (
    SERVICE_RECORD_ID
  , CLAIM_ID                    
)

)

/*###########################################################################
  # Setup table to hold claims data extracted from claims to submit
  ###########################################################################*/    

declare @claims as table (
  SERVICE_RECORD_ID bigint
, CLAIM_ID bigint
, CLIENT_ID bigint
, PATIENT_ID bigint
, SERVICE_DATE datetime
, SERVICE_TYPE_ID int
, PROC_MOD_COMBO varchar(50)
, PRACTITIONER_ID bigint
, LINE_NUMBER int
, PROCEDURE_ID bigint
, SERVICE_UNITS int
, PROCEDURE_UNITS_MIN int
, PROCEDURE_UNITS_MAX int
, PROCEDURE_UNITS_MAX_SVC int
, PROCEDURE_UNIT_TYPE varchar(50)
, PROCEDURE_SERVICE_FEE numeric(18,2)
, CLAIM_STATUS char(10)
, CLAIM_HOLD bit
, CLAIM_PROXY_PART_OF bit
, CLAIM_HAS_PROXY bit
, CLAIM_IS_PROXY bit

UNIQUE CLUSTERED (
    SERVICE_RECORD_ID
  , CLAIM_ID                    
)

)

/*###########################################################################
  # Setup table to hold services data extracted from claims to submit table
  ###########################################################################*/    

declare @services as table (
  SERVICE_RECORD_ID bigint
, SERVICE_RECORD_CLAIM_ID_1 bigint
, SERVICE_RECORD_CLAIM_ID_2 bigint
, SERVICE_RECORD_CLAIM_ID_3 bigint
, SERVICE_RECORD_CLAIM_ID_4 bigint
, CLIENT_NAME varchar(500)
, PATIENT_NAME varchar(500)
, CLIENT_ID bigint
, PATIENT_ID bigint
, SERVICE_DATE datetime
, SERVICE_TYPE_ID int
, SERVICE_RECORD_STATE int
, PRACTITIONER_ID bigint
, NUM_MINS int
, NUM_TRIPS int
, NUM_MILES int
, TRIP_1_START decimal (7,1)
, TRIP_1_END decimal (7,1)
, TRIP_2_START decimal (7,1)
, TRIP_2_END decimal (7,1)
, TRIP_3_START decimal (7,1)
, TRIP_3_END decimal (7,1)
, TRIP_4_START decimal (7,1)
, TRIP_4_END decimal (7,1)
, PATIENT_VALID_BIC bit
--, PATIENT_ELIG_MONTH_DATE datetime
--, PATIENT_ELIG bit
, ENTERED_ON datetime
, ENTERED_BY_USER_ID bigint
, ENTERED_BY_USER_NAME varchar(200)
, ENTERED_BY_SBSC bit
, ENTERED_BY_CLIENT bit
, JOURNAL_ASSOC bit
, JOURNAL_ID bigint
, JOURNAL_STATE_OK bit
, SVC_REC_APPROVAL_ASSOC bit
, SVC_REC_APPROVAL_SYSTEM bigint
, SVC_REC_APPROVAL_ID bigint
, SVC_REC_APPROVAL_OK bit

, ORP_REQUIRED bit
, SVC_IS_ORP_COMPLIANT bit

, WAITING_FOR_JOURNAL bit
, WAITING_FOR_SVC_REC_APPROVAL bit
, WAITING_FOR_VALID_ORP        bit
, SUBMIT_CLAIMS bit

UNIQUE CLUSTERED (
    SERVICE_RECORD_ID
)

)

/*###########################################################################
  # Populate table
  ###########################################################################*/    

insert into @claimsToSubmit
select 
  * 
from dbo.CLAIMS_TO_SUBMIT_VIEW_CORE(@clientID, @oldestDOS, @newestDOS)

/*###########################################################################
  # Populate table
  ###########################################################################*/    

insert into @services
select distinct 
  SERVICE_RECORD_ID
, SERVICE_RECORD_CLAIM_ID_1 
, SERVICE_RECORD_CLAIM_ID_2
, SERVICE_RECORD_CLAIM_ID_3
, SERVICE_RECORD_CLAIM_ID_4
, CLIENT_NAME
, PATIENT_NAME
, CLIENT_ID
, PATIENT_ID
, SERVICE_DATE
, SERVICE_TYPE_ID
, SERVICE_RECORD_STATE
, PRACTITIONER_ID
, NUM_MINS
, NUM_TRIPS
, NUM_MILES
, TRIP_1_START
, TRIP_1_END
, TRIP_2_START
, TRIP_2_END
, TRIP_3_START 
, TRIP_3_END
, TRIP_4_START
, TRIP_4_END
, PATIENT_VALID_BIC 
--, PATIENT_ELIG_MONTH_DATE
--, PATIENT_ELIG
, ENTERED_ON
, ENTERED_BY_USER_ID
, ENTERED_BY_USER_NAME
, ENTERED_BY_SBSC
, ENTERED_BY_CLIENT
, JOURNAL_ASSOC
, JOURNAL_ID
, JOURNAL_STATE_OK
, SVC_REC_APPROVAL_ASSOC
, SVC_REC_APPROVAL_SYSTEM
, SVC_REC_APPROVAL_ID
, SVC_REC_APPROVAL_OK

, ORP_REQUIRED
, SVC_IS_ORP_COMPLIANT

, WAITING_FOR_JOURNAL
, WAITING_FOR_SVC_REC_APPROVAL
, WAITING_FOR_VALID_ORP
, SUBMIT_CLAIMS

from @claimsToSubmit
    
/*###########################################################################
  # Populate table
  ###########################################################################*/    

insert into @claims
select distinct
  SERVICE_RECORD_ID
, CLAIM_ID
, CLIENT_ID
, PATIENT_ID
, SERVICE_DATE
, SERVICE_TYPE_ID
, PROC_MOD_COMBO
, PRACTITIONER_ID
, LINE_NUMBER
, PROCEDURE_ID
, SERVICE_UNITS
, PROCEDURE_UNITS_MIN
, PROCEDURE_UNITS_MAX
, PROCEDURE_UNITS_MAX_SVC
, PROCEDURE_UNIT_TYPE
, PROCEDURE_SERVICE_FEE
, CLAIM_STATUS
, CLAIM_HOLD
, CLAIM_PROXY_PART_OF
, CLAIM_HAS_PROXY
, CLAIM_IS_PROXY

from @claimsToSubmit

/*###########################################################################
  # Create result set that provides same signature as older version of this
  # udf.
  ###########################################################################*/    

insert into @recs

select 

    svcRecID                  = sr.[SERVICE_RECORD_ID]
  , claimID1                  = sr.[SERVICE_RECORD_CLAIM_ID_1]
  , claimID2                  = sr.[SERVICE_RECORD_CLAIM_ID_2]
  , svcRecIDStr               = convert(varchar(50), sr.[SERVICE_RECORD_ID])
  , claimID1Str               = convert(varchar(50), sr.[SERVICE_RECORD_CLAIM_ID_1])
  , claimID2Str               = convert(varchar(50), sr.[SERVICE_RECORD_CLAIM_ID_2])
  , minBased                  = case (sr.[SERVICE_TYPE_ID]) when dbo.CONST_SERVICES_TRANSPORT() then 0 else 1 end 
  , mileBased                 = case (sr.[SERVICE_TYPE_ID]) when dbo.CONST_SERVICES_TRANSPORT() then 1 else 0 end
  , enteredBySBSC             = sr.[ENTERED_BY_SBSC] 
  , enteredByClient           = sr.[ENTERED_BY_CLIENT]    
  , clientID                  = sr.[CLIENT_ID]
  , CLIENT_NAME               = sr.[CLIENT_NAME]    
  , patID                     = sr.[PATIENT_ID]
  , PATIENT_NAME              = sr.[PATIENT_NAME]
  , dos                       = sr.[SERVICE_DATE]   
  , created                   = sr.[ENTERED_ON]
  , svcType                   = sr.[SERVICE_TYPE_ID]    
  , numMins                   = sr.[NUM_MINS]        
  , trip1start                = sr.[TRIP_1_START]
  , trip1end                  = sr.[TRIP_1_END]
  , trip2start                = sr.[TRIP_2_START]
  , trip2end                  = sr.[TRIP_2_END]
  , trip3start                = sr.[TRIP_3_START]
  , trip3end                  = sr.[TRIP_3_END]
  , trip4start                = sr.[TRIP_4_START]
  , trip4end                  = sr.[TRIP_4_END]
  , ProcMod1                  = cr1.PROC_MOD_COMBO
  , procID1                   = isnull(cr1.PROCEDURE_ID,0)
  , claimUnits1               = cr1.SERVICE_UNITS
  , claimStatus1              = cr1.CLAIM_STATUS
  , hold1                     = cr1.CLAIM_HOLD    
  , min_units_1               = isnull(cr1.PROCEDURE_UNITS_MIN,0)
  , max_units_1               = isnull(cr1.PROCEDURE_UNITS_MAX,0)
  , max_svc_units_1           = cr1.PROCEDURE_UNITS_MAX_SVC
  , service_fee_1             = cr1.PROCEDURE_SERVICE_FEE    
  , PartOfProxy1              = cr1.CLAIM_PROXY_PART_OF
  , ProcMod2                  = cr2.PROC_MOD_COMBO
  , procID2                   = isnull(cr2.PROCEDURE_ID,0)
  , claimUnits2               = cr2.SERVICE_UNITS
  , claimStatus2              = cr2.CLAIM_STATUS
  , hold2                     = cr2.CLAIM_HOLD    
  , min_units_2               = isnull(cr2.PROCEDURE_UNITS_MIN,0)
  , max_units_2               = isnull(cr2.PROCEDURE_UNITS_MAX,0)
  , max_svc_units_2           = cr2.PROCEDURE_UNITS_MAX_SVC
  , service_fee_2             = cr2.PROCEDURE_SERVICE_FEE    
  , PartOfProxy2              = isnull(cr2.CLAIM_PROXY_PART_OF,0)
  , [state]                   = sr.[SERVICE_RECORD_STATE]
  , [ValidBic]                = sr.[PATIENT_VALID_BIC]
  , [SubmitClaims]            = sr.[SUBMIT_CLAIMS]
  , numTrips                  = sr.[NUM_TRIPS]
  , numMiles                  = sr.[NUM_MILES]
  , assocWithJournal          = sr.[JOURNAL_ASSOC]
  , journalID                 = sr.[JOURNAL_ID]
  , journalStateOK            = sr.[JOURNAL_STATE_OK]
  , assocWithSvcRecApproval   = sr.[SVC_REC_APPROVAL_ASSOC]
  , svcRecApprovalSystem      = sr.[SVC_REC_APPROVAL_SYSTEM]
  , svcRecApprovalID          = sr.[SVC_REC_APPROVAL_ID]
  , svcRecApprovalStateOK     = sr.[SVC_REC_APPROVAL_OK]
  
  , orpRequired               = sr.[ORP_REQUIRED]
  , claimIsOrpCompliant       = sr.[SVC_IS_ORP_COMPLIANT]
  
  , waitingForPracSupApproval = sr.[WAITING_FOR_SVC_REC_APPROVAL]
  , waitingForJournal         = sr.[WAITING_FOR_JOURNAL]
  , waitingForValidOrp        = sr.[WAITING_FOR_VALID_ORP]
  , unitType_1                = cr1.[PROCEDURE_UNIT_TYPE]
  , unitType_2                = cr2.[PROCEDURE_UNIT_TYPE]

/* Service record */
 
from @services as sr

/* Claim record 1 */

outer apply (           
  select top 1
      c.PROC_MOD_COMBO 
    , c.PROCEDURE_ID
    , c.SERVICE_UNITS
    , c.CLAIM_STATUS
    , c.CLAIM_HOLD
    , c.PROCEDURE_UNITS_MIN
    , c.PROCEDURE_UNITS_MAX
    , c.PROCEDURE_UNITS_MAX_SVC
    , c.PROCEDURE_SERVICE_FEE
    , c.CLAIM_PROXY_PART_OF
    , c.PROCEDURE_UNIT_TYPE
  from @claims as c
  where 
        SERVICE_RECORD_ID = sr.SERVICE_RECORD_ID
    and CLAIM_ID          = sr.SERVICE_RECORD_CLAIM_ID_1
) as cr1

/* Claim record 2*/

outer apply ( 

  select top 1
      c.PROC_MOD_COMBO 
    , c.PROCEDURE_ID
    , c.SERVICE_UNITS
    , c.CLAIM_STATUS
    , c.CLAIM_HOLD
    , c.PROCEDURE_UNITS_MIN
    , c.PROCEDURE_UNITS_MAX
    , c.PROCEDURE_UNITS_MAX_SVC
    , c.PROCEDURE_SERVICE_FEE
    , c.CLAIM_PROXY_PART_OF
    , c.PROCEDURE_UNIT_TYPE
  from @claims as c
  where 
        SERVICE_RECORD_ID = sr.SERVICE_RECORD_ID
    and CLAIM_ID          = sr.SERVICE_RECORD_CLAIM_ID_2
) as cr2
    

RETURN

END
GO




