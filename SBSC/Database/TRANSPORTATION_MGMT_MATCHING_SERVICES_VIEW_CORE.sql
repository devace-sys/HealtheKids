USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/*============================================================
 * For the given client find transportation services that
 * have at least one valid non transportation service for the 
 * same BIC/DOS.  Non transportation services can be provided by
 * other clients.
 *============================================================*/ 

CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE] (
   @userID                 bigint
 , @userGroup              int
 , @userRank               int
 , @clientID               bigint
 , @iep                    bit
 , @refDate                datetime
)

RETURNS @rows table (
    clientID         bigint
  , svcRecID         bigint
  , claimID          bigint
  , nonTransSvcRecID bigint
  UNIQUE CLUSTERED (clientID,svcRecID,claimID,nonTransSvcRecID)    
)
AS
BEGIN

/*============================================================
 * Required values
 *============================================================*/ 

if (@clientID is null) return

/*============================================================
 * Defaults
 *============================================================*/ 

if (@refDate is null)  set @refDate = getdate()
if (@iep     is null)  set @iep = 1

/*============================================================
 * Calculate min and max service dates
 *============================================================*/ 

declare @today     as datetime = @refDate 
declare @startDate as date     = convert(date,dbo.CALC_OLDEST_DOS_ALLOWED(@today))
declare @endDate   as date     = convert(date,@today)

/*============================================================
 * Setup table vars 
 *============================================================*/ 

declare @transSvcsDetail as table (
    clientID bigint
  , patID    bigint
  , dos      date
  , bic      nvarchar(14)
  , svcRecID bigint
  UNIQUE CLUSTERED (bic,dos,clientID,patID,svcRecID)    
)

declare @dupTransClaimSlots as table (
      clientID    bigint
    , patID       bigint
    , dos         date      
    , bic         nvarchar(14)

 UNIQUE CLUSTERED (bic,dos,clientID,patID)
)

declare @transSvcsSlots as table (
    clientID bigint
  , patID    bigint
  , dos      date  
  , bic      nvarchar(14) 
  , UNIQUE CLUSTERED (bic,dos,clientID,patID)
)

declare @bics as table (
   bic      nvarchar(14)   
 UNIQUE CLUSTERED (bic)
)

declare @bicsPatID as table (
   bic         nvarchar(14) 
  ,clientID    bigint
  ,patID       bigint    
UNIQUE CLUSTERED (bic,clientID,patID)
)

declare @otherSvcsDetail as table (
   clientID    bigint
  ,patID       bigint
  ,dos         date
  ,bic         nvarchar(14)
  ,svcRecID    bigint
UNIQUE CLUSTERED (bic,dos,clientID,patID,svcRecID)
)

declare @matches as table (
    transSvcRecID    bigint
  , nonTransSvcRecID bigint
UNIQUE CLUSTERED (transSvcRecID, nonTransSvcRecID) 
)

declare @tranSvcRecsToSend as table (    
     svcRecID         bigint    
UNIQUE CLUSTERED (svcRecID)
)

  
/*============================================================
 * Get trans service records for given client that have not
 * been sent.
 *============================================================*/ 
  
insert into @transSvcsDetail
select 
    sr.clientID
  , sr.patID
  , sr.dos
  , bic      = ltrim(rtrim(isnull(pp.BIC,'')))
  , svcRecID = sr.id  
from dbo.SERVICE_RECORDS  as sr
join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = sr.patID
where (      
      (sr.clientID  = @clientID) 
  and (sr.svcType   = dbo.CONST_SERVICES_TRANSPORT()) 
  and (   sr.state  = dbo.CONST_SVC_REC_STATE_NEW()
       or sr.state  = dbo.CONST_SVC_REC_STATE_MOD()) 
  and (sr.isIFSPorIEP = @iep)
  and (sr.patAbsent   = 0)
  and (sr.dos between @startDate and @endDate))
     
/*============================================================
 * Find slots from claims data that indicate the slot has 
 * already been sent
 *============================================================*/ 
   
insert into @dupTransClaimSlots
select distinct 
    clientID  = cc.CLIENT_ID
  , patientID = cc.PATIENT_ID
  , dos       = cc.SERVICE_DATE        
  , bic       = pp.BIC
