USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core] (
    @clientID bigint = null
  , @patID    bigint = null  
) 
returns @recs table (    
    patID                     bigint
  , latestFileID              bigint
  , latestFileRowID           bigint
  , latestFileDate            date
  , spEdSvcCode               int
  , spEdFreqCode              int
  , duration                  int
  , individualSvc             bit
  , groupSvc                  bit
  , startDate                 date
  , endDate                   date
  , nextFileDoesNotHaveSvc    bit default(0)
  , nextFileDoesNotHavePat    bit default(0)  
  , nextFileID                bigint
  , nextFileDate              date   
  , numSvcLines               int
  , svcLinesDetailsJSON       varchar(max)    
  unique clustered (patID, latestFileID, latestFileRowID)
)

AS
BEGIN


declare @today as datetime = convert(date,getdate())

/*------------------------------------*/
/* Holds file history for client      */
/*------------------------------------*/

declare @svcImportFileHistoryForClient as table (
    fileID       bigint    not null
  , fileDate     datetime
  , nextFileID   bigint
  , nextFileDate datetime
unique clustered (fileID)
)

/*------------------------------------*/
/* Holds latest file                  */
/*------------------------------------*/

declare @latestSvcImportFilesForPats as table (    
    patID             bigint    not null
  , spEdSvcCode       int       not null
  , startDate         datetime  not null
  , fileID            bigint    not null
  , calculatedEndDate datetime
unique clustered  (patID, spEdSvcCode, startDate, fileID)
)

/*------------------------------------*/
/* Holds latest file pats are in      */
/*------------------------------------*/

declare @latestFilePatIsIn as table (    
    patID  bigint not null
  , fileID bigint not null
unique clustered  (patID, fileID)
)

/*------------------------------------*/
/* Holds latest start dates for       */
/* pat and svc                        */
/*------------------------------------*/

declare @latestStartDatesForPatAndSvc as table (    
    patID             bigint    not null
  , spEdSvcCode       int       not null
  , startDate         datetime  not null
unique clustered  (patID, spEdSvcCode, startDate)
)

/*------------------------------------*/
/* Holds import summary rows          */
/*------------------------------------*/

declare @importSummaryRows as table (
    patID                     bigint   not null
  , spEdSvcCode               int      not null
  , startDate                 datetime not null
  , fileID                    bigint   not null
  , summaryRowIdx             bigint   not null
  , endDate                   datetime
  , spEdFreqCode              int
  , individualSvc             bit
  , groupSvc                  bit  
  , totalDuration             int
  , numSvcLines               int
  , svcLinesDetailsJSON       varchar(max)
  , latestFileRowID           bigint
  , hasEndDate                bit  
  , latestFilePatIsIn         bit default(0)
  , latestStartDate           bit default(0)
  , endDateAdjusted           bit default(0)
  , adjustedEndDate           datetime 
  , calculatedEndDate         datetime
  , nextFileDoesNotHaveSvc    bit default(0)
  , nextFileDoesNotHavePat    bit default(0)
  , nextFileID                bigint
  , nextFileReceivedDate      datetime  
  unique clustered  (patID, spEdSvcCode, startDate, fileId, summaryRowIdx)
)

/*------------------------------------*/
/* Holds import data to be            */
/* consolidated                       */
/*------------------------------------*/

declare @spEdDataImported table (    
    idx                       bigint identity(1,1) not null
  , patID                     bigint not null
  , latestFileID              bigint
  , latestFileRowID           bigint
  , spEdSvcCode               int    not null
  , spEdFreqCode              int    not null
  , duration                  int
  , individualSvc             bit
  , groupSvc                  bit
  , startDate                 date
  , endDate                   date  
  , numSvcLines               int
  , svcLinesDetailsJSON       varchar(max)
  , reportedStartDate         date
  , reportedEndDate           date
  , nextFileDoesNotHaveSvc    bit default(0)
  , nextFileDoesNotHavePat    bit default(0)  
  , mergedIdx                 bigint default(-1) not null    
    unique clustered    (idx)
  , unique nonclustered (patID, spEdSvcCode, spEdFreqCode, idx)
  , unique nonclustered (mergedIdx, idx)
)

/*------------------------------------*/
/* Holds merged rows for overlaps     */
/* identified                         */
/*------------------------------------*/

declare @spEdDataMerges as table (
    idx                       bigint identity(1,1) not null
  , patID                     bigint
  , spEdSvcCode               int
  , spEdFreqCode              int
  , mergedStartDate           date
  , mergedEndDate             date
  , duration                  int
  , individualSvc             bit default(0)
  , groupSvc                  bit default(0)
  , nextFileDoesNotHaveSvc    bit default(0)
  , nextFileDoesNotHavePat    bit default(0)  
  , numSvcLines               int default(0)
  , numRows                   int default(0)
  , rowIdxs                   varchar(max) default ('')
unique clustered (idx)
)

