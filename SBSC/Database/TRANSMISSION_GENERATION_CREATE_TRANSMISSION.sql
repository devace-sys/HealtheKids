
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CREATE_TRANSMISSION') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_CREATE_TRANSMISSION
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_CREATE_TRANSMISSION
(
    @generationID      as bigint
  , @userID            as bigint
  , @note              as varchar(7000)
  , @transmissionID    as bigint OUTPUT
  , @releaseClaimCount as bigint output
)
AS
BEGIN

/******************************************
 *
 *		Create a transmission using the unheld claims within a specific generation
 *	
 ******************************************/
set nocount on

declare @claims        as bigint_tabletype
declare @msgStr        as varchar(512) = ''
declare @claimSource   as bigint = null
declare @today         as datetime = getdate()
declare @useForBilling as bit = 1

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Create Tranmission Data - Starting'

set @transmissionID    = 0
set @releaseClaimCount = 0
set @today             = getdate()

select top 1 
    @claimSource    = tg.claimSource
from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Create Tranmission Data - Get Releasable Claims'

insert into @claims(id)
select 
  clr.ClaimID 
from dbo.TRANSMISSION_GENERATION_RELEASEABLE_CLAIMS(@generationID)	as clr

select 
  @releaseClaimCount = count(id) 
from @claims

set @msgStr = 'Transmission Generation Create Tranmission Data - Releasable Claim Count : ' + convert(varchar(256),@releaseClaimCount)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

if      (@claimSource = 1) set @useForBilling = 1
else if (@claimSource = 2) set @useForBilling = 1
else if (@claimSource = 3) set @useForBilling = 0
else                       set @useForBilling = 1

/* create the transmission */

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Create Tranmission Data - Generate Transmission Records'

--exec dbo.Claims_Create_Transmission @claims, @userID, @note, @transmissionID output

exec dbo.PRINT_STATUS_MESSAGE 'Claims Create Transmission - Starting'
exec dbo.PRINT_STATUS_MESSAGE 'Claims Create Transmission - Create Transmission Record'

/* Create the core transmission record */

insert into transmission_records (
	  Created_At
	, Created_By
	, transmission_note
	, UseForBilling
	, generationID )
Values(
	  @today
	, @userid
	, @note
	, @useForBilling
	, @generationID
)

set @transmissionID	= SCOPE_IDENTITY()

exec dbo.PRINT_STATUS_MESSAGE 'Claims Create Transmission - Create Transmission Record Claims Records'

/* Link the claims to transmit to the transmission record */

if (@claimSource in (1,2))
begin
insert into dbo.Transmission_Record_Claims (
    transmission_id
  , claim_id
  , Amount_Transmitted)
select 
	@transmissionID
  , clm.id
  , (select dbo.CLAIMS_AMOUNT_CALC(clm.id)) 
from @claims as clm
end

/* CIF voids use the amount paid */

else if (@claimSource = 3)
begin
  insert into dbo.Transmission_Record_Claims (
      transmission_id
    , claim_id
    , Amount_Transmitted)
  select 
	  @transmissionID
    , clm.id
    , crps.amountToPayBack
  from @claims                             as clm
  join dbo.CIF_REQUESTS_PENDING_SUBMISSION as crps on crps.claimID = clm.id
  
end
  
/* Summary report is only for new or retroactive claims */

if (@claimSource in (1,2))
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Claims Create Transmission - Create Transmission Summary Record'

  /* Pack transmission summary data into Transmission_Summary_By_Client_837 for later reference */
	
  /* Insert summary data into table */

  insert into dbo.Transmission_Summary_By_Client_837 (
		 TRANSMISSION_RECORD_ID
		,TRANSMISSION_DATE
		,CLIENT_ID
		,CLIENT_NAME
		,CLIENT_SHORTNAME
		,CLIENT_CDS
		,CLIENT_NPI
		,CLIENT_TAX_ID

		,TOTAL_NUMBER_CLAIMS
		,TOTAL_DOLLAR_AMOUNT		

		,CLAIMS_SUBMITTED		
		,AMOUNT_SUBMITTED			

		,CLAIMS_RESUBMITTED
		,AMOUNT_RESUBMITTED
		,RevenueSharingCategoryLEA
		,WhenToInvoice
		,InvoiceRate
	  )
	  select	 
			 @transmissionID	as Transmission_ID
			,@today		  	    as Transmission_Date
			,*					/* TODO: Explicitly define this rather than using wildcard */
	  from dbo.CLAIMS_HOWMUCH_CALCULATE(@claims)

end

exec dbo.PRINT_STATUS_MESSAGE 'Claims Create Transmission - Complete'


/****************************************************************************************************************************/

exec dbo.PRINT_STATUS_MESSAGE 'Transmission Generation Create Tranmission Data - Complete'

END
GO