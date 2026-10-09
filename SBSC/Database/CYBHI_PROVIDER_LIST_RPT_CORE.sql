USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_PROVIDER_LIST_RPT_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_PROVIDER_LIST_RPT_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CYBHI_PROVIDER_LIST_RPT_CORE] ( 
    @clientID           bigint
  , @generateRosterMode bit = 0
)

/***************************************************************************    
 * CYBHI_PROVIDER_LIST_RPT_CORE */    
/**    
 * Returns complete list of providers and if they can be included in
 * the TPA export and (if not) reasons why.
 *
 * The TPA requires a complete list of providers in the SPI roster for every 
 * submission.                                
 *
 * Return Files 
 * -------------
 * For the return file we will match up on NPI
 *
 * Consortium Billing
 * -------------------
 * For the batch registration we will register consortium members under
 * the consortium lead in a single combined file.                                                             
 ***************************************************************************/            

returns @providers table (    
    RowNumber              int          identity(1,1)
  , CanExportRow           bit          default(1)  
  , ProblemsDetected       varchar(max) default('')  
  , ChangeIndicator        varchar(1)   default('F') /* Should always be an F */
  , LocationID			   varchar(4)	default('')		
  , ProviderID             varchar(20)  default('')
  , ProviderTypeID         varchar(1)   default('')
  , FirstName	           varchar(25)  default('')
  , LastName               varchar(25)  default('')
  , PrimaryDegree          varchar(25)  default('')
  , Degree2                varchar(25)  default('')
  , Degree3                varchar(25)  default('')
  , ProvNPI                varchar(10)  default('')
  , ProvSSN                varchar(12)  default('')
  , ProvGender             varchar(1)   default('')
  , ProvDOB                varchar(10)  default('')
  , StateLicense1          varchar(30)  default('')
  , License1State          varchar(2)   default('')
  , License1EffDt          varchar(10)  default('')
  , License1ExpDt          varchar(10)  default('')
  , StateLicense2          varchar(30)  default('')
  , License2State          varchar(2)   default('')
  , License2EffDt          varchar(10)  default('')
  , License2ExpDt          varchar(10)  default('')
  , StateLicense3          varchar(30)  default('')
  , License3State          varchar(2)   default('')
  , License3EffDt          varchar(10)  default('')
  , License3ExpDt          varchar(10)  default('')
  , ProviderEffDt          varchar(10)  default('')
  , ProviderExpDt          varchar(10)  default('')
  , MailAddr1              varchar(55)  default('')
  , MailCity               varchar(30)  default('')
  , MailState              varchar(2)   default('')
  , MailZip                varchar(5)   default('')
  , MailPhone              varchar(10)  default('')
  , ProviderEmail		   varchar(60)	default('admin@healthekids.com')	 /* Should always be admin@healthekids.com */
  , ProviderTaxID          varchar(9)   default('')
  , TaxIDType              varchar(1)   default('F')
  , GroupName              varchar(100) default('')
  , GroupNPI               varchar(10)  default('')
  , BillName               varchar(100) default('')
  , BillAddr1              varchar(55)  default('')
  , BillCity               varchar(30)  default('')
  , BillState              varchar(2)   default('')
  , BillZip                varchar(5)   default('')
  , BillPhone              varchar(10)  default('')
  , PrimaryLocFlg          varchar(1)   default('N') /* Only one allowed for provider*/
  , HandicapFlg            varchar(1)   default('U') /* Value is unknown */ 
  , ServAddrEffDt          varchar(10)  default('')
  , ServAddrExpDt          varchar(10)  default('')
  , ServName               varchar(100) default('')
  , ServAddr1              varchar(55)  default('')
  , ServCity               varchar(30)  default('')
  , ServState              varchar(2)   default('')
  , ServZip                varchar(5)   default('')
  , ServPhone              varchar(10)  default('')
  , LowAge                 varchar(2)   default('0')
  , HighAge                varchar(2)   default('25')
  , FacilityName           varchar(100) default('')
  , FacilityProviderType   varchar(50)  default('')
  , Plan01                 varchar(1)   default('Y')
  , ProviderSpecialty1     varchar(100) default('')
  , ProviderSpecialty2     varchar(100) default('')
  , ProviderSpecialty3     varchar(100) default('')
  , ProviderSpecialty4     varchar(100) default('')
  , includeStateLicCells   bit          default(1)
  unique clustered (RowNumber)
)
as
begin

/*###########################################################################*/
/*#                    Exit if client not passed                            #*/
/*###########################################################################*/

if (@clientID is null) return

/*###########################################################################*/
/*#                             Init                                        #*/
/*###########################################################################*/

declare @todayDateOnly           as datetime     = convert(date,getdate())
declare @charsToRemove           as varchar(10)  = '~*:^' 
declare @minEffDateVal           as date         = convert(date,'7/1/2024')
declare @maxEffDateVal           as date         = convert(date,'12/31/9999')
--declare @minEffDateStr      as varchar(10)  = convert(varchar(10),(dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE(@minEffDateVal))) /* '07/01/2024' Leading 0s required */
--declare @maxEffDateStr      as varchar(10)  = convert(varchar(10),(dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE(@maxEffDateVal))) /* '12/31/9999' Leading 0s required */
declare @minEffDateStr           as varchar(10)  = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(@minEffDateVal) /* '07/01/2024' Leading 0s required */
declare @maxEffDateStr           as varchar(10)  = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(@maxEffDateVal) /* '12/31/9999' Leading 0s required */
declare @dlftMailState           as varchar(2)   = 'CA'
declare @provTypeGroup           as varchar(1)   = 'G'
declare @provTypeLicOrCred       as varchar(1)   = 'I'
declare @provTypePara            as varchar(1)   = 'P'
declare @clientFound             as bit          = 0
declare @clientNameStr           as varchar(100) = ''
declare @clientNPIStr            as varchar(10)  = ''
declare @clientTaxIDStr          as varchar(9)   = ''
declare @clientAddressStr        as varchar(55)  = ''
declare @clientCityStr           as varchar(30)  = ''
declare @clientStateStr          as varchar(2)   = ''
declare @clientZipStr            as varchar(5)   = ''
declare @clientPhoneStr          as varchar(10)  = ''
declare @noClientClaimStartVal   as bit         = 1
declare @clientClaimStartDateVal as date        = convert(date,'7/1/2024')
declare @consortium              as bit         = 0
declare @consortiumLeadClientID  as bigint      = null
declare @consortiumLead          as bit         = 0

