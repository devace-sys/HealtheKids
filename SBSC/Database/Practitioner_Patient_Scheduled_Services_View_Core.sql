USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Services_View_Core
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Patient_Scheduled_Services_View_Core] (
    @clientID               bigint     
  , @pracID                 bigint
  , @patID                  bigint 
  , @practitionerPatientCaseloadExpectedServiceID  bigint
  , @active                                        bit
  , @recID                                         bigint
  , @refDate                                       date     
  , @pracPatGroupID								   bigint 
)
    
returns table     
as
 
return 
(    

/***************************************************************************
 * Practitioner_Patient_Scheduled_Services_View_Core */
/**
 ***************************************************************************/

with
cte_p1
as
(
  select top 1  /*Note: Limited to just one row */
      pracName   = prp.CONCAT_NAME
	, clientName = clc.CLIENT_NAME
	, refDate    = convert(date,(isnull(@refDate,getdate())))
	, maxEndDate = convert(date,dbo.CONST_MAX_DATETIME())
  from dbo.PRACTITIONER_Practitioner as prp
  join dbo.PRACTITIONER_Client       as prc on  ((prc.PRACTITIONER_ID = prp.PRACTITIONER_ID)
                                            and (prc.CLIENT_ID        = @clientID))
  join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID          = prc.CLIENT_ID
  where (
       (prp.PRACTITIONER_ID = @pracID)
   and (clc.CLIENT_ID       = @clientID)
 )
)
,
cte_p2
as
(
  select top 1
      p1.pracName
	, p1.clientName
	, p1.refDate
	, p1.maxEndDate
	, refDateYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.refDate)
	, refDateStr = dbo.RPT_DATE_FMT(p1.refDate)
    , dow        = dbo.CALC_STANDARD_DAY_OF_WEEK_NUMBER(p1.refDate)
  from cte_p1 as p1
)
,
cte_p3
as
(
  select 
      p2.*    
	, ppss2.*
  from cte_p2 as p2
  cross apply (
    select
        ppss1.* 	
      , startDateDow    = dbo.CALC_STANDARD_DAY_OF_WEEK_NUMBER(ppss1.startDate)
	  , occursOnRefDate = dbo.Practitioner_Patient_Scheduled_Service_Occurs_On_RefDate ( 
          p2.refDate
        , p2.dow
        , ppss1.recurring
        , ppss1.startDate
        , ppss1.endDate
        , ppss1.mon
        , ppss1.tue
        , ppss1.wed
        , ppss1.thu
        , ppss1.fri )
	    , dateRangeBeforeInOrAfterRefDateVal = dbo.DATE_IS_BEFORE_IN_OR_AFTER_DATE_RANGE (
		      ppss1.startDate
			, isnull(ppss1.endDate,p2.maxEndDate)
			, p2.refDate )
    from dbo.Practitioner_Patient_Scheduled_Services_Data_Core (@clientID, @pracID, @patID, @practitionerPatientCaseloadExpectedServiceID, @active, @recID, @pracPatGroupID) as ppss1
  ) as ppss2
)
,
cte_p4
as
(
  select 
      p3.* 		
	, svcNamesListDataSourceName = csnlds.[name]	
	, groupName                  = gg.GROUP_NAME
	, svcName = dbo.BUILD_FULL_SERVICE_NAME_STRING (  p3.svcNamesListDataSourceID
	                                                
													, cip.NAME
													, cnp.NAME
													, ccy.NAME
													, cru.NAME

													, null
													, null
													, null
													, null

													, p3.svcTypeID
													, gg.GROUP_BASE
													, 0
													, 0
												    , 0
													, 0 
													, 0 )
   
  from      cte_p3                                as p3
  join      dbo.CLAIM_Svc_Names_List_Data_Sources as csnlds on csnlds.id             = p3.svcNamesListDataSourceID
  join      dbo.GROUP_Group                       as gg     on gg.GROUP_ID           = p3.groupID
  left join dbo.CLAIM_IEPandIFSPNames             as cip    on cip.IEP_IFSP_NAME_ID  = p3.nameID
  left join dbo.CLAIM_NoPlanNames                 as cnp    on cnp.NO_PLAN_NAME_ID   = p3.nameID 							 
  left join dbo.CLAIM_CYBHI_Names                 as ccy    on ccy.CYBHI_NAME_ID     = p3.nameID
  left join dbo.CLAIM_RU_HEALTH_NAMES             as cru    on cru.RU_HEALTH_NAME_ID = p3.nameID

)
select 
    p4.* 
  , patName             = pap.CONCAT_NAME /* This is here for service records */   
  , scheduleHasExpired  = convert(bit,(iif ((p4.dateRangeBeforeInOrAfterRefDateVal = -1),1,0)))
from cte_p4               as p4
join dbo.PATIENTS_Patient as pap  on pap.PATIENT_ID = p4.patID
) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Patient_Scheduled_Services_View_Core] TO [webuser]
GO