use SPEDMON 
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_PROCESS_CLAIM_ACKNOWLEDGE_DATA') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_PROCESS_CLAIM_ACKNOWLEDGE_DATA
end
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.CYBHI_PROCESS_CLAIM_ACKNOWLEDGE_DATA (
    @userID                  bigint        = -1
  , @pathFileName            nvarchar(512) = N''
  , @fileContents            varchar(max)  = ''  
  , @loadContentFromFile     bit           = 1
  , @showResultSets          bit           = 1
  , @rollbackRejectedClaims  bit           = 0
)
AS
BEGIN

/***************************************************************************    
 * CYBHI_PROCESS_CLAIM_ACKNOWLEDGE_DATA */    
/**    
 * Processes subset of ack data in 277
 *
 * 
 ***************************************************************************/            

/*###########################################################################*/
/*#                            Init                                         #*/
/*###########################################################################*/

set nocount on

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Starting'

declare @msg            as varchar(512) = ''
declare @tranOpen       as bit          = 0
declare @today          as datetime     = getdate()
declare @numTxSets      as int          = 0
declare @numValidTxSets as int          = 0
declare @numFound       as int          = 0
declare @numAccepted    as int          = 0
declare @numRejected    as int          = 0

declare @segments as dbo.X12Segments
declare @elements as dbo.X12Elements

declare @txSets as table (
    idCode       varchar(3)
  , controlNum   varchar(9)
  , typeCode     varchar(2)
)

declare @claimsData as table (    
    claimTrackingValue varchar(20)
  , claimStatusValue   varchar(2)  
  unique clustered (claimTrackingValue)
)

declare @cbhiClaims as table (
	  claimID      bigint
	, txStatusCode smallint
	, svcRecID     bigint	
	, accepted     bit 
	, txClaimID    bigint
  unique clustered(claimID)
)
  
declare @cybhiSvcs as table (
    svcRecID    bigint
  , svcRecState smallint
  , accepted    bit 
unique clustered (svcRecID)
)
 
begin try

/*###########################################################################*/
/*#                           Check User ID                                 #*/
/*###########################################################################*/

if (@userID = -1)
begin
  RAISERROR ('User ID is required', 11, 1)
  return
end

/*###########################################################################*/
/*#                    Load X12 Data from File                              #*/
/*###########################################################################*/

if (@loadContentFromFile = 1)
begin
  
  if (@pathFileName = '')
  begin
    RAISERROR ('No file name provided', 11, 1)
    return
  end

  set @fileContents = ''
  
  exec dbo.ReadStringFromFile @pathFileName, @fileContents OUTPUT
end

if (@fileContents = '')
begin
  RAISERROR ('File contents are empty', 11, 1)
  return
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#            Parse File Contents into Segments and Elements               #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Parsing into Segments and Elements'

insert into @segments select segs.* from dbo.X12ParseX12FileContentsIntoX12Segments (@fileContents) as segs
insert into @elements select elms.* from dbo.X12ParseX12SegmentsIntoX12Elements (@segments)         as elms

if (@showResultSets = 1)
begin
  select what = '277 Segments', t1.* from @segments as t1 order by t1.tx_control_number, t1.tx_start_idx, t1.tx_end_idx, idx
  --select * from @elements order by segment_idx, idx
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                          Validate Tx Sets                               #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Validate Against Rules for 277 Claim Ack Transactions'

;with
cte_p1
as
(
  select 
      stSegIdx     = segs.idx
	, idCode       = elems1.data_element
    , controlNum   = elems2.data_element
    , bhtSegIdx    = segs.idx + 1
  from @segments as segs 
  join @elements as elems1 on (elems1.segment_idx = segs.idx) and (elems1.element_ref = '01')
  join @elements as elems2 on (elems2.segment_idx = segs.idx) and (elems2.element_ref = '02')
  where 
    (segs.segment_name = 'ST') 
)
insert into @txSets(idCode, controlNum, typeCode)
select 
    p1.idCode
  , p1.controlNum
  , typeCode = elems6.data_element
from cte_p1 as p1
join @segments as segs   on segs.idx = p1.bhtSegIdx
join @elements as elems6 on ((elems6.segment_idx = segs.idx) and (elems6.element_ref = '06'))
where 
  (segs.segment_name = 'BHT')

if (@showResultSets = 1)
begin
  select what = '277 TX Sets', t1.* from @txSets as t1
end

set @numTxSets = 0

