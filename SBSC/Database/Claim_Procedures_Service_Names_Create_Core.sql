USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claim_Procedures_Service_Names_Create_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Claim_Procedures_Service_Names_Create_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Claim_Procedures_Service_Names_Create_Core] (
    @svcName                  nvarchar(100) = null
  , @inPerson                 bit  = 1
  , @teleHealth               bit  = 1 
  , @iep                      bit  = 0
  , @ifsp                     bit  = 0
  , @noPlan                   bit  = 0
  , @cybhi                    bit  = 0
  , @ruHealth                 bit  = 0
  , @nameIdIfspIepInPerson    bigint  output
  , @nameIdIfspIepTelehealth  bigint  output
  , @nameIdNoPlanInPerson     bigint  output
  , @nameIdNoPlanTelehealth   bigint  output
  , @nameIdCybhiInPerson      bigint  output
  , @nameIdCybhiTelehealth    bigint  output
  , @nameIdRuHealthInPerson   bigint  output
  , @nameIdRuHealthTelehealth bigint  output
)  
AS    
BEGIN    
   
/***************************************************************************    
 * Claim_Procedures_Service_Names_Create_Core */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    

BEGIN TRY    
   
declare @today                   as datetime      = null
declare @svcNameInPerson         as nvarchar(100) = null
declare @svcNameTeleHealth       as nvarchar(100) = null

/*-------------------------------    
 * Init     
 *------------------------------*/    

set @nameIdIfspIepInPerson    = null
set @nameIdIfspIepTelehealth  = null
set @nameIdNoPlanInPerson     = null
set @nameIdNoPlanTelehealth   = null
set @nameIdCybhiInPerson      = null
set @nameIdCybhiTelehealth    = null
set @nameIdRuHealthInPerson   = null
set @nameIdRuHealthTelehealth = null

set @today                   = GETDATE()    
set @svcName                 = trim(isnull(@svcName, N''))

/*-------------------------------    
 * Verify all parameters that    
 * indicate what type of operation    
 * to perform have been passed in    
 * and any other parms that are    
 * neccessary for proper operation    
 *------------------------------*/    
   
if (@svcName  = N'') RAISERROR ('Service name is required', 11, 1)

set @svcName           = trim(replace(@svcName,N'(via Telehealth',N''))
set @svcNameInPerson   = @svcName
set @svcNameTeleHealth = @svcName + N' (via Telehealth)'

/*-------------------------------    
 * Create new or retrieve existing    
 * IFSP/IEP service name ids    
 *------------------------------*/    

if ((@iep = 1) or (@ifsp = 1))
begin

  /* In person */

  if (@inPerson = 1)
  begin
    select top 1 
      @nameIdIfspIepInPerson = iep.IEP_IFSP_NAME_ID
    from dbo.CLAIM_IEPandIFSPNames as iep 
    where (iep.NAME = @svcNameInPerson)

    if (@nameIdIfspIepInPerson is null)
    begin
      insert into dbo.CLAIM_IEPandIFSPNames (NAME,IFSP,IEP) values (@svcNameInPerson,@ifsp,@iep)
      set @nameIdIfspIepInPerson = SCOPE_IDENTITY()
    end
  end /* In person */

  /* Telehealth */

  if (@teleHealth = 1)
  begin
    
	select top 1 
      @nameIdIfspIepTelehealth = iep.IEP_IFSP_NAME_ID
    from dbo.CLAIM_IEPandIFSPNames as iep 
    where (iep.NAME = @svcNameTeleHealth)

    if (@nameIdIfspIepTelehealth is null)
    begin
      insert into dbo.CLAIM_IEPandIFSPNames (NAME,IFSP,IEP) values (@svcNameTeleHealth,@ifsp,@iep)
      set @nameIdIfspIepTelehealth = SCOPE_IDENTITY()
    end
  end /* Telehealth */
end /* IEP or IFSP */


/*-------------------------------    
 * Create new or retrieve existing    
 * no plan service name ids    
 *------------------------------*/    

