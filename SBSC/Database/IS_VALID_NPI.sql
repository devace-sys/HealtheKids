USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_VALID_NPI') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_VALID_NPI
GO    

CREATE FUNCTION [dbo].[IS_VALID_NPI] (
    @npi varchar(50)
)
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
   return convert (bit,case when (len(ltrim(rtrim(isnull(@npi,'')))) = 10) then 1 else 0 end)
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_VALID_NPI] TO [webuser]
GO
