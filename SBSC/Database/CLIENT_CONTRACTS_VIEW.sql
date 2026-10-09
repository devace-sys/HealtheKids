USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_CONTRACTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_CONTRACTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_CONTRACTS_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @active              BIT 
  , @recID               BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * CLIENT_CONTRACTS_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN

select top (dbo.CONST_MAX_ROWS())
	  [id]
	, clientID        
	, contractNumber
	, startDate
	, endDate
	, convert(varchar, startDate, 23) as startDateStr
	, convert(varchar, endDate, 23)   as endDateStr      
	, contractTypeID   
	, feeStructureID        
	, additionalFeeAnswersJSON

from [dbo].[CLIENTS_Contracts]
where clientID = @clientID
  and ((@active is null) or (active = @active))
  and ((@recID  is null) or ([id]   = @recID))

order by startDate desc

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_CONTRACTS_VIEW] TO [webuser]
GO  
