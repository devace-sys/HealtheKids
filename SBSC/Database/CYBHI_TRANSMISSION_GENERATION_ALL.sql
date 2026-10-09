use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_ALL') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_ALL
end
GO

/*---------------------------------------------------------------------------------------------------------*/

/*

use SPEDMON
go

declare @userID   as bigint = 805
declare @path     as varchar(100) = 'C:\spedmon\data\import-export\claims\cybhi\837\'
declare @jsonData as varchar(max) = '[]'

exec dbo.CYBHI_TRANSMISSION_GENERATION_ALL 
	  @path 
	, @userID	
	, @jsonData output

select 
  t1.*
from OPENJSON(@jsonData)
with (     		  
	      [transmissionID]     bigint       '$.transmissionID'
		, [fileName]           varchar(100) '$.fileName'
		, [claimHoldCount]     int          '$.claimHoldCount'
	    , [claimReleaseCount]  int          '$.claimReleaseCount'
		, [generationOK]       bit          '$.generationOK'   
        , [fileGenerated]      bit          '$.fileGenerated'        	 
		, svcRecHoldCount      int          '$.svcRecHoldCount'
        , svcRecReleaseCount   int          '$.svcRecReleaseCount'
        , amountHeld           money        '$.amountHeld'
        , amountReleased       money        '$.amountReleased'
) as t1

*/

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_ALL (
    @path      varchar(255)	/* file path to save to	*/
  , @userID	   bigint
  , @jsonData  varchar(max) output
)
AS
BEGIN
  
set nocount on
set @jsonData = '[]'
  
/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation All - Init'

declare @curIdx             as int          = 0
declare @maxIdx             as int          = 0
declare @clientID           as bigint       =  -1

declare @possibleClaimCount as int          = 0
declare @claimHoldCount     as int          = 0
declare @claimReleaseCount  as int          = 0
declare @fileName           as varchar(100) = ''
declare @transmissionID     as bigint       = -1
declare @generationOK       as bit          = 0
declare @fileGenerated      as bit          = 0
declare @svcRecHoldCount    as int          = 0
declare @svcRecReleaseCount as int          = 0
declare @amountHeld         as money        = 0
declare @amountReleased     as money        = 0

declare @cybhiClients as table (
    idx                 int identity(1,1)
  , clientID            bigint
  , tpaApprovedOn       date
  , possibleClaimCount  int
  , claimHoldCount      int
  , claimReleaseCount   int
  , transmissionID      bigint       
  , [fileName]          varchar(100)
  , generationOK        bit   
  , fileGenerated       bit
  , svcRecHoldCount     int
  , svcRecReleaseCount  int
  , amountHeld          money
  , amountReleased      money
)

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation All - Getting all CYBHI Clients'

insert into @cybhiClients (
    clientID
  , tpaApprovedOn
  , possibleClaimCount
  , claimHoldCount
  , claimReleaseCount
  , generationOK 
  , fileGenerated
  , svcRecHoldCount
  , svcRecReleaseCount
  , amountHeld 
  , amountReleased
)
select 
      q1.clientID
    , q1.tpaApprovedOn
    , possibleClaimCount = 0
    , claimHoldCount     = 0
    , claimReleaseCount  = 0
    , generationOK       = 0
    , fileGenerated      = 0
	, svcRecHoldCount    = 0
	, svcRecReleaseCount = 0
	, amountHeld         = 0
	, amountReleased     = 0
from
(
  select 
      clientID               = clc.CLIENT_ID
    , tpaApprovedOn          = clc.cybhiTpaApprovedOn
    , numOfPendingClaimLines = isnull(clms.numOfPendingClaimLines,0)
  
  from dbo.CLIENTS_Client as clc

  cross apply (

    select
       numOfPendingClaimLines = count(clm.id)
    from dbo.CYBHI_CLAIMS                as clm
    join dbo.CLAIM_Procedures            as cp  on cp.PROCEDURE_ID = clm.procedureID

    where (	  
		  (clm.clientID      = clc.CLIENT_ID)    
	  and (clm.txStatusCode  = 1)
	  and (clm.numUnits      != 0)
	  and (clm.amountClaimed != 0.00)	
  	  and (cp.PUT_IN_837     = 1)
	  and (clm.active        = 1)	 
    )
    group by 
      clm.clientID
  ) as clms 
  
  where (
        (clc.cybhi               = 1) 
    and (clc.cybhiSubmitClaims   = 1)
    and (clc.cybhiTpaApproved    = 1)
    and (clc.cybhiTpaID is not null)
    and (clc.cybhiGenerate837     = 1)
    and (clc.cybhiAutoGenerate837 = 1)  
  )
) as q1

where 
  (q1.numOfPendingClaimLines > 0)
option(recompile)

select @curIdx = 1, @maxIdx = max(t1.idx) from @cybhiClients as t1

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation All - Generating Transmissions'

while (@curIdx <= @maxIdx)
begin

  select top 1 
      @clientID  = t1.clientID	
  from @cybhiClients as t1
  where 
    (t1.idx = @curIdx)
  option(recompile)

  set @possibleClaimCount = 0
  set @claimHoldCount     = 0
  set @claimReleaseCount  = 0
  set @fileName           = ''
  set @transmissionID     = -1
  set @generationOK       = 0
  set @fileGenerated      = 0
  set @svcRecHoldCount    = 0
  set @svcRecReleaseCount = 0
  set @amountHeld         = 0
  set @amountReleased     = 0

  exec dbo.CYBHI_TRANSMISSION_GENERATION 
	    @clientID           
	  , @path               
	  , @userID	          
	  , null /* @oldestDos */         
	  , null /* @latestDos */         
      , @possibleClaimCount output
	  , @claimHoldCount     output
      , @claimReleaseCount  output
	  , @fileName           output			
	  , @transmissionID     output
	  , @generationOK       output
	  , @fileGenerated      output
	  , @svcRecHoldCount    output
	  , @svcRecReleaseCount output
	  , @amountHeld         output
	  , @amountReleased     output  
  
  update @cybhiClients
  set 
     [fileName]            = @fileName
   , possibleClaimCount    = @possibleClaimCount
   , claimHoldCount        = @claimHoldCount
   , claimReleaseCount     = @claimReleaseCount
   , transmissionID        = @transmissionID
   , generationOK          = @generationOK
   , fileGenerated         = @fileGenerated
   , svcRecHoldCount       = @svcRecHoldCount
   , svcRecReleaseCount    = @svcRecReleaseCount
   , amountHeld            = @amountHeld
   , amountReleased        = @amountReleased
  
  where 
    (idx = @curIdx)
  
  option(recompile)

  set @curIdx = @curIdx + 1

end /* while */

/*---------------------------------------------------------------------------------------------------------*/

set @jsonData = convert(varchar(max),(select * from @cybhiClients FOR JSON AUTO, INCLUDE_NULL_VALUES ))
exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation All - Done'

END
GO
