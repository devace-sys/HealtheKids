USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_GOALS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_GOALS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_GOALS_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @patID               BIGINT
  , @groupSvcClassNameID BIGINT
  , @startDate           DATE
  , @endDate             DATE
  , @active              BIT 
  , @recID               BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_GOALS_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

with
cte_base
as
(
  select top 1
      clientID          = @clientID
    , patID             = @patID
    , maxEndDate        = convert(date,'12/31/9999')
    , patName           = pap.CONCAT_NAME  
    , patDOB            = convert(date,pap.DATE_OF_BIRTH)
  from dbo.CLIENTS_Client   as clc
  join dbo.PATIENTS_Client  as pac on pac.CLIENT_ID = clc.CLIENT_ID
  join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pac.PATIENT_ID
  where (
        (clc.CLIENT_ID  = @clientID) 
    and (pap.PATIENT_ID = @patID)
  )
)
,
cte_p0
as
(
  select top 1
      cb.*
	, startA = isnull(@startDate, cb.patDOB)
    , endA   = isnull(@endDate,   cb.maxEndDate)
  from cte_base as cb
)
,
cte_p1
as
(
  select 
      p0.patName
    , p0.startA
    , p0.endA
    , pg2.* 
  from cte_p0 as p0
  cross apply (
    select
        startB = iif( (pg1.goalTypeID = 10000)
	                 , p0.patDOB 
		             , isnull(pg1.startDate, p0.patDOB))
	  
	  , endB   = iif( (pg1.goalTypeID = 10000)
	                  , p0.maxEndDate
					  , isnull(pg1.endDate, p0.maxEndDate))
      
	  , groupSvcClassName   = scn.GROUP_SERVICE_CLASS_NAME
	  , goalTypeName        = pgt.[name]
	  , pgt.userDefinedGoal
	  , pgt.inputGoalProgressUsingWhat
	  , pg1.*
    from dbo.PATIENT_GOALS                   as pg1
	join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = pg1.groupSvcClassNameID
    join dbo.PATIENT_GOAL_TYPES              as pgt on pgt.id                          = pg1.goalTypeID
    where ( 
	       (pg1.clientID = p0.clientID)
      and  (pg1.patID    = p0.patID)
  	  and ((@groupSvcClassNameID is null) or (pg1.groupSvcClassNameID = @groupSvcClassNameID))
	  and ((@recID  is null)              or (pg1.[id]   = @recID))
      and ((@active is null)              or (pg1.active = @active))  
    )
  ) as pg2
)

select top (dbo.CONST_MAX_ROWS())  
      p1.id
	, p1.clientID
	, p1.groupSvcClassNameID 
	, p1.groupSvcClassName
	, p1.patID
	, p1.patName
	, p1.[name] /* Goal name */
	, p1.active
	, p1.startDate
	, startDateStrYMD     = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.startDate)
	, startDateStr        = dbo.RPT_DATE_FMT(p1.startDate)
	, p1.endDate
	, endDateStrYMD       = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.endDate)
	, endDateStr          = dbo.RPT_DATE_FMT(p1.endDate)
	, p1.goalMet
	, p1.goalMetOn
	, goalMetOnStrYMD	  = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.goalMetOn)
	, goalMetOnStr        = dbo.RPT_DATE_FMT(p1.goalMetOn)
	, p1.backgroundText
	, p1.notes
	, p1.hasObjectives
	, p1.hasObjective1
	, p1.objective1Text
	, p1.objective1Met
	, p1.objective1MetOn
	, objective1MetOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.objective1MetOn)
    , objective1MetOnStr    = dbo.RPT_DATE_FMT(p1.objective1MetOn)
	, p1.hasObjective2
	, p1.objective2Text
	, p1.objective2Met
	, p1.objective2MetOn
	, objective2MetOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.objective2MetOn)
	, objective2MetOnStr    = dbo.RPT_DATE_FMT(p1.objective2MetOn)
	, p1.hasObjective3
	, p1.objective3Text
	, p1.objective3Met
	, p1.objective3MetOn
	, objective3MetOnStrYMD = dbo.RPT_DATE_FMT_YYYY_MM_DD(p1.objective3MetOn)
	, objective3MetOnStr    = dbo.RPT_DATE_FMT(p1.objective3MetOn)
    , p1.goalTypeID
	, p1.goalTypeName
	, p1.inputGoalProgressUsingWhat
	, p1.baseLineValue
	, p1.userDefinedGoal
from cte_p1 as p1
  /* Overlap (StartA <= EndB) and (EndA >= StartB) */
where 
  ((p1.startA <= p1.endB) and (p1.endA >= p1.startB))


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_GOALS_VIEW] TO [webuser]
GO  
