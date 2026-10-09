USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_PLACE_ID_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_PLACE_ID_STRING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_PLACE_ID_STRING]
(    
    @placeClass bigint
  , @entityID1  bigint
  , @entityID2  bigint
  , @entityID3  bigint 
  , @returnEmptyIfAnyEntityParmsAreNull bit = 0
) 
RETURNS varchar(255)
WITH SCHEMABINDING
AS     
BEGIN    

if (@returnEmptyIfAnyEntityParmsAreNull = 1)
begin
  if (@entityID1 is null) return ''
  if (@entityID2 is null) return ''
  if (@entityID3 is null) return ''
end

return     + convert(varchar,@placeClass)
           + '-'
           + convert(varchar,@entityID1)
           + '-'
           + convert(varchar,@entityID2)
           + '-'
           + convert(varchar,@entityID3)
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_PLACE_ID_STRING] TO [webuser]
GO