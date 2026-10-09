USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS]  
AS    

BEGIN     
    
/***************************************************************************    
 * CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS */    
/**    
 * 
 * Note: This routine works using a pass by pass/bucket style of processing
 * where items that are marked as resolved are not processed in later passes
 ***************************************************************************/         

SET NOCOUNT ON        

BEGIN TRY

declare @standAloneCifRequests as table (
    cifRequestID                  bigint
  , saveTypeID                    int
  , svcRecID                      bigint
  , dosOrAttendanceChanged        bit
  , svcSelectionOrModalityChanged bit
  , numOfClaimsChanged            bit
  , replacementSvcRecID           bigint
unique clustered (cifRequestID)
)

declare @standAloneCifRequestsStats as table (
    cifRequestID                  bigint
  , claimsNegated                 bit default(0)
  , claimCountChanged             bit default(0)
  , numClaims                     int default(0)
  , numClaimsThatHaveBeenResolved int default(0)
  , resolved                      bit default(0)
  , cifSubmissionRequired         bit default(0)
  , resolution                    varchar(max) default('')
unique clustered (cifRequestID)
)

declare @standAloneClaimData as table (
    cifRequestID               bigint
  , claimID                    bigint
  , lx                         int
  , dos                        date
  , numUnits                   int          
  , claimStatus                int
  , ccn                        nchar(13)
  , numAdjudicationRecs        int          default(0)
  , netAmountPaid              money        default(0)
  , noActionNeeded             bit          default(0)
  , cifAlreadySubmitted        bit          default(0)
  , shouldSubmitVoidCIF        bit          default(0)
  , shouldSubmitChangeCIF      bit          default(0)
  , deactivateClaims           bit          default(0)
  , resolved                   bit          default(0)
  , resolution                 varchar(512) default('')            
unique clustered (cifRequestID, claimID)
)

declare @tranCount           as int
declare @userID              as bigint
declare @today               as datetime

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Starting'

set @tranCount           = 0
set @userID              = 0
set @today               = GETDATE()

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                                 DETERMINE UPDATES (IF ANY)                                      #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Determine Updates'

/*###################################################################################################*/
/*#                            Get Unresolved Stand Alone CIF Requests                              #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Determine Updates - Get Unresolved CIF Requests'

-- ########## Get request basic data and data about service record and id of replacement service (if any) ##########

insert into @standAloneCifRequests (
    cifRequestID
  , saveTypeID
  , svcRecID
  , dosOrAttendanceChanged
  , svcSelectionOrModalityChanged
  , numOfClaimsChanged
  , replacementSvcRecID
)

select distinct
      cifRequestID = cr.id
	, cr.saveTypeID
    , cr.svcRecID
	, cr.dosOrAttendanceChanged
	, cr.svcSelectionOrModalityChanged	
	, cr.numOfClaimsChanged
	, cr.replacementSvcRecID
from dbo.CIF_REQUESTS        as cr
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.cifRequestID = cr.id
join dbo.CLAIM_Claim         as clm on clm.CLAIM_ID     = crc.claimID

where (
      (clm.HAS_PROXY = 0) /* Limits to stand alone */
  and (clm.IS_PROXY  = 0) /* Limits to stand alone */
  and (cr.resolved   = 0) /* Unresolved only */
)

/*###################################################################################################*/
/*#                                       Get Claim Data                                            #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Determine Updates - Get Claim Data'

-- ########## Claims ##########

insert into @standAloneClaimData (
      cifRequestID
	, claimID
	, lx
    , dos
	, numUnits
	, claimStatus
)
select distinct
    cifRequestID    = scif.cifRequestID
  , crc.claimID
  , lx              = clm.LINE_NUMBER
  , dos             = clm.SERVICE_DATE
  , numUnits        = clm.SERVICE_UNITS
  , claimStatus     = convert(int,clm.STATUS)
from @standAloneCifRequests  as scif
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.cifRequestID = scif.cifRequestID
join dbo.CLAIM_Claim         as clm on clm.CLAIM_ID     = crc.claimID

-- ########## Adjudication data for claims - Pass 1 ##########

update scd
set 
    scd.numAdjudicationRecs = cca2.numAdjRecs
  , scd.netAmountPaid       = cca2.netAmtPaid
from @standAloneClaimData as scd
cross apply (
    select 
	    numAdjRecs = count(cca1.ADJUDICATION_ID)
	  , netAmtPaid = sum(cca1.AMOUNT_PAID) 
    
	from dbo.CLAIM_Claim_Adjudication as cca1
    where 
      (cca1.CLAIM_ID = scd.claimID)
    group by 
      cca1.CLAIM_ID
) as cca2

-- ########## Adjudication data for claims - Pass 2 ##########

update scd
set 
    scd.ccn = cca2.CCN
from @standAloneClaimData as scd
cross apply (
    /* Get first adjudication record that payment was received for */
    select top 1 
	  cca1.CCN 
	from dbo.CLAIM_Claim_Adjudication as cca1
	where 
	      (cca1.CLAIM_ID = scd.claimID)
	  and (cca1.AMOUNT_PAID > 0)
	order by 
	  cca1.DATE_ADJUDICATED asc
) as cca2

