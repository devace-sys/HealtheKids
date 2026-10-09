USE users
GO

/*
 * Note: This is the udf that is ultimately the source of email notifications for man pages
 */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS](  
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT
  , @appName             varchar(50)
  , @clientID            bigint
)

RETURNS 

@recs table (
   userID                     bigint
 , userGroup                  int
 , userRank                   int
 , userName                   nvarchar(512)
 , userLastName               nvarchar(256)
 , userFirstName              nvarchar(256)
 , userEmail                  nvarchar(512)
 , manPageIDs                               varchar(max)
 , manPageTitleStartdateDescriptionJSONarrs varchar(max) 
)

as
begin

  declare @manPagesDetail as table (
     userID                    bigint
   , userGroup                 int
   , userRank                  int
   , userName                  nvarchar(512)
   , userLastName              nvarchar(256)
   , userFirstName             nvarchar(256)
   , userEmail                 nvarchar(512)
   , manPageIDStr              varchar(100)
   , manPageTitleStartdateDescriptionJSONarr varchar(max)   
  )
  
  insert into @manPagesDetail (
     userID       
   , userGroup  
   , userRank   
   , userName   
   , userLastName 
   , userFirstName 
   , userEmail  
   , manPageIDStr 
   , manPageTitleStartdateDescriptionJSONarr 
  )
  select 
      userID 
    , userGroup
    , userRank
    , userName 
    , userLastName 
    , userFirstName 
    , userEmail 
    , manPageIDStr             = convert(varchar(50), manPageID)
    , manPageTitleStartdateDescriptionJSONarr = '{manPageTitle: "' + manPageTitle + '", manPageStartDateStr: "' + 
                                                  manPageStartDateStr + '", manPageDescription: "' + manPageDescription + '"}'
     
  from dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_CORE (  
      @userID   
    , @userGroup
    , @userRank
    , @appName
    , @clientID
    , 0
    , 0 /* @userHasSeen */
    , null
    , null
    , null ) as t1  
  where (
        ((len(t1.userEmail) != 0) and (t1.userSendEmailNotifications = 1))
    --and (CAST(manPageStartDate AS DATE) <= CAST(GETDATE() AS DATE))
	and (t1.userEmail not like N'@QUIT@%')
  )

  insert into @recs (
      userID
    , userGroup
    , userRank
    , userName
    , userLastName
    , userFirstName
    , userEmail
    , manPageIDs
    , manPageTitleStartdateDescriptionJSONarrs 
  )
  select 
      t1.userID
    , t1.userGroup
    , t1.userRank
    , t1.userName
    , t1.userLastName
    , t1.userFirstName
    , t1.userEmail
    , manPageIDs                = t2.manPageIDs
    , manPageTitleStartdateDescriptionJSONarrs = '[' + t3.manPageTitleStartdateDescriptionJSONarrs + ']'
  
  from @manpagesDetail as t1
  
  cross apply ( 
    select manPageIDs = stuff((select distinct N',' + t3.manPageIDStr from @manPagesDetail as t3 where t3.userID = t1.userID for xml path(''),type).value('text()[1]','nvarchar(max)'),1,1,N'') 
                                      -- the DISTINCT here eliminates the crash, the error that's frequently appearing from line 82 of APP_MAN_PAGE_LOG_USER_RESPONSES
                                      -- "Duplicate record ids are not allowed"
  ) as t2
  
  cross apply (
      select manPageTitleStartdateDescriptionJSONarrs = stuff((select distinct  ',' + t4.manPageTitleStartdateDescriptionJSONarr from @manPagesDetail as t4 where t4.userID = t1.userID for xml path(''),type).value('text()[1]','nvarchar(max)'),1,1,N'')  
  ) as t3
  
  group by 
      t1.userID
    , t1.userGroup
    , t1.userRank
    , t1.userName
    , t1.userLastName
    , t1.userFirstName
    , t1.userEmail
    , t2.manPageIDs
    , t3.manPageTitleStartdateDescriptionJSONarrs
  
  return

end
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_NOTIFICATIONS] TO [webuser]
GO