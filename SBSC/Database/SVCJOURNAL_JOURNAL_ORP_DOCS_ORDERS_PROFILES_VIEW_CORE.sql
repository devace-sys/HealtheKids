USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT      
  , @clientID               BIGINT
  , @pracID                 BIGINT
  , @groupSvcClassNameID    BIGINT  
  , @patID                  BIGINT
  , @referenceDate          DATE
  , @startRefDate           DATE
  , @endRefDate             DATE
  , @maxRow                 INT
  , @orpApprovalState       BIGINT
  , @recID                  BIGINT
  , @active                 BIT
  
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

with
cte_orp_docs_orders_profiles
as
(
select 
    id               = oddc.ID
  , clientID         = oddc.CLIENT_ID
  , patID            = oddc.PATIENT_ID
  , effectiveDate    = oddc.START_DATE
  , endDate          = oddc.END_DATE
  , diagnosis        = oddc.DIAGNOSIS
  , svcName          = oddc.SVCE_NAME
  , mdOrders         = oddc.MD_ORDERS
  , orpDocStdNameID  = oddc.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
  , orpDocStdName    = oddc.ORP_DOCUMENT_STANDARD_SELECTION_NAME
  , oddc.svcDesc
  , oddc.noteCrit1
  , oddc.noteCrit2
  , oddc.noteCrit3
  , oddc.noteCrit4
  , oddc.noteCrit5
  , oddc.noteCrit6
  , oddc.noteCrit7
  , oddc.noteCrit8
  , oddc.noteCrit9
  , oddc.noteCrit10
  , oddc.noteObsvCmnt
  , oddc.noteTemplateTitle
  , oddc.noteTemplateText
  , oddc.iep
  , oddc.iepYN
  , oddc.frequency
  , oddc.frequencyName
  , oddc.projectedMinutes
  , oddc.planStartDate
  , oddc.planStartDateStr	
  , oddc.planStartDateStrYMD	
  , oddc.planEndDate
  , oddc.planEndDateStr		
  , oddc.planEndDateStrYMD	
  , oddc.expectedOutcomes
  , oddc.dailyFreq
  , oddc.siteAide
  , oddc.siteAideYN 
  , oddc.busAide	
  , oddc.busAideYN
  , oddc.detailsTrainingPracsJSON
  , oddc.orderProfilePracIDsStr
  , orpPracID = oddc.ORP_PRAC_ID
  , created = oddc.CREATED
  , createdBy = oddc.CREATED_BY       
  , lastModified = oddc.LAST_MODIFIED    
  , lastModifiedBy = oddc.LAST_MODIFIED_BY 
  , active = oddc.ACTIVE

  , groupServiceClassNameID   = oddc.GROUP_SERVICE_CLASS_NAME_ID
  , groupServiceClassNameName = oddc.GROUP_SERVICE_CLASS_NAME	
  , oddc.allowMultipleOrders
  , oddc.orderContextFieldName
  , oddc.formBuilderQuestionsJSON
  , oddc.formBuilderAnswersJSON
  , effectiveDateStr = oddc.startDateStr
  , oddc.endDateStr
  , oddc.createdStr
  , oddc.lastModifiedStr
  , oddc.ORP_DOCUMENT_ID
  , oddc.svcDescOrFormBuilderHtml
  , refID = oddc.REFERENCE_ID
  , orpDocType = oddc.ORP_DOCUMENT_TYPE_ID
  , oddc.activeStr
  , orpDocID   = oddc.ORP_DOC_ID
  , refDate = (isnull(@referenceDate,convert(date,getdate())))
  , oddc.displayLastApproval 
  , oddc.hasLastApproval
  , oddc.lastApprovalOrpPracID
  , oddc.lastApprovalOrpName 
  , oddc.lastApprovalOrpTitle
  , oddc.lastApprovalOrpNPI
  , oddc.lastApprovalEffectiveDate
  , oddc.lastApprovalEffectiveDateStr
  , oddc.lastApprovalExpirationDate
  , oddc.lastApprovalExpirationDateStr
  , oddc.lastApprovalExpiresInDays
  , oddc.lastApprovalExpirationState
  , lastApprovalExpirationMessage = iif ( /* Expiration state is no auth yet*/
                                      (oddc.lastApprovalExpirationState = 0) 
                                      /* No auth state and eauth is pending */
									, iif ((EAuthPending2.hasEAuthPending = 1) 
									/* Change message and add pending date*/
									, EAuthPending2.eAuthPendingMessage
									/* Otherwise keep same message */
									,oddc.lastApprovalExpirationMessage)
									/* expirationState is something else.. pass message through */
                                    , oddc.lastApprovalExpirationMessage )

  , oddc.lastApprovalOrpIsValidMcalOrp
  , oddc.lastApprovalOrpIsValidMcalOrpStr

from dbo.ORP_DOCUMENTS_DATA_CORE (@clientID,@groupSvcClassNameID,@patID,null,@active,@recID,null) as oddc

/* EAuthorization Status Check */
outer apply (
  select top 1
      hasEAuthPending = 1
	, eAuthPendingMessage = 'Pending E-Authorization as of ' + dbo.RPT_DATE_FMT(EAuthPending1.created)
  from dbo.SERVICE_AUTHORIZATION_REQUESTS as EAuthPending1
  where (
    /* Optimized for [CLIENT_ID_CLOSED_ACTIVE_CUR_RESP_CODE_IDX] index */
    (
	      (EAuthPending1.clientID = oddc.CLIENT_ID)
      and (EAuthPending1.closed = 0)
      and (EAuthPending1.active = 1)
      and (EAuthPending1.currentResponseCode = 2000) /* Pending*/
      and (EAuthPending1.id is not null)
	)
    and (EAuthPending1.reqSvcAuthFromSelectionID = 20) /* ORP */
    and (EAuthPending1.orpDocID = oddc.ORP_DOC_ID)
    and (EAuthPending1.svcAuthorizationRequestTypeID in (1,2)) /* Order/Prescription or Patient Profile */
  )
) as EAuthPending2

where 
  (oddc.ORP_DOCUMENT_TYPE_ID != 1)
)

