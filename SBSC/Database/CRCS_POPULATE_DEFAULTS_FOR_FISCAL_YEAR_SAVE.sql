USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_POPULATE_DEFAULTS_FOR_FISCAL_YEAR_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.CRCS_POPULATE_DEFAULTS_FOR_FISCAL_YEAR_SAVE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE PROCEDURE [dbo].[CRCS_POPULATE_DEFAULTS_FOR_FISCAL_YEAR_SAVE]  ( 
	@clientID Bigint
)
AS    
BEGIN            
 
SET NOCOUNT ON    
 
DECLARE @TranOpen            AS BIT  
DECLARE @today               as DATETIME = GETDATE()
 
BEGIN TRY    
 
/*-------------------------------    
 * Init our output parameters    
 *------------------------------*/    
 
SET @today    = GETDATE()    
 
/*============================================================
 * Write data
 *============================================================*/  
 
BEGIN TRANSACTION    
 
	SET @TranOpen = 1     
	
	-------------------------------------------------------------------------------------------
	--	CRCS transportation personnel costs defaults
	-------------------------------------------------------------------------------------------
  	;with combo_personal_costs_cte as (
		select 
			clientID = cc.CLIENT_ID
		  , ct.jobCategory
		  , ct.displayOrder
		  , fyID = cfy.ID
		from dbo.CLIENTS_Client as cc
		cross join dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_DEFAULTS as ct
		cross join [dbo].[COMPANY_FISCAL_YEARS_VIEW_CORE] (    
					  2       
					, 0    
					, @today            
					, null           
			) as cfy
		where ((@clientID is null) or (cc.CLIENT_ID = @clientID))
	)

	Insert into dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS (           
			  clientID                          
			, fiscalYearID
			, jobCategory
			, totalSalaries
			, totalBenefits
			, fedResourceOrGrant                       
			, created                
			, createdBy
			, systemGenerated
			, displayOrder
	) 
	select
			  cc.clientID                                 
			, cc.fyID               
			, cc.jobCategory       
			, null     
			, null		
			, null
			, @today
			, null
			, 1
			, cc.displayOrder
	from combo_personal_costs_cte as cc  
	where not exists (
		select
			id
		from dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE ( 
			cc.clientID         
		, cc.fyID     
		, null           
		, null
		) as ct
		where ct.systemGenerated = 1         
	)

	-------------------------------------------------------------------------------------------
	--	CRCS transportation other costs defaults
	-------------------------------------------------------------------------------------------
	;with combo_other_costs_cte as (
	select 
		clientID = cc.CLIENT_ID
		, ct.[description]
		, ct.displayOrder
		, fyID = cfy.ID
	from dbo.CLIENTS_Client as cc
	cross join dbo.CRCS_TRANSPORTATION_OTHER_COSTS_DEFAULTS as ct
	cross join [dbo].[COMPANY_FISCAL_YEARS_VIEW_CORE] (    
					2       
				, 0    
				, @today            
				, null           
		) as cfy
	)

	Insert into dbo.CRCS_TRANSPORTATION_OTHER_COSTS (           
          clientID                          
        , fiscalYearID                      
        , description  
		, grossCosts   
		, expenditures 
        , created                
        , createdBy
		, systemGenerated
		, displayOrder
	)
	
	select 
		  cc.clientID                                 
		, cc.fyID               
		, cc.[description]  
		, null     
		, null		
		, @today
		, null
		, 1
		, cc.displayOrder
	from combo_other_costs_cte as cc  
	where not exists 
			(select top 1
				id
			from dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE ( 
			  cc.clientID         
			, cc.fyID     
			, null           
			, null
			) as ct
			where ct.systemGenerated = 1      
	) 
 
 
/*-------------------------------    
 * If we reach this point    
 * everything is OK, commit our    
 * changes and exit    
 *------------------------------*/    
 
COMMIT TRANSACTION    
SET @TranOpen = 0    
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
 
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
 
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
 
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
 
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
 
GRANT EXECUTE ON  [dbo].[CRCS_POPULATE_DEFAULTS_FOR_FISCAL_YEAR_SAVE] TO [webuser]
GO