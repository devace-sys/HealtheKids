/*###########################################################################*/
/*#    IMPORTANT NOTE REGARDING RENDERING AND REFERRING PRACTITIONERS       #*/
/*#                                                                         #*/
/*# 1. The CYBHI program limits practitioners that CLAIMS can be submitted  #*/         
/*# under (rendering practitioner) to licensed practitioners in most cases. #*/
/*# The only exceptions are if the procedures are discipline specific such  #*/
/*# as for para profs like CWC or CHW.                                      #*/
/*#                                                                         #*/
/*# So in the cases where its not a licensed prac or para prof              #*/ 
/*# the program allows for services that were rendered by non licensed      #*/ 
/*# practitioners to be claimed THROUGH a licensed practitioner.            #*/
/*#                                                                         #*/
/*# 2. The CYBHI program requires a referring practitioner for Medi-Cal     #*/         
/*# doc purposes and this practitioner must be a licensed practitioner.     #*/
/*#                                                                         #*/
/*# To facilitate 1 and 2 we use a claimingPracID.  The value of this is    #*/
/*# assigned before this routine is run.  The claimingPracID may not be     #*/
/*# the prac who actualy rendered the service.                              #*/
/*###########################################################################*/

use SPEDMON 
GO

/*---------------------------------------------------------------------------------------------------------*/

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].CYBHI_TRANSMISSION_GENERATION_CREATE_837_FILE_CONTENT') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
begin
  drop PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_CREATE_837_FILE_CONTENT
end
GO

/*---------------------------------------------------------------------------------------------------------*/

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.CYBHI_TRANSMISSION_GENERATION_CREATE_837_FILE_CONTENT (  
      @transmissionID bigint     
	, @userID         bigint  	
)
AS
BEGIN

set nocount on

declare @msgStr as varchar(512) = ''

exec dbo.PRINT_STATUS_MESSAGE 'Loading static constants'

/*#########################################################################
  #
  #                     Define Static Constants
  #
  #########################################################################*/

/*---------------------------------------------------------
  | Reserved characters
  ---------------------------------------------------------*/

declare @seg_term       as varchar(1)   = '~'	/* Segment Terminator */
declare @el_sep         as varchar(1)   = '*'	/* Element Seperator */
declare @subel_sep      as varchar(1)   = ':'	/* Subelement Seperator */
declare @rep_sep        as varchar(1)   = '^'	/* Repetition Seperator - see ISA11 */
declare @charsToRemove  as varchar(10)  = @seg_term + @el_sep + @subel_sep + @rep_sep 

/*---------------------------------------------------------
  | Clearing house / Sender/ Payer / Receiver IDS
  ---------------------------------------------------------*/

/* Clearing house */

declare @isaSenderID   as varchar(10) = 'AV09311993'  /* Availity */
declare @isaReceiverID as varchar(9)  = '030240928'   /* Availity */

declare @pcal_availity_id         as varchar(7)   = '1817530'         /* Availity customer ID for PCAL */
declare @pcal_availity_name       as varchar(33)  = 'Practi-Cal'
declare	@pcal_poc_name            as varchar(60)  = 'Chuck Muirhead'
declare @pcal_poc_phone           as varchar(80)  = '6616454956'            

--declare @carelon_availity_ID      as varchar(5)   = 'BHOVO'                     /* Availity customer ID */
--declare @calelon_availity_name    as varchar(25)  = 'CARELON BEHAVIORAL HEALTH' /* Availity short Name: BEACONHO */

declare @carelon_availity_ID      as varchar(80)  = 'BHOTP'                                      /* Availity customer ID */
declare @calelon_availity_name    as varchar(60)  = 'CARELON BEHAVIORAL HEALTH CA CYBHI PROGRAM' /* Availity short Name: CYBHI */

/*#########################################################################
  #
  #                         Define Globals
  #
  #########################################################################*/

/*---------------------------------------------------------
  | Date and time stamps
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Computing various date and time stamps'

declare @today as datetime = getdate()

declare @todayCCYYMMDD as varchar(8) = CONVERT(varchar(4),YEAR(@today)) 
                                     + RIGHT('0' + CONVERT(varchar(2),MONTH(@today)),2)
				                     + RIGHT('0' + CONVERT(varchar(2),DAY(@today))  ,2) 

declare @todayYYMMDD as varchar(6) = RIGHT(CONVERT(varchar(4),YEAR(@today)),2) 
                                    + RIGHT('0' + CONVERT(varchar(2),MONTH(@today)),2)
				                    + RIGHT('0' + CONVERT(varchar(2),DAY(@today))  ,2) 
			
declare @todayHHMM as varchar(4) = RIGHT('0' + CONVERT(varchar(2), DATEPART(hour,  @today)),2) 
                                 +  RIGHT('0' + CONVERT(varchar(2), DATEPART(minute,@today)),2) 
/*---------------------------------------------------------
  | Control Numbers
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Computing various control numbers'

declare @txIDStr              as varchar(8)  = RIGHT( '0000000000' + convert(varchar(50), @transmissionID),8)
declare @interchange_ctrl_num as varchar(9)  = '1' + @txIDStr       /* No leading 0s allowed */                                       
declare @group_ctrl_num       as varchar(9)  = '2' + @txIDStr       /* No leading 0s allowed */
declare @trans_ctrl_num       as varchar(9)  = '3' + @txIdStr       /* No leading 0s allowed */
declare @bht_batch_num        as varchar(30) = 'CYBHI-' + convert(varchar(24), @transmissionID);

/*---------------------------------------------------------
  | Content control
  ---------------------------------------------------------*/

declare @segsPerSvcRec        as int          = 4
declare @testOrProd           as char(1)      = 'P'
declare @cif                  as bit          = 0
declare @numPats              as int          = 0
declare @numSvcRecs           as int          = 0
declare @numNoteSegs          as int          = 0
declare @numSvcFacilityLoops  as int          = 0
declare @numSvcFacilitySegs   as int          = 0
declare @numClaims            as int          = 0
declare @segmentCount         as int          = 0
declare @totalAmountInFile    as money        = 0

/*---------------------------------------------------------
  | Client Data
  ---------------------------------------------------------*/