select @numTxSets = count(t1.controlNum) from @txSets as t1
if (@numTxSets = 0)
begin
  RAISERROR ('File does not contain any transaction sets', 11, 1)
  return
end

set @numValidTxSets = 0

select @numValidTxSets = count(t1.controlNum)
from @txSets as t1
where (
      (t1.idCode = '277') 
  and (t1.typeCode = 'TH')
)

if (@numValidTxSets = 0)
begin
  RAISERROR ('File does not contain any valid 277 - Claim Ack transaction sets', 11, 1)
  return
end

if (@numTxSets != @numValidTxSets)
begin
  RAISERROR ('File can only contain 277 - Claim Ack transaction sets', 11, 1)
  return
end

/*---------------------------------------------------------------------------------------------------------*/


/*###########################################################################*/
/*#       Extract JUST the claim tracking and claim status data             #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Extracting claim tracking and status data from segements and elements'

/*
 * Pass 1 - Find TRN segments and get claim tracking ID
 *
 * Excludes any TRN segments that dont have a TRN01 value of 2 and exclude any segments that
 * have the application name tracking id in TRN02.  
 */

;with
cte_p1
as
(
  select distinct 
      trnSegIdx          = segsTrn.idx
    , claimTrackingValue = elmsTrn2.data_element 
  from @segments as segsTrn 
  join @elements as elmsTrn1 on elmsTrn1.segment_idx = segsTrn.idx
  join @elements as elmsTrn2 on elmsTrn2.segment_idx = segsTrn.idx
  
  /* Limit to claim tracking ids (patient control number) */
  
  where (        
	    (segsTrn.segment_name = 'TRN')
    and ((elmsTrn1.element_ref = '01') and (elmsTrn1.data_element = '2'))
    and ((elmsTrn2.element_ref = '02') and (elmsTrn2.data_element != 'SPEDCARECYBHI1')) 
  )
)
,

/*
 * Pass 2 - Find adjacent (to the right of TRN segments) STC segments and get claim status
 *
 * Excludes any TRN that dont have STC segments immediately after. 
 * Futher exclude any STC segs that dont have the reject or accept values in STC 03.
 * 
 */

cte_p2
as
(
  select distinct 
      p1.trnSegIdx
    , p1.claimTrackingValue
    , stcSegIdx        = segsStc.idx
    , claimStatusValue = elmsStc3.data_element
  from cte_p1    as p1
  join @segments as segsStc  on segsStc.idx          = (p1.trnSegIdx + 1) /* Right of */
  join @elements as elmsStc3 on elmsStc3.segment_idx = segsStc.idx 

  where (
        (segsStc.segment_name = 'STC')
    and (elmsStc3.element_ref = '03')
    and (elmsStc3.data_element in ('WQ','U'))  /* U = Reject, WQ = Accept */
  )
)

insert into @claimsData (
    claimTrackingValue
  , claimStatusValue
)

select 
    claimTrackingValue = trim(p2.claimTrackingValue)
  , claimStatusValue   = trim(p2.claimStatusValue) 
from cte_p2 as p2

if (@showResultSets = 1)
begin
  select what = '277 Claim Tracking and Status', t1.* from @claimsData as t1
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                              Find Claims                                #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Finding Claims'

insert into @cbhiClaims (
    claimID     
  , txStatusCode
  , svcRecID 
  , accepted 
  , txClaimID
)
select 
	  t2.claimID
	, t3.txStatusCode
    , t2.svcRecID	
    , accepted = case when t1.claimStatusValue = 'WQ' then 1
	                  when t1.claimStatusValue = 'U'  then 0
		              else null 
	  end
  
   , txClaimID = t2.id

from @claimsData                         as t1
join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as t2 on t2.referenceID = t1.claimTrackingValue
join dbo.CYBHI_CLAIMS                    as t3 on t3.id          = t2.claimID

set @numFound = 0

select @numFound = count(t1.claimID) from @cbhiClaims as t1

if (@numFound = 0)
begin
  RAISERROR ('No claims found', 11, 1)
  return
end

