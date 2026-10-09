use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_MULTIPLE_837_PROCESS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_MULTIPLE_837_PROCESS
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_MULTIPLE_837_PROCESS (
	 @clientIDs bigint_tabletype READONLY	-- a list of client IDs
   , @path      VARCHAR(255)	-- file path to save to
   , @filename  VARCHAR(100) -- save file name
   , @userid	bigint	
   , @note      varchar(7000)
   , @txIdsJsonData varchar(max) output
)
AS
BEGIN

  set nocount on
  set @txIdsJsonData = '[]'

  exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - Starting' 

  declare @spaID                    as bigint   = 1
  declare @transmissionID			as bigint	= NULL
  declare @today					as datetime = GETDATE()
  declare @currentval    as bigint = 1
  declare @currentClient as bigint
  declare @maxRowID	     as bigint
  
  declare @clientIterationList as table (
	    row_id    bigint identity
	  , client_id bigint
    unique clustered (row_id)
  )

  declare @transmissionIDs as table (
      transmissionID bigint
	, retroactive    bit
	, cifVoid        bit
  )

  
if @filename is null
	set @filename = convert (varchar(10), convert(date,getdate(),112)) + '_837'
		 	
/*---------------------------------------------------------------------------------------------------------*/

insert into @clientIterationList 
	(client_id) 
select 
	id as client_id 
from @clientIDs

select @maxRowID = MAX(row_id) from @clientIterationList	
if (@maxRowID is null)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - No Client Values Passed - Exiting'
  exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - Complete' 
  return
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - Update CIF Resolutions (all clients)'
exec dbo.CIF_REQUESTS_UPDATE_RESOLUTIONS

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - Retroactive Claims'
set @currentval = 1	
while (@currentval <= @maxRowID)
begin		 
  select top 1 
	 @currentClient = t1.client_id 
  from @clientIterationList as t1
  where (t1.row_id = @currentval)			  			    		  		
  exec dbo.TRANSMISSION_GENERATION_CLIENT_837_RETROACTIVE_FOR_SPA @spaID, @currentClient,@path, @filename, @userid, @note, @transmissionID OUTPUT
  insert into @transmissionIDs(transmissionID,retroactive,cifVoid) values (@transmissionID,1,0)
  set @currentval = @currentval + 1
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - CIF Voids'
set @currentval = 1	
while (@currentval <= @maxRowID)
begin		 
  select top 1 
	 @currentClient = t1.client_id 
  from @clientIterationList as t1
  where (t1.row_id = @currentval)			  			    		  		
  exec dbo.TRANSMISSION_GENERATION_CLIENT_837_CIF_VOID @currentClient,@path, @filename, @userid, @note, @transmissionID OUTPUT
  insert into @transmissionIDs(transmissionID,retroactive,cifVoid) values (@transmissionID,0,1)
  set @currentval = @currentval + 1
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - Current Claims'
set @currentval = 1	

while (@currentval <= @maxRowID)
begin		 	  
  select top 1 
	 @currentClient = t1.client_id 
  from @clientIterationList as t1 
  where (t1.row_id = @currentval)			  			    		  		
	  
  exec dbo.TRANSMISSION_GENERATION_CLIENT_837_CURRENT_YEAR @currentClient, @path, @filename, @userid, @note, @transmissionID OUTPUT 
  insert into @transmissionIDs(transmissionID,retroactive,cifVoid) values (@transmissionID,0,0)
  set @currentval = @currentval + 1
end

/*---------------------------------------------------------------------------------------------------------*/

set @txIdsJsonData = isnull(convert(varchar(max), (select t1.transmissionID, t1.retroactive, t1.cifVoid from @transmissionIDs as t1 FOR JSON AUTO, INCLUDE_NULL_VALUES) ),'[]')

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Generate 837 File(s) - Complete' 

END
GO