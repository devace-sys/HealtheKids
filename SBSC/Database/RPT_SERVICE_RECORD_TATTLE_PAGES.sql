USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS]     
(@firstRow       as int,     
 @lastRow        as int,  
 @clientID       int, 
 @startDate      datetime,    
 @endDate        datetime)     
 returns @tattle table(rowNum           int,
					   rowTotal         int,	 
				       Client           nvarchar(100),                        
                       StartDate        varchar(20),     
                       EndDate          varchar(20),
                       PractitionerType nvarchar(max),
                       PractitionerID   int,
                       LastName         nvarchar(100),
                       FirstName        nvarchar(100))
                       
/***************************************************************************
 * RPT_SERVICE_RECORD_TATTLE_PAGES */
/**
 * Internal helper query for RPT_SERVICE_RECORD_TATTLE    
 *     
 * @param  firstRow        Start row    
 * @param  lastRow         End row    
 * @param  startDate       Starting date of service    
 * @param  endDate         Ending date of service    
 * @param  clientID        Client ID (required)      
 * @return                 Table       
 ***************************************************************************/     
                       
begin

declare @startDateStr as varchar(20)
declare @endDateStr   as varchar(20)
declare @dateFormat   as int


/*-------------------------------------------------
 * Format our dates for display
 * see http://www.mssqltips.com/tip.asp?tip=1145
 * for a list of formats.
 *------------------------------------------------*/

set @dateFormat   = 101 
set @startDateStr = convert(varchar, @startDate , @dateFormat) 
set @endDateStr   = convert(varchar, @endDate   , @dateFormat)



/*-------------------------------
 * Generate records
 *------------------------------*/
 /*-------------------------------    
 * This query handles preselection    
 * and paging of the core recordset    
 * It is crucial that this queries    
 * only duty is to QUICKLY return    
 * the smallest, rawest recordset    
 * possible.  Therefore please do    
 * not make any modifications that    
 * will slow down processing.      
 * Some examples of undesired     
 * modifications are:    
 *  - Computed columns    
 *  - Derived columns    
 *------------------------------*/ ;   
    
with recs_cte     
as (    
select     
  row_number() over(order by q1.Client) as rowNum,    
  count(*)over()                        as rowTotal,    
  q1.*     
from 
dbo.rpt_service_record_tattle_core(@clientid,@startdate,@enddate) AS q1)
  
  insert into @tattle
    select * from recs_cte    
     where (1=1) and    
         (((@FirstRow is null) and (@LastRow is null)) or (rowNum between @FirstRow and @LastRow))

return
end 
GO
