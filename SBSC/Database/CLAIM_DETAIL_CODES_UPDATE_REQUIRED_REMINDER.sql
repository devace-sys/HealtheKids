USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_DETAIL_CODES_UPDATE_REQUIRED_REMINDER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLAIM_DETAIL_CODES_UPDATE_REQUIRED_REMINDER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLAIM_DETAIL_CODES_UPDATE_REQUIRED_REMINDER]
AS
BEGIN   

set nocount on


RAISERROR ('Searching for claim detail codes that are missing data', 0, 1) WITH NOWAIT

declare @today              as datetime = getdate()
declare @rowCount           as bigint        = 0
declare @notifyEmails       as varchar(5000) = ''
declare @rows as table (
    CODE_ID      bigint
  , CODE_VALUE   nvarchar(20)
  , CODE_SOURCE nvarchar(255)
)

set @today = GETDATE()
set @notifyEmails = 'awebb@help4schools.com;afisher@help4schools.com'

insert into @rows
select
    CODE_ID
  , CODE_VALUE
  , CODE_SOURCE = case 
    when IS_ARC_CARC  = 1 then 'Claim Adjustment Reason Code (CARC)'
    when IS_HCRC_RARC = 1 then 'Remittance Advice Remark Code (RARC)'
    else                       'Unknown'
  end
from dbo.CLAIM_DETAIL_CODES 
where (ltrim(rtrim(isnull(DETAIL_TEXT,''))) = '')

set @rowCount = 0

select @rowCount = count(*) from @rows

if (@rowCount > 0) 
begin
  
  RAISERROR ('There are claim detail codes that require updates', 0, 1) WITH NOWAIT
  
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
   + N'<h1>There are Claim Detail Codes that Require Updates</h1>'
   + N'<h2>This is an automatically generated notice.  Please do not reply to it.</h2>'
   + N'<hr/>'  
   + N'<h3>Summary</h3>'
   + N'<p>'
   + N'As of <strong>' + dbo.RPT_DATE_FMT(@today) + '</strong> '
   + N'there are <strong>' + CONVERT(nvarchar,@rowCount) + '</strong> ' 
   + N'claim detail code records that require additional data.'
   + N' Details for each record and further instructions are provided below.'
   + N'</p>' 
   + N'<h3>Details For Each Record</h3>'
   + N'<table>'
   + N'<tr>' +
   + N'<th>Code ID</th>'    
   + N'<th>Code</th>'
   + N'<th>Code Source</th>'
   + N'</tr>'
   + CAST ( ( SELECT td = [CODE_ID], '',
     td = [CODE_VALUE],   '',
     td = [CODE_SOURCE],  ''
   FROM @rows
   FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX))
   + N'</table>'   
   + N'<h3>Further Instructions</h3>'
   + N'<ul>'  
   + N'<li>Please click <a href="http://sbscitdev.help4schools.com/dokuwiki/doku.php?id=spedmon:adjustment-denial-codes-management">here</a> for further instructions.</li>'
   + N'<li><i>Please note: You must be on our internal network to access futher instructions</i></li>'
   + N'</ul>'  
   + N'<hr/>'
   + N'<p>'
   + N'CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.'
   + N'</p>'
   + N'</body>'
   + N'</html>';
   
  RAISERROR ('Sending email', 0, 1) WITH NOWAIT

  EXEC msdb.dbo.sp_send_dbmail  
      @profile_name = 'SpEdCare_Batch_Task_Profile'  
    , @recipients   = @notifyEmails
    , @subject      = 'There Are Claim Detail Code Records That Require Updates' 
    , @body         = @html
    , @body_format  = 'HTML'
    , @sensitivity  = 'Confidential';
   
end
else
begin
  RAISERROR ('There are no claim detail codes that require updates', 0, 1) WITH NOWAIT
end

RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLAIM_DETAIL_CODES_UPDATE_REQUIRED_REMINDER] TO [webuser]
GO
