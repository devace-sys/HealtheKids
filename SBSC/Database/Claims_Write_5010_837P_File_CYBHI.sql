USE SPEDMON
GO

if OBJECT_ID('Claims_Write_5010_837P_File_CYBHI') is not null
  drop procedure Claims_Write_5010_837P_File_CYBHI
go

/***************************************************************************/

USE SPEDMON
GO

CREATE PROCEDURE dbo.Claims_Write_5010_837P_File_CYBHI (
    @clientID       as bigint       = -1
  , @transmissionID as bigint       = -1
  , @cif            as bit          = 0
  , @path           as varchar(255) = ''
  , @filename       as varchar(100) = ''
  , @claimIDs       as BIGINT_TableType READONLY
) as 

BEGIN

set nocount on

declare @msgStr        as varchar(512) = ''
declare @today         as datetime     = getdate()
declare @todayCCYYMMDD as varchar(8)   = ''
declare @todayYYMMDD   as varchar(6)   = ''
declare @todayHHMM     as varchar(4)   = ''

declare @seg_term   as varchar(1)  = '~'	/* Segment Terminator */
declare @el_sep     as varchar(1)  = '*'	/* Element Seperator */
declare @subel_sep  as varchar(1)  = ':'	/* Subelement Seperator */
declare @rep_sep    as varchar(1)  = '^'	/* Repetition Seperator - see ISA11 */

/* Submitter identifiers and contact information */
	 
declare @cmc_submitter_ID     as char(3)     = '9A7' --9A7 is the Medi-Cal submitter identifier for SBSC
declare	@poc_name             as char(60)    = 'VICTORIA ROHL SPITSYN'
declare @poc_phone            as char(80)    = '9163751707' /* the element before this one MUST be 'TE' (signifying this field is a telephone number); additionally, ACS requires no non-numeric characters for phone numbers */
declare @org_name             as char(33)    = 'SCHOOL BUSINESS SERVICES OF CALI'

declare @group_ctrl_num       as varchar(9)  = LEFT(convert (nvarchar(max), 1234567890),9)
declare @trans_ctrl_num       as varchar(9)  = RIGHT( '0000000000' + RIGHT(convert(nvarchar(max), @transmissionID),9),9) --'SBSC01' --field must be a minimum of 4 characters
declare @interchange_ctrl_num as varchar(9)  = LEFT('2' + convert (nvarchar(max), YEAR(@today)) + RIGHT('0000' + convert(nvarchar(max), @transmissionID), 4),9)

declare @charsToRemove        as varchar(10)  = ''

declare @clientName           as varchar(33)  = ''
declare @clientNPI            as varchar(10)  = ''
declare @clientTaxID          as varchar(10)  = ''
declare @clientAddress1       as varchar(26)  = ''
declare @clientAddress2       as varchar(26)  = ''
declare @clientCity           as varchar(18)  = ''
declare @clientState          as varchar(2)   = ''
declare @clientZip            as varchar(9)   = ''
declare @segsPerSvcRec        as int          = 3
declare @numPats              as int          = 0
declare @numSvcRecs           as int          = 0
declare @numClaims            as int          = 0
declare @segmentCount         as int          = 0
declare @curPatIdx            as int          = 0
declare @maxPatIdx            as int          = 0

declare @header               as varchar(max) = ''
declare @body                 as varchar(max) = ''
declare @footer               as varchar(max) = ''
declare @complete837          as varchar(max) = ''

declare @claims as table (
    patID             bigint
  , svcRecID          bigint
  , claimLineNum      int
  , claimID           bigint
  , pracID            bigint
  , dosCCYYMMDD       varchar(256)
  , procModCombo      varchar(256)
  , numUnitsStr       varchar(256)
  , amountClaimed     money
  , amountClaimedStr  varchar(256)
  , icd10CodeStr      varchar(256)
  , placeOfSvcCodeStr varchar(256)
  , ccn               varchar(256)
  , loop2400          varchar(max)
unique clustered (patID, svcRecID, claimLineNum, claimID)
)

