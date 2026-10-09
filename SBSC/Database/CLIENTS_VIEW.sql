USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENTS_VIEW]    
(@userID            INT,    
 @userGroup         INT,    
 @userRank          INT,   
 @recID             INT,     
 @clientName        NVARCHAR(50),
 @first_check       datetime,
 @last_check        datetime,
 @activeLEA         BIT,    
 @activeMAA         BIT,
 @rvnsharectgLEA    NVARCHAR(100),  
 @rvnsharectgMAA    NVARCHAR(100),   
 @approved_837      BIT,
 @approved_835      BIT,    
 @clrepIDLEA        BIGINT,         
 --@clrepIDMAA        BIGINT,
 @owndbycompIDLEA   BIGINT,  
 @owndbycompIDMAA   BIGINT,  
 @active            BIT,    
 @canEdit           BIT)    
 
 RETURNS TABLE    
 
 /***************************************************************************    
  * CLIENTS_VIEW */    
 /**    
  * Returns a table of clients that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank     
  * @param  clientname      All or part of client name   
  * @param  activeLEA       Client is an active LEA client
  * @param  activeMAA       Client is an active MAA client
  * @param  first_check
  * @param  last_check
  * @param  @rvnsharectgLEA       
  * @param  @rvnsharectgMAA      
  * @param  @approved_837      
  * @param  @approved_835
  * @param  active          If client is active
  * @param  recID           Client record id    
  * @return                 Table of client data    
  ***************************************************************************/     

/* TODO: Refactor this into a CTE */

