USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[APP_MAN_PAGES_USER_RESPONSE_VIEW_STATS_SUMMARY_CORE] (
   @appName        as varchar(50)
  ,@userID         as bigint
  ,@responseTypeID as int
  ,@refDate        as datetime
  ,@pageID         as bigint
)
RETURNS TABLE 
AS
RETURN 
(

select 

   mp.id as pageID
,  responseData.*

from dbo.APP_MAN_PAGES_USER_ROLES_FOR_USER_ID_VIEW_CORE ( @appName, @userID ) as mpurfui                                                        
join dbo.AppManPagesForUserRoles                                              as mpur    on mpur.appManPageUserRoleID = mpurfui.id

join dbo.APP_MAN_PAGES_DATA_CORE ( @appName, 1, 1, 1, @refDate, 0, null )     as mp      on mp.id = mpur.pageID

left join [dbo].[Users]                                                                                         as u       on u.[userrid]   = @userID  --TODO: this query will only "work" if @userID is passed in
left join [dbo].[Membership]                                                                                    as mem     on mem.[UserId]  = u.[UserId]
left join dbo.AppManPagesForAppOrganizations                                                                    as mporg   on mporg.pageid  = mp.id 
    
cross apply (
  
  select 
      count(rl.id)     as numOfTimes
    , min(rl.loggedOn) as firstTime
    , max(rl.loggedOn) as lastTime
    
  from dbo.AppManPagesUserResponseLog as rl

  where (
        (rl.pageID        = mpur.pageID)
    and (rl.userUID       = mpurfui.userUID)
    and (rl.reponseTypeID = @responseTypeID)
  )

) as responseData

where (
      (1=1)
  and ((@pageID is null) or (mp.id = @pageID))
  and (mporg.organizationID IS NULL OR (mem.District_ID IS NULL AND mem.SBSC_Employee = 1) OR mem.District_ID = mporg.organizationID)  -- narrow down/weed out the results with a mismatching organizationID IF and only IF a @userID is passed in
)

)
go