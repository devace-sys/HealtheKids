/* TODO: Remove this procedure once we are fully comfortable with its replacement.
  Note: We are keeping this procedure available under a new name so we can run it if needed in production.*/

USE spedmon
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_And_Update_SpEd_Data_Old') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Parse_And_Update_SpEd_Data_Old
GO

/***************************************************************************    
 * Patient_Data_Imports_Parse_And_Update_SpEd_Data_Old */    
/**    
 * This routine completely replaces ALL records in PATIENTS_PROMISED_SERVICES
 * for a given @clientID using the data stored in 
 *
 *     [Import_From_A.5_SERVICES_From_Client_Files]     
 * and [Import_From_A.5_SERVICES_From_Client_File_Rows] 
 *
 * It is designed to fail silently if there is an issue and rollback
 * as to not disrupt other processes.
 *
 * IMPORTANT NOTE: Patients can have promised services with the same
 * spEd service code and date range but different frequencies and durations
 * This is usualy for seperate individual and group services.
 * 
 * The consolidation logic and overlap logic takes this into account
 ***************************************************************************/                         

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Parse_And_Update_SpEd_Data_Old] (
    @clientID          bigint
  , @completedNormally bit = 0 output
)
AS

BEGIN

/*###########################################################################*/
/*#  Init and setup                                                         #*/
/*###########################################################################*/

set nocount on

set @completedNormally = 0

begin try

exec dbo.PRINT_STATUS_MESSAGE 'Parsing and updating SpEd patient promised services'

/*###########################################################################*/
/*#  Setup working vars                                                     #*/
/*###########################################################################*/

declare @tranOpen     as bit          = 0
declare @today        as datetime     = getdate()
declare @minYear      as int          = 1988
declare @maxYear      as int          = 2100
declare @maxIdx       as int          = 0
declare @curIdx       as int          = 0
declare @importFileID as bigint       = null
declare @numRows      as int          = 0
declare @msg          as varchar(256) = ''

/*###########################################################################*/
/*#  Exit if no client                                                      #*/
/*###########################################################################*/

if (@clientID is null) 
begin
  set @completedNormally = 0
  exec dbo.PRINT_STATUS_MESSAGE 'Client not provided'
  return(0)
end


/*###########################################################################*/
/*#  Setup Table Vars                                                       #*/
/*###########################################################################*/

/*------------------------------------*/
/* Holds files we can process         */
/*------------------------------------*/

declare @spEdDataImportFiles as table (
    idx         int     identity(1,1) not null
  , id          bigint                not null
  , [file_name] varchar(max)          not null
  unique clustered (idx)
)

/*------------------------------------*/
/* Holds file rows we can process     */
/*------------------------------------*/

declare @spEdDataImportFileRows as table (    
    fileID                 bigint  not null
  , patID                  bigint  not null
  , spEdSvcCode            int     not null
  , spEdFreqCode           int     not null
  , durationTotal          int     not null
  , individualSvc          bit     not null
  , groupSvc               bit     not null
  , startDate              date    not null
  , endDate                date    not null
  , latestFileRowID        bigint  not null  
)

/*------------------------------------*/
/* Holds all clean spEd services      */
/* promised for each patient          */
/* associated with the given client.  */
/* This data is used in compliance    */
/* calculations.                      */
/*------------------------------------*/

declare @spEdDataImportedAll as table (
    patID                  bigint
  , spEdSvcCode            int
  , spEdFreqCode           int
  , duration               int
  , individualSvc          bit
  , groupSvc               bit
  , startDate              date
  , endDate                date
  , latestFileRowID        bigint
unique clustered (
   patID        
 , spEdSvcCode  
 , spEdFreqCode 
 , duration     
 , individualSvc
 , groupSvc
 , startDate
 , endDate
 , latestFileRowID 
 )
)

/*------------------------------------*/
/* Holds patient specific SpEd data   */
/* for the given client ID.           */
/*                                    */ 
/* This data is not used in           */
/* compliance calculations.           */
/*------------------------------------*/

declare @spEdDataImportedPatientData as table (
    patID                           bigint
  , latestFileRowID                 bigint
  , latestSpEdDisabilityCode1       int
  , latestSpEdDisabilityCode2       int
  , latestLastEval                  date
  , latestLastAnnIEP                date
  , latestNextAnnIEP                date
  , latestSpEdSpecialTransportation bit
  , latestCaseManagerName           varchar(256)
  , latestExitedSpEdDate            date
unique clustered (
    patID           asc
  , latestFileRowID desc ) /* To match [PAT_ID_IDX_DESC] index on [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] */
)