declare @clientsParticipating as table (    
    clientID          bigint                   not null default -1
  , billingClient     bit                      not null default(0)
  , clientNameStr     varchar(100)             not null default('')
  , clientAddressStr  varchar(55)              not null default('')
  , clientCityStr     varchar(30)              not null default('')
  , clientStateStr    varchar(2)               not null default('')
  , clientZipStr      varchar(5)               not null default('')
  , clientPhoneStr    varchar(10)              not null default('')
)

declare @pracQualifications as table (
    pracID                bigint
  , dispGroupID           bigint
  , hasQualificationsData bit
  , primaryQualification  bit
  , licenseNum            varchar(512)
  , startDate             date
  , endDate               date
  , isLifetime            bit
  , expiresInDays         int
  , idx                   int identity(1,1)
  unique clustered (pracID, idx)
)

declare @pracs as table (
    pracID                     bigint  
  , clientID                   bigint
  , dispGroupID                bigint  
  , firstNameStr               varchar(25)  default('')
  , lastNameStr                varchar(25)  default('')
  , primaryDegreeCodeStr       varchar(25)  default('')
  , primaryDegreeCodeStr2      varchar(25)  default('')
  , primaryDegreeCodeStr3      varchar(25)  default('')
  , providerSpecialtyCodeStr1  varchar(100) default('')
  , providerSpecialtyCodeStr2  varchar(100) default('')
  , providerSpecialtyCodeStr3  varchar(100) default('')
  , providerSpecialtyCodeStr4  varchar(100) default('')
  , npiStr                     varchar(10)  default('')
  , ssnStr                     varchar(12)  default('')
  , genderStr                  varchar(1)   default('')
  , dobStr                     varchar(10)  default('')
  , mailAddr1Str               varchar(55)  default('')
  , mailCityStr                varchar(30)  default('')
  , mailStateStr               varchar(2)   default('')
  , mailZipStr                 varchar(5)   default('')
  , mailPhoneStr               varchar(10)  default('') 
  , providerEmailStr           varchar(60)  default('')
  , stateLicenseNumStr1        varchar(30)  default('')
  , stateLicenseIssueStateStr1 varchar(2)   default('')
  , stateLicenseEffDateStr1    varchar(10)  default('')
  , stateLicenseExpDateStr1    varchar(10)  default('')
  , stateLicenseNumStr2        varchar(30)  default('')
  , stateLicenseIssueStateStr2 varchar(2)   default('')
  , stateLicenseEffDateStr2    varchar(10)  default('')
  , stateLicenseExpDateStr2    varchar(10)  default('')
  , stateLicenseNumStr3        varchar(30)  default('')
  , stateLicenseIssueStateStr3 varchar(2)   default('')
  , stateLicenseEffDateStr3    varchar(10)  default('')
  , stateLicenseExpDateStr3    varchar(10)  default('')
  , cybhiProviderTypeID        varchar(1)   default('')
  , cybhiExportGroupName       varchar(100) default('')
  , cybhiExportGroupNPI        varchar(10)  default('')
  , locationID				   varchar(4)	default('')
  , stateLicenseExpInDays      int          
  , requiresSupervision        bit          default(0)
  , supervisedByPracID         bigint
  , includeLicData             bit          default(1)        
  , canExportRow               bit          default(1)  
  , problemsDetected           varchar(max) default('')  

unique clustered (pracID)
)

declare @sites as table (
    idx              int not null identity(1,1)
  , clientID         bigint
  , siteNameStr      varchar(100) default('')
  , siteAddressStr   varchar(55)  default('')
  , siteCityStr      varchar(30)  default('')
  , siteStateStr     varchar(2)   default('')
  , siteZip5Str      varchar(5)   default('')
  , sitePhoneStr     varchar(10)  default('')
  , PrimaryLocFlg    varchar(1)   default('N')  
unique clustered (idx)
)

/*###########################################################################*/
/*#                         Get client data                                 #*/
/*###########################################################################*/

set @consortium             = 0
set @consortiumLead         = 0
set @consortiumLeadClientID = null

select top 1
    @clientFound             = 1
  , @consortium              = isnull(clc.cybhiConsortiumBilling,0)
  , @consortiumLeadClientID  = isnull(clc.cybhiConsortiumLeadClientID,0)  
from dbo.CLIENTS_Client as clc 
where (
      (clc.CLIENT_ID = @clientID)
  and (clc.cybhi     = 1)
)

/*###########################################################################*/
/*#                   If Client Not Found - Exit                            #*/
/*###########################################################################*/

if (@clientFound = 0) return

/*###########################################################################*/
/*#                      Get Participating Clients                          #*/
/*###########################################################################*/

