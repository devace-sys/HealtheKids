USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_KIOSK_GET_BY_PTKN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTICE_OFFICE_KIOSK_GET_BY_PTKN
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PRACTICE_OFFICE_KIOSK_GET_BY_PTKN] (  
  @ptkn varchar(512)
) 
RETURNS TABLE
AS RETURN (  
 
select top 1
     pok.id
   , kioskName            = pok.[name]
   , clientName           = clc.CLIENT_NAME
   , siteName             = ss.SITE_NAME
   , practiceName         = gscn.GROUP_SERVICE_CLASS_NAME
   , pok.startTime
   , pok.endTime
   , startTimeStr         = dbo.RPT_TIME_FMT(pok.startTime,0) 
   , endTimeStr           = dbo.RPT_TIME_FMT(pok.endTime,0) 
   , clientLogoFileBase64 = clc.clientlogofiledata   
   , pok.groupSvcClassNameID
   , pok.clientID
   , pok.siteID

from dbo.PRACTICE_OFFICE_KIOSKS          as pok
join dbo.CLIENTS_Client                  as clc   on  clc.CLIENT_ID = pok.clientID
join dbo.SITES_Site                      as ss    on  ss.SITE_ID    = pok.siteID
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as gscn  on gscn.GROUP_SERVICE_CLASS_NAME_ID = pok.groupSvcClassNameID

where (
        (pok.publicToken = @ptkn)
    and (pok.active = 1)
)
 
)
GO
 

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTICE_OFFICE_KIOSK_GET_BY_PTKN] TO [webuser]
GO
 