/*------------------------------------*/
/* Holds additional spEd services     */
/* data promised for each patient     */
/* but this data is not part of the   */
/* promised services compliance       */
/* calculations.                      */
/*------------------------------------*/

declare @spEdDataImportedAdditionalSvcData as table (
    latestFileRowID                 bigint
  , latestSpEdProviderCode          int 
  , latestSpEdLocationCode          int
  
unique clustered (latestFileRowID asc ) /* To match [IDX] index on [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] */
)

/*------------------------------------*/
/* Used to help normalize dates      */
/*------------------------------------*/

declare @spEdDataDates as table (
    patID                  bigint
  , spEdSvcCode            int
  , startDate              date
  , adjustedEndDate        date      
unique clustered (patID,spEdSvcCode,startDate)
)

/*------------------------------------*/
/* Holds all clean spEd services      */
/* promised for each patient          */
/* after the data has been            */
/* consolidated and normalized.       */
/* This data is used in compliance    */
/* calculations and is permamently    */
/* stored in patients promised        */
/* services                           */
/*------------------------------------*/

declare @spEdDataImportedAndCorrected as table (
    patID                  bigint
  , spEdSvcCode            int
  , spEdFreqCode           int
  , duration               int
  , individualSvc          bit
  , groupSvc               bit
  , startDate              date
  , endDate                date  
  , latestFileRowID        bigint

unique clustered (
   patID        
 , spEdSvcCode  
 , spEdFreqCode 
 , duration     
 , individualSvc
 , groupSvc
 , startDate
 , endDate
 , latestFileRowID )
)

/*###########################################################################*/
/*#  Load and Preprocess                                                    #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading and preprocessing SpEd data that involves promised service metrics'

/*------------------------------------*/
/* Get files we can work with for     */
/* given client                       */
/*------------------------------------*/

insert into @spEdDataImportFiles (
   id
 , [file_name]
)
select 
    a5f.id
  , a5f.file_name 
from [dbo].[Import_From_A.5_SERVICES_From_Client_Files] as a5f  
where (
	  (a5f.client_id = @clientID)
  and (a5f.canUseData = 1) /* OK to use*/
) 
order by 
  a5f.id asc
option(recompile)

/*------------------------------------*/
/* Get file rows for each file        */
/* and preprocess the rows            */
/* Note: We are doing this in a loop  */
/* to simplify the logic needed to    */
/* keep the context of pre processing */
/* files rows within a file.          */
/*------------------------------------*/

select @curIdx = 1, @maxIdx = max(sdif.idx) from @spEdDataImportFiles as sdif option(recompile)