/*------------------------------------*/
/* Client is part of consortium       */
/*------------------------------------*/

if (@consortium = 1)
begin

  /*------------------------------------*/
  /* Client is the lead client          */
  /*------------------------------------*/

  if (@consortiumLeadClientID = 0) 
  begin  
    
	/*------------------------------------*/
    /* If we are generating the roster    */
	/* include all consortium members     */
    /*------------------------------------*/
	
	if (@generateRosterMode = 1)
	begin
	  insert into @clientsParticipating (clientID, billingClient)
	  select 
	      clientID      = t1.id 
	    , billingClient = t1.leadClient
	  from dbo.CYBHI_CONSORTIUM_MEMBERS_VIEW_CORE(null,null,null,@clientID) as t1
    end

	/*------------------------------------*/
    /* If we are not generating the roster*/
	/* include just the lead              */
    /*------------------------------------*/

	else
	begin
	  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
	end

  end

  /*------------------------------------*/
  /* Client is not the lead             */
  /*------------------------------------*/

  else
  begin

    /*------------------------------------*/
    /* If we are generating the roster    */
	/* exit.  Client is submitted under   */
	/* the lead.                          */
    /*------------------------------------*/

    if (@generateRosterMode = 1)
	begin
	  return
	end
	else

	/*------------------------------------*/
    /* If we are not generating the roster*/
	/* include just this client.          */
    /*------------------------------------*/

	begin
  	  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)	  
    end
  end
end

/*------------------------------------*/
/* Client is not part of consortium   */
/* include just this client */
/*------------------------------------*/

else
begin  
  insert into @clientsParticipating (clientID, billingClient) values (@clientID,1)
end

/*###########################################################################*/
/*#                     Get billing client data                             #*/
/*###########################################################################*/

select top 1
    @clientNameStr           = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiClientName,1,1,1,1,100)
  , @clientNPIStr            = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiNPI,0,1,0,0,10)
  , @clientTaxIDStr          = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiTaxID,0,1,0,0,9)
  , @clientClaimStartDateVal = clc.cybhiTpaApprovedOn
from dbo.CLIENTS_Client as clc
where 
  (clc.CLIENT_ID = @clientID)

/*------------------------------------*/
/* If no claiming start value found   */
/* flag as error                      */
/*------------------------------------*/

set @noClientClaimStartVal = 0

if (@clientClaimStartDateVal is null)
begin
  set @noClientClaimStartVal = 1
end

/*------------------------------------*/
/* If claiming start value found      */
/*------------------------------------*/

else
begin

  /*------------------------------------*/
  /* And its before the min start date  */
  /*------------------------------------*/

  if (@clientClaimStartDateVal < @minEffDateVal)
  begin

    /*------------------------------------*/
    /* Then treat as a bad date           */
    /*------------------------------------*/

    set @noClientClaimStartVal = 1

  end

  /*------------------------------------*/
  /* Otherwise this becomes our min     */
  /*------------------------------------*/

  else
  begin    
--    set @minEffDateStr = convert(varchar(10),(dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE(@clientClaimStartDateVal))) /* '07/01/2024' Leading 0s required */
	set @minEffDateStr = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(@clientClaimStartDateVal) /* '07/01/2024' Leading 0s required */

  end
end

/*------------------------------------*/
/* Mailing address                    */
/*------------------------------------*/

select top 1
    @clientAddressStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(ca.cybhiAddress1,1,1,1,0,55),@charsToRemove,null)
  , @clientCityStr    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(ca.cybhiCity,1,1,1,0,30),@charsToRemove,null)
  , @clientStateStr   = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(ca.cybhiState,0,0,1,0,2),@charsToRemove,null)
  , @clientZipStr     = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(ca.cybhiZip5,0,1,0,0,5),@charsToRemove,null)
from dbo.CLIENTS_Client as ca 
where 
  (ca.CLIENT_ID = @clientID)
  
/*------------------------------------*/
/* "Mailing" Phone                    */
/*------------------------------------*/

/* -------- First check if there is a dedicated CYBHI phone  -------- */

select top 1 
  @clientPhoneStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cc.phone,0,1,0,0,10),@charsToRemove,null)
from dbo.CLIENTS_Contacts as cc
where ( 
      (cc.clientID      = @clientID)
  and (cc.contactRoleID = 14) /* CYBHI coordinator */
  and (cc.active        = 1)
)

/* -------- If not then fallback to generic number  -------- */

if (@clientPhoneStr = '')
begin
  select 
    @clientPhoneStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cc.PHONE,0,1,0,0,10),@charsToRemove,null)
  from dbo.CLIENTS_Contact as cc
  where 
    (cc.CLIENT_ID = @clientID)
end

/*###########################################################################*/
/*#                     Get participating client data                       #*/
/*###########################################################################*/

/*------------------------------------*/
/* Mailing address                    */
/*------------------------------------*/

update cp
set
    cp.clientNameStr    = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiClientName,1,1,1,1,100)
  , cp.clientAddressStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiAddress1,1,1,1,0,55),@charsToRemove,null)
  , cp.clientCityStr    = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiCity,1,1,1,0,30),@charsToRemove,null)
  , cp.clientStateStr   = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiState,0,0,1,0,2),@charsToRemove,null)
  , cp.clientZipStr     = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(clc.cybhiZip5,0,1,0,0,5),@charsToRemove,null)
from @clientsParticipating as cp
join dbo.CLIENTS_Client    as clc  on clc.CLIENT_ID = cp.clientID
  