declare @claimingClientID            as bigint       = -1
declare @billingClientID             as bigint       = -1
declare @consortium                  as bit          = 0
declare @billingIsNotClaimingClient  as bit          = 0
declare @billingClientName           as varchar(33)  = ''
declare @billingClientNPI            as varchar(10)  = ''
declare @billingClientTaxID          as varchar(10)  = ''
declare @billingClientTpaID          as varchar(80)  = '' /* min 2 , max 80 chars */
declare @billingClientAddress1       as varchar(26)  = ''
declare @billingClientAddress2       as varchar(26)  = ''
declare @billingClientCity           as varchar(18)  = ''
declare @billingClientState          as varchar(2)   = ''
declare @billingClientZip            as varchar(9)   = ''

declare @claimingClientName          as varchar(33)  = ''
declare @claimingClientAddress1      as varchar(26)  = ''
declare @claimingClientAddress2      as varchar(26)  = ''
declare @claimingClientCity          as varchar(18)  = ''
declare @claimingClientState         as varchar(2)   = ''
declare @claimingClientZip           as varchar(9)   = ''
declare @claimingClientZip5          as varchar(5)   = ''
declare @claimingClientZip4          as varchar(5)   = ''

/*---------------------------------------------------------
  | Content building
  ---------------------------------------------------------*/

declare @header               as varchar(max) = ''
declare @body                 as varchar(max) = ''
declare @footer               as varchar(max) = ''
declare @fileContent          as varchar(max) = ''
declare @curPatIdx            as int          = 0
declare @maxPatIdx            as int          = 0

/*---------------------------------------------------------
  | Claim and service data
  ---------------------------------------------------------*/

declare @claims as table (
    patID                   bigint
  , svcRecID                bigint
  , claimLineNum            int
  , claimID                 bigint
  , claimingPracID          bigint
  , dosCCYYMMDD             varchar(256)
  , procModCombo            varchar(256)
  , numUnitsStr             varchar(256)
  , amountClaimed           money
  , amountClaimedStr        varchar(256)
  , icd10CodeStr            varchar(256)
  , placeOfSvcCodeStr       varchar(256)
  , ccn                     varchar(256)
  , referenceID             varchar(20)
  , renderingPracID         bigint
  , orpPracID               bigint
  , claimingIsNotRendering  bit default(0)
  , siteID                  bigint
  , loop2400                varchar(max)
  , patInsuranceCarrierID   bigint       /* Possible future use */
  , patInsuranceMemberID    varchar(80)
unique clustered (patID, svcRecID, claimLineNum, claimID)
)

/*---------------------------------------------------------
  | Service data
  ---------------------------------------------------------*/

declare @svcs as table (
    patID                   bigint
  , svcRecID                bigint
  , claimingPracID          bigint
  , referenceID             varchar(20)
  , numClaims               int
  , totAmountClaimed        money    
  , generateNoteSegment     bit default(0)
  , noteSegment             varchar(max)
  , renderingPracID         bigint 
  , orpPracID               bigint
  , loop2300                varchar(max)
  , loop2310A               varchar(max) /* Referring Prac */
  , loop2310B               varchar(max) /* Rendering Prac */
  , loop2310C               varchar(max) default('')
  , siteID                  int
  , includeSvcFacilityLoop  bit default(0) /* Important that this is defaulted to 0 */
  
unique clustered (patID, svcRecID)
)

declare @sites as table (
     siteID         int
   , siteNameStr    varchar(100)
   , siteAddressStr varchar(55)
   , siteCityStr    varchar(30)
   , siteStateStr   varchar(2)
   , siteZip5Str    varchar(5)
   , siteZip4Str    varchar(4)
   , loop2310C      varchar(max) /* Service Facility */

unique clustered (siteID)
)

/*---------------------------------------------------------
  | Patient data
  ---------------------------------------------------------*/

declare @pats as table (
    idx                   int identity(2,1) /* Start count at 2.  We use this for HLs. */
  , patID                 bigint
  , patInsuranceMemberID  varchar(80)
  , lname                 varchar(256)
  , fname                 varchar(256)
  --, tpaID                 varchar(256)  
  , dobCCYYMMDD           varchar(8)
  , sex                   varchar(1)
  , street1	              varchar(55) default('')
  , city	              varchar(30) default('')
  , [state]	              varchar(2)  default('')
  , zip5	              varchar(5)  default('')
  , loop2000B             varchar(max)
  , loop2010BA            varchar(max)
  , loop2010BB            varchar(max)
unique clustered (idx)
)

/*---------------------------------------------------------
  | Practitioner data
  ---------------------------------------------------------*/

declare @pracs as table (
    pracID     bigint
  , lname      varchar(256)
  , fname      varchar(256)
  , npi        varchar(256)
unique clustered (pracID)
)
					
/*#########################################################################
  #
  #                             Get data
  #
  #########################################################################*/

/*---------------------------------------------------------
  | Load transmission data
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading transmission data'

select top 1 
    @claimingClientID = cct.clientID 
  , @billingClientID  = cct.billingClientID
  , @consortium       = cct.consortium
  , @cif              = 0
from dbo.CYBHI_CLAIM_TRANSMISSIONS as cct
where 
  (cct.id = @transmissionID)
option(recompile)

/*---------------------------------------------------------
  | Determine if we have seperate billing and claiming
  | clients.  
  ---------------------------------------------------------*/

set @billingIsNotClaimingClient = 0

if (@consortium = 1)
begin
  if (@claimingClientID != @billingClientID)
  begin
    set @billingIsNotClaimingClient = 1
  end
  else
  begin
    set @billingIsNotClaimingClient = 0
  end
end
else
begin
  set @billingIsNotClaimingClient = 0
end

/*---------------------------------------------------------
  | Expected segments per service record
  |
  | 4 for new claims
  | 5 for cif claims
  ---------------------------------------------------------*/

set @segsPerSvcRec = 4
if (@cif = 1) set @segsPerSvcRec = 5

/*---------------------------------------------------------
  | Get billing client name, npi, and taxid.  Sanitize fields
  | Note: The transmission routine would have not allowed
  |       this routine to run if the data was invalid. 
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading billing client data and sanitizing'

select top 1 
    @billingClientName  = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cli.cybhiClientName,1,1,1,1,33), @charsToRemove,null)
  , @billingClientNPI   = trim(cli.cybhiNPI)
  , @billingClientTaxID = trim(cli.cybhiTaxID)
  , @billingClientTpaID = trim(cli.cybhiTpaID)
from dbo.CLIENTS_Client as cli 
where 
  (cli.CLIENT_ID = @billingClientID)
option(recompile)

/*---------------------------------------------------------
  | Get billing client address.  Sanitize.
  | Note: The transmission routine would have not allowed
  |       this routine to run if the address was incomplete.
  ---------------------------------------------------------*/

