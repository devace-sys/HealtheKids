USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE] (
    @userID                BIGINT
  , @userGroup             INT  
  , @userRank              INT      
  , @clientID              BIGINT
  , @groupSvcClassNameID   BIGINT
  , @patID                 BIGINT
  , @referenceDate         DATE
  , @startRefDate          DATE
  , @endRefDate            DATE
  , @maxRow                INT
  , @recID                 BIGINT
  , @active                BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE */    
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
	 , refDateStart = t1.effectiveDate
	 , refDateEnd   = isnull(t1.endDate,dateadd(year,20,t1.effectiveDate)) /* Default to effective date + 20 years */
     , t2.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID as orpDocStdNameID
	 , orpDocStdName = dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAME_BUILD_SELECTION_NAME (  t1.allowMultipleOrders
	                                                                                  , t3.NAME 
	                                                                                  , t1.orderContextFieldName
	                                                                                  , t1.formBuilderAnswersJSON )
    from dbo.SvcJournal_Prescribed_Orders          as t1
    join dbo.ORP_DOCUMENTS                         as t2 on t2.ID = t1.ORP_DOCUMENT_ID
    join dbo.ORP_DOCUMENT_STANDARD_SELECTION_NAMES as t3 on t3.ID = t2.ORP_DOCUMENT_STANDARD_SELECTION_NAME_ID

    where (
          (1=1)
      and ((@clientID            is null) or (t1.clientID = @clientID))
      and ((@patID               is null) or (t1.patID                       = @patID))
      and ((@recID               is null) or (t1.id                          = @recID))
      and ((@groupSvcClassNameID is null) or (t1.GROUP_SERVICE_CLASS_NAME_ID = @groupSvcClassNameID))
	  and ((@active              is null) or (t1.active   = @active))

    )
  )
  ,  
  cte_p2
  as
  (
    select 
      p1.*    
    from cte_p1 as p1
    where (
           (1=1)
      and ((@referenceDate is null) or (@referenceDate between refDateStart and refDateEnd))
      and ((@startRefDate is null)  or (effectiveDate >= @startRefDate))
      and ((@endRefDate is null)    or (effectiveDate <= @endRefDate))
    )
  )
  ,
  cte_p3
  as
  (
    select 
      p2.*    
      , noteTemplateTitle      = svcName
      , noteTemplateText       = dbo.BUILD_NOTE_TEMPLATE_TEXT(  svcName
                                                              , effectiveDate
                                                              , endDate   
                                                              , noteCrit1 
                                                              , noteCrit2 
                                                              , noteCrit3
                                                              , noteCrit4 )
    from cte_p2 as p2   
  )
  ,
  cte_p4
  as
  (
      select 
         id           
       , clientID
       , patID
       , effectiveDate
	  , endDate
	  , svcName
	  , orpDocStdNameID
      , orpDocStdName 
	  , svcDesc            = isnull(svcDesc,            '')
	  , noteCrit1          = isnull(noteCrit1,          '')
	  , noteCrit2          = isnull(noteCrit2,          '')
	  , noteCrit3          = isnull(noteCrit3,          '')
	  , noteCrit4          = isnull(noteCrit4,          '')
	  , noteObsvCmnt       = isnull(noteObsvCmnt,       '')
       , noteTemplateTitle
       , noteTemplateText
       , iep
       , iepYN              = dbo.RPT_BIT_TO_YNB(iep)
       , dailyFreq
       , pt.*
       , detailsTrainingPracsJSON = td.details
       , orpPracID 
       , orpPracName                = isnull(orp.CONCAT_NAME,'')
       , orpNPI                     = isnull(orp.npiNumber,'')
       , orpIsValidMcalOrp          = dbo.RPT_BIT_TO_YNU(orp.isValidMcalOrp)
       , groupServiceClassNameID    = p3.GROUP_SERVICE_CLASS_NAME_ID
       , groupServiceClassNameName  = isnull(scn.GROUP_SERVICE_CLASS_NAME,'')
       , created
       , createdBy      
       , lastModified
       , lastModifiedBy
	   , p3.active
       , orpDocID = p3.ORP_DOCUMENT_ID
	   , allowMultipleOrders
	   , orderContextFieldName
	   , formBuilderQuestionsJSON
	   , formBuilderAnswersJSON

    from cte_p3 as p3
    
    join      dbo.GROUP_GROUP_SERVICE_CLASS_NAMES as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = p3.GROUP_SERVICE_CLASS_NAME_ID   
    left join dbo.PRACTITIONER_Practitioner       as orp on orp.PRACTITIONER_ID             = p3.orpPracID    
    
    outer apply (    
      select top 1 * 
      from dbo.SvcJournal_Prac_Training_Parse_PracIDs (  p3.clientID
                                                       , p3.pracIDsStr
                                                       , p3.id )    
    ) as pt
        
    outer apply (
      select top 1 * 
      from dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON (p3.id)
    ) as td
    
  )
  ,
  cte_p5
  as
  (
    select 
       p4.* 
	 , hasLastApproval = convert(bit,(case when (cas.lastApprovalOrpPracID is null or cas.lastApprovalExpirationState = 0) then 0 else 1 end))
	 , cas.*
   from cte_p4 as p4    
   outer apply (
     select top 1 
	    vla.*
     from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_LAST_APPROVED (@userID, @userGroup, @userRank, p4.clientID, p4.orpDocID ) as vla
    ) as cas  
  )      
  select top (isnull(@maxRow,dbo.CONST_MAX_ROWS()))
    p5.* 
  from cte_p5 as p5
  order by 
      clientID      asc
    , patID         asc
    , effectiveDate desc
    , svcName       desc
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW_CORE] TO [webuser]
GO  
