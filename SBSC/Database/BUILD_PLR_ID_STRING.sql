USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_PLR_ID_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_PLR_ID_STRING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_PLR_ID_STRING]
(    
      @clientID           		Bigint
	, @patID              		Bigint
	, @pracID             		Bigint
	, @pracGroupID       		Bigint
	, @pracGroupFamilyID		Bigint
	, @svcTypeID         		Bigint
	, @holdCode           		Int
	, @svcDOSStart       		DateTime
	, @svcDOSEnd         		DateTime
) 
RETURNS varchar(256)
WITH SCHEMABINDING
AS     
BEGIN    

return     + convert(varchar(20), @clientID)          + '-'
           + convert(varchar(20), @patID)             + '-'
           + convert(varchar(20), @pracID)            + '-'
           + convert(varchar(20), @pracGroupID)       + '-'
           + convert(varchar(20), @pracGroupFamilyID) + '-'
           + convert(varchar(20), @svcTypeID)         + '-'
           + convert(varchar(20), @holdCode)          + '-'
           + convert(varchar, @svcDOSStart, 23)       + '-'
           + convert(varchar, @svcDOSEnd, 23)
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_PLR_ID_STRING] TO [webuser]
GO