-- ########## Create stats starting with number of claims ##########

insert into @standAloneCifRequestsStats (
    cifRequestID
  , numClaims  
)
select 
    scif.cifRequestID
  , numClaims = count(scd.claimID)
from @standAloneCifRequests as scif
join @standAloneClaimData   as scd on scd.cifRequestID = scif.cifRequestID
group by 
  scif.cifRequestID

-- ########## Determine claim negated status - Pass 1 ##########

update sacrs
  set sacrs.claimsNegated = 1
from @standAloneCifRequestsStats as sacrs
join @standAloneCifRequests      as sacr on sacr.cifRequestID = sacrs.cifRequestID
where 
  (sacr.saveTypeID = dbo.CONST_SAVE_TYPE_DELETE())

-- ########## Determine claim negated status - Pass 2 ##########

update sacrs
  set sacrs.claimsNegated = 1
from @standAloneCifRequestsStats as sacrs
join @standAloneCifRequests      as sacr on sacr.cifRequestID = sacrs.cifRequestID
where ( 
  (sacr.saveTypeID = dbo.CONST_SAVE_TYPE_EDIT())
and ( 
     (sacr.dosOrAttendanceChanged        = 1)
  or (sacr.svcSelectionOrModalityChanged = 1)    
  )
)

-- ########## Determine claim count changed status  ##########

update sacrs
  set sacrs.claimCountChanged = 1
from @standAloneCifRequestsStats as sacrs
join @standAloneCifRequests      as sacr on sacr.cifRequestID = sacrs.cifRequestID
where ( 
  (sacr.saveTypeID = dbo.CONST_SAVE_TYPE_EDIT())
and ( 
     (sacr.numOfClaimsChanged = 1)
  )
)

/*###################################################################################################*/
/*#                        Resolve CIF Requests - No Action Required Cases                          #*/
/*###################################################################################################*/
  
exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Determine Updates - Find Cases Where No Action Required'

-- ########## Service record edited or deleted and claim already in cif void submissions table ##########

exec dbo.PRINT_STATUS_MESSAGE 'Claim Already in Void CIF List and Void Transmission Submitted'

update scd
 set 
    scd.resolved            = 1
  , scd.noActionNeeded      = 1
  , scd.cifAlreadySubmitted = 1
  , scd.resolution          = 'claim already in void cif submissions table and void cif 837 was submitted'
from @standAloneCifRequests                   as scif
join @standAloneClaimData                     as scd   on scd.cifRequestID = scif.cifRequestID
join dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as crcvs on crcvs.claimID    = scd.claimID
where (
      (scd.resolved = 0)
  and (crcvs.submitted = 1)     
)

exec dbo.PRINT_STATUS_MESSAGE 'Unsubmitted held claim already deactivated'

update scd
 set 
    scd.resolved           = 1
  , scd.noActionNeeded     = 1
  , scd.resolution         = 'unsubmitted proxy claim already deactivated'
from @standAloneCifRequests as scif
join @standAloneClaimData   as scd on scd.cifRequestID = scif.cifRequestID
where (
      (scd.resolved      = 0)
  and (scd.claimStatus   = 5)
)

-- ########## Service record edit or deleted and claims denied ##########

exec dbo.PRINT_STATUS_MESSAGE 'Service Changed or Deleted and Claim Denied'

update scd
 set 
    scd.resolved           = 1
  , scd.noActionNeeded     = 1
  , scd.resolution         = 'claim was denied & net amount pay 0'
from @standAloneCifRequests as scif
join @standAloneClaimData   as scd on scd.cifRequestID = scif.cifRequestID
where (
      (scd.resolved      = 0)
  and (scd.claimStatus   = dbo.CONST_CLAIM_STATUS_SUB_REJECT())
  and (scd.netAmountPaid = 0)
)

-- ########## Service record edited or deleted and 0 Unit claims ##########

exec dbo.PRINT_STATUS_MESSAGE 'Service Changed or Deleted and 0 Unit Claim'

update scd
 set 
    scd.resolved           = 1
  , scd.noActionNeeded     = 1
  , scd.resolution         = 'claim has 0 units'
from @standAloneCifRequests as scif
join @standAloneClaimData   as scd on scd.cifRequestID = scif.cifRequestID
where (
      (scd.resolved = 0)
  and (scd.numUnits = 0)
)

