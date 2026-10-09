USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE PROCEDURE dbo.PRACTITIONER_CASELOAD_MEMBER_Save_Core (
    @userID                    bigint  
  , @clientID                  bigint
  , @pracID                    bigint
  , @patID                     bigint  
  , @planType                  int
  , @spEdServiceCode           int   
  , @orpDocID		           bigint
  , @startDate                 date
  , @endDate                   date  
  , @spEdFreqCode              int
  , @minsPerFreq               int
  , @expectedMinsInd           int
  , @expectedMinsGrp           int
  , @daysOfWeekSvcProvidedJSON varchar(max)
  , @addInitCldExpSvc          bit = 0
  , @validateRec               bit      
  , @clientIdOut               bigint output
  , @pracIdOut                 bigint output
  , @patIdOut                  bigint output
  , @groupIdOut                bigint output
  , @groupSvcClassNameIdOut    bigint output
  , @caseloadEntryIdOut        bigint output
)    
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTITIONER_CASELOAD_MEMBER_Save_Core */    
/**    
 *    
 ***************************************************************************/        

declare @today      as datetime = getdate()
declare @minsDaily  as int      = 0
declare @minsAnn    as int      = 0

set @clientIdOut            = 0
set @pracIdOut              = 0
set @patIdOut               = 0
set @groupIdOut             = 0
set @groupSvcClassNameIdOut = 0
set @caseloadEntryIdOut     = 0

/*-------------------------------    
 * Verify required parms
 *------------------------------*/   

if (@userID      IS NULL) RAISERROR ('userID is required',      11, 1)      
if (@validateRec IS NULL) RAISERROR ('Validate flag required',  11, 1)    
if (@clientID    IS NULL) RAISERROR ('Client id required',      11, 1)				     
if (@pracID      IS NULL) RAISERROR ('Prac id required',        11, 1)				     
if (@patID       IS NULL) RAISERROR ('Pat id required',         11, 1)				     

/*-------------------------------    
 * Verify client, practitioner,
 * and patient ids
 *------------------------------*/   

declare @tuppleFound as bit = 0
  
select top 1 

      @clientIdOut  = cc.CLIENT_ID
    , @pracIdOut    = prp.PRACTITIONER_ID
	, @groupIdOut   = pg.GROUP_ID
    , @patIdOut     = pap.PATIENT_ID  
    , @tuppleFound = 1

from dbo.CLIENTS_Client            as cc
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = cc.CLIENT_ID
join dbo.PATIENTS_Client           as pac on pac.CLIENT_ID       = cc.CLIENT_ID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS       as pg  on ((pg.PRACTITIONER_ID  = prp.PRACTITIONER_ID) and (pg.GROUP_TYPE in (1,2)))
join dbo.GROUP_Group               as gg  on ((gg.GROUP_ID         = pg.GROUP_ID)         and (gg.GROUP_TYPE in (1,2)))
join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID      = pac.PATIENT_ID
where ( 
           (cc.CLIENT_ID        = @clientID) 
	  and  (prp.PRACTITIONER_ID = @pracID)  
      and  (pap.PATIENT_ID      = @patID)         
      and  (prp.ACTIVE = 1)
	  and  (gg.ACTIVE  = 1)
      and  (upper(ltrim(rtrim(pap.ACTIVE))) = 'Y')
)

if (@tuppleFound = 0)
begin
  RAISERROR ('Invalid client, practitioner, or patient id', 11, 1) 
end

/*-------------------------------    
 * Retrieve practitioner 
 * group family
 *------------------------------*/   

select top 1
  @groupSvcClassNameIdOut = png.GROUP_SERVICE_CLASS_NAME_ID 
