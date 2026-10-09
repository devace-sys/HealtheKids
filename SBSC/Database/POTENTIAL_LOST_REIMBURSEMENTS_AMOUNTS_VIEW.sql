USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW] (
    @clientID            BIGINT
  , @plrClassCode        INT
)    

RETURNS TABLE

AS RETURN (

	 /***************************************************************************    
	  * POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW */    
	 /**    
	  ***************************************************************************/                         
	SELECT 
		ISNULL([1], 0)     as [deferred]
	  , ISNULL([0], 0)     as [review]
	  
	FROM
	(
 
	    select 
		  CLIENT_ID
		, TOT_EST_AMT
		, ISNULL(DEFER, 0) as DEFER
		from [dbo].[CLAIM_HOLD_CLAIMS_CURRENTLY_HELD_DATA_AND_RESPONSES_VIEW_CORE] (    
			 null			  
		   , null			  
		   , null			  
		   , @clientID			  
		   , null			  
		   , null 
		   , null               
		   , @plrClassCode        
		   , null            
		)
	) datasrc
	PIVOT
	(
		SUM(TOT_EST_AMT)
		FOR DEFER IN ([1], [0])
	) pvt

)
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[POTENTIAL_LOST_REIMBURSEMENTS_AMOUNTS_VIEW] TO [webuser]
GO  