while (@curIdx <= @maxIdx)
begin
  
  select top 1 @importFileID = id from @spEdDataImportFiles as sdif where (sdif.idx = @curIdx) option(recompile) 

  /*------------------------------------*/
  /* Pass 1 - Load rows and parse       */
  /* various raw fields.  Remove rows   */
  /* for missing patients and if a DNR  */
  /* flag is available, we will use it  */
  /* otherwise DNR defaults to false.   */
  /*------------------------------------*/

  ;with
  cte_p1
  as
  (
    select     
	    patID            = a5fr.Patient_ID
      , spEdSvcCode      = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Code],      1)        /* Will be -1 if not found */
      , spEdFreqCode     = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Frequency], 2)        /* Will be -1 if not found */ 
      , duration         = isnull(a5fr.[Total Minutes / Frequency],0)                                          /* 0 if null               */
      , startDate        = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[Start Date], @minYear, @maxYear)  /* Null if min or max value */
      , endDate          = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.[End Date],   @minYear, @maxYear)  /* Null if min or max value */
      , deliveryCodes    = replace(upper(trim(isnull(a5fr.Delivery,'I'))),'|','')                              /* Assume individual if nothing provided */
	  , doNotReport      = dbo.FLAG_STRING_TO_BIT(a5fr.[Marked DNR],1)
	  , fileRowID        = a5fr.ID
    
    from [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] as a5fr 	
    join dbo.PATIENTS_Patient                                   as pap  on pap.PATIENT_ID = a5fr.Patient_ID
    where (
          (a5fr.File_import_log_entry = @importFileID)
      and (a5fr.Patient_ID is not null)
	  and (a5fr.active = 1)
    )
  )
  ,

  /*------------------------------------*/
  /* Pass 2 - Exclude rows with missing */
  /* service codes, frequency codes     */
  /* and start dates. Also exclude rows */     
  /* where do not report is 1.          */
  /* Calculate end date if one was not  */
  /* provided and parse delivery codes  */
  /* into seperate individual and group */
  /* flags.                             */
  /*------------------------------------*/

  cte_p2
  as
  (
    select 
      p1.patID   
    , p1.spEdSvcCode  
    , p1.spEdFreqCode  
    , p1.duration  
    , individualSvc = convert(bit, case 
        when (p1.deliveryCodes  = 'G')      then 0
        when (p1.deliveryCodes  = '2')      then 0
		when (p1.deliveryCodes  = '4')      then 0
		when (p1.deliveryCodes  = 'I')      then 1
        when (p1.deliveryCodes  = '1')      then 1
        when (p1.deliveryCodes  = 'IG')     then 1
		when (p1.deliveryCodes  = '3')      then 1
		when (p1.deliveryCodes like '%In%') then 1
        else 0
      end)

    , groupSvc = convert(bit,case 
        when (p1.deliveryCodes  = 'I')      then 0
        when (p1.deliveryCodes  = '1')      then 0
		when (p1.deliveryCodes  = '4')      then 0
		when (p1.deliveryCodes  = 'G')      then 1
        when (p1.deliveryCodes  = '2')      then 1
        when (p1.deliveryCodes  = 'IG')     then 1
		when (p1.deliveryCodes  = '3')      then 1
		when (p1.deliveryCodes like '%Gr%') then 1
        else 0
      end)

	, p1.startDate 
    , endDate = isnull(p1.endDate,(dateadd(year,1,p1.startDate)))	
	, p1.fileRowID 

    from cte_p1 as p1
    where ( 
          (p1.spEdSvcCode != -1)
      and (p1.spEdFreqCode != -1)
	  and (p1.duration > 0)
	  and (p1.doNotReport = 0)  /* Dont include do not report rows */
	  and (p1.startDate is not null)
    ) 
  )  
  ,
  
  /*------------------------------------*/
  /* Pass 3 - Exclude rows with the     */
  /* same start and end dates or        */
  /* rows where the end date is before  */
  /* the start date.                    */
  /*------------------------------------*/

  cte_p3
  as
  (
    select
      p2.patID
    , p2.spEdSvcCode
    , p2.spEdFreqCode
    , p2.duration
    , p2.individualSvc
    , p2.groupSvc
    , p2.startDate
    , p2.endDate
    , p2.fileRowID
   from cte_p2 as p2
   where ( 
      (datediff(day,p2.startDate,p2.endDate) > 0) /* Eliminate same day svcs */  
   )
 )
 ,

  /*------------------------------------*/
  /* Pass 4 - Identify cases where      */
  /* "subservices" have been created    */
  /* we will aggregate these together   */
  /*------------------------------------*/

 cte_p4
 as
 (
   select
       p3.patID
     , p3.spEdSvcCode
     , p3.spEdFreqCode
     , p3.duration
     , p3.individualSvc
     , p3.groupSvc
     , p3.startDate
     , p3.endDate	
     , subServiceCount  = count(p3.fileRowID)
     , latestFileRowID  = max(p3.fileRowID)
   from cte_p3 as p3
   group by 
      p3.patID
    , p3.spEdSvcCode
    , p3.spEdFreqCode
    , p3.duration
	, p3.individualSvc
	, p3.groupSvc
	, p3.startDate
    , p3.endDate
 )
 ,
 
 /*------------------------------------*/
 /* Pass 5 - Aggregate sub services    */
 /* and store for later processing     */
 /*------------------------------------*/

 cte_p5
 as
 (
    select
      fileID = @importFileID
	, p4.patID
    , p4.spEdSvcCode
    , p4.spEdFreqCode
    , [durationTotal] = (p4.duration * p4.subServiceCount) /* The actual duration that needs to be satisfied */
    , p4.individualSvc
    , p4.groupSvc
    , p4.startDate
    , p4.endDate
	, p4.latestFileRowID
  from cte_p4 as p4
 )

 /*------------------------------------*/
 /* Pass 6 - Store for later proc      */
 /*------------------------------------*/

 insert into @spEdDataImportFileRows (
      fileID
    , patID
    , spEdSvcCode
    , spEdFreqCode
    , durationTotal
    , individualSvc
    , groupSvc 
    , startDate
    , endDate
    , latestFileRowID 
  )
  select distinct
      p5.fileID
    , p5.patID
    , p5.spEdSvcCode
    , p5.spEdFreqCode
    , p5.durationTotal
    , p5.individualSvc
    , p5.groupSvc 
    , p5.startDate
    , p5.endDate
    , p5.latestFileRowID 
  from cte_p5 as p5
  option(recompile)

  set @curIdx = @curIdx + 1