from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png
where (
      (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
  and (png.GROUP_SERVICE_CLASS_NAME_ID is not null) /* For index */
  and (png.GROUP_ID = @groupIdOut)
)

/*-------------------------------    
 * Find existing caseload entry 
 * using
 * client, prac, pat tuple
 *------------------------------*/    

select top 1
   @caseloadEntryIdOut = ppc.id
from dbo.PRACTITIONER_PATIENT_CASELOAD as ppc
where ( 
        (ppc.clientID = @clientIdOut)
    and (ppc.pracID   = @pracIdOut)
    and (ppc.patID    = @patIdOut)
)

set @caseloadEntryIdOut = isnull(@caseloadEntryIdOut,0)

/*-------------------------------    
 * If validating exit
 *------------------------------*/    

if (@validateRec = 1) return(0)

/*-------------------------------    
 * Take care of virtual nulls
 *------------------------------*/   

if (@orpDocID        in (0,-1))         set @orpDocID        = null
if (@spEdServiceCode in (0,-1))         set @spEdServiceCode = null
if (@spEdFreqCode    in (0,-1))         set @spEdFreqCode    = null
if (@minsPerFreq     in (0,-1))         set @minsPerFreq     = null
if (isnull(@expectedMinsInd,0) <= 0)    set @expectedMinsInd = null
if (isnull(@expectedMinsGrp,0) <= 0)    set @expectedMinsGrp = null
if (isnull(@planType,0) in (0,-1))      set @planType = 1
if (@daysOfWeekSvcProvidedJSON is null) set @daysOfWeekSvcProvidedJSON = '{"monInd":false,"tueInd":false,"wedInd":false,"thurInd":false,"friInd":false,"monGrp":false,"tueGrp":false,"wedGrp":false,"thurGrp":false,"friGrp":false}'

/*-------------------------------    
 * If one does not exist
 * create a new one
 *------------------------------*/    

if (@caseloadEntryIdOut = 0)
begin
  insert into dbo.PRACTITIONER_PATIENT_CASELOAD (
        clientID
      , pracID
      , patID
	  , created
      , createdBy
    )    
    values ( 
        @clientID
      , @pracID
      , @patID
	  , @today
      , @userID
    )

	set @caseloadEntryIdOut = SCOPE_IDENTITY()
end
   
/*-------------------------------    
 * Compute expected minutes
 * total (for legacy use)
 *------------------------------*/    

set @minsAnn = isnull(dbo.SPED_CALC_TOTAL_MINUTES_EXPECTED_FOR_PLAN (@startDate, @endDate, @spEdFreqCode, @minsPerFreq),0)

/*-------------------------------    
 * Save legacy data
 *------------------------------*/    

update dbo.PRACTITIONER_PATIENT_CASELOAD
set 
    expectedMinsInd              = @expectedMinsInd            /* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */
  , expectedMinsGrp              = @expectedMinsGrp            /* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */
  , planType                     = @planType                   /* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */
  , daysOfWeekSvcTmtProvidedJSON = @daysOfWeekSvcProvidedJSON  /* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */
  , expectedMinsSvcTmtAnn        = @minsAnn                    /* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */  
  , lastModified                 = @today
  , lastModifiedBy               = @userID
where (id = @caseloadEntryIdOut)  

/*-------------------------------    
 * Manage legacy support data
 *------------------------------*/    

delete from dbo.PRACTITIONER_PATIENT_CASELOAD_ORP_DOCUMENTS     where (caseloadEntryID = @caseloadEntryIdOut)
delete from dbo.PRACTITIONER_PATIENT_CASELOAD_PROMISED_SERVICES where (caseloadEntryID = @caseloadEntryIdOut)

/*-------------------------------    
 * Caseload Promised Services
 *------------------------------*/    

/* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */

if (@planType = 1)
begin
  if (@spEdServiceCode is not null)
	begin
	  insert into dbo.PRACTITIONER_PATIENT_CASELOAD_PROMISED_SERVICES (caseloadEntryID, startDate, endDate, spEdSvcCode)
	  values (@caseloadEntryIdOut, @startDate, @endDate, @spEdServiceCode)
	end
end

/*-------------------------------    
 * Caseload ORP Docs
 *------------------------------*/    

/* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */

else if (@planType = 2)
begin
  if (@orpDocID is not null)
  begin
    insert into dbo.PRACTITIONER_PATIENT_CASELOAD_ORP_DOCUMENTS (caseloadEntryID, orpDocID)
    values (@caseloadEntryIdOut, @orpDocID)
  end
end

/*-------------------------------    
 * Patients expected services
 *------------------------------*/    

/* Legacy. Handled by PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES now */

set @minsDaily = isnull(@expectedMinsInd, 0) + isnull(@expectedMinsGrp, 0)
set @minsAnn   = 0

INSERT INTO dbo.PATIENTS_EXPECTED_SERVICES (
        CLIENT_ID
      , PATIENT_ID
      , [START_DATE] 
      , END_DATE
      , GROUP_SERVICE_CLASS_PARTITION_ID
      , GROUP_SERVICE_CLASS_NAME_ID
      , DAILY_MINUTES
      , DAILY_ENCOUNTERS
      , CREATED
      , CREATED_BY
      , LAST_MODIFIED
      , LAST_MODIFIED_BY
      , ACTIVE
      , SVC_TYPE_ID
      , ANNUAL_MINUTES
	  , INDIVIDUAL_MINUTES
	  , GROUP_MINUTES
	  , DAYS_OF_WEEK_JSON
	  , PLAN_TYPE         
)    
VALUES ( 
        @clientID
      , @patID
	  , @startDate
	  , null
	  , 100
	  , @groupSvcClassNameIdOut
	  , @minsDaily
	  , 1
	  , @today
	  , @userID
	  , null
	  , null
	  , 1
	  , 2 /* Treatment */
	  , @minsAnn
	  , @expectedMinsInd
	  , @expectedMinsGrp
	  , @daysOfWeekSvcProvidedJSON
	  , @planType
)

/*-------------------------------    
 * If called for add the initial
 * expected service
 *
 * Note: If at least one of these
 * records do not exist the
 * user will not see their 
 * caseload data
 *------------------------------*/    

if (@addInitCldExpSvc = 1)
begin
  if not exists (
    select top 1
       t2.id 
    from dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as t2
    where ( 
          (t2.caseloadEntryID = @caseloadEntryIdOut)
      and (t2.active = 1)
    )
  )
  begin
    insert into dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES (
        caseloadEntryID 
	  , clientID
	  , pracID
	  , patID
	  , svcTrackingClass
	  , planType  
	  , spEdServiceCode
	  , orpDocID  
	  , startDate  
	  , endDate 
	  , spEdFreqCode
	  , minsPerFreq 
      , expectedMinsInd 
	  , expectedMinsGrp
	  , daysOfWeekSvcProvidedJSON
      , created 
      , createdBy  
	  , hasSvcDetails
	  , svcDetailsJSON
    )
    values (
        @caseloadEntryIdOut
	  , @clientID
	  , @pracID
	  , @patID
	  , 300
	  , @planType
	  , @spEdServiceCode
	  , @orpDocID
	  , @startDate
	  , @endDate
	  , @spEdFreqCode
	  , @minsPerFreq
	  , @expectedMinsInd
	  , @expectedMinsGrp
	  , @daysOfWeekSvcProvidedJSON
	  , @today
	  , @userID
	  , 0
	  , '{}'
    )
  end
end

RETURN(0)    

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONER_CASELOAD_MEMBER_Save_Core] TO [webuser]
GO
