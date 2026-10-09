USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @clientID                          BIGINT
  , @startDate                         DATE
  , @endDate                           DATE
  , @currentResponseCode               bigint
  , @closed                            BIT
  , @requestID                         bigint
  , @active                            BIT
  , @recID                             BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE */    
 /**    
  * Retuns a list of service authorization requests that @userID has access
  * to
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  
  select 

	  sar.id
	, [name]         = sar.svcName + ' provided to ' + pap.CONCAT_NAME
	, requestDate    = sar.created
	, requestDateStr = dbo.RPT_DATE_FMT(sar.created)
	, sar.active

	, clientID      = sar.clientID
	, clientName    = clc.CLIENT_NAME

	, districtContactName      = ua.[name] 
    , districtContactUserID    = sar.districtContactUserID
	, districtContactEmail     = ua.email
	, districtContactPhone     = ua.phone
	
	, pracID        = sar.pracID
	, pracName      = rpr.CONCAT_NAME
	, pracTitle     = rpgg.GROUP_NAME
	, pracEmail     = rpr.EMAIL
	, pracPhone     = rpr.PHONE_NUMBER
    , pracUserID    = rpr.UserID
	
	, sar.patID
	, patName       = pap.CONCAT_NAME
	, patDOBStr     = dbo.RPT_DATE_FMT(pap.DATE_OF_BIRTH)
	, patCSIS       = pap.CSIS      

    , sar.groupSvcClassNameID
	, sar.fileClass
	, sar.fileNameSpace
	, sar.fileSource

	, sar.hasFileIncludes 
	, sar.fileClassInclude
    , sar.fileNameSpaceInclude
    , sar.fileSourceInclude
	, sar.filesToIncludeUseClientIdDataParameter 
    , sar.filesToIncludeUsePracIdDataParameter 
    , sar.filesToIncludeUsePatIdDataParameter
	, sar.filesToIncludeUploadIds
    , sar.filesToIncludeUploadNames

    , sar.svcAuthorizationRequestTypeID
	, sar.referencedEntityID
	, sar.svcSelectionTypeID
	, sar.svcSelectionNameID
    , sar.svcName
	, sar.svcDescription

    , svcStartDate       = sar.svcStartDate
    , svcStartDateStr    = dbo.RPT_DATE_FMT(sar.svcStartDate)
	
	, sar.svcAuthorizationRequestEntrySourceID
	, reqSvcAuthEntrySource = sares.name

	, sar.svcAuthorizationRequestEntryPurposeID
	, reqSvcAuthEntryPurpose = sarep.name

	, sar.reqSvcAuthFromSelectionID
	, reqSvcAuthFromSelectionName = sarfw.name 
	
	, sar.reqSvcAuthMethodSelectionID
	, reqSvcAuthMethodSelectionName = sarm.name
	
	, sar.prtGrd1PersonID
	, prtGrd1Name                         = pg1.name
	, prtGrd1RelationshipWithPatientLabel = pg1.relationshipWithPatientLabel
	, prtGrd1Email                        = pg1.email
	, prtGrd1Phone                        = pg1.phone
	, prtGrd1PlaceAddress                 = pg1.placeAddress
	, prtGrd1UserID                       = pg1.userIDInt

	, sar.prtGrd2PersonID
	, prtGrd2Name                         = pg2.name
	, prtGrd2RelationshipWithPatientLabel = pg2.relationshipWithPatientLabel
	, prtGrd2Email                        = pg2.email
	, prtGrd2Phone                        = pg2.phone
	, prtGrd2PlaceAddress                 = pg2.placeAddress	
	, prtGrd2UserID                       = pg2.userIDInt
	
	, orpPracID
	, orpPracName         = orp.orpPracName
	, orpPracTitle        = orp.orpPracTitle
	, orpPracEmail        = orp.orpPracEmail
	, orpPracPhone        = orp.orpPracPhone
	, orpPracPlaceAddress = orp.orpPracPlaceAddress
	, orpUserID           = orp.orpUserID
	, orpPracNPI          = orp.orpNPI

	, sar.created
	, sar.createdBy
	, sar.lastModified
	, sar.lastModifiedBy
    
	
	, sar.currentStatusCode	
	, currentStatusName = sarpsc.name    		
	, sar.currentResponseCode
	, currentResponseName = sarrc.name   
	, sar.productKey
	, sar.closed
	
	/* Various rules */

	, sar.responseRequiredFromViewingUser 
    , sar.viewingUserCanAccessSupportingFiles
	, sar.viewingUserCanCurrentlyAccessResponseForm 	
	, sar.viewingUserCanCurrentlyDeleteAndSaveNew
	, sar.viewingUserCanCurrentlyCloseAndSaveNew
	, sar.viewingUserCanCurrentlyEditServiceDescription

	/* Previous response in chain */

    , showPrevResponseInChain = convert(bit,case when (sar.svcAuthorizationRequestEntryPurposeID = 50) then 1 else 0 end)
	, pcsarr.*
	
	/* Current response in chain (Note: At this time always a 1)*/
	
	, showCurrResponseInChain = convert(bit,1)
	, csarr.*

	/* Next response in chain (Note: At this time always a 0 */
	
	, showNextResponseInChain = convert(bit,0)
	, ncsarr.*

    , formBuilderQuestionsJSON = sar.formBuilderQuestionsJSON
	, formBuilderAnswersJSON   = sar.formBuilderAnswersJSON
	
  
  from dbo.SERVICE_AUTHORIZATION_REQUESTS_DATA_CORE  (  @userID
                                                      , @userGroup
                                                      , @userRank
                                                      , @clientID
                                                      , @startDate
                                                      , @endDate
                                                      , @currentResponseCode
                                                      , @closed
                                                      , @active
                                                      , @recID) as sar
    
  join dbo.CLIENTS_Client                                        as clc    on clc.CLIENT_ID   = sar.clientID
  join dbo.PATIENTS_Patient                                      as pap    on pap.PATIENT_ID  = sar.patID    

  join dbo.SERVICE_AUTHORIZATION_REQUEST_ENTRY_SOURCES           as sares  on sares.id        = sar.svcAuthorizationRequestEntrySourceID
  join dbo.SERVICE_AUTHORIZATION_REQUEST_ENTRY_PURPOSE           as sarep  on sarep.id        = sar.svcAuthorizationRequestEntryPurposeID
  join dbo.SERVICE_AUTHORIZATION_REQUEST_FROM_WHO                as sarfw  on sarfw.id        = sar.reqSvcAuthFromSelectionID  
  join dbo.SERVICE_AUTHORIZATION_REQUEST_METHOD                  as sarm   on sarm.id         = sar.reqSvcAuthMethodSelectionID
  join dbo.SERVICE_AUTHORIZATION_REQUEST_PROCESSING_STATUS_CODES as sarpsc on sarpsc.code     = sar.currentStatusCode
  join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_CODES          as sarrc  on sarrc.code      = sar.currentResponseCode


  /* Requesting/Rendering practitoner */

  left join  dbo.PRACTITIONER_Practitioner                  as rpr    on  (
                                                                            rpr.PRACTITIONER_ID   = sar.pracID) 
  left join  dbo.PRACTITIONER_GROUPS                        as rprg   on  (
                                                                            rprg.PRACTITIONER_ID  = rpr.PRACTITIONER_ID
                                                                            AND rprg.GROUP_TYPE in (1,2)
                                                                          )
  left join  dbo.GROUP_Group                                as rpgg   on  (
                                                                            rpgg.GROUP_ID = rprg.GROUP_ID )

  /* District contact */

  left join  users.dbo.USERS_ALL                            as ua     on  (sar.districtContactUserID = ua.id)
																					   
  /* ORP Practitioner */															    
  
  outer apply (
    
	select top 1 

	    orpPracName         = ppo.CONCAT_NAME
	  , orpPracTitle        = opgg.GROUP_NAME
	  , orpPracEmail        = ppo.EMAIL
	  , orpPracPhone        = ppo.PHONE_NUMBER	  
	  , orpPracPlaceAddress = dbo.BUILD_PLACE_ADDRESS_STRING ( ppo.street1
	                                                         , ppo.street2
		    			   									 , ppo.city
														     , ppo.usState
														     , ppo.zip5
														     , ppo.zip4
															 , 0 )

      , orpUserID = ppo.UserID
	  , orpNPI    = ppo.npiNumber

	from  dbo.PRACTITIONER_Practitioner as ppo
    join  dbo.PRACTITIONER_GROUPS       as oprg   on oprg.PRACTITIONER_ID  = ppo.PRACTITIONER_ID
                                                  and oprg.GROUP_TYPE in (1,2)
    join  dbo.GROUP_Group               as opgg   on opgg.GROUP_ID = oprg.GROUP_ID
 

    where (ppo.PRACTITIONER_ID = sar.orpPracID)

   ) as orp

  /* Parent/Guardian 1  */

  outer apply (    
    
	select top 1

	  ppvc1.name
	, ppvc1.relationshipWithPatientLabel
	, ppvc1.email
	, ppvc1.phone
	, ppvc1.placeAddress
	, ppvc1.userIDInt

   from dbo.PATIENT_PERSONS_VIEW_CORE (  @userID
                                       , @userGroup
                                       , @userRank
                                       , sar.clientID
                                       , sar.patID
                                       , 1 
                                       , null
                                       , null
                                       , sar.prtGrd1PersonID
									   , null) as ppvc1
    where 	
	  (ppvc1.id = sar.prtGrd1PersonID) /* Required since ppvc1 is a general entity view if personid is null we will return the first match based on clientid and patientid */
  
  ) as pg1