/*------------------------------------*/
/* Holds merged rows svc details      */
/* extracted                          */
/*------------------------------------*/

declare @spEdDataMergesSvcDetails as table (   
   mergedIdx           bigint not null
 , rowIdx              bigint not null
 , svcLineIdx          int    not null
 , newSvcLineIdx       int    not null
 , doNotReport         bit
 , fileID              bigint
 , fileRowID           bigint
 , hasEndDate          bit
 , duration            int
 , spEdLocationCode    int
 , spEdLocationName    varchar(256)
 , individualSvc       bit
 , groupSvc            bit
 , spEdProviderCode    int
 , spEdProviderName    varchar(256)
 , spEdDisabilityCode1 int
 , spEdDisabilityName1 varchar(256)
 , spEdDisabilityCode2 int
 , spEdDisabilityName2 varchar(256)
 , spEdSpecTransport   bit
 , lastEvalDate        date
 , lastAnnIEPDate      date
 , nextAnnIEPDate      date
 , exitedSpEdDate      date
 , caseManagerName     varchar(256)
 , additionalInfo      varchar(max)
 , reportableToCDE     bit
 , reportedStartDate   date
 , reportedEndDate     date
 , deliverySummary     varchar(50)

unique clustered (mergedIdx, rowIdx, svcLineIdx, newSvcLineIdx)
)

/*------------------------------------*/
/* Holds merged rows file stats       */
/*------------------------------------*/

declare @spEdDataMergesFileStats as table (
    mergedIdx                 bigint
  , latestFileID              bigint
  , latestFileRowID           bigint
unique clustered (mergedIdx)
)

/*------------------------------------*/
/* Holds merged rows svc details      */
/* regenerated                        */
/*------------------------------------*/

declare @spEdDataMergesSvcDetailsJSON as table (   
    mergedIdx                 bigint not null
  , svcLinesDetailsJSON       varchar(max) 
unique clustered (mergedIdx)
)

/*###########################################################################*/
/*#              Populate @svcImportFileHistoryForClient                    #*/
/*#                                                                         #*/
/*#     from table Patient_Data_Imports_SpEd_Data_File_Summary_Rows         #*/
/*#     and table Import_From_A.5_SERVICES_From_Client_Files                #*/
/*#     and table (if ref avail) Structured_Data_Imports                    #*/
/*#                                                                         #*/
/*#  We will use this to determine if we should end a plan if the patient   #*/
/*#  leaves client or service is discontinued                               #*/
/*###########################################################################*/

;with
cte_p1
as
(
  select 
    t1.fileID
  from dbo.Patient_Data_Imports_SpEd_Data_File_Summary_Rows as t1
  where 
    (t1.clientID = @clientID)
  group by 
    t1.fileID
)
,
cte_p2
as
( 
  select
      p1.fileID 
    , fileDate = convert(datetime,(convert(date,coalesce(t3.created, t2.began_processing)) /* Strip time component off */))
  from      cte_p1                                           as p1
  join      dbo.[Import_From_A.5_SERVICES_From_Client_Files] as t2 on t2.id = p1.fileID
  left join dbo.Structured_Data_Imports                      as t3 on t3.id = t2.structuredDataImportID
)
insert into @svcImportFileHistoryForClient (
    fileID
  , fileDate
  , nextFileID
  , nextFileDate
)
select
    p2.fileID 
  , p2.fileDate
  , nextFileID   = lead(p2.fileID)   over (order by p2.fileID)
  , nextFileDate = lead(p2.fileDate) over (order by p2.fileID)
from cte_p2 as p2
order by 
  p2.fileID
option(recompile)

/*###########################################################################*/
/*#             Populate @latestSvcImportFilesForPats                       #*/
/*#                                                                         #*/
/*#     from table Patient_Data_Imports_SpEd_Data_File_Summary_Rows         #*/
/*#                                                                         #*/
/*#  - Get id of the latest import file received that contains data for     #*/
/*#    client, patient, spEdSvcCode, start date.                            #*/
/*#                                                                         #*/
/*#    We are assuming that the latest file will have the most accurate     #*/
/*#    service terms.                                                       #*/
/*#                                                                         #*/
/*#  - Exclude future plans (with respect to plan start date and file date) #*/
/*#                                                                         #*/
/*#  - Calculate an end date we can use for normalizing dates later.        #*/
/*#    We are assuming that the end date is the next start date -1 day.     #*/
/*#                                                                         #*/
/*###########################################################################*/