declare @svcs as table (
    patID             bigint
  , svcRecID          bigint
  , pracID            bigint
  , numClaims         int
  , totAmountClaimed  money  
  , loop2300          varchar(max)
  , loop2310B         varchar(max)
unique clustered (patID, svcRecID)
)

declare @pats as table (
    idx         int identity(2,1) /* Start count at 2 */
  , patID       bigint
  , lname       varchar(256)
  , fname       varchar(256)
  , tpaID       varchar(256)  
  , dobCCYYMMDD varchar(8)
  , sex         varchar(1)
  , loop2000B   varchar(max)
  , loop2010BA  varchar(max)
  , loop2010BB  varchar(max)
unique clustered (idx)
)

declare @renderingPracs as table (
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
  | Init
  ---------------------------------------------------------*/

set @msgStr = 'Initializing'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @today         = getdate()
set @charsToRemove = @seg_term + @el_sep + @subel_sep + @rep_sep 

/*---------------------------------------------------------
  | Get current date in CCYYMMDD format
  ---------------------------------------------------------*/

set @todayCCYYMMDD = CONVERT(varchar(4),YEAR(@today)) 
                   + RIGHT('0' + CONVERT(varchar(2),MONTH(@today)),2)
				   + RIGHT('0' + CONVERT(varchar(2),DAY(@today))  ,2) 

/*---------------------------------------------------------
  | Get current date in YYMMDD format
  ---------------------------------------------------------*/

set @todayYYMMDD = RIGHT(CONVERT(varchar(4),YEAR(@today)),2) 
                 + RIGHT('0' + CONVERT(varchar(2),MONTH(@today)),2)
				 + RIGHT('0' + CONVERT(varchar(2),DAY(@today))  ,2) 
			
/*---------------------------------------------------------
  | Get current time in HHMM format
  ---------------------------------------------------------*/

set @todayHHMM =  RIGHT('0' + CONVERT(varchar(2), DATEPART(hour,  @today)),2) 
               +  RIGHT('0' + CONVERT(varchar(2), DATEPART(minute,@today)),2) 

/*---------------------------------------------------------
  | Expected segments per service record
  |
  | 3 for new claims
  | 4 for cif claims
  ---------------------------------------------------------*/

set @segsPerSvcRec = 3
if (@cif = 1) set @segsPerSvcRec = 4

/*---------------------------------------------------------
  | Get client name, npi, and taxid
  ---------------------------------------------------------*/

select top 1 
    @clientName  = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cli.CLIENT_NAME,1,1,1,1,33), @charsToRemove,null)
  , @clientNPI   = cli.NPI
  , @clientTaxID = cli.TAX_ID
from dbo.CLIENTS_Client as cli 
where 
  (cli.CLIENT_ID = @clientID)

/*---------------------------------------------------------
  | Get client address
  ---------------------------------------------------------*/

select top 1 
    @clientAddress1  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla.ADDRESS_1,''),'.',''),26)))),@charsToRemove,null)
  , @clientAddress2  = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(REPLACE(isnull(cla.ADDRESS_2,''),'.',''),26)))),@charsToRemove,null)
  , @clientCity      = dbo.STRING_REMOVE_CHARS((trim(UPPER(LEFT(cla.city, 18)))),@charsToRemove,null)
  , @clientState     = trim(upper(cla.[STATE]))
  , @clientZip       = trim(upper(LEFT(cla.ZIP + isnull(cla.ZIP_PLUS_FOUR,''),9)))
from CLIENTS_Address as cla 
where 
  (cla.CLIENT_ID = @clientID)

/*---------------------------------------------------------
  | Get claims data from claim ids passed in
  | and create some of the element values needed for later
  ---------------------------------------------------------*/

set @msgStr = 'Loading claim data'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

