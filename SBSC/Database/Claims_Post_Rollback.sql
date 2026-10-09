use SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_Post_Rollback') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Claims_Post_Rollback
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[Claims_Post_Rollback] (
    @userID                    as bigint        = 0
  , @fileNamePosting           as nvarchar(512) = N''	
  , @test			           as bit           = 1
)  
AS    
BEGIN    

set nocount on

set @userID          = isnull(@userID, -1)
set @fileNamePosting = trim(isnull(@fileNamePosting,N''))
set @test            = isnull(@test,1)

if (@userID = -1)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Please provide a user id'
  return
end

if (@fileNamePosting = N'')
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Please provide a file name'
  return
end

declare @tranOpen                     as bit          = 0
declare @postingDate                  as datetime     = null
declare @today                        as datetime     = getdate()
declare @jsonClaimPostings            as varchar(max) = ''
declare @jsonClaimPostingAdjustements as varchar(max) = ''
declare @jsonClaimAdjudications       as varchar(max) = ''
declare @jsonClaimAdjudicationDetails as varchar(max) = ''
declare @jsonPaymentSummary           as varchar(max) = ''
declare @jsonClaimsStandAlone         as varchar(max) = ''
declare @jsonClaimsProxyParent        as varchar(max) = ''
declare @jsonClaimsProxyChild         as varchar(max) = ''

-----------------------------------------------------------------------------------------------------------------------------------------------

declare @claimPostings as table (
    POSTING_ID bigint
  , CLIENT_ID  bigint
  unique clustered (POSTING_ID)
)

declare @claimPostingsPrevious as table (
    CLIENT_ID       bigint
  , PREV_POSTING_ID bigint
  , PREV_CHECK_DATE date
  unique clustered (CLIENT_ID)
)

declare @claimAdjudications as table (
    ADJUDICATION_ID bigint
  , CLAIM_ID        bigint
  , PROXY_DISBURSED bit
  , POSTING_ID      bigint
unique clustered (ADJUDICATION_ID)
)

declare @claimAdjudicationDetails as table (
    CCAD_ID         bigint
  , ADJUDICATION_ID bigint
  unique clustered (CCAD_ID)
)

declare @claimPostingAdjustments as table (
    ADJUST_ID bigint
  , POSTING_ID bigint
  unique clustered (ADJUST_ID)
)

declare @paymentSummary as table (
    PAYMENT_LINE_ID bigint
  , POSTING_ID      bigint
  unique clustered (PAYMENT_LINE_ID)
)

declare @claimsStandAlone as table (
  CLAIM_ID bigint
  unique clustered (CLAIM_ID)
)

declare @claimsProxyParent as table (
  CLAIM_ID bigint
  unique clustered (CLAIM_ID)
)

declare @claimsProxyChild as table (
    CLAIM_ID        bigint
  , PARENT_CLAIM_ID bigint
  unique clustered (CLAIM_ID)
)

-----------------------------------------------------------------------------------------------------------------------------------------------

if (@test = 1)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'In test mode - Please review data before rolling back.'
end

