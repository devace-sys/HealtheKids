USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_REPORT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_REPORT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_REPORT_VIEW] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int
 , @clientID               bigint
)
returns table as return
(

with
cte_p1
as
(
  select 
      rs.CLIENT_ID
    , rsm.PATIENT_ID
    , rs.ROUTE_ID
    , rsm.ORIG_PLACE_ID
    , rsm.DEST_PLACE_ID
    , rsm.ORIG_NAME
    , rsm.DEST_NAME
    , START_DATE = min(rs.MON_DATE)
    , END_DATE   = max(rs.FRI_DATE)
  
  from dbo.TRANSPORTATION_MGMT_ROUTE_SHEET         as rs
  join dbo.TRANSPORTATION_MGMT_ROUTE_SHEET_MEMBERS as rsm on rsm.ROUTE_SHEET_ID = rs.ID
  
  where (rs.CLIENT_ID = @clientID)
  
  group by
  
      rs.CLIENT_ID
    , rsm.PATIENT_ID
    , rs.ROUTE_ID
    , rsm.ORIG_PLACE_ID
    , rsm.DEST_PLACE_ID
    , rsm.ORIG_NAME
    , rsm.DEST_NAME
  
)
,
cte_p2
as
(
  select distinct
      rsm.CLIENT_ID
    , rsm.PATIENT_ID
    , rsm.ROUTE_ID
    , rsm.ORIG_NAME
    , rsm.DEST_NAME
    , rsm.START_DATE
    , rsm.END_DATE
    , tc.ID
  from cte_p1                                      as  rsm
  join dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS   as  tc on  tc.ORIG_PLACE_ID = rsm.ORIG_PLACE_ID                                                           
                                                          and tc.DEST_PLACE_ID = rsm.DEST_PLACE_ID 
  where (tc.DISTANCE_MILES is not null)
)
,
cte_p3
as
(
  select 
      tc.CLIENT_ID
    , tc.PATIENT_ID
    , tc.ROUTE_ID
    , ORIG_NAME
    , DEST_NAME 
    , START_DATE
    , END_DATE
    , tcad.ORIGIN_IN
    , tcad.DESTINATION_IN
    , tcad.DISTANCE_MILES
    , tcad.MAPS_URL
    , TRIP_DATA_LAST_UPDATED = MAX(tcad.CREATED_ON)
    
  from cte_p2 as tc
  join dbo.TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_DATA as tcad on tcad.TRIP_CALCULATION_ID = tc.ID
  group by
      tc.CLIENT_ID
    , tc.PATIENT_ID
    , tc.ROUTE_ID
    , ORIG_NAME
    , DEST_NAME 
    , START_DATE
    , END_DATE
    , tcad.ORIGIN_IN
    , tcad.DESTINATION_IN
    , tcad.DISTANCE_MILES
    , tcad.MAPS_URL
)
select 
  p3.*
 ,pap.LAST_NAME
 ,pap.FIRST_NAME
 ,pap.DATE_OF_BIRTH
 ,pap.CSIS
 ,tmar.NAME
 ,tmar.BUS_NUMBER
  
from cte_p3               as p3
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = p3.PATIENT_ID                                                                  
join dbo.TRANSPORTATION_MGMT_AUTHORIZED_ROUTES as tmar on tmar.ID = p3.ROUTE_ID
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_TRIP_CALCULATIONS_AUDIT_REPORT_VIEW] TO [webuser]
GO