-- ########## Service record edited or deleted and net amount paid <=0 ##########

exec dbo.PRINT_STATUS_MESSAGE 'Service Changed or Deleted and Net Amount Paid <= 0'

update scd
 set 
    scd.resolved           = 1
  , scd.noActionNeeded     = 1
  , scd.resolution         = 'claim paid but net amount paid was less than or equal to 0'
from @standAloneCifRequests as scif
join @standAloneClaimData   as scd on scd.cifRequestID = scif.cifRequestID
where (
      (scd.resolved            = 0)
  and (scd.numAdjudicationRecs > 0)
  and (scd.netAmountPaid       <= 0)
)

/*###################################################################################################*/
/*#                          Resolve CIF Requests - Action Required Cases                           #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Determine Updates - Find Cases Where Action Required'

exec dbo.PRINT_STATUS_MESSAGE 'Service claims negated and claims paid'

update sacd
set 
    sacd.resolved             = 1 
  , sacd.shouldSubmitVoidCIF  = 1
  , sacd.resolution           = 'service claims were negated and the claims were paid'
from @standAloneCifRequests      as sacr
join @standAloneCifRequestsStats as sacrs on sacrs.cifRequestID = sacr.cifRequestID
join @standAloneClaimData        as sacd  on sacd.cifRequestID  = sacr.cifRequestID
where (
      (sacd.resolved       = 0)
  and (sacrs.claimsNegated = 1) 
  and (sacd.claimStatus    = dbo.CONST_CLAIM_STATUS_SUB_PAID()) 
)

exec dbo.PRINT_STATUS_MESSAGE 'Service claim count changed and claims paid'

update sacd
set 
    sacd.resolved               = 1 
  , sacd.shouldSubmitChangeCIF  = 1
  , sacd.resolution             = 'service claim count changed and the previous claims were paid'
from @standAloneCifRequests      as sacr
join @standAloneCifRequestsStats as sacrs on sacrs.cifRequestID = sacr.cifRequestID
join @standAloneClaimData        as sacd  on sacd.cifRequestID  = sacr.cifRequestID

where (
      (sacd.resolved           = 0)
  and (sacrs.claimCountChanged = 1) 
  and (sacd.claimStatus        = dbo.CONST_CLAIM_STATUS_SUB_PAID()) 
)

exec dbo.PRINT_STATUS_MESSAGE 'Claim held and never submitted'

update sacd
set 
    sacd.resolved               = 1 
  , sacd.deactivateClaims       = 1
  , sacd.resolution             = 'claim in submitted state but held and never submitted'
from @standAloneCifRequests      as sacr
join @standAloneCifRequestsStats as sacrs on sacrs.cifRequestID = sacr.cifRequestID
join @standAloneClaimData        as sacd  on sacd.cifRequestID  = sacr.cifRequestID

where (
      (sacd.resolved           = 0)
  and (sacd.claimStatus        = dbo.CONST_CLAIM_STATUS_NOT_SUB()) 
)

-- ########## What Is Left ##########

exec dbo.PRINT_STATUS_MESSAGE 'What cannot be resolved yet'

update scd
set 
  scd.resolution  = ''
from  @standAloneClaimData as scd   
 
where (
      (scd.resolved = 0)
)

update scd
set 

  scd.resolution  = 'waiting for claim adjudication'
from  @standAloneClaimData as scd   
 
where (
      (scd.resolved       = 0)
  and (scd.claimStatus    = dbo.CONST_CLAIM_STATUS_SUB_PENDING())
)

/*###################################################################################################*/
/*#                            Resolve CIF Requests - Update Stats                                  #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Determine Updates - Update Counts and Other Stats'

-- ########## Count number of claims resolved ##########

exec dbo.PRINT_STATUS_MESSAGE 'Count number of claims resolved'

update scifs
set numClaimsThatHaveBeenResolved = scd2.numOf
from @standAloneCifRequestsStats as scifs
cross apply (
  select 
    numOf = count(scd1.claimID) 
  from @standAloneClaimData as scd1
  where (
        (scd1.cifRequestID = scifs.cifRequestID)
    and (scd1.resolved = 1)
  )
) as scd2

-- ########## Complete resolution text ##########

update @standAloneClaimData set resolution = 'no action needed '          + resolution where ((resolved = 1) and (noActionNeeded = 1))
update @standAloneClaimData set resolution = 'CIF submission required '   + resolution where ((resolved = 1) and (shouldSubmitVoidCIF = 1))
update @standAloneClaimData set resolution = 'CIF submission required '   + resolution where ((resolved = 1) and (shouldSubmitChangeCIF = 1))
update @standAloneClaimData set resolution = 'deactivate claims '         + resolution where ((resolved = 1) and (deactivateClaims = 1))
update @standAloneClaimData set resolution = 'not resolved yet '          + resolution where (resolved = 0)

-- ########## Combine resolution text ##########

exec dbo.PRINT_STATUS_MESSAGE 'Combine resolution text'

update scifs
set 
  scifs.resolution = '- ' + convert(varchar(10),scifs.numClaims) + ' Claims ' + scd2.resolutions
from @standAloneCifRequestsStats as scifs
cross apply (
  select 
    resolutions = STRING_AGG('- Claim ' + convert(varchar(10),scd1.lx) + ' ' + scd1.resolution, ' ')
  from @standAloneClaimData as scd1
  where (
        (scd1.cifRequestID = scifs.cifRequestID)
  )
) as scd2

-- ########## Determine cif requests that are not fully resolved ##########

exec dbo.PRINT_STATUS_MESSAGE 'Determine if cif request is not fully resolved'

update scifs
set 
    scifs.resolved = 0
from @standAloneCifRequestsStats as scifs
where 
  (scifs.numClaims != scifs.numClaimsThatHaveBeenResolved) /* Not fully resolved */

