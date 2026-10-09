USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW] (    
     @userID           bigint
   , @userGroup        int
   , @userRank         int
   , @clientID         bigint
   , @pirrMassUpdateID bigint  
   , @completed        bit
   , @processed        bit
)  

RETURNS TABLE

 /***************************************************************************    
  * PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW */    
 /**    
  * 
  *    
  ***************************************************************************/     

AS RETURN (

select 
    pirrmur.id      
  , pirrmur.pirrMassUpdateID
  , pirrmur.patID
  , patName = pap.CONCAT_NAME
  , pirrmur.patPerIDs
  , pirrmur.numOfPatPers
  , pirrmur.processed
  , pirrmur.pirrID
  , pirrmu.clientID
  , pirrmu.completed

from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES     as pirrmu
join dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS as pirrmur on pirrmur.pirrMassUpdateID = pirrmu.id
join dbo.PATIENTS_Patient                                 as pap     on pap.PATIENT_ID = pirrmur.patID

where (
      (1=1) 
  and ((@clientID         is null)  or (pirrmu.clientID   = @clientID))
  and ((@pirrMassUpdateID is null)  or (pirrmu.id         = @pirrMassUpdateID))
  and ((@completed        is null)  or (pirrmu.completed  = @completed))
  and ((@processed        is null)  or (pirrmur.processed = @processed))
  and (pirrmu.active = 1)
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS_VIEW] TO [webuser]
GO

  