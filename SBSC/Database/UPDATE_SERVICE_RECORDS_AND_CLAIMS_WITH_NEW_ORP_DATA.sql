USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_SERVICE_RECORDS_AND_CLAIMS_WITH_NEW_ORP_DATA') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_SERVICE_RECORDS_AND_CLAIMS_WITH_NEW_ORP_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[UPDATE_SERVICE_RECORDS_AND_CLAIMS_WITH_NEW_ORP_DATA]  
AS    

BEGIN     
    
/***************************************************************************    
 * UPDATE_SERVICE_RECORDS_AND_CLAIMS_WITH_NEW_ORP_DATA */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

declare @tranCount          as int
declare @userID             as bigint
declare @today              as datetime
declare @numSvcRecs         as bigint
declare @numClmRecs         as bigint
declare @numSvcRecsToUpdate as bigint
declare @numClmRecsToUpdate as bigint
declare @numSvcRecsUpdated  as bigint
declare @numClmRecsUpdated  as bigint
declare @msg                as varchar(255)
declare @oldestDOS          as datetime
declare @numRematches       as bigint

declare @nonHealthSvcRecsToRematch as table (
    id          bigint
  , orpDocID    bigint
  , orpPracID   bigint
  , hasOrpDocID bit
)

declare @svcRecData as table (
    id                 bigint
  , hasOrpDocID        bit
  , curOrpRequired     bit
  , curOrpDocID        bigint
  , curOrpPracID       bigint
  , curOrpPracNPI      varchar(50)
  , curOrpValidMcalOrp bit        
  , curCheckSum        int
  , newOrpRequired     bit
  , newOrpDocID        bigint
  , newOrpPracID       bigint
  , newOrpPracNPI      varchar(50)
  , newOrpValidMcalOrp bit
  , newCheckSum        int
)

declare @claimData as table (
    svcRecID                bigint
  , CLAIM_ID                bigint
  , CUR_ORP_PRACTITIONER_ID bigint
  , NEW_ORP_PRACTITIONER_ID bigint
)

declare @svcRecUpdates   as table (
    id                 bigint
  , newOrpRequired     bit
  , newOrpDocID        bigint
  , newOrpPracID       bigint
  , newOrpPracNPI      varchar(50)
  , newOrpValidMcalOrp bit  
)

declare @claimRecUpdates as table (
    CLAIM_ID                bigint
  , NEW_ORP_PRACTITIONER_ID bigint
)

set @tranCount          = 0
set @userID             = 0
set @today              = GETDATE()

BEGIN TRY
begin transaction

set @numSvcRecs         = 0
set @numClmRecs         = 0
set @numSvcRecsToUpdate = 0
set @numClmRecsToUpdate = 0
set @numSvcRecsUpdated  = 0
set @numClmRecsUpdated  = 0
set @numRematches       = 0

set @tranCount = 1

set @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,@today))

/*============================================================
 * Get non health service records that need orp document 
 * rematch
 *============================================================*/  

RAISERROR ('Searching for non health service records that require ORP document rematch', 0, 1) WITH NOWAIT

/* Uses index [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS] */

insert into @nonHealthSvcRecsToRematch
select distinct
      sr.id
	, sr.orpDocID
	, sr.orpPracID
	, sr.hasOrpDocID
from dbo.CLIENTS_Client   as clc
join dbo.SERVICE_RECORDS  as sr  on  (
                                     (sr.clientID   = clc.CLIENT_ID)
                                 and (sr.patID is not null)        /**/
								 and (sr.pracGrpSvcClsNameID != 3) /* Not health services */		
								 and (sr.svcType    =  dbo.CONST_SERVICES_TREATMENT())						
								 and (sr.dos >= @oldestDOS)
								 and  (sr.svcType    =  dbo.CONST_SERVICES_TREATMENT())
                                 and  (sr.state not in (  dbo.CONST_SVC_REC_STATE_SUB()
                                                       , dbo.CONST_SVC_REC_STATE_DEL()
                                                       , dbo.CONST_SVC_REC_STATE_CIF()))

								 and (sr.orpRequired = 1)      /* Required */							
								 and (sr.orpDocID is not null) /* Orp document id associated */
								 )

/* Does the document have approval for the dos */

outer apply (
  select top 1
    odc1.ID
  from dbo.ORP_DOCUMENTS_DATA_CORE (null,null,null,null,null,sr.orpDocID,null) as odc1
  where (
        (odc1.hasLastApproval = 1)
	and (sr.dos between odc1.lastApprovalEffectiveDate and odc1.lastApprovalExpirationDate)
  )
) as odc2

where (
       (clc.CLIENT_ID != 112)
  and  (clc.LEA = 1)
  and  (odc2.ID is null) /* Doc associated has no approval data or approval data is for diff date than dos */
)

select @numSvcRecs  = count(*) from @nonHealthSvcRecsToRematch
set @msg = 'Number of non health service records to rematch : ' + convert(varchar,@numSvcRecs)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * Update non health service records that need to be 
 * reasociated 
 *============================================================*/  

