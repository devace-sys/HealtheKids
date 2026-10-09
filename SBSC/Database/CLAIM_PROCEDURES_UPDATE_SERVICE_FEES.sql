USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURES_UPDATE_SERVICE_FEES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_PROCEDURES_UPDATE_SERVICE_FEES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE [dbo].[CLAIM_PROCEDURES_UPDATE_SERVICE_FEES] (
    @procModCombosStr  varchar(8000)
  , @serviceFee        money
  , @over17Fee         money
  , @under18Fee        money
  , @billingProgramID  tinyint
  , @validate          bit
  , @jsonData varchar(max) output
)    
AS    
BEGIN    
   
/***************************************************************************    
 * CLAIM_PROCEDURES_UPDATE_SERVICE_FEES */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    
      
declare @tranOpen      as bit
declare @today         as datetime 
declare @over17FeeStr  as nchar(10)
declare @under18FeeStr as nchar(10)
declare @tcmFeeStr     as nchar(10)
declare @zeroFeeStr    as nchar(10)

declare @jsonDataProcs  as varchar(max)
declare @jsonDataGroups as varchar(max)

declare @procsToUpdate as table (
    PROCEDURE_ID         bigint
  , PROCEDURE_NAME       nvarchar(50)
  , PROC_MOD_COMBO       varchar(50)

  , SERVICE_FEE      money
  , OVER_17_FEE      nchar(10)
  , UNDER_18_FEE     nchar(10)
  , TCM_LOW_RATE     nchar(10)
  , TCM_MEDIUM_RATE  nchar(10)
  , TCM_HIGH_RATE    nchar(10)
  
  , NEW_SERVICE_FEE      money
  
  , NEW_OVER_17_FEE      nchar(10)
  , NEW_UNDER_18_FEE     nchar(10)
  
  , NEW_TCM_LOW_RATE     nchar(10)
  , NEW_TCM_MEDIUM_RATE  nchar(10)
  , NEW_TCM_HIGH_RATE    nchar(10)
  
  , DATE_MODIFIED_STR    varchar(50)
 
  , EFFECTIVE_DATE_STR   varchar(50)
  , EXPIRATION_DATE_STR  varchar(50)
  , DATA_HAS_BEEN_UPDATED bit
)

declare @groupsInvolved as table (
    GROUP_ID   bigint 
  , GROUP_NAME nvarchar(max)
)

set @jsonDataProcs   = ''
set @jsonDataGroups  = ''
set @jsonData = '{' 
                 + '"procs":[]'
			     + ',"groups":[]'
			     + '}'
set @today           = GETDATE()    
set @tranOpen        = 0

BEGIN TRY    

set @procModCombosStr = trim(isnull(@procModCombosStr,''))
set @serviceFee       = isnull(@serviceFee, 0.00)
set @over17Fee        = isnull(@over17Fee,  0.00)
set @under18Fee       = isnull(@under18Fee, 0.00)

set @over17FeeStr  = convert (nchar(10),@over17Fee)
set @under18FeeStr = convert (nchar(10),@under18Fee)
set @tcmFeeStr     = convert (nchar(10),@serviceFee)
set @zeroFeeStr    = N'0.00'

if (@procModCombosStr = '') 
begin
  return(0)
end

insert into @procsToUpdate
select distinct
  q1.*
