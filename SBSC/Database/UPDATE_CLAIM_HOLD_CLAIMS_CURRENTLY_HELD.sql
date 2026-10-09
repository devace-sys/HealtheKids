USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD
(
  @clientID as bigint
)
AS    

BEGIN     
    
/***************************************************************************    
 * UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        

declare @maxIdx           as bigint
declare @curIdx           as bigint
declare @clientIDToUpdate as bigint

declare @clients as table (
    IDX       bigint identity(1,1)
  , CLIENT_ID bigint
)

BEGIN TRY

RAISERROR ('Updating claims currently held data for all select clients', 0, 1) WITH NOWAIT 

RAISERROR ('Getting all select clients', 0, 1) WITH NOWAIT 

insert into @clients
select clc.CLIENT_ID from dbo.CLIENTS_Client_Active_LEA as clc
where 
(
      (1=1)
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
)
order by 
  clc.CLIENT_ID

RAISERROR ('Reorganizing index', 0, 1) WITH NOWAIT 
ALTER INDEX [CLIENT_ID_IDX] ON [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DETAIL_DATA] REORGANIZE  WITH ( LOB_COMPACTION = ON )

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Dropping indexes', 0, 1) WITH NOWAIT 

DROP INDEX IF EXISTS [CLIENT_ID_IDX] ON [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA]
DROP INDEX IF EXISTS [IDX]           ON [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA] WITH ( ONLINE = OFF )

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Updating claims currently held data for each select client', 0, 1) WITH NOWAIT 

select @curIdx = min(idx), @maxIdx = max(idx) from @clients

while (@curIdx <= @maxIdx)
begin
	select top 1 @clientIDToUpdate = t1.CLIENT_ID from @clients as t1 where (t1.IDX = @curIdx)
	exec dbo.UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_FOR_CLIENT @clientIDToUpdate
	set @curIdx = @curIdx + 1
end

/*---------------------------------------------------------------------------------------------------------------------*/

RAISERROR ('Creating indexes', 0, 1) WITH NOWAIT 

CREATE UNIQUE CLUSTERED INDEX [IDX] ON [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA]
(
  [IDX] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [CLIENT_ID_IDX] ON [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA]
(
	[CLIENT_ID] ASC,
	[IDX] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

/*---------------------------------------------------------------------------------------------------------------------*/

/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT 

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
         
  -- Error or raise error with severity 11 to 19 will be caught here          
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[UPDATE_CLAIM_HOLD_CLAIMS_CURRENTLY_HELD] TO [webuser]
GO
