USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE] ( 
	     @clientID          Bigint 
	   , @fiscalYearID      Bigint
	   , @active            Bit
	   , @recID             Bigint   
)
     
RETURNS TABLE  

AS RETURN(

  select 
    cto.*
  , grossRatio        = (isnull(cto.grossCosts  , 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID))
  , expendituresRatio = (isnull(cto.expenditures, 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID))
  , grossRatioStr        = FORMAT((isnull(cto.grossCosts  , 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID)), 'C2')
  , expendituresRatioStr = FORMAT((isnull(cto.expenditures, 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID)), 'C2')
  from dbo.CRCS_TRANSPORTATION_OTHER_COSTS as cto
  where (cto.clientID     = @clientID)
    and (cto.fiscalYearID = @fiscalYearID)
    and ((@recID  is null) or (cto.id     = @recID))
	and ((@active is null) or (cto.active = @active))
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_TRANSPORTATION_OTHER_COSTS_VIEW_CORE] TO [webuser]
GO