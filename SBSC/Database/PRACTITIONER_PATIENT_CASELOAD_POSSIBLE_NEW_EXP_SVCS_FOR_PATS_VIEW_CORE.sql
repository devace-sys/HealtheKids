USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE] (
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT
  , @clientID            BIGINT
  , @pracID              BIGINT
  , @patsCsv             VARCHAR(max)
  , @loadCurrentCaseload bit   = 0
)    

RETURNS @newServices table (
	  patID                     bigint
	, patName                   varchar(256)
	, spEdServiceCode           int
	, spEdServiceName           varchar(256)
    , spEdFreqCode              int
	, spEdFreqName              varchar(256)
    , minsPerFreq               int
    , startDate                 date
	, startDateStr              varchar(50)
    , endDate                   date
	, endDateStr                varchar(50)
	, previousPPCESID           bigint default(-1)
    , expectedMinsInd           int           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, expectedMinsGrp           int           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, daysOfWeekSvcProvidedJSON varchar(max)  /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
    , hasSvcLinesDetails        bit
    , svcLinesDetailsJSON       varchar(max)
	, selected                  bit default(0)
)

BEGIN

 /***************************************************************************    
  * PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE */    
 /**    
  * 
  * @return Table of expected service data   
  ***************************************************************************/     

declare @today               as datetime
declare @todayYearFromNow    as datetime
declare @dfltExpSvcStartDate as date
declare @dfltExpSvcEndDate   as date

declare @planStartDate     as date
declare @planEndDate       as date
declare @curIdxPat         as int
declare @maxIdxPat         as int
declare @patID             as bigint
declare @patName           as varchar(256)
declare @inCaseload        as bit
declare @caseloadEntryID   as bigint
declare @numPossibleSvcs   as int

declare @curIdxSpEdSvc     as int
declare @maxIdxSpEdSvc     as int

declare @pats as table (
    idx                     int identity(1,1)
  , patID                   bigint
  , patName                 varchar(256)
  , inCaseload              bit default(0)
  , caseloadEntryID         bigint  
  unique clustered    (idx)
, unique nonclustered (patID, idx)
)

declare @svcCodesPracSupports as table (
  spEdSvcCode int
  unique clustered (spEdSvcCode)
)

set @today               = convert(date,getdate())
set @todayYearFromNow    = dateadd(year,1,@today)
set @planStartDate       = dbo.CALC_OLDEST_DOS_ALLOWED(@today)
set @planEndDate         = dateadd(month,13,@planStartDate)
set @dfltExpSvcStartDate = convert(date,@today)
set @dfltExpSvcEndDate   = convert(date,@todayYearFromNow)

/*############################################################################
 *# Get practitioner caseload pats and put in a CSV if required
 *############################################################################*/

