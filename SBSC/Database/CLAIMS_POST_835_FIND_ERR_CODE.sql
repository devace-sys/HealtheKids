USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_POST_835_FIND_ERR_CODE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_POST_835_FIND_ERR_CODE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLAIMS_POST_835_FIND_ERR_CODE] ( @Short_Err as varchar(15) )
RETURNS BIGINT 
AS     
BEGIN    
  declare @errorID as bigint = null    
  select top 1 @errorID = Error_ID from dbo.Claim_Claim_Posting_Errorcodes where Short_Err = @Short_Err
  return @errorID       
END    
GO
