/* NOTE: IEP Flag does not apply anymore.  This is IEP only */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MISSING_ASSESSMENTS_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MISSING_ASSESSMENTS_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_MISSING_ASSESSMENTS_CORE]
(
   @clientID          bigint  = null  /* null = all active clients */
 , @repID             bigint  = null  /* null = all reps */
 , @mcalPatients      bit     = null  /* null = all patients, 1 = Medi-Cal Elig, 2= No Medi-Cal */
 , @iep               bit     = null  /* null = all services, 1= IEP/IFSP only, 2= Non IEP */
)

RETURNS @recs table (
    [Client]                nvarchar(max)
  , [Rep]                   varchar(101)
  , [Patient]               NVARCHAR(100)
  , [CurrentSite]           nvarchar(50)
  , [DOB]                   VARCHAR(50) 
  , [BIC]                   nvarchar(14)
  , [Active]                varchar(3)
  , [PractitionerGrouping]  VARCHAR(1000)
  , [EarliestDOS]           VARCHAR(50)
  , [LatestDOS]             VARCHAR(50) 
  , [NumberOfTreatments]    int
  , [NumOfAssmts]           int
  , [AssessementRate]       money
  , [ClientID]              bigint
  , [RepID]                 bigint
  , [PatID]                 bigint
  , [SiteID]                bigint
  , [PractitionerGroupID]   bigint
  , [LastAssmtDetails]      varchar(512)

)

AS 
BEGIN

declare @today          as datetime = getdate()
declare @startDate      as datetime = convert(date,dbo.CALC_OLDEST_DOS_ALLOWED(@today))
declare @endDate        as datetime = convert(date,@today)
declare @startDateAssmt as datetime = DATEADD (month,-1,@startDate)

declare @clients as table (
   CLIENT_ID   bigint
 , CLIENT_NAME nvarchar(max)
 , REP_NAME    varchar(101)
 , REP_ID      bigint
  UNIQUE CLUSTERED (CLIENT_ID)
)

declare @clientsPatients as table (
    CLIENT_ID          bigint
  , PATIENT_ID         bigint
  , EARLIEST_DOS       varchar(50)
  , LATEST_DOS         varchar(50)
  UNIQUE CLUSTERED (CLIENT_ID, PATIENT_ID)
)

declare @groupSvcClassNameIDs as table (
   GROUP_SERVICE_CLASS_NAME_ID bigint 
 , GROUP_SERVICE_CLASS_NAME    varchar(1000)
 , POTENTIAL_RATE              money
  UNIQUE CLUSTERED (GROUP_SERVICE_CLASS_NAME_ID)
)

declare @missingAssmts as table (
   CLIENT_ID                   bigint
 , PATIENT_ID                  bigint
 , GROUP_SERVICE_CLASS_NAME_ID bigint
 , TOTAL_TMTS                  int
 , TOTAL_ASSMTS                int
 UNIQUE CLUSTERED (CLIENT_ID, PATIENT_ID, GROUP_SERVICE_CLASS_NAME_ID)
)

/*###########################################################################
  # Get clients we are targeting
  ###########################################################################*/  

insert into @clients
select 
    clc.CLIENT_ID 
  , clc.CLIENT_NAME
  , clc.REP_NAME
  , clc.REP_ID
from dbo.CLIENTS_Client_Active_LEA as clc
where (
       (1=1)
  and ((@clientID is null) or (clc.CLIENT_ID = @clientID))
  and ((@repID    is null) or (clc.REP_ID    = @repID))
) option (recompile)

/*###########################################################################
  # Get group "families" we are targeting and max potential assmt rates
  ###########################################################################*/  

insert into @groupSvcClassNameIDs (
   GROUP_SERVICE_CLASS_NAME_ID 
 , GROUP_SERVICE_CLASS_NAME
 , POTENTIAL_RATE
)
select distinct
   t1.GROUP_SERVICE_ClASS_NAME_ID
 , t2.GROUP_SERVICE_CLASS_NAME
 , POTENTIAL_RATE = t1.RATE_ASSMT  
from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES              as t1
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                        as t2 on t2.GROUP_SERVICE_CLASS_NAME_ID = t1.GROUP_SERVICE_CLASS_NAME_ID
option (recompile)

