USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENTS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[ORP_DOCUMENTS_VIEW_CORE] (
    @userID                   BIGINT
  , @userGroup                INT  
  , @userRank                 INT 
  , @clientID                 BIGINT
  , @rdrGroupSvcClassNameID   BIGINT
  , @patID                    BIGINT
  , @dos                      DATE
  , @orpDocTypeID             INT
  , @refID                    BIGINT
  , @active                   BIT 
  , @recID                    BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * ORP_DOCUMENTS_VIEW_CORE */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
 with
  
/*###########################################################################
  # Pass 1 - Get Core Data
  ###########################################################################*/  

  cte_p1
  as
  (  
    select  
        oddc.ID                                    as id   
      , oddc.CLIENT_ID                             as clientID
      , oddc.PATIENT_ID                            as patID    
      , oddc.ORP_DOCUMENT_TYPE_ID                  as orpDocTypeID 
      , oddc.ORP_DOCUMENT_TYPE_NAME                as orpDocTypeName     
      , oddc.REFERENCE_ID                          as refID
      , oddc.ORP_DOCUMENT_STANDARD_SELECTION_NAME  as name
      , oddc.ORP_DOCUMENT_STANDARD_SELECTION_NOTES as notes
      , oddc.ORP_ORDERS                            as description
      , oddc.ADDITIONAL_INFO                       as additionalInfo
      , oddc.GROUP_SERVICE_CLASS_NAME_ID           as groupServiceClassNameID 
      , oddc.GROUP_SERVICE_CLASS_NAME              as groupServiceClassNameName
      , oddc.START_DATE                            as startDate
      , oddc.END_DATE                              as endDate
      , oddc.ORP_PRAC_ID                           as orpPracID
      , oddc.SVC_NOTE_TEMPLATE_TITLE               as svcNoteTemplateTitle
      , oddc.SVC_NOTE_TEMPLATE_TEXT                as svcNoteTemplateText
	  , oddc.SVC_NOTE_CRITERIA_FORM_QUESTIONS_JSON as svcNoteCriteriaFormQuestionsJSON
      , oddc.ACTIVE                                as active
	  , oddc.lastApprovalEffectiveDateStr
	  , oddc.lastApprovalOrpName		     
	  , oddc.lastApprovalOrpNPI
	  , oddc.lastApprovalExpiresInDays
	  , oddc.lastApprovalExpirationState
      , oddc.startDateStr
	  , oddc.endDateStr
	  , [context1] = oddc.viewSelContext1
	  , oddc.iep
	  , oddc.frequency
	  , oddc.frequencyName
	  , oddc.projectedMinutes
	  , oddc.planStartDate
	  , oddc.planStartDateStr	
	  , oddc.planStartDateStrYMD
	  , oddc.planEndDate
	  , oddc.planEndDateStr		
	  , oddc.planEndDateStrYMD	
  	  , orpDocumentStandardSelectionNameID = oddc.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID

	from dbo.ORP_DOCUMENTS_DATA_CORE (  @clientID
                                      , @rdrGroupSvcClassNameID
                                      , @patID
                                      , @dos
                                      , @active
									  , @recID
									  , @refID) as oddc 
    where (
          (1=1)
      and ((@orpDocTypeID is null) or (oddc.ORP_DOCUMENT_TYPE_ID = @orpDocTypeID))
    )
  )  
  ,
  
  /*###########################################################################
    # Pass 2 - Get
    ###########################################################################*/  

  cte_p2
  as
  (
  
    select 
  
        p1.*
      , pap.LAST_NAME                       as patLastName
      , pap.FIRST_NAME                      as patFirstName
      , pap.CONCAT_NAME                     as patName
      , pap.DATE_OF_BIRTH                   as patDOB
      , isnull(pap.CSIS,'')                 as patCSIS
      , isnull(pap.BIC,'')                  as patBIC
      , p1.groupServiceClassNameID          as rdrGroupServiceClassNameID
      , p1.groupServiceClassNameName        as rdrGroupServiceClassNameName
	  
	  , prp.LAST_NAME                       as orpLastName
      , prp.FIRST_NAME                      as orpFirstName
      , prp.CONCAT_NAME                     as orpPracName
      , isnull(prp.npiNumber,'')            as orpPracNpiNumber
      , orpPracHasNpi = dbo.IS_VALID_NPI (prp.npiNumber)                  
      , prp.isValidMcalOrp                  as orpPracIsValidMcalOrp
      , prp.isValidMcalOrpLastValidated     as orpPracIsValidMcalOrpLastValidated
	  
  
	from      cte_p1                        as p1
    left join dbo.PATIENTS_Patient          as pap on pap.PATIENT_ID           = p1.patID
    left join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID      = p1.orpPracID  

  
  )
  ,
  
  /*###########################################################################
    # Pass 3
    ###########################################################################*/  

  cte_p3
  as
  (
    select 
      p2.* 
    , orpPracIsReadyFor837 = dbo.IS_ORP_COMPLIANT (1,orpPracHasNpi ,orpPracIsValidMcalOrp)
    , displayRank = case when orpDocTypeID = 3 then (row_number() over (partition by clientID, patID, orpDocTypeID order by startDate desc, active desc)) else 1 end
  from cte_p2 as p2  
  ) 
  
  /*###########################################################################
    # Output
    ###########################################################################*/  

  select 
    p3.* 
  from cte_p3 as p3

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ORP_DOCUMENTS_VIEW_CORE] TO [webuser]
GO  