;with
cte_p1
as
(
  select       
      t1.patID
    , t1.spEdSvcCode
    , t1.startDate
    , t1.fileID
	, planStartsInDays = datediff(day,t1.startDate,t2.fileDate)
  from dbo.Patient_Data_Imports_SpEd_Data_File_Summary_Rows as t1
  join @svcImportFileHistoryForClient                       as t2 on t2.fileID = t1.fileID  
  where (
        (t1.clientID = @clientID)
    and ((@patID is null) or (t1.patID = @patID))   
  )
)
,
cte_p2
as
(
  select 
    p1.* 
  from cte_p1 as p1
  where 
    (p1.planStartsInDays >= 0)
)
,
cte_p3
as
(
  select       
      p2.patID
    , p2.spEdSvcCode
    , p2.startDate
    , fileID = max(p2.fileID)
  from cte_p2 as p2
  
  group by      
      p2.patID
    , p2.spEdSvcCode
    , p2.startDate
)
insert into @latestSvcImportFilesForPats (    
    patID 
  , spEdSvcCode
  , startDate 
  , fileID  
  , calculatedEndDate
)
select     
    p3.patID
  , p3.spEdSvcCode
  , p3.startDate
  , p3.fileID
  , calculatedEndDate = dateadd(day,-1,(lead(p3.startDate) over (partition by p3.patID, p3.spEdSvcCode order by p3.startDate)))
from cte_p3 as p3
order by
    p3.patID
  , p3.spEdSvcCode
  , p3.startDate
  , p3.fileID
option(recompile)


/*###########################################################################*/
/*#                    Populate @latestFilePatIsIn                          #*/
/*#                                                                         #*/
/*#                  from @latestSvcImportFilesForPats                      #*/
/*#                                                                         #*/
/*#  - Get latest file that info for a patient appears                      #*/
/*#  - We will use this for normalizing dates later                         #*/
/*#                                                                         #*/
/*###########################################################################*/

insert into @latestFilePatIsIn (patID, fileID)
select 
      t1.patID
	, fileID = max(t1.fileID)
from @latestSvcImportFilesForPats as t1
group by 
    t1.patID
option(recompile)

/*###########################################################################*/
/*#               Populate @latestStartDatesForPatAndSvc                    #*/
/*#                                                                         #*/
/*#                  from @latestSvcImportFilesForPats                      #*/
/*#                                                                         #*/
/*#  - Get max/latest start date for a pat and svc                          #*/
/*#  - We will use this for normalizing dates later                         #*/
/*#                                                                         #*/
/*###########################################################################*/

insert into @latestStartDatesForPatAndSvc (patID, spEdSvcCode, startDate)
select 
      t1.patID
    , t1.spEdSvcCode
	, startDate = max(t1.startDate)	
from @latestSvcImportFilesForPats as t1
group by 
    t1.patID
  , t1.spEdSvcCode
option(recompile)

/*###########################################################################*/
/*#                     Populate @importSummaryRows                         #*/
/*#                                                                         #*/
/*#                 from @latestSvcImportFilesForPats                       #*/
/*#     and table Patient_Data_Imports_SpEd_Data_File_Summary_Rows          #*/
/*#                                                                         #*/
/*#  - There may be multiple rows for the same pat, svc, and start date     #*/
/*#    per file.                                                            #*/
/*#                                                                         #*/
/*###########################################################################*/

insert into @importSummaryRows (    
    patID 
  , spEdSvcCode
  , startDate 
  , fileID 
  , summaryRowIdx
  , endDate
  , spEdFreqCode
  , individualSvc
  , groupSvc
  , totalDuration
  , numSvcLines
  , svcLinesDetailsJSON 
  , latestFileRowID
  , hasEndDate
)

select distinct
    t3.*
from @latestSvcImportFilesForPats as t1 

cross apply (

  select distinct
      t2.patID 
    , t2.spEdSvcCode
	, t2.startDate     
    , t2.fileID  
    , summaryRowIdx = t2.idx
	, t2.endDate 
    , t2.spEdFreqCode
    , t2.individualSvc
    , t2.groupSvc
    , t2.totalDuration
    , t2.numSvcLines
    , t2.svcLinesDetailsJSON 
    , t2.latestFileRowID
    , t2.hasEndDate  
  from dbo.Patient_Data_Imports_SpEd_Data_File_Summary_Rows as t2

  where ( 
        ((t2.clientID    = @clientID))
    and (t2.patID       = t1.patID)
	and (t2.spEdSvcCode = t1.spEdSvcCode)
	and (t2.startDate   = t1.startDate) 
	and (t2.fileID      = t1.fileID)
  )
) as t3