from dbo.CLAIM_Claim           as cc
join dbo.CLAIM_Procedures      as cp  on cp.PROCEDURE_ID = cc.PROCEDURE_ID
join dbo.PATIENTS_Patient      as pp  on pp.PATIENT_ID   = cc.PATIENT_ID
where (
      (cc.CLIENT_ID = @clientID)
  and (cc.SERVICE_DATE between @startDate and @endDate)
  and (cc.STATUS != '1')    
  and (cp.SERVICE_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT())
)
  
/*============================================================
 * Condense down into slots and remove slots that have already
 * been claimed for
 *============================================================*/ 

insert into @transSvcsSlots
select distinct
    t1.clientID
  , t1.patID
  , t1.dos
  , t1.bic 
from @transSvcsDetail         as t1
left join @dupTransClaimSlots as t2 on t2.bic       = t1.bic
                                    and t2.dos      = t1.dos
                                    and t2.clientID = t1.clientID
                                    and t2.patID    = t1.patID
where (t2.patID is null)
  
group by 
    t1.clientID
  , t1.patID
  , t1.dos
  , t1.bic
  
/*============================================================
 * Get bics from slots
 *============================================================*/ 

insert into @bics
select distinct bic from @transSvcsSlots
where (bic != '')

/*============================================================
 * Get all client/patient ids associated with bics
 *============================================================*/ 

insert into @bicsPatID 
select distinct
    bic      = ltrim(rtrim(isnull(pp.BIC ,'')))
  , clientID = pc.CLIENT_ID
  , patID    = pp.PATIENT_ID 
from dbo.PATIENTS_Client  as pc
join dbo.PATIENTS_Patient as pp on pp.PATIENT_ID = pc.PATIENT_ID
join @bics                as b  on b.bic         = ltrim(rtrim(isnull(pp.BIC,'')))

/*============================================================
 * Get all non transportation services for the client/pat id
 * pairs we found
 *============================================================*/ 

insert into @otherSvcsDetail
select distinct
    sr.clientID
  , sr.patID
  , sr.dos
  , bpi.bic
  , svcRecID = sr.id  
from @bicsPatID                as bpi
join dbo.SERVICE_RECORDS       as sr  on  sr.clientID     = bpi.clientID
                                      and sr.patID        = bpi.patID                                
join dbo.SERVICE_RECORD_CLAIMS as src on  src.svcRecID    = sr.id
join dbo.CLAIM_Claim           as cc  on  cc.CLAIM_ID     = src.claimID
join dbo.CLAIM_Procedures      as cp  on  cp.PROCEDURE_ID = cc.PROCEDURE_ID
where (        
      (sr.svcType     != dbo.CONST_SERVICES_TRANSPORT())
  and (sr.svcType     != dbo.CONST_SERVICES_NON_BILL())           
  and (sr.state       != dbo.CONST_SVC_REC_STATE_DEL()) 
  and (sr.state       != dbo.CONST_SVC_REC_STATE_CIF())     
  and (sr.patAbsent   =  0)
  and (cp.PUT_IN_837  = 1) /* Covered service... can be IEP or non IEP */
  and (sr.dos between @startDate and @endDate))

/*============================================================
 * Match up
 *============================================================*/ 
 
insert into @matches
select distinct 
   transSvcRecID    = t1.svcRecID
 , nonTransSvcRecID = t2.svcRecID
from @transSvcsDetail as t1
join @otherSvcsDetail as t2 on  t2.bic = t1.bic
                            and t2.dos = t1.dos

/*============================================================
 * Sumarize
 *============================================================*/ 

insert into @tranSvcRecsToSend
select distinct 
    svcRecID         = ts.id    
from @matches            as sm
join dbo.SERVICE_RECORDS as ts   on ts.id = sm.transSvcRecID
join dbo.SERVICE_RECORDS as nts  on nts.id = sm.nonTransSvcRecID

/*============================================================
 * Output
 *============================================================*/ 

insert into @rows
select distinct
    clientID = @clientID
  , src.svcRecID
  , src.claimID 
  , tsm.nonTransSvcRecID
from dbo.SERVICE_RECORD_CLAIMS as src  
join @tranSvcRecsToSend as tsr on tsr.svcRecID      = src.svcRecID
join @matches           as tsm on tsm.transSvcRecID = src.svcRecID                       

return
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_MATCHING_SERVICES_VIEW_CORE] TO [webuser]
GO