RAISERROR ('Updating non health service records that require ORP document rematch', 0, 1) WITH NOWAIT

update 
  sr
set
    sr.orpRequired     = 1
  , sr.hasOrpDocID     = 0
  , sr.orpDocID        = null
  , sr.orpPracID       = null
  , sr.orpPracNPI      = null
  , sr.orpValidMcalOrp = null
  , sr.lastmodified    = @today
  , sr.state           = dbo.CONST_SVC_REC_STATE_MOD()
from @nonHealthSvcRecsToRematch     as sru 
join dbo.SERVICE_RECORDS            as sr on sr.id = sru.id
where 
  (1=1)

set @numSvcRecsUpdated  = @@ROWCOUNT
set @msg = 'Number of non health service records updated : ' + convert(varchar,@numSvcRecsUpdated)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * Update claim records that are related
 * to non health service records that need to be reassociated 
 *============================================================*/  

RAISERROR ('Updating related claims for non health service records that require ORP document rematch', 0, 1) WITH NOWAIT

update
  clm
set
    clm.ORP_PRACTITIONER_ID = null
  , clm.LAST_UPDATED        = @today  
from @nonHealthSvcRecsToRematch     as sru
join dbo.SERVICE_RECORD_CLAIMS      as src on src.svcRecID = sru.id
join dbo.CLAIM_Claim                as clm on clm.CLAIM_ID = src.claimID
where 
  (1=1)

set @numClmRecsUpdated  = @@ROWCOUNT
set @msg = 'Number of related non health service claim records updated : ' + convert(varchar,@numClmRecsUpdated)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * Add audit records
 *============================================================*/  

insert into dbo.SERVICE_RECORDS_AUDIT_LOG 
select 
   sru.id                             as svcRecID
 , @today                             as loggedOn
 , @userID                            as userID
 , dbo.CONST_SAVE_TYPE_EDIT()         as saveType
 , dbo.CONST_SVC_REC_STATE_MOD()      as [state]
 , [reason] = 'Clear previous ORP data for rematch attempt' 
             + ' orpDocID : '  + convert(varchar,(isnull(sru.orpDocID,-1)))
			 + ' orpPracID : ' + convert(varchar,(isnull(sru.orpPracID,-1))) 
			 + ' hasOrpDocID'  + convert(varchar,(isnull(sru.hasOrpDocID,0)))

from @nonHealthSvcRecsToRematch as sru


/*============================================================
 * Attempt automatch
 *============================================================*/  

set @numSvcRecs         = 0
set @numClmRecs         = 0
set @numSvcRecsToUpdate = 0
set @numClmRecsToUpdate = 0
set @numSvcRecsUpdated  = 0
set @numClmRecsUpdated  = 0
set @numRematches       = 0

/*============================================================
 * Get service records that may need to be modified
 *============================================================*/  

RAISERROR ('Searching for service records that require ORP data', 0, 1) WITH NOWAIT

/* Uses index [CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS] */

insert into @svcRecData
select  
     sr.id                            as id
   , sr.hasOrpDocID                   as hasOrpDocID
   , sr.orpRequired                   as curOrpRequired
   , sr.orpDocID                      as curOrpDocID
   , sr.orpPracID                     as curOrpPracID
   , sr.orpPracNPI                    as curOrpPracNPI
   , sr.orpValidMcalOrp               as curOrpValidMcalOrp   
   
   , CHECKSUM (  sr.id
               , sr.orpRequired
               , sr.orpDocID
               , sr.orpPracID
               , sr.orpPracNPI
               , sr.orpValidMcalOrp)  as curCheckSum
   
   , orpd.OrpRequired                 as newOrpRequired
   , orpd.OrpDocumentID               as newOrpDocID
   , orpd.PracID                      as newOrpPracID
   , orpd.NpiNumber                   as newOrpPracNPI
   , orpd.IsValidMcalOrp              as newOrpValidMcalOrp
   
   , CHECKSUM (  sr.id
               , orpd.OrpRequired
               , orpd.OrpDocumentID
               , orpd.PracID
               , orpd.NpiNumber
               , orpd.IsValidMcalOrp) as newCheckSum
                                          
from dbo.CLIENTS_Client   as clc
join dbo.SERVICE_RECORDS  as sr  on  (
                                      (sr.clientID = clc.CLIENT_ID)
                                 and  (sr.pracID is not null)
                                 and  (sr.patID  is not null)
								 and  (sr.dos >= @oldestDOS)
								 and  (sr.svcType    =  dbo.CONST_SERVICES_TREATMENT())
                                 and  (sr.state not in (  dbo.CONST_SVC_REC_STATE_SUB()
                                                       , dbo.CONST_SVC_REC_STATE_DEL()
                                                       , dbo.CONST_SVC_REC_STATE_CIF()))

								 )
cross apply (
  select top 1
    gorp.* 
  from dbo.GET_ORP_PRAC_NPI_DATA (0,sr.svcType,sr.dos,sr.clientID,sr.groupID,sr.orpDocID,sr.patID, 1/*@procedureBillingProgramID*/) as gorp
) as orpd

