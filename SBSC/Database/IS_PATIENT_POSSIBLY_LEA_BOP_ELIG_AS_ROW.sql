USE SPEDMON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_PATIENT_POSSIBLY_LEA_BOP_ELIG_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_PATIENT_POSSIBLY_LEA_BOP_ELIG_AS_ROW
GO    

CREATE FUNCTION [dbo].[IS_PATIENT_POSSIBLY_LEA_BOP_ELIG_AS_ROW] (
    @BIC          nvarchar(14)
  , @ffpQualified bit
)   
RETURNS TABLE
WITH SCHEMABINDING 
AS
RETURN
(
  select top 1
    isElig = convert(bit,(iif(((q1.lenOfBic = 14) and (q1.ffpQualified = 1)),1,0)))
  from 
  (
    select top 1 
	    ffpQualified = isnull(@ffpQualified,1)       /* Assume true if we dont have a value for now */
	  , lenOfBic     = len(trim(isnull(@bic,N'')))   /* BIC has to be 14 characters to be possibly valid */
  ) as q1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[IS_PATIENT_POSSIBLY_LEA_BOP_ELIG_AS_ROW] TO [webuser]
GO