/*###########################################################################
  # Get all applicable client + patient combos
  ###########################################################################*/  

insert into @clientsPatients 
select distinct 
    [CLIENT_ID]    = sr2.clientID
  , [PATIENT_ID]   = sr2.patID
  , [EARLIEST_DOS] = dbo.RPT_DATE_FMT(sr2.earliestDos)
  , [LASTEST_DOS]  = dbo.RPT_DATE_FMT(sr2.lastestDos)   
 
from @clients as clc
cross apply (
  /* Optimized to use the following index: CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS */
  select distinct 
      sr1.clientID
    , sr1.patID 
    , earliestDos = min(sr1.dos)
	, lastestDos  = max(sr1.dos)
  from dbo.SERVICE_RECORDS  as sr1 
  where     (sr1.clientID = clc.CLIENT_ID)
        and (sr1.pracID is not null)
        and (sr1.patID  is not null)
        and (sr1.dos between @startDate and @endDate)
	    and (sr1.state not in (99,199))
		and (sr1.svcType in (1,2))
		and ((@iep is null) or (sr1.isIFSPorIEP = @iep))
  group by 
      sr1.clientID
    , sr1.patID
) as sr2
option (recompile)

/*###########################################################################
  # Get all applicable client + patient combos that have treatments
  # but no assessements
  ###########################################################################*/  

;with
cte_p1
as
(
  select 
      cp.CLIENT_ID
	, cp.PATIENT_ID  
    , scn2.*
  from @clientsPatients as cp
  cross apply (
    select scn1.GROUP_SERVICE_CLASS_NAME_ID from @groupSvcClassNameIDs as scn1
  ) as scn2
)
,
cte_p2
as
(
select
   p1.CLIENT_ID
 , p1.PATIENT_ID
 , p1.GROUP_SERVICE_CLASS_NAME_ID
 , TOTAL_TMTS   = isnull(tmts.totRecs,0)
 , TOTAL_ASSMTS = isnull(assmts.totRecs,0)

from cte_p1 as p1

/* Treatments */

outer apply (
    select 
	  /* Was treatment delivered or attempted */
      totRecs = (pes.totRecsRegular + pes.totRecsPatAbsent + totRecsPracAbsent + totRecsMakeup)
	from dbo.PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE (  p1.CLIENT_ID
                                                                              , p1.PATIENT_ID
		   																	  , p1.GROUP_SERVICE_CLASS_NAME_ID
                                                                              , 2
                                                                              , @startDate
                                                                              , @endDate) as pes
  ) as tmts 

  /* Assessments */

  outer apply (
    select 
      /* Was assessment delivered */
	  totRecs = (pes.totRecsRegular + totRecsMakeup)	  
  from dbo.PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE (  @clientID
                                                                              , p1.PATIENT_ID
		   																	  , p1.GROUP_SERVICE_CLASS_NAME_ID
                                                                              , 1
                                                                              , @startDateAssmt
                                                                              , @endDate) as pes
  ) as assmts 

)
,
cte_p3
as
(
select p2.* 
from cte_p2 as p2
where 
      p2.TOTAL_TMTS != 0 
  and p2.TOTAL_ASSMTS = 0
)
insert into @missingAssmts
select p3.* 
from cte_p3 as p3
option (recompile)

/*###########################################################################
  # Generate result set
  ###########################################################################*/  

insert into @recs

select distinct
    q2.[Client]
  , q2.[Rep] 
  , q2.[Patient]
  , [CurrentSite] = ps.SITE_NAME
  , q2.[DOB]
  , q2.[BIC]
  , q2.[Active]
  , q2.[PractitionerGrouping] 
  , q2.[EarliestDOS]
  , q2.[LatestDOS]
  , q2.[NumberOfTreatments] 
  , q2.[NumOfAssmts]
  , q2.[AssessementRate]  
  , q2.[ClientID]
  , q2.[RepID]
  , q2.[PatID]
  , [SiteID] = ps.SITE_ID
  , q2.PractitionerGroupID
  , [LastAssmtDetails] = isnull(srAssmts2.Last_Assmt_Details,'No Applicable Records Found')
