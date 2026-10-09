USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_CLAIM_PAYER_STATUS_STATISTICS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_CLAIM_PAYER_STATUS_STATISTICS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_CLAIM_PAYER_STATUS_STATISTICS] ( @patID BIGINT )
RETURNS 
@recs 
TABLE (
        BIC                                       nvarchar(14)
      , PATIENT_IDS                               varchar(max)
      , PAID_CLAIMS_COUNT                         int
	  , PAID_EARLIEST_SERVICE_DATE                date
	  , PAID_LATEST_SERVICE_DATE                  date
	  , PAID_EARLIEST_PAYER_RECEIVED_CLAIM_DATE   date
	  , PAID_LATEST_PAYER_RECEIVED_CLAIM_DATE     date
	  , PAID_EARLIEST_PAYER_ADJUDICATED_DATE      date
	  , PAID_LATEST_PAYER_ADJUDICATED_DATE        date
	  , DENIED_CLAIMS_COUNT                       int
	  , DENIED_EARLIEST_SERVICE_DATE              date
	  , DENIED_LATEST_SERVICE_DATE                date
	  , DENIED_EARLIEST_PAYER_RECEIVED_CLAIM_DATE date
	  , DENIED_LATEST_PAYER_RECEIVED_CLAIM_DATE   date
	  , DENIED_EARLIEST_PAYER_ADJUDICATED_DATE    date
	  , DENIED_LATEST_PAYER_ADJUDICATED_DATE      date

)
BEGIN

 
 /***************************************************************************    
  * PATIENT_VIEW_CLAIM_PAYER_STATUS_STATISTICS */    
 /**    
  * Returns summary 
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @return               Table 
  ***************************************************************************/                         

declare @pats as table (
  BIC         varchar(255)
 ,PATIENT_IDS varchar(max)
 UNIQUE CLUSTERED (BIC)
)

declare @claims as table (
    ID                             int identity(1,1)
  , BIC                            varchar(255)  
  , CLAIM_ID                       bigint
  , CLAIM_PAYER_SERVICE_DATE       date
  , CLAIM_PAYER_RECEIVED_DATE      date
  , CLAIM_PAYER_ADJUDICATED_DATE   date
  , CLAIM_PAYER_PAID_CLAIM         bit
  , CLAIM_PAYER_DENIED_CLAIM       bit
  UNIQUE NONCLUSTERED (BIC, ID)
)

insert into @pats
select
    pvkb.BIC
  , PATIENT_IDS = STRING_AGG(pvkb.PATIENT_ID,',')
from dbo.PATIENT_VIEW_KNOWN_BICS(@patID) as pvkb
group by 
  pvkb.BIC

insert into @claims
select 
   pats.BIC 
  ,pvc2.*
from @pats as pats
cross apply (
  select 
      pvc.CLAIM_ID
    , pvc.CLAIM_PAYER_SERVICE_DATE
    , pvc.CLAIM_PAYER_RECEIVED_DATE
    , pvc.CLAIM_PAYER_ADJUDICATED_DATE
    , pvc.CLAIM_PAYER_PAID_CLAIM 
    , pvc.CLAIM_PAYER_DENIED_CLAIM
  from dbo.PATIENT_VIEW_CLAIMS_837_835_XREF_CORE(pats.BIC) as pvc
) as pvc2

insert into @recs
select 

    pats.BIC
  , pats.PATIENT_IDS
  , pvc_paid.*
  , pvc_denied.*

from @pats as pats
  
cross apply (
  
    select 
	    PAID_CLAIMS_COUNT = COUNT(pvc.CLAIM_ID) 
	  , PAID_EARLIEST_SERVICE_DATE              = min (pvc.CLAIM_PAYER_SERVICE_DATE)
	  , PAID_LATEST_SERVICE_DATE                = max (pvc.CLAIM_PAYER_SERVICE_DATE)
	  , PAID_EARLIEST_PAYER_RECEIVED_CLAIM_DATE = min (pvc.CLAIM_PAYER_RECEIVED_DATE)
	  , PAID_LATEST_PAYER_RECEIVED_CLAIM_DATE   = max (pvc.CLAIM_PAYER_RECEIVED_DATE)
	  , PAID_EARLIEST_PAYER_ADJUDICATED_DATE    = min (pvc.CLAIM_PAYER_ADJUDICATED_DATE)
	  , PAID_LATEST_PAYER_ADJUDICATED_DATE      = max (pvc.CLAIM_PAYER_ADJUDICATED_DATE)

	from @claims as pvc
	where (pvc.BIC = pats.BIC) and (pvc.CLAIM_PAYER_PAID_CLAIM = 1)
	group by 
	  pvc.BIC
  ) as pvc_paid
  
  cross apply (
    select 
	    DENIED_CLAIMS_COUNT                       = COUNT(pvc.CLAIM_ID) 
	  , DENIED_EARLIEST_SERVICE_DATE              = min (pvc.CLAIM_PAYER_SERVICE_DATE)
	  , DENIED_LATEST_SERVICE_DATE                = max (pvc.CLAIM_PAYER_SERVICE_DATE)
	  , DENIED_EARLIEST_PAYER_RECEIVED_CLAIM_DATE = min (pvc.CLAIM_PAYER_RECEIVED_DATE)
	  , DENIED_LATEST_PAYER_RECEIVED_CLAIM_DATE   = max (pvc.CLAIM_PAYER_RECEIVED_DATE)
      , DENIED_EARLIEST_PAYER_ADJUDICATED_DATE    = min (pvc.CLAIM_PAYER_ADJUDICATED_DATE)
	  , DENIED_LATEST_PAYER_ADJUDICATED_DATE      = max (pvc.CLAIM_PAYER_ADJUDICATED_DATE)
	  	
	from @claims as pvc
	where (pvc.BIC = pats.BIC) and (pvc.CLAIM_PAYER_DENIED_CLAIM = 1)
	group by 
	  pvc.BIC
  ) as pvc_denied
  
  return 

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_CLAIM_PAYER_STATUS_STATISTICS] TO [webuser]
GO   
