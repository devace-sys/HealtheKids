USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW] (    
     @userID           bigint
   , @userGroup        int
   , @userRank         int 
   , @clientID         bigint  
   , @completed        bit
)  

RETURNS TABLE

 /***************************************************************************    
  * PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW */    
 /**    
  * 
  *    
  ***************************************************************************/     

AS RETURN (

select 
    pirrmu.id
  , pirrmu.clientID
  , clientName = clc.CLIENT_NAME
  , pirrmu.requesterName
  , pirrmu.requesterEmail
  , pirrmu.requesterPhone
  , pirrmu.requestBaseUrl
  , pirrmu.numOfPats
  , pirrmu.numOfPatPers
  , numPatsProcessed = isnull(pirrmur2.numPatsProcessed,0)
  , pirrmu.completed

from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES as pirrmu
join dbo.CLIENTS_Client                               as clc on clc.CLIENT_ID = pirrmu.clientID
outer apply (
    select 
      numPatsProcessed = count(pirrmur1.id)
    from dbo.PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATE_ROWS as pirrmur1
    where (
          (pirrmur1.pirrMassUpdateID = pirrmu.id)
	  and (pirrmur1.processed        = 1)
    )
    group by 
      pirrmur1.pirrMassUpdateID
) as pirrmur2

where (
      (1=1)
  and ((@clientID         is null)  or (pirrmu.clientID   = @clientID))  
  and ((@completed        is null)  or (pirrmu.completed  = @completed))
  and (pirrmu.active = 1)
)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_INFO_REQUESTS_RESPONSES_MASS_UPDATES_VIEW] TO [webuser]
GO

  