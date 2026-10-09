USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATE_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATE_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATE_CORE] (    
    @patID                  bigint
  , @spEdSvcCode            int
  , @startDate              datetime
  , @endDate                datetime
  , @spEdFreqCode           int
  , @minsPerFreq            int 
  , @minsPerFreqAssigned    int
  , @hasSvcDetails          bit
  , @svcDetailsJSON         varchar(max)
  , @svcTrackingClass       int
  , @created                datetime
  , @lastModified           datetime
  , @updateToNewerPlan      bit = 0
)

/* Note: Only returns one rec */

returns @recs table (
    spEdSvcCode                        int
  , startDate                          datetime
  , endDate                            datetime
  , spEdFreqCode                       int
  , minsPerFreq                        int
  , minsPerFreqAssigned                int
  , hasSvcDetails                      bit
  , svcDetailsJSON                     varchar(max)
  , matchQuality                       int
  , createdOrLastModified              datetime
  , startDateChanged                   bit
  , endDateChanged                     bit
  , freqCodeChanged                    bit
  , minsPerFreqChanged                 bit
  , hasSvcDetailsChanged               bit
  , svcDetailsJSONChanged              bit
  , minsPerFreqAssignedWasRecalculated bit default(0) 
  , matchFound                         bit default(0)
  , updateNeeded                       bit default(0)
)     
as
begin

declare @noStartDate as bit = 0
declare @today       as datetime = convert(date,getdate())

if (@svcTrackingClass != dbo.CONST_SVC_TRACKING_CLASS_SPED()) return
if (@patID       is null) return
if (@spEdSvcCode is null) return

if (@updateToNewerPlan = 1)
begin
  set @startDate = @today
  set @endDate   = DATEADD(year,1,@startDate)
end

if (@startDate is null) 
begin
  set @noStartDate = 1
  set @startDate = convert(date,(coalesce(@lastModified,@created,@today)))
  set @endDate   = DATEADD(year,1,@startDate)
end

if (@endDate             is null)   set @endDate             = DATEADD(year,1,@startDate)
if (@spEdFreqCode        is null)   set @spEdFreqCode        = -1
if (@minsPerFreq         is null)   set @minsPerFreq         = -1
if (@minsPerFreqAssigned is null)   set @minsPerFreqAssigned = -1
if (@hasSvcDetails       is null)   set @hasSvcDetails       = 0
if (@svcDetailsJSON      is null)   set @svcDetailsJSON      = '{}'

declare @matchFound as bit = 0
set @matchFound = 0

/*###########################################################################
  # 1. Exact matches
  ###########################################################################*/
  
  insert into @recs (
      spEdSvcCode
    , startDate
    , endDate
    , spEdFreqCode
    , minsPerFreq 
	, hasSvcDetails
    , svcDetailsJSON
    , matchQuality
	, createdOrLastModified
  )
  select top 1    
	  pps.spEdServiceCode
	, pps.startDate
	, pps.endDate
	, pps.spEdFreqCode      
	, pps.minsPerFreq
	, pps.hasSvcLinesDetails
	, pps.svcLinesDetailsJSON
	, matchQuality = 1
   	, createdOrLastModified = coalesce(pps.lastModified,pps.created)
  from dbo.PATIENTS_PROMISED_SERVICES as pps
  where (
        /* [PAT_ID_IDX]*/
		((pps.patID              = @patID)
    and (pps.spEdServiceCode     = @spEdSvcCode)
	and (pps.active              = 1)
	and (pps.id is not null))
	and (pps.startDate           = @startDate)
	and (pps.endDate             = @endDate)
	and (pps.spEdFreqCode        = @spEdFreqCode)    
	and (pps.minsPerFreq         = @minsPerFreq)
    and (@noStartDate = 0)
  )
  order by 
    pps.fromSpEdDataFiles desc /* Prioritize sped data files */
  option(recompile)

  if exists (select top 1 t1.spEdSvcCode from @recs as t1) set @matchFound = 1

/*###########################################################################
  # 2. All except end date
  ###########################################################################*/