end

set @numRows = 0
select @numRows = isnull(count(t1.patID),0) from @spEdDataImportFileRows as t1
set @msg = 'Number of rows to process : ' + convert(varchar(50),@numRows)
exec dbo.PRINT_STATUS_MESSAGE @msg
set @msg  = ''


/*###########################################################################*/
/*#  Perform consolidation of imported SpEd Data                            #*/
/*#  for this client that involves promised service metrics.                #*/
/*#  The promised service metrics are service promised, frequency, duration #*/
/*#  group and/or individual delivery, start and end dates.                 #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Consolidating redundant/overlapping promised service metrics'

/*------------------------------------*/
/* Pass 1 - Perform consolidation by  */
/* grouping together redundant rows.  */
/* contains the same promised service */
/* data.  This takes care of data     */
/* overlaps from multiple files.      */
/*------------------------------------*/

;with
cte_p1
as
(
  select 
      sdifr.patID
    , sdifr.spEdSvcCode
    , sdifr.spEdFreqCode
    , sdifr.durationTotal
    , sdifr.individualSvc
    , sdifr.groupSvc
    , sdifr.startDate
    , sdifr.endDate
	, latestFileRowID  = max(sdifr.latestFileRowID)

  from @spEdDataImportFileRows as sdifr
  group by
     sdifr.patID
   , sdifr.spEdSvcCode
   , sdifr.spEdFreqCode
   , sdifr.durationTotal
   , sdifr.individualSvc
   , sdifr.groupSvc
   , sdifr.startDate
   , sdifr.endDate
)
,

/*------------------------------------*/
/* Pass 2 - Perform further           */
/* consolidation by attempting to     */
/* group together those rows where    */
/* there are multiple cases with the  */
/* same svc, freq, dur, start date    */
/* We will ultimately use the start   */
/* dates to normalize end dates.      */
/*------------------------------------*/

cte_p2
as
(
select
     p1.patID
   , p1.spEdSvcCode
   , p1.spEdFreqCode
   , p1.durationTotal
   , p1.individualSvc
   , p1.groupSvc
   , p1.startDate
   , endDate         = max(p1.endDate)
   , latestFileRowID = max(p1.latestFileRowID)
  from cte_p1 as p1
  group by
      p1.patID
    , p1.spEdSvcCode
    , p1.spEdFreqCode
    , p1.durationTotal
    , p1.individualSvc
    , p1.groupSvc
    , p1.startDate
)

/*------------------------------------*/
/* Pass 3 - Store the processed rows  */
/* in a table variable for further    */
/* processing */
/*------------------------------------*/

insert into @spEdDataImportedAll (
    patID
  , spEdSvcCode
  , spEdFreqCode
  , duration
  , individualSvc
  , groupSvc 
  , startDate
  , endDate
  , latestFileRowID 
)
select distinct
     p2.patID
   , p2.spEdSvcCode
   , p2.spEdFreqCode
   , duration = p2.durationTotal
   , p2.individualSvc
   , p2.groupSvc
   , p2.startDate
   , p2.endDate
   , p2.latestFileRowID 
from cte_p2 as p2
option(recompile)

/*###########################################################################*/
/*#  Get and parse additional information for each promised svc that is not #*/
/*#  required for promised service calculations (so we exclude them from    #*/
/*#  the load, parse, and consolidate) but they are part of the CALPADS     #*/
/*#  documentation.  We will use these values later                         #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading and parsing additional SpEdData for each promised service'

insert into @spEdDataImportedAdditionalSvcData (
    latestFileRowID
  , latestSpEdProviderCode
  , latestSpEdLocationCode
)

select
   sdi.latestFileRowID
 , latestSpEdProviderCode  = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Provider], 4)
 , latestSpEdLocationCode  = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Location], 3)

from @spEdDataImportedAll                                   as sdi
join [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] as a5fr on a5fr.ID = sdi.latestFileRowID
option(recompile)

/*###########################################################################*/
/*#  Get and parse additional spEd information for each patient.            #*/
/*#  This information is not service specific but it is patient specific.   #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading and parsing additional SpEd data for each patient'

/*------------------------------------*/
/* Get each patient                   */
/*------------------------------------*/

