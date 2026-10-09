USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_IS_POTENTIAL_ORP_FOR_GROUP_SERVICE_CLASS_NAME_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_IS_POTENTIAL_ORP_FOR_GROUP_SERVICE_CLASS_NAME_ID
GO    

CREATE FUNCTION [dbo].[PRACTITIONER_IS_POTENTIAL_ORP_FOR_GROUP_SERVICE_CLASS_NAME_ID] (
    @clientID             bigint
  , @pracID               bigint
  , @groupSvcClassNameID  bigint
)
RETURNS BIT
AS
BEGIN
  
  if (@clientID            is null) return null
  if (@pracID              is null) return null
  if (@groupSvcClassNameID is null) return null

  if exists (select top 1 t1.PRACTITIONER_ID from dbo.PRACTITIONERS_DATA_CORE  (6, @clientID, null, null, @groupSvcClassNameID) as t1 where (t1.PRACTITIONER_ID = @pracID))   
    return 1
  
  return 0
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[PRACTITIONER_IS_POTENTIAL_ORP_FOR_GROUP_SERVICE_CLASS_NAME_ID] TO [webuser]
GO
