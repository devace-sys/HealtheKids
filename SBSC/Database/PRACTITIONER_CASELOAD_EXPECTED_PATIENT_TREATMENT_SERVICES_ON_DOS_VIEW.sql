USE SPEDMON
GO

/* TODO: This is going to be deprecated and replaced with  */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW] (
   @userID          BIGINT    
 , @userGroup       BIGINT    
 , @userRank        BIGINT
 , @clientID        BIGINT
 , @pracID          BIGINT
 , @dos             DATETIME 
 , @pracPatGroupID  BIGINT
)    

RETURNS 
@recs 
table (
    id                      bigint identity(1,1)
  , patID                   bigint  
  , patName                 nvarchar(100)
  , dos                     datetime
  , dosStr                  varchar(50)
  , numMins                 int
  , svcTypeID               int /* 2 */
  , svcSubTypeID            int /* 2000 = Individual, 2001 = Group */
  , planTypeSelectionID     int /* 1= IEP or IFSP,  2= Other */
  , internalPlanTypeID      int
  , planIsIEPIFSP           bit
  , serviceNameID           bigint
  , serviceName             nvarchar(100)
  , orpRequired             bit
  , orpDocumentID           bigint  
  , orpDocumentName         varchar(255)
  , orpDocTypeID            bigint /* This is a bigint not int */
  , orpDocSelectionRequired bit
)


BEGIN

 /***************************************************************************    
  * PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW */    
 /**    
  * 
  * @return Table of expected service data   
  ***************************************************************************/     

declare @today                as datetime
declare @pracGroupID          as bigint
declare @telehealthPracOnly   as bit = 0
declare @svcClassNameID       as bigint
declare @dow                  as int


declare @caseloadData as table (
     patID               bigint
   , expectedMinsInd     int
   , expectedMinsGrp     int
   , planTypeSelectionID int
   , planIsIEPIFSP       bit
   , daysOfWeekSvcTmtProvidedJSON nvarchar(max)
)

/*============================================================
 * Exit if required parameters are not passed
 *============================================================*/

if (@clientID is null) return
if (@pracID   is null) return

/*============================================================
 * Get todays date
 *============================================================*/

set @today = getdate()

/*============================================================
 * Default to todays date
 *============================================================*/

if (@dos is null) set @dos = getdate()

/*============================================================
 * Standardize day of week number (insulating us against datefirst
 * changes).  Sunday will always be 0 and Saturday will always be 6
 * Days between will be 1-5. 
 * Courtesey of https://stackoverflow.com/a/1113891 see comment
 * by https://stackoverflow.com/users/196451/endy-tjahjono 
 *============================================================*/

set @dow = dbo.CALC_STANDARD_DAY_OF_WEEK_NUMBER(@dos)

/*============================================================
 * If day of week is Sunday or Saturday, exit
 *============================================================*/

if (@dow in (0,6)) return

/*============================================================
  * Load current caseload data and convert some of the column
  * values to consistant data values
  *============================================================*/

insert into @caseloadData
select
      q1.patID
    , q1.expectedMinsInd
    , q1.expectedMinsGrp
    , q1.planTypeSelectionID 
    , planIsIEPIFSP = convert(bit,(iif((q1.planTypeSelectionID = 1),1,0)))
    , q1.daysOfWeekSvcTmtProvidedJSON 
from
(
  select
      patID                        = ppc.patID
    , expectedMinsInd              = isnull(ppc.expectedMinsInd,0)
    , expectedMinsGrp              = isnull(ppc.expectedMinsGrp,0)
    , planTypeSelectionID          = isnull(ppc.planType,1) /* Default to IEP if not defined */
    , daysOfWeekSvcTmtProvidedJSON = convert(nvarchar(max),ppc.daysOfWeekSvcTmtProvidedJSON) 
  from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
  where (
        (ppc.clientID = @clientID)
    and (ppc.pracID   = @pracID)
    and (ppc.patID is not null)
  )
) as q1

/*============================================================
 * If there are no caseload records, exit
 *============================================================*/

if (not exists (select top 1 patID from @caseloadData)) return

/*============================================================
  * Find all patients who are scheduled to receive a service
  * on dos.  Order by patient name and service sub type
  *============================================================*/

insert into @recs

select
    q1.patID
  , patName                 = pap.CONCAT_NAME
  , dos                     = @dos
  , dosStr                  = dbo.RPT_DATE_FMT_YYYY_MM_DD(@dos)
  , q1.numMins              
  , svcTypeID               = 2
  , q1.svcSubTypeID
  , q1.planTypeSelectionID
  , internalPlanTypeID      = dbo.DOS_DOB_IEP_TO_PLAN_TYPE (@dos, pap.DATE_OF_BIRTH, q1.planIsIEPIFSP)
  , q1.planIsIEPIFSP 
  , serviceNameID           = null
  , serviceName             = null
  , orpRequired             = null
  , orpDocumentID           = null
  , orpDocumentName         = null
  , orpDocTypeID            = null
  , orpDocSelectionRequired = null
