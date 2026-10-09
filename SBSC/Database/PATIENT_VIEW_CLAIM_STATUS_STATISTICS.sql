USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_CLAIM_STATUS_STATISTICS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_CLAIM_STATUS_STATISTICS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_CLAIM_STATUS_STATISTICS] ( @patID BIGINT )
RETURNS @recs 
TABLE (
    PATIENT_ID             bigint
  , CLIENT_ID              bigint
  , ACTIVE                 bit
  , USER_ID                bigint
  , LAST_POP               datetime
  , CURRENT_BIC            nvarchar(14)
  
  , NOT_YET_TRANSMITTED_NUM_OF          int
  , NOT_YET_TRANSMITTED_EARLIEST_DOS    date  
  , NOT_YET_TRANSMITTED_LATEST_DOS      date
  , NOT_YET_TRANSMITTED_EARLIEST_UPDATE datetime
  , NOT_YET_TRANSMITTED_LATEST_UPDATE   datetime

  , TRANSMITTED_NOT_YET_ADJUDICATED_NUM_OF          int
  , TRANSMITTED_NOT_YET_ADJUDICATED_EARLIEST_DOS    date  
  , TRANSMITTED_NOT_YET_ADJUDICATED_LATEST_DOS      date
  , TRANSMITTED_NOT_YET_ADJUDICATED_EARLIEST_UPDATE datetime
  , TRANSMITTED_NOT_YET_ADJUDICATED_LATEST_UPDATE   datetime
  
  , ADJUDICATED_AND_PAID_NUM_OF          int
  , ADJUDICATED_AND_PAID_EARLIEST_DOS    date  
  , ADJUDICATED_AND_PAID_LATEST_DOS      date
  , ADJUDICATED_AND_PAID_EARLIEST_UPDATE datetime
  , ADJUDICATED_AND_PAID_LATEST_UPDATE   datetime

  , ADJUDICATED_AND_DENIED_NUM_OF          int
  , ADJUDICATED_AND_DENIED_EARLIEST_DOS    date  
  , ADJUDICATED_AND_DENIED_LATEST_DOS      date
  , ADJUDICATED_AND_DENIED_EARLIEST_UPDATE datetime
  , ADJUDICATED_AND_DENIED_LATEST_UPDATE   datetime
  
  , TOTAL_CLAIMS_TRANSMITTED int
  , TOTAL_CLAIMS_ADJUDICATED int
)
AS
BEGIN
 
 /***************************************************************************    
  * PATIENT_VIEW_CLAIM_STATUS_STATISTICS */    
 /**    
  * Returns summary 
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @return               Table 
  ***************************************************************************/                         
     
declare @pats as table (
    PATIENT_ID         bigint
  , CLIENT_ID          bigint
  , CURRENT_BIC        nvarchar(14)
  , USER_ID            bigint
  , LAST_POP           datetime
  , ACTIVE             bit
)

declare @claims as table (
    PATIENT_ID           bigint
  , CLIENT_ID            bigint
  , CLAIM_ID             bigint
  , STATUS               nchar(20)
  , STATUS_VAL           int
  , ENTRY_DATE           datetime
  , SERVICE_DATE         date
  , LAST_UPDATED         datetime
  , REFERENCE_CLAIM_ID_1 bigint
  , HAS_PROXY            bit
  , IS_PROXY             bit
    UNIQUE CLUSTERED (PATIENT_ID, STATUS_VAL, CLAIM_ID)
)

insert into @pats
select top 1
    pap.PATIENT_ID
  , pc.CLIENT_ID
  , pap.BIC  
  , pap.userID
  , pap.LASTPOP
  , dbo.YN_TO_BIT(pap.ACTIVE)
from      dbo.PATIENTS_Patient    as pap  
left join dbo.PATIENTS_Client     as pc   on pc.PATIENT_ID   = pap.PATIENT_ID
where (pap.PATIENT_ID = @patID)

insert into @claims
select 
    clms.PATIENT_ID
  , clms.CLIENT_ID
  , clms.CLAIM_ID
  , clms.STATUS
  , STATUS_VAL = convert(int,clms.STATUS)
  , clms.ENTRY_DATE
  , clms.SERVICE_DATE
  , clms.LAST_UPDATED
  , clms.REFERENCE_CLAIM_ID_1
  , clms.HAS_PROXY        
  , clms.IS_PROXY
from @pats                  as pap
join dbo.CLAIM_Claim        as clms on clms.PATIENT_ID = pap.PATIENT_ID