AS RETURN(   
          
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/     
 
select top (dbo.CONST_MAX_ROWS()) *
   from (
   select

     c.CLIENT_ID                        as id,    
     c.CLIENT_NAME                      as name,    
     c.CLIENT_CDS                       as CDS,
     c.NPI                              as NPI,
     c.TAX_ID                           as tax_ID,
     c.FIRST_CHECK                      as firstcheck,
     c.LAST_CHECK                       as lastcheck,
	 c.APPROVED_837                     as approved_837,
	 c.APPROVED_835                     as approved_835,

	 c.EIN,
	 c.COE,
	 c.LEA,
	 c.MAA,
	 c.RevenueSharingCategoryLEACurrent as rvnsharectgLEA,
     c.RevenueSharingCategoryMAACurrent            as rvnsharectgMAA,
     c.ClientRepIDLEACurrent                       as clrepidLEA,
     cr1.first_name+', '+cr1.last_name             as clrepnameLEA,     
     c.ClientRepIDMAACurrent                       as clrepidMAA,
     cr2.first_name+', '+cr2.last_name             as clrepnameMAA,
     c.OwnedByCompanyID_LEA                        as owndbycompidLEA,
     cm1.name                                      as companynameLEA,
     c.OwnedByCompanyID_MAA                        as owndbycompidMAA,
     cm2.name                                      as companynameMAA,
	 c.lecOrLgaID,
	 lol.[name]                                    as lecOrLgaName,

     c.ShortName                                   as shortname,  
     c.NameRecgByDHCS_EDS                          as namercgbyDHCS_EDS, 
     c.TCM_RATE,

     Convert(varchar(20),c.LEARecoveryBudget)      as LEARecoveryBudget,
	 Convert(varchar(20),c.hyQueueFee)			   as hyQueueFee,
	 Convert(varchar(20),c.planWriterFee)		   as planWriterFee,
	 Convert(varchar(20),c.baselineReimbursement)  as baselineReimbursement,

	 c.carePlanLegalLang                           as carePlanLegalLang,
	 c.clientlogofiledata                          as clientlogofiledata,

   c.claimNoPlan                                   as claimNoPlan,
   c.claimNoPlanEffectiveDate                      as claimNoPlanEffectiveDate,
   c.claim_TCM                                     as claim_TCM,
   c.claim_TCMEffectiveDate                        as claim_TCMEffectiveDate,
   c.parentConsentAgreement                        as parentConsentAgreement,
   c.parentConsentAgreementEffectiveDate           as parentConsentAgreementEffectiveDate,
   ca.ADDRESS_1                                    as address1,               
   ca.ADDRESS_2                                    as address2,
   ca.CITY                                         as city,
   ca.STATE                                        as state,
   ca.ZIP                                          as zip,
   ca.ZIP_PLUS_FOUR                                as zipplusfour,
   cc.CONTACT_LAST_NAME + ' ' + 
   cc.CONTACT_FIRST_NAME                           as contactname,    
   cc.CONTACT_LAST_NAME                            as contactlname,
   cc.CONTACT_FIRST_NAME                           as contactfname,                                            
   cc.TITLE                                        as contactTitle,
   cc.EMAIL                                        as contactEmail,
   cc.PHONE                                        as contactPhone,
   cc.FAX                                          as contactFax,
     isnull(cn.note,'')                            as notes,
     '    '                                        as blank,
     c.vLEA,
     c.vMAA,
     /* Derive active flag based on LEA and MAA flags*/
     active = case 
       when c.vLEA = 0 and c.vMAA = 0 then convert(bit,0)
       when c.vLEA = 0 and c.vMAA = 1 then convert(bit,1)
       when c.vLEA = 1 and c.vMAA = 0 then convert(bit,1)
       when c.vLEA = 1 and c.vMAA = 1 then convert(bit,1)
     end,
     u.LoweredUserName                  as clrepEmailLEA,
     isnull(sroa.approvalSystem,0) as svcRecApprovalSystem,
     c.sendUsersEmailNotifications,
       planWriterAccessGranted      = isnull(pw.ACCESS_GRANTED,convert(bit,0))
     , planWriterAccessGrantedStr   = dbo.RPT_BIT_TO_YN(isnull(pw.ACCESS_GRANTED,convert(bit,0)))
     , planWriterAccessEndDate      = pw.END_DATE
     , planWriterAccessEndDateStr   = dbo.RPT_DATE_FMT(pw.END_DATE)
     , c.numDaysToHoldClientEnteredClaims
     , c.autoGenerate837File
     , autoGenerate837FileStr =  dbo.RPT_BIT_TO_YN(c.autoGenerate837File)
	 , teleCommTeleHealthAccessGranted    = c.teleCommTeleHealthAccessGranted
     , teleCommTeleHealthAccessGrantedStr = dbo.RPT_BIT_TO_YN(c.teleCommTeleHealthAccessGranted)
     , teleCommTeleHealthAccessEndDate    = c.teleCommTeleHealthAccessEndDate
     , teleCommTeleHealthAccessEndDateStr = dbo.RPT_DATE_FMT(c.teleCommTeleHealthAccessEndDate)

	 , teleCommTeleIEPAccessGranted    = c.teleCommTeleIEPAccessGranted
     , teleCommTeleIEPAccessGrantedStr = dbo.RPT_BIT_TO_YN(c.teleCommTeleIEPAccessGranted)
     , teleCommTeleIEPAccessEndDate    = c.teleCommTeleIEPAccessEndDate
     , teleCommTeleIEPAccessEndDateStr = dbo.RPT_DATE_FMT(c.teleCommTeleIEPAccessEndDate)
     , c.defaultMCALBillingConsentMsgText

   , dbo.RPT_BIT_TO_YN(c.LEA)                                as LEAYN
   , dbo.RPT_BIT_TO_YN(c.MAA)                                as MAAYN
   , dbo.RPT_BIT_TO_YN(c.COE)                                as COEYN
   , dbo.RPT_DATE_FMT(c.FIRST_CHECK)                         as firstcheckStr
   , dbo.RPT_DATE_FMT(c.LAST_CHECK)                          as lastcheckStr
   , dbo.RPT_BIT_TO_YN(c.APPROVED_837)                       as approved_837YN
   , dbo.RPT_BIT_TO_YN(c.APPROVED_835)                       as approved_835YN
   , dbo.RPT_BIT_TO_YNU(c.claimNoPlan)                       as claimNoPlanYN
   , dbo.RPT_DATE_FMT(c.claimNoPlanEffectiveDate)            as claimNoPlanEffectiveDateStr
   , dbo.RPT_BIT_TO_YNU(c.claim_TCM)                         as claim_TCMYN
   , dbo.RPT_DATE_FMT(c.claim_TCMEffectiveDate)              as claim_TCMEffectiveDateStr
   , dbo.RPT_BIT_TO_YNU(c.parentConsentAgreement)            as parentConsentAgreementYN
   , dbo.RPT_DATE_FMT(c.parentConsentAgreementEffectiveDate) as parentConsentAgreementEffectiveDateStr
   , c.cronTabExpectedTotPop
   , c.cronTabExpectedSpecEdSvcs   
   , c.sendRequestsForTotPop
   , sendRequestsForTotPopStr = dbo.RPT_BIT_TO_YN(c.sendRequestsForTotPop)
   , c.sendRequestsForSpEd
   , sendRequestsForSpEdStr = dbo.RPT_BIT_TO_YN(c.sendRequestsForSpEd)
   , c.SELPACode
   , (cast(selpa.code as varchar) + ' ' + selpa.[name] ) as SELPACodeAndName
   , c.sendElibilityDataMatchRequestsToDHCS
   , sendElibilityDataMatchRequestsToDHCSStr = dbo.RPT_BIT_TO_YN(c.sendElibilityDataMatchRequestsToDHCS) 
   , c.cdeComplianceClient
   , cdeComplianceClientStr = dbo.RPT_BIT_TO_YN(c.cdeComplianceClient)
   , c.cybhi
   , cybhiStr               = dbo.RPT_BIT_TO_YN(c.cybhi)
   , c.fuzzyMatchSitesByNameAndCode
   , fuzzyMatchSitesByNameAndCodeStr = dbo.RPT_BIT_TO_YN(c.fuzzyMatchSitesByNameAndCode)
   , cybhiClientCode = isnull(c.cybhiClientCode,'')
   , c.initialContractStartDate
   , c.healtheKids_percent
   , c.cybhi_percent
   , c.crcs_percent
   , c.cdeReporting_percent
   , (c.healtheKids_percent + c.cybhi_percent + c.crcs_percent + c.cdeReporting_percent + c.planImplementation_percent) total_percent
   , c.planImplementation_percent
   , c.ruHealth_percent
   , c.newProduct2_percent
   , c.newProduct3_percent
   , c.accounting_percent
   , c.flatFee_amount

   --, c.practiCal_percent
   --, c.spEdCare_percent

   , c.csba_percent
   , c.lba_percent
   , c.partner1_percent
   , c.partner1E_percent
   , c.partner2_percent
   , c.clientRetention
   , c.mba_bba_percent

   --, c.mba_dg_percent
   , c.spEdCare_bba_percent 
   --, c.spEdCare_dg_percent

   , c.smaa_1_percent
   , c.smaa_2_percent
   , c.smaa_3_percent        
   , c.cybhiDoNotClaimOverappingLEABopSvcs
   , c.cybhiAddOnMissingInfoRequestsToPatientPersons
   , c.cybhiTpaApproved
   , c.cybhiTpaApprovedOn
   , c.cybhiTpaID
   , c.cybhiConsortiumBilling
   , c.cybhiConsortiumLeadClientID
   , c.leaBopConsortiumBilling
   , c.leaBopConsortiumLeadClientID

   , c.cybhiSubmitClaims
   , c.impliedFerpaConsent
 
   , c.cybhiClinicalSupervisorPracID
   , cybhiClinicalSupervisorPracName = isnull(ccsPrac.CONCAT_NAME,N'')

   , cybhiClientName				 = trim(isnull(c.cybhiClientName,N''))
   , cybhiNPI						 = trim(isnull(c.cybhiNPI,N''))
   , cybhiTaxID						 = trim(isnull(c.cybhiTaxID,N''))
   , cybhiAddress1				     = trim(isnull(c.cybhiAddress1,N''))
   , cybhiAddress2				     = trim(isnull(c.cybhiAddress2,N''))
   , cybhiCity					     = trim(isnull(c.cybhiCity,N''))
   , cybhiState						 = trim(isnull(c.cybhiState,N''))
   , cybhiZip5					     = trim(isnull(c.cybhiZip5,N''))
   , cybhiZip4						 = trim(isnull(c.cybhiZip4,N''))
   
   , c.cybhiGenerate837
   , c.cybhiAutoGenerate837
   , c.cybhiNumDaysToHoldEnteredClaims
   from (
     /* Ensure that active flags for LEA and MAA return true or false*/
     select 
       t1.*, 
       isnull(t1.LEA,convert(bit,0)) as vLEA, 
       isnull(t1.MAA,convert(bit,0)) as vMAA 
     from dbo.CLIENTS_Client as t1
   ) as c
   left join  CLIENTS_Address               as ca  on ca.CLIENT_ID = c.CLIENT_ID
   left join  CLIENTS_Contact               as cc  on cc.CLIENT_ID = c.CLIENT_ID       
   left join  INPUT_NOTES_CLIENT(@recID)    as cn  on cn.clientID  = c.CLIENT_ID
   left join  CLIENTS_Client_Reps           as cr1 on cr1.id       = c.ClientRepIDLEACurrent  
   left join  CLIENTS_Client_Reps           as cr2 on cr2.id       = c.ClientRepIDMAACurrent  
   left join  USERS.dbo.Users               as u   on cr1.user_id  = u.userrid
   left join  COMPANIES                     as cm1 on cm1.id      = c. OwnedByCompanyID_LEA 
   left join  COMPANIES                     as cm2 on cm2.id      = c. OwnedByCompanyID_MAA 
   left join  dbo.SERVICE_RECORDS_APPROVAL_OPTIONS as sroa on sroa.clientID = c.CLIENT_ID
   left join  dbo.PLAN_WRITER               as pw  on  pw.CLIENT_ID = c.CLIENT_ID
                                                   and pw.ACTIVE    = 1
   left join  dbo.LEC_OR_LGA as lol on lol.id = c.lecOrLgaID
   left join  dbo.SELPAS     as selpa on selpa.code = c.SELPACode

   left join  dbo.PRACTITIONER_Practitioner as ccsPrac on ccsPrac.PRACTITIONER_ID = c.cybhiClinicalSupervisorPracID

   ) as cv   
   where 
     (1=1)     
   and ((@clientName       is null)  or (cv.[name] like dbo.CREATE_NAME_PAT(@clientName)))   

   and ((@activeLEA        is null)  or (cv.vLEA            = @activeLEA))
   and ((@activeMAA        is null)  or (cv.vMAA            = @activeMAA))    
   and ((@approved_837     is null)  or (cv.APPROVED_837    = @approved_837)) 
   and ((@approved_835     is null)  or (cv.APPROVED_835    = @approved_835))   
   and ((@clrepIDLEA       is null)  or (cv.clrepidLEA      = @clrepIDLEA)) 
  -- and ((@clrepIDMAA       is null)  or (cv.clrepidMAA      = @clrepIDMAA)) 
   and ((@first_check      is null)  or (cv.firstcheck      = @first_check)) 
   and ((@last_check       is null)  or (cv.lastcheck       = @last_check))  
   and ((@rvnsharectgLEA   is null)  or (cv.rvnsharectgLEA  = @rvnsharectgLEA )) 
   and ((@rvnsharectgMAA   is null)  or (cv.rvnsharectgMAA  = @rvnsharectgMAA)) 
   and ((@owndbycompIDLEA  is null)  or (cv.owndbycompidLEA = @owndbycompIDLEA)) 
   and ((@owndbycompIDMAA  is null)  or (cv.owndbycompidMAA = @owndbycompIDMAA)) 
   and ((@active           is null)  or (cv.active          = @active))
   and ((@recID            is null)  or (cv.id              = @recID)) 
   order by 
     cv.[name]
 )    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENTS_VIEW] TO [webuser]
GO
