USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_REF_DATE_CRON_TAB_SELECTION_VALUE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION IS_REF_DATE_CRON_TAB_SELECTION_VALUE
GO    

CREATE FUNCTION [dbo].[IS_REF_DATE_CRON_TAB_SELECTION_VALUE] (
    @refDate          date
  , @cronTabSelectionValue  bigint
)
RETURNS BIT
WITH SCHEMABINDING
AS
BEGIN

/* Daily */

if (@cronTabSelectionValue = 10) 
begin
  return 1
end

declare @dd                  as int = DATEPART(dd,@refDate)
declare @mm                  as int = DATEPART(mm,@refDate)
declare @isFirstDayOfMonth   as bit = iif((@dd = 1),1,0)

/* Start of week */

if (@cronTabSelectionValue = 20)
begin
  declare @dw as int = ( @@datefirst - 1 + datepart(dw, @refDate) ) % 7 
  if (@dw = 0) return 1 else return 0
end

/* Start of month */

else if (@cronTabSelectionValue = 30) 
begin
  if (@isFirstDayOfMonth = 1) return 1 else return 0
end

/* Start of quarter */

else if (@cronTabSelectionValue = 40)
begin
  declare @isQuarterStartMonth as bit = iif((@mm in (1,4,7,10)),1,0)
  if ((@isFirstDayOfMonth = 1) and (@isQuarterStartMonth = 1)) return 1 else return 0
end

/* Start of year */

else if (@cronTabSelectionValue = 50) 
begin
  declare @isFirstMonth as bit = iif((@mm = 1),1,0)
  if ((@isFirstMonth = 1) and (@isFirstDayOfMonth = 1)) return 1 else return 0
end
else
begin
  return 0
end

return 0

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_REF_DATE_CRON_TAB_SELECTION_VALUE] TO [webuser]
GO