select top 1 
    @billingClientAddress1  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla.cybhiAddress1,''),'.',''),26)))),@charsToRemove,null)
  , @billingClientAddress2  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla.cybhiAddress2,''),'.',''),26)))),@charsToRemove,null)
  , @billingClientCity      = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(cla.cybhiCity, 18)))),@charsToRemove,null)
  , @billingClientState     = trim(upper(cla.cybhiState))
  , @billingClientZip       = trim(upper(LEFT(cla.cybhiZip5 + isnull(cla.cybhiZip4,''),9)))
from dbo.CLIENTS_Client as cla 
where 
  (cla.CLIENT_ID = @billingClientID)
option(recompile)

exec dbo.PRINT_STATUS_MESSAGE 'Loading claiming client data and sanitizing'

/*---------------------------------------------------------
  | Get claiming client data - Sanitize
  | Note: The transmission routine would have not allowed
  |       this routine to run if the data was invalid. 
  ---------------------------------------------------------*/

select
    @claimingClientName  = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cli.cybhiClientName,1,1,1,1,33), @charsToRemove,null)
from dbo.CLIENTS_Client as cli 
where 
  (cli.CLIENT_ID = @claimingClientID)
option(recompile)

/*---------------------------------------------------------
  | Get claiming client address.  Sanitize.
  | Note: The transmission routine would have not allowed
  |       this routine to run if the address was incomplete.
  ---------------------------------------------------------*/

select top 1 
    @claimingClientAddress1  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla.cybhiAddress1,''),'.',''),26)))),@charsToRemove,null)
  , @claimingClientAddress2  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla.cybhiAddress2,''),'.',''),26)))),@charsToRemove,null)
  , @claimingClientCity      = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(cla.cybhiCity, 18)))),@charsToRemove,null)
  , @claimingClientState     = trim(upper(cla.cybhiState))
  , @claimingClientZip       = trim(upper(LEFT(cla.cybhiZip5 + isnull(cla.cybhiZip4,''),9)))
  , @claimingClientZip5      = trim(upper(left(cla.cybhiZip5,5)))
  , @claimingClientZip4      = trim(upper(left(isnull(cla.cybhiZip4,''),4)))

from CLIENTS_Client as cla 
where 
  (cla.CLIENT_ID = @claimingClientID)
option(recompile)

/*---------------------------------------------------------
 | Get sites (data is pre sanitized) 
 ---------------------------------------------------------*/

insert into @sites (
     siteID  
   , siteNameStr    
   , siteAddressStr 
   , siteCityStr 
   , siteStateStr
   , siteZip5Str 
   , siteZip4Str 
)
select 
     ss.siteID  
   , ss.siteNameStr    
   , ss.siteAddressStr 
   , ss.siteCityStr 
   , ss.siteStateStr
   , ss.siteZip5Str 
   , ss.siteZip4Str 
from dbo.CYBHI_TRANSMISSION_GENERATION_GET_SITES (@transmissionID) as ss
where (
      (ss.internalSite = 0) /* Exclude unknown school code, etc.  Svcs delivered at these site will use the biller facility if biller facility is same as claiming client facility. */
  and (ss.siteApproved = 1) /* Only approved sites.  Sites that are not approved will fallback to biller facility if biller facility is same as claiming client facility. */
)
option(recompile)

/*---------------------------------------------------------
  | If the billing client is NOT the claiming client
  | then we need to include the claiming client facility
  | as a site.
  ---------------------------------------------------------*/

if (@billingIsNotClaimingClient = 1)
begin

  insert into @sites (
       siteID  
     , siteNameStr    
     , siteAddressStr 
     , siteCityStr 
     , siteStateStr
     , siteZip5Str 
     , siteZip4Str 
  )
  values (
       -1
     , @claimingClientName
     , @claimingClientAddress1
     , @claimingClientCity
     , @claimingClientState
     , @claimingClientZip5
     , @claimingClientZip4  
  )
  option(recompile)
end

/*---------------------------------------------------------
 | Generate service facility loop for each site
 ---------------------------------------------------------*/

update @sites
set loop2310C = ''

/* NM1 - SERVICE FACILITY LOCATION NAME */

+ 'NM1'       /* 00 */ 
+ @el_sep 
+ '77'        /* 01 */    
+ @el_sep 
+ '2'         /* 02 */    
+ @el_sep 
+ siteNameStr /* 03 */ 
+ @el_sep 
+ @el_sep     /* 04 */
+ @el_sep     /* 05 */
+ @el_sep     /* 06 */
+ @el_sep     /* 07 */
+ @seg_term   

/* N3 - SERVICE FACILITY LOCATION ADDRESS */

+ 'N3'           /* 00*/
+ @el_sep 
+ siteAddressStr /* 01 */ 
+ @seg_term

/* N4 - SERVICE FACILITY LOCATION CITY, STATE, ZIP CODE */

+ 'N4'         /* 00 */    
+ @el_sep 
+ siteCityStr  /* 01 */ 
+ @el_sep 
+ siteStateStr /* 02 */ 
+ @el_sep 
+ siteZip5Str  /* 03 */
+ siteZip4Str 
+ @seg_term
option(recompile)

