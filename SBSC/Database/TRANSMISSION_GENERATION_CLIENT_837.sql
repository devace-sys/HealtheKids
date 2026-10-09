
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CLIENT_837') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_CLIENT_837
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_CLIENT_837 (
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

exec dbo.TRANSMISSION_GENERATION_CLIENT_837_CURRENT_YEAR
    @clientID
  , @path
  , @filename
  , @userid
  , @note
  , @transmissionID OUTPUT

END
GO