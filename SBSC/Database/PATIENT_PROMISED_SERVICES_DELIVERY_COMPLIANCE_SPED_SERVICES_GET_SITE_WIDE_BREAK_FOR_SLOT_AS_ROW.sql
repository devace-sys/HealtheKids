USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SITE_WIDE_BREAK_FOR_SLOT_AS_ROW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SITE_WIDE_BREAK_FOR_SLOT_AS_ROW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SITE_WIDE_BREAK_FOR_SLOT_AS_ROW] (
    @clientID        bigint
  , @patID           bigint
  , @planStartDate   datetime
  , @planEndDate     datetime
  , @spEdFreqCode    int
  , @minsPerFreq     int
  , @dosStart        datetime
  , @dosEnd          datetime
) 
RETURNS table
AS
return
(     
  with
  cte_p1
  as
  (
    select top 1 
      ps.SITE_ID 
    from dbo.PATIENT_SITES_GET(@patID) as ps  
    where( 
           (ps.PATIENT_ID = @patID)
	  and  (@dosStart between ps.START_DATE and ps.END_DATE)
	)
    order by 
      ps.PATIENT_SCHOOL_ID desc
  )
  ,
  cte_p2
  as
  (
  select top 1 
    ssb.id
  from cte_p1                           as p1                                               
  join dbo.CLIENT_SCHOOL_SESSION_BREAKS as ssb on (
                                                   ((ssb.clientID = @clientID)
                                               and (ssb.siteID = p1.SITE_ID)
                                               and ((@planStartDate <= ssb.endDate) and (@planEndDate >= ssb.startDate)) /*(StartA <= EndB) and (EndA >= StartB)*/
											   and (ssb.id is not null)) /* Index predicate */
											   and (ssb.clientWideBreak = 0)
                                               and (ssb.active = 1)
											   ) 
  where  (((@dosStart >= ssb.startDate) and (@dosEnd <= ssb.endDate)) /* Eliminate dups*/)
 )
 select  
   meb2.totMins 
 from cte_p2
 cross apply (
   select top 1 meb1.totMins 
   from dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_BREAK_AS_ROW (@dosStart, @dosEnd, @spEdFreqCode, @minsPerFreq) as meb1 
 ) as meb2
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PROMISED_SERVICES_DELIVERY_COMPLIANCE_SPED_SERVICES_GET_SITE_WIDE_BREAK_FOR_SLOT_AS_ROW] TO [webuser]
GO