/*---------------------------------------------------------
  | Get claims data from claim ids passed in
  | and create some of the element values needed for later
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading claims data and creating some of the element values needed'

insert into @claims (    
    patID
  , svcRecID
  , claimLineNum 
  , claimID 
  , claimingPracID     
  , dosCCYYMMDD  
  , procModCombo
  , numUnitsStr
  , amountClaimed
  , amountClaimedStr 
  , icd10CodeStr
  , placeOfSvcCodeStr  
  , ccn   
  , referenceID
  , renderingPracID
  , orpPracID
  , claimingIsNotRendering
  , siteID
  , patInsuranceCarrierID
  , patInsuranceMemberID 
)
select 
    cc.patID    
  , cc.svcRecID
  , claimLineNum = cc.claimLineNum  
  , cc.claimID  
  , cc.claimingPracID

  , dosCCYYMMDD = LEFT((CONVERT(varchar(4), YEAR(cc.dos))),4)
                + RIGHT('0' + CONVERT(varchar(2), month(cc.dos)),2) 
                + RIGHT('0' + CONVERT(varchar(2), DAY(cc.dos)),2) 

  , procModCombo = upper(trim(convert(varchar(10),cp.PROCEDURE_CODE)) 
	        	 + @subel_sep 
				 + convert(varchar(2),(trim(isnull(cp.PROCEDURE_MODIFIER_1,N''))))
                 + @subel_sep 
				 + convert(varchar(2),(trim(isnull(cp.PROCEDURE_MODIFIER_2,N''))))
                 + @subel_sep 
				 + convert(varchar(2),(trim(isnull(cp.PROCEDURE_MODIFIER_3,N''))))
                 + @subel_sep 
				 + convert(varchar(2),(trim(isnull(cp.PROCEDURE_MODIFIER_4,N''))))
				 )

  , numUnitsStr       = trim(convert(varchar(256),cc.numUnits))
  , amountClaimed     = cc.amountClaimed
  , amountClaimedStr  = trim(convert(varchar(256),cc.amountClaimed))
  , icd10CodeStr      = upper(replace(trim(convert(varchar(256),isnull(cp.ICD_10_DIAGNOSIS_CODE,''))),'.',''))
  , placeOfSvcCodeStr = trim(isnull(cp.PLACE_OF_SERVICE_CODE,''))
  , ccn               = ''
  , cc.referenceID
  , cc.renderingPracID
  , cc.orpPracID
  , claimingIsNotRendering = iif ((cc.claimWithWhatPracMode in (2,3)),1,0)  /* 1 (licensed) , 4,5 (credentialed), and 6,7 (certain para) can claim under their name */
  , cc.siteID
  , cc.patInsuranceCarrierID
  , cc.patInsuranceMemberID 

from dbo.CYBHI_TRANSMISSION_GENERATION_GET_CLAIMS (@transmissionID, 0) as cc
join dbo.CLAIM_Procedures                                              as cp on cp.PROCEDURE_ID = cc.procedureID
order by 
    cc.patID
  , cc.svcRecID
  , cc.claimLineNum
  , cc.claimID
option(recompile)

/*---------------------------------------------------------
  | Get claim count.  
  | We will use this as part of a segment count checksum.
  ---------------------------------------------------------*/

set @numClaims = 0
select @numClaims = count(clms.claimID) from @claims as clms option(recompile)

/*---------------------------------------------------------
  | From the claims data get claiming and rendering prac ids  
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading claiming, rendering, and orp practitioner data and sanitizing'

insert into @pracs (
  pracID
)
select distinct 
  pracID
from
(
  select distinct 
    pracID = cc.claimingPracID
  from @claims as cc

  union

  select distinct 
    pracID = cc.renderingPracID
  from @claims as cc

  union

  select distinct 
    pracID = cc.orpPracID
  from @claims as cc

) as q1
order by 
  q1.pracID
option(recompile)

/*---------------------------------------------------------
  | Get claiming and rendering pracs names and npi #s.  
  | Sanitize.
  ---------------------------------------------------------*/

update cp
set
    cp.lname  = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.LAST_NAME,1,1,1,1,null)),@charsToRemove,null)
  , cp.fname  = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.FIRST_NAME,1,1,1,1,null)),@charsToRemove,null)
  , cp.npi    = trim(isnull(prp.npiNumber,''))
from @pracs                        as cp
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = cp.pracID
option(recompile)

/*---------------------------------------------------------
  | From the claims data get patient ids 
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading patient data and sanitizing'

insert into @pats ( 
      patID  
	, patInsuranceMemberID
)
select distinct
    patID                = clms.patID 
  , patInsuranceMemberID = clms.patInsuranceMemberID
from @claims as clms
order by 
  clms.patID
option(recompile)

/*---------------------------------------------------------
  | Get patient count.  
  | We will use this as part of a segment count checksum.
  ---------------------------------------------------------*/

set @numPats = 0
select @numPats = count(pats.patID) from @pats as pats option(recompile)

/*---------------------------------------------------------
  | Get patient name, insurance, and demographic data
  | and santitize.
  ---------------------------------------------------------*/

update pats
set 
    pats.lname   = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.LAST_NAME,1,1,1,1,null)),@charsToRemove,null)  
  , pats.fname   = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.FIRST_NAME,1,1,1,1,null)),@charsToRemove,null)
 
  , pats.dobCCYYMMDD = CONVERT(varchar(4),YEAR(pap.DATE_OF_BIRTH)) 
                     + RIGHT('0' + CONVERT(varchar(2),MONTH(pap.DATE_OF_BIRTH)),2)
				     + RIGHT('0' + CONVERT(varchar(2),DAY(pap.DATE_OF_BIRTH))  ,2) 
  , pats.sex         = isnull(pap.SEX,N'')  
  
  , pats.street1 = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.ADDRESS_1,1,1,1,0,55),@charsToRemove,null)  
  , pats.city    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.CITY,1,1,1,0,30),@charsToRemove,null)  
  , pats.[state] = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.[STATE],0,0,1,0,2),@charsToRemove,null)  
  , pats.[zip5]  = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pp2.ZIP_5,0,1,0,0,5),@charsToRemove,null)  

from @pats                as pats
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pats.patID

/* Get patient home address */

cross apply (
  select top 1 
      --pp1.ID
	  pp1.ADDRESS_1
	--, pp1.ADDRESS_2
	, pp1.CITY
	, pp1.[STATE]
	, pp1.ZIP_5
	--, pp1.ZIP_4	
  from dbo.PATIENT_PLACES as pp1
  where (
        (pp1.PATIENT_ID         = pats.patID)
    and (pp1.PATIENT_PLACE_TYPE = 1)
    and (pp1.ACTIVE             = 1)
  )
  order by 
    pp1.ID desc
) as pp2
option(recompile)

