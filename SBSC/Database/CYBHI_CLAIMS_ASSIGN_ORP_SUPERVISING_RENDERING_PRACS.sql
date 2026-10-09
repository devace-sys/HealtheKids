use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_CLAIMS_ASSIGN_ORP_SUPERVISING_RENDERING_PRACS') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_CLAIMS_ASSIGN_ORP_SUPERVISING_RENDERING_PRACS
end
GO

CREATE PROCEDURE dbo.CYBHI_CLAIMS_ASSIGN_ORP_SUPERVISING_RENDERING_PRACS (  
  @transmissionID bigint	    
)
AS
BEGIN
  
set nocount on
 
declare @tommorow                      as datetime = convert(date,dateadd(day,1,getdate()))
declare @cybhiClinicalSupervisorPracID as bigint   = null
  
declare @claims as table (
    id                        bigint
  , clientID                  bigint
  , patInsuranceCarrierPcCode varchar(20)
  , dos                       date
  , renderingPracID           bigint
  , renderingPracGroupID      bigint
  , orpPracID                 bigint
  , supervisingPracID         bigint
  , claimingPracID            bigint
  , claimWithWhatPracMode     tinyint
  , svcRecID                  bigint
)

/*--------------------------------------------------------------------------------------------------------*/

/* Get default clinical supervisor  */

set @cybhiClinicalSupervisorPracID = 0

select top 1
  @cybhiClinicalSupervisorPracID = isnull(clc.cybhiClinicalSupervisorPracID,0)
from dbo.CYBHI_CLAIM_TRANSMISSIONS as cct
join dbo.CLIENTS_Client            as clc on clc.CLIENT_ID = cct.clientID
where 
  (cct.id = @transmissionID)
option(recompile)

/*--------------------------------------------------------------------------------------------------------*/

/* Find all active claims that dont have a claiming prac set.  
 * Claiming prac will be set at the end of this routine if everything passes.
 * **** The claiming prac value is our gatekeeper. ****
 */

insert into @claims (
    id
  , clientID
  , patInsuranceCarrierPcCode
  , dos
  , renderingPracID
  , renderingPracGroupID
  , svcRecID
)
select 
    id = t1.claimID
  , t1.clientID
  , t1.patInsuranceCarrierPcCode
  , t1.dos
  , t1.renderingPracID  
  , renderingPracGroupID = sr.groupID
  , svcRecID = sr.id
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, null) as t1  
join dbo.SERVICE_RECORDS                                                  as sr  on sr.id  = t1.svcRecID
option(recompile)

/*--------------------------------------------------------------------------------------------------------*/

/* ########## Claim With What Prac Mode 1 ##########
 *
 *            TARGETS LICENSED
 *
 * - claimingPrac is rendering prac
 * - orpPrac is rendering prac
 * - supervisingPrac does not apply
 * - claim note is NOT included 
 */

/* Requires 1 pass */

update clms
set
    clms.claimingPracID        = clms.renderingPracID
  , clms.orpPracID             = clms.renderingPracID
  , clms.supervisingPracID     = null 
  , clms.claimWithWhatPracMode = 1
from @claims                                                       as clms
join dbo.CYBHI_TRANSMISSION_GENERATION_VIEW_LICENSED_PRAC_GROUPS() as lpg on lpg.GROUP_ID = clms.renderingPracGroupID
where (
  (clms.claimingPracID is null)
)
option(recompile)

/*--------------------------------------------------------------------------------------------------------*/

/* ########## Claim With What Prac Mode 2 ########## 
 *
 *         TARGETS ASSOCIATE UNDER LICENSED
 *
 * - claimingPrac is rendering pracs direct supervisor
 * - orpPrac is rendering pracs direct supervisor
 * - supervisingPrac is rendering pracs direct supervisor
 * - claim note is included contains rendering prac name + npi
 */

/* Requires 2 passes */

update clms
set 
  claimWithWhatPracMode = 2
from @claims as clms
join dbo.CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS() as apg on apg.GROUP_ID = clms.renderingPracGroupID
where (
    (clms.claimingPracID is null)  
)
option(recompile)

update clms
set 
    clms.claimingPracID        = ppdss.SUPERVISING_PRAC_ID  
  , clms.orpPracID             = ppdss.SUPERVISING_PRAC_ID
  , clms.supervisingPracID     = ppdss.SUPERVISING_PRAC_ID
