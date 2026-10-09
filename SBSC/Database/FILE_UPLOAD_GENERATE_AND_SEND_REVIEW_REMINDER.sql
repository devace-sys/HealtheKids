USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_GENERATE_AND_SEND_REVIEW_REMINDER') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_GENERATE_AND_SEND_REVIEW_REMINDER
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[FILE_UPLOAD_GENERATE_AND_SEND_REVIEW_REMINDER]
AS
BEGIN   

set nocount on

declare @today as datetime = getdate()
set @today = GETDATE()

/* Every Friday
 * Change Batch status from 10 to 50 to prevent input staff 
 * from wasting time in workflow 
 * (See emails from Georgia from end of August 2017) */

/*IF (DATENAME(WEEKDAY, @today) in ('Friday'))
BEGIN

  RAISERROR ('Sweeping all applicable input batches in status 10 to into status 50', 0, 1) WITH NOWAIT

  update dbo.INPUT_BATCHES
  set 
      Current_status_Code   = 50
    , Estimated_Input_Hours = '0.01'
    , Current_Status_Date   = @today

  where ( 
         (Current_status_Code = 10)
     and (File_Name not like '%qform%') 
     and (File_Name     like '%.pdf')
  )     

END

/* Move all WFA files in status 100 (Entered to Review - Input Complete) 
 * to Finished Claims but only if the assigned staffer has a higher than 
 * starting training rating in the batches' type of work */

RAISERROR ('Sweeping all applicable input batches in status 100 to input complete', 0, 1) WITH NOWAIT
 
update INPUT_BATCHES
set 
  Current_status_Code = 200 
where (
      Current_status_Code = 100
  and id in (
    select ib.id
    from INPUT_BATCHES ib
    inner join TYPE_OF_WORK tow on ib.Type_Of_Work = tow.id
    inner join TRAINED_STAFF ts on ts.WORKTYPE_ID = ib.Type_Of_Work
                                and ts.STAFF_ID = ib.Current_status_UserID2
    inner join STAFF_TRAINING_RATES str on ts.RATING = str.RATING_ID 
    where (
          (ib.Current_status_Code = 100)
      and (str.RATING_ID <> 1) /* Anything other than 0.25 */
    )
  )
)
*/

RAISERROR ('File upload review reminders', 0, 1) WITH NOWAIT

declare @rowCount           as bigint        = 0
declare @maxIdleThreshold   as bigint        = 7
declare @maxIdleCurrent     as bigint        = 0
declare @fileClassWorkBatch as bigint        = 1
declare @notifyEmails       as varchar(5000) = ''

declare @rows as table (
    [Date Received]       varchar(10)
  , [Days Sitting Idle]   varchar(8)
  , [Waiting In App]      varchar(20)
  , [File]                varchar(50)
  , [Type of Work]        varchar(8)
  , [Age At Arrival]      varchar(8)
  , [Current Age]         varchar(8)
  , [Oldest DOS]          varchar(10)
  , [Upload ID]           varchar(50)
)

declare @emails as table (
   Email    nvarchar(256)
)

set @today = GETDATE()

RAISERROR ('Searching for files that are sitting idle', 0, 1) WITH NOWAIT

insert into @rows
select

    [Date Received]         = dbo.RPT_DATE_FMT(t1.UploadedOn)
  , [Days Sitting Idle]     = datediff(day,t1.UploadedOn, @today)
  , [Waiting In App]        = t1.[Waiting In App]
  , [File]                  = t1.FileName
  , [Type of Work]          = t1.TypeOfWork
  , [Age At Arrival]        = datediff(day,t1.OldestDOS, t1.UploadedOn)
  , [Current Age]           = datediff(day,t1.OldestDOS, @today)
  , [Oldest DOS]            = dbo.RPT_DATE_FMT(t1.OldestDOS)
  , [Upload ID]             = convert(varchar(50),t1.id)

from
(  
  /* Search for all files that are wating for review in the file upload review app */
   
  select 
    [Waiting In App]  = 'File Upload Review'
  , [FileName]   = fu.filedName 
  , [UploadedOn] = fu.fileUploaded
  , [UploadedBy] = fu.fileUploaderContactEmail
  , [OldestDOS]  = convert(date,fu.ReferenceDate1)
  , [TypeOfWork] = fu.fileSubClass 
  , fu.id

  from  dbo.FILE_UPLOADS   as fu
  where ( 
        (fu.clientID   != 112)
	and (fu.fileUploaded is not null)
	and (fu.fileClass  =  1)    
    and (fu.active     =  1)
    and (fu.reviewFile =  1)    
  )

  union 
  
  /* Search for all files that are sitting in status 10 that are not PDF files
   * If there are any files, generate a reminder email */

  select 
    [Waiting In App] = 'Workflow'
  , [FileName]   = fu.filedName 
  , [UploadedOn] = fu.fileUploaded
  , [UploadedBy] = fu.fileUploaderContactEmail
  , [OldestDOS]  = convert(date,fu.ReferenceDate1)
  , [TypeOfWork] = fu.fileSubClass 
  , fu.id

  from dbo.FILE_UPLOAD_ID_INPUT_BATCH_ID_XREF(null) as fuib 
  join dbo.INPUT_BATCHES                        as ib on ib.id = fuib.inputBatchID
  join dbo.FILE_UPLOADS                         as fu on fu.id = fuib.uploadID

  where (

        (fuib.batchedFileIsPDF  = 0) 
    and (ib.Current_status_Code = 10)
    and (ib.ClientID          != 112)
    and (ib.Active              = 1)
  )
) as t1

