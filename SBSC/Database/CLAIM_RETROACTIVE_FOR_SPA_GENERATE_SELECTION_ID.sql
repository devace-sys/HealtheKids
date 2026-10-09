USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID](
    @forSpaID    bigint
  , @clientID    bigint
  , @fyID        bigint
  , @pracID      bigint
  , @isIFSPorIEP bit
  , @groupID     bigint
  , @nameID      bigint
) 
RETURNS varchar(8000) 
AS    
BEGIN    
  return convert(varchar(8000),CONCAT_WS ( '-',@forSpaID,@clientID,@fyID,@pracID,@isIFSPorIEP,@groupID,@nameID))

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLAIM_RETROACTIVE_FOR_SPA_GENERATE_SELECTION_ID] TO [webuser]
GO