from @claims                                 as clms
join dbo.CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS()  as apg on apg.GROUP_ID = clms.renderingPracGroupID

/* Join makes sure claiming prac is not set if no direct sup is found.  Uses index */

join dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss on  ((ppdss.ACTIVE = 1)
                                                                         and (ppdss.SUPERVISED_PRAC_ID = clms.renderingPracID)
                                                                         and (clms.dos between convert(date,ppdss.START_DATE) and convert(date,isnull(ppdss.END_DATE,@tommorow)))
                                                                         and (ppdss.SUPERVISING_PRAC_ID is not null)
																		 and (ppdss.ID is not null)
																		 and (ppdss.relationshipTypeID = 10))
where (
      (clms.claimWithWhatPracMode = 2)  
  and (clms.claimingPracID is null)
)
option(recompile)

/*--------------------------------------------------------------------------------------------------------*/

/* ########## Claim With What Prac Mode 3 ##########
 *
 *   TARGETS PARA PROF THAT CANNOT CLAIM ON THEIR OWN
 *
 * - claimingPrac is clinical supervisor or dedicated orp supervisor
 * - orpPrac is CYBHI clinical supervisor or dedicated orp supervisor
 * - supervisingPrac is CYBHI clinical supervisor or dedicated orp supervisor
 * - claim note is included contains rendering prac name + npi
 */

/* Requires 4 passes */

update clms
set 
  claimWithWhatPracMode = 3
from @claims as clms 
join dbo.CYBHI_VIEW_PARA_PROF_PRAC_GROUPS() as  ppg on ppg.GROUP_ID = clms.renderingPracGroupID
                                            and ppg.IS_CLAIMING_PRAC_IN_837 = 0
where 
  (clms.claimingPracID is null)	
option(recompile)

/* Determine if we use clinical supervisor or dedicated orp */

update clms
set 
  clms.orpPracID = dbo.CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA (@cybhiClinicalSupervisorPracID, clms.renderingPracID, clms.dos, @tommorow, clms.svcRecID)  
from @claims as clms
where 
  (clms.claimWithWhatPracMode = 3)  
option(recompile)

/* OrpPrac is claiming and supervising */

update clms
set 
    clms.claimingPracID    = clms.orpPracID
  , clms.supervisingPracID = clms.orpPracID
from @claims as clms
where 
  (clms.claimWithWhatPracMode = 3)
option(recompile)

/* Make sure claiming and supervising and orp are reset to null if orp not found */

update clms
set 
    clms.claimingPracID        = null
  , clms.orpPracID             = null
  , clms.supervisingPracID     = null
from @claims as clms
where (       
      (clms.claimWithWhatPracMode = 3)
  and (clms.claimingPracID        = 0)
)
option(recompile)

/*--------------------------------------------------------------------------------------------------------*/

/* ########## Claim With What Prac Mode 4 ##########
 *
 *   TARGETS CREDENTIALED - INSURANCE IS MCAL OR PASS THROUGH
 *
 * - claimingPrac is rendering prac
 * - orpPrac is CYBHI clinical supervisor or dedicated orp supervisor
 * - supervisingPrac does not apply
 * - claim note is NOT included 
 */

/* Requires 3 passes */

update clms
set 
  claimWithWhatPracMode = 4
from @claims as clms
join dbo.CYBHI_VIEW_CREDENTIALED_PRAC_GROUPS() as cpg on cpg.GROUP_ID = clms.renderingPracGroupID
where (   
       (clms.claimingPracID is null)
   and (clms.patInsuranceCarrierPcCode in ('P','PC'))
)
option(recompile)

/* Determine if we use clinical supervisor or dedicated orp */

update clms
set 
    clms.claimingPracID        = clms.renderingPracID
  , clms.orpPracID             = dbo.CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA (@cybhiClinicalSupervisorPracID, clms.renderingPracID, clms.dos, @tommorow, clms.svcRecID)  
  , clms.supervisingPracID     = null
from @claims as clms
where  
  (clms.claimWithWhatPracMode = 4)
option(recompile)

/* Make sure claiming prac is not set if orp not found */

update clms
set 
    clms.claimingPracID        = null
  , clms.orpPracID             = null
  , clms.supervisingPracID     = null
from @claims as clms
where (       
      (clms.claimWithWhatPracMode = 4)
  and (clms.orpPracID = 0)
)
option(recompile)