if (@test = 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'In live mode - Data will be archived and then deleted or updated'
end

-----------------------------------------------------------------------------------------------------------------------------------------------

exec dbo.PRINT_STATUS_MESSAGE 'Get postings'

insert into @claimPostings (POSTING_ID, CLIENT_ID)
select 
    ccp.POSTING_ID
  , CLIENT_ID = ccp.clientID 
from dbo.CLAIM_Claim_Posting as ccp
where 
  (ccp.FILE_NAME_POSTING = @fileNamePosting)
option(recompile)

if not exists (select top 1 * from @claimPostings)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Postings not found'
  return
end

exec dbo.PRINT_STATUS_MESSAGE 'Get posting date (will be same for all posting rows)'

select top 1 
  @postingDate = ccp.POSTING_DATE
from @claimPostings          as t1
join dbo.CLAIM_Claim_Posting as ccp on ccp.POSTING_ID = t1.POSTING_ID

exec dbo.PRINT_STATUS_MESSAGE 'Get previous posting check dates'

;with
cte_p1
as
(
  select distinct 
    t1.CLIENT_ID 
  from @claimPostings as t1
)
insert into @claimPostingsPrevious (CLIENT_ID, PREV_POSTING_ID, PREV_CHECK_DATE)
select 
    t1.CLIENT_ID
  , PREV_POSTING_ID  = t3.POSTING_ID
  , PREV_CHECK_DATE  = t3.CHECK_DATE
from cte_p1 as t1
cross apply (
  select top 1 
      t2.POSTING_ID
    , t2.CHECK_DATE 
  from dbo.CLAIM_Claim_Posting as t2
  where (
        (t2.clientID = t1.CLIENT_ID)
    and (t2.POSTING_ID not in (select cp.POSTING_ID from @claimPostings as cp where (cp.CLIENT_ID = t1.CLIENT_ID)))
  )
  order by 
    t2.POSTING_ID desc
) as t3
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Get claim adjudications'

insert into @claimAdjudications (ADJUDICATION_ID, CLAIM_ID, PROXY_DISBURSED, POSTING_ID)
select 
    cca.ADJUDICATION_ID
  , cca.CLAIM_ID
  , cca.PROXY_DISBURSED 
  , cca.POSTING_ID
from @claimPostings               as cp
join dbo.CLAIM_Claim_Adjudication as cca on cca.POSTING_ID = cp.POSTING_ID
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Get claim adjudication details'

insert into @claimAdjudicationDetails (CCAD_ID,ADJUDICATION_ID)
select 
   ccad.CCAD_ID
  ,ccad.ADJUDICATION_ID
from @claimAdjudications                  as cca
join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS as ccad on ccad.ADJUDICATION_ID = cca.ADJUDICATION_ID
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Get posting adjustements'

insert into @claimPostingAdjustments (ADJUST_ID, POSTING_ID)
select 
    ccpa.ADJUST_ID
  , ccpa.POSTING_ID
from @claimPostings                      as cp
join dbo.claim_claim_posting_adjustments as ccpa on ccpa.POSTING_ID = cp.POSTING_ID
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Get payment summary'

insert into @paymentSummary (PAYMENT_LINE_ID, POSTING_ID)
select 
    ps.PAYMENT_LINE_ID
  , ps.POSTING_ID
from @claimPostings as cp
join dbo.Payment_Summary_By_Client_835 as ps on ps.POSTING_ID = cp.POSTING_ID
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Get stand alone claims'

insert into @claimsStandAlone (CLAIM_ID)
select 
  clms.CLAIM_ID
from @claimAdjudications as ca
join dbo.CLAIM_Claim     as clms on clms.CLAIM_ID = ca.CLAIM_ID
where (
      ((clms.[STATUS] = dbo.CONST_CLAIM_STATUS_SUB_PAID()) or (clms.[STATUS] = dbo.CONST_CLAIM_STATUS_SUB_REJECT()))
  and (clms.HAS_PROXY = 0)
  and (clms.IS_PROXY  = 0)
)

exec dbo.PRINT_STATUS_MESSAGE 'Get proxy parent claims'

insert into @claimsProxyParent (CLAIM_ID)
select 
  clms.CLAIM_ID
from @claimAdjudications as ca
join dbo.CLAIM_Claim     as clms on clms.CLAIM_ID = ca.CLAIM_ID
where (
      ((clms.[STATUS] = dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID()) or (clms.[STATUS] = dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED()))
  and (clms.HAS_PROXY = 0)
  and (clms.IS_PROXY = 1)
)

exec dbo.PRINT_STATUS_MESSAGE 'Get proxy child claims'

insert into @claimsProxyChild (CLAIM_ID,PARENT_CLAIM_ID)
select 
    clms.CLAIM_ID
  , PARENT_CLAIM_ID = clms.REFERENCE_CLAIM_ID_1
from @claimAdjudications as ca
join @claimsProxyParent as cpp on cpp.CLAIM_ID = ca.CLAIM_ID
join dbo.CLAIM_Claim as clms on clms.REFERENCE_CLAIM_ID_1 = cpp.CLAIM_ID
where ( 
      ((clms.[STATUS] = dbo.CONST_CLAIM_STATUS_SUB_PAID()) or (clms.[STATUS] = dbo.CONST_CLAIM_STATUS_SUB_REJECT()))
  and (clms.HAS_PROXY = 1)
  and (clms.IS_PROXY = 0)
)

exec dbo.PRINT_STATUS_MESSAGE 'Creating JSON for data archive'

set @jsonClaimPostings            = convert(varchar(max),(select * from @claimPostings            for json auto, INCLUDE_NULL_VALUES ))
set @jsonClaimPostingAdjustements = convert(varchar(max),(select * from @claimPostingAdjustments  for json auto, INCLUDE_NULL_VALUES))
set @jsonClaimAdjudications       = convert(varchar(max),(select * from @claimAdjudications       for json auto, INCLUDE_NULL_VALUES))
set @jsonClaimAdjudicationDetails = convert(varchar(max),(select * from @claimAdjudicationDetails for json auto, INCLUDE_NULL_VALUES))
set @jsonPaymentSummary           = convert(varchar(max),(select * from @paymentSummary           for json auto, INCLUDE_NULL_VALUES))
set @jsonClaimsStandAlone         = convert(varchar(max),(select * from @claimsStandAlone         for json auto, INCLUDE_NULL_VALUES))
set @jsonClaimsProxyParent        = convert(varchar(max),(select * from @claimsProxyParent        for json auto, INCLUDE_NULL_VALUES))
set @jsonClaimsProxyChild         = convert(varchar(max),(select * from @claimsProxyChild         for json auto, INCLUDE_NULL_VALUES))

-----------------------------------------------------------------------------------------------------------------------------------------------

if (@test = 1)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'In test mode - Displaying data that will be updated or deleted'

  select 
      what= 'Delete postings'
	, ccp.*
  from @claimPostings          as t1
  join dbo.CLAIM_Claim_Posting as ccp on ccp.POSTING_ID = t1.POSTING_ID
                                    and ccp.clientID = t1.CLIENT_ID

  select 
      what ='Update client last check'
	, clc.CLIENT_ID
	, clc.CLIENT_NAME
	, clc.LAST_CHECK
	, t1.PREV_POSTING_ID
	, t1.PREV_CHECK_DATE	
  from @claimPostingsPrevious as t1
  join dbo.CLIENTS_Client     as clc on clc.CLIENT_ID = t1.CLIENT_ID

  select 
      what = 'Delete payment summary'
    , ps.*
  from @paymentSummary as t1
  join Payment_Summary_By_Client_835 as ps on ps.PAYMENT_LINE_ID = t1.PAYMENT_LINE_ID
                                     and ps.POSTING_ID = t1.POSTING_ID

  select 
         what = 'Delete claim adjudication details'
       , ccad.*
  from @claimAdjudicationDetails as t1
  join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS as ccad on ccad.CCAD_ID          = t1.CCAD_ID
                                                    and ccad.ADJUDICATION_ID = t1.ADJUDICATION_ID
 
  select 
      what = 'Delete posting adjustments'
    , ccpa.*
  from @claimPostingAdjustments as t1
  join dbo.claim_claim_posting_adjustments as ccpa on ccpa.ADJUST_ID = t1.ADJUST_ID
                                                 and ccpa.POSTING_ID = t1.POSTING_ID


  select 
      what = 'Delete claim adjudications'
    , cca.*
  from @claimAdjudications as t1
  join dbo.CLAIM_Claim_Adjudication as cca on cca.ADJUDICATION_ID = t1.ADJUDICATION_ID
                                           and cca.POSTING_ID     = t1.POSTING_ID

  select 
      what = 'Update stand alone claims'
	, clms.*
  from @claimsStandAlone as t1
  join dbo.CLAIM_Claim as clms on clms.CLAIM_ID = t1.CLAIM_ID

  select 
      what = 'Update proxy parent claim'
	, clms.*
  from @claimsProxyParent as t1
  join dbo.CLAIM_Claim as clms on clms.CLAIM_ID = t1.CLAIM_ID

  select 
      what = 'Update proxy child claim'
    , clms.*
  from @claimsProxyChild as t1
  join dbo.CLAIM_Claim as clms on clms.CLAIM_ID = t1.CLAIM_ID
  
 
  exec dbo.PRINT_STATUS_MESSAGE 'Exiting because we are in test mode'
  exec dbo.PRINT_STATUS_MESSAGE 'Done'

  return
end
     
-----------------------------------------------------------------------------------------------------------------------------------------------

if (@test = 0)
begin

  exec dbo.PRINT_STATUS_MESSAGE 'In live mode - Rolling back posting'

  begin try

  set @tranOpen = 1
  begin transaction
  
  exec dbo.PRINT_STATUS_MESSAGE 'Creating rollback record to archive previous data'

    insert into dbo.CLAIM_Claim_Posting_Rollback (    
        postingDate 
	  , jsonClaimPostings
      , jsonClaimPostingAdjustements
      , jsonClaimAdjudications      
      , jsonClaimAdjudicationDetails
      , jsonPaymentSummary          
      , jsonClaimsStandAlone        
      , jsonClaimsProxyParent       
      , jsonClaimsProxyChild        
	  , createdBy                   
	  , createdOn 
    )               
    values (
          @postingDate 
	  , @jsonClaimPostings
      , @jsonClaimPostingAdjustements
      , @jsonClaimAdjudications      
      , @jsonClaimAdjudicationDetails
      , @jsonPaymentSummary          
      , @jsonClaimsStandAlone        
      , @jsonClaimsProxyParent       
      , @jsonClaimsProxyChild        
	  , @userID                   
	  , @today
    ) 
	
	exec dbo.PRINT_STATUS_MESSAGE 'Update client last check'
	
    update clc
      set clc.LAST_CHECK = t1.PREV_CHECK_DATE
    from @claimPostingsPrevious as t1
    join dbo.CLIENTS_Client     as clc on clc.CLIENT_ID = t1.CLIENT_ID

	exec dbo.PRINT_STATUS_MESSAGE 'Update stand alone claims'

    update clms
	set 
	  clms.[STATUS]     = dbo.CONST_CLAIM_STATUS_SUB_PENDING()
    , clms.LAST_UPDATED = @today
	from @claimsStandAlone as t1
    join dbo.CLAIM_Claim as clms on clms.CLAIM_ID = t1.CLAIM_ID

    exec dbo.PRINT_STATUS_MESSAGE 'Update proxy parent claims'

    update clms
	set
      clms.[STATUS]     = dbo.CONST_CLAIM_STATUS_SUB_PENDING()
    , clms.LAST_UPDATED = @today
    from @claimsProxyParent as t1
    join dbo.CLAIM_Claim as clms on clms.CLAIM_ID = t1.CLAIM_ID
 
    exec dbo.PRINT_STATUS_MESSAGE 'Update proxy child claims'

	update clms
    set
        clms.[STATUS]     = dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY()
      , clms.LAST_UPDATED = @today
  
    from @claimsProxyChild as t1
    join dbo.CLAIM_Claim as clms on clms.CLAIM_ID = t1.CLAIM_ID

    exec dbo.PRINT_STATUS_MESSAGE 'Delete payment summary'

    delete ps
    from @paymentSummary as t1
    join Payment_Summary_By_Client_835 as ps on ps.PAYMENT_LINE_ID = t1.PAYMENT_LINE_ID
                                   and ps.POSTING_ID = t1.POSTING_ID

    exec dbo.PRINT_STATUS_MESSAGE 'Delete claim adjudication details'

    delete ccad
    from @claimAdjudicationDetails as t1
    join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS as ccad on ccad.CCAD_ID          = t1.CCAD_ID
                                                     and ccad.ADJUDICATION_ID = t1.ADJUDICATION_ID

    exec dbo.PRINT_STATUS_MESSAGE 'Delete claim adjudications'

    delete cca
    from @claimAdjudications as t1
    join dbo.CLAIM_Claim_Adjudication as cca on cca.ADJUDICATION_ID = t1.ADJUDICATION_ID
                                             and cca.POSTING_ID     = t1.POSTING_ID

	exec dbo.PRINT_STATUS_MESSAGE 'Delete posting adjustements'

	delete ccpa
    from @claimPostingAdjustments as t1
    join dbo.claim_claim_posting_adjustments as ccpa on ccpa.ADJUST_ID = t1.ADJUST_ID
                                                    and ccpa.POSTING_ID = t1.POSTING_ID

    exec dbo.PRINT_STATUS_MESSAGE 'Delete postings'

    delete ccp    
    from @claimPostings          as t1
    join dbo.CLAIM_Claim_Posting as ccp on ccp.POSTING_ID = t1.POSTING_ID
                                        and ccp.clientID = t1.CLIENT_ID

  commit transaction 
  set @tranOpen = 0										  
  
  exec dbo.PRINT_STATUS_MESSAGE 'Roll back committed'

  end try
  begin catch
    exec dbo.PRINT_STATUS_MESSAGE 'An issue occured'
	if @tranOpen = 1 
	begin
	  exec dbo.PRINT_STATUS_MESSAGE 'Reverting roll back'
	  rollback transaction
	end
  end catch
end /* test */

exec dbo.PRINT_STATUS_MESSAGE 'Done'
return

END /*of stored procedure*/
GO