insert into @claims (    
    patID
  , svcRecID
  , claimLineNum 
  , claimID 
  , pracID     
  , dosCCYYMMDD  
  , procModCombo
  , numUnitsStr
  , amountClaimed
  , amountClaimedStr 
  , icd10CodeStr
  , placeOfSvcCodeStr  
  , ccn   
)
select     
    cc.patID    
  , src.svcRecID
  , claimLineNum = cc.claimLineNum  
  , src.claimID  
  , pracID = cc.renderingPracID 

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

from @claimIDs                       as cids
join dbo.CYBHI_CLAIMS                as cc  on cc.id           = cids.id
join dbo.CYBHI_SERVICE_RECORD_CLAIMS as src on src.claimID     = cc.id
join dbo.CLAIM_Procedures            as cp  on cp.PROCEDURE_ID = cc.procedureID

order by 
    cc.patID
  , src.svcRecID
  , cc.claimLineNum
  , src.claimID

/*---------------------------------------------------------
  | Get claim count.  
  | We will use this as part of a segment count checksum.
  ---------------------------------------------------------*/

set @numClaims = 0
select @numClaims = count(clms.claimID) from @claims as clms

/*---------------------------------------------------------
  | From the claims data get rendering prac ids  
  ---------------------------------------------------------*/

insert into @renderingPracs (
  pracID
)
select distinct 
  cc.pracID 
from @claims as cc
order by 
  cc.pracID

/*---------------------------------------------------------
  | Get rendering pracs names and npi #s
  ---------------------------------------------------------*/

set @msgStr = 'Loading practitioner data'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

update rp
set
    rp.lname  = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.LAST_NAME,1,1,1,1,null)),@charsToRemove,null)
  , rp.fname  = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.FIRST_NAME,1,1,1,1,null)),@charsToRemove,null)
  , rp.npi    = trim(isnull(prp.npiNumber,''))
from @renderingPracs               as rp
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = rp.pracID

/*---------------------------------------------------------
  | Replace blank npi numbers with prac id
  | TODO: Remove once testing complete
  ---------------------------------------------------------*/

update @renderingPracs
  set npi = 'PRAC' + convert(varchar(50),pracID)
where 
  (len(npi) = 0)

/*---------------------------------------------------------
  | From the claims data get patient ids 
  ---------------------------------------------------------*/

insert into @pats ( 
    patID  
)
select distinct
  patID = clms.patID 
from @claims as clms
order by 
  clms.patID

/*---------------------------------------------------------
  | Get patient count.  
  | We will use this as part of a segment count checksum.
  ---------------------------------------------------------*/

set @numPats = 0
select @numPats = count(pats.patID) from @pats as pats

/*---------------------------------------------------------
  | Get patient name, insurance, and demographic data
  ---------------------------------------------------------*/

set @msgStr = 'Loading patient data'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

update pats
set 
    pats.lname   = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.LAST_NAME,1,1,1,1,null)),@charsToRemove,null)  
  , pats.fname   = dbo.STRING_REMOVE_CHARS((dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(pap.FIRST_NAME,1,1,1,1,null)),@charsToRemove,null)
  , pats.tpaID   = trim(isnull(pap.cybhiTpaID,''))
  , pats.dobCCYYMMDD = CONVERT(varchar(4),YEAR(pap.DATE_OF_BIRTH)) 
                     + RIGHT('0' + CONVERT(varchar(2),MONTH(pap.DATE_OF_BIRTH)),2)
				     + RIGHT('0' + CONVERT(varchar(2),DAY(pap.DATE_OF_BIRTH))  ,2) 
  , pats.sex         = isnull(pap.SEX,N'')
from @pats                as pats
join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = pats.patID

/*---------------------------------------------------------
  | Replace blank bic numbers with patientID
  | TODO: Remove once testing complete
  ---------------------------------------------------------*/

update @pats
  set tpaID = 'PAT' + convert(varchar(50),patID)
where 
  (len(tpaID) = 0)


/*---------------------------------------------------------
  | From the claim data get service data and totals
  ---------------------------------------------------------*/

