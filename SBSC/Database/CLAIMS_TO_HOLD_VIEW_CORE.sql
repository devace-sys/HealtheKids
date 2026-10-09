USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TO_HOLD_VIEW_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TO_HOLD_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_TO_HOLD_VIEW_CORE] (  
   @clientID  AS bigint
 , @oldestDOS AS datetime
 , @newestDOS as datetime)

/***************************************************************************    
 * CLAIMS_TO_HOLD_VIEW_CORE */    
/**    
 * Returns a set of claims from all possible claim slots that are subject
 * to possible hold and possible proxy.  Note this query does not show
 * IF the claims should be held or why.  It just shows claims that are
 * subject to monitoring.
 *
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 ***************************************************************************/        

RETURNS 

@recs table (
  svcRecID bigint
, claimID1 bigint
, claimID2 bigint
, svcRecIDStr varchar(50)
, claimID1Str varchar(50)
, claimID2Str varchar(50)
, minBased bit
, mileBased bit
, enteredBySBSC bit
, enteredByClient bit
, clientID bigint
, CLIENT_NAME varchar(500)
, patID bigint
, PATIENT_NAME varchar(500)
, dos datetime
, created datetime
, svcType int
, numMins int
, trip1start decimal (7,1)
, trip1end decimal (7,1)
, trip2start decimal (7,1)
, trip2end decimal (7,1)
, trip3start decimal (7,1)
, trip3end decimal (7,1)
, trip4start decimal (7,1)
, trip4end decimal (7,1)
, ProcMod1 varchar(50)
, procID1 bigint
, claimUnits1 int
, claimStatus1 char(10)
, hold1 bit
, min_units_1 int
, max_units_1 int
, max_svc_units_1 int
, service_fee_1 numeric(18,2)
, PartOfProxy1 bit
, ProcMod2 varchar(50)
, procID2 bigint
, claimUnits2 int
, claimStatus2 char(10)
, hold2 bit
, min_units_2 int
, max_units_2 int
, max_svc_units_2 int
, service_fee_2 numeric(18,2)
, PartOfProxy2 bit
, state int 
, ValidBIC bit
, SubmitClaims bit
, numTrips int
, numMiles int
, assocWithJournal bit
, journalID bigint
, journalStateOK bit
, assocWithSvcRecApproval bit
, svcRecApprovalSystem bigint
, svcRecApprovalID bigint
, svcRecApprovalStateOK int
, orpRequired bit
, claimIsOrpCompliant bit

, waitingForPracSupApproval bit
, waitingForJournal bit
, waitingForValidOrp bit
, unitType_1 varchar(50)
 ,unitType_2 varchar(50)
, numMinsExpected int
, numTripsExpected int
, numSvcsExpected int

  UNIQUE CLUSTERED (
   svcRecID
  )
)
AS     
BEGIN

   
/*###########################################################################
  # Table var for service slots
  ###########################################################################*/   
   
 declare @service_slots as table (
    svcRecID bigint
  , claimID1 bigint
  , claimID2 bigint
  , svcRecIDStr varchar(50)
  , claimID1Str varchar(50)
  , claimID2Str varchar(50)
  , minBased bit
  , mileBased bit
  , enteredBySBSC bit
  , enteredByClient bit
  , clientID bigint
  , CLIENT_NAME varchar(500)
  , patID bigint
  , PATIENT_NAME varchar(500)
  , dos datetime
  , created datetime
  , svcType int
  , numMins int
  , trip1start decimal (7,1)
  , trip1end decimal (7,1)
  , trip2start decimal (7,1)
  , trip2end decimal (7,1)
  , trip3start decimal (7,1)
  , trip3end decimal (7,1)
  , trip4start decimal (7,1)
  , trip4end decimal (7,1)
  , ProcMod1 varchar(50)
  , procID1 bigint
  , claimUnits1 int
  , claimStatus1 char(10)
  , hold1 bit
  , min_units_1 int
  , max_units_1 int
  , max_svc_units_1 int
  , service_fee_1 numeric(18,2)
  , PartOfProxy1 bit
  , ProcMod2 varchar(50)
  , procID2 bigint
  , claimUnits2 int
  , claimStatus2 char(10)
  , hold2 bit
  , min_units_2 int
  , max_units_2 int
  , max_svc_units_2 int
  , service_fee_2 numeric(18,2)
  , PartOfProxy2 bit
  , state int 
  , ValidBIC bit
  , SubmitClaims bit
  , numTrips int
  , numMiles int
  , assocWithJournal bit
  , journalID bigint
  , journalStateOK bit
  , assocWithSvcRecApproval bit
  , svcRecApprovalSystem bigint
  , svcRecApprovalID bigint
  , svcRecApprovalStateOK int
  , orpRequired bit
  , claimIsOrpCompliant bit
  , waitingForPracSupApproval bit
  , waitingForJournal bit
  , waitingForValidOrp bit
  , unitType_1 varchar(50)
  , unitType_2 varchar(50)

  UNIQUE CLUSTERED (
    svcRecID
  )

)

