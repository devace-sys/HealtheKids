USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLEAN_PATIENT_DATA_CSIS_SSID') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.CLEAN_PATIENT_DATA_CSIS_SSID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[CLEAN_PATIENT_DATA_CSIS_SSID]
AS
BEGIN   

set nocount on

declare @numOfInvdSsid as int = 0
declare @numOfSalvSsid as int = 0

RAISERROR ('Cleaning patient data - Patient CSIS/SSID', 0, 1) WITH NOWAIT

declare @AllPatientsWithInvalidCSIS as table (
    PATIENT_ID bigint
  , CSIS varchar(10)
  unique clustered (PATIENT_ID)
)

declare @PatientsWithInvalidCSISThatMightBeSalvagable as table (
   PATIENT_ID bigint
  ,CSIS varchar(10)
  unique clustered (PATIENT_ID)
)

/* Trim CSIS if neccessary */

RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Trimming CSIS if neccessary', 0, 1) WITH NOWAIT
update dbo.PATIENTS_Patient 
  set CSIS = ltrim(rtrim(CSIS)) 
where ((CSIS is not null) and (dbo.IS_STRING_TRIMMABLE(CSIS) = 1))

/* Search for all cases where CSIS/SSID is not valid */

RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Searching for invalid values', 0, 1) WITH NOWAIT
insert into @AllPatientsWithInvalidCSIS
select
    pap.PATIENT_ID
  , pap.CSIS
from dbo.PATIENTS_Patient as pap
where (   
      (pap.CSIS is not null) 
  and (dbo.IS_VALID_CSIS_SSID (pap.CSIS) = 0)
)

set @numOfInvdSsid = 0
select @numOfInvdSsid = COUNT(PATIENT_ID) from @AllPatientsWithInvalidCSIS

/* There are invalid SSID */