/* ########## Claim With What Prac Mode 5 ##########
 *
 *  TARGETS CREDENTIALED - INSURANCE IS NOT MCAL PASSTHROUGH
 *
 * - claimingPrac is rendering prac
 * - orpPrac is rendering prac
 * - supervisingPrac is not set
 * - claim note is NOT included 
 */

update clms
set 
    claimWithWhatPracMode      = 5
  , clms.claimingPracID        = clms.renderingPracID
  , clms.orpPracID             = clms.renderingPracID
  , clms.supervisingPracID     = null 
from @claims as clms
join dbo.CYBHI_VIEW_CREDENTIALED_PRAC_GROUPS() as cpg on cpg.GROUP_ID = clms.renderingPracGroupID
where ( 
      (clms.claimingPracID is null)
  and (clms.patInsuranceCarrierPcCode = 'C')
)
option(recompile)

/*--------------------------------------------------------------------------------------------------------*/

/* ########## Claim With What Prac Mode 6 ##########
 *
 *   TARGETS PARA PROF THAT CAN CLAIM ON THEIR OWN - INSURANCE IS MCAL OR PASS THROUGH
 *
 * - claimingPrac is rendering prac
 * - orpPrac is CYBHI clinical supervisor or dedicated orp supervisor
 * - supervisingPrac does not apply
 * - claim note is NOT included 
 */

/* Requires 3 passes */

update clms
set 
  claimWithWhatPracMode = 6
from @claims as clms
join dbo.CYBHI_VIEW_PARA_PROF_PRAC_GROUPS() as  ppg on ppg.GROUP_ID = clms.renderingPracGroupID
                                            and ppg.IS_CLAIMING_PRAC_IN_837 = 1
where (   
       (clms.claimingPracID is null)
   and (clms.patInsuranceCarrierPcCode in ('P','PC'))
)
option(recompile)

/* Determine if we use clinical supervisor or dedicated orp */

update clms
set 
    clms.claimingPracID     = clms.renderingPracID
  , clms.orpPracID          = dbo.CYBHI_CLAIM_ASSIGN_ORP_DETERMINE_ORP_FOR_CREDENTIALED_OR_PARA (@cybhiClinicalSupervisorPracID, clms.renderingPracID, clms.dos, @tommorow, clms.svcRecID)  
  , clms.supervisingPracID  = null
from @claims as clms
where 
  (clms.claimWithWhatPracMode = 6)
option(recompile)

/* Make sure claiming prac is not set if orp not found */

update clms
set 
    clms.claimingPracID        = null
  , clms.orpPracID             = null
  , clms.supervisingPracID     = null
from @claims as clms
where (       
      (clms.claimWithWhatPracMode = 6)
  and (clms.orpPracID = 0)
)
option(recompile)

/* ########## Claim With What Prac Mode 7 ##########
 *
 *  TARGETS PARA PROF THAT CAN CLAIM ON THEIR OWN - INSURANCE IS NOT MCAL PASSTHROUGH
 *
 * - claimingPrac is rendering prac
 * - orpPrac is rendering prac
 * - supervisingPrac is not set
 * - claim note is NOT included 
 */

update clms
set 
    claimWithWhatPracMode      = 7
  , clms.claimingPracID        = clms.renderingPracID
  , clms.orpPracID             = clms.renderingPracID
  , clms.supervisingPracID     = null 
from @claims as clms
join dbo.CYBHI_VIEW_PARA_PROF_PRAC_GROUPS() as  ppg on ppg.GROUP_ID = clms.renderingPracGroupID
                                            and ppg.IS_CLAIMING_PRAC_IN_837 = 1
where ( 
      (clms.claimingPracID is null)
  and (clms.patInsuranceCarrierPcCode = 'C')
)
option(recompile)


/*--------------------------------------------------------------------------------------------------------*/

/* Update CYBHI claim records */

update cc
set    
   cc.supervisingPracID     = clms.supervisingPracID     /* Doc only right now */
 , cc.orpPracID             = clms.orpPracID             /* Used in 837 generation */
 , cc.claimWithWhatPracMode = clms.claimWithWhatPracMode /* Used in 837 generation */
 , cc.claimingPracID        = clms.claimingPracID        /* Used in 837 generation */
from @claims          as clms
join dbo.CYBHI_CLAIMS as cc on cc.id = clms.id
option(recompile)

END
GO