/* Parent/Guardian 2  Note: Currently not used  */

  outer apply (  
  
    select top 1

	  ppvc2.name
	, ppvc2.relationshipWithPatientLabel
	, ppvc2.email
	, ppvc2.phone
	, ppvc2.placeAddress
	, ppvc2.userIDInt   
   
   from dbo.PATIENT_PERSONS_VIEW_CORE (  @userID
                                       , @userGroup
                                       , @userRank
                                       , sar.clientID
                                       , sar.patID
                                       , 1 
                                       , null
                                       , null
                                       , sar.prtGrd2PersonID
									   , null) as ppvc2

    where 
	  (ppvc2.id = sar.prtGrd2PersonID) /* Required since ppvc2 is a general entity view if personid is null we will return the first match based on clientid and patientid */

  ) as pg2
 
 /* This requests (current link in chain) current response data */	
  
 cross apply (
   select top 1
	    currChainRequestEntryPurposeID          = crd.requestEntryPurposeID	                
	  , currChainRequestEntryPurposeName        = crd.requestEntryPurposeName
	  , currChainReqSvcAuthFromSelectionID      = crd.requestFromSelectionID
	  , currChainReqSvcAuthFromSelectionName    = crd.requestFromSelectionName
	  , currChainReqSvcAuthMethodSelectionID    = crd.requestMethodSelectionID
	  , currChainReqSvcAuthMethodSelectionName  = crd.requestFromSelectionName      
	  , currChainResponseFromUserID             = crd.responseFromUserID
	  , currChainResponseFromUserName           = crd.responseFromUserName
	  , currChainRespondantName                 = crd.respondantName
	  , currChainRespondantTitle                = crd.respondantTitle
	  , currChainRespondantSignature            = crd.respondantSignature
	  , currChainRespondantEmail                = crd.respondantEmail
	  , currChainRespondantPhone                = crd.respondantPhone
	  , currChainRespondantNPI                  = crd.respondantNPI
	  , currChainShowRespondantNPI              = crd.showRespondantNPI
	  , currChainResponseRecordedOn             = crd.responseRecordedOn 
	  , currChainResponseRecordedOnStr          = crd.responseRecordedOnStr
	  , currChainResponseEffectiveDate          = crd.responseEffectiveDate
	  , currChainResponseEffectiveDateStr       = crd.responseEffectiveDateStr
	  , currChainResponseNotes                  = crd.responseNotes
	  , currChainResponseSectionTitle           = crd.responseSectionTitle 
	  , currChainResponseAttestIntro            = crd.responseAttestIntro
	  , currChainResponseAttestStatement        = crd.responseAttestStatement 
	  , currChainResponsePersonRoleCode         = crd.responsePersonRoleCode  
	  , currChainResponsePersonRoleName         = crd.responsePersonRoleName
	  , currChainResponseCode                   = crd.responseCode
	  , currChainResponseName                   = crd.responseName
	  , currChainResponseSummary                = crd.responseSummary
	  , currChainShowResponseNotes              = crd.showResponseNotes
   from dbo.SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE(null,null,null,sar.id) as crd
 ) as csarr
  

 /* Previous Request in Chain - Its Current Response Data */
    
 outer apply (

   select top 1

	    prevChainRequestEntryPurposeID          = prd.requestEntryPurposeID	                
	  , prevChainRequestEntryPurposeName        = prd.requestEntryPurposeName
	  , prevChainReqSvcAuthFromSelectionID      = prd.requestFromSelectionID
	  , prevChainReqSvcAuthFromSelectionName    = prd.requestFromSelectionName
	  , prevChainReqSvcAuthMethodSelectionID    = prd.requestMethodSelectionID
	  , prevChainReqSvcAuthMethodSelectionName  = prd.requestFromSelectionName      
	  , prevChainResponseFromUserID             = prd.responseFromUserID
	  , prevChainResponseFromUserName           = prd.responseFromUserName
	  , prevChainRespondantName                 = prd.respondantName
	  , prevChainRespondantTitle                = prd.respondantTitle
	  , prevChainRespondantSignature            = prd.respondantSignature
	  , prevChainRespondantEmail                = prd.respondantEmail
	  , prevChainRespondantPhone                = prd.respondantPhone
	  , prevChainRespondantNPI                  = prd.respondantNPI
	  , prevChainShowRespondantNPI              = prd.showRespondantNPI
	  , prevChainResponseRecordedOn             = prd.responseRecordedOn 
	  , prevChainResponseRecordedOnStr          = prd.responseRecordedOnStr
	  , prevChainResponseEffectiveDate          = prd.responseEffectiveDate
	  , prevChainResponseEffectiveDateStr       = prd.responseEffectiveDateStr
	  , prevChainResponseNotes                  = prd.responseNotes
	  , prevChainResponseSectionTitle           = prd.responseSectionTitle 
	  , prevChainResponseAttestIntro            = prd.responseAttestIntro
	  , prevChainResponseAttestStatement        = prd.responseAttestStatement 
	  , prevChainResponsePersonRoleCode         = prd.responsePersonRoleCode  
	  , prevChainResponsePersonRoleName         = prd.responsePersonRoleName
	  , prevChainResponseCode                   = prd.responseCode
	  , prevChainResponseName                   = prd.responseName
	  , prevChainResponseSummary                = prd.responseSummary
	  , prevChainShowResponseNotes              = prd.showResponseNotes
   from dbo.SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE(null,null,null,sar.prevRequestID) as prd
 ) as pcsarr
 

  /* Next Request in Chain - Its Current Response Data  */

   outer apply (
   select top 1
	  	nextChainRequestEntryPurposeID               = nrd.requestEntryPurposeID	                
	  , nextChainRequestEntryPurposeName             = nrd.requestEntryPurposeName
	  , nextChainReqSvcAuthFromSelectionID           = nrd.requestFromSelectionID
	  , nextChainReqSvcAuthFromSelectionName         = nrd.requestFromSelectionName
	  , nextChainReqSvcAuthMethodSelectionID         = nrd.requestMethodSelectionID
	  , nextChainReqSvcAuthMethodSelectionName       = nrd.requestFromSelectionName      
	  , nextChainResponseFromUserID                  = nrd.responseFromUserID
	  , nextChainResponseFromUserName                = nrd.responseFromUserName
	  , nextChainRespondantName                      = nrd.respondantName
	  , nextChainRespondantTitle                     = nrd.respondantTitle
	  , nextChainRespondantSignature                 = nrd.respondantSignature
	  , nextChainRespondantEmail                     = nrd.respondantEmail
	  , nextChainRespondantPhone                     = nrd.respondantPhone
	  , nextChainRespondantNPI                       = nrd.respondantNPI
	  , nextChainShowRespondantNPI                   = nrd.showRespondantNPI
	  , nextChainResponseRecordedOn                  = nrd.responseRecordedOn 
	  , nextChainResponseRecordedOnStr               = nrd.responseRecordedOnStr
	  , nextChainResponseEffectiveDate               = nrd.responseEffectiveDate
	  , nextChainResponseEffectiveDateStr            = nrd.responseEffectiveDateStr
	  , nextChainResponseNotes                       = nrd.responseNotes
	  , nextChainResponseSectionTitle                = nrd.responseSectionTitle 
	  , nextChainResponseAttestIntro                 = nrd.responseAttestIntro
	  , nextChainResponseAttestStatement             = nrd.responseAttestStatement 
	  , nextChainResponsePersonRoleCode              = nrd.responsePersonRoleCode  
	  , nextChainResponsePersonRoleName              = nrd.responsePersonRoleName
	  , nextChainResponseCode                        = nrd.responseCode
	  , nextChainResponseName                        = nrd.responseName
	  , nextChainResponseSummary                     = nrd.responseSummary
	  , nextChainShowResponseNotes                   = nrd.showResponseNotes
   from dbo.SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE(null,null,null,sar.nextRequestID) as nrd
 ) as ncsarr
 
  where (
        (1=1) 
    and ((@requestID is null) or (sar.id = @requestID))


  )

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_VIEW_CORE] TO [webuser]
GO  
