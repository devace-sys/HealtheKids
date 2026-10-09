USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TO_RELEASE_VIEW_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TO_RELEASE_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_TO_RELEASE_VIEW_CORE] (
    @clientID  AS bigint
  , @oldestDOS AS datetime
  , @newestDOS as datetime
  , @today     AS datetime )

/***************************************************************************    
 * CLAIMS_TO_RELEASE_VIEW_CORE */    
/**    
 * Returns a table of claims that are ready to be released and in the case
 * of claims that should be released as part of a proxy, computes neccessary
 * proxy claim data.
 *
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 * @param   today           Todays date (passed in)
 ***************************************************************************/        

returns

@recs table (
  clientID bigint
, dos datetime
, patID bigint
, svcType int
, minBased bit
, mileBased bit
, procID1 bigint
, procID2 bigint
, min_units_1 int
, max_units_1 int
, totNumMinsExpd int
, totNumTripsExpd int
, totNumSvcsExpd  int
, client_name varchar(500)
, patient_name varchar(500)
, minEntryDateTime datetime
, maxEntryDateTime datetime
, totNumSvcRecs int
, totNumEnteredBySBSC int
, totNumEnteredByClient int
, totNumMinsRecv int
, totNumTripsRecv int
, totNumMilesRecv decimal (7,1)
, totNumUnitsRecv1 int
, totNumUnitsRecv2 int
, svcRecIDStrs nvarchar(max)
, clmID1Strs nvarchar(max)
, clmID2Strs nvarchar(max)
, Proxy_Send_Override int
, UseOrLoseStatus int
, ServiceAgeInMonths int
, MinEntryAgeInDays int
, MaxEntryAgeInDays int
, AllEnteredBySBSC int
, AllEnteredByClient int
, EnteredToday int
, EnteredAtLeast45DaysAgo int
, RecvMaxUnits int
, RecvExpdMins int
, RecvExpdTrips int
, RecvExpdSvcs  int
, PrefServiceReceived int
, UnitLimitReached int
, HoldUntilNextTrans int
, HoldLimitsReached int
, Sendable int
, ProxyNeeded int
)

AS
BEGIN


declare @claims_to_hold as table (

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
, numMinsExpected int
, numTripsExpected int
, numSvcsExpected int

/* Note clustered index is same order as where statements in for xml parts of cte_p3 */
unique clustered (
  clientID
, dos
, patID
, svcType
, minBased
, mileBased
, procID1
, procID2
, min_Units_1
, max_Units_1
, svcRecID
)

)

declare @override_check as table (
 id bigint

 unique clustered (
   id
 )

)

/*###########################################################################
  # Get list of claims that have been held or will be held
  # 
  # Note: This list is limited to services that have claims and have not been 
  # submitted yet and for where we can submit the claim.  
  #
  # We are excluding 
  #
  # - Claims from service records that require a supervising practitioner 
  #   to approve and we have not received approval yet or approval was not
  #   given.
  #
  # - Claims associated with closed journals where any service records are 
  #   waiting for approval
  #
  # - Claims associated with reopened service journals
  #
  # - Claims that do not have a valid ORP
  #
  #    ^    VERY IMPORTANT 
  #   / \   THIS EXCLUSION CHECK HAS TO BE REPEATED IN THE "BUCKET ROUTINE"
  #  / ! \  TRANSMISSION_GENERATION_APPLY_HOLDS.sql
  #  -----  
  #
  ###########################################################################*/    

insert into @claims_to_hold
select * 
from dbo.CLAIMS_TO_HOLD_VIEW_CORE (@clientID, @oldestDOS, @newestDOS) 
where ( 
        (waitingForPracSupApproval = 0) /* Only include services that we are NOT waiting for prac sup approval on */
    and (waitingForJournal         = 0) /* Only include services that are NOT waiting for a journal to be ready */
    and (waitingForValidOrp        = 0) /* Only include services that are NOT waiting for a valid ORP */
)

/*###########################################################################
  # Hold/Proxy Override Check
  # We want to override the Sendable flag if:
  #   1. Service record is listed in the override table
  #   2. Service record has the same patient/procedure/svc_date
  #      as the originally overridden service record in point 1
  ###########################################################################*/    

insert into @override_check
select distinct
  sr_all_override.id
from dbo.SERVICE_RECORDS_PROXY_OVERRIDE as srpo
join dbo.service_records                as sr_orig         on srpo.svcrec_id = sr_orig.id
join dbo.service_records                as sr_all_override on sr_orig.dos       = sr_all_override.dos
                                                           and sr_orig.patid    = sr_all_override.patid
                                                           and sr_orig.nameid   = sr_all_override.nameid
                                                           and sr_orig.groupid  = sr_all_override.groupid
                                                           and sr_orig.clientid = sr_all_override.clientid

