USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_VIEW_DEFAULT_DATES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_GOALS_VIEW_DEFAULT_DATES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_GOALS_VIEW_DEFAULT_DATES] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @patID               BIGINT
  , @groupSvcClassNameID BIGINT
  , @refDate             DATETIME 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_GOALS_VIEW_DEFAULT_DATES */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN

with
cte_p1
as
(
  select top 1
    startDate = convert(date,
	                    coalesce( svcDates.svcCurrStartDate
                                , pap.spEdLastAnnualIEPDate
	                            , pap.spEdLastEvalDate
                                , pap.spEdNextAnnualIEPDate
	                            , @refDate ))
   
   from dbo.PATIENTS_Client  as pc 
   join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pc.PATIENT_ID

   outer apply (
     select top 1     
           svcCurrStartDate = pps.startDate
	
     from dbo.PATIENTS_PROMISED_SERVICES                 as pps  
     join dbo.SpEd_Service_Xref_Group_Service_Class_Name as cscn on cscn.spEdServiceCodeValue = pps.spEdServiceCode
     where (
           (pps.patID = pap.PATIENT_ID)
	  and (cscn.active = 1)
	  and (cscn.groupServiceClassNameID = @groupSvcClassNameID)
      and (pps.startDate is not null)
	  and (pps.active = 1)
      and (cscn.active = 1)
     )
     order by          
	     pps.startDate desc
    ) as svcDates  
    where (
          (pc.CLIENT_ID = @clientID)
	  and (pc.PATIENT_ID = @patID)
	   
    )
)
,
cte_p2
as
(

select top 1 
    clientID            = @clientID
  , patID               = @patID
  , groupSvcClassNameID = @groupSvcClassNameID
  , p1.startDate
  , endDate = convert(date,(dateadd(year, 1, p1.startDate)))
from cte_p1 as p1
)
,
cte_p3
as
(
select top 1
    p2.* 
  , startDateStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p2.startDate)
  , endDateStrYMD   = dbo.RPT_DATE_FMT_YYYY_MM_DD(p2.endDate)
  , startDateStr    = dbo.RPT_DATE_FMT(p2.startDate)
  , endDateStr      = dbo.RPT_DATE_FMT(p2.endDate)
 , defaultGoalTypeID = case 
     when (p2.groupSvcClassNameID = 2) then 200
     when (p2.groupSvcClassNameID = 9) then 100
	 else 100
   end
from cte_p2 as p2
)
select top 1 
  p3.* 
from cte_p3 as p3

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_GOALS_VIEW_DEFAULT_DATES] TO [webuser]
GO  
