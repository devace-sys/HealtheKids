USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_PATIENT_POSSIBLY_LEA_BOP_ELIG
GO    

CREATE FUNCTION [dbo].[IS_PATIENT_POSSIBLY_LEA_BOP_ELIG] (
    @BIC          nvarchar(14)
  , @ffpQualified bit
)   
RETURNS BIT
WITH SCHEMABINDING 
AS
BEGIN 
  set @ffpQualified = isnull(@ffpQualified,1)  /* Assume true if we dont have a value for now */
  if (@ffpQualified = 0) return 0              /* If we have a false from DHCS then patient is not eligible regardless of Medi-Cal beneficiary status */
  set @BIC = trim(isnull(@bic,N''))            /* Cleanup incoming value for BIC */
  if (len(@BIC) != 14) return 0                /* BIC has to be 14 characters to be possibly valid */
  return 1                                     /* If we reach this point patient is possibly LEA BOP eligible */
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_PATIENT_POSSIBLY_LEA_BOP_ELIG] TO [webuser]
GO