order by 
  UploadedOn asc

set @rowCount = 0

select @rowCount = count(*) from @rows

if (@rowCount > 0) 
begin
  
  RAISERROR ('There are files waiting for staff attention', 0, 1) WITH NOWAIT
  RAISERROR ('Building regular notification list.  Currently this list is all active Work Leaders', 0, 1) WITH NOWAIT

  insert into @emails select Email = 'mail@help4schools.com'

  insert into @emails
  select 
     m.Email
  from Users.dbo.RoleData     as rd
  join users.dbo.Roles        as r  on r.RoleId  = rd.RoleId
  join users.dbo.UsersInRoles as ur on ur.RoleId = r.RoleId
  join users.dbo.Membership   as m  on m.UserId  = ur.UserId
  join users.dbo.Users        as u  on u.UserId  = m.UserId
  where 
    (rd.RoleId = '4887E5EE-F573-4889-8C74-7BB681C9429A')

    
  select @maxIdleCurrent = MAX([Days Sitting Idle]) from @rows

  if (@maxIdleCurrent >= @maxIdleThreshold)
  begin
    RAISERROR ('One or more of the files waiting for review have been idle long enough to add escalation emails to the list', 0, 1) WITH NOWAIT
    insert into @emails select Email = 'awebb@help4schools.com'
    insert into @emails select Email = 'vwr@help4schools.com'
  end
    
  select @notifyEmails = stuff((select N';' + email from @emails FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')

  RAISERROR ('Creating email for the following : ', 0, 1) WITH NOWAIT
  RAISERROR (@notifyEmails, 0, 1) WITH NOWAIT
  
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
   + N'<h1>There Are Files That Require Staff Attention</h1>'
   + N'<h2>This is an automatically generated notice.  Please do not reply to it.</h2>'
   + N'<hr/>'  
   + N'<h3>Summary</h3>'
   + N'<p>'
   + N'As of <strong>' + dbo.RPT_DATE_FMT(@today) + '</strong> '
   + N'there are <strong>' + CONVERT(nvarchar,@rowCount) + '</strong> ' 
   + N'files that were uploaded as work batches that require additional handling by staff.'
   + N' Details for each file and initial handling instructions are provided below.'
   + N'</p>' 
   + N'<h3>Details For Each File</h3>'
   + N'<table>'
   + N'<tr>' +
   + N'<th>Date<br/>Received</th>'    
   + N'<th>Days<br/>Sitting<br/>Idle</th>'
   + N'<th>Waiting In App</th>'
   + N'<th>File</th>'
   + N'<th>Type<br/>of<br/>Work</th>'
   + N'<th>Age<br/>At<br/>Arrival</th>'
   + N'<th>Current<br/>Age</th>'
   + N'<th>Oldest<br/>DOS</th>'
   + N'<th>Upload<br/>ID</th>'
   + N'</tr>'
   + CAST ( ( SELECT td = [Date Received],'',
     td = [Days Sitting Idle],'',
     td = [Waiting In App],'',
     td = [File],'',
     td = [Type of Work],'',
     td = [Age At Arrival],'',
     td = [Current Age],'',
     td = [Oldest DOS],'',
     td = [Upload ID]
     FROM @rows
     FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX) )  
   + N'</table>'
   
   + N'<h3>Initial Handling Instructions For Files Waiting In The File Upload Review App</h3>'
   + N'<ul>'  
   + N'<li>Please launch the <strong>File Upload Review</strong> app to process these files.  They will be listed under the <strong>Requires Review</strong> section in the app.</li>'
   + N'<li>For more information on the <strong>File Upload Review</strong> app including how to access and use the app please click'
   + N' <a href="http://sbscitdev.help4schools.com/dokuwiki/doku.php?id=app:fileuploadreview">here</a>'
   + N' to review our internal wiki page for the app.<br/>The wiki page is a living document so please be sure to check it often for updates and changes.</li>'
   + N'<li><i>Please note: You must be on our internal network to access both the app and the WIKI page</i></li>'  
   + N'</ul>'

   + N'<h3>Initial Handling Instructions For Files Waiting In The Workflow App</h3>'
   + N'<ul>'  
   + N'<li>Please launch the <strong>Workflow</strong> app to process these files.</li>'
   + N'<li>For more information on the <strong>Workflow</strong> app including how to access and use the app please click'
   + N' <a href="http://sbscitdev.help4schools.com/dokuwiki/doku.php?id=app:workflow">here</a>'
   + N' to review our internal wiki page for the app.<br/>The wiki page is a living document so please be sure to check it often for updates and changes.</li>'
   + N'<li><i>Please note: You must be on our internal network to access both the app and the wiki page</i></li>'
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
    , @subject      = 'There Are Files That Require Staff Attention' 
    , @body         = @html
    , @body_format  = 'HTML'
    , @sensitivity  = 'Confidential';
   
end
else
begin
  RAISERROR ('No files waiting for review', 0, 1) WITH NOWAIT
end

RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_GENERATE_AND_SEND_REVIEW_REMINDER] TO [webuser]
GO