/*------------------------------------*/
/* "Mailing" Phone                    */
/*------------------------------------*/

/* -------- First check if there is a dedicated CYBHI phone  -------- */

update cp
set
  clientPhoneStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cc.phone,0,1,0,0,10),@charsToRemove,null)
from @clientsParticipating as cp
join dbo.CLIENTS_Contacts  as cc on cc.clientID = cp.clientID
where ( 
      (cc.contactRoleID = 14) /* CYBHI coordinator */
  and (cc.active        = 1)
)

/* -------- If not then fallback to generic number  -------- */

update cp
set
  cp.clientPhoneStr = dbo.STRING_REMOVE_CHARS(dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(cc.PHONE,0,1,0,0,10),@charsToRemove,null)
from @clientsParticipating as cp
join dbo.CLIENTS_Contact   as cc on cc.CLIENT_ID = cp.clientID
where 
  (cp.clientPhoneStr = '')

/*###########################################################################*/
/*#                      Get practitioner data                              #*/
/*###########################################################################*/

/*------------------------------------*/
/* Practitioner ids for everyone      */
/* participating in CYBHI under this  */
/* client.                            */
/*------------------------------------*/

insert into @pracs (pracID, clientID, dispGroupID, cybhiExportGroupName, cybhiExportGroupNPI)
select 
    pracID               = prp.PRACTITIONER_ID 
  , clientID             = cp.clientID
  , dispGroupID          = ggd.GROUP_ID
  , cybhiExportGroupName = @clientNameStr
  , cybhiExportGroupNPI  = @clientNPIStr  
from @clientsParticipating         as cp
join dbo.PRACTITIONER_CLIENT       as prc on prc.CLIENT_ID = cp.clientID
join dbo.PRACTITIONER_Practitioner as prp on (prp.PRACTITIONER_ID = prc.PRACTITIONER_ID)
join dbo.PRACTITIONER_GROUPS       as pgd on (((pgd.PRACTITIONER_ID = prp.PRACTITIONER_ID) and (pgd.GROUP_TYPE in (1,2)) and (pgd.GROUP_ID > 0) and (pgd.PRACTITIONER_GROUP > 0)) and (pgd.ACTIVE = 1))
join dbo.GROUP_GROUP               as ggd on ((ggd.GROUP_ID = pgd.GROUP_ID) and (ggd.ACTIVE = 1))
where (
  (prp.participatesInCYBHI = 1)
)

/*------------------------------------*/
/* Assign provider specific flags     */
/* based on dispGroup                 */
/*------------------------------------*/

/* Note: Keep this in synch with CYBHI_CLAIMS_ASSIGN_ORP_SUPERVISING_RENDERING_PRACS */

update pracs
set 
    pracs.cybhiProviderTypeID = pg.SPI_ROSTER_PROVIDER_TYPE_ID
  , pracs.requiresSupervision = pg.REQUIRES_SUPERVISION
  , pracs.includeLicData      = pg.SPI_ROSTER_INCLUDE_LIC_DATA
from @pracs as pracs
join dbo.CYBHI_TRANSMISSION_GENERATION_VIEW_LICENSED_PRAC_GROUPS() as pg on pg.GROUP_ID = pracs.dispGroupID

update pracs
set 
    pracs.cybhiProviderTypeID = pg.SPI_ROSTER_PROVIDER_TYPE_ID
  , pracs.requiresSupervision = pg.REQUIRES_SUPERVISION
  , pracs.includeLicData      = pg.SPI_ROSTER_INCLUDE_LIC_DATA
from @pracs as pracs
join CYBHI_VIEW_CREDENTIALED_PRAC_GROUPS() as pg on pg.GROUP_ID = pracs.dispGroupID

update pracs
set 
    pracs.cybhiProviderTypeID = pg.SPI_ROSTER_PROVIDER_TYPE_ID
  , pracs.requiresSupervision = pg.REQUIRES_SUPERVISION
  , pracs.includeLicData      = pg.SPI_ROSTER_INCLUDE_LIC_DATA
from @pracs as pracs
join CYBHI_VIEW_ASSOCIATE_PRAC_GROUPS() as pg on pg.GROUP_ID = pracs.dispGroupID

update pracs
set 
    pracs.cybhiProviderTypeID = pg.SPI_ROSTER_PROVIDER_TYPE_ID
  , pracs.requiresSupervision = pg.REQUIRES_SUPERVISION
  , pracs.includeLicData      = pg.SPI_ROSTER_INCLUDE_LIC_DATA
from @pracs as pracs
join CYBHI_VIEW_PARA_PROF_PRAC_GROUPS() as pg on pg.GROUP_ID = pracs.dispGroupID

/*------------------------------------*/
/* Name, NPI, Address, Employment     */
/* and Education Data                 */
/*------------------------------------*/

update pracs
set    
    firstNameStr  = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.FIRST_NAME,1,1,1,1,25)
  , lastNameStr   = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.LAST_NAME,1,1,1,1,25)
  , npiStr        = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.npiNumber,0,1,0,0,10)
