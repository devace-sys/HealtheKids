
use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_BATCH_837') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE TRANSMISSION_GENERATION_BATCH_837
GO

CREATE PROCEDURE TRANSMISSION_GENERATION_BATCH_837 (
	  @path          VARCHAR(255)-- file path to save to
	, @filenameRoot  VARCHAR(100) -- save file name	
	, @note          varchar(7000)
	, @notifyEmails  varchar(5000) -- ; delimited list of emails
)
AS
BEGIN

set nocount on
		
declare @today          as datetime = getdate()
declare @userid         as bigint   = 0 /* This is a constant 0 to indicate that the calling user is an automated process */
declare @msg            as varchar(512)
declare @clientsToTransmit bigint_tabletype						
declare @txIdsJsonData as varchar(max) = '[]'

exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Starting'
exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Determine If Its OK To Run Today'

declare @refDate as date = convert(date,@today)
set @msg = 'Batch Generation of 837 Files - Todays Date : ' + datename(dw,@refDate) + ' ' + convert(varchar(107),@refDate)
exec dbo.PRINT_STATUS_MESSAGE @msg

/* Get day of week of refDate */

declare @dwRefDate as int = (datediff(dd, 0, @refDate) % 7) /* 0 Monday to 6 Sunday */

/* Get last day of month (dom) with respect to refDate */

declare @lastDayOfMonth as date = EOMONTH(@refDate)

/* Find out what day of the week it is */

declare @dwLastDayOfMonth as int  = (datediff(dd, 0, @lastDayOfMonth) % 7) /* 0 Monday to 6 Sunday */

/* Get last weekday (Mon-Fri) of month using day of week of last day of month */

declare @lastWeekDayOfMonth  as date = case
  when @dwLastDayOfMonth = 5 THEN DATEADD(dd, -1, @lastDayOfMonth) /* Last dom is Saturday, Subtract 1 Day */
  when @dwLastDayOfMonth = 6 THEN DATEADD(dd, -2, @lastDayOfMonth) /* Last dom is Sunday, Subtract 2 Days */
  else @lastDayOfMonth                                             /* Last dom falls on a weekday so use it */
end

set @msg = 'Batch Generation of 837 Files - Last Weekday Date For This Month : ' + datename(dw,@lastWeekDayOfMonth) + ' ' + convert(varchar(107),@lastWeekDayOfMonth)
exec dbo.PRINT_STATUS_MESSAGE @msg

/* Get day before last weekday of month */

declare @dayBeforeLastWeekDayOfMonth  as date = dateadd(dd,-1,@lastWeekDayOfMonth)

/* Find out what day of the week it is */

declare @dwDayBeforeLastWeekDayOfMonth as int  = (datediff(dd, 0, @dayBeforeLastWeekDayOfMonth) % 7) /* 0 Monday to 6 Sunday */

/* Get next to last weekday (Mon-Fri) of month using day of week of day before last weekday we calculated */

declare @nextToLastWeekDayOfMonth as date = case
  when @dwDayBeforeLastWeekDayOfMonth = 5 then DATEADD(dd, -1, @dayBeforeLastWeekDayOfMonth) /* Saturday, sub 1 day*/
  when @dwDayBeforeLastWeekDayOfMonth = 6 then DATEADD(dd, -2, @dayBeforeLastWeekDayOfMonth) /* Sun, sub 2 day */
  else @dayBeforeLastWeekDayOfMonth                                                          /* Already a weekday, use it*/
end

set @msg = 'Batch Generation of 837 Files - Next To Last Weekday Date For This Month : ' + datename(dw,@nextToLastWeekDayOfMonth) + ' ' + convert(varchar(107),@nextToLastWeekDayOfMonth)
exec dbo.PRINT_STATUS_MESSAGE @msg

/* Is the day of week for @refDate a weekly transmission day? */

declare @isWeeklyTxDay as bit = iif ((@dwRefDate = 3),1,0) /* Is it Thursday */ 

/* Is ref date the next to last weekday of month, if so its monthly tx time */

declare @isMonthlyTxDay as bit = iif ((@refDate = @nextToLastWeekDayOfMonth),1,0) /* Is it Thursday */ 

if (@isWeeklyTxDay = 1) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Today Is A Weekly Transmission Day'
end

if (@isMonthlyTxDay = 1) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Today Is A Monthly Transmission Day'
end

if ((@isWeeklyTxDay = 1) or (@isMonthlyTxDay = 1))
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Today Is OK To Run - Proceed'
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Today Is NOT OK To Run - Exiting'
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Complete'
  return
end
	  
exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Find All Clients We Can Autogenerate 837 Files For'		

insert into @clientsToTransmit(id)
select 
  clc.CLIENT_ID as client_id