from
(
  select
      ind.patID
    , ind.numMins
	, ind.planTypeSelectionID
	, ind.planIsIEPIFSP
    , svcSubTypeID = 2000 
  
  from 
  (
    /* Individual services */

	select 
       cd.patID
     , numMins = cd.expectedMinsInd 
	 , planTypeSelectionID
	 , planIsIEPIFSP
     , SvcOnDOS = trim(lower(isnull((case 
       when @dow = 1 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.monInd')
       when @dow = 2 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.tueInd')
	   when @dow = 3 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.wedInd')
       when @dow = 4 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.thurInd')
       when @dow = 5 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.friInd')
       else null end) , N'false')))
  from @caseloadData as cd
  ) as ind
  where (ind.SvcOnDOS = N'true')

  union all

  /* Group services */

  select
      grp.patID
    , grp.numMins
	, grp.planTypeSelectionID
	, grp.planIsIEPIFSP
    , svcSubTypeID = 2001

  from 
  (
    select 
       cd.patID
     , numMins = cd.expectedMinsGrp 
     , planTypeSelectionID
	 , planIsIEPIFSP
	 , SvcOnDOS = trim(lower(isnull((case 
       when @dow = 1 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.monGrp')
       when @dow = 2 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.tueGrp')
	   when @dow = 3 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.wedGrp')
       when @dow = 4 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.thurGrp')
       when @dow = 5 then JSON_VALUE (cd.daysOfWeekSvcTmtProvidedJSON, '$.friGrp')
       else null end) , N'false')))
  from @caseloadData as cd
  ) as grp
  where (grp.SvcOnDOS = N'true')
) as q1

join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = q1.patID

where ((@pracPatGroupID is null) or (exists 
									(select top 1 id from PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW (
										@userID, @userGroup, @userRank, @clientID, @pracID, @pracPatGroupID, null, null, null, null, pap.PATIENT_ID)))
)
order by 
    pap.CONCAT_NAME
  , q1.svcSubTypeID

/*============================================================
 * If there are no patients found, exit
 *============================================================*/

if not exists (select top 1 id from @recs) return

/*============================================================
  * Determine prac group ID
  *============================================================*/

set @pracGroupID = null
select top 1 @pracGroupID = pg.[GROUP_ID] from dbo.PRACTITIONER_GROUPS as pg
where ((pg.[PRACTITIONER_ID] = @pracID) and (pg.[GROUP_TYPE] in( 1,2)))

/*============================================================
 * If group id is not found, exit
 *============================================================*/

if (@pracGroupID is null) return

/*============================================================
 * See if this is a telehealth only group
 *============================================================*/

set @telehealthPracOnly = 0

select top 1 
  @telehealthPracOnly = 1 
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
where (
      (png.GROUP_SERVICE_CLASS_PARTITION_ID = 500)
  and (png.GROUP_ID = @pracGroupID)
)

/*============================================================
  * If the practitioner is NOT telehealth only 
  * Find the in person service selections
  *============================================================*/

if (@telehealthPracOnly = 0)
begin

  update t1
    set 
        t1.serviceNameID  = svac2.SERVICE_NAME_ID
      , t1.serviceName    = svac2.SERVICE_NAME_STANDARD
  from @recs as t1

  cross apply (
    select top 1
        svac1.SERVICE_NAME_ID
      , svac1.SERVICE_NAME_STANDARD
    from dbo.SERVICES_VIEW_ALL_CORE (@clientID, @pracGroupID, t1.internalPlanTypeID, 2, null, 1, 1, @dos, 1) as svac1
    where ( 
          (svac1.SERVICE_SUB_TYPE_1_ID = t1.svcSubTypeID)
      and (svac1.PROCEDURE_NAME not like 'TLHL%') 
	  and (svac1.PROCEDURE_HAS_95 = 0)
    )
  ) as svac2
  where (t1.serviceNameID is null)
end

/*============================================================
  * If the practitioner IS telehealth only 
  * Find the only service selection available
  * There should ONLY be telehealth options available
  *============================================================*/

else
begin
  update t1
    set 
        t1.serviceNameID  = svac2.SERVICE_NAME_ID
      , t1.serviceName    = svac2.SERVICE_NAME_STANDARD
  from @recs as t1

  cross apply (
    select top 1
        svac1.SERVICE_NAME_ID
      , svac1.SERVICE_NAME_STANDARD
    from dbo.SERVICES_VIEW_ALL_CORE (@clientID, @pracGroupID, t1.internalPlanTypeID, 2, null, 1, 1, @dos, 1) as svac1
    where ( 
          (svac1.SERVICE_SUB_TYPE_1_ID = t1.svcSubTypeID)
	  and (svac1.PROCEDURE_HAS_95 = 1)
    )
  ) as svac2
  where (t1.serviceNameID is null)
end

/*============================================================
  * Attempt autoselection of ORP document and determines if
  * user needs to select a document.  
  *
  * Note: The selection required logic is also performed in
  * SERVICES_VIEW_BY_PRAC_PAT_PLAN.sql and the logic needs to be
  * kept in synch with any changes to that files logic.
  *============================================================*/

update t1
  set 
      t1.orpRequired             = t3.OrpRequired
    , t1.orpDocumentID           = t3.OrpDocumentID
    , t1.orpDocumentName         = t3.OrpDocumentName
	, t1.orpDocTypeID            = t3.OrpDocTypeID
	, t1.orpDocSelectionRequired = case when (t3.OrpDocumentID is not null) then 0 else 1 end
from @recs as t1
cross apply (
  select top 1
      t2.OrpRequired
    , t2.OrpDocumentID
    , t2.OrpDocumentName
	, t2.OrpDocTypeID
  from dbo.GET_ORP_PRAC_NPI_DATA (0, 2, @dos, @clientID, @pracGroupID, null, t1.patID,1 /*@procedureBillingProgramID*/) as t2 
) as t3
where (t1.orpDocumentID is null and t1.serviceNameID is not null)

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_CASELOAD_EXPECTED_PATIENT_TREATMENT_SERVICES_ON_DOS_VIEW] TO [webuser]
GO
