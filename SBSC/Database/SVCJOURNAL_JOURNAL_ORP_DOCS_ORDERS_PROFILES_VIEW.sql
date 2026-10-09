USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW] (
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
  , @orpApprovalState       bigint
  , @recID                  BIGINT
  , @active                 BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

select top (dbo.CONST_MAX_ROWS()) 
  t1.* 
from dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE (
    @userID    
  , @userGroup 
  , @userRank  
  , @clientID  
  , @pracID  
  , dbo.GET_ORP_SVC_CLASS_NAME_ID_FROM_MULTI(@groupSvcClassNameID, null, @pracID) 
  , @patID    
  , @referenceDate 
  , @startRefDate  
  , @endRefDate  
  , @maxRow  
  , @orpApprovalState
  , @recID  
  , @active 
) as t1

order by 
    t1.clientID
  , t1.patName

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW] TO [webuser]
GO  
