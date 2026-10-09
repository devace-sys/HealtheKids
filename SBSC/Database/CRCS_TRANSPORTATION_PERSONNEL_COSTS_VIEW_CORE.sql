USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE] ( 
	     @clientID          Bigint 
	   , @fiscalYearID      Bigint
	   , @active            Bit
	   , @recID             Bigint   
)
     
RETURNS TABLE  

AS RETURN(

  select 
	 ctpc.*
   , salaryRatio      = (isnull(ctpc.totalSalaries     , 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID))
   , benefitsRatio    = (isnull(ctpc.totalBenefits     , 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID))
   , federalRatio     = (isnull(ctpc.fedResourceOrGrant, 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID))
   , salaryRatioStr   = FORMAT((isnull(ctpc.totalSalaries     , 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID)), 'C2')
   , benefitsRatioStr = FORMAT((isnull(ctpc.totalBenefits     , 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID)), 'C2')
   , federalRatioStr  = FORMAT((isnull(ctpc.fedResourceOrGrant, 0) * dbo.CALC_CRCS_TRANSPORTATION_RATE_AMOUNT(@clientID, @fiscalYearID)), 'C2')
  from dbo.CRCS_TRANSPORTATION_PERSONNEL_COSTS as ctpc
  where (ctpc.clientID     = @clientID)
    and (ctpc.fiscalYearID = @fiscalYearID)
    and ((@recID  is null) or (ctpc.id     = @recID))
	and ((@active is null) or (ctpc.active = @active))
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_TRANSPORTATION_PERSONNEL_COSTS_VIEW_CORE] TO [webuser]
GO