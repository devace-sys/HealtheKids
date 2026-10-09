/***************************************************************************
 * RPT_SERVICE_RECORD_TATTLE_TEST.SQL */
/**
 * Test wrapper for the tattle tale report.
 * Call only do not install in SQL.
 ***************************************************************************/ 
 
use SPEDMON

declare @pageRows   as bit
declare @pageSize   as int
declare @pageNumber as int
declare @clientID   as int
declare @startDate  as datetime
declare @endDate    as datetime

/*-------------------------------
 * Set desired values below
 *------------------------------*/

set @pageRows   = 0
set @pageSize   = 100
set @pageNumber = 1
set @clientID   = null
set @startDate  = CONVERT(datetime,'2/1/2011 00:00:00')
set @endDate    = CONVERT(datetime,'2/4/2011 23:59:59')

/*-------------------------------
 * Call
 *------------------------------*/
 
select * 
from 
dbo.RPT_SERVICE_RECORD_TATTLE(@pageRows,@pageSize,@pageNumber,@clientID,@startDate,@endDate) 