if (@noPlan = 1)
begin

  /* In person */

  if (@inPerson = 1)
  begin
    select top 1 
      @nameIdNoPlanInPerson = nplan.NO_PLAN_NAME_ID
    from dbo.CLAIM_NoPlanNames as nplan 
    where (nplan.NAME = @svcNameInPerson)

    if (@nameIdNoPlanInPerson is null)
    begin
      insert into dbo.CLAIM_NoPlanNames (NAME) values (@svcNameInPerson)
      set @nameIdNoPlanInPerson = SCOPE_IDENTITY()
    end
  end /* In person */

  /* Telehealth */

  if (@teleHealth = 1)
  begin
    select top 1 
      @nameIdNoPlanTelehealth = nplan.NO_PLAN_NAME_ID
    from dbo.CLAIM_NoPlanNames as nplan 
    where (nplan.NAME = @svcNameTeleHealth)

    if (@nameIdNoPlanTelehealth is null)
    begin
      insert into dbo.CLAIM_NoPlanNames (NAME) values (@svcNameTeleHealth)
      set @nameIdNoPlanTelehealth = SCOPE_IDENTITY()
    end
  end /* Telehealth */
end /* No Plan */
     
/*-------------------------------    
 * Create new or retrieve existing    
 * cybhi service name ids
 *------------------------------*/    

if (@cybhi = 1)
begin

  /* In person */

  if (@inPerson = 1)
  begin
    select top 1 
      @nameIdCybhiInPerson = cybhi.CYBHI_NAME_ID
    from dbo.CLAIM_CYBHI_Names as cybhi 
    where (cybhi.NAME = @svcNameInPerson)

    if (@nameIdCybhiInPerson is null)
    begin
      insert into dbo.CLAIM_CYBHI_Names (NAME) values (@svcNameInPerson)
      set @nameIdCybhiInPerson = SCOPE_IDENTITY()
    end
  end /* In person */

  /* Telehealth */

  if (@teleHealth = 1)
  begin
    select top 1 
      @nameIdCybhiTelehealth = cybhi.CYBHI_NAME_ID
    from dbo.CLAIM_CYBHI_Names as cybhi 
    where (cybhi.NAME = @svcNameTeleHealth)

    if (@nameIdCybhiTelehealth is null)
    begin
      insert into dbo.CLAIM_CYBHI_Names(NAME) values (@svcNameTeleHealth)
      set @nameIdCybhiTelehealth = SCOPE_IDENTITY()
    end
  end /* Telehealth */
end /* CYBHI */
	 
/*-------------------------------    
 * Create new or retrieve existing    
 * ru health service name ids
 *------------------------------*/    

if (@ruHealth = 1)
begin

  /* In person */

  if (@inPerson = 1)
  begin
    select top 1 
      @nameIdRuHealthInPerson = cru.RU_HEALTH_NAME_ID
    from dbo.CLAIM_RU_HEALTH_Names as cru 
    where (cru.NAME = @svcNameInPerson)

    if (@nameIdRuHealthInPerson is null)
    begin
      insert into dbo.CLAIM_RU_HEALTH_Names (NAME) values (@svcNameInPerson)
      set @nameIdRuHealthInPerson = SCOPE_IDENTITY()
    end
  end /* In person */

  /* Telehealth */

  if (@teleHealth = 1)
  begin
    select top 1 
      @nameIdRuHealthTelehealth = cru.RU_HEALTH_NAME_ID
    from dbo.CLAIM_RU_HEALTH_Names as cru 
    where (cru.NAME = @svcNameTeleHealth)

    if (@nameIdRuHealthTelehealth is null)
    begin
      insert into dbo.CLAIM_RU_HEALTH_Names(NAME) values (@svcNameTeleHealth)
      set @nameIdRuHealthTelehealth = SCOPE_IDENTITY()
    end
  end /* Telehealth */
end /* RU Health */
	   
/*-------------------------------    
 * If we reach this point    
 * everything is OK, exit   
 *------------------------------*/    
   
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

 
