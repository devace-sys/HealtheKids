USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS] (
    @userID             BIGINT
  , @userGroup          INT    
  , @userRank           INT
  , @clientID           BIGINT
  , @supervisingPracID  BIGINT
  , @supervisedPracID   BIGINT
  , @patID              BIGINT
  , @startDate          DATETIME
  , @endDate            DATETIME
)
    
returns table     
as
return (

/***************************************************************************    
 * SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS */    
/**    
 * View services records    
 *     
 * @param  userID             User id of who is viewing services    
 * @param  userGroup          1 = Client, 2 = SBSC (from users db)    
 * @param  userRank           Users role ranking    
 * @param  clientID           Client ID    
 * @param  supervisingPracID  Assigned supervising practitioner ID    
 * @param  supervisedPracID   Assigned supervised practitioner ID    
 * @param  patID              PatientID    
 * @param  startDate          Start date of service    
 * @param  endDate            End date of service    
 * @return                    Service records    
 * TODO: Update to use modified core routine
 ***************************************************************************/     

with

/*###########################################################################
  # Prac to prac supervisor - supervised relationship
  ###########################################################################*/  

cte_p0
as
(
  select 
  
      SUPERVISING_PRAC_ID
    , SUPERVISED_PRAC_ID
    
  from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as t1
 
  where (
         (t1.CLIENT_ID           = @clientID )
     and (t1.SUPERVISING_PRAC_ID = @supervisingPracID) 
     and (t1.ACTIVE              = 1)
     and (t1.SHARE_NOTES         = 0)
     and (t1.relationshipTypeID  = 10)
 	 and ((@supervisedPracID is null) or (t1.SUPERVISED_PRAC_ID = @supervisedPracID))
 )

/*###########################################################################
  # Department Head (If applicable for client + group family)
  ###########################################################################*/  

 union

 select 
     SUPERVISING_PRAC_ID = t0.DEPT_HEAD_PRAC_ID
   , t0.SUPERVISED_PRAC_ID 
 from dbo.PRACTITIONER_DIRECT_SUPERVISED_FOR_DEPARTMENT_HEAD_VIEW_CORE ( @clientID, @supervisingPracID, @supervisedPracID) as t0
 where 
   ((t0.departmentHeadsCanViewSupervisedPracsSvcRecs = 1) or (t0.departmentHeadsCanViewAllPracDataInTheirReportingGroup = 1))
)
,

/*###########################################################################
  # Retrieve service records.  Restrict service records to supervision dates
  ###########################################################################*/  

cte_p1
as
(    
  select     
  
      ppss.SUPERVISING_PRAC_ID
    , sr.*    
    
  from cte_p0 as ppss
  
  cross apply (
  
    select 
      srvc.*  
    from dbo.SERVICE_RECORDS_VIEW_CORE (  @userID
                                        , @userGroup
                                        , @userRank
                                        , @clientID		
										, null								
                                        , ppss.SUPERVISED_PRAC_ID
                                        , @patID
										, null
                                        , @startDate
                                        , @endDate
                                        , null
                                        , null
                                        , null
                                        , null
                                        , 0
                                        , null) as srvc
  ) as sr                                      
)
,

/*###########################################################################
  # Get additional data.  Create column headings
  ###########################################################################*/  

cte_p2
as
(
  select 
      id
    , CLIENT_NAME                  as clientName
    , pp1.CONCAT_NAME              as supervisingPracName
    , gg1.GROUP_NAME               as supervisingPracGroup
    , PR_CONCAT_NAME               as supervisedPracName  
    , gg2.GROUP_NAME               as supervisedPracGroup
    , supervisedPracNameAndGroup = PR_CONCAT_NAME + ' (' + gg2.GROUP_NAME + ')'
	, PA_CONCAT_NAME                  as patName    
	, dbo.RPT_DATE_FMT(PA_DOB)        as patDobStr
	, PA_CSIS                         as patSSID	
	, psvc.SITE_NAME                  as patCurrentSiteName
	, patAbsent                       as patAbsentVal
	, attendanceStatusSelectionName   as attendanceStatusSelectionName
    , dbo.RPT_BIT_TO_YN(patAbsent)    as patAbsentStr
    , dos                             as svcDate
    , dbo.RPT_DATE_FMT(dos)           as svcDateStr
	, SVC_NAME                        as svcProvided
    , numMins                         as svcMins
	, svcNotesFormBuilderTextAndNotes as svcNotes
	, svcNotesPrivateFormBuilderText  as privateSvcNotes
    , clientID                        as clientID
    , SUPERVISING_PRAC_ID             as supervisingPracID  
    , pracID                          as supervisedPracID
    , groupID                         as supervisedPracGroupID
    , patID                           as patID
    , p1.renderingPracSig
    , p1.reviewingPracSig
   
   from cte_p1                        as p1    
   join dbo.PRACTITIONER_Practitioner as pp1  on  pp1.PRACTITIONER_ID = p1.SUPERVISING_PRAC_ID
   join dbo.PRACTITIONER_GROUPS       as pg1  on  pg1.PRACTITIONER_ID = p1.SUPERVISING_PRAC_ID
                                              and pg1.GROUP_TYPE in (1,2)    
   join dbo.GROUP_Group               as gg1  on  gg1.GROUP_ID = pg1.GROUP_ID
                                              and gg1.GROUP_TYPE in (1,2) 
   join dbo.GROUP_Group               as gg2  on  gg2.GROUP_ID = p1.groupID
                                              and gg2.GROUP_TYPE in (1,2)   
   join dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) as psvc on psvc.PATIENT_ID = p1.patID
)

/*###########################################################################
  # Output
  ###########################################################################*/  

select top (dbo.CONST_MAX_ROWS())  
  p2.* 
from cte_p2 as p2
order by 
    p2.clientName
  , p2.supervisingPracName
  , p2.supervisedPracName
  , p2.patName
  , p2.svcDate

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORDS_REVIEW_FOR_DIRECT_ASSIGNED_SUPERVISING_PRACS] TO [webuser]
GO