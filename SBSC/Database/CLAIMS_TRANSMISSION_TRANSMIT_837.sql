use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CLAIMS_TRANSMISSION_TRANSMIT_837') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.CLAIMS_TRANSMISSION_TRANSMIT_837
GO

use SPEDMON 
GO

CREATE PROCEDURE CLAIMS_TRANSMISSION_TRANSMIT_837
(
	@claimslist bigint_tabletype READONLY,
	@userid bigint,
	@note varchar(7000),
	@transmission_ID bigint OUTPUT
)

AS
BEGIN
 select 1
END
GO
 
use SPEDMON 
GO

ALTER PROCEDURE dbo.CLAIMS_TRANSMISSION_TRANSMIT_837
(
	  @generationID   bigint
	, @transmissionID bigint
	, @Path           VARCHAR(255)
	, @Filename       VARCHAR(100)
	, @userID         bigint
	
)

AS
BEGIN

/******************************************
 *
 *			Create_Transmission
 *
 *	When creating an 837 file for transmission
 *	(sometimes just referred to as a 'transmission'),
 *	we want to assign that transmission a unique 
 *	identifier and record metadata re: the context 
 *	in which the transmission was made as well as
 *	which claims are linked to/within the specified
 *	transmission.
 *
 *	This sproc has dependencies:
 *		Type BIGINT_TableType
 *		Table dbo.Transmission_Records 
 *		Table dbo.Transmission_Record_Claims
 *	
 *	20130218: Modified sproc to store summary data for
 *	invoicing.
 *	
 ******************************************/
set nocount on

declare @today       as datetime
declare @clmStatus   as char(10) 
declare @msg         as varchar(512)
declare @numClaims   as bigint = 0
declare @claimSource as bigint 

declare @clms as table (
  claim_id bigint
UNIQUE CLUSTERED (claim_id) 
)			

declare @svcRecs as table (
  svcRecID bigint
UNIQUE CLUSTERED (svcRecID)
)

declare @837_claims as bigint_tabletype

/*---------------------------------------------------------------------------------------------------------*/

set @today     = GETDATE()
set @clmStatus = convert(char(10),dbo.CONST_CLAIM_STATUS_SUB_PENDING())  /* Save time on update */

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Starting'

select top 1 
    @claimSource    = tg.claimSource
from dbo.TRANSMISSION_GENERATIONS as tg
where (tg.id = @generationID)

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Get All Claims Related To Tx Record'

insert into @clms
select distinct 
  trc.claim_id     
from dbo.Transmission_Record_Claims					as trc 
where ((trc.transmission_id = @transmissionID) and (trc.claim_id is not null))

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Get All Service Records Related to Tx Record'

insert into @svcRecs
select distinct 
  src.svcRecID
from  @clms                     as clm
join dbo.SERVICE_RECORD_CLAIMS	as src on src.claimID = clm.claim_id

/*---------------------------------------------------------------------------------------------------------*/

select @numClaims = count(claim_id) from @clms
set @msg = 'Claims Transmission Create Transmission - Claim Count ' + convert(varchar(256),@numClaims)
exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

if (@numClaims = 0) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - No Claims So No 837 File Will Be Generated'
  exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Complete'
  return
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - There Are Claims To Transmit'
end

/*---------------------------------------------------------------------------------------------------------*/

/* If this is new claims or retroactive claims */

if (@claimSource in (1,2))
begin

  exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Update Claim Status'
    
  update cc    
  set 
       cc.STATUS       = @clmStatus
     , cc.LAST_UPDATED = @today		 
     , cc.NUMBER_OF_SUBMISSIONS = (isnull(cc.NUMBER_OF_SUBMISSIONS, 0) + 1) /* increment counter  */ 								   
  from  @clms					as trc 
  join dbo.CLAIM_Claim	        as cc on cc.CLAIM_ID = trc.claim_id
	        
  /*---------------------------------------------------------------------------------------------------------*/

  exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Update Service Record Status'

  update sr     
  set 
      sr.state        = dbo.CONST_SVC_REC_STATE_SUB()
    , sr.lastmodified = @today        
  from @svcRecs            as trc
  join dbo.SERVICE_RECORDS as sr  on sr.id = trc.svcRecID

  /*---------------------------------------------------------------------------------------------------------*/
	      
  exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Update Service Record Audit Log'
      
  INSERT INTO dbo.SERVICE_RECORDS_AUDIT_LOG (
      svcRecID    
    , loggedOn    
    , userID   
    , state
  )    
  select     
       sr.svcRecID     as id
     , @today	 	     as loggedOn     
     , @userID	     as userID     
     , dbo.CONST_SVC_REC_STATE_SUB()	as [state]     
  from @svcRecs					        as sr 
 
end
else if (@claimSource = 3) /* CIF void */
begin

  update sac
    set 
	  sac.submitted      = 1
    , sac.submittedOn    = @today
	, sac.generationID   = @generationID
    , sac.transmissionID = @transmissionID
  from @clms                                    as clm
  join dbo.CIF_REQUESTS_CLAIMS_VOID_SUBMISSIONS as sac on sac.claimID = clm.claim_id
 
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Creating a List of Claims to Pass to 837 Write File Routine'

insert into @837_claims(id)
select distinct
  trc.claim_id 
from @clms as trc
order by 
  trc.claim_id

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Creating Unique FileName'
set @Filename = RIGHT(convert(varchar(256),@transmissionID) + '_' + @Filename + '_' + convert (varchar(10), convert(date,getdate(),112)) + '_837', 100)

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Call 837 File Write Routine'
exec dbo.Claims_Write_5010_837_File @generationID, @transmissionID, @837_claims, @Path, @Filename

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Update Transmission Record With Filename'

update dbo.Transmission_Records
  set fileName = @Filename 
where (Transmission_ID = @transmissionID)

/*---------------------------------------------------------------------------------------------------------*/

set @msg = 'Claims Transmission Create Transmission - 837 File Generated : ' + @FileName
exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Claims Transmission Create Transmission - Complete'

END
GO