if (@showResultSets = 1)
begin
  select 
     what = 'SpEdCare CYBHI Claims'
    , t1.* 
    , t2.active
	, t2.referenceID
	, svcName = t5.NAME
	, t2.siteID
	, t3.patID
	, t3.claimingPracID
	, t3.supervisingPracID
	, t3.renderingPracID
	, t3.claimWithWhatPracMode
	, t3.txStatusCode
  
  from @cbhiClaims                         as t1
  join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as t2 on t2.id = t1.txClaimID
  join dbo.CYBHI_CLAIMS                    as t3 on t3.id = t2.claimID
  join dbo.CLAIM_Procedures                as t4 on t4.PROCEDURE_ID = t3.procedureID
  join dbo.CLAIM_CYBHI_Names               as t5 on t5.CYBHI_NAME_ID = t4.CYBHI_NAME
  order by 
    t1.accepted asc
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                              Find Svc Records                           #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Finding Svc Recs'

insert into @cybhiSvcs (
     svcRecID
   , svcRecState 
   , accepted
)
select distinct
    cctc.svcRecID
  , svcRecState = sr.[state]
  , cctc.accepted
from @cbhiClaims            as cctc
join dbo.SERVICE_RECORDS    as sr on sr.id = cctc.svcRecID

if (@showResultSets = 1)
begin
  select what = 'SpEdCare CYBHI Svcs', t1.* 
  from @cybhiSvcs as t1
end

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#                    Get Accepted/Rejected Stats                          #*/
/*###########################################################################*/

set @numAccepted = 0
set @numRejected = 0

select @numAccepted = count(t1.claimID) from @cbhiClaims as t1 where t1.accepted = 1
select @numRejected = count(t1.claimID) from @cbhiClaims as t1 where t1.accepted = 0

set @msg = 'CYBHI Process Claim Acknowledge Data - Claims' 
         + ' - Claim Lines Found : '    + convert(varchar(50),@numFound)
		 + ' - Claim Lines Accepted : ' + convert(varchar(50),@numAccepted)
		 + ' - Claim Lines Rejected : ' + convert(varchar(50),@numRejected)

exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

/*###########################################################################*/
/*#               Rollback Rejected Claims and Services                     #*/
/*###########################################################################*/

set @tranOpen = 0

if (@numRejected > 0)
begin

  if exists (select top 1 claimID from @cbhiClaims where ((txStatusCode != 2) and (accepted = 0)))
  begin
    RAISERROR ('All rejected claims have to be in a submitted status', 11, 1)
    return
  end

  if exists (select top 1 svcRecID from @cybhiSvcs where ((svcRecState != 20) and (accepted = 0)))
  begin
    RAISERROR ('All rejected svcs have to be in submitted status',11,1)
    return
  end

end

if ((@numRejected > 0) and (@rollbackRejectedClaims = 1))
begin
  
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Rolling Back Rejected Claims and Services'

  
  set @tranOpen = 1
  begin transaction
  
    update clm 
    set 
        clm.txStatusCode   = 1
	  , clm.lastModified   = @today
	  , clm.lastModifiedBy = @userID
	  , clm.numOfSubmissions = iif ((clm.numOfSubmissions > 0)
	                              , (clm.numOfSubmissions - 1)
								  , 0)
    from @cbhiClaims as t1
    join dbo.CYBHI_CLAIMS as clm on clm.id = t1.claimID
    where 
	  (t1.accepted = 0)

    update sr
    set
        sr.state        = 10
	  , sr.lastmodified = dbo.CONST_SVC_REC_STATE_MOD()
    from @cybhiSvcs          as t1
    join dbo.SERVICE_RECORDS as sr on sr.id = t1.svcRecID
    where 
	  (t1.accepted = 0)

    update cct
	set 
	  cct.active = 0
	from @cbhiClaims                         as t1
    join dbo.CYBHI_CLAIM_TRANSMISSION_CLAIMS as cct on cct.id = t1.txClaimID
    where (
	      (cct.claimID = t1.claimID)
	  and (t1.accepted = 0)
	)

    commit transaction
	set @tranOpen = 0
end


/*###########################################################################*/
/*#                             Done                                        #*/
/*###########################################################################*/

end try
begin catch
  if (@tranOpen = 1) rollback transaction
  set @tranOpen = 0
  declare @errorMessage  as nvarchar(4000) = N''
  set @errorMessage = N'CYBHI Process Claim Acknowledge Data - ** ERROR ** ' + ERROR_MESSAGE()  
  exec dbo.PRINT_STATUS_MESSAGE @errorMessage
end catch

/*###########################################################################*/
/*#                             Done                                        #*/
/*###########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Process Claim Acknowledge Data - Done'

return

/*---------------------------------------------------------------------------------------------------------*/

END
GO
