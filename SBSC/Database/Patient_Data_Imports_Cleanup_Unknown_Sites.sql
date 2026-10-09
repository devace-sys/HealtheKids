USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patient_Data_Imports_Cleanup_Unknown_Sites') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Patient_Data_Imports_Cleanup_Unknown_Sites
GO


/*-------------------------------
 * Create new
 *------------------------------*/

CREATE PROCEDURE [dbo].[Patient_Data_Imports_Cleanup_Unknown_Sites] 
AS

BEGIN

set nocount on

declare @clients as table (
    IDX bigint identity(1,1)
   ,CLIENT_ID        bigint
unique clustered (IDX)
)

declare @clientID as bigint = -1
declare @curIdx   as bigint = 1
declare @maxIdx   as bigint = 0
declare @numWins  as int    = 0
declare @numFails as int    = 0

/*############################################################################
 *# Get all active clients
 *############################################################################*/

insert into @clients (CLIENT_ID)
select distinct 
  CLIENT_ID 
from dbo.CLIENTS_Client as clc 
where (clc.LEA = 1)

set @curIdx = 1
select @maxIdx = max(IDX) from @clients

while (@curIdx <= @maxIdx)
begin
  select top 1 @clientID = t1.CLIENT_ID from @clients as t1 where (t1.IDX = @curIdx)
  begin try
    exec dbo.Patient_Data_Imports_Cleanup_Unknown_Sites_For_A_Client @clientID
    set @numWins = @numWins + 1
  end try
  begin catch
    set @numFails = @numFails + 1
  end catch
  set @curIdx = @curIdx + 1
end

/*############################################################################
 *# Done
 *############################################################################*/

RETURN(0)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[Patient_Data_Imports_Cleanup_Unknown_Sites] TO [webuser]
