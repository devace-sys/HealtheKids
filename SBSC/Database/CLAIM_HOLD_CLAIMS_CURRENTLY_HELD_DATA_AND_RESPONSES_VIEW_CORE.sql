USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE] (    
     @userID			  bigint
   , @userGroup			  int  
   , @userRank			  int
   , @clientID			  bigint
   , @pracID			  bigint
   , @groupSvcClassNameID bigint
   , @patID               bigint
   , @plrClassCode        int
   , @deferred            bit
)
     
RETURNS TABLE

/***************************************************************************    
 * CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE */    
/**    
 * Returns held claims data with user's responses if any
 *      
 ***************************************************************************/     

AS RETURN(

  select     
      chc.*
	, chcr.DEFER
	, chcr.NOTES
	, hc.HOLD_REASON
	, hc.INSTRUCTIONS
  from dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA as chc
  left join dbo.CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_ACTIONABLE_REPORT_DATA_RESPONSES as chcr on 
	    chcr.PLR_ID_STRING = chc.PLR_ID_STRING
  
  left join dbo.CLAIM_HOLD_CODES    as hc on hc.HOLD_CODE = chc.HOLD_CODE
  where (
   (1=1)     
    and ((@clientID			   is null) or (chc.CLIENT_ID            = @clientID))    
	and ((@pracID			   is null) or (chc.PRAC_ID              = @pracID))
	and ((@groupSvcClassNameID is null) or (chc.PRAC_GROUP_FAMILY_ID = @groupSvcClassNameID))
	and ((@patID               is null) or (chc.PAT_ID               = @patID))
	and ((@deferred            is null) or (isnull(chcr.DEFER, 0)    = @deferred))
	and (chc.HOLD_CODE in (select holdCode from dbo.PLR_CLASSIFICATION_CLAIM_HOLD_CODES where code = @plrClassCode))
  )
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE] TO [webuser]
GO