;

/*###########################################################################
  # Claims to hold 'pointer'
  ###########################################################################*/    

with
cte_hold_claims
as
(
  select * from @claims_to_hold 
)
,

/*###########################################################################
  # Hold/Proxy Override Check 'pointer'
  ###########################################################################*/    

cte_override_check
as
(
  select id from @override_check     
)
,

/*###########################################################################
  # Output Pass 1
  # 
  # Combine and aggregate like claims and create detail lines of service and
  # claim record ids.
  ###########################################################################*/    

cte_output_pass_1
as
(
  select
 
    /*-------------------------------
     * Combinations
     *------------------------------*/
   
    clientID,
    dos,
    patID,    
    svcType,
    minBased,
    mileBased,
    procID1,
    procID2,
    min_units_1,
    max_units_1,
    numMinsExpected  AS totNumMinsExpd,  /* Note: Dont sum this.  Rename is just for clarity */
    numTripsExpected AS totNumTripsExpd, /* Note: Dont sum this.  Rename is just for clarity */
    numSvcsExpected AS totNumSvcsExpd,
    client_name,    
    patient_name,

    /*-------------------------------
     * Aggregates
     *------------------------------*/
    
    min(created)           AS minEntryDateTime,
    max(created)           AS maxEntryDateTime,
    count(svcRecID)        AS totNumSvcRecs,  /* TODO: Use this for total encounter release*/
    sum(convert(int,enteredBySBSC))     AS totNumEnteredBySBSC,
    sum(convert(int,enteredByClient))   AS totNumEnteredByClient,
    sum(numMins)           AS totNumMinsRecv,
    sum(numTrips)          AS totNumTripsRecv,
    sum(numMiles)          AS totNumMilesRecv,
    dbo.INT_CAPPED_AT_MAX (sum(claimUnits1), max_units_1) AS totNumUnitsRecv1,  /* 1st claim */
    dbo.INT_CAPPED_AT_MAX (sum(claimUnits2), max_units_2) AS totNumUnitsRecv2,  /* 2nd claim */

    /*-------------------------------
     * Detail lists
     *------------------------------*/
               
    [svcRecIDStrs] = substring((SELECT ( ', ' + t2.svcRecIDStr)
                from cte_hold_claims AS t2
                where
                      (t1.clientID           = t2.clientID)           AND
                      (t1.dos                = t2.dos)                AND
                      (t1.patID              = t2.patID)              AND
                      (t1.svcType            = t2.svcType)            AND
                      (t1.minBased           = t2.minBased)           AND
                      (t1.mileBased          = t2.mileBased)          AND                     
                      (t1.procID1            = t2.procID1)            AND              
                      (t1.procID2            = t2.procID2)            AND                    
                      (t1.min_units_1        = t2.min_units_1)        AND
                      (t1.max_units_1        = t2.max_units_1)        AND
                      (t1.min_units_2        = t2.min_units_2)        AND
                      (t1.max_units_2        = t2.max_units_2)        AND
                      (t1.numMinsExpected    = t2.numMinsExpected)    AND
                      (t1.numTripsExpected   = t2.numTripsExpected)   AND
                      (t1.numSvcsExpected    = t2.numSvcsExpected)    AND
                      (t1.client_name        = t2.client_name)        AND
                      (t1.patient_name       = t2.patient_name)       
                                                     
                for xml path ( '' )), 3, 1000 ),    
                             
   /*-------------------------------
    * Create list of claim rec ids
    * for svc rec claim 1
    *------------------------------*/
               
   [clmID1Strs] = substring((SELECT ( ', ' + t2.claimID1Str)
                FROM cte_hold_claims AS t2
                WHERE
                      (t1.clientID           = t2.clientID)           AND
                      (t1.dos                = t2.dos)                AND
                      (t1.patID              = t2.patID)              AND
                      (t1.svcType            = t2.svcType)            AND
                      (t1.minBased           = t2.minBased)           AND
                      (t1.mileBased          = t2.mileBased)          AND                     
                      (t1.procID1            = t2.procID1)            AND              
                      (t1.procID2            = t2.procID2)            AND                
                      (t1.min_units_1        = t2.min_units_1)        AND
                      (t1.max_units_1        = t2.max_units_1)        AND
                      (t1.min_units_2        = t2.min_units_2)        AND
                      (t1.max_units_2        = t2.max_units_2)        AND
                      (t1.numMinsExpected    = t2.numMinsExpected)    AND
                      (t1.numTripsExpected   = t2.numTripsExpected)   AND                                 
                      (t1.numSvcsExpected    = t2.numSvcsExpected)    AND
                      (t1.client_name        = t2.client_name)        AND
                      (t1.patient_name       = t2.patient_name)       

                FOR xml path ( '' )), 3, 1000 ),

   /*-------------------------------
    * Create list of claim rec ids
    * for svc rec claim 2
    *------------------------------*/
   
   [clmID2Strs] = substring((SELECT ( ', ' + t2.claimID2Str)
                FROM cte_hold_claims AS t2
                WHERE
                      (t1.clientID           = t2.clientID)           AND
                      (t1.dos                = t2.dos)                AND
                      (t1.patID              = t2.patID)              AND
                      (t1.svcType            = t2.svcType)            AND
                      (t1.minBased           = t2.minBased)           AND
                      (t1.mileBased          = t2.mileBased)          AND                     
                      (t1.procID1            = t2.procID1)            AND              
                      (t1.procID2            = t2.procID2)            AND   
                      (t1.min_units_1        = t2.min_units_1)        AND
                      (t1.max_units_1        = t2.max_units_1)        AND
                      (t1.min_units_2        = t2.min_units_2)        AND
                      (t1.max_units_2        = t2.max_units_2)        AND
                      (t1.numMinsExpected    = t2.numMinsExpected)    AND
                      (t1.numTripsExpected   = t2.numTripsExpected)   AND
                      (t1.numSvcsExpected    = t2.numSvcsExpected)    AND
                      (t1.client_name        = t2.client_name)        AND
                      (t1.patient_name       = t2.patient_name)

                FOR xml path ( '' )), 3, 1000 ),
                
        [Proxy_Send_Override] = case when ovr.id IS NOT NULL then 1 else NULL end
                       
  from            cte_hold_claims        as t1
  left outer join cte_override_check     as ovr on t1.svcRecIDStr = ovr.id

  where (1=1)

  group by
    clientID,
    dos,
    patID,
    svcType,
    minBased,
    mileBased,
    procID1,
    procID2,
    min_units_1,
    max_units_1,
    min_units_2,
    max_units_2,
    numMinsExpected,
    numTripsExpected,
    numSvcsExpected,    
    client_name,
    patient_name,
    case when ovr.id IS NOT NULL then 1 else NULL end
)
,

