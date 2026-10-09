use SPEDMON

/***************************************************************************
 * Performs the yearly maitanance required for A&I report
 * Refreshes the view dbo.LEA_FY_DATA as per the dates the report is run
 * 
 * Checks if the fiscal year is ending by the next report period
 * If the end date is in ending fiscal year then no need to do anything now
 * If the end date is in new fiscal year the following should be done
 *
 * 1, New rows for the ending fiscal year should be inserted into 
 *    permanent data table dbo.LEA_Fiscal_Year_Totals_Recovered with the 
 *    amounts for each client. 
 * 2, the view dbo.LEA_FY_DATA needs to be refreshed 
 ***************************************************************************/
 
  declare @today date = getdate()
  declare @startweek date, @endWeek date, @fyStart date, @fyEnd date,@fyID int
	
/* Set the startweek and endweek values to describe the 7-day period ending last Friday */
  set @startweek = dateadd(day,-7-DATEPART(dw,@today),@today)
  set @endWeek   = dateadd(day,-1-DATEPART(dw,@today),@today)
  select @fyStart = FY_START,@fyEnd = FY_END from dbo.COMPANY_FISCAL_YEARS
   where @endWeek >= FY_START and @EndWeek <= FY_END
   
  if(DATEADD(dd,7,@endWeek) > @fyEnd)
  begin
  
   select @fyID = ID from dbo.COMPANY_FISCAL_YEARS
   where @endWeek >= FY_START and @endWeek <= FY_END
   
   insert into dbo.LEA_Fiscal_Year_Totals_Recovered           
   select [Client ID], @fyID, [Current Year - Total], [Current Year - State Adjustments]
     from RPT_AnI_WEEKLY(null,null,@startweek,@EndWeek,@fyStart)     
   
   set @endWeek = DATEADD(dd,7,@endWeek)
   
   end          
   
   exec LEA_FY_PermData_Tbl_Defs @endWeek
   
go