USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PRACTITIONERS_EFFICENCY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PRACTITIONERS_EFFICENCY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
 /***************************************************************************    
  * RPT_PRACTITIONERS_EFFICENCY_CORE */    
 /**    
  ***************************************************************************/     

CREATE FUNCTION [dbo].[RPT_PRACTITIONERS_EFFICENCY_CORE]  (
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @clientID              bigint
  , @rptGroupID			   bigint
  , @groupSvcClassNameID   bigint
  , @pracID                bigint
  , @startDate             datetime
  , @endDate               datetime
)    
returns @recs table (
    pracID              bigint
  , dispGroupID         int
  , reptGroupID         int
  , groupSvcClassNameID int   
  , pracName            varchar(256)
  , disciplineGroup     varchar(512)
  , reportingGroup      varchar(512)
  , practiceFamily      varchar(512)
  , numSvcsWithoutNotes int default(0)
  , c1 varchar(50) default('')
  , c2 varchar(50) default('')
  , c3 varchar(50) default('')
  , c4 varchar(50) default('')
  , c5 varchar(50) default('')
  , c6 varchar(50) default('')
  , c7 varchar(50) default('')
  , c8 varchar(50) default('')
  , c9 varchar(50) default('')
  , c10 varchar(50) default('')
  , c11 varchar(50) default('')
  , c12 varchar(50) default('')
  , c13 varchar(50) default('')
  , c14 varchar(50) default('')
  , c15 varchar(50) default('')
  , c16 varchar(50) default('')
  , c17 varchar(50) default('')
  , c18 varchar(50) default('')
  , c19 varchar(50) default('')
  , c20 varchar(50) default('')
  , c21 varchar(50) default('')
  , c22 varchar(50) default('')
  , c23 varchar(50) default('')
  , c24 varchar(50) default('')
  , c25 varchar(50) default('')

  , [_c1_col_label]  varchar(100) default ''
  , [_c2_col_label]  varchar(100) default ''
  , [_c3_col_label]  varchar(100) default ''
  , [_c4_col_label]  varchar(100) default ''
  , [_c5_col_label]  varchar(100) default ''
  , [_c6_col_label]  varchar(100) default ''
  , [_c7_col_label]  varchar(100) default ''
  , [_c8_col_label]  varchar(100) default ''
  , [_c9_col_label]  varchar(100) default ''
  , [_c10_col_label] varchar(100) default ''
  , [_c11_col_label] varchar(100) default ''
  , [_c12_col_label] varchar(100) default ''
  , [_c13_col_label] varchar(100) default ''
  , [_c14_col_label] varchar(100) default ''
  , [_c15_col_label] varchar(100) default ''  
  , [_c16_col_label] varchar(100) default ''
  , [_c17_col_label] varchar(100) default ''
  , [_c18_col_label] varchar(100) default ''
  , [_c19_col_label] varchar(100) default ''
  , [_c20_col_label] varchar(100) default ''
  , [_c21_col_label] varchar(100) default ''
  , [_c22_col_label] varchar(100) default ''
  , [_c23_col_label] varchar(100) default ''
  , [_c24_col_label] varchar(100) default ''
  , [_c25_col_label] varchar(100) default ''

  unique clustered (pracID)
)
as 
begin

/*============================================================
 * Exit if key fields are not provided
 *===========================================================*/  

if (@clientID  is null) return
if (@startDate is null) return
if (@endDate   is null) return

declare @pracs as table (
    pracID              bigint
  , dispGroupID         int
  , reptGroupID         int
  , groupSvcClassNameID int   
  , pracName            nvarchar(256)
  , disciplineGroup     nvarchar(512)
  , reportingGroup      nvarchar(512)
  , practiceFamily      nvarchar(512)
  , numPatsOnCaseload   int
unique clustered (pracID)
)

declare @dispGroupIDs as table (
    dispGroupID int
  , c1Used bit default(0)
  , c2Used bit default(0)
  , c3Used bit default(0)
  , c4Used bit default(0)
  , c5Used bit default(0)
  , c6Used bit default(0)
  , c7Used bit default(0)
  , c8Used bit default(0)
  , c9Used bit default(0)
  , c10Used bit default(0)
  , c11Used bit default(0)
  , c12Used bit default(0)
  , c13Used bit default(0)
  , c14Used bit default(0)
  , c15Used bit default(0)
  , c16Used bit default(0)
  , c17Used bit default(0)
  , c18Used bit default(0)
  , c19Used bit default(0)
  , c20Used bit default(0)
  , c21Used bit default(0)
  , c22Used bit default(0)
  , c23Used bit default(0)
  , c24Used bit default(0)
  , c25Used bit default(0)

unique clustered (dispGroupID)
)