order by    
    t3.patID
  , t3.spEdSvcCode
  , t3.startDate
  , t3.fileID

option(recompile)

/*###########################################################################*/
/*#                    Update @importSummaryRows                            #*/
/*#                                                                         #*/
/*#                   From @latestFilePatIsIn                               #*/
/*#               and @latestStartDatesForPatAndSvc                         #*/
/*#               and @svcImportFileHistoryForClient                        #*/
/*#                                                                         #*/
/*#  - Set latest file patient appears in                                   #*/
/*#  - Set latest start date for a patient + svc code                       #*/ 
/*#  - Determine if service is in next file                                 #*/
/*#  - Determine if patient is in next file                                 #*/
/*#  - Set calculated end date                                              #*/
/*#  - Determine and set adjusted end date                                  #*/
/*#                                                                         #*/
/*###########################################################################*/

/*------------------------------------*/
/* Set latest file pat is in          */
/*------------------------------------*/

update t1
set 
  t1.latestFilePatIsIn = 1            
from @importSummaryRows as t1
join @latestFilePatIsIn as t2 on ((t2.patID = t1.patID) and (t2.fileID = t1.fileID))
option(recompile)

/*------------------------------------*/
/* Set latest start date              */
/*------------------------------------*/

update t1
set 
  t1.latestStartDate = 1            
from @importSummaryRows            as t1
join @latestStartDatesForPatAndSvc as t2 on ((t2.patID = t1.patID) 
                                         and (t2.spEdSvcCode = t1.spEdSvcCode) 
							             and (t2.startDate   = t1.startDate))
option(recompile)

/*------------------------------------*/
/* Determine if service               */
/* is in next file                    */
/*------------------------------------*/

update t1
set 
    t1.nextFileDoesNotHaveSvc = 1 
  , t1.nextFileID             = t2.nextFileID
  , t1.nextFileReceivedDate   = t2.nextFileDate
from @importSummaryRows             as t1
join @svcImportFileHistoryForClient as t2 on t2.fileID = t1.fileID
where ( 
      (t1.latestStartDate = 1)
  and (t2.nextFileID is not null) /* If this is the latest file then we cant tell yet */
)
option(recompile)

/*------------------------------------*/
/* Determine if patient               */
/* is in next file                    */
/*------------------------------------*/

update t1
set
    t1.nextFileDoesNotHavePat = 1
  , t1.nextFileID             = t2.nextFileID
  , t1.nextFileReceivedDate   = t2.nextFileDate
from @importSummaryRows             as t1
join @svcImportFileHistoryForClient as t2 on t2.fileID = t1.fileID
where ( 
      (t1.latestFilePatIsIn = 1)
  and (t2.nextFileID is not null) /* If this is the latest file then we cant tell yet */
)
option(recompile)

/*------------------------------------*/
/* Set calculated end date            */
/*------------------------------------*/

update t1
set 
  t1.calculatedEndDate  = t2.calculatedEndDate
from @importSummaryRows            as t1
join @latestSvcImportFilesForPats  as t2 on ((t2.patID       = t1.patID) 
                                         and (t2.spEdSvcCode = t1.spEdSvcCode) 
								         and (t2.startDate   = t1.startDate) 
								         and (t2.fileID      = t1.fileID))
option(recompile)

/*------------------------------------*/
/* Set adjusted end date (aed) for    */
/*                                    */
/* - rows that have not had aed set   */
/* - svcs that were not continued     */
/* - end date after next file date    */
/* - start date before next file date */
/*                                    */
/*  Adjusted end date is set to       */
/*  date we received next file        */
/*------------------------------------*/

update t1
set 
    t1.adjustedEndDate  = t1.nextFileReceivedDate
  , t1.endDateAdjusted  = 1
from @importSummaryRows as t1
where (
      (t1.endDateAdjusted        = 0)  
  and (t1.nextFileDoesNotHaveSvc = 1)  
  and (t1.startDate < t1.nextFileReceivedDate) /* Start date is before next file date */
  and (t1.endDate   > t1.nextFileReceivedDate) /* End date is after next file date */
)
option(recompile)

/*------------------------------------*/
/* Set adjusted end date (aed) for    */
/*                                    */
/* - rows that have not had aed set   */
/* - pats that have left              */
/* - end date after next file date    */
/* - start date before next file date */
/*                                    */
/*  Adjusted end date is set to       */
/*  date we received next file        */
/*------------------------------------*/

update t1
set 
    t1.adjustedEndDate  = t1.nextFileReceivedDate
  , t1.endDateAdjusted  = 1
