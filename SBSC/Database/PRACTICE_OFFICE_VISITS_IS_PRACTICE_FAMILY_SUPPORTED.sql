USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED
/**/    
 * Is the practice family supported for this system
 ***************************************************************************/   

CREATE FUNCTION [dbo].[PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED] (
  @groupSvcClassNameID bigint
)
RETURNS BIT                                    
AS    
BEGIN    
  set @groupSvcClassNameID = isnull(@groupSvcClassNameID,-1)
  if (@groupSvcClassNameID in (3)) return 1
  return 0
END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_IS_PRACTICE_FAMILY_SUPPORTED] TO [webuser]

GO