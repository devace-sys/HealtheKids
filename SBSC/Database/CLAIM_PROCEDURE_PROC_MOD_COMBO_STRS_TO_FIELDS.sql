USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURE_PROC_MOD_COMBO_STRS_TO_FIELDS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURE_PROC_MOD_COMBO_STRS_TO_FIELDS 
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLAIM_PROCEDURE_PROC_MOD_COMBO_STRS_TO_FIELDS] (
  @procModCombosStr as varchar(8000)
)

returns @procModCombos table (
    IDX                  bigint identity(1,1)
  , PROCEDURE_CODE       nchar(10)
  , PROCEDURE_MODIFIER_1 nchar(10)
  , PROCEDURE_MODIFIER_2 nchar(10)
  , PROCEDURE_MODIFIER_3 nchar(10)
  , PROCEDURE_MODIFIER_4 nchar(10)
  , NUM_OF_MODS          int
)
  
as
begin

declare @procModCombosStrParts as table (
   id   bigint
  ,part varchar(8000)
)

declare @procModComboStrParts as table (
    id   bigint
  , part varchar(8000)
)

declare @minIdx          as bigint
declare @maxIdx          as bigint
declare @curIdx          as bigint
declare @procModComboStr as varchar(8000)
declare @proc            as nchar(10)
declare @mod1            as nchar(10)
declare @mod2            as nchar(10)
declare @mod3            as nchar(10)
declare @mod4            as nchar(10)
declare @numMods         as int

insert into @procModCombosStrParts
select 
   t1.id
 , part = trim(REPLACE(REPLACE(REPLACE(t1.part,' ','CHAR(17)CHAR(18)'),'CHAR(18)CHAR(17)',''),'CHAR(17)CHAR(18)',' ')) /* Guard against extra spaces.  Courtesey of https://stackoverflow.com/a/2455869 */

from dbo.STRING_SPLIT(@procModCombosStr,',',1) as t1

select 
    @minIdx = min(id)
  , @maxIdx = max(id) 
from @procModCombosStrParts

set @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin
  
  delete @procModComboStrParts

  set @proc    = null
  set @mod1    = null
  set @mod2    = null
  set @mod3    = null
  set @mod4    = null
  set @numMods = null

  select top 1 
    @procModComboStr = t1.part 
  from @procModCombosStrParts as t1 
  where (t1.id = @curIdx)
  
  insert into @procModComboStrParts
  select 
      t2.id
	, t2.part 
  from dbo.STRING_SPLIT(@procModComboStr,' ',1) as t2

  select 
    @numMods = count(t3.id) 
  from @procModComboStrParts as t3
  where (t3.id > 1)

  select top 1 @proc = t3.part from @procModComboStrParts as t3 where (t3.id = 1)
  select top 1 @mod1 = t3.part from @procModComboStrParts as t3 where (t3.id = 2)
  select top 1 @mod2 = t3.part from @procModComboStrParts as t3 where (t3.id = 3)
  select top 1 @mod3 = t3.part from @procModComboStrParts as t3 where (t3.id = 4)
  select top 1 @mod4 = t3.part from @procModComboStrParts as t3 where (t3.id = 5)

  insert into @procModCombos
  select 
    PROCEDURE_CODE       = @proc
  , PROCEDURE_MODIFIER_1 = @mod1
  , PROCEDURE_MODIFIER_2 = @mod2
  , PROCEDURE_MODIFIER_3 = @mod3
  , PROCEDURE_MODIFIER_4 = @mod4
  , NUM_MODS             = @numMods

  set @curIdx = @curIdx + 1
end

return 
end

GO