if (@matchFound = 0)
begin
  insert into @recs (
      spEdSvcCode
    , startDate
    , endDate
    , spEdFreqCode
    , minsPerFreq 
	, hasSvcDetails
    , svcDetailsJSON
    , matchQuality
	, createdOrLastModified
  )
  select top 1 
	  pps.spEdServiceCode
	, pps.startDate
	, pps.endDate
	, pps.spEdFreqCode      
	, pps.minsPerFreq
	, pps.hasSvcLinesDetails
	, pps.svcLinesDetailsJSON
	, matchQuality = 2
    , createdOrLastModified = coalesce(pps.lastModified,pps.created)
  from dbo.PATIENTS_PROMISED_SERVICES as pps
  where (
        /* [PAT_ID_IDX]*/
		((pps.patID              = @patID)
    and (pps.spEdServiceCode     = @spEdSvcCode)
	and (pps.active              = 1)
	and (pps.id is not null))
	and (pps.startDate           = @startDate)
	and (pps.spEdFreqCode        = @spEdFreqCode)    
	and (pps.minsPerFreq         = @minsPerFreq)
    and (@noStartDate = 0)
  )
  order by 
    pps.fromSpEdDataFiles desc /* Prioritize sped data files */
  option(recompile)

  if exists (select top 1 t1.spEdSvcCode from @recs as t1) set @matchFound = 1
end /* matchFound */


/*###########################################################################
  # 3. All except end date and mins per freq
  ###########################################################################*/

if (@matchFound = 0)
begin
  insert into @recs (
      spEdSvcCode
    , startDate
    , endDate
    , spEdFreqCode
    , minsPerFreq 
	, hasSvcDetails
    , svcDetailsJSON
    , matchQuality
	, createdOrLastModified
  )
  select top 1   
	  pps.spEdServiceCode
	, pps.startDate
	, pps.endDate
	, pps.spEdFreqCode      
	, pps.minsPerFreq
	, pps.hasSvcLinesDetails
	, pps.svcLinesDetailsJSON
	, matchQuality = 3
	, createdOrLastModified = coalesce(pps.lastModified,pps.created)
  from dbo.PATIENTS_PROMISED_SERVICES as pps
  where (
        /* [PAT_ID_IDX]*/
		((pps.patID              = @patID)
    and (pps.spEdServiceCode     = @spEdSvcCode)
	and (pps.active              = 1)
	and (pps.id is not null))

	and (pps.startDate           = @startDate)
	and (pps.spEdFreqCode        = @spEdFreqCode)    
    and (@noStartDate = 0)
  )
  order by 
    pps.fromSpEdDataFiles desc /* Prioritize sped data files */
  option(recompile)

  if exists (select top 1 t1.spEdSvcCode from @recs as t1) set @matchFound = 1
end /* matchFound */


/*###########################################################################
  # 4. All except end date and mins per freq and freq code
  ###########################################################################*/

if (@matchFound = 0)
begin
  insert into @recs (
      spEdSvcCode
    , startDate
    , endDate
    , spEdFreqCode
    , minsPerFreq 
	, hasSvcDetails
    , svcDetailsJSON
    , matchQuality
	, createdOrLastModified
  )
  select top 1      
	  pps.spEdServiceCode
	, pps.startDate
	, pps.endDate
	, pps.spEdFreqCode      
	, pps.minsPerFreq
	, pps.hasSvcLinesDetails
	, pps.svcLinesDetailsJSON
	, matchQuality = 4
	, createdOrLastModified = coalesce(pps.lastModified,pps.created)
  from dbo.PATIENTS_PROMISED_SERVICES as pps
  where (
        /* [PAT_ID_IDX]*/
		((pps.patID              = @patID)
    and (pps.spEdServiceCode     = @spEdSvcCode)
	and (pps.active              = 1)
	and (pps.id is not null))

	and (pps.startDate           = @startDate)
	and (@noStartDate = 0)
  )
  order by 
    pps.fromSpEdDataFiles desc /* Prioritize sped data files */
  option(recompile)

  if exists (select top 1 t1.spEdSvcCode from @recs as t1) set @matchFound = 1
end /* matchFound */

/*###########################################################################
  # 5. All except end date and mins per freq and freq code and start date
  # Will try to find the closest start date
  ###########################################################################*/

if (@matchFound = 0)
begin
  insert into @recs (
      spEdSvcCode
    , startDate
    , endDate
    , spEdFreqCode
    , minsPerFreq 
	, hasSvcDetails
    , svcDetailsJSON
    , matchQuality
	, createdOrLastModified
  )
  select top 1
	  pps.spEdServiceCode
	, pps.startDate
	, pps.endDate
	, pps.spEdFreqCode      
	, pps.minsPerFreq
	, pps.hasSvcLinesDetails
	, pps.svcLinesDetailsJSON
	, matchQuality = 5
	, createdOrLastModified = coalesce(pps.lastModified,pps.created)
  from dbo.PATIENTS_PROMISED_SERVICES as pps
  where (
        /* [PAT_ID_IDX]*/
		((pps.patID              = @patID)
    and (pps.spEdServiceCode     = @spEdSvcCode)
	and (pps.active              = 1)
	and (pps.id is not null))

	and (@startDate between pps.startDate and pps.endDate)	
  )
  order by 
    pps.fromSpEdDataFiles desc /* Prioritize sped data files */
  option(recompile)

  if exists (select top 1 t1.spEdSvcCode from @recs as t1) set @matchFound = 1
