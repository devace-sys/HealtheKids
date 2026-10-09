USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @transMgmtID            BIGINT
 , @sheetBatchID           BIGINT
 , @sheetCode              VARCHAR(512)
 , @routeID                BIGINT
 , @active                 BIT
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(
  select
  
      id              = tmar.id
    , name            = tmar.NAME
    , busNumber       = tmar.BUS_NUMBER
    , transMgmtID     = tmv.ID
    , clientID        = tmv.clientID
    , clientName      = tmv.clientName
    , pracID          = tmv.pracID
    , pracName        = tmv.pracName
    , setupClient      = tmv.setup
    , sheetBatchID     = tmar.SHEET_BATCH_ID
    , sheetCode        = tmar.SHEET_CODE
    , sheetID          = tmar.id
    , routeID          = tmar.ROUTE_ID
    , routeName        = tmr.NAME	
    , startDate        = tmar.MON_DATE
    , endDate          = tmar.FRI_DATE    
    , origName         = isnull(tmar.ORIG_NAME,'')
    , origAddress      = isnull(tmar.ORIG_ADDRESS,'')
    , origPlaceID      = tmar.ORIG_PLACE_ID    
    , destName         = isnull(tmar.DEST_NAME,'')
    , destAddress      = isnull(tmar.DEST_ADDRESS,'')
    , destPlaceID      = tmar.DEST_PLACE_ID    
    , distanceMiles    = tmar.DISTANCE_MILES
    , distanceMilesStr = isnull(convert(varchar(52),tmar.DISTANCE_MILES),'')            
    , monDateVal       = tmar.MON_DATE
    , tueDateVal       = tmar.TUE_DATE
    , wedDateVal       = tmar.WED_DATE
    , thuDateVal       = tmar.THU_DATE
    , friDateVal       = tmar.FRI_DATE    
    , monDateStr       = dbo.RPT_DATE_FMT(tmar.MON_DATE)
    , tueDateStr       = dbo.RPT_DATE_FMT(tmar.TUE_DATE)
    , wedDateStr       = dbo.RPT_DATE_FMT(tmar.WED_DATE)
    , thuDateStr       = dbo.RPT_DATE_FMT(tmar.THU_DATE)
    , friDateStr       = dbo.RPT_DATE_FMT(tmar.FRI_DATE)
    , weekOfServiceVal = DATEPART(week,tmar.REF_DATE)
    , sheetProcessed   = convert(bit,case when (trsp.ID is null) then 0 else 1 end)

    , busDriverID      = tmr.BUS_DRIVER_ID
    , busDriverName    = isnull(tmbd2.busDriverName,'')

  from      dbo.TRANSPORTATION_MGMT_VIEW (  @userID
                                          , @userGroup
                                          , @userRank
                                          , @clientID
                                          , @active
                                          , @transMgmtID)  as tmv
                                      
  join      dbo.TRANSPORTATION_MGMT_ROUTE_SHEET            as tmar on  tmar.CLIENT_ID              = tmv.clientID
                                                                   and tmar.TRANSPORTATION_MGMT_ID = tmv.id
  join      dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES      as tmr  on  tmr.ID                      = tmar.ROUTE_ID
  left join dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_PROCESSING as trsp on  trsp.SHEET_CODE             = tmar.SHEET_CODE
   
  outer apply (
    select top 1 
	   busDriverName = trim(trim(isnull(tmbd1.firstName,'')) + ' ' + trim(isnull(tmbd1.lastName,'')))
	from dbo.TRANSPORTATION_MGMT_BUS_DRIVERS as tmbd1
    where (tmbd1.id = tmr.BUS_DRIVER_ID)
  ) as tmbd2

  where ( 
        (1=1)
    and ((@sheetBatchID is null) or (tmar.SHEET_BATCH_ID = @sheetBatchID))
    and ((@sheetCode    is null) or (tmar.SHEET_CODE     = @sheetCode))
    and ((@routeID      is null) or (tmar.ROUTE_ID       = @routeID)) 
    and ((@active       is null) or (tmar.ACTIVE         = @active))
    and ((@recID        is null) or (tmar.id             = @recID))
  )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_ROUTE_SHEETS_VIEW_CORE] TO [webuser]
GO