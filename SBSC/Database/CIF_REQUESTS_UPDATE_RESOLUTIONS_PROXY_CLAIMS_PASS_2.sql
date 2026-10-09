USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2]  
AS    

BEGIN     
    
/***************************************************************************    
 * CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2 */    
/**    
 * 
 * Note: This routine works using a pass by pass/bucket style of processing
 * where items that are marked as resolved are not processed in later passes
 ***************************************************************************/         

SET NOCOUNT ON        

BEGIN TRY

declare @proxyCifRequests as table (
    cifRequestID                      bigint
  , saveTypeID                        int
  , svcRecID                          bigint
  , dosOrAttendanceChanged            bit
  , svcSelectionOrModalityChanged     bit
  , numOfClaimsChanged                bit
  , siblingServiceWasChangedOrDeleted bit
  , replacementSvcRecID               bigint
unique clustered (cifRequestID)
)

declare @proxyCifRequestsStats as table (
    cifRequestID                       bigint
  , numProxyClaims                     int default(0)
  , numProxyClaimsThatHaveBeenResolved int default(0)
  , resolved                           bit default(0)
  , resolution                         varchar(max) default('')
  , cifSubmissionRequired              bit default(0)
unique clustered (cifRequestID)
)

declare @parentClaimData as table (
    parentClaimID              bigint
  , okToResolve                bit          default(1)
  , lx                         int
  , numUnits                   int          
  , claimStatus                int
  , ccn                        nchar(13)
  , numAdjudicationRecs        int          default(0)
  , netAmountPaid              money        default(0)
  , noActionNeeded             bit          default(0)
  , cifAlreadySubmitted        bit          default(0)
  , shouldSubmitCIF            bit          default(0)
  , waitingForAdjudication     bit          default(0)
  , deactivateClaims           bit          default(0)
  , resolved                   bit          default(0)
  , resolution                 varchar(512) default('') 
  , childClaimsCsv             varchar(max) default('')         
  unique clustered (parentClaimID)
)

declare @childClaimData as table (
      parentClaimID              bigint
    , childClaimID               bigint
    , cifRequestID               bigint
    , svcRecID                   bigint
    , needsCifRequestRecord      bit default(1)
  unique clustered (parentClaimID, childClaimID, cifRequestID)
)

declare @parentClaimsThatHaveMissingCifRequestRecords as table (
    parentClaimID bigint
  unique clustered (parentClaimID)
)

declare @tranCount as int
declare @userID    as bigint
declare @today     as datetime

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Starting'

set @tranCount     = 0
set @userID        = 0
set @today         = GETDATE()

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                            Get Unresolved Proxy CIF Requests                                    #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Get Unresolved CIF Requests'

insert into @proxyCifRequests (
    cifRequestID
  , saveTypeID
  , svcRecID
  , dosOrAttendanceChanged
  , svcSelectionOrModalityChanged
  , numOfClaimsChanged
  , siblingServiceWasChangedOrDeleted
  , replacementSvcRecID
)
select distinct
      cifRequestID = cr.id
	, cr.saveTypeID
    , cr.svcRecID
	, cr.dosOrAttendanceChanged
	, cr.svcSelectionOrModalityChanged	
	, cr.numOfClaimsChanged
	, cr.siblingServiceWasChangedOrDeleted
	, cr.replacementSvcRecID
from dbo.CIF_REQUESTS        as cr
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.cifRequestID = cr.id
join dbo.CLAIM_Claim         as clm on clm.CLAIM_ID = crc.claimID
where ( 
      (cr.resolved   = 0)
  and (clm.HAS_PROXY = 1)
  and (clm.IS_PROXY  = 0)
)

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                            Get All Parent and Child Claims                                      #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Get All Parent and Child Claims'

-- ########## Parent Claims ##########

insert into @parentClaimData (
  parentClaimID
)
select distinct
  parentClaimID = clm.REFERENCE_CLAIM_ID_1 
from @proxyCifRequests       as pcr
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.cifRequestID = pcr.cifRequestID
join dbo.CLAIM_Claim         as clm on clm.CLAIM_ID     = crc.claimID
 
-- ########## Child Claims (Default assumption is that all child claims require a cif request record) ##########

insert into @childClaimData (
    parentClaimID
  , childClaimID
)
select 
    pcd.parentClaimID
  , childClaimID = clm.CLAIM_ID 
from @parentClaimData as pcd
join dbo.CLAIM_Claim  as clm on clm.REFERENCE_CLAIM_ID_1 = pcd.parentClaimID
where ( 
      (clm.HAS_PROXY = 1)
  and (clm.IS_PROXY  = 0)
)

