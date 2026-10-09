USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE] (
    @userID        BIGINT    
  , @userGroup     INT  
  , @userRank      INT 
  , @selectionIDs  varchar(max)
  , @authorized    BIT
  , @editDelReason VARCHAR(7000)
  , @recordID      BIGINT        OUTPUT
  , @spDetails     VARCHAR(8000) OUTPUT
  , @saveType      INT           OUTPUT)  
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE */    
/**    
 * 
 ***************************************************************************/        

/*============================================================
 * Variables and init
 *============================================================*/  

declare @tranOpen    as bit
declare @minIDX      as bigint 
declare @maxIDX      as bigint
declare @curIDX      as bigint
declare @selectionID as varchar(8000)

set @tranOpen  = 0
set @recordID  = 0
set @spDetails = ''
set @saveType  = 0

declare @selections as table (
    idx         bigint identity(1,1)
  , selectionID varchar(8000)
)

insert into @selections
select 
  selectionID = t1.value 
from STRING_SPLIT(@selectionIDs,',') as t1

select @minIDX = min(idx), @maxIDX = max(idx) from @selections
set @curIDX = @minIDX

BEGIN TRY
BEGIN TRANSACTION

set @TranOpen = 1

while (@curIDX <= @maxIDX)
begin
  
  select top 1 
    @selectionID = t1.selectionID 
  from @selections as t1
  where t1.idx = @curIDX
   
  exec dbo.CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE_CORE
      @userID
    , @userGroup
    , @userRank
    , @selectionID  
    , @authorized   
    , @editDelReason
	, @recordID  OUTPUT
    , @spDetails OUTPUT
    , @saveType  OUTPUT

  set @curIDX = @curIDX + 1

end

/*============================================================
 * All done, commit changes and get out
 *============================================================*/  
    
COMMIT TRANSACTION    
SET @TranOpen = 0    
RETURN(0)    
END TRY  

/*============================================================
 * Exception handling
 *============================================================*/      

BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
      
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
   
  -- Only send really bad exceptions back with sp details

  if (@ErrorSeverity > 11)    
    SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLAIM_RETROACTIVE_FOR_SPA_CLIENT_AUTHORIZATION_SAVE] TO [webuser]
GO
