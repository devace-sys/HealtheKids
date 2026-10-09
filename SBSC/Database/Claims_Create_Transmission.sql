/* TODO: This is no longer used and should be removed once all dependencies have been resolved (adhoc queries) */

use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Claims_Create_Transmission') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE Claims_Create_Transmission
GO

CREATE PROCEDURE Claims_Create_Transmission
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
 
ALTER PROCEDURE Claims_Create_Transmission
(
	@claimslist bigint_tabletype READONLY,
	@userid bigint,
	@note varchar(7000),
	@generationID bigint,
	@transmission_ID bigint OUTPUT
)

AS
BEGIN

print 'No longer used'

END
GO