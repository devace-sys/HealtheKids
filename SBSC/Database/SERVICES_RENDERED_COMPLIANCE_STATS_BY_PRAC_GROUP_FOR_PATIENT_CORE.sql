USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE] (
     @userID                      bigint    
   , @userGroup                   int    
   , @userRank                    int 
   , @clientID                    bigint
   , @patID                       bigint
   , @startDate                   datetime
   , @endDate                     datetime
   , @pracGroupServiceClassNameID bigint
)

returns @recs table (
    CLIENT_ID       bigint
  , PATIENT_ID      bigint
  , GENERAL_SERVICE_PLAN_GROUP_NAME varchar(500)
  , IEP_OR_IFSP     bit
  , SERVICE_TYPE_ID int
  , SERVICE_SUB_TYPE_ID int
  , FROM_DATE date
  , TO_DATE date
  , NUM_PRACS int
  , MIN_DOS date
  , MAX_DOS date
  , NUM_SVCS_PRESENT int
  , TOT_MINS_PRESENT int
  , NUM_SVCS_ABSENT int
  , TOT_MINS_ABSENT int
  
  UNIQUE CLUSTERED (  
      CLIENT_ID
    , PATIENT_ID
    , GENERAL_SERVICE_PLAN_GROUP_NAME 
  )

) 
  
as
begin

/******************************************************************************
 * Service meta data 
 ******************************************************************************/

declare @serviceData as table (

   GENERAL_SERVICE_PLAN_GROUP_NAME varchar(500)
 , GROUP_SERVICE_CLASS_PARTITION_ID bigint
 , GROUP_SERVICE_CLASS_PARTITION_NAME varchar(1000)
 , GROUP_SERVICE_CLASS_NAME_ID bigint
 , GROUP_SERVICE_CLASS_NAME varchar(1000)
 , PARENT_GROUP_ID bigint
 , GROUP_BASE varchar(100)
 , GROUP_ID bigint
 , SERVICE_PLAN_TYPE_ID int
 , SERVICE_TYPE_ID int
 , SERVICE_SUB_TYPE_ID int
 , SERVICE_NAME_ID bigint
 , PROCEDURE_START_DATE date
 , PROCEDURE_END_DATE   date
 , PROCEDURE_HAS_GT     bit
 , GENERAL_SERVICE_PLAN varchar(100)
 , GENERAL_SERVICE_GROUP varchar(500)
 , GENERAL_SERVICE_NAME  varchar(500)
 , IEP_OR_IFSP          bit
 
)

/******************************************************************************
 * Service records details -- will be used to create summary
 ******************************************************************************/

declare @servicesDetail  as table (
 
  GENERAL_SERVICE_PLAN_GROUP_NAME varchar(500)
, IEP_OR_IFSP                     bit
, SERVICE_TYPE_ID                 int
, SERVICE_SUB_TYPE_ID             int
, DOS                           date
, NUM_MINS_PRESENT              int
, NUM_MINS_ABSENT               int
, NUM_SVCS_PRESENT              int
, NUM_SVCS_ABSENT               int
, PRAC_NUM                      int
, SERVICE_RECORD_ID             bigint

  UNIQUE CLUSTERED (  
      GENERAL_SERVICE_PLAN_GROUP_NAME                
    , DOS
    , SERVICE_RECORD_ID
  )

)

/******************************************************************************
 * Service records sum -- This will be output
 ******************************************************************************/

declare @servicesSum as table (
    GENERAL_SERVICE_PLAN_GROUP_NAME varchar(500)
  , IEP_OR_IFSP        bit
  , SERVICE_TYPE_ID    int
  , SERVICE_SUB_TYPE_ID  int
  , FROM_DATE  date
  , TO_DATE    date
  , NUM_PRACS          int
  , TOT_MINS_PRESENT   int
  , TOT_MINS_ABSENT    int  
  , NUM_SVCS_PRESENT   int
  , NUM_SVCS_ABSENT    int
  , MIN_DOS    date
  , MAX_DOS    date
  
  UNIQUE CLUSTERED (  
    GENERAL_SERVICE_PLAN_GROUP_NAME                
  )
)

/******************************************************************************
 * Get service data
 ******************************************************************************/

insert into @serviceData
select 
  * 
from dbo.CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA()
where (
      (GROUP_SERVICE_CLASS_PARTITION_ID = 1)
  and (GROUP_SERVICE_CLASS_NAME_ID      = @pracGroupServiceClassNameID) 
  --and (SERVICE_TYPE_ID                  = dbo.CONST_SERVICES_TREATMENT())
)

/******************************************************************************
 * Get service details
 ******************************************************************************/
 