-- ########## Determine cif requests that are fully resolved ##########

exec dbo.PRINT_STATUS_MESSAGE 'Determine if cif request is fully resolved'

update scifs
set 
    scifs.resolved = 1
from @standAloneCifRequestsStats as scifs
where 
  (scifs.numClaims = scifs.numClaimsThatHaveBeenResolved) /* Fully resolved */

-- ########## Determine what value to set cifSubmissionRequired flag ##########

exec dbo.PRINT_STATUS_MESSAGE 'Determine what value to set cif submission required flag'

update sacrs
  set sacrs.cifSubmissionRequired = 1
from @standAloneCifRequestsStats as sacrs
join @standAloneClaimData        as sacd on sacd.cifRequestID = sacrs.cifRequestID
where ( 
     (sacd.cifAlreadySubmitted   = 1)
  or (sacd.shouldSubmitVoidCIF   = 1)
  or (sacd.shouldSubmitChangeCIF = 1)
)


/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*#                                 UPDATE CIF REQUEST DATA                                         #*/
/*#                                                                                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/
 
exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Update CIF Request Data'

begin transaction
set @tranCount = 1

-- ########## Update CIF Request Data With Latest ##########

exec dbo.PRINT_STATUS_MESSAGE 'Update CIF requests with latest data'

update cr
set       
      cr.lastModifiedOn        = @today
	, cr.lastModifiedBy        = @userID
	, cr.resolved              = sacrs.resolved
	, cr.resolvedOn            = @today
	, cr.resolvedUsing         = 100 /* 100 = Stand alone claim resolver, 200 = Proxy claim resolved */
	, cr.cifSubmissionRequired = sacrs.cifSubmissionRequired
	, cr.resolution            = sacrs.resolution
from @standAloneCifRequestsStats as sacrs
join dbo.CIF_REQUESTS            as cr on cr.id = sacrs.cifRequestID

-- ########## Deactivate claims ##########

exec dbo.PRINT_STATUS_MESSAGE 'Deactivate applicable claims'

update clm
set 
   clm.STATUS       = '5'
  ,clm.LAST_UPDATED = @today
from @standAloneCifRequestsStats as sacrs
join @standAloneClaimData        as sacd on sacd.cifRequestID = sacrs.cifRequestID
join dbo.CLAIM_Claim             as clm  on clm.CLAIM_ID      = sacd.claimID
where (
      
      (sacrs.resolved        = 1)
  and (sacd.deactivateClaims = 1)
  and (clm.IS_PROXY  = 0)
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
    clientId = clm.CLIENT_ID
  , sacd.claimID
  , dos = clm.SERVICE_DATE
  , sacd.ccn
  , amountToPayBack = sacd.netAmountPaid 
  , proxyClaim = 0
  , childClaimsSvc = ''
  , submitted = 0
from @standAloneCifRequestsStats as sacrs
join @standAloneClaimData        as sacd on sacd.cifRequestID = sacrs.cifRequestID
join dbo.CLAIM_Claim             as clm  on clm.CLAIM_ID      = sacd.claimID
where (
      (sacrs.resolved = 1)
  and (sacrs.cifSubmissionRequired = 1) /* Stand alone claims that have cifChange are submited as cifVoid */
  and (sacd.netAmountPaid > 0)
  and (sacd.ccn is not null)
  and (sacd.claimID not in (
      select top 1 
	    sac1.claimID 
	  from dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as sac1 
	  where (	  
	    (sac1.claimID  = sacd.claimID)
	  )
  )) 
)

commit transaction
set @tranCount = 0

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Stand Alone Claims - Done'

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
 
GRANT EXECUTE ON  [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_STAND_ALONE_CLAIMS] TO [webuser]
GO