-- ########## Child claims CSV ##########

update pcd 
  set pcd.childClaimsCsv = ccd2.childClaimsCsv
from @parentClaimData as pcd
cross apply (
  select 
    childClaimsCsv = STRING_AGG(convert(varchar(50),ccd1.childClaimID), ',')	 
  from @childClaimData   as ccd1 
  where (ccd1.parentClaimID = pcd.parentClaimID)
) as ccd2


-- ########## Determine if svc rec requires cif request record ##########

update ccd
set 
    ccd.cifRequestID          = crc.cifRequestID
  , ccd.svcRecID              = crc.svcRecID
  , ccd.needsCifRequestRecord = 0
from @childClaimData         as ccd
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.claimID = ccd.childClaimID

-- ########## Create stats starting with number of claims ##########

insert into @proxyCifRequestsStats (
    cifRequestID
  , numProxyClaims  
)
select 
   pcr.cifRequestID
  ,cpcd.numProxyClaims
from @proxyCifRequests as pcr 
cross apply (
  select 
    numProxyClaims = count(pcd.parentClaimID)
  from @childClaimData   as ccd 
  join @parentClaimData  as pcd on pcd.parentClaimID = ccd.parentClaimID 
  where 
    (ccd.cifRequestID = pcr.cifRequestID)
) as cpcd

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#  Identify Parent Claims We Cannot Resolve Because All Siblings Do Not Have CIF Request Records  #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Identify Parent Claims We Cannot Resolve Because All Siblings Do Not Have CIF Request Records'

insert into @parentClaimsThatHaveMissingCifRequestRecords (
  parentClaimID
)
select distinct 
  ccd.parentClaimID 
from @childClaimData as ccd
where 
  (ccd.needsCifRequestRecord = 1)

update t2
  set t2.okToResolve = 0 
from @parentClaimsThatHaveMissingCifRequestRecords as t1
join @parentClaimData                              as t2 on t2.parentClaimID = t1.parentClaimID

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                            Get Parent Claim Adjudication Status                                 #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Get Parent Claim Adjudication Status'

update pcd
set
    pcd.lx          = clm.LINE_NUMBER
  , pcd.numUnits    = clm.SERVICE_UNITS
  , pcd.claimStatus = convert(int, clm.STATUS)
from @parentClaimData as pcd
join dbo.CLAIM_Claim  as clm on clm.CLAIM_ID = pcd.parentClaimID
where ( 
      (clm.HAS_PROXY = 0)
  and (clm.IS_PROXY = 1)
)

update pcd
set 
    pcd.numAdjudicationRecs = cca2.numAdjRecs
  , pcd.netAmountPaid       = cca2.netAmtPaid
from @parentClaimData as pcd
cross apply (
    select 
	    numAdjRecs = count(cca1.ADJUDICATION_ID)
	  , netAmtPaid = sum(cca1.AMOUNT_PAID) 
    
	from dbo.CLAIM_Claim_Adjudication as cca1
    where 
      (cca1.CLAIM_ID = pcd.parentClaimID)
    group by 
      cca1.CLAIM_ID
) as cca2


update pcd
set 
    pcd.ccn = cca2.CCN
from @parentClaimData as pcd
cross apply (
    /* Get first adjudication record that payment was received for */
    select top 1 
	  cca1.CCN 
	from dbo.CLAIM_Claim_Adjudication as cca1
	where 
	      (cca1.CLAIM_ID = pcd.parentClaimID)
	  and (cca1.AMOUNT_PAID > 0)
	order by 
	  cca1.DATE_ADJUDICATED asc
) as cca2


/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                                  Determine Resolutions                                          #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/


