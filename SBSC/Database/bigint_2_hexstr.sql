USE [spedmon]
GO

IF  EXISTS
  (SELECT * FROM sys.objects
   WHERE object_id = OBJECT_ID(N'[dbo].[bigint_2_hexstr]')
     AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')
   )
DROP FUNCTION [dbo].[bigint_2_hexstr]

GO  
CREATE FUNCTION [dbo].[bigint_2_hexstr] (@value bigint, @len int)
returns varchar(16) WITH SCHEMABINDING
as
begin
return
    substring (
              CONVERT(
                VARCHAR(16),
                CONVERT(VARBINARY(8), @value),
                2
              ),
              17 - @len, /*1-indexed, 16 max len; offset (17 - @len) */
              @len
          )
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[bigint_2_hexstr] TO [webuser]
GO
