USE users
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CONTENT_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CONTENT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CONTENT_CORE](  
     @userID              BIGINT    
   , @userGroup           INT    
   , @userRank            INT
   , @appName             varchar(50)
   , @userNotifiedByEmail bit
   , @userHasSeen         bit
   , @userWillReadLater   bit
   , @userHasRead         bit
   , @refDate             datetime
   , @welcome_new_user    bit
   , @includeContent      bit
   , @pageID              bigint
)

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * APP_MAN_PAGES_VIEW_CONTENT_CORE */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null 
 * @return                 Table of user data
 ***************************************************************************/ 
 
with
cte_p1
as
(
  select  
      mp.*
  
    , NotifiedByEmail.firstTime  as notifiedByEmailFirstTime
    , NotifiedByEmail.lastTime   as notifiedByEmailLastTime
    , NotifiedByEmail.numOfTimes as notifiedByEmailNumTimes
    
    , Seen.firstTime             as seenFirstTime
    , Seen.lastTime              as seenLastTime
    , Seen.numOfTimes            as seenNumTimes
  
    , WillReadLater.firstTime    as willReadLaterFirstTime
    , WillReadLater.lastTime     as willReadLaterLastTime
    , WillReadLater.numOfTimes   as willReadLaterNumTimes
  
    , HasRead.firstTime          as hasReadFirstTime
    , HasRead.lastTime           as hasReadLastTime
    , HasRead.numOfTimes         as hasReadNumOfTimes
    
    , userNotifiedByEmail = convert(bit,case when NotifiedByEmail.numOfTimes > 0 then 1 else 0 end)
    , userHasSeen         = convert(bit,case when Seen.numOfTimes            > 0 then 1 else 0 end)
    , userWillReadLater   = convert(bit,case when WillReadLater.numOfTimes   > 0 then 1 else 0 end)
    , userHasRead         = convert(bit,case when HasRead.numOfTimes         > 0 then 1 else 0 end)

  from dbo.APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE (@appName,@userID)                                      as mpurfui  
  join dbo.AppManPagesForUserRoles                                                                                as mpur    on mpur.appManPageUserRoleID  = mpurfui.id

  join dbo.APP_MAN_PAGES_VIEW_CORE (@userID,@userGroup,@userRank,@appName,1,1,1,@refDate,@includeContent,@pageID) as mp      on mp.id                      = mpur.pageID

  left join [dbo].[Users]                                                                                         as u       on u.[userrid] = @userID  --TODO: this query will only "work" if @userID is passed in
  left join [dbo].[Membership]                                                                                    as mem     on mem.[UserId]  = u.[UserId]
  left join dbo.AppManPagesForAppOrganizations                                                                    as mporg   on mporg.pageid  = mp.id 

  outer apply (
    select top 1          
        numOfTimes
      , firstTime
      , lastTime     
    from dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE (@appName, mpurfui.userID,4,@refDate,mpur.pageID)
  ) as NotifiedByEmail
  
  outer apply (
    select top 1          
        numOfTimes
      , firstTime
      , lastTime 
    from dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE (@appName, mpurfui.userID,1,@refDate,mpur.pageID)
  ) as Seen

  outer apply (
    select top 1          
        numOfTimes
      , firstTime
      , lastTime     
    from dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE (@appName, mpurfui.userID,2,@refDate,mpur.pageID)
  ) as WillReadLater
  
  outer apply (
    select top 1          
        numOfTimes
      , firstTime
      , lastTime     
    from dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE (@appName, mpurfui.userID,3,@refDate,mpur.pageID)
  ) as HasRead
    
  where (
         (1=1)
    and ((@pageID is null) or (mpur.pageID  = @pageID))
    and (mporg.organizationID IS NULL OR (mem.District_ID IS NULL AND mem.SBSC_Employee = 1) OR mem.District_ID = mporg.organizationID)  -- narrow down/weed out the results with a mismatching organizationID IF and only IF a @userID is passed in
  )
)
,
cte_p2
as
(
  select 
     p1.*      
  from cte_p1 as p1
  where (
        (1=1)
     and ((@userNotifiedByEmail is null) or (p1.userNotifiedByEmail        = @userNotifiedByEmail))
     and ((@userHasSeen         is null) or (p1.userHasSeen                = @userHasSeen))
     and ((@userWillReadLater   is null) or (p1.userWillReadLater          = @userWillReadLater))
     and ((@userHasRead         is null) or (p1.userHasRead                = @userHasRead))
     and ((@welcome_new_user    is null) or (p1.include_in_welcome_package = @welcome_new_user) )

  )
)

select 
  p2.* 
from cte_p2 as p2


)  

GO