declare @cp as table (
    GROUP_ID              int
  , SERVICE_TYPE_ID       int
  , SERVICE_SUB_TYPE_1_ID int
  , IEP_IFSP_NAME         int
  , NO_PLAN_NAME          int
  , idx                   int identity(1,1)
unique clustered (GROUP_ID, SERVICE_TYPE_ID, SERVICE_SUB_TYPE_1_ID,IEP_IFSP_NAME,NO_PLAN_NAME,IDX)
)

declare @dgn as table (
    svcName     nvarchar(100)
  , sectionID   int
  , dispGroupID int
  , nameID      int
  , svcType     int
  , isIEP       bit
  , notesRequired bit default(1)
  , cn          int
  , idx         int identity(1,1)
unique clustered (dispGroupID, nameID, cn, idx)
)

declare @sn as table (
    cn          int identity(1,1)
  , svcName     nvarchar(100)
  , sectionID   int 
unique clustered (cn,svcName,sectionID)
)

declare @svcRecs as table (
    pracID          int
  , cn              int
  , id              bigint
  , notesRequired   bit default(1)
  , hasNotes        bit default(0)
  unique clustered (pracID,cn,id)
)

/*============================================================
 * Get practitioners that will be the subject of the report
 *===========================================================*/  
 
insert into @pracs (
    pracID
  , dispGroupID  
  , reptGroupID
  , groupSvcClassNameID
  , pracName
  , disciplineGroup
  , reportingGroup
  , practiceFamily
  , numPatsOnCaseload
)

select distinct

    rprc.pracID
  , rprc.dispGroupID
  , rprc.reptGroupID
  , rprc.groupSvcClassNameID
  , rprc.pracName 
  , rprc.dispGroupName
  , rprc.reptGroupName
  , rprc.practiceFamily
  , rprc.numPatsOnCaseload
from dbo.RPT_PRACTITIONERS_REVIEW_CORE (@userID, @userGroup, @userRank, @clientID, @pracID, null, @rptGroupID, @groupSvcClassNameID, null, null, 1) as rprc

/*============================================================
 * Collect the practitioners discpline group ids 
 *===========================================================*/  

insert into @dispGroupIDs (
  dispGroupID
)
select distinct
  dispGroupID
from @pracs

/*============================================================
 * Collect BILLABLE procedure data that is effective for 
 * date range (StartA <= EndB) and (EndA >= StartB)
 *===========================================================*/  

;with
cte_p1
as
(
  select 
      GROUP_ID = dgi.dispGroupID
	, cp.SERVICE_TYPE_ID
	, cp.SERVICE_SUB_TYPE_1_ID
	, cp.IEP_IFSP_NAME
	, cp.NO_PLAN_NAME
	, PROC_START_DATE = convert(datetime, isnull (cp.DATE_EFFECTIVE, dbo.CONST_MIN_DATETIME()))
    , PROC_END_DATE   = convert(datetime, isnull (cp.DATE_EXPIRES,   dbo.CONST_MAX_DATETIME()))

  from @dispGroupIDs                 as dgi 
  join dbo.CLAIM_Allowed_Procedures  as cap on cap.GROUP_ID    = dgi.dispGroupID
  join dbo.CLAIM_Procedures          as cp  on cp.PROCEDURE_ID = cap.PROCEDURE_ID
  
  where (
        (cp.Active = 1)
    and (cp.SERVICE_TYPE_ID in (1,2))
    and (cp.PUT_IN_837 = 1)
  )
)

insert into @cp (
    GROUP_ID        
  , SERVICE_TYPE_ID 
  , SERVICE_SUB_TYPE_1_ID
  , IEP_IFSP_NAME 
  , NO_PLAN_NAME  
)
select distinct 
   p1.GROUP_ID
 , p1.SERVICE_TYPE_ID
 , p1.SERVICE_SUB_TYPE_1_ID
 , p1.IEP_IFSP_NAME
 , p1.NO_PLAN_NAME
from cte_p1 as p1
where 
  ((p1.PROC_START_DATE <= @endDate) and (p1.PROC_END_DATE >= @startDate))

/*============================================================
 * Get IEP/IFSP assessment and treatment 
 * procedure data for these discipline group ids
 *
 * Please note the sectionID generation, service type
 * and notes required calculations
 *===========================================================*/  

