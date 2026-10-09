USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.HAS_MOD_IN_SLOT_NUM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.HAS_MOD_IN_SLOT_NUM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[HAS_MOD_IN_SLOT_NUM](
 @hasMod   nchar(10)
,@slot1Mod nchar(10)
,@slot2Mod nchar(10)
,@slot3Mod nchar(10)
,@slot4Mod nchar(10)
) 
RETURNS SMALLINT
WITH SCHEMABINDING 
AS     
BEGIN      
  set @hasMod   = upper(trim(isnull(@hasMod,  N'')))
  set @slot1Mod = upper(trim(isnull(@slot1Mod,N'')))
  set @slot2Mod = upper(trim(isnull(@slot2Mod,N'')))
  set @slot3Mod = upper(trim(isnull(@slot3Mod,N'')))
  set @slot4Mod = upper(trim(isnull(@slot4Mod,N'')))  
  if (@hasMod = @slot1Mod) return 1
  if (@hasMod = @slot2Mod) return 2
  if (@hasMod = @slot3Mod) return 3
  if (@hasMod = @slot4Mod) return 4
  return 0
  
END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[HAS_MOD_IN_SLOT_NUM] TO [webuser]
GO
