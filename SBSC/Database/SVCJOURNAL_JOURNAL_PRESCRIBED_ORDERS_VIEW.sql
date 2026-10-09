USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW] (
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
  , @recID                  BIGINT
  , @active                 BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  
  select 
      sjpo.* 
    , clientName               = cc.CLIENT_NAME
    , patName                  = pp.CONCAT_NAME
    , effectiveDateStr         = dbo.RPT_DATE_FMT(sjpo.effectiveDate)
    , endDateStr               = dbo.RPT_DATE_FMT(sjpo.endDate)
    , createdStr               = dbo.RPT_DATE_FMT(sjpo.created)
    , lastModifiedStr          = dbo.RPT_DATE_FMT(sjpo.lastModified)
    , createdByUserName        = isnull(ucb.UserName,'')
    , lastModifiedByUserName   = isnull(umb.UserName,'') 
	, displayLastApproval      = convert(bit,(case when (sjpo.lastApprovalEffectiveDateStr is null) then 0 else 1 end))
    , svcDescOrFormBuilderHtml = dbo.FORM_BUILDER_JSON_QA_DATA_TO_HTML_OR_ALTERNATE_TEXT (  sjpo.formBuilderQuestionsJSON
									                                                      , sjpo.formBuilderAnswersJSON
																	   		              , 1
																			              , 0
																			              , 1
																			              , 0
																						  , 0
																						  , 0
																					      , sjpo.svcDesc)
	  
  from dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE (   @userID
                                                            , @userGroup
                                                            , @userRank
                                                            , @clientID
                                                            , dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI(
                                                                @groupSvcClassNameID
                                                              , null
                                                              , @pracID)
                                                            , @patID
                                                            , @referenceDate
                                                            , @startRefDate
                                                            , @endRefDate
                                                            , @maxRow
                                                            , @recID
															, @active ) as sjpo
                                                              
  join dbo.PATIENTS_PATIENT   as pp   on pp.PATIENT_ID = sjpo.patID 
  join dbo.CLIENTS_Client     as cc   on cc.CLIENT_ID  = sjpo.clientID  
 
  left join users.dbo.Users   as ucb  on ucb.userrid   = sjpo.createdBy
  left join users.dbo.Users   as umb  on umb.userrid   = sjpo.lastModifiedBy
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW] TO [webuser]
GO  
