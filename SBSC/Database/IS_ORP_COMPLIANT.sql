USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_ORP_COMPLIANT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_ORP_COMPLIANT
GO    

CREATE FUNCTION [dbo].[IS_ORP_COMPLIANT] (
    @orpRequired       bit
  , @orpNpiValid       bit
  , @orpIsValidMcalOrp bit
)
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
   set @orpRequired       = isnull (@orpRequired,       0)
   set @orpNpiValid       = isnull (@orpNPIValid,       0)
   set @orpIsValidMcalOrp = isnull (@orpIsValidMcalOrp, 0)
   
   if (@orpRequired = 0)                                return 1
   if ((@orpNPIValid = 1) and (@orpIsValidMcalOrp = 1)) return 1
   return 0
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_ORP_COMPLIANT] TO [webuser]
GO
