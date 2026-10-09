USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_VALID_FY_ID_AND_QTR_NUM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_VALID_FY_ID_AND_QTR_NUM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[IS_VALID_FY_ID_AND_QTR_NUM](@fYID bigint, @qtrNum int) 
RETURNS BIT
WITH SCHEMABINDING
AS     
BEGIN
    if (@fYID is null or @qtrNum is null)
	begin
	 return 0
	end

	if exists(
		select top 1 fq.ID 
		from dbo.COMPANY_FISCAL_QUARTERS as fq
		where (fq.FY_ID = @fyID and fq.QTR = @qtrNum)
	)
	begin
		return 1
	end	
	
	return 0 	
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[IS_VALID_FY_ID_AND_QTR_NUM] TO [webuser]
GO
