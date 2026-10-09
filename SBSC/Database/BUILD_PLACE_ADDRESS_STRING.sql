USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_PLACE_ADDRESS_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_PLACE_ADDRESS_STRING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_PLACE_ADDRESS_STRING]
(
    @address1                   varchar(1000)
  , @address2                   varchar(1000)
  , @city                       varchar(100)
  , @state                      varchar(2)
  , @zip5                       varchar(5)
  , @zip4                       varchar(4)
  , @showNoAddressMessage       bit = 0
) 
RETURNS varchar(2500)
WITH SCHEMABINDING
AS     
BEGIN    

  declare @addressLine as varchar(2500)
  
  set @address1 = ltrim(rtrim(isnull(@address1  ,'')))
  set @address2 = ltrim(rtrim(isnull(@address2  ,'')))
  set @city     = ltrim(rtrim(isnull(@city      ,'')))
  set @state    = ltrim(rtrim(isnull(@state     ,'')))
  set @zip5     = ltrim(rtrim(isnull(@zip5      ,'')))
  set @zip4     = ltrim(rtrim(isnull(@zip4      ,'')))
    
  set @addressLine = ltrim ( rtrim (
      case when (@address1 != '') then         @address1  else '' end
    + case when (@address2 != '') then ' '   + @address2  else '' end
    + case when (@city     != '') then ', '  + @city      else '' end
    + case when (@state    != '') then ', '  + @state     else '' end
    + case when (@zip5     != '') then ', '  + @zip5      else '' end
    + case when (@zip4     != '') then '-'   + @zip4      else '' end 
  ))
  if (@showNoAddressMessage = 1)
  begin
    if (len(@addressLine) = 0) set @addressLine = 'No address data is stored in SpEdCare'
  end

  return @addressLine

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_PLACE_ADDRESS_STRING] TO [webuser]
GO