insert into @dgn (
    svcName
  , sectionID
  , dispGroupID
  , nameID 
  , svcType
  , isIEP
  , notesRequired
)
select distinct
    svcName     = iif( (cp.SERVICE_TYPE_ID = 1), N'IEP/IFSP Assessments', N'IEP/IFSP Therapy or Treatments')
  , sectionID   = iif ((cp.SERVICE_TYPE_ID = 1), 1, 2)
  , dispGroupID = dg.dispGroupID
  , nameID      = iep.IEP_IFSP_NAME_ID
  , svcType     = cp.SERVICE_TYPE_ID
  , isIEP       = 1
  , notesRequired = iif ((cp.SERVICE_TYPE_ID = 1),0,1)
from @dispGroupIDs                as dg
join @cp                          as cp   on cp.GROUP_ID = dg.dispGroupID
join dbo.CLAIM_IEPandIFSPNames    as iep  on iep.IEP_IFSP_NAME_ID  = cp.IEP_IFSP_NAME
where (
      (cp.SERVICE_TYPE_ID in (1,2))
  and (cp.NO_PLAN_NAME is null)
)

/*============================================================
 * Get NON IEP/IFSP treatment
 * procedure data for these discipline group ids
 *===========================================================*/  

insert into @dgn (
    svcName
  , sectionID 
  , dispGroupID
  , nameID 
  , svcType
  , isIEP
  , notesRequired
)
select distinct
    svcName       = N'Non IEP/IFSP Therapy or Treatments'
  , sectionID     = 3
  , dispGroupID   = dg.dispGroupID
  , nameID        = np.NO_PLAN_NAME_ID 
  , svcType       = cp.SERVICE_TYPE_ID
  , isIEP         = 0
  , notesRequired = 1
from @dispGroupIDs                as dg
join @cp                          as cp   on cp.GROUP_ID = dg.dispGroupID
join dbo.CLAIM_NoPlanNames        as np  on np.NO_PLAN_NAME_ID = cp.NO_PLAN_NAME
where (
      (cp.SERVICE_TYPE_ID = 2)
  and (cp.IEP_IFSP_NAME is null)
)

/*============================================================
 * Get NON IEP/IFSP screenings
 * procedure data for these discipline group ids
 *===========================================================*/  

insert into @dgn (
    svcName
  , sectionID 
  , dispGroupID
  , nameID 
  , svcType
  , isIEP
  , notesRequired
)
select distinct
    svcName       = dbo.SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT(np.NAME)
  , sectionID     = 4
  , dispGroupID   = dg.dispGroupID
  , nameID        = np.NO_PLAN_NAME_ID 
  , svcType       = cp.SERVICE_TYPE_ID
  , isIEP         = 0
  , notesRequired = 1
from @dispGroupIDs                as dg
join @cp                          as cp   on cp.GROUP_ID = dg.dispGroupID
join dbo.CLAIM_NoPlanNames        as np  on np.NO_PLAN_NAME_ID = cp.NO_PLAN_NAME
where (
      (cp.SERVICE_TYPE_ID = 1)
  and (cp.SERVICE_SUB_TYPE_1_ID is null)
  and (cp.IEP_IFSP_NAME is null)
)

/*============================================================
 * Generate column names and numbers (cn) 
 * In order of section and name
 *===========================================================*/  

insert into @sn(
    svcName
   ,sectionID
)
select distinct 
   dgn.svcName 
  ,dgn.sectionID
from @dgn as dgn
order by 
  dgn.sectionID
, dgn.svcName

/*============================================================
 * Update procedure data with these column numbers
 *===========================================================*/  

update dgn
  set dgn.cn = sn.cn
from @dgn as dgn 
join @sn  as sn  on ((sn.cn is not null) and (sn.svcName = dgn.svcName) and (sn.sectionID = dgn.sectionID))

/*============================================================
 * Update discipline group data with column usage
 * This will be used later to determine non applicable columns
 *===========================================================*/  

update dgi 
  set dgi.c1Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 1)

update dgi 
  set dgi.c2Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 2)

update dgi 
  set dgi.c3Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 3)

update dgi 
  set dgi.c4Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 4)

update dgi 
  set dgi.c5Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 5)

update dgi 
  set dgi.c6Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 6)

update dgi 
  set dgi.c7Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 7)

update dgi 
  set dgi.c8Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 8)

update dgi 
  set dgi.c9Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 9)