/*###########################################################################
  # Output Pass 2
  # Calculate dos and entry date criteria
  # Determine user group who entered
  ###########################################################################*/    

cte_output_pass_2
as
(
  select
    p1.*,  
    [UseOrLoseStatus]     = dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM (p1.dos, @today),
    [ServiceAgeInMonths]  = dbo.CALC_AGE_IN_MONTHS (p1.dos,              @today),
    [MinEntryAgeInDays]   = dbo.CALC_AGE_IN_DAYS   (p1.minEntryDateTime, @today),
    [MaxEntryAgeInDays]   = dbo.CALC_AGE_IN_DAYS   (p1.maxEntryDateTime, @today),
    [AllEnteredBySBSC]    = case when ([totNumEnteredByClient] = 0 ) then 1 else 0 end,
    [AllEnteredByClient]  = case when ([totNumEnteredBySBSC]   = 0 ) then 1 else 0 end
  from cte_output_pass_1 as p1
)
,

/*###########################################################################
  # Output Pass 3
  # Determine relative date of entry flags
  # Determine if we received max units, expected units, expected mins or trips  
  ###########################################################################*/    

cte_output_pass_3
as
(
  select 
  
    p2.*,
    [EnteredToday]            = case when ([MaxEntryAgeInDays]     = 0 ) then 1 else 0 end,   
    [EnteredAtLeast45DaysAgo] = case when ([MinEntryAgeInDays]    >= 45) then 1 else 0 end,
  
    [RecvMaxUnits] = case
      when  totNumUnitsRecv1  = max_units_1  then 1  /* We got all we need */
      when  totNumUnitsRecv1  > max_units_1  then 1  /* We got more than we need */
      when  totNumUnitsRecv1  < max_units_1  then 0  /* Not yet */
    end,
   
    [RecvExpdMins] = case
      when  totNumMinsExpd = totNumMinsRecv  then 1 /* We got all we are going to get */
      when  totNumMinsExpd < totNumMinsRecv  then 1 /* We got more than we expected */
      when  totNumMinsExpd > totNumMinsRecv  then 0 /* Not yet */
    end,
 
    [RecvExpdTrips] = case
      when  totNumTripsExpd = totNumTripsRecv  then 1 /* We got all we are going to get */
      when  totNumTripsExpd < totNumTripsRecv  then 1 /* We got more than we expected */
      when  totNumTripsExpd > totNumTripsRecv  then 0 /* Not yet */
    end, 
    
    [RecvExpdNumSvcs] = case
      when  totNumSvcsExpd = totNumSvcRecs  then 1 /* We got all we are going to get */
      when  totNumSvcsExpd < totNumSvcRecs  then 1 /* We got more than we expected */
      when  totNumSvcsExpd > totNumSvcRecs  then 0 /* Not yet */
    end 
    
  from cte_output_pass_2 as p2
)
,