from @importSummaryRows as t1
where (
      (t1.endDateAdjusted        = 0)  
  and (t1.nextFileDoesNotHavePat = 1)  
  and (t1.startDate < t1.nextFileReceivedDate) /* Start date is before next file date */
  and (t1.endDate   > t1.nextFileReceivedDate) /* End date is after next file date */
)
option(recompile)

/*------------------------------------*/
/* Remove rows from use where         */
/*                                    */
/* - rows that have not had aed set   */
/* - svcs that were not continued     */
/* - start date after or on next      */
/*   file date                        */
/*------------------------------------*/

delete @importSummaryRows 
where (
      (endDateAdjusted        = 0)  
  and (nextFileDoesNotHaveSvc = 1)  
  and (startDate >= nextFileReceivedDate) /* Start date is on or after next file date */ 
)
option(recompile)


/*------------------------------------*/
/* Remove rows from use where         */
/*                                    */
/* - rows that have not had aed set   */
/* - pat not in next file             */
/* - start date after or on next      */
/*   file date                        */
/*------------------------------------*/

delete @importSummaryRows
where (
      (endDateAdjusted        = 0)  
  and (nextFileDoesNotHavePat = 1)  
  and (startDate >= nextFileReceivedDate) /* Start date is on or after next file date */
)
option(recompile)

/*------------------------------------*/
/* Set adjusted end date (aed) for    */
/*                                    */
/* - rows that have not had aed set   */
/* - pat                              */
/* - svc code                         */
/* - start date                       */ 
/* - last file pat is in              */ 
/* - latest start date                */
/*                                    */
/*  Adjusted end date is set to       */
/*  client provided or our default    */
/*------------------------------------*/

update t1
set 
    t1.adjustedEndDate  = t1.endDate /* Using client provided or our default (one year from start date)*/  
  , t1.endDateAdjusted  = 1
from @importSummaryRows           as t1
join @latestSvcImportFilesForPats as t2 on ((t2.patID       = t1.patID) 
                                        and (t2.spEdSvcCode = t1.spEdSvcCode) 
                                        and (t2.startDate   = t1.startDate) 
                                        and (t2.fileID      = t1.fileID))
where (
       (t1.endDateAdjusted   = 0)   
   and (t1.latestFilePatIsIn = 1)  
   and (t1.latestStartDate   = 1)
)
option(recompile)


/*------------------------------------*/
/* Set adjusted end date (aed) for    */
/*                                    */
/* - rows that have not had aed set   */
/* - pat                              */
/* - svc code                         */ 
/* - start date                       */
/* - file                             */
/* - startDate before end date        */
/*                                    */
/* Adjusted end date is set to either */
/*                                    */
/* - client provided/our default      */
/* - or calculated end date           */
/*                                    */
/* depending on if end date overlaps  */
/* next start                         */
/*------------------------------------*/

update t1
set 
   t1.adjustedEndDate = iif((t2.calculatedEndDate is null)  
                            /* No calc end date, use end date provided */
							, t1.endDate 
							/* Calc date available */
				            , iif((t1.endDate > t2.calculatedEndDate) 
				                   /* Use calc end date if the end date is greater than calc end date */
								   , t2.calculatedEndDate 
						           /* Otherwise use end date  */
								   , t1.endDate))
  , t1.endDateAdjusted = 1
from @importSummaryRows           as t1
join @latestSvcImportFilesForPats as t2 on ((t2.patID       = t1.patID) 
                                        and (t2.spEdSvcCode = t1.spEdSvcCode) 
						                and (t2.startDate   = t1.startDate) 
						                and (t2.fileID      = t1.fileID))
where (
     (t1.endDateAdjusted = 0) 
 and (t1.startDate < t1.endDate)
)
option(recompile)

/*###########################################################################*/
/*#               Cleanup temp data we no longer need                       #*/
/*###########################################################################*/

delete @latestStartDatesForPatAndSvc  option(recompile)
delete @latestSvcImportFilesForPats   option(recompile)
delete @latestFilePatIsIn             option(recompile)

/*###########################################################################*/
/*#                     Populate @spEdDataImported                          #*/
/*###########################################################################*/

insert into @spEdDataImported (    
    patID                    
  , latestFileID             
  , latestFileRowID          
  , spEdSvcCode              
  , spEdFreqCode             
  , duration                 
  , individualSvc            
  , groupSvc                 
  , startDate                
  , endDate      
  , numSvcLines  
  , svcLinesDetailsJSON 
  , reportedStartDate
  , reportedEndDate
  , nextFileDoesNotHaveSvc
  , nextFileDoesNotHavePat  
)
select 
    t1.patID
  , latestFileID = t1.fileID
  , t1.latestFileRowID 
  , t1.spEdSvcCode
  , t1.spEdFreqCode
  , duration = t1.totalDuration
  , t1.individualSvc
  , t1.groupSvc
  , t1.startDate
  , endDate = t1.adjustedEndDate
  , t1.numSvcLines
  , t1.svcLinesDetailsJSON
  , reportedStartDate = t1.startDate
  , reportedEndDate   = t1.endDate
  , t1.nextFileDoesNotHaveSvc
  , t1.nextFileDoesNotHavePat