insert into @recs
select
    pats.PATIENT_ID
  , pats.CLIENT_ID 
  , pats.ACTIVE 
  , pats.USER_ID
  , pats.LAST_POP
  , pats.CURRENT_BIC
  , stat1.*
  , stat2.*
  , stat3.*
  , stat4.*
 , TOTAL_CLAIMS_TRANSMITTED = (stat2.TRANSMITTED_NOT_YET_ADJUDICATED_NUM_OF 
                            + stat3.ADJUDICATED_AND_PAID_NUM_OF 
							+ stat4.ADJUDICATED_AND_DENIED_NUM_OF)
 , TOTAL_CLAIMS_ADJUDICATED = (stat3.ADJUDICATED_AND_PAID_NUM_OF 
							+ stat4.ADJUDICATED_AND_DENIED_NUM_OF)
from @pats as pats

outer apply (
  select 
      NOT_YET_TRANSMITTED_NUM_OF          = count(clms.CLAIM_ID) 
    , NOT_YET_TRANSMITTED_EARLIEST_DOS    = MIN(clms.SERVICE_DATE)
	, NOT_YET_TRANSMITTED_LATEST_DOS      = MAX(clms.SERVICE_DATE)
    , NOT_YET_TRANSMITTED_EARLIEST_UPDATE = MIN(clms.ENTRY_DATE)
	, NOT_YET_TRANSMITTED_LATEST_UPDATE   = MAX(clms.ENTRY_DATE)
  from @claims as clms          
  where (
        (clms.PATIENT_ID = pats.PATIENT_ID) 
    and (clms.STATUS_VAL = 1)
  )
) as stat1

outer apply (
  select 
      TRANSMITTED_NOT_YET_ADJUDICATED_NUM_OF          = count(clms.CLAIM_ID) 
    , TRANSMITTED_NOT_YET_ADJUDICATED_EARLIEST_DOS    = MIN(clms.SERVICE_DATE)
	, TRANSMITTED_NOT_YET_ADJUDICATED_LATEST_DOS      = MAX(clms.SERVICE_DATE)
    , TRANSMITTED_NOT_YET_ADJUDICATED_EARLIEST_UPDATE = MIN(clms.LAST_UPDATED)
	, TRANSMITTED_NOT_YET_ADJUDICATED_LATEST_UPDATE   = MAX(clms.LAST_UPDATED)
  from @claims as clms          
  where (
        (clms.PATIENT_ID = pats.PATIENT_ID) 
    and (
	       ((clms.STATUS_VAL = 2)  and (clms.HAS_PROXY = 0) and (clms.IS_PROXY = 0) and (clms.REFERENCE_CLAIM_ID_1 is null))
	    or ((clms.STATUS_VAL = 12) and (clms.HAS_PROXY = 1) and (clms.IS_PROXY = 0) and (clms.REFERENCE_CLAIM_ID_1 is not null)) /* Status while not yet adjudicated */
		or ((clms.STATUS_VAL = 2)  and (clms.HAS_PROXY = 1) and (clms.IS_PROXY = 0) and (clms.REFERENCE_CLAIM_ID_1 is not null)) /* Status after adjudication */
    )
  )
) as stat2

outer apply (
  select 
      ADJUDICATED_AND_PAID_NUM_OF          = count(clms.CLAIM_ID) 
    , ADJUDICATED_AND_PAID_DOS             = MIN(clms.SERVICE_DATE)
	, ADJUDICATED_AND_PAID_LATEST_DOS      = MAX(clms.SERVICE_DATE)
    , ADJUDICATED_AND_PAID_EARLIEST_UPDATE = MIN(clms.LAST_UPDATED)
	, ADJUDICATED_AND_PAID_LATEST_UPDATE   = MAX(clms.LAST_UPDATED)
  from @claims as clms          
  where (
        (clms.PATIENT_ID = pats.PATIENT_ID) 
    and (clms.STATUS_VAL = 3)
  )
) as stat3

outer apply (
  select 
      ADJUDICATED_AND_DENIED_NUM_OF           = count(clms.CLAIM_ID) 
    , ADJUDICATED_AND_DENIED_EARLIEST_DOS    = MIN(clms.SERVICE_DATE)
	, ADJUDICATED_AND_DENIED_LATEST_DOS      = MAX(clms.SERVICE_DATE)
    , ADJUDICATED_AND_DENIED_EARLIEST_UPDATE = MIN(clms.LAST_UPDATED)
	, ADJUDICATED_AND_DENIED_LATEST_UPDATE   = MAX(clms.LAST_UPDATED)
  from @claims as clms          
  where (
        (clms.PATIENT_ID = pats.PATIENT_ID) 
    and (clms.STATUS_VAL = 4)
  )
) as stat4

RETURN

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_CLAIM_STATUS_STATISTICS] TO [webuser]
GO   