/*---------------------------------------------------------
  | From the claim data get service data and totals
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Loading service data and computing totals'

insert into @svcs (
    patID
  , svcRecID
  , claimingPracID
  , renderingPracID 
  , orpPracID
  , referenceID
  , siteID
  , numClaims
  , totAmountClaimed
)
select
    clms.patID
  , clms.svcRecID
  , clms.claimingPracID
  , clms.renderingPracID
  , clms.orpPracID
  , clms.referenceID
  , clms.siteID
  , numClaims        = count(clms.claimID)
  , totAmountClaimed = sum(clms.amountClaimed) 
from @claims as clms
group by 
    clms.patID
  , clms.svcRecID
  , clms.claimingPracID
  , clms.renderingPracID
  , clms.orpPracID
  , clms.referenceID
  , clms.siteID
option(recompile)

/*---------------------------------------------------------
  | From the claim and service data determine if a note
  | segment is required for each service
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'For each svcs determine if a note segment is required'

update svcs
set
  svcs.generateNoteSegment = clms.claimingIsNotRendering
from @svcs   as svcs
join @claims as clms on  ((clms.patID    = svcs.patID) 
                     and (clms.svcRecID = svcs.svcRecID))
option(recompile)
				
/*---------------------------------------------------------
  | If the claiming and billing clients are different
  | then we need to have the claiming client added as a 
  | facility for cases where the siteID is either for
  | the unknown school code or the site was not approved
  | by the TPA.  We added the claiming client info as a 
  | site with an id of -1.
  ---------------------------------------------------------*/

if (@billingIsNotClaimingClient = 1)
begin
  update svcs
  set 
    siteID = -1
  from @svcs       as svcs
  left join @sites as ss on ss.siteID = svcs.siteID
  where 
    (ss.siteID is null)
  option(recompile)
end

/*---------------------------------------------------------
  | From the claim and service data determine if the facility
  | loop is required (this loop has 3 segments)
  ---------------------------------------------------------*/

update svcs
set 
  svcs.includeSvcFacilityLoop = 1
from @svcs  as svcs
join @sites as ss on ss.siteID = svcs.siteID
option(recompile)

/*---------------------------------------------------------
 | Get service record count.  
 | We will use this as part of a segment count checksum.
 ---------------------------------------------------------*/

set @numSvcRecs = 0
select @numSvcRecs = count(svcs.svcRecID) from @svcs as svcs option(recompile)

/*---------------------------------------------------------
 | Get total amount in transaction (recall one tx per file)
 | We will use this to report out a stat
 ---------------------------------------------------------*/

set @totalAmountInFile = 0
select @totalAmountInFile = sum(svcs.totAmountClaimed) from @svcs as svcs option(recompile)

/*---------------------------------------------------------
  | Get total note segment count
  | We will use this as part of a segement count checksum
  ---------------------------------------------------------*/

exec dbo.PRINT_STATUS_MESSAGE 'Determine total number of note segements'

set @numNoteSegs = 0

select 
  @numNoteSegs = count(svcs.svcRecID)
from @svcs as svcs
where 
  (svcs.generateNoteSegment = 1)
option(recompile)

/*---------------------------------------------------------
  | Get total svc facility segment count
  | We will use this as part of a segement count checksum
  ---------------------------------------------------------*/

set @numSvcFacilityLoops = 0
set @numSvcFacilitySegs  = 0

select 
  @numSvcFacilityLoops = count(svcs.svcRecID)
from @svcs as svcs
where 
  (svcs.includeSvcFacilityLoop = 1)
option(recompile)

set @numSvcFacilitySegs = 3 * @numSvcFacilityLoops


/*#########################################################################
  #
  #                     Get expected segment count
  #
  # The count is "a tally of all segments between the ST and the SE 
  # segments including the ST and SE segments." 
  #
  #########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Calculating segment count'

set @segmentCount = 11                               /* 11 header segments (fixed) */
                  + (@numPats     * 7)               /* 7 segments x number of patients */
				  + (@numSvcRecs  * @segsPerSvcRec)  /* 4 or 5 segements x num of svcs recs  */
				  + (@numNoteSegs)                   /* Will vary based on who rendered the service */
				  + (@numSvcFacilitySegs)            /* Will vary based on site that svcs was rendered at */
				  + (@numClaims   * 3)               /* 3 segements x num of claim recs */ 
				  + 1                                /* 1 footer segment (fixed) */
				  
set @msgStr = 'Expected segment count : ' + convert(varchar(50),@segmentCount)


exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*#########################################################################
  #
  #                            Generate Header
  #
  #########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Generating header segment data (ISA, GS, ST, BHT)'

/*---------------------------------------------------------
  | Generate header segments : 
  |
  | ISA, GS, ST, BHT
  |
  | and header loops : 
  |
  | LOOP 1000A  – SUBMITTER
  | LOOP 1000B  - RECEIVER
  | LOOP 2000A  - BILLING PROVIDER
  | LOOP 2010AA – BILLING PROVIDER NAME
  ---------------------------------------------------------*/

