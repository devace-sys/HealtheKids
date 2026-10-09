USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_PLANNED_VS_ACTUAL_REF_DATES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUBLICATION_PLANNED_VS_ACTUAL_REF_DATES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[REPORT_PUBLICATION_PLANNED_VS_ACTUAL_REF_DATES]
(@DateStart DATETIME, 
 @DateEnd   DATETIME) 

RETURNS @recs TABLE (PlannedRefDate DATETIME, ActualRefDate DATETIME)

/***************************************************************************    
 * REPORT_PUBLICATION_PLANNED_VS_ACTUAL_REF_DATES */    
/**    
 * Returns a comparison of planned ref dates with actual ref dates recorded
 * These dates represent each reference date that the report distribution
 * Missing actual ref dates represent the days that application must be 
 * run manually to "make up" the date.
 *
 * @return table 
 ***************************************************************************/     

AS     
BEGIN
    

/*-------------------------------
 * Setup our working variables 
 *------------------------------*/
declare @refDateStart      as datetimedeclare @refDateEnd        as datetimedeclare @refDateCur        as datetime
/*-------------------------------
 * Setup table var to hold all
 * possible ref dates
 *------------------------------*/

declare @RptPubRefDatesAll as table (PlannedRefDate Datetime) 

/*-------------------------------
 * Generate all possible ref
 * dates between @DateStart and
 * @DateEnd and store in the
 * table var
 *------------------------------*/set @refDateStart = dbo.DATE_ONLY(@DateStart)set @refDateEnd   = dbo.DATE_ONLY(@DateEnd)set @refDateCur   = @refDateStart
while (@refDateCur <= @refDateEnd)begin
  insert into @RptPubRefDatesAll (PlannedRefDate) values (@refDateCur)
  set @refDateCur = dateadd(day,1,@refDateCur)
end
/*-------------------------------
 * Generate a comparison between
 * all possible ref dates and
 * actual ref dates recorded
 *------------------------------*/
insert into @recsselect  pd.PlannedRefDate,   ad.ActualRefDate from @RptPubRefDatesAll as pdleft join (  select distinct ReferenceDate as [ActualRefDate] from REPORT_PUBLICATION_DISTRIBUTION_HISTORY
) as ad on ad.ActualRefDate = pd.PlannedRefDate
 /*-------------------------------
  * Return the comparison
  *------------------------------*/
  
return

end 

GO
