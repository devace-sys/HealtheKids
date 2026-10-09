USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW] (
    @userID                   as BIGINT
  , @userGroup                as INT  
  , @userRank                 as INT      
  , @clientID                 as BIGINT
  , @journalID                as BIGINT
  , @pracID			          as BIGINT
  , @patID			          as BIGINT
  , @isDefault                as BIT
  , @noteNamespace            as VARCHAR(500)
  , @noteSource               as VARCHAR(500)
  , @groupSvcClassNameID      as BIGINT
  , @includeOnlyOrpDocTypeIDs as VARCHAR(8000)
  , @displayRank              as BIGINT
  , @refID                    as BIGINT
  , @orpDocTypeID             as int
  , @dos                      as Date
  , @groupID                  as BIGINT
  , @term			          as VARCHAR(255) 
  , @includeOrders            as bit = 1
  , @includeEvents            as bit = 1  
  , @active                   as BIT
  , @recID                    as BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW */    
 /**    
  * Returns a list of open journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
	select top (dbo.CONST_MAX_ROWS())
		t1.*
	from [dbo].[SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW_CORE] (
		@userID                  
	  , @userGroup               
	  , @userRank                
	  , @clientID                
	  , @journalID               
	  , @pracID			         
	  , @patID			         
	  , @isDefault               
	  , @noteNamespace           
	  , @noteSource              
	  , @groupSvcClassNameID     
	  , @includeOnlyOrpDocTypeIDs
	  , @displayRank             
	  , @refID                   
	  , @orpDocTypeID            
	  , @dos 
	  , @groupID                    
	  , @term		
	  , @includeOrders 
      , @includeEvents 	         
	  , @active                  
	  , @recID                   
	) as t1 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_EVENTS_AND_PAT_ORDERS_VIEW] TO [webuser]
GO  