from
(
  select 
      t1.PROCEDURE_ID
    , t1.PROCEDURE_NAME

    , PROC_MOD_COMBO = dbo.RPT_PROC_MOD_COMBO ( t1.PROCEDURE_CODE
                                               ,t1.PROCEDURE_MODIFIER_1
                                               ,t1.PROCEDURE_MODIFIER_2
                                               ,t1.PROCEDURE_MODIFIER_3
                                               ,t1.PROCEDURE_MODIFIER_4)    
  
    , SERVICE_FEE         = t1.SERVICE_FEE
    , OVER_17_FEE         = t1.OVER_17_FEE
    , UNDER_18_FEE        = t1.UNDER_18_FEE

    , TCM_LOW_RATE        = t1.TCM_LOW_RATE
    , TCM_MEDIUM_RATE     = t1.TCM_MEDIUM_RATE
    , TCM_HIGH_RATE       = t1.TCM_HIGH_RATE

    , NEW_SERVICE_FEE         = @serviceFee
    , NEW_OVER_17_FEE         = @over17FeeStr
    , NEW_UNDER_18_FEE        = @under18FeeStr
    , NEW_TCM_LOW_RATE        = iif ((t1.SERVICE_TYPE_ID = 4),@tcmFeeStr,@zeroFeeStr)
    , NEW_TCM_MEDIUM_RATE     = iif ((t1.SERVICE_TYPE_ID = 4),@tcmFeeStr,@zeroFeeStr)
    , NEW_TCM_HIGH_RATE       = iif ((t1.SERVICE_TYPE_ID = 4),@tcmFeeStr,@zeroFeeStr)
    , DATE_MODIFIED_STR       = dbo.RPT_DATE_FMT(t1.DATE_MODIFIED)
    , EFFECTIVE_DATE_STR      = dbo.RPT_DATE_FMT(t1.DATE_EFFECTIVE)
    , EXPIRATION_DATE_STR     = dbo.RPT_DATE_FMT(t1.DATE_EXPIRES)
    , DATA_HAS_BEEN_UPDATED   = 0

  from dbo.CLAIM_PROCEDURES_THAT_HAVE_PROC_MOD_COMBOS_VIEW_CORE(@procModCombosStr,@billingProgramID) as t1
  join dbo.CLAIM_Allowed_Procedures as cap on cap.PROCEDURE_ID = t1.PROCEDURE_ID
  join dbo.GROUP_Group              as gg  on gg.GROUP_ID = cap.GROUP_ID
  where 
        (t1.Active = 1)
    and (gg.ACTIVE = 1)

) as q1

insert into @groupsInvolved
select distinct 
    gg.GROUP_ID
  , gg.GROUP_NAME
from @procsToUpdate               as ptu
join dbo.CLAIM_Allowed_Procedures as cap on cap.PROCEDURE_ID = ptu.PROCEDURE_ID
join dbo.GROUP_Group              as gg  on gg.GROUP_ID = cap.GROUP_ID
where 
  (gg.ACTIVE = 1)

if (@validate = 0) 
begin

  set @tranOpen = 1
  begin transaction

  update cp
  set 
      cp.DATE_MODIFIED   = @today
    , cp.SERVICE_FEE     = ptu.NEW_SERVICE_FEE
    , cp.OVER_17_FEE     = ptu.NEW_OVER_17_FEE
    , cp.UNDER_18_FEE    = ptu.NEW_UNDER_18_FEE
    , cp.TCM_LOW_RATE    = ptu.NEW_TCM_LOW_RATE
    , cp.TCM_MEDIUM_RATE = ptu.NEW_TCM_MEDIUM_RATE
    , cp.TCM_HIGH_RATE   = ptu.NEW_TCM_HIGH_RATE
  from @procsToUpdate       as ptu 
  join dbo.CLAIM_Procedures as cp on cp.PROCEDURE_ID = ptu.PROCEDURE_ID

  update @procsToUpdate
  set 
      DATE_MODIFIED_STR      = dbo.RPT_DATE_FMT(@today)
	, DATA_HAS_BEEN_UPDATED  = 1

  commit transaction
  set @tranOpen = 0
end

set @jsonDataProcs = (
  select 
    t1.* 
  from @procsToUpdate as t1 
  join dbo.CLAIM_Procedures as cp on cp.PROCEDURE_ID = t1.PROCEDURE_ID
  order by 
    t1.PROC_MOD_COMBO asc
	,cp.DATE_EFFECTIVE desc
	,cp.DATE_EXPIRES desc
	FOR JSON AUTO, INCLUDE_NULL_VALUES 
)     

set @jsonDataGroups = (
  select t1.* from @groupsInvolved as t1 FOR JSON AUTO, INCLUDE_NULL_VALUES
)

set @jsonData = '{' 
              + '"procs":'  + isnull(@jsonDataProcs,'[]')
			  + ',"groups":' + isnull(@jsonDataGroups,'[]')
			  + '}'

RETURN(0)    
END TRY    
   
BEGIN CATCH    
   
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
 
  if (@tranOpen = 1) rollback transaction

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

GRANT EXECUTE ON  [dbo].[CLAIM_PROCEDURES_UPDATE_SERVICE_FEES] TO [webuser]
GO
