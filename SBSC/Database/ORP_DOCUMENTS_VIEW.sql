USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ORP_DOCUMENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ORP_DOCUMENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[ORP_DOCUMENTS_VIEW] (
    @userID                    BIGINT
  , @userGroup                 INT  
  , @userRank                  INT 
  , @clientID                  BIGINT
  , @rdrPracID                 BIGINT
  , @rdrGroupSvcClassNameID    BIGINT  
  , @patID                     BIGINT
  , @dos                       DATE
  , @term                      VARCHAR(255)  
  , @orpDocTypeID              INT
  , @refID                     BIGINT
  , @includeOnlyOrpDocTypeIDs  VARCHAR(8000)
  , @displayRank               BIGINT
  , @active                    BIT 
  , @recID                     BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * ORP_DOCUMENTS_VIEW */    
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
	  , dbo.RPT_DATE_FMT(t1.patDOB)                  as patDOBStr
      , dbo.RPT_BIT_TO_YNU(t1.orpPracIsValidMcalOrp) as orpPracIsValidMcalOrpStr
      , dbo.RPT_BIT_TO_YNU(t1.orpPracIsReadyFor837)  as orpPracIsReadyFor837Str
      
    from dbo.ORP_DOCUMENTS_VIEW_CORE (  @userID
                                      , @userGroup
                                      , @userRank
                                      , @clientID
                                      , dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI(
                                            @rdrGroupSvcClassNameID
                                          , null
                                          , @rdrPracID)
                                      , @patID
                                      , @dos
                                      , @orpDocTypeID
                                      , @refID 
                                      , @active
                                      , @recID) as t1    
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
     and (@includeOnlyOrpDocTypeIDs is null) or (p1.orpDocTypeID in (select recid as orpDocTypeID from dbo.MULTI_RECORD_ID_PARSE(isnull(@includeOnlyOrpDocTypeIDs,''),',')))
    )
  )
  ,
  cte_p3
  as
  (
    select 
       p2.*       
    from cte_p2 as p2
    where (
          (1=1) 
      and ((@displayRank is null) or (displayRank = @displayRank))
    )
  )
  , 
  cte_p4
  as
  (
    select 
       p3.*      
     , clc.CLIENT_NAME as clientName     
    from cte_p3             as p3
    join dbo.CLIENTS_CLIENT as clc on clc.CLIENT_ID = p3.clientID
    where ( 
         (1=1)
     and ((@term is null)  
     or (
          (p3.name           like '%' + @term + '%') /* Standard name search */
       or (p3.notes          like '%' + @term + '%') /* Keyword search */
       or (p3.description    like '%' + @term + '%') 
       or (p3.additionalInfo like '%' + @term + '%')
     )
    )   
   )
  )  
  select top (dbo.CONST_MAX_ROWS()) 
    p4.*   
  from cte_p4 as p4
  order by 
      p4.clientName
    , p4.patName
    , p4.startDate
    , p4.endDate    
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ORP_DOCUMENTS_VIEW] TO [webuser]
GO  
