USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIMS_TRANSMISSION_LIST_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIMS_TRANSMISSION_LIST_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].CLAIMS_TRANSMISSION_LIST_VIEW

(@clientID  AS int,
 @oldestDOS AS date,
 @newestDOS as date,
 @transmissionDate AS datetime)
 
RETURNS @final_claims TABLE (claim_id bigint) AS 

BEGIN

/***************************************************************************    
 * CLAIMS_TRANSMISSION_LIST_VIEW */    
/**    
 * 
 * 
 * 
 *
 * @param   clientID        Client ID you wish to work with or null for all
 * @param   oldestDOS       Earliest date of service to work with
 * @param   today           Todays date (passed in)
 ***************************************************************************/        
-- I believe this is deprecated now

insert into @final_claims
select distinct ClaimID
from dbo.CLAIMS_TRANSMISSION_LIST_VIEW_HOLDS(@clientID, @oldestDOS, @newestDOS, @TransmissionDate)
where doHold = 0

return 

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIMS_TRANSMISSION_LIST_VIEW] TO [webuser]
GO
  