insert into @svcs (
    patID
  , svcRecID
  , pracID
  , numClaims
  , totAmountClaimed
)
select
    clms.patID
  , clms.svcRecID
  , clms.pracID
  , numClaims        = count(clms.claimID)
  , totAmountClaimed = sum(clms.amountClaimed) 
from @claims as clms
group by 
    patID
  , svcRecID
  , pracID

 /*---------------------------------------------------------
  | Get service record count.  
  | We will use this as part of a segment count checksum.
  ---------------------------------------------------------*/

set @numSvcRecs = 0
select @numSvcRecs = count(svcs.svcRecID) from @svcs as svcs

/*#########################################################################
  #
  #                     Get expected segment count
  #
  # The count is "a tally of all segments between the ST and the SE 
  # segments including the ST and SE segments." 
  #
  #########################################################################*/

set @segmentCount = 10                               /* 10 header segments (fixed) */
                  + (@numPats     * 5)               /* 5 segments x number of patients */
				  + (@numSvcRecs  * @segsPerSvcRec)  /* 3 or 4 segements x num of svcs recs  */ 				  
				  + (@numClaims   * 3)               /* 3 segements x num of claim recs */ 
				  + 1                   /* 1 footer segment (fixed) */
				  
set @msgStr = 'Expected segment count : ' + convert(varchar(50),@segmentCount)
exec dbo.PRINT_STATUS_MESSAGE @msgStr

/*#########################################################################
  #
  #                            Generate Header
  #
  #########################################################################*/

set @msgStr = 'Generating header'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

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
            + '00'  
			+ @el_sep 
			+ '          ' 
			+ @el_sep 
			+ '00' 
			+ @el_sep 
			+ '          ' 
			+ @el_sep 
			+ 'ZZ' 
			+ @el_sep 
			+ @cmc_submitter_ID 
			+ '            '
			+ @el_sep 
			+ 'ZZ' 
			+ @el_sep 
			+ '610442         '
			+ @el_sep 
			+ @todayYYMMDD
			+ @el_sep 
		    + @todayHHMM
			+ @el_sep 
		    + @rep_sep 
			+ @el_sep 
			+ '00501'  
			+ @el_sep 
            + @interchange_ctrl_num 
			+ @el_sep 
			+ '0' 
			+ @el_sep 
			+ 'T' 
			+ @el_sep 
			+ @subel_sep 	
	        + @seg_term 
            
			/* ########## Functional Group Start Segment ########## */
            
			+ 'GS' 
			+ @el_sep 
            + 'HC' 
			+ @el_sep 
		    + @cmc_submitter_ID 
			+ @el_sep 
	  	    + '610442' 
			+ @el_sep 
			+ @todayCCYYMMDD
			+ @el_sep 
		    + @todayHHMM			
			+ @el_sep 
		    + @group_ctrl_num 
			+ @el_sep 
		    + 'X' 
			+ @el_sep 
	   	    + '005010X222A2'
	        + @seg_term
			
			/* ########## Transaction Set Start Segment ########## */
            
			+ 'ST' 
			+ @el_sep 
            + '837' 
			+ @el_sep 
	        + @trans_ctrl_num 
			+ @el_sep 
	        + '005010X222A2'
	        + @seg_term

			/* ########## Hier Transaction Start Segment  ########## */
            
             + 'BHT' 
			 + @el_sep 
             + '0019' 
			 + @el_sep 
			 + '00'
			 + @el_sep 
			 + LEFT('SBSC01',30) 
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
			+ '2'  
			+ @el_sep /* 2 = Non person entity*/
			+ @org_name 
			+ @el_sep /* Last or Org name */
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
			+ @cmc_submitter_ID 
			+ @seg_term
			
			/*+ 'PER' + @el_sep 
			+ 'IC' + @el_sep 
			+ RTRIM(@poc_name) + @el_sep 
			+ 'TE' + @el_sep 
			+ RTRIM(@poc_phone)
	        + @seg_term 
			*/
            
			/* ########## LOOP 1000B - RECEIVER ########## */

            + 'NM1' 
			+ @el_sep 
			+ '40' 
			+ @el_sep 
			+ '2' 
			+ @el_sep 
			+ 'CARELON BEHAVIORAL HEALTH,INC.' 
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
			+ 'BEACON963116116' 
			+ @seg_term

			/* ########## LOOP 2000A - BILLING PROVIDER ########## */
			
            + 'HL' 
			+ @el_sep 
            + '1' 
			+ @el_sep /* idx 1 is assigned to client */ 
		    + '' 
			+ @el_sep 
		    + '20' 
			+ @el_sep 
		    + '1' 
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
			+ @clientName 
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
			+ @clientNPI /* Need to check if this needs to be the TPA id */
		    + @seg_term 
			
			+ 'N3' 
			+ @el_sep 
			+ @clientAddress1
			+ @el_sep 
			+ @clientAddress2
			+ @seg_term
	        
			+ 'N4' 
			+ @el_sep 
			+ @clientCity
			+ @el_sep 
			+ @clientState
			+ @el_sep
			+ @clientZip
		    + @seg_term 
			
			+ 'REF' 
			+ @el_sep 
			+ 'EI'  
			+ @el_sep 
			+ @clientTaxID 			
		    + @seg_term


