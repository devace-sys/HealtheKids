USE spedmon
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_AND_MANPAGE_COMBINED_SEARCH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_AND_MANPAGE_COMBINED_SEARCH
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGE_AND_MANPAGE_COMBINED_SEARCH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGE_AND_MANPAGE_COMBINED_SEARCH
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[NEWSLETTER_PAGE_AND_MANPAGE_COMBINED_SEARCH] (

     @userID                  bigint
   , @userGroup               int   
   , @userRank                int

   , @clientID                bigint

   , @appName        varchar(50)
   
   , @navURLManPage         varchar(250)
   , @navURLMultimediaPage  varchar(250)

   , @term               varchar(256)

   , @recID              bigint
     -- NOT USED

)


RETURNS TABLE
AS
RETURN

(

with 
cte_newsletters_base
as
(
  select top 1 currentDate = convert(datetime, convert(date,getdate()))
)
,
cte_newsletters_by_manpage_role
as
(
select 
  q1.* 
from cte_newsletters_base as p0
cross apply (
    select     
      np.id
    , [name]     = np.title
    , np.tooltip
from users.dbo.APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE('spedcare',@userID) as mpur
join dbo.NewsletterPagesForUserRoles as npur on npur.userRoleID = mpur.id
join dbo.NewsletterPages             as np   on np.id           = npur.pageID
where (
      (np.isResourceLibraryTopic = 1)
  and (np.readyToSend            = 1)
  and (np.startDate <= p0.currentDate)
  and (np.active                 = 1)
  and (dbo.IS_TERM_IN_TAGS(@term, np.tags,1) = 1)
)
) as q1
)
,
cte_newsletters_by_contact_role
as
(
select 
  q1.* 
from cte_newsletters_base as p0
cross apply (
    select     
      np.id
    , [name]     = np.title
    , np.tooltip
from dbo.CLIENTS_Contacts               as cc
join dbo.NewsletterPagesForContactRoles as npcr on npcr.contactRoleID = cc.contactRoleID
join dbo.NewsletterPages                as np   on np.id              = npcr.pageID
where (
      (((cc.clientID      = @clientID)
  and (cc.contactUserID = @userID))
  and (cc.active = 1))
  and (np.isResourceLibraryTopic = 1)
  and (np.readyToSend            = 1)
  and (np.startDate <= p0.currentDate)
  and (np.active                 = 1)
  and (dbo.IS_TERM_IN_TAGS(@term, np.tags,1) = 1)
)
) as q1
)
,
cte_newsletters_combine
as
(
select * from cte_newsletters_by_manpage_role
union
select * from cte_newsletters_by_contact_role
)
,
cte_newsletters_filter_by_client_only_p1
as
(
select 
    t1.* 
  , [navToURL]            = @navURLMultimediaPage + CAST( t1.id as varchar)
  , [contentFrom]         = 'newsletter'
  , pageIsForClientIDOnly = iif ((npfc2.id is null),0,1)
  , pageForClientID       = isnull(npfc2.pageForClientIDOnly,-1)
from cte_newsletters_combine as t1
outer apply (
  select top 1 
       npfc1.id
	 , pageForClientIDOnly = npfc1.clientID	
  from dbo.NewsletterPagesForClients as npfc1 
  where     
    (npfc1.pageID = t1.id)	
) as npfc2
)
,
cte_newsletters_filter_by_client_only_p2
as
(
  select
    p1.* 
  , okToInclude = convert(bit, (case 
                    when p1.pageIsForClientIDOnly = 0 then 1
				    when p1.pageIsForClientIDOnly = 1 then iif((p1.pageForClientID = @clientID),1,0)      
                    else 0
                  end))
  from cte_newsletters_filter_by_client_only_p1 as p1
)

select  
      p2.id
    , p2.[name] 
    , p2.tooltip
	, p2.[navToURL] 
	, p2.[contentFrom] 
from cte_newsletters_filter_by_client_only_p2 as p2
where 
  (p2.okToInclude = 1)

union

select
    id,
    [title] as [name],
    [description]      as tooltip ,
    @navURLManPage + CAST( id as varchar)  as [navToURL],
	[contentFrom] = 'manpage'
    -- 0       as [isMultiMedia]
  from
  [users].[dbo].[APP_MAN_PAGES_VIEW_CONTENT](  
     @userID             
   , @userGroup           
   , @userRank        
   , @appName  
   , null -- @userHasRead    bit
   , null -- @refDate        datetime

   , null -- @welcome_new_user  bit
   , 0 -- @includeContent    bit

   , @recID
)  mp_c
where 
  (mp_c.[title] like ( '%' + @term + '%' ))
)
GO


GRANT SELECT ON  dbo.[NEWSLETTER_PAGE_AND_MANPAGE_COMBINED_SEARCH]  TO [webuser]
GO