from dbo.CLIENTS_Client as clc
where (
          (clc.LEA          = 1) 
      and (clc.APPROVED_837 = 1)
      and (clc.APPROVED_835 = 1)
      and (clc.autoGenerate837File = 1)
)
order by 
  clc.CLIENT_ID
			
declare @numClients as bigint = 0
select @numClients = COUNT(t1.id) from @clientsToTransmit as t1

if (@numClients = 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - No Clients Found - Exiting'
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Complete'
  return
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Clients Found - Proceeding' 
end

exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Generate 837 File(s) Routine - Calling'
exec dbo.TRANSMISSION_GENERATION_MULTIPLE_837_PROCESS @clientsToTransmit, @path, @filenameRoot, @userID, @note, @txIdsJsonData output
exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Generate 837 File(s) Routine - Returned'
exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Parsing Tx Ids Returned From Generate 837 Files(s) Routine'

declare @txIds as table (
    transmissionID bigint  
  , retroactive    bit 
  , cifVoid        bit
)

insert into @txIds 
select 
      txIds.*  
  from OPENJSON(@txIdsJsonData)
  WITH (
      transmissionID       bigint  '$.transmissionID'   
	, retroactive          bit     '$.retroactive'
	, cifVoid              bit     '$.cifVoid'
) as txIds

exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Getting All Applicable Transmissions Using Tx Ids Returned'

declare @genTransFiles as table (generationID bigint, transmissionID bigint, fileName varchar(100))
				
insert into @genTransFiles ( 
  generationID
, transmissionID 
, fileName )

select 
    tr.generationID
  , tx.transmissionID
  , tr.fileName
from @txIds                     as tx
join  dbo.Transmission_Records	as tr on tr.Transmission_ID = tx.transmissionID
where (tr.fileName is not null)

/* Email howmuch file data to recipients */
				
set @msg = 'Batch Generation of 837 Files - Creating Email for the Following : ' + @notifyEmails
exec dbo.PRINT_STATUS_MESSAGE @msg
				
declare @rows as table ( [fileName] varchar(100) )

        insert into @rows (fileName)
		select filename from @genTransFiles
			
		declare @rowCount bigint
		set @rowCount = (select COUNT(*) from @rows)
				
        declare @html as nvarchar(max)
				 
		set @html =
					N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
				   + N'<html xmlns="http://www.w3.org/1999/xhtml">'
				   + N'<head>'
				   + N'<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
				   + N'<title>A Message From SpEdCare</title>'
				   + N'<meta name="viewport" content="width=device-width, initial-scale=1.0"/>'
				   + N'<style type="text/css">'
				   + N' body {background-color:#fff;width:95%;margin:0 auto;}'
				   + N' h1,h2,h3,ul,li,table,td,th,p {color:#000;font-size:14pt;}'
				   + N' hr {margin-top:10px;margin-bottom:10px;}'
				   + N' h1,h2 {text-align:center;font-weight:bold;}'
				   + N' h1 {font-size:24pt;}'
				   + N' h2 {font-size:18pt;}'
				   + N' h3 {font-size:16pt;text-decoration:underline;}'
				   + N' table {border-collapse:collapse;width:95%;margin:0 auto;}'
				   + N' th {background-color:#ccc;}'
				   + N' td {background-color:#fff;}'
				   + N' th,td {padding:5px;border:1px solid #000;}'
				   + N'</style>'
				   + N'</head>'
				   + N'<body>'
				   + N'<h1>There Are 837 Files That Require Staff Attention</h1>'
				   + N'<h2>This is an automatically generated notice.  Please do not reply to it.</h2>'
				   + N'<hr/>'  
				   + N'<h3>Summary</h3>'
				   + N'<p>'
				   + N'As of <strong>' + dbo.RPT_DATE_FMT(@today) + '</strong> '
				   + N'there are <strong>' + CONVERT(nvarchar,@rowCount) + '</strong> ' 
				   + N'837 files that are ready for additional handling by staff.'
				   + N' Details for each file are listed below.'
				   + N'</p>' 
				   + N'<h3>Details For Each File</h3>'
				   + N'<table>'
				   + N'<tr>' +
				   + N'<th>File Names</th>'
				   + N'</tr>'
				   + isnull(CAST ( ( SELECT td = fileName
					 FROM @rows
					 FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ),N'')  
				   + N'</table>'				   				 
				   + N'<hr/>'
				   + N'<p>'
				   + N'CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.'
				   + N'</p>'
				   + N'</body>'
				   + N'</html>';
				 
				 
		exec dbo.PRINT_STATUS_MESSAGE 'Batch Generation of 837 Files - Sending Email'

		EXEC msdb.dbo.sp_send_dbmail  
					  @profile_name = 'SpEdCare_Batch_Task_Profile'  
					, @recipients   = @notifyEmails
					, @subject      = 'Nightly Generated 837s Ready for Transmission' 
					, @body         = @html
					, @body_format  = 'HTML'
					, @sensitivity  = 'Confidential';
END
GO