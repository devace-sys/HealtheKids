USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE] (
   @refDate  datetime
 , @numWeeks int
)    

RETURNS @recs TABLE (
    SLOT                         int
  , START_DATE                   datetime
  , END_DATE                     datetime
  , CHECK_DATE                   datetime  
  , REASON                       varchar(8000)
  , ADJUDICATION_ID              bigint
  , CCN                          nchar(13)
  , TRANSMISSION_RECORD_CLAIM_ID bigint
  , CLAIM_ID                     bigint
  , CLIENT_ID                    bigint
  , REF_MIN_START_DATE           datetime
  , REF_MAX_END_DATE             datetime
  , REF_DATE_TODAY               datetime
  , REF_DATE_OLDEST_DOS          datetime
  , REF_VALUE_NUM_WEEKS          int
)
 
/***************************************************************************    
 * CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE */    
/**    
 ***************************************************************************/                         
     
AS 
BEGIN


declare @today     as datetime  = null
declare @startDate as datetime  = null
declare @endDate   as datetime  = null
declare @oldestDos as datetime  = null

declare @dates as table (   
    [START_DATE]   datetime
  , [END_DATE]     datetime
  , [SLOT]         int
  unique clustered ([START_DATE],[END_DATE],[SLOT])
)

/* Get current date */

set @today = getdate()

/* Calculate oldest date of service allowed with respect to current date */

set @oldestDos = dbo.CALC_OLDEST_DOS_ALLOWED (convert(date,@today))

/* Get latest check date if no ref date is passed */

if (@refDate is null)  
begin
  select 
    @refDate = max(ccp.CHECK_DATE) 
  from dbo.CLIENTS_Client_Active_LEA as clc 
  join dbo.CLAIM_Claim_Posting       as ccp on ccp.clientID = clc.CLIENT_ID
end

/* Default to 16 week window */

if (@numWeeks is null) set @numWeeks = 16

/* Get weeks to look at */

insert into @dates
select 
   t1.START_DATE
 , t1.END_DATE 
 , SLOT = t1.IDX
from dbo.CALC_LAST_OR_NEXT_N_WEEK_START_AND_END_DATES ( @refDate, @numWeeks, 'L') as t1

/* Get earliest possible and latest possible check date */

select 
    @startDate = MIN(t1.[START_DATE])
  , @endDate   = MAX(t1.[END_DATE])     
from @dates as t1

/* Generate data */

insert into @recs
select  
    SLOT       = d2.SLOT
  , START_DATE = d2.START_DATE
  , END_DATE   = d2.END_DATE
  , CHECK_DATE = ccp.CHECK_DATE
  , REASON     = isnull(cdc.CODE_VALUE,'') + ' - ' + isnull(cdc.DETAIL_TEXT,'')
  , cca.ADJUDICATION_ID
  , cca.CCN
  , cca.TRANSMISSION_RECORD_CLAIM_ID
  , cca.CLAIM_ID
  , clc.CLIENT_ID
  , REF_MIN_START_DATE          = @startDate
  , REF_MAX_END_DATE            = @endDate
  , REF_DATE_TODAY              = @refDate
  , REF_DATE_OLDEST_DOS         = @oldestDos
  , REF_VALUE_NUM_WEEKS         = @numWeeks

from dbo.CLIENTS_Client_Active_LEA        as clc
join dbo.CLAIM_Claim_Posting              as ccp on ccp.clientID        = clc.CLIENT_ID
join dbo.CLAIM_Claim_Adjudication         as cca on cca.POSTING_ID      = ccp.POSTING_ID
                                                 and (cca.AMOUNT_PAID = 0)
join dbo.CLAIM_Claim                      as clm on clm.CLAIM_ID        = cca.CLAIM_ID
join dbo.CLAIM_CLAIM_ADJUDICATION_DETAILS as cad on cad.ADJUDICATION_ID = cca.ADJUDICATION_ID
join dbo.CLAIM_DETAIL_CODES               as cdc on cdc.CODE_ID         = cad.DETAIL_CODE_ID

cross apply (
  select top 1    
      d1.START_DATE
    , d1.END_DATE
	, d1.SLOT
  from @dates as d1
  where (ccp.CHECK_DATE between d1.START_DATE and d1.END_DATE)
) as d2

where (     
      (ccp.CHECK_DATE BETWEEN @startDate and @endDate) 
  and (clm.SERVICE_DATE >= @oldestDos)
  and (clm.STATUS not in ('3','13')) /* Exclude claims that finally got paid */
)

/* Get rid of 835 reference text found in a number of denial reasons */

update @recs
set REASON = REPLACE(REASON,'Note: Refer to the 835 Healthcare Policy Identification Segment (loop 2110 Service Payment Information REF), if present.','')

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_DENIED_WITH_RESPECT_TO_RECENT_POSTING_DATA_CORE] TO [webuser]
GO  
