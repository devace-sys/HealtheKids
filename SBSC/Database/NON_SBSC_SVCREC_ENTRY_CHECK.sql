USE SPEDMON;
GO
IF OBJECT_ID (N'NON_SBSC_SVCREC_ENTRY_CHECK', N'IF') IS NOT NULL
    DROP FUNCTION NON_SBSC_SVCREC_ENTRY_CHECK;
GO


CREATE FUNCTION NON_SBSC_SVCREC_ENTRY_CHECK
	(
		@client_name as nvarchar(max),
		@startCreateDate as datetime,
		@endCreateDate as datetime
	)
	
RETURNS table
as

RETURN
(



/* This was a basic report query created (At TR's request) for Eileen Whitlock on 20131203 as a  
	way to quickly see if practitioners/people at the district were putting
	in their own work.
	
	This is intended only for TEMPORARY use before being put into reporting circulation. */
	

select
      client_practitioners.CONCAT_NAME as 'Practitioner Who Performed Service/Batch Filename'
	  ,ISNULL(client_svcrecs.Email, 'No Service Records Entered') as 'E-mail of Person Who Entered the Service Record/Worktype'
      ,SUM(CASE when client_svcrecs.svc_type is not NULL AND ( client_svcrecs.svc_type =  dbo.CONST_SERVICES_ASSESS()) then 1 else 0 END) as 'Assessments Recorded this Period'
      ,SUM(CASE when client_svcrecs.svc_type is not NULL AND ( client_svcrecs.svc_type =  dbo.CONST_SERVICES_TREATMENT() 
				  or client_svcrecs.svc_type = dbo.CONST_SERVICES_TRANSPORT()) then 1 else 0 END) as 'Treatment/Therapy/Transportation Recorded this Period'
      ,SUM(CASE when client_svcrecs.svc_type is not NULL AND ( client_svcrecs.svc_type =  dbo.CONST_SERVICES_TCM()) then 1 else 0 END) as 'TCM Encounters Recorded this Period'
      ,isnull(CONVERT(varchar(max),CONVERT(date,Min(client_svcrecs.dos))),'') as 'Oldest Service Recorded'
      ,isnull(CONVERT(varchar(max),CONVERT(date,Max(client_svcrecs.dos))),'') as 'Newest Service Recorded'


  FROM 
  
  (
	select pp.*
	FROM
		[SPEDMON].[dbo].[PRACTITIONER_Practitioner] as pp
		join PRACTITIONER_Client as pc 
			on pc.PRACTITIONER_ID = pp.PRACTITIONER_ID
			and pp.active = 1
		join CLIENTS_Client cc on pc.CLIENT_ID = cc.CLIENT_ID and cc.CLIENT_NAME = @client_name
	) client_practitioners
	
	left outer join
	(
	select sr.*, sva.svc_type, um.email
	from 
	CLIENTS_Client cc 
	inner join SERVICE_RECORDS as sr 
		on sr.clientid = cc.client_id and cc.CLIENT_NAME = @client_name
      and sr.created >= DATEADD(dd,-(DAY(@startcreatedate)-1),@startcreatedate) /* Start of month */
      and sr.created <= DATEADD(dd,-(DAY(DATEADD(mm,1,@startcreatedate))),DATEADD(mm,1,@startcreatedate)) /* End of month */

	inner join SERVICES_VIEW_ALL() sva on sva.name_id = sr.nameID and sva.prac_group_id = sr.groupID
  inner join users.dbo.Users as uu on uu.userrid = sr.userID
  inner join users.dbo.Membership as um on um.UserId = uu.UserId and um.SBSC_Employee = 0
   ) client_svcrecs
   on client_svcrecs.pracid = client_practitioners.practitioner_id
           
  group by
		client_practitioners.CONCAT_NAME 
	  ,client_svcrecs.Email 
	  
UNION ALL

select 
	filename, 
	worktype, 
	0,0,0, 
	isnull(CONVERT(varchar(max),CONVERT(date,oldestdateofservice)),''), 
	'' 
from 
	input_batches_view (NULL ,null,null,null,null,null,null,null,null) ibv
where 
	1=1
	and ibv.client = @client_name 
	and ibv.dateonfile >= DATEADD(dd,-(DAY(@startcreatedate)-1),@startcreatedate) /* Start of month */
	and ibv.dateonfile <= DATEADD(dd,-(DAY(DATEADD(mm,1,@startcreatedate))),DATEADD(mm,1,@startcreatedate)) /* End of month */
)


;
GO
USE SPEDMON

GRANT SELECT ON [dbo].[NON_SBSC_SVCREC_ENTRY_CHECK] TO [HELP4SCHOOLS\ewhitlock]
GRANT SELECT ON [dbo].[INPUT_BATCHES_VIEW] TO [HELP4SCHOOLS\ewhitlock]

GO

use [users]
GO
GRANT SELECT ON [dbo].[USERS_VIEW_CORE] TO [HELP4SCHOOLS\ewhitlock]

GO


