USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_CURRENT_AND_EXPIRING_ORDERS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RPT_CURRENT_AND_EXPIRING_ORDERS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RPT_CURRENT_AND_EXPIRING_ORDERS] (
    @userID                 BIGINT
  , @userGroup              INT  
  , @userRank               INT      
  , @clientID               BIGINT  
)    

RETURNS TABLE
 
 /***************************************************************************    
  * RPT_CURRENT_AND_EXPIRING_ORDERS */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select top (dbo.CONST_MAX_ROWS())
    q1.*
  from 
  (
    select 
      t1.*  
    from dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE (
        @userID              
      , @userGroup          
      , @userRank               
      , @clientID         
      , null  -- @pracID                 BIGINT
      , null  -- @groupSvcClassNameID    BIGINT  
      , null  -- @patID                  BIGINT
      , null  -- @referenceDate          DATE
      , null  -- @startRefDate           DATE
      , null  -- @endRefDate             DATE
      , null  -- @maxRow                 INT
      , 1   -- @orpApprovalState       bigint                    
      , null  -- @recID                  BIGINT
      , 1     -- @active                 BIT
    ) as t1    

    union all
 
    select  
      t2.*
    from  dbo.SVCJOURNAL_JOURNAL_ORP_DOCS_ORDERS_PROFILES_VIEW_CORE (
        @userID              
      , @userGroup          
      , @userRank               
      , @clientID         
      , null  -- @pracID                 BIGINT
      , null  -- @groupSvcClassNameID    BIGINT  
      , null  -- @patID                  BIGINT
      , null  -- @referenceDate          DATE
      , null  -- @startRefDate           DATE
      , null  -- @endRefDate             DATE
      , null  -- @maxRow                 INT
      , 2     -- @orpApprovalState         varchar(10)  
      , null  -- @recID                  BIGINT
      , 1     -- @active                 BIT
    ) as t2 
  ) as q1
  
  order by 
    q1.lastApprovalExpirationDate ASC
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_CURRENT_AND_EXPIRING_ORDERS] TO [webuser]
GO  