from @importSummaryRows as t1
option(recompile)

/*###########################################################################*/
/*#                 Cleanup temp data we no longer need                     #*/
/*###########################################################################*/

delete @importSummaryRows option(recompile)

---------------------------------------------------------------------------------------------------------------

/*###########################################################################*/
/*#                Merge - Populate @spEdDataMerges                         #*/
/*#  Identify rows to merge and perform initial aggregation                 #*/
/*###########################################################################*/

;
with
cte_psr
as
(
  select 
      psr.patID
	, psr.spEdSvcCode
	, psr.spEdFreqCode
	, psr.startDate
	, psr.endDate
	, psr.duration
    , psr.numSvcLines
	, psr.idx	
  from @spEdDataImported as psr
)
,
cte_start_flags
as 
(
    select
        psr.*
        
		/* Check if current range starts after the furthest end date seen so far */
        , is_new_group = CASE 
            WHEN psr.startDate <= MAX(psr.endDate) OVER (
                PARTITION BY psr.patID, psr.spEdSvcCode, psr.spEdFreqCode  
                ORDER BY psr.startDate, psr.endDate
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ) THEN 0 
            ELSE 1 
        END 
    FROM cte_psr as psr
)
,
cte_grouped_ranges 
as 
(
    select 
        sf.*
        /* Generate unique ID for each continuous "island" */
        , group_id = SUM(is_new_group) OVER (
            PARTITION BY sf.patID, sf.spEdSvcCode, sf.spEdFreqCode  
            ORDER BY sf.startDate, sf.endDate
        ) 
    from cte_start_flags as sf
)
,
cte_merged
as
(
  select 
      gr.patID
    , gr.spEdSvcCode
	, gr.spEdFreqCode  	
    , mergedStartDate = min(gr.startDate) 
    , mergedEndDate   = max(gr.endDate) 
    , duration        = sum(gr.duration)
	, numSvcLines     = sum(gr.numSvcLines)
	, numRows         = count(gr.idx)	
    , rowIdxs         = string_agg(convert(varchar(max),gr.idx),',')
from cte_grouped_ranges as gr
group by 
    gr.patID
  , gr.spEdSvcCode
  , gr.spEdFreqCode
  , gr.group_id
)

insert into @spEdDataMerges (
    patID            
  , spEdSvcCode      
  , spEdFreqCode     
  , mergedStartDate  
  , mergedEndDate    
  , duration 
  , numSvcLines
  , numRows          
  , rowIdxs          
)
select 
    mg.patID
  , mg.spEdSvcCode
  , mg.spEdFreqCode
  , mg.mergedStartDate
  , mg.mergedEndDate
  , mg.duration
  , mg.numSvcLines
  , mg.numRows
  , mg.rowIdxs
from cte_merged as mg
where 
  (mg.numRows > 1)
order by 
    mg.patID
  , mg.spEdSvcCode
  , mg.spEdFreqCode
  , mg.mergedEndDate
option(recompile)

/*###########################################################################*/
/*#                 Merge - Update @spEdDataImported                        #*/
/*#                          Flag Rows to Merge                             #*/
/*###########################################################################*/

;with
cte_p1
as
(
  select 
    t3.promisedServiceIdx 
  , mergedIdx = t1.idx
  from @spEdDataMerges as t1
  cross apply (
    select 
      promisedServiceIdx = convert(bigint,t2.[value])
    from string_split(t1.rowIdxs,',') as t2
  )
as t3
)

update psr
set 
   psr.mergedIdx = p1.mergedIdx  
from cte_p1               as p1
join @spEdDataImported    as psr on psr.idx = p1.promisedServiceIdx
option(recompile)

/*###########################################################################*/
/*#                   Merge - Update @spEdDataImported                      #*/
/*#               Determine value for merged individual                     #*/
/*###########################################################################*/

update psm
set 
  psm.individualSvc = 1
from @spEdDataMerges     as psm
join @spEdDataImported   as psr on psr.mergedIdx = psm.idx
where 
  (psr.individualSvc = 1)
option(recompile)

/*###########################################################################*/
/*#                   Merge - Update @spEdDataImported                      #*/
/*#               Determine value for merged group                          #*/
/*###########################################################################*/

update psm
set 
  psm.groupSvc = 1