if (@loadCurrentCaseload = 1)
begin
  set @patsCsv = ''
  select 
    @patsCSV = STRING_AGG(CONVERT(varchar(max),ppc.patID),',')
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  where (
        (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
  )
end

/*############################################################################
 *# Extract patient ids
 *############################################################################*/

insert into @pats (patID)
select distinct 
  q1.patID
from
(
  select 
    patID = convert(bigint,t1.[part]) 
  from dbo.STRING_SPLIT(@patsCSV,',',1) as t1
) as q1

update pats
set 
  pats.patName = pap.CONCAT_NAME
from @pats as pats
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pats.patID
join dbo.PATIENTS_Client  as pac on ((pac.CLIENT_ID = @clientID) and (pac.PATIENT_ID = pac.PATIENT_ID))

select @maxIdxPat = max(idx) from @pats
set    @curIdxPat = 1

/*############################################################################
 *# If no patient ids exit
 *############################################################################*/

if (@maxIdxPat = 0) return

/*############################################################################
 *# Determine which spEd service codes prac currently supports
 *# (this only has to be done once)
 *############################################################################*/

insert into @svcCodesPracSupports (
  spEdSvcCode
)
select 
  t1.spEdSvcCode
from dbo.Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core (@userID,@userGroup,@userRank,@clientID,@pracID) as t1

/*############################################################################
 *# Determine which patients are currently on caseload
 *############################################################################*/

update pats
set 
    pats.inCaseload      = 1
  , pats.caseloadEntryID = ppc.id
from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
join @pats                             as pats on pats.patID = ppc.patID
where ( 
      (ppc.clientID = @clientID)
  and (ppc.pracID   = @pracID)  
)

/*############################################################################
 *# For each patient
 *############################################################################*/

while (@curIdxPat <= @maxIdxPat)
begin

  /*############################################################################
   *# Init table that holds service codes that are currently on caseload for pat
   *############################################################################*/

  declare @svcCodesPatHas as table (
      spEdSvcCode               int
	, previousPPCESID           bigint default(-1)
	, expectedMinsInd           int
    , expectedMinsGrp           int
    , daysOfWeekSvcProvidedJSON varchar(max)
    unique clustered (spEdSvcCode)
  )

  delete @svcCodesPatHas

  /*############################################################################
   *# Init table that holds service codes to search for
   *############################################################################*/

  declare @svcCodesToSearch as table (
    spEdSvcCode int
    unique clustered (spEdSvcCode)
  )
  
  delete @svcCodesToSearch

  /*############################################################################
   *# Init table that holds possible services
   *############################################################################*/

  declare @possibleServices as table (
      patID                     bigint    
	, spEdServiceCode           int
    , spEdFreqCode              int
    , minsPerFreq               int
    , startDate                 date
    , endDate                   date
	, previousPPCESID           bigint default(-1)
	, expectedMinsInd           int          /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
    , expectedMinsGrp           int          /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
    , daysOfWeekSvcProvidedJSON varchar(max) /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
    , hasSvcLinesDetails        bit
    , svcLinesDetailsJSON       varchar(max)
    , selected                  bit default(0)
    unique clustered (patID, spEdServiceCode, spEdFreqCode, minsPerFreq, startDate)
  )

  delete @possibleServices

  /*############################################################################
   *# Get patient info
   *############################################################################*/

  select top 1 
      @patID           = p.patID 
    , @patName         = p.patName
    , @inCaseload      = p.inCaseload
    , @caseloadEntryID = p.caseloadEntryID
  from @pats as p 
  where 
    (p.idx = @curIdxPat)

  /*############################################################################
   *# If patient is part of this pracs caseload
   *############################################################################*/

  if (@inCaseload = 1)
  begin

	/*############################################################################
     *# Get service codes already on caseload for pat
     *############################################################################*/

    insert into @svcCodesPatHas (
	   spEdSvcCode
	 , previousPPCESID
	 , expectedMinsInd           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	 , expectedMinsGrp           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	 , daysOfWeekSvcProvidedJSON /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	)
    select 
        q1.spEdSvcCode
      , q1.previousPPCESID
	  , q1.expectedMinsInd
      , q1.expectedMinsGrp
      , q1.daysOfWeekSvcProvidedJSON
    from
    (
     select 
	      spEdSvcCode = ppces.spEdServiceCode 
	    , previousPPCESID = ppces.id
		, ppces.expectedMinsInd
	    , ppces.expectedMinsGrp
	    , ppces.daysOfWeekSvcProvidedJSON
	    , ranking = DENSE_RANK() over(partition by ppces.spEdServiceCode order by ppces.startDate desc, ppces.id desc)
	  from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
	  where (
            (ppces.caseloadEntryID  = @caseloadEntryID)
  	    and (ppces.svcTrackingClass = 100)
        and (ppces.active           = 1)
      )
  ) as q1
  where 
    (q1.ranking = 1)
	/*
	select distinct
	  spEdSvcCode = ppces.spEdServiceCode 
	from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces
	where (
          (ppces.caseloadEntryID  = @caseloadEntryID)
  	  and (ppces.svcTrackingClass = 100)
      and (ppces.active           = 1)
    )
	*/
  end

  /*############################################################################
   *# Get service codes to search for
   *# (what prac supports + what is on caseload for patient)
   *############################################################################*/

  insert into @svcCodesToSearch (spEdSvcCode)
  select 
    t3.spEdSvcCode
  from
  (
    select t1.spEdSvcCode from @svcCodesPracSupports as t1
    union
    select t2.spEdSvcCode from @svcCodesPatHas       as t2
  ) as t3

  /*############################################################################
   *# Get all possible SpEd services 
   *############################################################################*/

  insert into @possibleServices (
	  patID
    , spEdServiceCode
    , spEdFreqCode
    , minsPerFreq 
    , startDate 
    , endDate 
    , hasSvcLinesDetails  
    , svcLinesDetailsJSON 
  )
  select 
      pps2.patID
	, pps2.spEdServiceCode
    , pps2.spEdFreqCode
    , pps2.minsPerFreq
    , pps2.startDate
    , pps2.endDate	 
	, pps2.hasSvcLinesDetails
	, pps2.svcLinesDetailsJSON
  from
  (
    select        
        ranking = DENSE_RANK() over(partition by pps1.patID, pps1.spEdServiceCode order by pps1.startDate desc, pps1.ppsID desc)
      , pps1.*
    from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (  @clientID
	                                                , @patID
													, null
													, null
													, null
													, null
													, null
													, @planStartDate
													, @planEndDate
													, null
													, null) as pps1
	join @svcCodesToSearch                                  as scps on scps.spEdSvcCode = pps1.spEdServiceCode
  ) as pps2
  where 
    (pps2.ranking = 1)
  
  /*############################################################################
   *# If patient is part of this pracs caseload
   *############################################################################*/

  if (@inCaseload = 1)
  begin

	/*############################################################################
     *# Remove any possible services that are already on caseload
     *############################################################################*/

    delete ps  /* Note: This deletes rows from the TABLE VARIABLE */
    from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces  
    join @possibleServices                                   as ps     on  ((ps.patID           = ppces.patID)
	  		    	  												   and (ps.spEdServiceCode  = ppces.spEdServiceCode)
                                                                       and (ps.spEdFreqCode     = ppces.spEdFreqCode)
                                                                       and (ps.minsPerFreq      = ppces.minsPerFreq)
                                                                       and (ps.startDate        = ppces.startDate))

    where (
          (ppces.caseloadEntryID  = @caseloadEntryID)
  	  and (ppces.svcTrackingClass = 100)
      and (ppces.active           = 1)
    )
  
    /*############################################################################
     *# Flag what is left as selected if the possible service represents a 
	 *# spEd service that was already on the caseload (we assume the prac is 
	 *# going to continue the service)
     *############################################################################*/

	 update ps
	 set 
	     ps.selected                  = 1	
	   , ps.previousPPCESID           = scph.previousPPCESID
	   , ps.expectedMinsInd           = scph.expectedMinsInd           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	   , ps.expectedMinsGrp           = scph.expectedMinsGrp           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	   , ps.daysOfWeekSvcProvidedJSON = scph.daysOfWeekSvcProvidedJSON /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	 from @possibleServices as ps
	 join @svcCodesPatHas   as scph on scph.spEdSvcCode = ps.spEdServiceCode

  end

  /*############################################################################
   *# If patient is not part of this pracs caseload
   *############################################################################*/

  else  
  begin

    set @numPossibleSvcs = 0
	select @numPossibleSvcs = count(ps.patID) from @possibleServices as ps

	/*############################################################################
     *# And there are no possible services
     *############################################################################*/

	if (@numPossibleSvcs = 0)
	begin
  	  
	  /*############################################################################
       *# Create a generic "any treatment" service and flag as selected
       *############################################################################*/

	  insert into @possibleServices (
	      patID		
        , spEdServiceCode
        , spEdFreqCode
        , minsPerFreq 
        , startDate 
        , endDate 
        , hasSvcLinesDetails  
        , svcLinesDetailsJSON 
		, selected
      )
	  values (
	      @patID
		, null
		, 90 /* Freq code for other since we dont know */
		, 15  /* 15 minute to start since we dont know */
		, @dfltExpSvcStartDate
		, @dfltExpSvcEndDate
		, 0
		, null 
		, 1
	  )
	end /* No possible svcs for pat not on caseload */
    
	/*############################################################################
     *# And there are possible services
     *############################################################################*/

	else  
  	begin  
	
	  /*############################################################################
       *# Preselect all services for this new patient
       *############################################################################*/

      update @possibleServices set selected = 1
	
	end /* There are possible services*/

  end /* Pat is not on caseload */

  /*############################################################################
   *# Add services to output
   *############################################################################*/

  insert into @newServices (
      patID  
	, patName
    , spEdServiceCode
	, spEdServiceName
    , spEdFreqCode
	, spEdFreqName 
    , minsPerFreq  
    , startDate 
	, startDateStr
    , endDate 
	, endDateStr
	, previousPPCESID
	, expectedMinsInd           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, expectedMinsGrp           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */       
	, daysOfWeekSvcProvidedJSON /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */

    , hasSvcLinesDetails 
    , svcLinesDetailsJSON 
	, selected
  )
  select 
      patID           = @patID
	, patName         = @patName
	, ps.spEdServiceCode
    , spEdServiceName = isnull(ss.name,'Any Treatment') 
    , ps.spEdFreqCode 	
    , spEdFreqName    = isnull(ssf.name,'')
	, ps.minsPerFreq 
    , ps.startDate
	, startDateStr = dbo.RPT_DATE_FMT(ps.startDate) 
    , ps.endDate 
	, endDateStr   = dbo.RPT_DATE_FMT(ps.endDate)
	, ps.previousPPCESID
    , ps.expectedMinsInd           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, ps.expectedMinsGrp           /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
	, ps.daysOfWeekSvcProvidedJSON /* TODO: This field is no longer used, it has been replaced with dedicated schedule system.  Refactor out when possible. */
    , ps.hasSvcLinesDetails
    , ps.svcLinesDetailsJSON 
	, ps.selected
  from      @possibleServices          as ps
  left join dbo.SpEd_Service           as ss  on ss.codeValue   = ps.spEdServiceCode
  left join dbo.SpEd_Service_Frequency as ssf on ssf.codeValue  = ps.spEdFreqCode
  
  set @curIdxPat = @curIdxPat + 1
end


return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_POSSIBLE_NEW_EXP_SVCS_FOR_PATS_VIEW_CORE] TO [webuser]
GO
