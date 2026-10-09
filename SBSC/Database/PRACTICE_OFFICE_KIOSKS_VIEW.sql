USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_KIOSKS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTICE_OFFICE_KIOSKS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTICE_OFFICE_KIOSKS_VIEW] (  
    @userID              bigint
  , @userGroup           int 
  , @userRank            int  
  , @clientID            bigint
  , @groupSvcClassNameID bigint
  , @active              bit
  , @recID               bigint
) 
RETURNS TABLE
AS RETURN (  
 
select
   pok.*
 , siteName           = ss.SITE_NAME
 , groupSvcClassName  = gscn.GROUP_SERVICE_CLASS_NAME
 , startTimeStr       = dbo.RPT_TIME_FMT(pok.startTime,0) 
 , startTimeHHMMStr   = dbo.RPT_TIME_FMT_HH_MM_SS(pok.startTime,0)
 , endTimeStr         = dbo.RPT_TIME_FMT(pok.endTime,0) 
 , endTimeHHMMStr     = dbo.RPT_TIME_FMT_HH_MM_SS(pok.endTime,0)
   
from dbo.PRACTICE_OFFICE_KIOSKS          as pok
join dbo.SITES_Site                      as ss    on ss.SITE_ID  = pok.siteID
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as gscn  on gscn.GROUP_SERVICE_CLASS_NAME_ID = pok.groupSvcClassNameID
where (
           (1=1)    
    and (pok.clientID = @clientID)
    and ((@groupSvcClassNameID is null) or (pok.groupSvcClassNameID = @groupSvcClassNameID))
    and ((@active    is null)  or (pok.active    = @active))
    and ((@recID     is null)  or (pok.id        = @recID))
)
 
)
GO
 

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTICE_OFFICE_KIOSKS_VIEW] TO [webuser]
GO
 