insert into @spEdDataImportedPatientData (
    patID
  , latestFileRowID
)
select
    patID
  , latestFileRowID = max(sdi.latestFileRowID)
from @spEdDataImportedAll as sdi
group by 
  sdi.patID
option(recompile)

/*------------------------------------*/
/* Then get their SpEd data.          */
/* This data should be duplicated on  */
/* each row associated with the       */
/* patient so we just need the latest */
/* rows.                              */
/*------------------------------------*/

update ipd
set 
   ipd.latestSpEdDisabilityCode1       = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Disability 1 Code], 5)
 , ipd.latestSpEdDisabilityCode2       = dbo.SPED_EXTRACT_OR_LOOKUP_INCOMING_CODE_NAME_OR_VALUE (a5fr.[Disability 2 Code], 5)
 , ipd.latestLastEval                  = a5fr.[Date of Last Evaluation]
 , ipd.latestLastAnnIEP                = a5fr.[Date of Last Annual IEP]
 , ipd.latestNextAnnIEP                = a5fr.[Date of Next Annual IEP]
 , ipd.latestSpEdSpecialTransportation = dbo.FLAG_STRING_TO_BIT(a5fr.[Special Transportation],1)
 , ipd.latestCaseManagerName           = a5fr.caseManagerName
 , ipd.latestExitedSpEdDate            = dbo.DATE_REPLACE_MIN_OR_MAX_VALUE_WITH_NULL(a5fr.exitedSpEdDate,@minYear,@maxYear)


from @spEdDataImportedPatientData                           as ipd
join [dbo].[Import_From_A.5_SERVICES_From_Client_File_Rows] as a5fr on ((a5fr.Patient_ID = ipd.patID) and (a5fr.id = ipd.latestFileRowID))
option(recompile)
 
/*###########################################################################*/
/*#  Group together adjacent spEdSvc and start date rows by patient so we   #*/
/*#  can provide end dates for rows that do not have an end date            #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Calculating adjusted end dates'

;with
cte_p1
as
(
  select 
      sdi.patID
    , sdi.spEdSvcCode
    , sdi.startDate
  from @spEdDataImportedAll as sdi
  group by
     sdi.patID
   , sdi.spEdSvcCode
   , sdi.startDate
)
,
cte_p2
as
(
select 
    p1.patID
  , p1.spEdSvcCode
  , p1.startDate
  , adjustedEndDate = dateadd(day,-1,(lead(p1.startDate) over (partition by p1.patID, p1.spEdSvcCode order by p1.startDate)))
from cte_p1 as p1
)
insert into @spEdDataDates (
   patID
 , spEdSvcCode
 , startDate
 , adjustedEndDate
)
select 
   p2.patID
 , p2.spEdSvcCode
 , p2.startDate
 , p2.adjustedEndDate
from cte_p2 as p2
option(recompile)

/*###########################################################################*/
/*#  Correct overlapping start/end dates so we have clean adjacent blocks   #*/
/*#  that contain the terms of service promised for a patient.              #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Cleaning and normalizing SpEd data'

insert into @spEdDataImportedAndCorrected (
    patID    
  , spEdSvcCode
  , spEdFreqCode
  , duration    
  , individualSvc
  , groupSvc 
  , startDate 
  , endDate  
  , latestFileRowID
)

/*------------------------------------*/
/* Correct the overlaps for adjacent  */
/* rows with different "terms" of     */
/* service by replacing the end date  */
/* of each row with the start date    */
/* of the next row -1 day.  This will */
/* also automatically preserve cases  */ 
/* where the data already had a non   */
/* overlap.                           */ 
/*------------------------------------*/

select 
	 sdi.patID
   , sdi.spEdSvcCode
   , sdi.spEdFreqCode
   , sdi.duration
   , sdi.individualSvc
   , sdi.groupSvc
   , sdi.startDate
   , endDate = iif((sdd.adjustedEndDate is null)
                   , sdi.endDate
				   , iif((sdi.endDate > sdd.adjustedEndDate)
				         , sdd.adjustedEndDate
						 , sdi.endDate)
				  )
   --, endDate = isnull(dateadd(day,-1,lead(sdi.startDate) over (partition by sdi.patID, sdi.spEdSvcCode, sdi.spEdFreqCode, sdi.duration, sdi.individualSvc, sdi.groupSvc, sdi.startDate order by sdi.startDate)), sdi.endDate)
   , sdi.latestFileRowID