from @spEdDataMerges    as psm
join @spEdDataImported  as psr on psr.mergedIdx = psm.idx
where 
  (psr.groupSvc = 1)
option(recompile)

/*###########################################################################*/
/*#                   Merge - Update @spEdDataImported                      #*/
/*#          Determine value for merged nextFileDoesNotHaveSvc              #*/
/*###########################################################################*/

update psm
set 
  psm.nextFileDoesNotHaveSvc = 1
from @spEdDataMerges    as psm
join @spEdDataImported  as psr on psr.mergedIdx = psm.idx
where 
  (psr.nextFileDoesNotHaveSvc = 1)
option(recompile)

/*###########################################################################*/
/*#                   Merge - Update @spEdDataImported                      #*/
/*#          Determine value for merged nextFileDoesNotHavePat              #*/
/*###########################################################################*/

update psm
set 
  psm.nextFileDoesNotHavePat = 1
from @spEdDataMerges    as psm
join @spEdDataImported  as psr on psr.mergedIdx = psm.idx
where 
  (psr.nextFileDoesNotHavePat = 1)
option(recompile)

/*###########################################################################*/
/*#               Merge - Populate @spEdDataMergesSvcDetails                #*/
/*#                           Extract Svc Details                           #*/
/*###########################################################################*/

insert into @spEdDataMergesSvcDetails (
   mergedIdx
 , rowIdx
 , svcLineIdx          
 , newSvcLineIdx
 , doNotReport         
 , fileID              
 , fileRowID           
 , hasEndDate          
 , duration            
 , spEdLocationCode    
 , spEdLocationName    
 , individualSvc       
 , groupSvc            
 , spEdProviderCode    
 , spEdProviderName    
 , spEdDisabilityCode1 
 , spEdDisabilityName1 
 , spEdDisabilityCode2 
 , spEdDisabilityName2 
 , spEdSpecTransport 
 , lastEvalDate     
 , lastAnnIEPDate   
 , nextAnnIEPDate   
 , exitedSpEdDate   
 , caseManagerName  
 , additionalInfo   
 , reportableToCDE  
 , reportedStartDate
 , reportedEndDate
 , deliverySummary  
)
select 
   psr.mergedIdx
 , rowIdx = psr.idx
 , t1.svcLineIdx          
 , newSvcLineIdx = ROW_NUMBER() over (partition by psr.mergedIdx order by psr.idx, t1.svcLineIdx)
 , t1.doNotReport         
 , t1.fileID              
 , t1.fileRowID           
 , t1.hasEndDate          
 , t1.duration            
 , t1.spEdLocationCode    
 , t1.spEdLocationName    
 , t1.individualSvc       
 , t1.groupSvc            
 , t1.spEdProviderCode    
 , t1.spEdProviderName    
 , t1.spEdDisabilityCode1 
 , t1.spEdDisabilityName1 
 , t1.spEdDisabilityCode2 
 , t1.spEdDisabilityName2 
 , t1.spEdSpecTransport 
 , t1.lastEvalDate     
 , t1.lastAnnIEPDate   
 , t1.nextAnnIEPDate   
 , t1.exitedSpEdDate   
 , t1.caseManagerName  
 , t1.additionalInfo   
 , t1.reportableToCDE  
 , reportedStartDate = isnull(t1.reportedStartDate,psr.startDate)
 , reportedEndDate   = isnull(t1.reportedEndDate,  psr.endDate)
 , t1.deliverySummary  
from @spEdDataImported as psr
cross apply (
  select 
    t0.*
  from dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Parse_Svc_Lines_Details_JSON (psr.svcLinesDetailsJSON) as t0
) as t1
where 
  (psr.mergedIdx != -1)
option(recompile)

/*###########################################################################*/
/*#             Merge - Populate @spEdDataMergeFileStats                    #*/
/*#                           Generate file stats                           #*/
/*###########################################################################*/

insert into @spEdDataMergesFileStats (
    mergedIdx
  , latestFileID
  , latestFileRowID
)  
select 
    t1.mergedIdx
  , latestFileID    = max(t1.fileID)
  , latestFileRowID = max(t1.fileRowID)
from @spEdDataMergesSvcDetails as t1
group by 
  t1.mergedIdx
option(recompile)

/*###########################################################################*/
/*#             Merge - Populate @spEdDataMergesSvcDetailsJSON              #*/
/*#                          Aggregate Svc Details                          #*/
/*###########################################################################*/