/*#########################################################################
  #
  #                            Generate Body
  #
  #########################################################################*/

set @msgStr = 'Generating body'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

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
          + CONVERT(varchar(256),idx) 
		  + @el_sep 
          + '1' /*CONVERT(varchar(MAX), parentHL) */ 
		  + @el_sep 
          + '22' 
		 -- TODO: Check on if this should be included
		 -- + @el_sep 
         -- + '1'  /* 0 = not patient, 1 = is patient*/ 
          + @seg_term      
   	      
		  + 'SBR' 
		  + @el_sep
	      + 'P'        /* 01  */ 
		  + @el_sep
		  + '18'       /* 02  */ 
		  + @el_sep 
		  + ''         /* 03 */ 
		  + @el_sep 
		  + '' 		   /* 04 */ 
		  + @el_sep 
		  + ''         /* 05 */
		  + @el_sep 
		  + ''         /* 06 */
		  + @el_sep 
		  + ''         /* 07 */
		  + @el_sep
		  + 'ZZ'       /* 08 */
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
		     + UPPER(LEFT(pats.tpaID,15))
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
			 + 'CARELON BEHAVIORAL HEALTH,INC.' 
			 + @el_sep
			 + @el_sep 
			 + @el_sep 
			 + @el_sep
			 + @el_sep
			 + 'PI' 
			 + @el_sep
			 + 'BEACON963116116'  
			 + @el_sep
			 + @seg_term

from @pats as pats


/*---------------------------------------------------------
  | Generate loops for service record level data
  |
  | Note: The 837P uses a segment identifier of CLM to 
  | represent what we store in our service record
  |
  | LOOP 2300  - CLAIM INFORMATION
  | LOOP 2310B - RENDERING PROVIDER NAME 
  ---------------------------------------------------------*/

update svcs
set 

/* ########## LOOP 2300 - CLAIM INFORMATION ########## */
	
svcs.loop2300 = 'CLM'
              + @el_sep
	          + convert(varchar(20),svcs.svcRecID)		/* 01 */ 
		      + @el_sep
		      + convert(varchar(256),svcs.totAmountClaimed) /* 02 */
		      + @el_sep
		      + '' /* 03 */
			  + @el_sep 
			  + '' /* 04 */
			  + @el_sep 
			  + clms2.placeOfSvcCodeStr 
			  + @subel_sep
		      + 'B' 
		      + @subel_sep
		      + iif((@cif = 0),'1','8') /* 0 = Freq Original, 8= Delete */
			  + @el_sep
			  + 'Y'                    /* 06 - Provider signature on file */
			  + @el_sep
			  + 'A'                    /* 07 - Provider Accept Assignment Code (TODO: Check on this) */
			  + @el_sep
			  + 'Y'                    /* 08 - Benefits Assigned to Provider */
			  + @el_sep
			  + 'Y'                    /* 09 - Release of info to other orgs authorized by patient */			  
			  + @seg_term	
			  
			  /* Include claim control number segment if this is a CIF */
			  
			  + iif(@cif = 1
			        ,'REF' + @el_sep + 'F8' + @el_sep + clms2.ccn + @seg_term
					,'')	
		      
			  + 'HI'
		      + @el_sep
		      + 'ABK'
		      + @subel_sep		 
		      + clms2.icd10CodeStr
		      + @seg_term

