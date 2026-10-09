USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_STATUS_REPORT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_STATUS_REPORT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_STATUS_REPORT_VIEW] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int
 , @clientID               bigint
)
returns table as return
(

select 
    SHEET_ID = t1.ID
  , t1.NAME
  , t1.BUS_NUMBER
  , t1.SHEET_CODE
  , t1.MON_DATE
  , t1.FRI_DATE
  , SHEET_PROC_ID = t2.ID 
  , PRINTED_ON    = t1.CREATED_ON 
  , ENTERED_ON    = t2.CREATED_ON
 
from       dbo.TRANSPORTATION_MGMT_ROUTE_SHEET            as t1
left join  dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING as t2 on t2.SHEET_ID = t1.ID
where (
      (t1.CLIENT_ID = @clientID)
  and (t1.ACTIVE    = 1)
)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING_STATUS_REPORT_VIEW] TO [webuser]
GO