from
(
  select 
      q1.* 
    , MCAL_PATIENT = convert (bit,(case when (q1.BIC != '') then 1 else 0 end))  
  from
  (
    select 
        [Client]               = cl.CLIENT_NAME
      , [Rep]                  = cl.REP_NAME
      , [Patient]              = pp.CONCAT_NAME
      , [DOB]                  = dbo.RPT_DATE_FMT(pp.DATE_OF_BIRTH)
      , [BIC]                  = trim(isnull(pp.BIC,N''))
      , [Active]               = dbo.RPT_BIT_TO_YN(dbo.YN_TO_BIT(pp.ACTIVE)) 
      , [PractitionerGrouping] = gn.GROUP_SERVICE_CLASS_NAME
	  , [PractitionerGroupID]  = gn.GROUP_SERVICE_CLASS_NAME_ID
      , [EarliestDOS]          = cp.EARLIEST_DOS
      , [LatestDOS]            = cp.LATEST_DOS
      , [NumberOfTreatments]   = ma.TOTAL_TMTS
      , [NumOfAssmts]          = ma.TOTAL_ASSMTS
      , [AssessementRate]      = gn.POTENTIAL_RATE  
      , [ClientID]             = ma.CLIENT_ID  
      , [RepID]                = cl.REP_ID 
      , [PatID]                = ma.PATIENT_ID
 
    from @missingAssmts        as ma 
    join @clientsPatients      as cp on  cp.CLIENT_ID  = ma.CLIENT_ID 
                                     and cp.PATIENT_ID = ma.PATIENT_ID
    join @clients              as cl on cl.CLIENT_ID   = ma.CLIENT_ID							
    join @groupSvcClassNameIDs as gn on gn.GROUP_SERVICE_CLASS_NAME_ID = ma.GROUP_SERVICE_CLASS_NAME_ID
    join dbo.PATIENTS_Patient  as pp on pp.PATIENT_ID                  = ma.PATIENT_ID
  ) as q1
) as q2
join dbo.PATIENTS_SITES_VIEW_CURRENT(@clientID) as ps on ps.PATIENT_ID = q2.PatID

outer apply (
   select top 1  
	   Last_Assmt_Details = isnull(cpst1.SERVICE_TYPE_NAME,'Assessement') 
	                      + ' on ' +  dbo.RPT_DATE_FMT(srAssmts1.dos)
						  + ' by ' + prp1.CONCAT_NAME 
	                      + ' (' + gg1.GROUP_NAME+ ')' 						  						  	 
	                      + ' - '  + sras.[name]
	from dbo.SERVICE_RECORDS                      as srAssmts1 
    join dbo.PRACTITIONER_Practitioner            as prp1  on prp1.PRACTITIONER_ID  = srAssmts1.pracID
	join dbo.GROUP_Group                          as gg1   on gg1.GROUP_ID          = srAssmts1.groupID
	join dbo.SERVICE_RECORD_ATTENDANCE_SELECTIONS as sras  on sras.id               = srAssmts1.attendanceSelectionID
	left join dbo.CLAIM_Procedures_Service_Types  as cpst1 on cpst1.SERVICE_TYPE_ID = srAssmts1.svcSubType1
    
	where (   /* For index*/ 
              ((srAssmts1.clientID = q2.ClientID)
          and (srAssmts1.patID = q2.PatID)
          and (srAssmts1.pracGrpSvcClsNameID = q2.PractitionerGroupID)
		  and (srAssmts1.svcType = 1)		  
		  and (srAssmts1.dos is not null)
		  and (srAssmts1.id is not null))
		  and (srAssmts1.state not in (99,199))
		  and ((@iep is null) or (srAssmts1.isIFSPorIEP = @iep))
    )
    order by 
	  srAssmts1.dos desc

) as srAssmts2

where ( 
      (1=1)
  and ((@mcalPatients is null) or (q2.MCAL_PATIENT = @mcalPatients))
)
option (recompile)

RETURN
END

GO

/*-------------------------------
* User Permissions
*------------------------------*/

GRANT SELECT ON  [dbo].[RPT_MISSING_ASSESSMENTS_CORE] TO [webuser]
GO