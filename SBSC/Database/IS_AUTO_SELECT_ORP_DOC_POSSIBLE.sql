USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_AUTO_SELECT_ORP_DOC_POSSIBLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_AUTO_SELECT_ORP_DOC_POSSIBLE
GO    

CREATE FUNCTION [dbo].[IS_AUTO_SELECT_ORP_DOC_POSSIBLE] ( @groupSvcClassNameID bigint )
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN
  /* All group families except health services can possibly have orps be autoselected */
  if (@groupSvcClassNameID != 3) return 1
  return 0
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_AUTO_SELECT_ORP_DOC_POSSIBLE] TO [webuser]
GO