--  , dobStr        = convert(varchar(10),(dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE(prp.dob))) /*dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(prp.dob)*/
  , dobStr        = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(prp.dob)
  , ssnStr        = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.ssn,0,1,0,0,9)
  , genderStr     = prp.gender
  , mailAddr1Str  = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.street1,1,1,1,0,55)
  , mailCityStr   = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.city,1,1,1,0,30)
  , mailStateStr  = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.usState,0,0,1,0,2)
  , mailZipStr    = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.zip5,0,1,0,0,5)
  , mailPhoneStr  = dbo.STRING_REMOVE_NON_ALPHA_NUMERIC(prp.PHONE_NUMBER,0,1,0,0,10)
  , providerEmailStr          = convert(varchar(60),trim(isnull(prp.email,N'')))
  , primaryDegreeCodeStr      = trim(isnull(prp.cybhiDegreeCode,''))
  , primaryDegreeCodeStr2     = trim(isnull(prp.cybhiDegreeCode2,''))
  , primaryDegreeCodeStr3	  = trim(isnull(prp.cybhiDegreeCode3,''))  
  , providerSpecialtyCodeStr1 = trim(isnull(prp.cybhiSpecialtyCode,''))
  , providerSpecialtyCodeStr2 = trim(isnull(prp.cybhiSpecialtyCode2,''))
  , providerSpecialtyCodeStr3 = trim(isnull(prp.cybhiSpecialtyCode3,''))
  , providerSpecialtyCodeStr4 = trim(isnull(prp.cybhiSpecialtyCode4,''))
  , locationID = case 
      when prp.employeeRelationshipID = 10 then 'E'    /* */
      when prp.employeeRelationshipID = 20 then 'CP'   /* Contracted */
      when prp.employeeRelationshipID = 30 then 'ANCP' /* Note not expected at all */
      else '' 
    end
from @pracs                        as pracs
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = pracs.pracID

/*------------------------------------*/
/* Get current qualifications data    */
/*                                    */
/* TODO: Refactor eventually to       */
/* support more than primary qual     */
/*------------------------------------*/

insert into @pracQualifications (
    pracID               
  , dispGroupID          
  , hasQualificationsData
  , primaryQualification
  , licenseNum
  , startDate
  , endDate  
  , isLifetime 
  , expiresInDays
)
select 
    pracs.pracID               
  , t2.dispGroupID          
  , t2.hasQualificationsData
  , t2.primaryQualification
  , t2.licenseNum
  , t2.startDate
  , t2.endDate  
  , t2.isLifetime 
  , t2.expiresInDays
from @pracs as pracs

cross apply (

  select top 1
      t1.pracID
    , t1.dispGroupID
    , t1.hasQualificationsData
    , t1.primaryQualification
    , t1.licenseNum
    , t1.startDate
    , t1.endDate
    , t1.isLifetime
    , t1.expiresInDays

  from dbo.Practitioner_Qualifications_View_Core (@clientID,pracs.pracID,null,null,null) as t1  
  
  where 
    ((t1.primaryQualification = 1) and (t1.ranking = 1))

) as t2

/*------------------------------------*/
/* Get current license                */
/*------------------------------------*/

update pracs
set 
    pracs.stateLicenseNumStr1        = t2.stateLicenseNumStr
  , pracs.stateLicenseIssueStateStr1 = t2.issueStateStr
  , pracs.stateLicenseEffDateStr1    = t2.effDateStr
  , pracs.stateLicenseExpDateStr1    = t2.expDateStr
  , pracs.stateLicenseExpInDays      = t2.expiresInDays

from @pracs as pracs

cross apply (

  select top 1 
        stateLicenseNumStr = left(trim(t1.licenseNum),30) /* No limits on chars that can be used */
      , issueStateStr      = @dlftMailState
	  --, effDateStr         = convert(varchar(10),(dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE(t1.startDate))) /*dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.startDate)*/
      --, expDateStr         = convert(varchar(10),(dbo.CALC_EXCEL_DATE_SERIAL_NUMBER_FROM_DATE(t1.endDate)))  /*dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.endDate)*/
	  , effDateStr         = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.startDate)
      , expDateStr         = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.endDate)

	  , t1.expiresInDays
  from @pracQualifications as t1

  where (
         (t1.pracID = pracs.pracID)
     and (t1.hasQualificationsData = 1)

	--and (t1.primaryQualification = 1)
  --  and (t1.expiresInDays > 0)
	--and (t1.expiresInDays is not null)
	--and (t1.startDate  is not null)
	--and (t1.licenseNum != '')
  )

  order by 
    t1.expiresInDays desc

) as t2

/*------------------------------------*/
/* Get additional licenses            */
/*                                    */
/* TODO: Refactor eventually to use   */
/* qualification table var            */
/*------------------------------------*/

update pracs
set
    pracs.stateLicenseNumStr2        = isnull(addLic.stateLicenseNumStr2, '')
  , pracs.stateLicenseIssueStateStr2 = isnull(addLic.issueStateStr2, '')
  , pracs.stateLicenseEffDateStr2    = isnull(addLic.effDateStr2, '')
  , pracs.stateLicenseExpDateStr2    = isnull(addLic.expDateStr2, '')

  , pracs.stateLicenseNumStr3        = isnull(addLic.stateLicenseNumStr3, '')
  , pracs.stateLicenseIssueStateStr3 = isnull(addLic.issueStateStr3, '')
  , pracs.stateLicenseEffDateStr3    = isnull(addLic.effDateStr3, '')
  , pracs.stateLicenseExpDateStr3    = isnull(addLic.expDateStr3, '')

from @pracs as pracs

