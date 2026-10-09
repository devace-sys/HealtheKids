USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW] (
    @userID               bigint
  , @userGroup            int  
  , @userRank             int 
  , @clientID             bigint
  , @taskID	              bigint
  , @isPending            bit
  , @isNotCompleted       bit
  , @isCompleted          bit
  , @active               bit
  , @recID                bigint

  , @fyID     bigint
  
)    

RETURNS TABLE
AS RETURN

select 
  ccci.* 

from dbo.CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW_CORE (
	  @clientID  
	, @taskID	   
	, @isPending     
    , @isNotCompleted
    , @isCompleted   
	, @active    
	, @recID

        , @fyID
      
     
) as ccci

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_COMPLIANCE_CLIENT_ITEMS_VIEW] TO [webuser]
GO  
