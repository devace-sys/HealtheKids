
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_837_PROCESS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_837_PROCESS
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_837_PROCESS
(
	@clientIDs bigint_tabletype READONLY	-- a list of client IDs
	,@path VARCHAR(255)	-- file path to save to
	,@Filename VARCHAR(100) -- save file name
	,@userid	bigint	
	,@note varchar(7000)
)
AS
BEGIN
	/* In the interests of forward compatibility, the functionality here has been deprecated
		and this sproc is now flagged to indicate a more appropriate method. */

	raiserror ('TRANSMISSION_GENERATION_837_PROCESS is deprecated - use TRANSMISSION_GENERATION_MULTIPLE_837_PROCESS instead',11,1)

END
	

GO