update dgi 
  set dgi.c10Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 10)

update dgi 
  set dgi.c11Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 11)

update dgi 
  set dgi.c12Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 12)

update dgi 
  set dgi.c13Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 13)

update dgi 
  set dgi.c14Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 14)

update dgi 
  set dgi.c15Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 15)

update dgi 
  set dgi.c16Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 16)

update dgi 
  set dgi.c17Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 17)

update dgi 
  set dgi.c18Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 18)

update dgi 
  set dgi.c19Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 19)

update dgi 
  set dgi.c20Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 20)

update dgi 
  set dgi.c21Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 21)

update dgi 
  set dgi.c22Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 22)

update dgi 
  set dgi.c23Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 23)

update dgi 
  set dgi.c24Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 24)

update dgi 
  set dgi.c25Used = 1
from @dispGroupIDs as dgi
join @dgn          as dgn on dgn.dispGroupID = dgi.dispGroupID
where 
  (dgn.cn = 25)

/*============================================================
 * Get services entered and calculate if public notes were
 * entered.
 *===========================================================*/  

insert into @svcRecs (
    pracID
  , cn
  , id
  , notesRequired
  , hasNotes
)
select 
    sr2.pracID
  , sr2.cn
  , sr2.id
  , notesRequired = dgn.notesRequired
  , hasNotes      = iif (((sr2.lenSrNotes = 0) and (sr2.lenFbAnswers = 2)),0,1)
from @pracs as p
join @dgn   as dgn on ((dgn.dispGroupID = p.dispGroupID) and (dgn.nameID is not null))

cross apply (
  select   	
      sr1.pracID
    , dgn.cn
    , sr1.id 
    , lenSrNotes      = len(trim(isnull(sr1.notes,'')))
    , lenFbAnswers    = len(isnull(srfbd.svcNotesFormBuilderAnswersJSON,'{}'))
  from      dbo.SERVICE_RECORDS                   as sr1  
  left join dbo.SERVICE_RECORDS_FORM_BUILDER_DATA as srfbd on srfbd.svcRecId = sr1.id
  
  where ( 
  
      /* [CLIENT_PRAC_PAT_DOS_CREATED_ID_W_EXTRA_COLS] */

        (sr1.clientID = @clientID)
    and (sr1.pracID = p.pracID)
    and (sr1.patID is not null)
    and (sr1.dos between @startDate and @endDate)
    and (sr1.created is not null)
    and (sr1.userID is not null)

	/* Included cols */

    and (sr1.state not in (99,199))
    and (sr1.svcType     = dgn.svcType)
    and (sr1.isIFSPorIEP = dgn.isIEP)
    and (sr1.nameID      = dgn.nameID)
    and (sr1.groupID     = dgn.dispGroupID)    
  )
) as sr2

/*============================================================
 * Generate output
 *===========================================================*/  

insert into @recs (
   pracID
 , dispGroupID
 , reptGroupID         
 , groupSvcClassNameID
 , pracName
 , disciplineGroup
 , reportingGroup
 , practiceFamily
 , numSvcsWithoutNotes
 , c1
 , c2
 , c3
 , c4
 , c5
 , c6
 , c7
 , c8
 , c9
 , c10
 , c11
 , c12
 , c13
 , c14
 , c15
 , c16
 , c17
 , c18
 , c19
 , c20
 , c21
 , c22
 , c23
 , c24
 , c25

)
select 
   p.pracID 
 , p.dispGroupID
 , p.reptGroupID         
 , p.groupSvcClassNameID
 , p.pracName
 , p.disciplineGroup
 , p.reportingGroup
 , p.practiceFamily
 , numSvcsWithoutNotes = noNotes.numOf

 , c1   = convert(varchar(50),c1.numOf)
 , c2   = convert(varchar(50),c2.numOf)
 , c3   = convert(varchar(50),c3.numOf)
 , c4   = convert(varchar(50),c4.numOf)
 , c5   = convert(varchar(50),c5.numOf)
 , c6   = convert(varchar(50),c6.numOf)
 , c7   = convert(varchar(50),c7.numOf)
 , c8   = convert(varchar(50),c8.numOf)
 , c9   = convert(varchar(50),c9.numOf)
 , c10  = convert(varchar(50),c10.numOf)
 , c11  = convert(varchar(50),c11.numOf)
 , c12  = convert(varchar(50),c12.numOf)
 , c13  = convert(varchar(50),c13.numOf)
 , c14  = convert(varchar(50),c14.numOf)
 , c15  = convert(varchar(50),c15.numOf)
 , c16  = convert(varchar(50),c16.numOf)
 , c17  = convert(varchar(50),c17.numOf)
 , c18  = convert(varchar(50),c18.numOf)
 , c19  = convert(varchar(50),c19.numOf)
 , c20  = convert(varchar(50),c20.numOf)
 , c21  = convert(varchar(50),c21.numOf)
 , c22  = convert(varchar(50),c22.numOf)
 , c23  = convert(varchar(50),c23.numOf)
 , c24  = convert(varchar(50),c24.numOf)
 , c25  = convert(varchar(50),c25.numOf)