/*###########################################################################
  # Get service slots
  ###########################################################################*/    

insert into @service_slots
select
  sr.*
from dbo.SERVICE_SLOTS_VIEW_CORE (@clientID, @oldestDOS, @newestDOS) as sr
where (    
      (sr.ValidBic      = 1)    /* Patient has a valid BIC */
  and (sr.PartOfProxy1  = 0)    /* Prevents dup proxy */
  and (sr.PartOfProxy2  = 0)
)

/*###########################################################################
  # Get recurring services for hold and proxy
  ###########################################################################*/    

insert into @recs

select
      sr.*  
    , [numMinsExpected]  = rs.numMinsExpected
    , [numTripsExpected] = rs.numTripsExpected
    , [numSvcsExpected]  = rs.numSvcsExpected

from @service_slots as sr

cross apply ( 
   
  select top 1
       expectedFound    = 1  
     , numMinsExpected  = numMinsExpd
     , numTripsExpected = 0  
     , numSvcsExpected  = 0
    
    from dbo.RECURRING_SERVICES_MIN_BASED_PROCS_EXPD_SUMMARY (
        @clientID
      , null
      , null
      , sr.dos
      , dbo.CONST_SERVICES_TREATMENT()
      , null                                                            
      , null
      , 1
      , 1) as mpe

    where (
          (mpe.clientID = sr.clientID)
      and (mpe.patID    = sr.patID)
      and (mpe.procID   = sr.procID1)
      and (sr.svcType  = dbo.CONST_SERVICES_TREATMENT())
    )
) as rs

/*###########################################################################
  # Get transportation for hold and proxy
  # Exclude recs that were already included
  ###########################################################################*/    

insert into @recs
select
      sr.*  
    , [numMinsExpected]  = 0
    , [numTripsExpected] = 2  /* Expect at most 2 trips */
    , [numSvcsExpected]  = 0
from      @service_slots as sr
left join @recs          as r on r.svcRecID = sr.svcRecID
where ( 
      (sr.svcType = dbo.CONST_SERVICES_TRANSPORT())
  and (r.svcRecID is null)
)


/*###########################################################################
  # Get TCM for aggregation and proxy
  # Exclude recs that were already included
  ###########################################################################*/    

insert into @recs
select
      sr.*  
    , [numMinsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numTripsExpected] = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numSvcsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
from      @service_slots as sr
left join @recs          as r on r.svcRecID = sr.svcRecID
where (
      (sr.svcType = dbo.CONST_SERVICES_TCM())
  and (r.svcRecID is null)
)

/*###########################################################################
  # Get minute based assessements for aggregation and proxy
  # Note: This excludes encouter based assessements
  # Exclude recs that were already included
  ###########################################################################*/    

insert into @recs
select
      sr.*  
    , [numMinsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numTripsExpected] = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numSvcsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
from      @service_slots as sr
left join @recs          as r on r.svcRecID = sr.svcRecID
where ( 
      (sr.svcType = dbo.CONST_SERVICES_ASSESS())
  and (sr.unitType_1  = 'MINUTES')
  and (r.svcRecID is null)
)

/*###########################################################################
  # Get treatments (minute based) for aggregation and proxy
  # This excludes encounter based treatments and excludes recs that 
  # were already included.... including recurring service treatments.
  ###########################################################################*/    

insert into @recs
select
      sr.*  
    , [numMinsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numTripsExpected] = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numSvcsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
from      @service_slots as sr
left join @recs          as r on r.svcRecID = sr.svcRecID
where ( 
      (sr.svcType = dbo.CONST_SERVICES_TREATMENT())
  and (sr.unitType_1  = 'MINUTES')
  and (r.svcRecID is null)
)

/*###########################################################################
  # Get any remaining services associated with the service journal 
  # or services waiting for approval or services that require an ORP.  
  # 
  # The claims release routine will exclude these from consideration.
  #
  # We pass these on because we want the info in any diagnostic or problem
  # finding queries we may want to run 
  #
  # Exclude recs that were already included
  #
  # NOTE: THIS NEEDS TO BE THE LAST PASS!!!!!!
  #
  ###########################################################################*/    

insert into @recs
select
      sr.*  
    , [numMinsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numTripsExpected] = 0 /* Set to 0 for aggregation between transmissions mode */
    , [numSvcsExpected]  = 0 /* Set to 0 for aggregation between transmissions mode */
from      @service_slots as sr
left join @recs          as r on r.svcRecID = sr.svcRecID
where ( 
      ((sr.assocWithJournal = 1) or (sr.assocWithSvcRecApproval = 1) or (sr.orpRequired = 1)) 
  and (r.svcRecID is null)
)


return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_TO_HOLD_VIEW_CORE] TO [webuser]
GO
  