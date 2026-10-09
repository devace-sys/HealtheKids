USE [spedmon]
GO

IF  EXISTS
  (SELECT * FROM sys.objects
   WHERE object_id = OBJECT_ID(N'[dbo].[hexstr_2_bigint]')
     AND type in (N'FN', N'IF', N'TF', N'FS', N'FT')
   )
DROP FUNCTION [dbo].[hexstr_2_bigint]
GO

CREATE FUNCTION [dbo].[hexstr_2_bigint] (@value varchar(16))
returns bigint WITH SCHEMABINDING
as
begin
return
   convert (
              bigint,
              convert(
                varbinary(8),
                CASE WHEN len(@value) % 2 = 1 THEN '0x0' ELSE '0x' END
                  +
                @value,
                1
              )
            )
END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON [dbo].[hexstr_2_bigint] TO [webuser]

GO
