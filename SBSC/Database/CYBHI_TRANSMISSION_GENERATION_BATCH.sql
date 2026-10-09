use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_BATCH') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_BATCH
end
GO

/*---------------------------------------------------------------------------------------------------------*/

/*

exec dbo.CYBHI_TRANSMISSION_GENERATION_BATCH 
    'C:\spedmon\data\import-export\claims\cybhi\837\'
  , 'awebb@help4schools.com'

*/

/*---------------------------------------------------------------------------------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_BATCH (
    @path          varchar(255)  = ''
  , @notifyEmails  varchar(5000) = ''
)
AS
BEGIN
  
set nocount on

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Starting'

/*---------------------------------------------------------------------------------------------------------*/

if (len(@path) = 0) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Path required'
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Done'
  return(0)
end

/*---------------------------------------------------------------------------------------------------------*/

if (len(@notifyEmails) = 0) 
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Notification emails required'
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Done'
  return(0)
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Init'

declare @msg         as varchar(512)  = ''
declare @today       as datetime      = getdate()
declare @refDate     as date          = convert(date,@today)
declare @dwRefDate   as int           = -1
declare @jsonData    as varchar(max)  = '[]'
declare @htmlHeader  as nvarchar(max) = ''
declare @htmlContent as nvarchar(max) = ''
declare @htmlFooter  as nvarchar(max) = ''
declare @html        as nvarchar(max) = ''
declare @fileCount   as int           = 0

declare @files as table ( 
    [fileName]              varchar(256) 	
  , [svcRecReleaseCount]   int
  , [amountReleased]       money
)

/*---------------------------------------------------------------------------------------------------------*/

set @msg = 'CYBHI Transmission Generation Batch - Todays Date : ' + datename(dw,@refDate) + ' ' + convert(varchar(107),@refDate)
exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

set @msg = 'CYBHI Transmission Generation Batch - 837 file folder : ' + @path
exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

set @msg = 'CYBHI Transmission Generation Batch - Email List : ' + @notifyEmails
exec dbo.PRINT_STATUS_MESSAGE @msg

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Checking if today is a day to run'

set @dwRefDate = (datediff(dd, 0, @refDate) % 7) /* 0 Monday to 6 Sunday */

if (@dwRefDate != 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Today is not a run day.  Exiting'
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Done'
  return(0)
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Today is a run day.  Running.'
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Calling Generation All Routine'

exec dbo.CYBHI_TRANSMISSION_GENERATION_ALL @path, 0 /*@userID - system */, @jsonData output

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Parsing Results of Generation All Routine Call'

insert into @files (
    [fileName]
  , [svcRecReleaseCount]
  , [amountReleased]
)
select 
    t2.[fileName]
  , t2.[svcRecReleaseCount]
  , t2.[amountReleased]
from
(
  select 
     t1.[fileName]
   , t1.[svcRecReleaseCount]
   , t1.[amountReleased]
  from OPENJSON(@jsonData)
  with (     		  	      
		[fileName]           varchar(100) '$.fileName'  
      , [fileGenerated]      bit          '$.fileGenerated'
      , svcRecReleaseCount   int          '$.svcRecReleaseCount'
      , amountReleased       money        '$.amountReleased'
  ) as t1
  where 
    (t1.[fileGenerated] = 1)
) as t2

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Counting Result Rows'

set @fileCount = -1
select @fileCount = count(t1.[fileName]) from @files as t1

if (@fileCount > 0)
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - There are files to transmit'
end
else
begin
  exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - No files'
end

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Generating status email.'

set @htmlHeader = N'' 
    + N'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
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
	+ N'<h1>CYBHI Claim Transmission Files (837 Files) Status</h1>'
    + N'<h2>This is an automatically generated notice.  Please do not reply to it.</h2>'
	+ N'<hr/>'  

set @htmlFooter = N''
    + N'<hr/>'
	+ N'<p>'
	+ N'CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.'
	+ N'</p>'
	+ N'</body>'
	+ N'</html>';


if (@fileCount > 0)
begin
  set @htmlContent = N''
	  + N'<h3>Summary</h3>'
	  + N'<p>'
	  + N'As of <strong>' + dbo.RPT_DATE_FMT(@today) + '</strong> '
	  + N'there are <strong>' + CONVERT(nvarchar,@fileCount) + '</strong> ' 
	  + N'CYBHI 837 files that are ready for transmission.'
	  + N'</p>'
	  + N'<h3>Summary</h3>'
	  + N'<p>'
	  + N'<h3>Details For Each File</h3>'
	  + N'<table>'
	  + N'<tr>' +
	  + N'<th>File Name</th>'
	  + N'<th>Claims</th>'
	  + N'<th>Amount</th>'
	  + N'</tr>'
	  + isnull(CAST ( ( SELECT td = [fileName], ''
	  , td = [svcRecReleaseCount], ''
	  , td = [amountReleased], '' 
	  FROM @files FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) ),N'')  
	  + N'</table>'				   				 
end /* There are files */
else
begin
  set @htmlContent = N''
	  + N'<h3>Summary</h3>'
	  + N'<p>'
	  + N'As of <strong>' + dbo.RPT_DATE_FMT(@today) + '</strong> '
	  + N'there are NO CYBHI 837 files available for transmission.  Please check logs for details.'
	  + N'</p>'
end

set @html = @htmlHeader + @htmlContent + @htmlFooter

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Sending status email.'
	 				
EXEC msdb.dbo.sp_send_dbmail  
			  @profile_name = 'SpEdCare_Batch_Task_Profile'  
			, @recipients   = @notifyEmails
			, @subject      = 'CYBHI 837s Ready for Transmission' 
			, @body         = @html
			, @body_format  = 'HTML'
			, @sensitivity  = 'Confidential';

/*---------------------------------------------------------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'CYBHI Transmission Generation Batch - Done'
return(0)

END
GO