cross apply (

  select
      stateLicenseNumStr2 = max(case when q.additionalSlot = 1 then q.stateLicenseNumStr end)
    , issueStateStr2      = max(case when q.additionalSlot = 1 then q.issueStateStr end)
    , effDateStr2         = max(case when q.additionalSlot = 1 then q.effDateStr end)
    , expDateStr2         = max(case when q.additionalSlot = 1 then q.expDateStr end)

    , stateLicenseNumStr3 = max(case when q.additionalSlot = 2 then q.stateLicenseNumStr end)
    , issueStateStr3      = max(case when q.additionalSlot = 2 then q.issueStateStr end)
    , effDateStr3         = max(case when q.additionalSlot = 2 then q.effDateStr end)
    , expDateStr3         = max(case when q.additionalSlot = 2 then q.expDateStr end)

  from (

    select
        stateLicenseNumStr = left(trim(t1.licenseNum),30)
      , issueStateStr      = @dlftMailState
      , effDateStr         = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.startDate)
      , expDateStr         = dbo.RPT_DATE_FMT_WITH_LEADING_ZEROS(t1.endDate)
      , additionalSlot     = row_number() over (
                                order by 
                                    t1.ranking asc
                                  , t1.expiresInDays desc
                              )

    from dbo.Practitioner_Qualifications_View_Core (@clientID,pracs.pracID,null,null,null) as t1

    where (
          (t1.hasQualificationsData = 1)
      and (trim(isnull(t1.licenseNum,'')) <> '')

      /* Do not duplicate License1 */
      and not (
              (t1.primaryQualification = 1)
          and (t1.ranking = 1)
      )

      /* Additional licenses should be valid */
      and (t1.expiresInDays > 7)
    )

  ) as q

  where 
    q.additionalSlot <= 2

) as addLic

/*------------------------------------*/
/* Pre reject pracs that dont have    */
/* qualification data */
/*------------------------------------*/

update p
set 
    p.canExportRow = 0
  , p.problemsDetected = ' * Missing qualifications data'
from @pracQualifications as q
join @pracs              as p on p.pracID = q.pracID
where (
      (q.hasQualificationsData = 0)
  and (p.stateLicenseExpInDays is null)
  and (p.canExportRow = 1)
  and (p.includeLicData = 1)
)

/*------------------------------------*/
/* Pre reject pracs that dont have    */
/* primary qualification data         */
/*------------------------------------*/

update p
set 
    p.canExportRow = 0
  , p.problemsDetected = ' * Missing primary qualifications'
from @pracs as p
where (
    (p.stateLicenseExpInDays is null)
and (p.canExportRow = 1)
and (p.includeLicData = 1)
)

/*------------------------------------*/
/* Pre reject pracs that have expired */
/* qualification data                 */
/*------------------------------------*/

update p
set 
    p.canExportRow = 0
  , p.problemsDetected = ' * Expired qualifications'
from @pracs as p
where (
      (p.stateLicenseExpInDays <= 0)
  and (p.canExportRow   = 1)
  and (p.includeLicData = 1)
)

/*------------------------------------*/
/* Pre reject pracs that have         */
/* expiring qualification data        */
/*------------------------------------*/

update p
set 
    p.canExportRow = 0
  , p.problemsDetected = ' * Qualifications expiring in 7 days or less'
from @pracs as p
where ( 
      (p.stateLicenseExpInDays between 1 and 7)
  and (p.canExportRow   = 1)
  and (p.includeLicData = 1)
)

/*###########################################################################*/
/*#                         Get Primary Sites      `                        #*/
/*###########################################################################*/

insert into @sites (
    siteNameStr   
  , siteAddressStr
  , siteCityStr  
  , siteStateStr 
  , siteZip5Str   
  , sitePhoneStr 
  , PrimaryLocFlg
)
select 
    siteNameStr    = cp.clientNameStr
  , siteAddressStr = cp.clientAddressStr
  , siteCityStr    = cp.clientCityStr
  , siteStateStr   = cp.clientStateStr
  , siteZip5Str    = cp.clientZipStr
  , sitePhoneStr   = cp.clientPhoneStr
  , PrimaryLocFlg  = iif((cp.billingClient = 1),'Y','N')
from @clientsParticipating as cp


/*###########################################################################*/
/*#                        Get Secondary Sites                              #*/
/*###########################################################################*/

insert into @sites (
    siteNameStr   
  , siteAddressStr
  , siteCityStr  
  , siteStateStr 
  , siteZip5Str   
  , sitePhoneStr
  , PrimaryLocFlg  
)
select 
    ss2.siteNameStr    
  , ss2.siteAddressStr 
  , ss2.siteCityStr    
  , ss2.siteStateStr   
  , ss2.siteZip5Str     
  , ss2.sitePhoneStr   
  , PrimaryLocFlag = 'N'      
from @clientsParticipating as cp
cross apply (
  select 
    ss1.* 
  from dbo.CYBHI_SITES_VIEW_DATA_CORE (cp.clientID) as ss1
  where 
    (ss1.internalSite = 0) 
) as ss2

/*###########################################################################*/
/*#                          Create export rows                             #*/
/*###########################################################################*/

/*------------------------------------*/
/* G Rows for Client                  */
/* One G row per site                 */
/* (primary and secondary sites)      */
/*------------------------------------*/

