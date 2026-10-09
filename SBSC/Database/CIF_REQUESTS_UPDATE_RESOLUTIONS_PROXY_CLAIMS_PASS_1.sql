USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1]  
AS    

BEGIN     
    
/***************************************************************************    
 * CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1 */    
/**    
 * Generates any missing CIF request records so every proxy claim has a 
 * related CIF request record
 ***************************************************************************/         

SET NOCOUNT ON        

BEGIN TRY

declare @proxyCifRequests as table (
    cifRequestID                  bigint
  , svcRecID                      bigint
unique clustered (cifRequestID)
)

declare @parentClaimData as table (
    parentClaimID              bigint  
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

declare @serviceRecordsThatNeedACifRequestRecord as table (
      idx      int identity(1,1)
    , svcRecID bigint  
  unique clustered (idx)
)

declare @tranCount       as int = 0
declare @today           as datetime = getdate()
declare @svcRecID        as bigint = null
declare @newSvcRecID     as bigint = null
declare @spDetails       as VARCHAR(8000) = ''
declare @srJsonData      as varchar(max)  = ''
declare @newSrJsonData   as varchar(max)  = ''
declare @cifRequestID    as bigint        = null
declare @cifRecID        as bigint        = 0
declare @srClientID      as bigint        = null
declare @srUserID        as bigint        = null
declare @srUserGroup     as int           = null
declare @srUserRank      as int           = null
declare @maxIdx          as int           = 0
declare @curIdx          as int           = 0

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Starting'

set @tranCount = 0
set @today     = GETDATE()

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                            Get Unresolved Proxy CIF Requests                                    #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Get Unresolved CIF Requests'

insert into @proxyCifRequests (
    cifRequestID
  , svcRecID
)
select distinct
      cifRequestID = cr.id
    , cr.svcRecID
from dbo.CIF_REQUESTS        as cr
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.cifRequestID = cr.id
join dbo.CLAIM_Claim         as clm on clm.CLAIM_ID     = crc.claimID
where ( 
      (cr.resolved   = 0)
  and (clm.HAS_PROXY = 1)
  and (clm.IS_PROXY  = 0)
)

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                            Get All Parent and Child Claims                                      #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Get All Parent and Child Claims'

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

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                  Determine What Service Records Require a CIF Request Record                    #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Determine what service records require a cif request record'

-- ########## If a child claim has a related CIF request claim then it does not need a cif request record ##########

update ccd
set 
    ccd.cifRequestID          = crc.cifRequestID
  , ccd.svcRecID              = crc.svcRecID
  , ccd.needsCifRequestRecord = 0
from @childClaimData         as ccd
join dbo.CIF_REQUESTS_CLAIMS as crc on crc.claimID = ccd.childClaimID

-- ########## Get missing service record ids from service record claims ##########

update ccd
  set ccd.svcRecID = src.svcRecID
from @childClaimData as ccd
join dbo.SERVICE_RECORD_CLAIMS as src on src.claimID = ccd.childClaimID
where 
  (ccd.needsCifRequestRecord = 1)

-- ########## Compile list of service records that need a CIF request record ##########

insert into @serviceRecordsThatNeedACifRequestRecord (
  svcRecID
)
select distinct 
  ccd.svcRecID 
from @childClaimData as ccd
where 
  (ccd.needsCifRequestRecord = 1)

/*###################################################################################################*/
/*#                                                                                                 #*/
/*#                        Create CIF Request Records If Neccessary                                 #*/
/*#                                                                                                 #*/
/*###################################################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Create CIF Request Records If Neccessary'

select 
  @curIdx = min(t1.idx)
, @maxIdx = max(t1.idx) 
from @serviceRecordsThatNeedACifRequestRecord as t1

while (@curIdx <= @maxIdx)
begin
  
  
  begin try
  
  select 
    @svcRecID = t1.svcRecID 
  from @serviceRecordsThatNeedACifRequestRecord as t1 where (t1.idx = @curIdx)
  
  set @spDetails     = ''
  set @newSvcRecID   = 0
  set @srJsonData    = ''
  set @newSrJsonData = ''
  set @srClientID     = null
  set @srUserID       = null
  set @srUserGroup    = null
  set @srUserRank     = null
  set @cifRequestID   = null

  begin transaction
  set @tranCount = 1

    /*============================================================
     * Clone service record
     *============================================================*/ 
	
	exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Create CIF Request Record - Clone Service Record'

    exec dbo.SERVICE_RECORD_Clone_Core 
      @svcRecID
    , 0
    , 'Duplicate service record'
    , 'Invalid combo'
    , 'No record found'
    , 'Edit not allowed'
    , 'Data error'
    , 'Minutes required'
    , 'Min def'
    , 'Mile req'
    , 'Pat elig'
    , 'Dob gt dos'
    , 'Not active'
    , 'Pat absent'
    , 'Future dos'
    , @spDetails        output
    , @srUserID         output
    , @srUserGroup      output
    , @srUserRank       output
    , @srClientID       output
	, @newSvcRecID      output    

    /*============================================================
     * CIF 
     *============================================================*/ 
   
    exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Create CIF Request Record - Create CIF Request'

	 /* Get original and new service record data for archive purposes */

    set @srJsonData = convert (  varchar(max)
                             ,(select sr.* from dbo.SERVICE_RECORDS as sr 
		  				       where sr.id = @svcRecID FOR JSON AUTO, INCLUDE_NULL_VALUES)
						    )  
  
    set @newSrJsonData = convert (  varchar(max)
                             ,(select sr.* from dbo.SERVICE_RECORDS as sr 
			  			       where sr.id = @newSvcRecID FOR JSON AUTO, INCLUDE_NULL_VALUES)
						    )

    /* Call existing CIF initiate logic */

    exec dbo.SERVICE_RECORD_INITIATE_CIF_Core @srUserID, @srUserGroup, @srUserRank, 'A sibling service was changed or deleted',0 ,@srClientID , @svcRecID, @today, @spDetails output, @cifRecID output
  
   /* The table CLAIMS_LIST_DO_NOT_RESUBMIT is updated with new claims */
  
   insert into dbo.CIF_REQUESTS (
      clientID
	, svcRecID
	, saveTypeID
	, reason	
	, svcRecData
	, svcRecDataReplacement
	, replacementSvcRecID
	, createdOn
	, createdBy
	, dosOrAttendanceChanged  
	, svcSelectionOrModalityChanged
	, numOfClaimsChanged
	, numOfUnitsChanged
    , siblingServiceWasChangedOrDeleted
   )
   values ( 
       @srClientID
     , @svcRecID
     , dbo.CONST_SAVE_TYPE_EDIT()
	 , 'A sibling service was changed or deleted'
     , @srJsonData
	 , @newSrJsonData
     , @newSvcRecID
	 , @today
     , @srUserID
	 , 0
     , 0
     , 0
     , 0
	 , 1 
	) 

   set @cifRequestID = SCOPE_IDENTITY()
   
   insert into dbo.CIF_REQUESTS_CLAIMS (     
        cifRequestID
	  , svcRecID
	  , claimID )
   select  
        cifRequestID = @cifRequestID
	  , src.svcRecID
	  , src.claimID
   from dbo.SERVICE_RECORD_CLAIMS as src
   where (src.svcRecID = @svcRecID)
   
  end try
  begin catch
    print ERROR_MESSAGE()
    if (@tranCount = 1) 
	begin
	  rollback transaction
      set @tranCount = 0
	end
  end catch
  
  if (@tranCount = 1) 
  begin
    commit transaction
    set @tranCount = 0
  end
  
  set @curIdx = @curIdx + 1

end


exec dbo.PRINT_STATUS_MESSAGE 'CIF Requests - Update Resolutions - Proxy Claims Pass 1 - Done'

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
 
GRANT EXECUTE ON  [dbo].[CIF_REQUESTS_UPDATE_RESOLUTIONS_PROXY_CLAIMS_PASS_1] TO [webuser]
GO
