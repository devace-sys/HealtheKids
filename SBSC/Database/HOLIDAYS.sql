USE [SPEDMON]
GO
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('Holidays') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[Holidays]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[HOLIDAYS]()
returns @holidays table(Holiday  nvarchar(30),
					    Date     date)
					    
/***************************************************************************    
 * Holidays*/    
/**    
 * Finds the Company holidays in a given year and returns as a table
 * http://stackoverflow.com/questions/457176/how-do-i-determine-a-public-holiday-in-sql-server  
 * 
 * @return             Table
 ***************************************************************************/   
as
begin
  declare @date  as  datetime
  declare @hdate as  datetime
  declare @year as nvarchar(4)
  set @year = DATENAME(year,getdate())
 /*-----------------------------------------------------------------
  * Newyear Holidays in a given @year
  *
  * If newyear falls in week days then there is no need in adjustment 
  * for the holiday. If it falls on sunday then the following day 
  * will be the holiday. If the last day i.e. 12/31 of the @year is a 
  * friday then it will be a holiday since the newyear day for the 
  * next year will be on saturday.
  -----------------------------------------------------------------*/
  
  set @date = convert(datetime,@year+'-01-01')
  
  if DATENAME(dw,@date) = 'Sunday'
    begin
      set @hdate = @date + 1
      insert into @holidays values ('NewyearDay_Adj',@hdate)
    end
  else if DATENAME(dw,@date) != 'Saturday'
    insert into @holidays values ('NewyearDay',@date)
  
    if DATENAME(dw,@year+'-12-31') = 'Friday'
      begin
        set @hdate = convert(datetime,@year+'-12-31')   	
        insert into @holidays values ('NewyearDay_Adj',@hdate)
      end 

--Christmas Holiday

  set @date = convert(datetime,@year+'-12-25')
  

  insert into @holidays values ('ChristmasDay',@date)

--Independenceday Holiday

  set @date = convert(datetime,@year+'-07-04')
  

   	
  insert into @holidays values ('IndependenceDay',@date)

--Laborday Holiday

  declare @date1 as datetime
  set @date1 = convert(datetime,@year+'-09-01')
  
 --Find the first monday in September
 
  set @date  = DATEADD(wk, DATEDIFF(wk,0, dateadd(dd,6-datepart(day,@date1),@date1) ), 0)

  insert into @holidays values ('LaborDay',@date)

--Thanksgiving Holiday

  set @date1 = convert(datetime,@year+'-11-01')
  
  --Find the first monday in November
  
  set @date = DATEADD(wk, DATEDIFF(wk,0, dateadd(dd,6-datepart(day,@date1),@date1) ), 0)
  
  /*----------------------------------------------------------------
   * Now find the first Thursday of the month. 
   * If the first Monday is greater than fourth day of the month then
   * subtract  4 from it else add 3 to it to get the first thursday.
   * Now add 21 days to it to get the fourth thursday of the month.
  ------------------------------------------------------------------*/
  
  if (DATEPART(dd,@date) > 4)
    set @hdate = @date - 4 + 21
  else
    set @hdate = @date + 3 + 21
    
  insert into @holidays values ('ThanksGivingDay',@hdate)  
    	
return   

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[HOLIDAYS] TO [webuser]

GO