if (@numOfInvdSsid != 0)
begin

  /* Invalid CSIS/SSID contains all digits */

  RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Invalid values found', 0, 1) WITH NOWAIT
  RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Identifying invalid values that might be correctable', 0, 1) WITH NOWAIT

  insert into @PatientsWithInvalidCSISThatMightBeSalvagable
  select 
     t1.PATIENT_ID
    ,t1.CSIS
  from @AllPatientsWithInvalidCSIS as t1
  where (dbo.IS_STRING_ALL_DIGITS(t1.CSIS) = 1)

  set @numOfSalvSsid = 0
  select @numOfSalvSsid = COUNT(PATIENT_ID) from @PatientsWithInvalidCSISThatMightBeSalvagable

  /* There are values that might be salvaged */
  
  if (@numOfSalvSsid != 0)
  begin

    RAISERROR ('Cleaning patient data - Patient CSIS/SSID - There are some invalid values that might be correctable', 0, 1) WITH NOWAIT
    
    /* Take the records that might be salvaged OFF our cleanup list */

    RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Saving invalid values that might be correctable', 0, 1) WITH NOWAIT
    
    delete 
      t1
    from @AllPatientsWithInvalidCSIS                   as t1
    join @PatientsWithInvalidCSISThatMightBeSalvagable as t2 on t2.PATIENT_ID = t1.PATIENT_ID

    RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Notifying staff about invalid values that might be correctable', 0, 1) WITH NOWAIT

    declare @rows as table (

       [Client]       nvarchar(255)
     , [ClientActive] nvarchar(255)
     , [LastName]    nvarchar(255)
     , [FirstName]   nvarchar(255)
     , [DateOfBirth] nvarchar(255)
     , [Active]      nvarchar(255)
     , [CSIS]         nvarchar(10)
     , [Created]      nvarchar(10)
     , [Updated]      nvarchar(10)
     , [LastPop]      nvarchar(10)
     , [RepName]      nvarchar(255)
     , [RepEmail]     nvarchar(255)
     , [PatientID]    nvarchar(255)
     , [ClientID]     nvarchar(255)
    )
    
    insert into @rows
    select
        cc.CLIENT_NAME        as [Client]
      , dbo.BIT_TO_YN(cc.LEA) as [ClientActive]
      , pap.LAST_NAME         as [LastName]
      , pap.FIRST_NAME        as [FirstName]
      , dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH) as [DateOfBirth]
      , pap.ACTIVE                          as [Active]
      , pap.CSIS                            as [CSIS]
      , [Created]   = dbo.RPT_DATE_FMT(pap.DATE_CREATED)
      , [Updated]   = dbo.RPT_DATE_FMT(pap.LAST_UPDATED)
      , [LastPop]   = dbo.RPT_DATE_FMT(pap.LASTPOP)
      , [RepName]   = cc.REP_NAME
      , [RepEmail]  = cc.REP_EMAIL
      , [PatientID] = pap.PATIENT_ID
      , [ClientID]  = cc.CLIENT_ID
     
    from @PatientsWithInvalidCSISThatMightBeSalvagable as t1
    join dbo.PATIENTS_Patient                          as pap on pap.PATIENT_ID = t1.PATIENT_ID
    join dbo.PATIENTS_Client                           as pc on pc.PATIENT_ID = pap.PATIENT_ID
    join dbo.CLIENTS_Client_All                        as cc on cc.CLIENT_ID  = pc.CLIENT_ID

    order by
      cc.CLIENT_NAME
    , pap.LAST_NAME
    , pap.FIRST_NAME
  
    declare @notifyEmails       as varchar(5000) = ''
    declare @html as nvarchar(max)
    set @notifyEmails = 'awebb@help4schools.com;anton@help4schools.com;rdonga@help4schools.com'
    
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
     + N'<h1>There Are Patient Records with CSIS/SSID Values That Are Invalid But May Be Correctable</h1>'
     + N'<h2>This is an automatically generated notice.  Please do not reply to it.</h2>'
     + N'<hr/>'  
     + N'<h3>Summary</h3>'
     + N'<p>'
     + N'As of <strong>' + dbo.RPT_DATE_FMT(GETDATE()) + '</strong> '
     + N'there are <strong>' + CONVERT(nvarchar,@numOfSalvSsid) + '</strong> ' 
     + N'patients that have CSIS/SSID values that may have originally had leading zeros but the zeros were lost during import.'
     + N' Details for each patient record and further instructions are provided below.'
     + N'</p>' 
     + N'<h3>Details For Each Patient Record</h3>'
     + N'<table>'
     + N'<tr>' +
     + N'<th>Client Name</th>'    
     + N'<th>Client<br/>Active</th>'
     + N'<th>Last Name</th>'
     + N'<th>First Name</th>'
     + N'<th>DOB</th>'
     + N'<th>Active</th>'
     + N'<th>CSIS</th>'
     + N'<th>Created</th>'
     + N'<th>Last<br/>Updated</th>'
     + N'<th>Last<br/>Populated</th>'
     + N'<th>Rep Name</th>'
     + N'<th>Rep Email</th>'
     + N'<th>Patient ID</th>'
     + N'<th>Client ID</th>'
     + N'</tr>'
   + CAST ( ( SELECT td = [Client],'',
     td = [ClientActive],'',
     td = [LastName],'',
     td = [FirstName],'',     
     td = [DateOfBirth],'',
     td = [Active],'',
     td = [CSIS],'',
     td = [Created],'',
     td = [Updated],'',
     td = [LastPop],'',
     td = [RepName],'',
     td = [RepEmail],'',
     td = [PatientID],'',
     td = [ClientID],''
     FROM @rows
     FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX))
   + N'</table>'   
   + N'<h3>Further Instructions</h3>'
   + N'<ul>'  
   + N'<li>Please click <a href="http://sbscitdev.help4schools.com/dokuwiki/doku.php?id=spedmon:patient-data-csis-cleanup">here</a> for further instructions.</li>'
   + N'<li><i>Please note: You must be on our internal network to access futher instructions</i></li>'
   + N'</ul>'  
   + N'<hr/>'
   + N'<p>'
   + N'CONFIDENTIALITY: This communication and any documents, files, or previous e-mail messages attached to it constitute an electronic communication within the scope of the Electronic Communication Privacy Act, 18 USCA 2510. This communication may contain non-public, confidential, or legally privileged information intended for the sole use of the designated recipient(s). The unlawful interception, use or disclosure of such information is strictly prohibited under 18 USCA 2511 and any applicable laws. If you are not the intended recipient of this communication, you are hereby notified to destroy all copies of this e-mail message and to contact the sender.'
   + N'</p>'
   + N'</body>'
   + N'</html>';
    
   EXEC msdb.dbo.sp_send_dbmail  
      @profile_name = 'SpEdCare_Batch_Task_Profile'  
    , @recipients   = @notifyEmails
    , @subject      = 'There Are Patient Records with Invalid CSIS/SSID Values'
    , @body         = @html
    , @body_format  = 'HTML'
    , @sensitivity  = 'Confidential';
   
  end
  else
  begin
    RAISERROR ('Cleaning patient data - Patient CSIS/SSID - There are no invalid values that might be correctable', 0, 1) WITH NOWAIT
  end
  
  /* Clean up all patient records that have an invalid CSIS */

  RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Updating patient records to clean up invalid values', 0, 1) WITH NOWAIT

  update pap
    set pap.CSIS = null  
  from dbo.PATIENTS_Patient        as pap
  join @AllPatientsWithInvalidCSIS as t2 on t2.PATIENT_ID = pap.PATIENT_ID
  where (pap.CSIS is not null)
  
  
end
else
begin
  RAISERROR ('Cleaning patient data - Patient CSIS/SSID - No invalid values found', 0, 1) WITH NOWAIT
end

RAISERROR ('Cleaning patient data - Patient CSIS/SSID - Done', 0, 1) WITH NOWAIT

RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLEAN_PATIENT_DATA_CSIS_SSID] TO [webuser]
GO
