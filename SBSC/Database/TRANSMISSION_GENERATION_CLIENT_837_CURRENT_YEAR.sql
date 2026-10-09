
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLIENT_837_CURRENT_YEAR') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_CURRENT_YEAR
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_CLIENT_837_CURRENT_YEAR (
	  @clientID           bigint	-- the client we want to transmit
	, @path               VARCHAR(255)	-- file path to save to
	, @filename           VARCHAR(100) -- save file name
	, @userid	          bigint	
	, @note               varchar(7000)
	, @transmissionID     bigint OUTPUT
)
AS
BEGIN

set nocount on

declare @today     as datetime
declare @oldestDOS as datetime
declare @newestDOS as datetime

set @today      = getdate()
set @oldestDOS = dbo.CALC_OLDEST_DOS_ALLOWED (convert(date,@today))
set @newestDOS = @today

exec dbo.TRANSMISSION_GENERATION_CLIENT_837_BY_DATES 
    @clientID
  , @path
  , @filename
  , @userid
  , @note
  , @today
  , @oldestDOS
  , @newestDOS
  , 1 /* Claim source = 1 (current) */
  , null /* Claim sub source (not used) */
  , @transmissionID OUTPUT

END
GO