from @pracs as p

outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.notesRequired = 1) and (sr1.hasNotes = 0))) as noNotes

outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 1)))  as c1
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 2)))  as c2
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 3)))  as c3
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 4)))  as c4
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 5)))  as c5
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 6)))  as c6
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 7)))  as c7
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 8)))  as c8
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 9)))  as c9
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 10))) as c10
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 11))) as c11
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 12))) as c12
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 13))) as c13
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 14))) as c14
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 15))) as c15
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 16))) as c16
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 17))) as c17
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 18))) as c18
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 19))) as c19
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 20))) as c20
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 21))) as c21
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 22))) as c22
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 23))) as c23
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 24))) as c24
outer apply (select numOf = count(sr1.id) from @svcRecs as sr1 where ((sr1.pracID = p.pracID) and (sr1.cn = 25))) as c25

/*============================================================
 * Set labels
 *===========================================================*/  

update @recs set [_c1_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 1),'')
update @recs set [_c2_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 2),'')
update @recs set [_c3_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 3),'')
update @recs set [_c4_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 4),'')
update @recs set [_c5_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 5),'')
update @recs set [_c6_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 6),'')
update @recs set [_c7_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 7),'')
update @recs set [_c8_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 8),'')
update @recs set [_c9_col_label]  = isnull((select top 1 svcName from @sn as sn where sn.cn = 9),'')
update @recs set [_c10_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 10),'')
update @recs set [_c11_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 11),'')
update @recs set [_c12_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 12),'')
update @recs set [_c13_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 13),'')
update @recs set [_c14_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 14),'')
update @recs set [_c15_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 15),'')
update @recs set [_c16_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 16),'')
update @recs set [_c17_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 17),'')
update @recs set [_c18_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 18),'')
update @recs set [_c19_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 19),'')
update @recs set [_c20_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 20),'')
update @recs set [_c21_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 21),'')
update @recs set [_c22_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 22),'')
update @recs set [_c23_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 23),'')
update @recs set [_c24_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 24),'')
update @recs set [_c25_col_label] = isnull((select top 1 svcName from @sn as sn where sn.cn = 25),'')

/*============================================================
 * Set blank values for columns that are not applicable
 * for a practitioner based on their disciplimne group
 *===========================================================*/  

update r
  set r.c1 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c1Used = 0)

update r
  set r.c2 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c2Used = 0)

update r
  set r.c3 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c3Used = 0)

update r
  set r.c4 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c4Used = 0)

update r
  set r.c5 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c5Used = 0)

update r
  set r.c6 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c6Used = 0)

update r
  set r.c7 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c7Used = 0)

update r
  set r.c8 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c8Used = 0)

update r
  set r.c9 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c9Used = 0)

update r
  set r.c10 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c10Used = 0)

update r
  set r.c11 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c11Used = 0)

update r
  set r.c12 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c12Used = 0)

update r
  set r.c13 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c13Used = 0)

update r
  set r.c14 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c14Used = 0)

update r
  set r.c15 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c15Used = 0)

update r
  set r.c16 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c16Used = 0)

update r
  set r.c17 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c17Used = 0)

update r
  set r.c18 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c18Used = 0)

update r
  set r.c19 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c19Used = 0)

update r
  set r.c20 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c20Used = 0)

update r
  set r.c21 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c21Used = 0)

update r
  set r.c22 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c22Used = 0)

update r
  set r.c23 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c23Used = 0)

update r
  set r.c24 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c24Used = 0)

update r
  set r.c25 = ''
from @recs         as r
join @pracs        as p   on p.pracID        = r.pracID
join @dispGroupIDs as dgi on dgi.dispGroupID = p.dispGroupID
where 
  (dgi.c25Used = 0)

return

end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].RPT_PRACTITIONERS_EFFICENCY_CORE TO [webuser]
GO

  