/*###################################################################################################*/
/*#                              Resolve  - No Action Required Cases                                #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Find Cases Where No Action Is Required'

exec dbo.PRINT_STATUS_MESSAGE 'Proxy claim already in void cif submissions table and void cif 837 was submitted'

update pcd
 set 
    pcd.resolved            = 1
  , pcd.noActionNeeded      = 1
  , pcd.cifAlreadySubmitted = 1
  , pcd.resolution          = 'proxy claim already in void cif submissions table and void cif 837 was submitted'
from @parentClaimData                         as pcd
join dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as crcvs on crcvs.claimID = pcd.parentClaimID
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (crcvs.submitted = 1)     
)

exec dbo.PRINT_STATUS_MESSAGE 'Unsubmitted held proxy claim already deactivated'

update pcd
 set 
    pcd.resolved            = 1
  , pcd.noActionNeeded      = 1
  , pcd.resolution          = 'unsubmitted proxy claim already deactivated'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.claimStatus = 5)
)

exec dbo.PRINT_STATUS_MESSAGE 'Proxy claim denied and net amount paid is 0'

update pcd
 set 
    pcd.resolved            = 1
  , pcd.noActionNeeded      = 1
  , pcd.resolution          = 'proxy claim was denied & net amount pay 0'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.claimStatus = dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED())
  and (pcd.netAmountPaid = 0)
)

exec dbo.PRINT_STATUS_MESSAGE 'Proxy claim has 0 units'

update pcd
 set 
    pcd.resolved            = 1
  , pcd.noActionNeeded      = 1
  , pcd.resolution          = 'proxy claim has 0 units'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.numUnits    = 0)
)

exec dbo.PRINT_STATUS_MESSAGE 'Proxy claim paid but net amount paid was less than or equal to 0'

update pcd
 set 
    pcd.resolved            = 1
  , pcd.noActionNeeded      = 1
  , pcd.resolution          = 'proxy claim paid but net amount paid was less than or equal to 0'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.claimStatus = dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID())
  and (pcd.numAdjudicationRecs > 0)
  and (pcd.netAmountPaid <= 0)
)

/*###################################################################################################*/
/*#                              Resolve  - Action Required Cases                                   #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Find Cases Where Action Is Required'

exec dbo.PRINT_STATUS_MESSAGE 'Proxy claim paid and one or more child claims were modified or deleted'

update pcd
 set 
    pcd.resolved            = 1
  , pcd.shouldSubmitCIF     = 1
  , pcd.resolution          = 'proxy claim paid and one or more child claims were modified or deleted'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.claimStatus = dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID())
)

exec dbo.PRINT_STATUS_MESSAGE 'Proxy claim held and never submitted'

update pcd
 set 
    pcd.resolved               = 1
  , pcd.deactivateClaims       = 1
  , pcd.resolution             = 'proxy claim in submitted state but held and never submitted'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.claimStatus = dbo.CONST_CLAIM_STATUS_NOT_SUB())
)

/*###################################################################################################*/
/*#                                     Whats Left                                                  #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Find Cases Where Resolution Cannot Be Determined Yet'

update pcd
 set 
    pcd.resolved               = 0
  , pcd.resolution             = ''
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
)

update pcd
 set 
    pcd.resolved               = 0
  , pcd.waitingForAdjudication = 1
  , pcd.resolution             = 'waiting for adjudication'
from @parentClaimData  as pcd
where (
      (pcd.okToResolve = 1)
  and (pcd.resolved    = 0)
  and (pcd.claimStatus = dbo.CONST_CLAIM_STATUS_SUB_PENDING())
)

update pcd
 set 
    pcd.resolved               = 0
  , pcd.resolution             = 'Unable to resolve until all related service records have CIF request records'
from @parentClaimData  as pcd
where (
	  (pcd.okToResolve = 0)
  and (pcd.resolved    = 0)
)

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                                    Update Stats                                                 #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Update Stats'

-- ########## Count proxy claims that have been resolved ##########

exec dbo.PRINT_STATUS_MESSAGE 'Count proxy claims that have been resolved'

update pcrs
set 
  pcrs.numProxyClaimsThatHaveBeenResolved = cpcd.numClaims
from @proxyCifRequestsStats as pcrs 
cross apply (
  select 
    numClaims = count(pcd.parentClaimID)
  from @childClaimData   as ccd 
  join @parentClaimData  as pcd on pcd.parentClaimID = ccd.parentClaimID 
  where (ccd.cifRequestID = pcrs.cifRequestID) and (pcd.resolved = 1)
) as cpcd


update @parentClaimData set resolution = 'no action needed '          + resolution where ((okToResolve = 1) and (resolved = 1) and (noActionNeeded = 1))
update @parentClaimData set resolution = 'CIF submission required '   + resolution where ((okToResolve = 1) and (resolved = 1) and (shouldSubmitCIF = 1))
update @parentClaimData set resolution = 'deactivate claims '         + resolution where ((okToResolve = 1) and (resolved = 1) and (deactivateClaims = 1))
update @parentClaimData set resolution = 'not resolved yet '          + resolution where (resolved = 0)

-- ########## Compose resolution text ##########

exec dbo.PRINT_STATUS_MESSAGE 'Combine resolution text'

update pcrs
set 
  pcrs.resolution = '- ' + convert(varchar(50),pcrs.numProxyClaims) + ' Proxy Claims '                  
				  + cpcd.resolutions
from @proxyCifRequestsStats as pcrs 
cross apply (
  select 
    resolutions = STRING_AGG('- Claim ' + convert(varchar(10),pcd.lx) + ' ' + pcd.resolution, ' ')	 
  from @childClaimData   as ccd 
  join @parentClaimData  as pcd on pcd.parentClaimID = ccd.parentClaimID 
  where (ccd.cifRequestID = pcrs.cifRequestID)
) as cpcd


-- ########## Determine cif requests that are not fully resolved ##########

exec dbo.PRINT_STATUS_MESSAGE 'Determine if cif request is not fully resolved'

update pcrs
set 
    pcrs.resolved = 0
from @proxyCifRequestsStats as pcrs
where 
  (pcrs.numProxyClaims != pcrs.numProxyClaimsThatHaveBeenResolved) /* Not fully resolved */

