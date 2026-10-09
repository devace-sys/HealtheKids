use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLIENT_837_BY_DATES') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_BY_DATES
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_BY_DATES (
	  @clientID           bigint	-- the client we want to transmit
	, @path               VARCHAR(255)	-- file path to save to
	, @filename           VARCHAR(100) -- save file name
	, @userid	          bigint	
	, @note               varchar(7000)
	, @today              datetime
	, @oldestDOS          datetime
	, @newestDOS          datetime
	, @claimSource        bigint
	, @claimSubSource     bigint
	, @transmissionID     bigint OUTPUT
)
AS
BEGIN

set nocount on
 	
declare @shortName           as varchar(100) = ''
declare @clientName          as varchar(512) = ''
declare @generationID	     as	bigint	     = NULL
declare @msgStr              as varchar(512) = ''
declare @potentialClaimCount as bigint       = 0
declare @heldClaimCount      as bigint       = 0
declare @releaseClaimCount   as bigint       = 0

exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Starting'
	
/*---------------------------------------------------------------------------------------------------------*/

if (@clientID is null) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for client not provided, exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@path is null) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for path not provided, exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@filename is null) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for filename not provided, exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@today is null) 
begin
  set @today = getdate()
end

/*---------------------------------------------------------------------------------------------------------*/

if (@oldestDOS is null) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for oldest dos was not provided, exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@newestDOS is null) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for newest dos was not provided, exiting'      
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@claimSource is null) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for claim source was not provided, exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

if (@claimSource = 1) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Claim Source 1 - Current claiming window'
end
else if (@claimSource = 2) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Claim Source 2 - Retroactive'
end
else if (@claimSource = 3) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Claim Source 3 - CIF voids'
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Value for claim source is unknown or unsupported - exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

/* Get client data */

set @shortName = null

select top 1
    @clientName = clc.CLIENT_NAME
  , @shortName  = clc.ShortName 
  
from dbo.CLIENTS_Client as clc 
where ( 
      (clc.CLIENT_ID = @clientID)	
  and (clc.CLIENT_ID <> 112) /* SpEdCare USD */
  and (clc.LEA          = 1)
  and (clc.APPROVED_835 = 1)
  and (clc.APPROVED_837 = 1)
)

/*---------------------------------------------------------------------------------------------------------*/

set @msgStr = 'Generating 837 file - ClientName: ' + @clientName
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Generating 837 file - ClientShortName: ' + isnull(@shortName,'')
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*---------------------------------------------------------------------------------------------------------*/

if (@shortName is null)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - This client is not setup for transmission, has no short name, or not found.  Exiting'
  return
end

/*---------------------------------------------------------------------------------------------------------*/

/* Create file name */

set @filename = @shortName + '_' + @filename

/*---------------------------------------------------------------------------------------------------------*/

/* Create and output status data */

set @msgStr  =  'Generating 837 file - ClientID : ' + convert(varchar(256),@clientID)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr =  'Generating 837 file - Dates of service : ' + convert(varchar,@oldestDOS) + ' to ' + convert(varchar,@newestDOS) 
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*---------------------------------------------------------------------------------------------------------*/

/* Run generation for client, produce transmission, save 837 */
/* TODO: Find out why this transaction is not wrapped in a try catch */

exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Opening Transaction'

BEGIN TRANSACTION
    
	/* Note: Each subroutine is responsible for determining what to do based on claim source.  
	 * For example cif voids do not trigger denial resubs, transportation matching, etc. */

	/*---------------------------------------------------------------------------------------------------------*/

	/* Create transmission generation record */

	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Create transmission generation record'    
	exec dbo.TRANSMISSION_GENERATION_CREATE @clientID, null, null, @oldestDOS, @newestDOS, null, null, @claimSource, @claimSubSource, @generationID OUTPUT
    set @msgStr  =  'Generating 837 file - GenerationID : ' + convert(varchar(256),@generationID)
    exec dbo.PRINT_STATUS_MESSAGE @msgStr
   
    /*---------------------------------------------------------------------------------------------------------*/

	/* Resubmit denied claims */

	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Resubmit denied claims'
    exec dbo.TRANSMISSION_GENERATION_CLIENT_PROCESS_DENIAL_RESUBMISSIONS @generationID, @userID

	/*---------------------------------------------------------------------------------------------------------*/

	/* Match transportation and create proxy claims */

	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Match transportation and create proxy claims'    
	exec dbo.TRANSMISSION_GENERATION_CLIENT_CLAIM_INIT @generationID, @userID
	
    /*---------------------------------------------------------------------------------------------------------*/

	/* Get transmittable claims for generation */

	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Append potentially transmittable claims to generation'    
	exec dbo.TRANSMISSION_GENERATION_APPEND_GENERATION_CLAIMS @generationID, @potentialClaimCount output

	/*---------------------------------------------------------------------------------------------------------*/

	/* Check the claims in the generation and figure out which are held (bucket routine) */
	
	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Applying generation holds (bucket routine)'    
	exec dbo.TRANSMISSION_GENERATION_APPLY_HOLDS @generationID, 0, @heldClaimCount output
	
   /*---------------------------------------------------------------------------------------------------------*/

	/* Use the releasable claims as a basis for creating a transmission */

	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Create generation transmission'
	exec dbo.TRANSMISSION_GENERATION_CREATE_TRANSMISSION @generationID, @userID, @note, @transmissionID OUTPUT, @releaseClaimCount output
    set @msgStr = 'Generating 837 file - TransmissionID : ' + convert(varchar(256),@transmissionID)
    exec dbo.PRINT_STATUS_MESSAGE @msgStr

	/*---------------------------------------------------------------------------------------------------------*/

	/* Prep claims and write 837 file for this transmission */

	exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Update claim records and create 837 file'
	exec dbo.CLAIMS_TRANSMISSION_TRANSMIT_837 @generationID, @transmissionID, @path, @filename, @userID
    
   /*---------------------------------------------------------------------------------------------------------*/

COMMIT TRANSACTION

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Comitting Transaction'
exec dbo.PRINT_STATUS_MESSAGE 'Generating 837 file - Completed'

/*---------------------------------------------------------------------------------------------------------*/

END
GO