set @header = /* ########## Interchange Start Segment ########## */
             'ISA' 
			+ @el_sep  
            + '00'                      /* ISA 01 : 00 = No auth info present */
			+ @el_sep 
			+ '          '              /* ISA 02 : 10 blank spaces */ 
			+ @el_sep 
			+ '00'                      /* ISA 03 : 00 = No security info included*/
			+ @el_sep 
			+ '          '              /* ISA 04 : 10 blank spaces */
			+ @el_sep 
			+ 'ZZ'                      /* ISA 05: ZZ = Mutually defined */
			+ @el_sep 
			+ @isaSenderID + '     '    /* ISA 06 : Interchange Sender ID - Identification code published by the sender for other parties to use as the receiver ID to route data to them; the sender always codes this value in the sender ID element */
			+ @el_sep 
			+ '01'                      /* ISA 07 : 01 = Duns (Dun & Bradstreet)*/
			+ @el_sep 			  
			+ @isaReceiverID + '      ' /* ISA 08 : Interchange Receiver ID - Identification code published by the receiver of the data; When sending, it is used by the sender as their sending ID, thus other parties sending to them will use this as a receiving ID to route data to them.  Code + spaces */
			+ @el_sep 
			+ @todayYYMMDD              /* ISA 09 : Date */
			+ @el_sep 
		    + @todayHHMM                /* ISA 10 : Time*/
			+ @el_sep 
		    + @rep_sep                  /* ISA 11 : Rep sep */
			+ @el_sep 
			+ '00501'                   /* ISA 12 : Interchange Control Version Number - 00501*/
			+ @el_sep 
            + @interchange_ctrl_num     /* ISA 13 : Interchange Control Number - Must be a positive unsigned number and must be identical to the value in IEA02. Must be 9 chars */
			+ @el_sep 
			+ '1'                       /* ISA 14 : 1 = Sender requests acknowledge */
			+ @el_sep 
			+ @testOrProd               /* ISA 15 : Test or prod.  T= Test, P= Prod*/
			+ @el_sep                   
			+ @subel_sep 	            /* ISA 16 */
	        + @seg_term                 /* Terminator */ 
            
			/* ########## Functional Group Start Segment ########## */
            
			+ 'GS' 
			+ @el_sep 
            + 'HC' 
			+ @el_sep 
		    + @billingClientTpaID    /* Client TPA ID */
			+ @el_sep 
	  	    + @isaReceiverID  /* Availity */
			+ @el_sep 
			+ @todayCCYYMMDD
			+ @el_sep 
		    + @todayHHMM			
			+ @el_sep 
		    + @group_ctrl_num 
			+ @el_sep 
		    + 'X' 
			+ @el_sep 
	   	    + '005010X222A1'
	        + @seg_term
			
			/* ########## Transaction Set Start Segment ########## */
            
			+ 'ST' 
			+ @el_sep 
            + '837' 
			+ @el_sep 
	        + @trans_ctrl_num 
			+ @el_sep 
	        + '005010X222A1'  
	        + @seg_term

			/* ########## Hier Transaction Start Segment  ########## */
            
             + 'BHT' 
			 + @el_sep 
             + '0019' 
			 + @el_sep 
			 + '00'
			 + @el_sep 
			 + @bht_batch_num 
			 + @el_sep 
			 + @todayCCYYMMDD
			 + @el_sep 
			 + @todayHHMM
			 + @el_sep 
			 + 'CH'  
	         + @seg_term

            /* ########## LOOP 1000A – SUBMITTER ########## */

            + 'NM1'
			+ @el_sep 
            + '41' 
			+ @el_sep 
			+ '2'                 /* 2 = Non person entity*/
			+ @el_sep 
			+ @billingClientName         /* Last or Org name */ 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ ''
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '46' 
			+ @el_sep 
			+ @billingClientTpaID
			+ @seg_term
			
			+ 'PER' 
			+ @el_sep 
			+ 'IC' 
			+ @el_sep 
			+ @pcal_poc_name
			+ @el_sep 
			+ 'TE' 
			+ @el_sep 
			+ @pcal_poc_phone
	        + @seg_term 
			
			/* ########## LOOP 1000B - RECEIVER ########## */

            + 'NM1' 
			+ @el_sep 
			+ '40' 
			+ @el_sep 
			+ '2' 
			+ @el_sep 
			+ @calelon_availity_name
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '46' 
			+ @el_sep 
			+ @carelon_availity_id
			+ @seg_term

			/* ########## LOOP 2000A - BILLING PROVIDER ########## */
			
            + 'HL' 
			+ @el_sep 
            + '1'      /* HL 01 : idx 1 is assigned to client*/
			+ @el_sep 
		    + ''       /* HL 02 : Parent idx not used */
			+ @el_sep 
		    + '20'     /* HL 03 : 20 = Info source */
			+ @el_sep 
		    + '1'      /* HL 04 : 1= Has child HL */
			+ @seg_term 
			
            + 'PRV' 
			+ @el_sep 
            + 'BI' 
			+ @el_sep 
            + 'PXC' 
			+ @el_sep 
            + '261QS1000X' /* 261QS1000X is the taxonomy code for 'Student Health: Active'*/
            + @seg_term

		    /* ########## LOOP 2010AA – BILLING PROVIDER NAME ########## */

			+ 'NM1' 
			+ @el_sep 
			+ '85' 
			+ @el_sep 
			+ '2' 
			+ @el_sep 
			+ @billingClientName 
			+ @el_sep
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ '' 
			+ @el_sep 
			+ 'XX' 
			+ @el_sep 
			+ @billingClientNPI 
		    + @seg_term 			
			+ 'N3' 
			+ @el_sep 
			+ @billingClientAddress1
			+ @el_sep 
			+ @billingClientAddress2
			+ @seg_term	        
			+ 'N4' 
			+ @el_sep 
			+ @billingClientCity
			+ @el_sep 
			+ @billingClientState
			+ @el_sep
			+ @billingClientZip
		    + @seg_term 			
			+ 'REF' 
			+ @el_sep 
			+ 'EI'  
			+ @el_sep 
			+ @billingClientTaxID 			
		    + @seg_term

/*#########################################################################
  #
  #                            Generate Body
  #
  #########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Generating body'

/*---------------------------------------------------------
  | Generate loops for patient level data
  |
  | LOOP 2000B  - SUBSCRIBER HIERARCHICAL LEVEL
  | LOOP 2010BA - SUBSCRIBER NAME
  | LOOP 2010BB – PAYER NAME
  ---------------------------------------------------------*/

update pats
set 

/* ########## LOOP 2000B - SUBSCRIBER HIERARCHICAL LEVEL ########## */

loop2000B = 'HL' 
          + @el_sep 
          + CONVERT(varchar(256),idx)                    /* HL 01 */
		  + @el_sep 
          + '1' /*CONVERT(varchar(MAX), parentHL) */     /* HL 02 */
		  + @el_sep 
          + '22' 		                                 /* HL 03 */
		  + @el_sep 
          + '0'  /* 0 = No additional subordinate HL */  /* HL 04 */
          + @seg_term         	      
		  
		  + 'SBR' 
		  + @el_sep
	      + 'P'        /* 01  */ 
		  + @el_sep
		  + '18'       /* 02  18 = self*/ 
		  + @el_sep 
		  + ''         /* 03 */ 
		  + @el_sep 
		  + '' 		   /* 04 */ 
		  + @el_sep 
		  + ''         /* 05 : Ins type code */
		  + @el_sep 
		  + ''         /* 06 */
		  + @el_sep 
		  + ''         /* 07 */
		  + @el_sep
		  + ''        /*  08 */
		  + @el_sep
		  + 'ZZ'       /* 09 - 	Claim Filing Indicator Code : ZZ = Mutually defined or Unknown type of insurance */
		  + @seg_term 
		  
