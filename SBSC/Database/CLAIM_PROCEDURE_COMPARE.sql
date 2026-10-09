USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURE_COMPARE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURE_COMPARE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIM_PROCEDURE_COMPARE] (
   
    @procA AS nchar(10)
   ,@mod1A AS nchar(10)
   ,@mod2A AS nchar(10)
   ,@mod3A AS nchar(10)
   ,@mod4A AS nchar(10)
   
   ,@procB AS nchar(10)
   ,@mod1B AS nchar(10)
   ,@mod2B AS nchar(10)
   ,@mod3B AS nchar(10)
   ,@mod4B AS nchar(10)
)

RETURNS bit 
WITH SCHEMABINDING 
AS    
BEGIN
  
/***************************************************************************    
 * CLAIM_PROCEDURE_COMPARE */    
/**    
 * Compares proc mod combos
 * Returns 1 if equal 0 if not
 ***************************************************************************/  

declare @prA as nvarchar(10)
declare @m1A as nvarchar(10)
declare @m2A as nvarchar(10)
declare @m3A as nvarchar(10)
declare @m4A as nvarchar(10)

declare @prB as nvarchar(10)
declare @m1B as nvarchar(10)
declare @m2B as nvarchar(10)
declare @m3B as nvarchar(10)
declare @m4B as nvarchar(10)

declare @modsA as table (
  modX nvarchar(10)
)

declare @modsB as table (
  modX nvarchar(10)
)

declare @modsAStr as nvarchar(max) = N''
declare @modsBStr as nvarchar(max) = N''

/* Convert all proc codes and mods to nvarchars so we dont have to deal with padding */

set @prA = trim(convert(nvarchar(10),upper(isnull(@procA,N''))))
set @m1A = trim(convert(nvarchar(10),upper(isnull(@mod1A,N''))))
set @m2A = trim(convert(nvarchar(10),upper(isnull(@mod2A,N''))))
set @m3A = trim(convert(nvarchar(10),upper(isnull(@mod3A,N''))))
set @m4A = trim(convert(nvarchar(10),upper(isnull(@mod4A,N''))))
  
set @prB = trim(convert(nvarchar(10),upper(isnull(@procB,N''))))
set @m1B = trim(convert(nvarchar(10),upper(isnull(@mod1B,N''))))
set @m2B = trim(convert(nvarchar(10),upper(isnull(@mod2B,N''))))
set @m3B = trim(convert(nvarchar(10),upper(isnull(@mod3B,N''))))
set @m4B = trim(convert(nvarchar(10),upper(isnull(@mod4B,N''))))

/* If procedure code is different stop right here and exit, procs are different */

if (@prA != @prB) return 0

/* If procedure code is same and all mods are the same we can exit, procs are the same */

if ((@m1A = @m1B) and (@m2A = @m2B) and (@m3A = @m3B) and (@m4A = @m4B)) return 1

/* Now we need to handle cases where the mods are in different orders */

/* Create strings where we aggregate the mods together SORTED by mod so we can easily compare */

insert into @modsA values (@m1A)
insert into @modsA values (@m2A)
insert into @modsA values (@m3A)
insert into @modsA values (@m4A)

select 
  @modsAStr = STRING_AGG (t1.modx, N' ') WITHIN GROUP (ORDER BY t1.modx ASC)
from @modsA as t1

insert into @modsB values (@m1B)
insert into @modsB values (@m2B)
insert into @modsB values (@m3B)
insert into @modsB values (@m4B)

select 
  @modsBStr = STRING_AGG (t1.modx, N' ') WITHIN GROUP (ORDER BY t1.modx ASC)
from @modsB as t1

/* If both strings are equal then exit, procs are the same. */

if (@modsAStr = @modsBStr) return 1

return 0

end    
GO