;with
cte_p1
as
(
select 
    mergedIdx = psm.idx
  , svcLineDetailsJSON = dbo.Patient_Data_Imports_Parse_SpEd_Data_File_Row_Create_Svc_Line_Details_JSON (
      psmd.newSvcLineIdx
	, psmd.doNotReport
	, psmd.fileID
    , psmd.fileRowID 
	, psmd.hasEndDate
	, psmd.duration 
	, psmd.spEdLocationCode
	, psmd.spEdProviderCode
	, psmd.individualSvc
	, psmd.groupSvc
    , psmd.spEdDisabilityCode1
	, psmd.spEdDisabilityCode2
	, psmd.spEdSpecTransport
	, psmd.lastEvalDate
    , psmd.lastAnnIEPDate
    , psmd.nextAnnIEPDate 
    , psmd.exitedSpEdDate	
	, psmd.caseManagerName
	, psmd.additionalInfo
	, psmd.reportableToCDE	
	, psmd.reportedStartDate
	, psmd.reportedEndDate
)
from @spEdDataMerges           as psm
join @spEdDataMergesSvcDetails as psmd on psmd.mergedIdx = psm.idx
)

insert into @spEdDataMergesSvcDetailsJSON (
    mergedIdx
  , svcLinesDetailsJSON
)
select 
   p1.mergedIdx
 , svcLinesDetailsJSON = '[' + STRING_AGG(convert(varchar(max),p1.svcLineDetailsJSON),',') +']'
from cte_p1 as p1
group by 
  p1.mergedIdx
option(recompile)

/*###########################################################################*/
/*#  Remove rows flagged for merge                                          #*/
/*###########################################################################*/

delete @spEdDataImported where (mergedIdx != -1) option(recompile)

/*###########################################################################*/
/*#  Add merged rows                                                        #*/
/*###########################################################################*/

insert into @spEdDataImported (
    patID                 
  , latestFileID          
  , latestFileRowID       
  , spEdSvcCode          
  , spEdFreqCode         
  , duration           
  , individualSvc     
  , groupSvc         
  , startDate       
  , endDate         
  , numSvcLines     
  , svcLinesDetailsJSON
  , nextFileDoesNotHaveSvc 
  , nextFileDoesNotHavePat
)
select 
    t1.patID
  , t3.latestFileID
  , t3.latestFileRowID
  , t1.spEdSvcCode
  , t1.spEdFreqCode
  , t1.duration
  , t1.individualSvc
  , t1.groupSvc
  , startDate = t1.mergedStartDate
  , endDate   = t1.mergedEndDate
  , t1.numSvcLines
  , t2.svcLinesDetailsJSON
  , t1.nextFileDoesNotHaveSvc
  , t1.nextFileDoesNotHavePat
from @spEdDataMerges               as t1
join @spEdDataMergesSvcDetailsJSON as t2 on t2.mergedIdx = t1.idx
join @spEdDataMergesFileStats      as t3 on t3.mergedIdx = t1.idx
option(recompile)

/*###########################################################################*/
/*#          Cleanup temp data we no longer need                            #*/
/*###########################################################################*/

delete @spEdDataMerges               option(recompile)
delete @spEdDataMergesSvcDetails     option(recompile)
delete @spEdDataMergesFileStats      option(recompile)
delete @spEdDataMergesSvcDetailsJSON option(recompile)

/*###########################################################################*/
/*#                           Output                                        #*/
/*###########################################################################*/

insert into @recs (
    patID                
  , latestFileID        
  , latestFileRowID
  , latestFileDate     
  , spEdSvcCode         
  , spEdFreqCode        
  , duration            
  , individualSvc       
  , groupSvc            
  , startDate           
  , endDate
  , nextFileDoesNotHaveSvc 
  , nextFileDoesNotHavePat
  , nextFileID
  , nextFileDate              
  , numSvcLines         
  , svcLinesDetailsJSON 
)
select     
    patID                
  , latestFileID        
  , latestFileRowID
  , latestFileDate = t2.fileDate     
  , spEdSvcCode         
  , spEdFreqCode        
  , duration            
  , individualSvc       
  , groupSvc            
  , startDate           
  , endDate             
  , nextFileDoesNotHaveSvc
  , nextFileDoesNotHavePat
  , nextFileID   = t2.nextFileID
  , nextFileDate = convert(date,t2.nextFileDate)
  , numSvcLines         
  , svcLinesDetailsJSON 
from @spEdDataImported              as t1
join @svcImportFileHistoryForClient as t2 on t2.fileID = t1.latestFileID
option(recompile)

/*###########################################################################*/
/*#          Cleanup temp data we no longer need                            #*/
/*###########################################################################*/

delete @svcImportFileHistoryForClient option(recompile)
delete @spEdDataImported              option(recompile)
return

end
GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patient_Data_Imports_Parse_SpEd_Data_File_Summary_Rows_Into_Promised_Services_Core] TO [webuser]
GO   