from @spEdDataImportedAll as sdi
join @spEdDataDates       as sdd on  ((sdd.patID      = sdi.patID)
                                 and (sdd.spEdSvcCode = sdi.spEdSvcCode)
                                 and (sdd.startDate   = sdi.startDate))

where (sdi.startDate < sdi.endDate)
order by
    sdi.patID
  , sdi.spEdSvcCode
  , sdi.spEdFreqCode
  , sdi.duration
  , sdi.individualSvc
  , sdi.groupSvc
  , sdi.startDate
  , sdi.latestFileRowID
option(recompile)

begin transaction
set @tranOpen = 1

/*###########################################################################*/
/*#  Update patient promised service data                                   #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Replacing promised service data'

/*------------------------------------*/
/* Remove previous data               */
/*------------------------------------*/

delete pps
from @spEdDataImportedPatientData   as ipd
join dbo.PATIENTS_Promised_Services as pps on pps.patID = ipd.patID
option(recompile)

/*------------------------------------*/
/* Replace with updated data          */
/*------------------------------------*/

insert into dbo.PATIENTS_Promised_Services (
    patID
  , spEdServiceCode
  , spEdProviderCode
  , spEdFreqCode
  , spEdLocationCode
  , startDate
  , endDate
  , individualDelivery
  , groupDelivery
  , minsPerFreq
  , fromSpEdDataFiles
  , latestFileRowID
  , doNotReplace
  , created
  , createdBy
  , active
)
select 
    sdi.patID
  , spEdServiceCode    = sdi.spEdSvcCode
  , spEdProviderCode   = sdiad.latestSpEdProviderCode
  , spEdFreqCode       = sdi.spEdFreqCode
  , spEdLocationCode   = sdiad.latestSpEdLocationCode
  , sdi.startDate
  , sdi.endDate
  , individualDelivery = sdi.individualSvc
  , groupDelivery      = sdi.groupSvc
  , minsPerFreq        = sdi.duration
  , fromSpEdDataFiles  = 1
  , latestFileRowID    = sdi.latestFileRowID
  , doNotReplace       = 0
  , created            = @today
  , createdBy          = 0
  , active             = 1
from @spEdDataImportedAndCorrected      as sdi        
join @spEdDataImportedAdditionalSvcData as sdiad on sdiad.latestFileRowID = sdi.latestFileRowID
option(recompile)

/*###########################################################################*/
/*#  Update patient spEd data                                               #*/
/*###########################################################################*/

update pap
set
    pap.spEdLastEvalDate          = ipd.latestLastEval
  , pap.spEdLastAnnualIEPDate     = ipd.latestLastAnnIEP
  , pap.spEdNextAnnualIEPDate     = ipd.latestNextAnnIEP
  , pap.spEdSpecialTransportation = ipd.latestSpEdSpecialTransportation
  , pap.spEdDisability1Code       = ipd.latestSpEdDisabilityCode1
  , pap.spEdDisability2Code       = ipd.latestSpEdDisabilityCode2
  , pap.spEdCaseManagerName       = ipd.latestCaseManagerName
  , pap.spEdExitedSpEdDate        = ipd.latestExitedSpEdDate
  , pap.LAST_UPDATED              = @today

from @spEdDataImportedPatientData as ipd
join dbo.PATIENTS_Patient         as pap on pap.PATIENT_ID = ipd.patID
option(recompile)

commit transaction
set @tranOpen = 0

exec dbo.PRINT_STATUS_MESSAGE 'Completed normally'
set @completedNormally = 1
return(0)

end try

/*###########################################################################*/
/*#  Exception handling                                                     #*/
/*###########################################################################*/

begin catch

  /*------------------------------------*/
  /* Rollback if neccessary             */
  /*------------------------------------*/

  if (@tranOpen = 1)
  begin
    ROLLBACK TRANSACTION
	set @tranOpen = 0
  end

  /*------------------------------------*/
  /* Let caller know we had problem     */
  /*------------------------------------*/
  
  set @completedNormally = 0
  
  print ERROR_MESSAGE()  
  exec dbo.PRINT_STATUS_MESSAGE 'Completed with errors'
  exec dbo.PRINT_STATUS_MESSAGE 'Updates not committed'

  return(0)
  
end catch

/*------------------------------------*/
/* Should never get here but          */
/* if we do its not normal            */
/*------------------------------------*/

set @completedNormally = 0
return(0)


END
GO

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Parse_And_Update_SpEd_Data_Old] TO [webuser]
GO