/* ########## LOOP 2310B - RENDERING PROVIDER NAME  ##########*/

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
			     + '' /* 05 */
			     + @el_sep
                 + '' /* 06 */
			     + @el_sep
			     + '' /* 07 */
			     + @el_sep
			     + 'XX' /* 08 */
			     + @el_sep
				 + pracs.npi /* 09*/
                 + @seg_term

from @svcs           as svcs
join @renderingPracs as pracs on pracs.pracID = svcs.pracID
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

/* TODO: What do we do with these loops? */
/* LOOP 2330B – OTHER PAYER NAME INFORMATION */
/* LOOP 2430  - LINE ADJUDICATION INFORMATION */

/*---------------------------------------------------------
  | Build body
  ---------------------------------------------------------*/

select @maxPatIdx = max(pats.idx) from @pats as pats
set @curPatIdx = 2
set @body = ''

declare @maxPatIdxStr as varchar(50) = convert(varchar(50),@maxPatIdx)

while (@curPatIdx <= @maxPatIdx)
begin
  
  set @msgStr = 'Patient ' + convert(varchar(50),@curPatIdx) + ' of ' + @maxPatIdxStr
  exec dbo.PRINT_STATUS_MESSAGE @msgStr

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

  /*---------------------------------------------------------
    | Get service and claim loops
    | There are at least 1 set of these per patient
    ---------------------------------------------------------*/

  select
    
	/* All service record + claim line combos per patient */

    @svcsAndClaimLoops = STRING_AGG(convert(varchar(max),q1.svcAndClaimsLoops),'')
  
  from
  (
    select top 1000  /* Each service record */
        svcAndClaimsLoops = svcs.loop2300 
		                  + svcs.loop2310B 
						  + STRING_AGG(convert(varchar(max),clms2.loop2400),'')
    from @svcs as svcs
   
    cross apply (
      select top 10 /* Claim lines for each service record */
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
	  , svcs.loop2310B
	  , svcs.svcRecID
	order by 
	  svcs.svcRecID
  ) as q1
	  
  set @body = @body 
            + @patLoops
			+ @svcsAndClaimLoops

  set @curPatIdx = @curPatIdx + 1

end


/*#########################################################################
  #
  #                            Generate Footer
  #
  #########################################################################*/

set @msgStr = 'Generating footer'
exec dbo.PRINT_STATUS_MESSAGE @msgStr
                 
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
            + '1'  
			+ @el_sep 
			+ @group_ctrl_num 
		    + @seg_term
            
			/* ########## Interchange End Segment ########## */
			
			+ 'IEA' 
			+ @el_sep 
            + '1' 
			+ @el_sep 
			+ @interchange_ctrl_num
		    + @seg_term
	
/*#########################################################################
  #
  #                 Generate Complete 837P File Content
  #
  #########################################################################*/

set @msgStr = 'Generating complete 837'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @msgStr = 'Upcase everything and combine'
exec dbo.PRINT_STATUS_MESSAGE @msgStr

set @complete837 = upper(@header) 
                 + upper(@body)
				 + upper(@footer)

/*#########################################################################
  #
  #                         Write To File
  #
  #########################################################################*/

exec dbo.writestringtofile @complete837, @Path, @Filename

END
GO
