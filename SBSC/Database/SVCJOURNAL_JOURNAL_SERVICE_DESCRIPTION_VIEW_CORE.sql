USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE] (
    @userID            BIGINT
  , @userGroup         INT  
  , @userRank          INT      
  , @clientID          BIGINT
  , @patID             BIGINT
  , @referenceDate     DATE
  , @maxRow            INT
  , @recID             BIGINT
  , @active            BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  with
  cte_p1
  as
  (
    select 
        t1.*
      , refDate = isnull(@referenceDate,convert(date,getdate()))
      , t2.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID as orpDocStdNameID
	  , orpDocStdName = dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME (  t1.allowMultipleOrders
	                                                                                  , t3.NAME 
	                                                                                  , t1.orderContextFieldName
	                                                                                  , t1.formBuilderAnswersJSON )

    from dbo.SvcJournal_Service_Descriptions as t1
	join dbo.ORP_DOCUMENTS                         as t2 on t2.ID = t1.ORP_DOCUMENT_ID
    join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as t3 on t3.ID = t2.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID
    where (
          (1=1)
      and ((@clientID is null) or (t1.clientID  = @clientID))
      and ((@patID    is null) or (t1.patID     = @patID))
      and ((@recID    is null) or (t1.id        = @recID))
	  and ((@active   is null) or (t1.active    = @active))
      and (t1.effectiveDate <= isnull(@referenceDate,convert(date,getdate())))
    )
    

  )
  ,
  cte_p2
  as
  (
    select
        id           
      , clientID
      , patID
      , effectiveDate
      , diagnosis          = isnull(diagnosis,          '')
      , mdOrders           = isnull(mdOrders,           '')
      , serviceDescription = isnull(serviceDescription, '')
      , expectedOutcomes   = isnull(expectedOutcomes,   '')
      , effRefDiff         = datediff(day,effectiveDate,refDate) 
      , refDate
      , iep
      , iepYN              = dbo.RPT_BIT_TO_YNB (iep)
      , siteAide    
      , siteAideYN         = dbo.RPT_BIT_TO_YNB (siteAide)
      , busAide
      , busAideYN          = dbo.RPT_BIT_TO_YNB (busAide)
      , pt.*
      , detailsTrainingPracsJSON = td.details 
      , p1.orpPracID
      , orpPracName = isnull(orp.CONCAT_NAME,'')
      , orpNPI                     = isnull(orp.npiNumber,'')
      , orpIsValidMcalOrp          = dbo.RPT_BIT_TO_YNU(orp.isValidMcalOrp)
      , created
      , createdBy      
      , lastModified
      , lastModifiedBy
	  , p1.active
	  , orpDocID = p1.ORP_DOCUMENT_ID
	  , allowMultipleOrders
	  , orderContextFieldName
	  , formBuilderQuestionsJSON
	  , formBuilderAnswersJSON
    from cte_p1 as p1
    
    left join dbo.PRACTITIONER_Practitioner as orp on orp.PRACTITIONER_ID = p1.orpPracID

    outer apply (
    
      select top 1 * 
      from dbo.SvcJournal_Prac_Training_Parse_PracIDs (  p1.clientID
                                                       , p1.pracIDsStr
                                                       , p1.id )    
    ) as pt
  
    outer apply (
      select top 1 * 
      from dbo.SvcJournal_View_Service_Description_Prac_Training_Details_JSON(p1.id)
    ) as td
  
  )
  ,   
  cte_p3
  as
  (
    select 
       p2.* 
	 , hasLastApproval = convert(bit,(case when (cas.lastApprovalOrpPracID is null or cas.lastApprovalExpirationState = 0) then 0 else 1 end))	 
	 , cas.*
   from cte_p2 as p2
   outer apply (
     select top 1 
	    vla.*
     from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED (@userID, @userGroup, @userRank, p2.clientID, p2.orpDocID ) as vla
    ) as cas  
  )      
  
  select top (isnull(@maxRow,dbo.CONST_MAX_ROWS()))   
    p3.*      
  from cte_p3 as p3
  order by 
        clientID      asc
      , patID         asc
      , effectiveDate desc
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_SERVICE_DESCRIPTION_VIEW_CORE] TO [webuser]
GO  