insert into @providers (
    LocationID
  , ProviderID
  , ProviderTypeID
  , ProvNPI
  , License1State
  , ProviderEffDt
  , ProviderExpDt
  , MailAddr1 
  , MailCity
  , MailState
  , MailZip 
  , MailPhone
  , ProviderTaxID
  , GroupName 
  , GroupNPI 
  , PrimaryLocFlg 
  , HandicapFlg  
  , ServAddrEffDt 
  , ServAddrExpDt
  , ServName 
  , ServAddr1 
  , ServCity 
  , ServState
  , ServZip 
  , ServPhone
  , FacilityName 
  , CanExportRow
  , ProblemsDetected
)
select
    LocationID         = 'E'
  , ProviderID         = sites.providerID   
  , ProviderTypeID     = @provTypeGroup
  , ProviderNPI        = @clientNPIStr
  , License1State      = ''
  , ProviderEffDt      = @minEffDateStr
  , ProviderExpDt      = @maxEffDateStr
  , MailAddr1          = @clientAddressStr
  , MailCity           = @clientCityStr
  , MailState          = @clientStateStr
  , MailZip            = @clientZipStr
  , MailPhone          = @clientPhoneStr  
  , ProviderTaxID      = @clientTaxIDStr
  , GroupName          = @clientNameStr
  , GroupNPI           = @clientNPIStr
  , PrimaryLocFlg      = sites.PrimaryLocFlg
  , HandicapFlg        = 'U' 
  , ServAddrEffDt      = @minEffDateStr
  , ServAddrExpDt      = @maxEffDateStr
  , ServName           = sites.siteNameStr
  , ServAddr1          = sites.siteAddressStr
  , ServCity           = sites.siteCityStr
  , ServState          = sites.siteStateStr
  , ServZip            = sites.siteZip5Str
  , ServPhone          = sites.sitePhoneStr
  , FacilityName       = ''
  , CanExportRow     = iif(@noClientClaimStartVal = 1,0,1)
  , ProblemsDetected = iif(@noClientClaimStartVal = 0,'',' * Client CYBHI TPA approved on date is invalid.  It needs to either be on or after 7/1/2024.')     
  
  from (
    select top 9999999
      providerID = @clientNPIStr
    , t1.* 
   from @sites as t1
   order by 
      t1.idx asc
  ) as sites

/*------------------------------------*/
/* I or P Rows for Practitioners      */
/* One I or P row per prac + site     */
/* (primary and secondary sites)      */
/*------------------------------------*/
 
insert into @providers (
	LocationID
  , ProviderID
  , ProviderTypeID
  , FirstName
  , LastName
  , PrimaryDegree
  , Degree2
  , Degree3
  , ProvNPI 
  , ProvSSN 
  , ProvGender
  , ProvDOB   
  , StateLicense1
  , License1State
  , License1EffDt
  , License1ExpDt
  , StateLicense2
  , License2State
  , License2EffDt
  , License2ExpDt
  , StateLicense3
  , License3State
  , License3EffDt
  , License3ExpDt
  , ProviderEffDt
  , ProviderExpDt
  , MailAddr1 
  , MailCity
  , MailState
  , MailZip 
  , MailPhone
  --, ProviderEmail
  , ProviderTaxID
  , GroupName 
  , GroupNPI 
  , PrimaryLocFlg 
  , HandicapFlg  
  , ServAddrEffDt 
  , ServAddrExpDt
  , ServName 
  , ServAddr1 
  , ServCity 
  , ServState
  , ServZip 
  , ServPhone
  , FacilityName 
  , ProviderSpecialty1
  , ProviderSpecialty2
  , ProviderSpecialty3
  , ProviderSpecialty4
  , CanExportRow
  , ProblemsDetected
  , includeStateLicCells
)

select
	LocationID		   = pracs.locationID
  , ProviderID         = sites.providerID
  , ProviderTypeID     = pracs.cybhiProviderTypeID
  , FirstName          = pracs.firstNameStr
  , LastName           = pracs.lastNameStr
  , PrimaryDegree      = pracs.primaryDegreeCodeStr
  , Degree2            = pracs.primaryDegreeCodeStr2
  , Degree3            = pracs.primaryDegreeCodeStr3
  , ProvNPI            = pracs.npiStr
  , ProvSSN            = pracs.ssnStr
  , ProvGender         = pracs.genderStr
  , ProvDOB            = pracs.dobStr
  , StateLicense1      = iif ( (pracs.includeLicData=1), pracs.stateLicenseNumStr1,        '')
  , License1State      = iif ( (pracs.includeLicData=1), pracs.stateLicenseIssueStateStr1, '')
  , License1EffDt      = iif ( (pracs.includeLicData=1), pracs.stateLicenseEffDateStr1,    '')
  , License1ExpDt      = iif ( (pracs.includeLicData=1), pracs.stateLicenseExpDateStr1,    '')
  , StateLicense2      = iif ( (pracs.includeLicData=1), pracs.stateLicenseNumStr2,        '')
  , License2State      = iif ( (pracs.includeLicData=1), pracs.stateLicenseIssueStateStr2, '')
  , License2EffDt      = iif ( (pracs.includeLicData=1), pracs.stateLicenseEffDateStr2,    '')
  , License2ExpDt      = iif ( (pracs.includeLicData=1), pracs.stateLicenseExpDateStr2,    '')
  , StateLicense3      = iif ( (pracs.includeLicData=1), pracs.stateLicenseNumStr3,        '')
  , License3State      = iif ( (pracs.includeLicData=1), pracs.stateLicenseIssueStateStr3, '')
  , License3EffDt      = iif ( (pracs.includeLicData=1), pracs.stateLicenseEffDateStr3,    '')
  , License3ExpDt      = iif ( (pracs.includeLicData=1), pracs.stateLicenseExpDateStr3,    '')
  , ProviderEffDt      = @minEffDateStr
  , ProviderExpDt      = @maxEffDateStr
  , MailAddr1          = pracs.mailAddr1Str
  , MailCity           = pracs.mailCityStr
  , MailState          = pracs.mailStateStr
  , MailZip            = pracs.mailZipStr  
  , MailPhone          = pracs.mailPhoneStr
  --, ProviderEmail	   = pracs.providerEmailStr	
  , ProviderTaxID      = @clientTaxIDStr
  , GroupName          = pracs.cybhiExportGroupName
  , GroupNPI           = pracs.cybhiExportGroupNPI
  , PrimaryLocFlg      = sites.PrimaryLocFlg
  , HandicapFlg        = 'U'
  , ServAddrEffDt      = @minEffDateStr
  , ServAddrExpDt      = @maxEffDateStr
  , ServName           = sites.siteNameStr
  , ServAddr1          = sites.siteAddressStr
  , ServCity           = sites.siteCityStr
  , ServState          = sites.siteStateStr
  , ServZip            = sites.siteZip5Str
  , ServPhone          = sites.sitePhoneStr
  , FacilityName       = ''
  , ProviderSpecialty1 = pracs.providerSpecialtyCodeStr1  
  , ProviderSpecialty2 = pracs.providerSpecialtyCodeStr2
  , ProviderSpecialty3 = pracs.providerSpecialtyCodeStr3
  , ProviderSpecialty4 = pracs.providerSpecialtyCodeStr4
  , CanExportRow       = pracs.canExportRow
  , ProblemsDetected   = pracs.problemsDetected
  , includeStateLicCells = pracs.includeLicData
