USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENTS_DATA_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENTS_DATA_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[ORP_DOCUMENTS_DATA_CORE] (    
    @clientID                 bigint
  , @groupSvcClassNameID      bigint
  , @patID                    bigint
  , @dos                      date
  , @active                   bit  
  , @recID                    bigint
  , @refID                    bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * ORP_DOCUMENTS_DATA_CORE */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

with

/*###########################################################################
  # Special Authorization Documents for Multiple Patients
  ###########################################################################*/  

cte_ad_p1
as
(
  select 
    
	  t1.GROUP_SERVICE_CLASS_PARTITION_ID
    , t1.GROUP_SERVICE_CLASS_NAME_ID
	, [SVCE_NAME]      = 'Special auth document'
    , t1.CLIENT_ID  
    , PATIENT_ID = @patID
    , t1.START_DATE
    , t1.END_DATE
    , DIAGNOSIS          = ''
	, MD_ORDERS          = ''
    , t1.ORP_PRAC_ID
	, ORP_ORDERS         = 'Special authorization document covering all applicable patients for this service'
    , ADDITIONAL_INFO    = ''

    , SVC_NOTE_TEMPLATE_TITLE = ''
    , SVC_NOTE_TEMPLATE_TEXT  = ''
	, SVC_NOTE_CRITERIA_FORM_QUESTIONS_JSON = ''
    , t1.CREATED
    , t1.CREATED_BY
    , t1.LAST_MODIFIED
    , t1.LAST_MODIFIED_BY
    , t1.ACTIVE

    , ORP_DOC_ID   = t1.ORP_DOCUMENT_ID
    , REFERENCE_ID = t1.id
	, formBuilderQuestionsJSON	 = null
	, formBuilderAnswersJSON  	 = null
	, detailsTrainingPracsJSON   = '{}'
	, orderProfilePracIDsStr     = ''

	, orderContextFieldName      = ''
	, allowMultipleOrders        = convert(bit,0)
	, svcDesc                    = ''
	, expectedOutcomes           = ''
    , noteCrit1			         = ''
	, noteCrit2			         = ''
	, noteCrit3			         = ''
	, noteCrit4			         = ''
	, noteCrit5			         = ''
	, noteCrit6			         = ''
	, noteCrit7			         = ''
	, noteCrit8 		         = ''
	, noteCrit9			         = ''
	, noteCrit10		         = ''
	, noteObsvCmnt		         = ''
	, noteTemplateTitle          = ''
    , noteTemplateText           = ''

	, iep                        = null
	, frequency					 = null
	, frequencyName				 = null
    , projectedMinutes			 = null
    , planStartDate				 = null
    , planStartDateStr			 = null
    , planStartDateStrYMD		 = null
    , planEndDate				 = null
    , planEndDateStr			 = null
    , planEndDateStrYMD			 = null
 	, dailyFreq                  = null
    , siteAide                   = null
    , busAide                    = null
	, createdOrModified          = isnull(t1.LAST_MODIFIED,t1.CREATED)
  
   , pracsTrainingRecID = 0
   , pracIDsStr = ''
   , pracNamesStr = ''
   , pracTitlesStr = ''  
   , displayLastApproval              = convert(bit,(case when ((t1.START_DATE is null) or (t1.END_DATE is null)) then 0 else 1 end))
   , hasLastApproval                  = convert(bit,(case when (orp.PRACTITIONER_ID is null) then 0 else 1 end))
   , lastApprovalOrpPracID            = t1.ORP_PRAC_ID
   , lastApprovalOrpName              = isnull(orp.CONCAT_NAME,'') 
   , lastApprovalOrpTitle             = gg.GROUP_NAME 
   , lastApprovalOrpNPI               = isnull(orp.npiNumber,'')
   , lastApprovalEffectiveDate        = t1.START_DATE
   , lastApprovalEffectiveDateStr     = dbo.RPT_DATE_FMT(t1.START_DATE)
   , lastApprovalExpirationDate       = t1.END_DATE
   , lastApprovalExpirationDateStr    = dbo.RPT_DATE_FMT(t1.END_DATE)
   , lastApprovalExpiresInDays        = datediff(day,getdate(),isnull(t1.END_DATE,getdate()))
   , lastApprovalOrpIsValidMcalOrp    = orp.isValidMcalOrp
   , lastApprovalOrpIsValidMcalOrpStr = dbo.RPT_BIT_TO_YNU(orp.isValidMcalOrp)

  from dbo.CLIENT_PBS_DOCUMENTATION as t1
  
  left join dbo.PRACTITIONER_Practitioner as orp on orp.PRACTITIONER_ID = t1.ORP_PRAC_ID
  left join dbo.PRACTITIONER_GROUPS       as pg  on (   (pg.PRACTITIONER_ID = orp.PRACTITIONER_ID)
                                                    and (pg.GROUP_TYPE in (1,2))
												    )
  left join dbo.GROUP_Group               as gg  on (   (gg.GROUP_ID = pg.GROUP_ID)
                                                    and (gg.GROUP_TYPE in (1,2))
												    )
  where (
        (1=1)
    and ((@clientID            is null) or (t1.CLIENT_ID                   = @clientID))
    and ((@groupSvcClassNameID is null) or (t1.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
    and ((@active              is null) or (t1.active                      = @active))
    and ((@recID               is null) or (t1.ORP_DOCUMENT_ID             = @recID))
	and ((@refID               is null) or (t1.id                          = @refID))
  )
)
,
cte_ad_p2
as
(
  select 
    p1.* 
   , lastApprovalExpirationState = case 
	      when (p1.lastApprovalExpiresInDays < 0)                then 3
		  when (p1.lastApprovalExpiresInDays between 0 and 30 )  then 2
		  when (p1.lastApprovalExpiresInDays > 30 )              then 1
		  else 0
	end		 
  from cte_ad_p1 as p1
)
,
cte_ad_p3
as
(
  select 
     p2.*
   , lastApprovalExpirationMessage = case 
	   when (p2.lastApprovalExpirationState = 3)  then 'Expired For ' + convert(varchar,abs(lastApprovalExpiresInDays)) + ' days' 
	   when (p2.lastApprovalExpirationState = 2)  then 'Expiring In ' + convert(varchar,lastApprovalExpiresInDays)      + ' days'
       when (p2.lastApprovalExpirationState = 1)  then 'Current'
	   when (p2.lastApprovalExpirationState = 0)  then 'Not Yet Signed or Pending Signature/Authorization'	
	   
	   /* Was : Not Signed or Pending E-Authorization */
   end

  from cte_ad_p2 as p2
)
,

/*###########################################################################
  # Individual Orders and Prescriptions
  ###########################################################################*/  

cte_op
as
(
select     
     t2.GROUP_SERVICE_CLASS_PARTITION_ID
   , t2.GROUP_SERVICE_CLASS_NAME_ID
   , [SVCE_NAME]      = t2.svcName
   , CLIENT_ID        = t2.clientID 
   , PATIENT_ID       = t2.patID
   , START_DATE       = t2.effectiveDate
   , END_DATE         = isnull(t2.endDate,convert(date,dbo.CONST_MAX_DATETIME()))
   , DIAGNOSIS        = ''
   , MD_ORDERS        = ''
   , ORP_PRAC_ID      = t2.orpPracID
   , ORP_ORDERS       = isnull(t2.svcDesc,'')
   , ADDITIONAL_INFO  = ''

   , SVC_NOTE_TEMPLATE_TITLE = t2.svcName
   , SVC_NOTE_TEMPLATE_TEXT  = dbo.BUILD_NOTE_TEMPLATE_TEXT (   t2.svcName
                                                              , t2.effectiveDate
                                                              , t2.endDate   
                                                              , t2.noteCrit1 
                                                              , t2.noteCrit2 
                                                              , t2.noteCrit3
                                                              , t2.noteCrit4 )
  
   , SVC_NOTE_CRITERIA_FORM_QUESTIONS_JSON = dbo.BUILD_NOTE_CRITERIA_FORM_QUESTIONS_JSON (
																					 t2.noteCrit1
																				   , t2.noteCrit2
																				   , t2.noteCrit3
																				   , t2.noteCrit4
																				   , t2.noteCrit5
																				   , t2.noteCrit6
																				   , t2.noteCrit7
																				   , t2.noteCrit8
																				   , t2.noteCrit9
																				   , t2.noteCrit10 )
   , CREATED          = t2.created
   , CREATED_BY       = t2.createdBy
   , LAST_MODIFIED    = t2.lastModified
   , LAST_MODIFIED_BY = t2.lastModifiedBy
   , ACTIVE           = t2.active
  
   , ORP_DOC_ID       = t2.ORP_DOCUMENT_ID
   , REFERENCE_ID     = t2.id
   , t2.formBuilderQuestionsJSON
   , t2.formBuilderAnswersJSON  
   , detailsTrainingPracsJSON   = td2.details
   , orderProfilePracIDsStr     = t2.pracIDsStr

   , orderContextFieldName = isnull(t2.orderContextFieldName,'')
   , allowMultipleOrders   = isnull(t2.allowMultipleOrders,0)
   , svcDesc               = isnull(t2.svcDesc,'')
   , expectedOutcomes      = ''
   , noteCrit1          = isnull(t2.noteCrit1,'')
   , noteCrit2          = isnull(t2.noteCrit2,'')
   , noteCrit3          = isnull(t2.noteCrit3,'')
   , noteCrit4          = isnull(t2.noteCrit4,'')
   , noteCrit5          = isnull(t2.noteCrit5,'')
   , noteCrit6          = isnull(t2.noteCrit6,'')
   , noteCrit7          = isnull(t2.noteCrit7,'')
   , noteCrit8          = isnull(t2.noteCrit8,'')
   , noteCrit9          = isnull(t2.noteCrit9,'')
   , noteCrit10         = isnull(t2.noteCrit10,'')
   , noteObsvCmnt        = isnull(t2.noteObsvCmnt,'')
   , noteTemplateTitle  = t2.svcName
   , noteTemplateText   = dbo.BUILD_NOTE_TEMPLATE_TEXT( t2.svcName, t2.effectiveDate, t2.endDate, t2.noteCrit1 , t2.noteCrit2 , t2.noteCrit3, t2.noteCrit4 )
   
   , iep                        = t2.iep

   , t2.frequency
   , frequencyName = ssf.[name]
   , t2.projectedMinutes
   , t2.planStartDate
   , planStartDateStr	= dbo.RPT_DATE_FMT(t2.planStartDate)
   , planStartDateStrYMD	= dbo.RPT_DATE_FMT_YYYY_MM_DD(t2.planStartDate)
   , t2.planEndDate
   , planEndDateStr		= dbo.RPT_DATE_FMT(t2.planEndDate)
   , planEndDateStrYMD	= dbo.RPT_DATE_FMT_YYYY_MM_DD(t2.planEndDate)

   , dailyFreq                  = t2.dailyFreq
   , siteAide                   = null
   , busAide                    = null
   , createdOrModified          = isnull(t2.lastModified,t2.created)
  
  from dbo.SvcJournal_Prescribed_Orders as t2

  left join dbo.SpEd_Service_Frequency as ssf on ssf.codeValue = t2.frequency

  outer apply (
      select top 1 td1.* 
      from dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON (t2.id) as td1
  ) as td2
   
  where (
        (1=1)
    /* Optimized for index : [CLIENT_ID_PATID_EFF_DATE_IDX] */
	and ((@clientID            is null) or (t2.clientID                    = @clientID))
    and ((@groupSvcClassNameID is null) or (t2.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
    and ((@patID               is null) or (t2.patID                       = @patID))
    and ((@active              is null) or (t2.active                      = @active))
	and ((@recID               is null) or (t2.ORP_DOCUMENT_ID             = @recID))
  	and ((@refID               is null) or (t2.id                          = @refID))
  )  

)
,

/*###########################################################################
  # Individual Patient Profiles
  ###########################################################################*/  

cte_pp
as
(
  select      
     t3.GROUP_SERVICE_CLASS_PARTITION_ID
   , t3.GROUP_SERVICE_CLASS_NAME_ID
   , [SVCE_NAME]      = '1:1 Accompany and Monitoring'
   , CLIENT_ID        = t3.clientID 
   , PATIENT_ID       = t3.patID
   , START_DATE       = t3.effectiveDate
   , END_DATE         = convert(date,dbo.CONST_MAX_DATETIME())
   , DIAGNOSIS        = isnull(t3.diagnosis,'')
   , MD_ORDERS        = isnull(t3.mdOrders,'')
   , ORP_PRAC_ID      = t3.orpPracID
   , ORP_ORDERS       = isnull(t3.serviceDescription,'')
   , ADDITIONAL_INFO  = isnull(t3.serviceDescription,'')

   , SVC_NOTE_TEMPLATE_TITLE = ''
   , SVC_NOTE_TEMPLATE_TEXT  = ''
   , SVC_NOTE_CRITERIA_FORM_QUESTIONS_JSON = ''
   , CREATED          = t3.created
   , CREATED_BY       = t3.createdBy
   , LAST_MODIFIED    = t3.lastModified
   , LAST_MODIFIED_BY = t3.lastModifiedBy
   , ACTIVE           = t3.active
   
   , ORP_DOC_ID       = t3.ORP_DOCUMENT_ID
   , REFERENCE_ID     = t3.id
   , t3.formBuilderQuestionsJSON
   , t3.formBuilderAnswersJSON  
   , detailsTrainingPracsJSON   = td2.details
   , orderProfilePracIDsStr     = t3.pracIDsStr

   , orderContextFieldName      = isnull(t3.orderContextFieldName,'')   
   , allowMultipleOrders        = isnull(t3.allowMultipleOrders,0)     
   , svcDesc                    = isnull(t3.serviceDescription,'')
   , expectedOutcomes           = isnull(t3.expectedOutcomes,'')
   , noteCrit1			        = ''
   , noteCrit2			        = ''
   , noteCrit3			        = ''
   , noteCrit4			        = ''
   , noteCrit5			        = ''
   , noteCrit6			        = ''
   , noteCrit7			        = ''
   , noteCrit8 		            = ''
   , noteCrit9			        = ''
   , noteCrit10		            = ''
   , noteObsvCmnt		        = ''
   , noteTemplateTitle          = ''
   , noteTemplateText           = ''
   
   , iep                        = t3.iep

   , t3.frequency
   , frequencyName = ssf.[name]
   , t3.projectedMinutes
   , t3.planStartDate
   , planStartDateStr		= dbo.RPT_DATE_FMT(t3.planStartDate)
   , planStartDateStrYMD	= dbo.RPT_DATE_FMT_YYYY_MM_DD(t3.planStartDate)
   , t3.planEndDate
   , planEndDateStr			= dbo.RPT_DATE_FMT(t3.planEndDate)
   , planEndDateStrYMD		= dbo.RPT_DATE_FMT_YYYY_MM_DD(t3.planEndDate)

   , dailyFreq                  = null
   , t3.siteAide
   , t3.busAide
   , createdOrModified          = isnull(t3.lastModified,t3.created)

  from dbo.SvcJournal_Service_Descriptions as t3
  
  left join dbo.SpEd_Service_Frequency as ssf on ssf.codeValue = t3.frequency

  cross apply (
      select top 1 td1.* 
      from dbo.SvcJournal_View_Service_Description_Prac_Training_Details_JSON (t3.id) as td1
  ) as td2 
    
  where (
        (1=1)    
   
    /* Optimized for index : [CLIENT_ID_PAT_ID_EFF_DATE] */

    and ((@clientID            is null) or (t3.clientID                 = @clientID))
    and ((@groupSvcClassNameID is null) or (t3.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
    and ((@patID               is null) or (t3.patID                    = @patID))
    and ((@active              is null) or (t3.active                   = @active))
	and ((@recID               is null) or (t3.ORP_DOCUMENT_ID          = @recID))
	and ((@refID               is null) or (t3.id                       = @refID))

  )
)
,
cte_op_pp_p1
as
(
    select t1.* from cte_op as t1
    union all
    select t2.* from cte_pp as t2
)
,
cte_op_pp_p2
as
(
  select 
     p1.*
   , pracsTrainingRecID = pt.recID
   , pt.pracIDsStr
   , pt.pracNamesStr
   , pt.pracTitlesStr
  
   , displayLastApproval = convert(bit,(case when (auth.lastApprovalEffectiveDateStr is null) then 0 else 1 end))
   , hasLastApproval     = convert(bit,(case when (auth.lastApprovalOrpPracID is null or auth.lastApprovalExpirationState = 0) then 0 else 1 end))
   , auth.lastApprovalOrpPracID
   , auth.lastApprovalOrpName 
   , auth.lastApprovalOrpTitle
   , auth.lastApprovalOrpNPI
   , auth.lastApprovalEffectiveDate
   , auth.lastApprovalEffectiveDateStr
   , auth.lastApprovalExpirationDate
   , auth.lastApprovalExpirationDateStr
   , auth.lastApprovalExpiresInDays
   , auth.lastApprovalOrpIsValidMcalOrp
   , auth.lastApprovalOrpIsValidMcalOrpStr

   , lastApprovalExpirationState   = isnull(auth.lastApprovalExpirationState, 0)
   , lastApprovalExpirationMessage = isnull(auth.lastApprovalExpirationMessage,'Not Yet Signed or Pending Signature/Authorization')	   
  
  /* Was : Not Signed or Pending E-Authorization */
  
  from cte_op_pp_p1 as p1
  
  outer apply (    
      select top 1 
	    pt1.* 
      from dbo.SvcJournal_Prac_Training_Parse_PracIDs (  p1.CLIENT_ID
                                                       , p1.orderProfilePracIDsStr
                                                       , p1.REFERENCE_ID ) as pt1
  ) as pt
  
  outer apply (
	 select top 1
	      la.*
	 from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED (null,null,null, @clientID, p1.ORP_DOC_ID) as la
  ) as auth
  
  
) 
,
cte_out_p1
as
(
  select t1.* from cte_ad_p3    as t1
  union all
  select t2.* from cte_op_pp_p2 as t2
)
,
cte_out_p2
as
(
  select   
      od.ID
	, ORP_DOCUMENT_ID = od.ID
    , od.ORP_DOCUMENT_TYPE_ID
    , ORP_DOCUMENT_TYPE_NAME = odt.NAME
    , od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
	, ORP_DOCUMENT_STANDARD_SELECTION_NAME = dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME (  p1.allowMultipleOrders
	                                                                                                        , odssn.NAME 
	                                                                                                        , p1.orderContextFieldName
	                                                                                                        , p1.formBuilderAnswersJSON )
    , ORP_DOCUMENT_STANDARD_SELECTION_NOTES = isnull(odssn.NOTES,'')
    , gsn.GROUP_SERVICE_CLASS_NAME
    , p1.*
	, iepYN                      = dbo.RPT_BIT_TO_YNB (p1.iep)
	, siteAideYN = dbo.RPT_BIT_TO_YNB(p1.siteAide)
    , busAideYN = dbo.RPT_BIT_TO_YNB(p1.busAide)
	, orderContextFieldValue  = dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_EXTRACT_CONTEXT_FIELD_VALUE (  p1.allowMultipleOrders , p1.orderContextFieldName, p1.formBuilderAnswersJSON )        
	, svcDescOrFormBuilderHtml   = dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML_OR_ALTERNATE_TEXT (  p1.formBuilderQuestionsJSON
								                                                          , p1.formBuilderAnswersJSON
																   		                  , 1
																			              , 0
																			              , 1
																			              , 0
																						  , 0
																						  , 0
																					      , p1.ORP_ORDERS)
  
   , startDateStr         = dbo.RPT_DATE_FMT(p1.START_DATE)
   , endDateStr           = dbo.RPT_DATE_FMT(p1.END_DATE)
   , createdStr           = dbo.RPT_DATE_FMT(p1.CREATED)
   , lastModifiedStr      = dbo.RPT_DATE_FMT(p1.LAST_MODIFIED)
   , activeStr            = dbo.RPT_BIT_TO_YN(p1.active)
   , createdOrModifiedStr = dbo.RPT_DATE_FMT(p1.createdOrModified)

  from      cte_out_p1                                as p1
  join      dbo.ORP_DOCUMENTS                         as od    on od.ID                    = p1.ORP_DOC_ID
  join      dbo.ORP_DOCUMENT_TYPES                    as odt   on odt.ORP_DOCUMENT_TYPE_ID = od.ORP_DOCUMENT_TYPE_ID
  join      dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as odssn on odssn.ID                 = od.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
  join      dbo.GROUP_GROUP_SERVICE_CLASS_NAMES       as gsn   on gsn.GROUP_SERVICE_CLASS_NAME_ID = p1.GROUP_SERVICE_CLASS_NAME_ID
   
  where 
        (1=1)
    and ((@dos is null) or (@dos between p1.START_DATE and p1.END_DATE))
    
)

select 
   p2.* 
 , [viewSelContext1] =                      
					  'Authorization Status : ' + p2.lastApprovalExpirationMessage
					 + iif((p2.hasLastApproval = 1)
					 , ' | Last Authorized By : ' + isnull(p2.lastApprovalOrpName,'')			   
					   + ' (NPI # ' + isnull(p2.lastApprovalOrpNPI,'') +')'
                     , '')
 , createdByUserName = cbu2.userName
 
from cte_out_p2 as p2

outer apply (
  select top 1 
    cbu1.userName
  from users.dbo.USERS_ALL as cbu1 
  where (cbu1.id = p2.CREATED_BY)
) as cbu2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ORP_DOCUMENTS_DATA_CORE] TO [webuser]
GO  
