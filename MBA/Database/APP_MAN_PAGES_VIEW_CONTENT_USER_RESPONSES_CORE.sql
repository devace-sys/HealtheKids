USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CONTENT_USER_RESPONSES_CORE] (  
     @userID              BIGINT    
   , @userGroup           INT    
   , @userRank            INT
   , @appName             varchar(50)
   , @clientID            bigint 
   , @userNotifiedByEmail bit
   , @userHasSeen         bit
   , @userWillReadLater   bit
   , @userHasRead         bit
   , @pageID              bigint
)

RETURNS 
@recs table (
   rowOrder            bigint
 , userID              bigint
 , userGroup           int
 , userRank            int
 , userDistrictID      bigint
 , userDistrictName    nvarchar(max)
 , userName            nvarchar(512)
 , userLastName        nvarchar(256)
 , userFirstName       nvarchar(256)
 , userEmail           nvarchar(512)
 , userRoleName        nvarchar(512)
 , userSendEmailNotifications  bit
 , manPageID           bigint
 , manPageTitle        varchar(512)

 , manPageStartDate    datetime
 , manPageStartDateStr varchar(50)
 , manPageDescription varchar(max)

 , userResponseNotifiedByEmail bit
 , userResponseUserHasSeen     bit
 , userResponseWillReadLater   bit
 , userResponseHasRead         bit
 
 , userResponseNotifiedByEmailFirst datetime
 , userResponseNotifiedByEmailLast  datetime
 , userResponseNotifiedByEmailCount int

 , userResponseSeenFirst            datetime
 , userResponseSeenLast             datetime
 , userResponseSeenCount            int
  
 , userResponseWillReadLaterFirst  datetime
 , userResponseWillReadLaterLast   datetime
 , userResponseWillReadLaterCount  int
  
 , userResponseHasReadFirst        datetime
 , userResponseHasReadLast         datetime
 , userResponseHasReadCount        int
)
AS
BEGIN

/***************************************************************************
 * APP_MAN_PAGES_VIEW_CONTENT_RESPONSES_CORE */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 

declare @users as table (
   userID         bigint
 , userGroup      int
 , userRank       int
 , userDistrictID int
 , userDistrictName nvarchar(max)
 , userName       nvarchar(512)
 , userLastName   nvarchar(256)
 , userFirstName  nvarchar(256)
 , userEmail      nvarchar(512)
 , userRoleName   nvarchar(512)
 , sendEmailNotifications  bit
)

declare @today as datetime = getdate()

insert into @users
select 
  q1.*
from
(
  select
      userID         = u.userrid
    , userGroup      = rd.userGroup
    , userRank       = rd.rank
    , userDistrictID   = isnull(m.District_ID,0)
    , userDistrictName = isnull(cc.CLIENT_NAME,'Practi-Cal')
    , userName       = u.UserName
    , userLastName   = m.LastName
    , userFirstName  = m.FirstName
    , userEmail      = trim(isnull(m.Email,N''))
    , userRoleName   = r.RoleName
    , sendEmailNotifications = m.sendUserEmailNotifications
  
  from dbo.Users        as u
  join dbo.Membership   as m   on m.UserId   = u.UserId
  join dbo.UsersInRoles as uir on uir.UserId = u.UserId
  join dbo.Roles        as r   on r.RoleId   = uir.RoleId
  join dbo.RoleData     as rd  on rd.RoleId  = r.RoleId
  
  left join Spedmon.dbo.CLIENTS_Client as cc on cc.CLIENT_ID = m.District_ID
  
  where (
        (r.RoleId != dbo.CONST_ROLE_INACTIVE())
    and (UserName not like N'%@QUIT@%')
    and (rd.appName = @appName)
    
  )
) as q1

where ( 
      (1=1)  
  and ((@clientID is null) or (userDistrictID = @clientID))
)

insert into @recs
select 
    rowOrder = dense_rank ( ) over ( 
    order by 
      t1.userDistrictName
    , t1.userLastName
    , t1.userFirstName
    , t2.startDate
    , t2.title
    , t1.userID
    , t2.id
  )
  , userID           = t1.userID
  , userGroup        = t1.userGroup
  , userRank         = t1.userRank
  , userDistrictID   = t1.userDistrictID
  , userDistrictName = t1.userDistrictName
  , userName         = t1.UserName
  , userLastName     = t1.userLastName
  , userFirstName    = t1.userFirstName
  , userEmail        = t1.userEmail
  , userRoleName     = t1.userRoleName
  , userSendEmailNotifications = t1.sendEmailNotifications
  , manPageID           = t2.id
  , manPageTitle        = t2.title

  , manPageStartDate    = t2.startDate
  , manPageStartDateStr = t2.startDateStr
  , manPageDescription  = t2.description

  , userResponseNotifiedByEmail = t2.userNotifiedByEmail
  , userResponseUserHasSeen     = t2.userHasSeen
  , userResponseWillReadLater   = t2.userWillReadLater
  , userResponseHasRead         = t2.userHasRead
  
  , userResponseNotifiedByEmailFirst = t2.notifiedByEmailFirstTime
  , userResponseNotifiedByEmailLast  = t2.notifiedByEmailLastTime
  , userResponseNotifiedByEmailCount = t2.notifiedByEmailNumTimes

  , userResponseSeenFirst            = t2.seenFirstTime
  , userResponseSeenLast             = t2.seenLastTime
  , userResponseSeenCount            = t2.seenNumTimes
  
  , userResponseWillReadLaterFirst  = t2.willReadLaterFirstTime
  , userResponseWillReadLaterLast   = t2.willReadLaterLastTime
  , userResponseWillReadLaterCount  = t2.willReadLaterNumTimes
  
  , userResponseHasReadFirst        = t2.hasReadFirstTime
  , userResponseHasReadLast         = t2.hasReadLastTime
  , userResponseHasReadCount        = t2.hasReadNumOfTimes
  
from @users as t1

cross apply (
  select 
    t0.* 
  from dbo.APP_MAN_PAGES_VIEW_CONTENT_CORE ( 
     t1.userID          
   , t1.userGroup
   , t1.userRank
   , @appName
   , @userNotifiedByEmail
   , @userHasSeen        
   , @userWillReadLater
   , @userHasRead
   , @today

   , null  -- welcome_new_user
   , 0     -- includeContent
   , @pageID
   ) as t0
) as t2


return

END  

GO


