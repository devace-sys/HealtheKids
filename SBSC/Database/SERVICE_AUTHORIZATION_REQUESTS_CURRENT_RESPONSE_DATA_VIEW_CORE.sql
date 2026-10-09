USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @requestID bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE */    
 /**    
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  
  with
  cte_p1
  as
  (
  select top 1 

        requestEntryPurposeID         = sarep.id
	  , requestEntryPurposeName       = sarep.name
      , requestFromSelectionID        = sar.reqSvcAuthFromSelectionID
	  , requestFromSelectionName      = sarfw.name
	  , requestMethodSelectionID      = sar.reqSvcAuthMethodSelectionID	  
	  , requestMethodSelectionName    = sarm.name
	  	  
	  , responseSectionTitle  =  case when (sar.reqSvcAuthFromSelectionID = 10) then 'Parent or Guardian Consent for Authorization and Management of Medical Services in the School Setting'
	                                  when (sar.reqSvcAuthFromSelectionID = 20) then 'Authorized Healthcare Provider Authorization for Medical Services in the School Setting'
								      else ''
						          end
	  
	  , responseAttestIntro  =  case when (sar.reqSvcAuthMethodSelectionID = 10) then 'I herby attest by submitting my response that :'
	                                                                             else 'I herby attest by signing this form that : '
						            end

	  , responseAttestStatement  =  case when (sar.reqSvcAuthFromSelectionID = 10) then sarraspg.responseAttestStatement
	                                     when (sar.reqSvcAuthFromSelectionID = 20) then sarrasorp.responseAttestStatement
								         else ''
						            end

	  , respondantSignature = case when ( sar.reqSvcAuthMethodSelectionID = 10) then 
	                            case when (sar.currentResponseID is not null) then
	                               'Electronically signed by ' 
								  + m.LastName
								  + ', '
								  + m.FirstName
								  + ' ('
								  + u.UserName 
								  + ')'
								else '' end
							else '' end
	  
	  , respondantName = case when (sar.reqSvcAuthFromSelectionID = 10) then pg1data.name
	                          when (sar.reqSvcAuthFromSelectionID = 20) then orpdata.name
							  else ''
						   end
	  
	  , respondantTitle = case when (sar.reqSvcAuthFromSelectionID = 10) then pg1data.title
	                           when (sar.reqSvcAuthFromSelectionID = 20) then orpdata.title
							   else ''
						   end
	  , respondantEmail = case when (sar.reqSvcAuthFromSelectionID = 10) then pg1data.email
	                           when (sar.reqSvcAuthFromSelectionID = 20) then orpdata.email
							   else ''
						   end

	  , respondantPhone =  case when (sar.reqSvcAuthFromSelectionID = 10) then pg1data.phone
	                            when (sar.reqSvcAuthFromSelectionID = 20) then orpdata.phone
							  	else ''
					       end

	  , respondantNPI     = case when (sar.reqSvcAuthFromSelectionID = 20) then orpdata.npi else '' end
	  , showRespondantNPI = convert(bit,(case when (sar.reqSvcAuthFromSelectionID = 20) then 1 else 0 end))

	  , responseCode             = sar.currentResponseCode
	  , responseName             = sarrc.name
	  , responseID               = sar.currentResponseID
	  
	  , responseFromUserID       = sarr.userID
	  , responseFromUserName     = u.UserName	 
	  , responsePersonRoleCode   = sarr.personRoleCode
	  , responsePersonRoleName   = saprc.name
	  , responseRecordedOn       = sarr.createdOn
	  , responseRecordedOnStr    = dbo.RPT_DATE_FMT(sarr.createdOn)	  
	  , responseEffectiveDate    = sarr.effectiveDate
	  , responseEffectiveDateStr = dbo.RPT_DATE_FMT(sarr.effectiveDate)
	  , responseNotes            = trim(isnull(sarr.responseNotes,''))
	  
	from dbo.SERVICE_AUTHORIZATION_REQUESTS                           as sar

    join dbo.SERVICE_AUTHORIZATION_REQUEST_ENTRY_PURPOSE              as sarep     on sarep.id     = sar.svcAuthorizationRequestEntryPurposeID
	join dbo.SERVICE_AUTHORIZATION_REQUEST_METHOD                     as sarm      on sarm.id      = sar.reqSvcAuthMethodSelectionID
	join dbo.SERVICE_AUTHORIZATION_REQUEST_FROM_WHO                   as sarfw     on sarfw.id     = sar.reqSvcAuthFromSelectionID 
	join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_CODES             as sarrc     on sarrc.code   = sar.currentResponseCode	
	join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_ATTEST_STATEMENTS as sarraspg  on sarraspg.id  = sar.pg1AttestStatementID
	join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSE_ATTEST_STATEMENTS as sarrasorp on sarrasorp.id = sar.orpAttestStatementID

	left join dbo.SERVICE_AUTHORIZATION_REQUEST_RESPONSES             as sarr     on sarr.id     = sar.currentResponseID
	left join dbo.SERVICE_AUTHORIZATION_PERSON_ROLE_CODES             as saprc    on saprc.code  = sarr.personRoleCode
	left join users.dbo.Users                                         as u        on u.userrid   = sarr.userID
	left join users.dbo.Membership                                    as m        on m.UserId    = u.UserId

	outer apply (
	 select top 1
	     ppvc1.name 
	   , ppvc1.email
	   , ppvc1.phone
	   , title = ppvc1.relationshipWithPatientLabel
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
	) as pg1data
	
	outer apply (
	  select top 1 
	      name  = orp.FIRST_NAME + ' ' + orp.LAST_NAME
		, email = orp.EMAIL
		, phone = orp.PHONE_NUMBER
		, title = ggorp.GROUP_NAME
		, npi   = orp.npiNumber
	  from  dbo.PRACTITIONER_Practitioner as orp
	  join  dbo.PRACTITIONER_GROUPS       as pgorp on pgorp.PRACTITIONER_ID = orp.PRACTITIONER_ID
	                                               and pgorp.GROUP_TYPE in (1,2)
      join  dbo.GROUP_Group               as ggorp on ggorp.GROUP_ID = pgorp.GROUP_ID
	  where (orp.PRACTITIONER_ID = sar.orpPracID)
	) as orpdata
	
	where (sar.id = @requestID)
    )
	,
	cte_p2
	as
	(
	  select 
	    p1.* 
	  , responseSummary =  'This request '
	                       + case when (p1.responseCode = 2000)
	                           then 'is '  + upper(p1.responseName)  + ' a ' 
	                           else 'was ' + upper(p1.responseName)  + ' in a '
                             end
                           + upper(p1.requestMethodSelectionName) + ' response from the '
						   + upper(p1.requestFromSelectionName)   + ' (' 
						   + p1.respondantName
						   + ')'
						   + case when (p1.responseCode != 2000) then
						   + ' on ' +  p1.responseRecordedOnStr else '' end
						   + case when (p1.responseCode = 3000) then 
						    ' effective as of ' + p1.responseEffectiveDateStr else '' end
						   +'.'

	  , showResponseNotes  = convert(bit,(case when responseCode != 200 then
	                                        case when responseNotes != '' then 1 else 0 end
	                                      else 0 end))
	  from cte_p1 as p1

	)
	select p2.* from cte_p2 as p2
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_CURRENT_RESPONSE_DATA_VIEW_CORE] TO [webuser]
GO  