/* ########## LOOP 2010BA - SUBSCRIBER NAME ########## */

, loop2010BA = 'NM1' 
             + @el_sep 
			 + 'IL' 
			 + @el_sep 
			 + '1'  
			 + @el_sep 
			 + UPPER(LEFT(lName,35)) 
			 + @el_sep 
			 + UPPER(LEFT(fName,25)) 
			 + @el_sep 
			 + @el_sep 
			 + @el_sep 
			 + @el_sep 		
			 +'MI' 
			 + @el_sep 
		     + pats.patInsuranceMemberID
			 + @seg_term 
			 
			 + 'N3'
			 + @el_sep
			 + pats.street1
			 + @seg_term
			 
			 + 'N4'
			 + @el_sep
			 + pats.city
			 + @el_sep
			 + pats.[state]
			 + @el_sep
			 + pats.zip5	
			 + @seg_term

			 + 'DMG'
			 + @el_sep
			 + 'D8'
			 + @el_sep
			 + pats.dobCCYYMMDD
			 + @el_sep
			 + pats.sex
			 + @seg_term

/* ########## LOOP 2010BB – PAYER NAME ########## */

, loop2010BB = 'NM1' 
             + @el_sep 
             + 'PR'  
			 + @el_sep
		     + '2'   
			 + @el_sep
			 + @calelon_availity_name 
			 + @el_sep
			 + @el_sep 
			 + @el_sep 
			 + @el_sep
			 + @el_sep
			 + 'PI' 
			 + @el_sep
			 + @carelon_availity_ID  
			 + @el_sep
			 + @seg_term

from @pats as pats
option(recompile)

/*---------------------------------------------------------
  | Generate note segment for service record level data
  |
  | Note: The 837P uses a segment identifier of CLM to 
  | represent what we store in our service record
  ---------------------------------------------------------*/

update svcs
set 
  svcs.noteSegment = 'NTE'
                   + @el_sep
				   + 'ADD'
				   + @el_sep
                   + pracs.fname + ' ' + pracs.lname + ' ' + pracs.npi
                   + @seg_term
from @svcs  as svcs
join @pracs as pracs on pracs.pracID = svcs.renderingPracID
where 
  (svcs.generateNoteSegment = 1)
option(recompile)

/*---------------------------------------------------------
  | Generate loops for service record level data
  |
  | Note: The 837P uses a segment identifier of CLM to 
  | represent what we store in our service record
  |
  | LOOP 2300  - CLAIM INFORMATION       (2 or 3 segments + 1 for note if note is required)
  | LOOP 2310B - RENDERING PROVIDER NAME (1)
  | LOOP 2310A - REFERRING PROVIDER NAME (1) (ORP)
  ---------------------------------------------------------*/

update svcs
set 

/* ########## LOOP 2300 - CLAIM INFORMATION ########## */
	
svcs.loop2300 = 'CLM'
              + @el_sep
	          + svcs.referenceID		                    /* 01 - Cross reference for 835 */ 
		      + @el_sep
		      + convert(varchar(256),svcs.totAmountClaimed) /* 02 */
		      + @el_sep
		      + ''                                          /* 03 */
			  + @el_sep 
			  + ''                                         /* 04 */
			  + @el_sep 
			  + clms2.placeOfSvcCodeStr                    /* 05 */
			  + @subel_sep
		      + 'B' 
		      + @subel_sep
		      + iif((@cif = 0),'1','8')                   /* 1 = Freq Original, 8= Delete */
			  + @el_sep
			  + 'Y'                                       /* 06 - Provider signature on file */
			  + @el_sep
			  + 'A'                                       /* 07 - Provider Accept Assignment Code (A = Assigned) */
			  + @el_sep
			  + 'Y'                                      /* 08 - Benefits Assigned to Provider */
			  + @el_sep
			  + 'Y'                                      /* 09 - Release of info to other orgs authorized by patient */			  
			  + @seg_term	
			  
			  /* Include claim control number segment if this is a CIF */
			  
			  + iif((@cif = 1)
			        ,'REF' + @el_sep + 'F8' + @el_sep + clms2.ccn + @seg_term
					,'')	
		      
			  /* Include note segment if applicable */

			  + iif( ((@cif = 0) and (svcs.generateNoteSegment = 1))
			         , svcs.noteSegment
			         , '')

			  + 'HI'
		      + @el_sep
		      + 'ABK'
		      + @subel_sep		 
		      + clms2.icd10CodeStr
		      + @seg_term
			   
/* ########## LOOP 2310B - RENDERING PROVIDER NAME ##########*/

, svcs.loop2310B = 'NM1'
                 + @el_sep
			     + '82'     /* 01 */
			     + @el_sep
			     + '1'      /* 02 */
			     + @el_sep
			     + pracs.lname 
			     + @el_sep
			     + pracs.fname
			     + @el_sep
			     + ''         /* 05 */
			     + @el_sep
                 + ''         /* 06 */
			     + @el_sep
			     + ''         /* 07 */
			     + @el_sep
			     + 'XX'       /* 08 */
			     + @el_sep
				 + pracs.npi  /* 09*/
                 + @seg_term

/* ########## LOOP 2310C - SERVICE FACILITY NAME  ##########*/

, svcs.loop2310C = isnull(ss2.loop2310C,'')

/*----------*/

from @svcs  as svcs
join @pracs as pracs on pracs.pracID = svcs.claimingPracID

/*----------*/

cross apply (
  select top 1 
      clms1.placeOfSvcCodeStr
	, clms1.icd10CodeStr 
	, clms1.ccn
  from @claims as clms1 
  where ( 
        (clms1.patID        = svcs.patID)
    and (clms1.svcRecID     = svcs.svcRecID)
    and (clms1.claimLineNum = 1)
	and (clms1.claimID is not null)
  )
) as clms2

/*----------*/

outer apply (
  select top 1 
    ss1.loop2310C 
  from @sites as ss1 
  where ( 
        (svcs.includeSvcFacilityLoop = 1)
    and (ss1.siteID = svcs.siteID)
  )
) as ss2
option(recompile)

update svcs
set 
			   
/* ########## LOOP 2310A - REFERRING PROVIDER NAME ##########*/