,
cte_output
as
(
select 
	  cc.* 
	, effRefDiff = datediff(day,cc.effectiveDate,(isnull(@referenceDate,convert(date,getdate())))) 
	, orpPracName            = isnull(orp.CONCAT_NAME,'')
    , orpNPI                 = isnull(orp.npiNumber,'')
    , orpIsValidMcalOrp      = dbo.RPT_BIT_TO_YNU(orp.isValidMcalOrp)
	, clientName             = clc.CLIENT_NAME
    , patName                = pap.CONCAT_NAME
	, createdByUserName      = isnull(ucb.UserName,'')
	, lastModifiedByUserName = isnull(umb.UserName,'')

	, siteName  = ps.SITE_NAME
	, studentID = ps.STUDENT_ID

from cte_orp_docs_orders_profiles as cc

join dbo.CLIENTS_Client                        as clc  on clc.CLIENT_ID                   = cc.clientID
join dbo.PATIENTS_Patient                      as pap  on pap.PATIENT_ID                  = cc.patID

left join dbo.PRACTITIONER_Practitioner   as orp  on orp.PRACTITIONER_ID = cc.orpPracID    
left join users.dbo.Users                 as ucb  on ucb.userrid         = cc.createdBy
left join users.dbo.Users                 as umb  on umb.userrid         = cc.lastModifiedBy
left join dbo.PATIENTS_SITES_VIEW_CURRENT (@clientID)  as ps on ps.PATIENT_ID = cc.patID 


)

select t1.* 
from cte_output as t1
where ( 
      (1=1)
  and ((@orpApprovalState is null) or (t1.lastApprovalExpirationState = @orpApprovalState))
)
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE] TO [webuser]
GO  