insert into @servicesDetail
select     
    sd.GENERAL_SERVICE_PLAN_GROUP_NAME
  , sd.IEP_OR_IFSP
  , sd.SERVICE_TYPE_ID
  , sd.SERVICE_SUB_TYPE_ID
  , DOS                 = sr.dos
  , NUM_MINS_PRESENT    = case when (sr.patAbsent = 0) then sr.numMins else 0 end
  , NUM_MINS_ABSENT     = case when (sr.patAbsent = 1) then sr.numMins else 0 end
  , NUM_SVCS_PRESENT    = case when (sr.patAbsent = 0) then 1 else 0 end
  , NUM_SVCS_ABSENT     = case when (sr.patAbsent = 1) then 1 else 0 end
  , PRAC_NUM            = DENSE_RANK() OVER (partition by sd.GENERAL_SERVICE_PLAN_GROUP_NAME order by prp.CONCAT_NAME, prp.PRACTITIONER_ID )
  , SERVICE_RECORD_ID   = sr.id
  
from dbo.SERVICE_RECORDS              as sr  
join dbo.PATIENTS_Patient             as pap    on pap.PATIENT_ID      = sr.patID
join dbo.PRACTITIONER_Practitioner    as prp    on prp.PRACTITIONER_ID = sr.pracID

cross apply
(
  select top 1 
    * 
  from @serviceData 
  where     GROUP_SERVICE_CLASS_NAME_ID = @pracGroupServiceClassNameID
        and SERVICE_PLAN_TYPE_ID        = sr.planType 
        and SERVICE_TYPE_ID             = sr.svcType
        and GROUP_ID                    = sr.groupID
        and SERVICE_NAME_ID             = sr.nameID
        and sr.dos between PROCEDURE_START_DATE and PROCEDURE_END_DATE
) as sd
                                                                                                                                                                                      
where (
      (sr.clientID  = @clientID)
  and (sr.patID     = @patID)
  and (sr.dos between @startDate and @endDate)
  and (sr.svcType = dbo.CONST_SERVICES_TREATMENT())
  and (sr.state != dbo.CONST_SVC_REC_STATE_DEL())
  and (sr.state != dbo.CONST_SVC_REC_STATE_CIF())  
)

/******************************************************************************
 * Get summary of services actually rendered
 ******************************************************************************/
 
insert into @servicesSum
select 
    GENERAL_SERVICE_PLAN_GROUP_NAME
  , IEP_OR_IFSP
  , SERVICE_TYPE_ID
  , SERVICE_SUB_TYPE_ID
  , FROM_DATE            = @startDate
  , TO_DATE              = @endDate
  , NUM_PRACS            = MAX(PRAC_NUM)
  , TOT_MINS_PRESENT     = SUM(NUM_MINS_PRESENT)
  , TOT_MINS_ABSENT      = SUM(NUM_MINS_ABSENT)  
  , NUM_SVCS_PRESENT     = SUM(NUM_SVCS_PRESENT)
  , NUM_SVCS_ABSENT      = SUM(NUM_SVCS_ABSENT)
  , MIN_DOS              = MIN(DOS)
  , MAX_DOS              = MAX(DOS)
  
from @servicesDetail
group by GENERAL_SERVICE_PLAN_GROUP_NAME, IEP_OR_IFSP, SERVICE_TYPE_ID, SERVICE_SUB_TYPE_ID


/******************************************************************************
 * Fill in gaps for services not rendered
 ******************************************************************************/

insert into @servicesSum
select distinct 
  sd.GENERAL_SERVICE_PLAN_GROUP_NAME
 ,sd.IEP_OR_IFSP
 ,sd.SERVICE_TYPE_ID
 ,sd.SERVICE_SUB_TYPE_ID
 ,@startDate
 ,@endDate
 ,0
 ,0
 ,0
 ,0
 ,0
 ,null
 ,null 
from @serviceData as sd
where sd.GENERAL_SERVICE_PLAN_GROUP_NAME not in (select GENERAL_SERVICE_PLAN_GROUP_NAME from @servicesSum)

/******************************************************************************
 * Output
 ******************************************************************************/

insert into @recs
select 
    @clientID
  , @patID
  , GENERAL_SERVICE_PLAN_GROUP_NAME
  , IEP_OR_IFSP
  , SERVICE_TYPE_ID
  , SERVICE_SUB_TYPE_ID
  , FROM_DATE
  , TO_DATE
  , NUM_PRACS
  , MIN_DOS
  , MAX_DOS
  , NUM_SVCS_PRESENT
  , TOT_MINS_PRESENT
  , NUM_SVCS_ABSENT
  , TOT_MINS_ABSENT
from @servicesSum

return
end
go
