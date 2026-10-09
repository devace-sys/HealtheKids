use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_APPLY_TX_SIZE_LIMIT_HOLDS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_TX_SIZE_LIMIT_HOLDS
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_APPLY_TX_SIZE_LIMIT_HOLDS (
  @generationID as bigint
)

AS
BEGIN

/******************************************************************************************
 *
 * TRANSMISSION_GENERATION_APPLY_TX_SIZE_LIMIT_HOLDS
 * 
 *	Holds any claim that will push the size of the transmission to over 5000 CLM segments
 *	Uses prioritization logic to help ensure every claim will get sent eventually
 ******************************************************************************************/
set nocount on

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Starting'

declare @today          as datetime   = getdate()
declare @oldestDOS		as datetime   = dbo.CALC_OLDEST_DOS_ALLOWED(@today)

declare @claims as table (
    CLAIM_ID              bigint
  , IS_PROXY              bit
  , DAYS_TILL_AGE_OUT     int  
  , NUMBER_OF_SUBMISSIONS bigint
  , PRIORITY_NUMBER       bigint
unique clustered (CLAIM_ID)
)

declare @claimTxSlotKeys table (
     CLAIM_ID                 bigint
   , TX_SLOT_KEY              bigint
   , IDX                      int identity(1,1)
  unique clustered (CLAIM_ID, TX_SLOT_KEY, IDX)
)

declare @txSlots as table (    
      TX_SLOT  bigint
	, CLAIM_ID bigint    
    , HOLD_FOR_NEXT_TX bit default(0)
  unique clustered (TX_SLOT,CLAIM_ID)
)

declare @txSlotStatsDetails as table (
    TX_SLOT    bigint
  , NUM_CLAIMS int
unique clustered (TX_SLOT)
)

declare @txSlotStatsTotals as table (
    TX_SLOT              bigint
  , RUNNING_TOTAL_CLAIMS int
unique clustered (TX_SLOT)
)

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Get claims that are not held'

insert into @claims (
    CLAIM_ID
  , IS_PROXY  
  , DAYS_TILL_AGE_OUT
  , NUMBER_OF_SUBMISSIONS
)
select distinct 
     clm.CLAIM_ID 
  , clm.IS_PROXY
  , DAYS_TILL_AGE_OUT = (datediff(day,clm.SERVICE_DATE,@oldestDOS))*-1
  , clm.NUMBER_OF_SUBMISSIONS	   
from dbo.TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS(@generationID) as tgrc
join dbo.CLAIM_CLAIM as clm on clm.CLAIM_ID = tgrc.ClaimID
option(recompile)	

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Calculate priority'

update t1
set 
  t1.PRIORITY_NUMBER = (t1.DAYS_TILL_AGE_OUT + t1.NUMBER_OF_SUBMISSIONS)
from @claims as t1
option(recompile)	

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Get tx slot keys 1 of 2 - Stand alone claims'

insert into @claimTxSlotKeys (CLAIM_ID, TX_SLOT_KEY)
select 
    CLAIM_ID                 = t1.CLAIM_ID
  , TX_SLOT_KEY              = src.svcRecID   
from @claims as t1
join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID = t1.CLAIM_ID
where 
  (t1.IS_PROXY = 0)
option(recompile)	

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Get tx slot keys 2 of 2 - Proxy claims'

insert into @claimTxSlotKeys  (CLAIM_ID, TX_SLOT_KEY)
select
     t1.CLAIM_ID
   , TX_SLOT_KEY      = max(src.svcRecID) /* We just need one of the related */  
from @claims as t1
join dbo.CLAIM_Claim as pclm on pclm.CLAIM_ID = t1.CLAIM_ID
join dbo.CLAIM_CLAIM as cclm on ((cclm.HAS_PROXY = 1)
                             and (cclm.REFERENCE_CLAIM_ID_1 = pclm.CLAIM_ID)
							 and (cclm.CLAIM_ID > 0))

join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID = cclm.CLAIM_ID
where 
  (t1.IS_PROXY = 1)
group by 
  t1.CLAIM_ID
option(recompile)	

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Determine tx slot values'

insert into @txSlots (TX_SLOT, CLAIM_ID)
select 
    TX_SLOT = dense_rank() over(order by t1.TX_SLOT_KEY)
  , t1.CLAIM_ID 
from @claimTxSlotKeys  as t1
join @claims           as t2 on t2.CLAIM_ID = t1.CLAIM_ID
order by 
  t2.PRIORITY_NUMBER asc
option(recompile)	

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Counting clm lines per slot'

insert into @txSlotStatsDetails(TX_SLOT,NUM_CLAIMS)
select     
  t1.TX_SLOT
, NUM_CLAIMS = count(t1.CLAIM_ID)
from @txSlots as t1
group by 
  t1.TX_SLOT
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Generate running total of clm lines'

insert into @txSlotStatsTotals(TX_SLOT, RUNNING_TOTAL_CLAIMS)
select
    t1.TX_SLOT
  , RUNNING_TOTAL = sum(t1.NUM_CLAIMS) over(order by t1.TX_SLOT rows unbounded preceding)
from @txSlotStatsDetails as t1
order by 
  t1.TX_SLOT
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Mark all slots above 5000 as held'

update t2
  set t2.HOLD_FOR_NEXT_TX = 1 
from @txSlotStatsTotals as t1
join @txSlots           as t2 on t2.TX_SLOT = t1.TX_SLOT
where 
  (t1.RUNNING_TOTAL_CLAIMS > 5000)
option(recompile)

if exists (select top 1 t1.CLAIM_ID from @txSlots as t1 where t1.HOLD_FOR_NEXT_TX = 1)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - CLAIMS WERE HELD.  Generate another transmission ASAP.'		

  insert into dbo.TRANSMISSION_GENERATION_LIST_CLAIMS_HELD (GenerationID, ClaimID, holdReason, GenListClaimID)
  select 
      @generationID
    , t1.CLAIM_ID
    , 'Transmission size exceeded. Claim held for next transmission.'
	, GenListClaimID = tg2.id
  
  from @txSlots as t1
  cross apply (
    select top 1 
      tg1.id 
    from dbo.TRANSMISSION_GENERATION_LIST_CLAIMS as tg1
    where 
          (tg1.GenerationID = @generationID)
      and (tg1.ClaimID      = t1.CLAIM_ID)
  ) as tg2
  where (        
	(t1.HOLD_FOR_NEXT_TX = 1)
  )
  option(recompile)	
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Nothing held'		
end

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Applying Tx Size Limit Holds - Done'		

END
GO