from @pracs as pracs

cross apply (
  select top 9999999
      providerID = pracs.npiStr
    , t1.* 
  from @sites as t1
  order by 
    t1.idx asc
) as sites


/*###########################################################################*/
/*#                        Assign Billing Columns                           #*/
/*###########################################################################*/

update @providers
set
    BillName    = @clientNameStr
  , BillAddr1   = @clientAddressStr
  , BillCity    = @clientCityStr
  , BillState   = @clientStateStr
  , BillZip     = @clientZipStr   
  , BillPhone   = @clientPhoneStr

/*###########################################################################*/
/*#                        Validate export rows                             #*/
/*###########################################################################*/

/*------------------------------------*/
/* All provider types                 */
/*------------------------------------*/

update @providers
set
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + '* Provider type not determined (If this is a person make sure providers discipline is a supported CYBHI discipline)'
where (       
  (ProviderTypeID = '')
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + iif(PrimaryLocFlg = 'Y',' * Client',' * Site') 
					 + ' name missing'
where (       
  (ServName = '')
) 

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + iif(PrimaryLocFlg = 'Y',' * Client',' * Site') 
                     + ' address, city, state, or zip missing'
where (       
  ((ServAddr1 = '') or (ServCity = '') or (ServState = '') or (ServZip = '') or (ServPhone = ''))
) 

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + iif(PrimaryLocFlg = 'Y',' * Client',' * Site') 
                     + ' phone number missing'
where (       
  ((ServPhone = ''))
) 

/*------------------------------------*/
/* Required fields for all provider   */
/* types.                             */
/*------------------------------------*/

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Group name missing'
where 
  (GroupName = '')

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Group NPI missing'
where 
  (GroupNPI = '')

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected  
                     + ' * Mailing address, city, state, or zip missing'
where (       
  ((MailAddr1 = '') or (MailCity = '') or (MailState = '') or (MailZip = ''))
) 

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Contact phone number missing'
where (       
  (MailPhone = '')
) 

/*------------------------------------*/
/* Critical fields for "person"       */
/* provider types                     */
/*------------------------------------*/

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner first or last name missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and ((FirstName = '') or (LastName = ''))
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner CYBHI primary degree missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (PrimaryDegree = '')
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner CYBHI primary speciality missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (ProviderSpecialty1 = '')
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner NPI missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (ProvNPI = '')
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner (clients) tax id missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (ProviderTaxID = '')
)

/*------------------------------------*/
/* Required fields for "person"       */
/* provider types                     */
/*------------------------------------*/

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner gender missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (ProvGender = '')
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner DOB missing or invalid'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (
		isnull(trim(ProvDOB), '') = ''
       or ProvDOB = '-1'
  )
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner state license number missing'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (StateLicense1 = '')
  and (includeStateLicCells = 1)
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner state license effective date missing or invalid'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (
		isnull(trim(License1EffDt), '') = '' 
		or License1EffDt = '-1'
  )
  and (includeStateLicCells = 1)
)

update @providers
set 
    CanExportRow     = 0
  , ProblemsDetected = ProblemsDetected 
                     + ' * Practitioner state license expiration date missing or invalid'
where ( 
      (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
  and (
		isnull(trim(License1ExpDt), '') = ''
		or License1ExpDt = '-1'
  )
  and (includeStateLicCells = 1)
)

/*------------------------------------*/
/* Determine if the one client wide   */
/* provider "group" row for primary   */
/* site is OK                         */
/*------------------------------------*/

declare @clientGroupRowOK as bit = 0

select top 1 
  @clientGroupRowOK = t1.CanExportRow
from @providers as t1
where
  ((ProviderTypeID = @provTypeGroup) and (PrimaryLocFlg = 'Y'))
order by 
  RowNumber

/*------------------------------------*/
/* If not then invalidate all rows    */
/*------------------------------------*/

if (@clientGroupRowOK = 0)
begin
  update @providers
    set 
	  CanExportRow     = 0
	, ProblemsDetected = ' * Client is missing data that invalidates this entire row.  See the client "G" row for PrimaryLocFlg="Y" for more details. ' 	                   
					   + ProblemsDetected
  where 
    (ProviderTypeID in (@provTypeLicOrCred, @provTypePara))
end

update @providers set ProblemsDetected = trim(ProblemsDetected)

return

end
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CYBHI_PROVIDER_LIST_RPT_CORE] TO [webuser]
GO