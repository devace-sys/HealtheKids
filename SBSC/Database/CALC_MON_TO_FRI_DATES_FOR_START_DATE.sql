USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_MON_TO_FRI_DATES_FOR_START_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_MON_TO_FRI_DATES_FOR_START_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_MON_TO_FRI_DATES_FOR_START_DATE] ( @startDate datetime )

returns @dates table (
    idx      int
  , dowValue date
) 
  
as
begin

declare @refDate as datetime
if @startDate is null set @startDate = GETDATE()
set @refDate = dateadd(wk, datediff(wk,0,@startDate),0)

insert into @dates values (null, @refDate)
-- 1 is Sun
insert into @dates values (2, dateadd(day,0,@refDate))
insert into @dates values (3, dateadd(day,1,@refDate))
insert into @dates values (4, dateadd(day,2,@refDate))
insert into @dates values (5, dateadd(day,3,@refDate))
insert into @dates values (6, dateadd(day,4,@refDate))
-- 7 is Sat

return
end
go