where (
       (clc.CLIENT_ID != 112)
  and  (clc.LEA = 1)
)

/*============================================================
 * Get claim records that may need to be modified
 *============================================================*/  

RAISERROR ('Searching for related claim records that require ORP data', 0, 1) WITH NOWAIT

insert into @claimData
select 

   src.svcRecID           as svcRecID
 , cc.CLAIM_ID            as CLAIM_ID
 , cc.ORP_PRACTITIONER_ID as CUR_ORP_PRACTITIONER_ID
 , sr.newOrpPracID        as NEW_ORP_PRACTITIONER_ID
 
from @svcRecData               as sr
join dbo.SERVICE_RECORD_CLAIMS as src on src.svcRecID = sr.id
join dbo.CLAIM_Claim           as cc  on cc.CLAIM_ID  = src.claimID

select @numSvcRecs  = count(*) from @svcRecData
select @numClmRecs  = count(*) from @claimData

set @msg = 'Number of possible service records : ' + convert(varchar,@numSvcRecs)
RAISERROR (@msg, 0, 1) WITH NOWAIT

set @msg = 'Number of possible claim records : ' + convert(varchar,@numClmRecs)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * Determine what service records should be updated
 *============================================================*/  

RAISERROR ('Determine what service records can be updated with ORP data', 0, 1) WITH NOWAIT

insert into @svcRecUpdates
select 
    id
  , newOrpRequired
  , newOrpDocID
  , newOrpPracID
  , newOrpPracNPI
  , newOrpValidMcalOrp
from @svcRecData
where (curCheckSum != newCheckSum)

/*============================================================
 * Determine what claims should be updated
 *============================================================*/  

RAISERROR ('Determine what related claim records can be updated with ORP data', 0, 1) WITH NOWAIT

insert into @claimRecUpdates
select 
    cc.CLAIM_ID
  , cc.NEW_ORP_PRACTITIONER_ID
from @svcRecUpdates as sr
join @claimData     as cc on cc.svcRecID = sr.id

select @numSvcRecsToUpdate = count(*) from @svcRecUpdates
select @numClmRecsToUpdate = count(*) from @claimRecUpdates

set @msg = 'Number of service records to update : ' + convert(varchar,@numSvcRecsToUpdate)
RAISERROR (@msg, 0, 1) WITH NOWAIT

set @msg = 'Number of claim records to update : ' + convert(varchar,@numClmRecsToUpdate)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * Update service records 
 *============================================================*/  

update 
  sr
set
    sr.orpRequired     = sru.newOrpRequired
  , sr.orpDocID        = sru.newOrpDocID
  , sr.orpPracID       = sru.newOrpPracID
  , sr.orpPracNPI      = sru.newOrpPracNpi
  , sr.orpValidMcalOrp = sru.newOrpValidMcalOrp  
  , sr.lastmodified    = @today
  , sr.state           = dbo.CONST_SVC_REC_STATE_MOD()
from dbo.SERVICE_RECORDS as sr 
join @svcRecUpdates      as sru on sru.id = sr.id
where (1=1)

set @numSvcRecsUpdated  = @@ROWCOUNT
set @msg = 'Number of service records updated : ' + convert(varchar,@numSvcRecsUpdated)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * Add audit records
 *============================================================*/  

insert into dbo.SERVICE_RECORDS_AUDIT_LOG 
select 
   sru.id                         as svcRecID
 , @today                         as loggedOn
 , @userID                        as userID
 , dbo.CONST_SAVE_TYPE_EDIT()     as saveType
 , dbo.CONST_SVC_REC_STATE_MOD()  as [state]
 , 'Automatic update of ORP data' as reason
from @svcRecUpdates as sru

/*============================================================
 * Update claim records
 *============================================================*/  

update
  cc
set
    cc.ORP_PRACTITIONER_ID = cru.NEW_ORP_PRACTITIONER_ID
  , cc.LAST_UPDATED        = @today  
from dbo.CLAIM_Claim  as cc
join @claimRecUpdates as cru on cru.CLAIM_ID = cc.CLAIM_ID
where (1=1)

set @numClmRecsUpdated  = @@ROWCOUNT
set @msg = 'Number of claim records updated : ' + convert(varchar,@numClmRecsUpdated)
RAISERROR (@msg, 0, 1) WITH NOWAIT

select 
  @numRematches = count(t1.id) 
from @svcRecUpdates             as t1
join @nonHealthSvcRecsToRematch as t2 on t2.id = t1.id
where
  (t1.newOrpDocID != t2.orpDocID)

set @msg = 'Number of non health services rematched with new ORP doc : ' + convert(varchar,@numRematches)
RAISERROR (@msg, 0, 1) WITH NOWAIT

/*============================================================
 * If we reach this point, no issues, commit transaction
 *============================================================*/  

if (@tranCount = 1) commit transaction

set @tranCount = 0

/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT

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
 
GRANT EXECUTE ON  [dbo].[UPDATE_SERVICE_RECORDS_AND_CLAIMS_WITH_NEW_ORP_DATA] TO [webuser]
GO