svcs.loop2310A = 'NM1'
                 + @el_sep
				 + 'DN'
				 + @el_sep
				 + '1'
				 + @el_sep
				 + pracs.lname 
			     + @el_sep
			     + pracs.fname
			     + @el_sep
			     + ''         /* 05 */
			     + @el_sep
                 + ''         /* 06 */
			     + @el_sep
			     + ''         /* 07 */
			     + @el_sep
			     + 'XX'       /* 08 */
			     + @el_sep
				 + pracs.npi  /* 09*/
                 + @seg_term
/*----------*/

from @svcs  as svcs
join @pracs as pracs on pracs.pracID = svcs.orpPracID
option(recompile)

/*---------------------------------------------------------
  | Generate loops for claim record level data
  |
  | Note: The 837P uses multiple segments (LX, SV2) to 
  | represent what we store in our claim record
  |
  | LOOP 2400 - SERVICE LINE
  ---------------------------------------------------------*/
			
update clms
set 

/* ########## LOOP 2400 - SERVICE LINE ########## */

clms.loop2400 = 'LX' 
              + @el_sep 
              + convert(varchar(50),clms.claimLineNum)
		      + @seg_term 			
		      + 'SV1'  
		      + @el_sep
		      + 'HC'   
		      + @subel_sep 
		      + procModCombo 
		      + @el_sep 
		      + amountClaimedStr 
		      + @el_sep 
		      + 'UN'             
		      + @el_sep 
		      + numUnitsStr /* 04*/ 		
		      + @el_sep
			  + ''          /* 05*/
		      + @el_sep
			  + ''          /* 06*/
		      + @el_sep
			  + '1'         /* 07 - 1 */ 			  
			  + @seg_term 		   		   
		      + 'DTP' 
		      + @el_sep 
		      + '472' 
		      + @el_sep 
		      + 'RD8' 
		      + @el_sep 
		      + dosCCYYMMDD + '-' + dosCCYYMMDD		
		      + @seg_term

from @claims as clms
option(recompile)

/*---------------------------------------------------------
  | Build body
  ---------------------------------------------------------*/

select @maxPatIdx = max(pats.idx) from @pats as pats
set @curPatIdx = 2
set @body = ''

while (@curPatIdx <= @maxPatIdx)
begin
  
  declare @patID             as bigint       = -1
  declare @patLoops          as varchar(max) = ''
  declare @svcsAndClaimLoops as varchar(max) = ''

  /*---------------------------------------------------------
    | Get patient loops for patient
	| There is only 1 set of these per patient
    ---------------------------------------------------------*/

  select top 1  
     @patID    = pats.patID
   , @patLoops = pats.loop2000B + pats.loop2010BA + pats.loop2010BB 
  from @pats as pats
  where 
    (pats.idx = @curPatIdx)
  option(recompile)

  /*---------------------------------------------------------
    | Get service and claim loops
    | There are at least 1 set of these per patient
    ---------------------------------------------------------*/

  select
    
	/* All service record + claim line combos per patient */

    @svcsAndClaimLoops = STRING_AGG(convert(varchar(max),q1.svcAndClaimsLoops),'')
  
  from
  (
    select top 100  /* Each service record.  Spec limit of 100 per HL */
        svcAndClaimsLoops = svcs.loop2300 
		                  + svcs.loop2310A
		                  + svcs.loop2310B 
						  + svcs.loop2310C
						  + STRING_AGG(convert(varchar(max),clms2.loop2400),'')
    from @svcs as svcs
   
    cross apply (
      select top 50 /* Claim lines for each service record.  Spec limits to 50 */
	    clms1.loop2400 
	  from @claims as clms1
	  where 
	         (clms1.patID    = @patID)
	     and (clms1.svcRecID = svcs.svcRecID)
	  order by 
	    clms1.claimLineNum
    ) as clms2
    where 
      (svcs.patID = @patID)
	group by 
	    svcs.loop2300
	  , svcs.loop2310A
	  , svcs.loop2310B
	  , svcs.loop2310C
	  , svcs.svcRecID
	order by 
	  svcs.svcRecID
  ) as q1
  option(recompile)
  	  
  set @body = @body 
            + @patLoops
			+ @svcsAndClaimLoops

  set @curPatIdx = @curPatIdx + 1

end


/*#########################################################################
  #
  #                   Generate Footer (SE, GE, IEA)
  #
  #########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Generating footer (SE, GE, IEA)'
                 
set @footer = /* ########## Transaction Set End Segment ########## */
            'SE' 
			+ @el_sep 
            + RIGHT (convert(varchar(10),@segmentCount),10) 
			+ @el_sep 
		    + @trans_ctrl_num 
            + @seg_term 

			/* ########## Functional Group End Segment ########## */
            
			+ 'GE' 
			+ @el_sep 
            + '1'                  /* Number of transaction sets*/
			+ @el_sep 
			+ @group_ctrl_num 
		    + @seg_term
            
			/* ########## Interchange End Segment ########## */
			
			+ 'IEA' 
			+ @el_sep 
            + '1'                   /* Number of function groups */
			+ @el_sep 
			+ @interchange_ctrl_num
		    + @seg_term
	
/*#########################################################################
  #
  #                               Stats
  #
  #########################################################################*/

exec dbo.PRINT_STATUS_MESSAGE 'Stats'

set @msgStr = 'Number of Patients : ' + convert(varchar(50),@numPats)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Number of Notes : ' + convert(varchar(50),@numNoteSegs)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Number of Service Facilty : ' + convert(varchar(50),@numSvcFacilitySegs)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Number of Service Records : ' + convert(varchar(50),@numSvcRecs)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Number of Claim Lines : ' + convert(varchar(50),@numClaims)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Total Dollar Amount in File : ' + convert(varchar(50),@totalAmountInFile)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*#########################################################################
  #
  #                 Generate Complete 837P File Content
  #
  #########################################################################*/

set @msgStr = 'Generating complete 837 file content'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @fileContent = upper(@header) + upper(@body) + upper(@footer)

update dbo.CYBHI_CLAIM_TRANSMISSIONS 
  set 
     fileContent    = @fileContent
   , lastModified   = getdate()
   , lastModifiedBy = @userID
  where 
    (id = @transmissionID)
  option(recompile)

return(0)

END
GO
