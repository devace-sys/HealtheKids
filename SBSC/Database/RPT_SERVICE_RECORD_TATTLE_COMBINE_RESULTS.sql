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
(@clientID       int, 
 @groupID        int, 
 @pracID         int, 
 @startDate      datetime,    
 @endDate        datetime)     
 returns @recs   table([Month/Year]        varchar(20),    /* New column we add */
                       Client              nvarchar(max),  /* Columns from core */   
                       [Start Date]        varchar(20),     
                       [End Date]          varchar(20),
                       [Practitioner Type] nvarchar(max),
                       [Reporting Group]   nvarchar(max),
                       [Practitioner ID]   int,
                       [Last Name]         nvarchar(100),
                       [First Name]        nvarchar(100))
                       
/***************************************************************************
 * RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS */
/**
 * Internal helper query for RPT_SERVICE_RECORD_TATTLE.
 * It combines the results of mutiple calls to RPT_SERVICE_RECORD_TATTLE_CORE    
 *     
 * @param  clientID        Client ID  
 * @param  groupID         GroupID   
 * @param  pracID          PractitionerID     
 * @param  startDate       Starting date of service (required)    
 * @param  endDate         Ending date of service (required)
 * @return                 Table       
 ***************************************************************************/     
                       
begin

declare @numRanges AS int
declare @currentID AS int
declare @sDate     AS datetime
declare @eDate     AS datetime
declare @mYear     AS varchar(20)

/*--------------------------------------------------------------------
 * Take our incoming date range and split it into individual date 
 * ranges partitioned by month/year.
 *  
 * For example if the date range 1/1/2010 to 3/31/2010 was passed in
 * we would split this range into three partitions.
 *
 *   1.  1/1/2010 - 1/31/2010
 *   2.  2/1/2010 - 2/28/2010
 *   3.  3/1/2010 - 3/31/2010
 *
 * Note: The day component of the date is disregarded, so if you
 * pass in 1/15/2010 to 3/2/2010 it will result in the same output
 * as shown above.
 *-------------------------------------------------------------------*/     

declare @dateRanges table(id         int ,
                          startDate  datetime,
                          endDate    datetime,
                          monthYear  varchar(20))
                          
insert into @dateRanges select * from dbo.DATE_RANGE_SPLIT( @startDate,@endDate)
select @numRanges = count(*) from @dateRanges
 
/*---------------------------------------    
 * Go through each record in @dateRanges
 * and create tattle records for each
 * month.
 *
 * Note: We are using a "cursorless loop"  
 * to generate this report because we need
 * to evaluate whether or not to tattle on
 * a practitioner BY MONTH so we cannot simply
 * provide a date range and a left join because
 * all it would take is for a practitioner
 * to provide records for one month and they
 * would be excluded from the list.
 *--------------------------------------*/      
 
 -- TODO: See if we can do this by just using a query
 
set @currentID = 1

-- TODO: Insert reference to our wiki page on this cursorless design pattern

while (@currentID <= @numRanges)                        
begin
  
  -- Fetch first/next date range (month)
  
  select @sDate = startDate, 
         @eDate = endDate,
         @mYear = monthYear 
  from   @dateRanges 
  where  id = @currentID
            
  -- Call RPT_SERVICE_RECORD_TATTLE_CORE to generate our records for the given month 
  -- and place them in our output table.
  
  insert into @recs 
  select @mYear as [Month/Year],
         tc.*
  from dbo.RPT_SERVICE_RECORD_TATTLE_CORE(@clientID,@groupID,@pracID,@sDate,@eDate) tc
         
  -- Advance to next date month
  
  set @currentID = @currentID + 1  
end 
return
end

GO

GRANT SELECT ON SPEDMON.dbo.RPT_SERVICE_RECORD_TATTLE_COMBINE_RESULTS TO webuser;

GO