end /* matchFound */

/*###########################################################################
  # Nothing found.  Pass back original values
  ###########################################################################*/

if (@matchFound = 0)
begin
  insert into @recs (
      spEdSvcCode
    , startDate
    , endDate
    , spEdFreqCode
    , minsPerFreq 
	, minsPerFreqAssigned
	, hasSvcDetails
    , svcDetailsJSON
    , matchQuality
	, matchFound
	, updateNeeded    
   )
   values (
       @spEdSvcCode
	 , @startDate
	 , @endDate
	 , @spEdFreqCode
	 , @minsPerFreq
	 , @minsPerFreqAssigned
	 , @hasSvcDetails
	 , @svcDetailsJSON
	 ,-1
	 , 0
	 , 0	 
   )
end /* matchFound is no */

/*###########################################################################
  # Match found
  ###########################################################################*/

else
begin

/*###########################################################################
  # Check for changes
  ###########################################################################*/

  update t1
  set
      t1.startDateChanged      = iif((t1.startDate      != @startDate),      1,0)
    , t1.endDateChanged        = iif((t1.endDate        != @endDate),        1,0)
    , t1.freqCodeChanged       = iif((t1.spEdFreqCode   != @spEdFreqCode),   1,0)
    , t1.minsPerFreqChanged    = iif((t1.minsPerFreq    != @minsPerFreq),    1,0)
    , t1.hasSvcDetailsChanged  = iif((t1.hasSvcDetails  != @hasSvcDetails),  1,0)
    , t1.svcDetailsJSONChanged = iif((t1.svcDetailsJSON != @svcDetailsJSON), 1,0)
    , t1.matchFound            = 1
  
  from @recs as t1

  update @recs
  set 
    updateNeeded = 1	
  where ( 
       (startDateChanged      = 1) 
    or (endDateChanged        = 1)
    or (freqCodeChanged       = 1)
    or (minsPerFreqChanged    = 1)
    or (hasSvcDetailsChanged  = 1)
    or (svcDetailsJSONChanged = 1)
  )

  /* If minutes per frequency changed */

  if exists (select top 1 spEdSvcCode from @recs where minsPerFreqChanged = 1)
  begin
  
    /* Determine what the new value of minsPerFrequencyAssigned should be.*/

    /* Previous assignment was the total so we keep that ratio */

    if (@minsPerFreq = @minsPerFreqAssigned)
    begin
      update @recs 
	  set 
	     minsPerFreqAssigned                = minsPerFreq
       , minsPerFreqAssignedWasRecalculated = 0     
    end /* no change to ratio */
  
    /* Previous assignment was a percentage of the total so we need to calculate that percent to 
     * derive what the new assigment is (approximately).  User may still need to change it.
     */

    else
    begin
  
	  declare @minsPerFreqReal         as real
      declare @pctMinsAssigned         as real
	  declare @minsPerFreqAssignedReal as real
	  declare @minsPerFreqAssignedNew  as int

	  select top 1 @minsPerFreqReal = convert(real,t1.minsPerFreq) from @recs as t1
      set @pctMinsAssigned = dbo.CALC_PERCENTAGE (@minsPerFreqAssigned, @minsPerFreq,0,1,2)
	  set @minsPerFreqAssignedReal = (@minsPerFreqReal * @pctMinsAssigned)
      set @minsPerFreqAssignedNew  = floor(@minsPerFreqAssignedReal)
	
	  update @recs 
	  set 
	    minsPerFreqAssigned = @minsPerFreqAssignedNew
	  , minsPerFreqAssignedWasRecalculated = 1    
    end /* ratio changed */
  end /* Mins per freq changed */

  /* Mins per freq did not change */

  else
  begin
    update @recs 
      set minsPerFreqAssigned = minsPerFreq    
  end /* Mins per freq did not change */

end /* matchFound is yes */



return

end

 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_VIEW_PPS_UPDATE_CORE] TO [webuser]
GO