USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW_CORE](
   @userID      BIGINT
 , @userGroup   INT
 , @userRank    INT
 , @appName     varchar(50)
 , @okToDisplay bit
 , @active      bit
 , @timeToDisplay bit
 , @refDate     datetime
 , @includeContent bit
 , @recID       bigint
)
RETURNS TABLE
AS
RETURN
(

/***************************************************************************
 * APP_MAN_PAGES_VIEW_CORE */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null
 * @return                 Table of user data
 ***************************************************************************/

select

 rowOrder = dense_rank ( ) over (
    order by
      mp.display_order 
    , mp.startDate
    , mp.title
    , mp.id
  )
 , mp.*
 , startDateStr       = dbo.RPT_DATE_FMT  (mp.startDate)
 , endDateStr         = dbo.RPT_DATE_FMT  (mp.endDate)
 , okToDisplayStr     = dbo.RPT_BIT_TO_YN (mp.okToDisplay)
 , ur.userRoleIdsStr       as forUserRoleIdValsStr
 , ur.userRoleNamesStr     as forUserRoleIdNamesStr

from dbo.APP_MAN_PAGES_DATA_CORE (
   @appName
 , @okToDisplay
 , @active
 , @timeToDisplay
 , @refDate
 , @includeContent
 , @recID) as mp

join dbo.APP_MAN_PAGES_FOR_USER_ROLES_VIEW_SUMMARY_CORE ( @appName ) as ur on ur.pageID = mp.id

)

GO

grant select on APP_MAN_PAGES_VIEW_CORE to webuser
GO