-- ########## Determine cif requests that are fully resolved ##########

exec dbo.PRINT_STATUS_MESSAGE 'Determine if cif request is fully resolved'

update pcrs
set 
    pcrs.resolved = 1
from @proxyCifRequestsStats as pcrs
where (
      (pcrs.numProxyClaims = pcrs.numProxyClaimsThatHaveBeenResolved)
  and (pcrs.numProxyClaims != 0)
)

-- ########## Flag if cif required (for reporting) ##########

update pcrs
set 
  pcrs.cifSubmissionRequired = 1
from @proxyCifRequestsStats as pcrs 
join @childClaimData        as ccd on ccd.cifRequestID  = pcrs.cifRequestID
join @parentClaimData       as pcd on pcd.parentClaimID = ccd.parentClaimID 
where 
  ((pcd.shouldSubmitCIF = 1) or (pcd.cifAlreadySubmitted = 1))

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                                    Take Action                                                  #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Take Action'

begin transaction
set @tranCount = 1

-- ########## Update CIF Request Data With Latest ##########

exec dbo.PRINT_STATUS_MESSAGE 'Update CIF requests with latest data'

update cr
set       
      cr.lastModifiedOn        = @today
	, cr.lastModifiedBy        = @userID
	, cr.resolved              = pcrs.resolved
	, cr.resolvedOn            = @today
	, cr.resolvedUsing         = 200 /* 100 = Stand alone claim resolver, 200 = Proxy claim resolved */
	, cr.cifSubmissionRequired = pcrs.cifSubmissionRequired
	, cr.resolution            = pcrs.resolution
from @proxyCifRequestsStats      as pcrs
join dbo.CIF_REQUESTS            as cr on cr.id = pcrs.cifRequestID

-- ########## Deactivate applicable claims ##########

exec dbo.PRINT_STATUS_MESSAGE 'Deactivate applicable claims'

update clm
set 
   clm.STATUS       = '5'
  ,clm.LAST_UPDATED = @today
from @parentClaimData as pcd
join dbo.CLAIM_CLAIM as clm on clm.CLAIM_ID = pcd.parentClaimID
where (
      (pcd.okToResolve      = 1)
  and (pcd.resolved         = 1)
  and (pcd.deactivateClaims = 1)
  and (clm.IS_PROXY = 1)
  and (clm.HAS_PROXY = 0)
)

-- ########## Create claim void submissions ##########

exec dbo.PRINT_STATUS_MESSAGE 'Creating claim void submissions'

insert into dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS (
     clientID 
   , claimID  
   , dos
   , ccn
   , amountToPayBack 
   , proxyClaim
   , childClaimsCsv
   , submitted 
)

select distinct
    clientID        = clm.CLIENT_ID
  , claimID         = pcd.parentClaimID
  , dos             = clm.SERVICE_DATE
  , pcd.ccn
  , amountToPayBack = pcd.netAmountPaid 
  , proxyClaim      = 1
  , childClaimsSvc  = pcd.childClaimsCsv
  , submitted       = 0
from @parentClaimData   as pcd
join dbo.CLAIM_Claim    as clm  on clm.CLAIM_ID = pcd.parentClaimID
where (
      (pcd.okToResolve     = 1)
  and (pcd.resolved        = 1)
  and (pcd.shouldSubmitCIF = 1) 
  and (pcd.netAmountPaid > 0)
  and (pcd.ccn is not null)
  and (pcd.parentClaimID not in (
      select top 1 
	    sac1.claimID 
	  from dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as sac1 
	  where (	  
	    (sac1.claimID  = pcd.parentClaimID)
	  )
  ))
  and (clm.IS_PROXY = 1)
  and (clm.HAS_PROXY = 0) 
)

commit transaction
set @tranCount = 0

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 2 - Done'

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  if (@tranCount > 0) rollback transaction
  
  -- Error or raise error with severity 11 to 19 will be caught here          
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_2] TO [webuser]
GO