/*###########################################################################
  # Output Pass 4
  #
  # Determine if we reached unit limits.  Determine if we should hold until
  # next transmission.
  ###########################################################################*/    

cte_output_pass_4
as
(
  select
 
    p3.*,
    [PrefServiceReceived] = 0, /* For future use */

    [UnitLimitReached] =
    case    
      when (minBased = 1) then
        case
          when  ([RecvExpdMins] = 0 AND [RecvMaxUnits] = 0) then 0
          when  ([RecvExpdMins] = 0 AND [RecvMaxUnits] = 1) then 1
          when  ([RecvExpdMins] = 1 AND [RecvMaxUnits] = 0) then 1
          when  ([RecvExpdMins] = 1 AND [RecvMaxUnits] = 1) then 1
        end
      when (mileBased = 1) then
        case
          when  ([RecvExpdTrips] = 0 AND [RecvMaxUnits] = 0) then 0
          when  ([RecvExpdTrips] = 0 AND [RecvMaxUnits] = 1) then 1
          when  ([RecvExpdTrips] = 1 AND [RecvMaxUnits] = 0) then 1
          when  ([RecvExpdTrips] = 1 AND [RecvMaxUnits] = 1) then 1
        end     
    end, 
    
    [HoldUntilNextTrans] = 0 /* no hold until next trans as of 20151204 -DW */
    
  from cte_output_pass_3 as p3
)
,

/*###########################################################################
  # Output Pass 5
  # Determine if we reached our hold limits
  ###########################################################################*/   

cte_output_pass_5
as
(
  select
 
    p4.*,
    
    [HoldLimitsReached] =
    case when (MinBased = 1) then
      case    
        when  ([PrefServiceReceived] = 0 AND [UnitLimitReached] = 0) then 0
        when  ([PrefServiceReceived] = 1 AND [UnitLimitReached] = 0) then 1
        when  ([PrefServiceReceived] = 0 AND [UnitLimitReached] = 1) then 1
        when  ([PrefServiceReceived] = 1 AND [UnitLimitReached] = 1) then 1    
      end
    when (mileBased = 1) then
      case
        when  ([EnteredAtLeast45DaysAgo] = 0 AND [UnitLimitReached] = 0) then 0
        when  ([EnteredAtLeast45DaysAgo] = 1 AND [UnitLimitReached] = 0) then 1
        when  ([EnteredAtLeast45DaysAgo] = 0 AND [UnitLimitReached] = 1) then 1
        when  ([EnteredAtLeast45DaysAgo] = 1 AND [UnitLimitReached] = 1) then 1
      end
    end 
  
  from cte_output_pass_4 as p4
)
,

/*###########################################################################
  # Output Pass 6
  # Determine if we should hold or send and if a proxy is needed
  ###########################################################################*/   

cte_output_pass_6
as
( 
  select

    p5.*,

    [Sendable] = case
      when   ([Proxy_Send_Override] = 1)                                 then 1
      when   ([UseOrLoseStatus]     = 1)                                 then 1
      when  (([RecvMaxUnits]        = 1) and ([HoldUntilNextTrans] = 0)) then 1     
      when  (([MinBased]  = 1) and ([RecvExpdMins]            = 1)  and ([HoldUntilNextTrans] = 0)) then 1 
      when  (([MinBased]  = 1) and ([PrefServiceReceived]     = 1)  and ([HoldUntilNextTrans] = 0)) then 1         
      when  (([MileBased] = 1) and ([RecvExpdTrips]           = 1)  and ([HoldUntilNextTrans] = 0)) then 1
      when  (([MileBased] = 1) and ([EnteredAtLeast45DaysAgo] = 1)  and ([HoldUntilNextTrans] = 0)) then 1    
      else 0
    end,
      
   [ProxyNeeded] = case when (totNumSvcRecs > 1) then 1 else 0 end 
 
  from cte_output_pass_5 as p5
)

/*###########################################################################
  # Output
  ###########################################################################*/   

insert into @recs
select * from cte_output_pass_6

return
end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_TO_RELEASE_VIEW_CORE] TO [webuser]
GO
  