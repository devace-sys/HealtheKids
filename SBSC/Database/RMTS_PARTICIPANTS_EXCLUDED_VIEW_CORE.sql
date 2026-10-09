USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_EXCLUDED_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_PARTICIPANTS_EXCLUDED_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_EXCLUDED_VIEW_CORE] (
    @clientID            bigint
  , @rosterID            bigint
)    
 
RETURNS 
TABLE
AS
RETURN
(
select 
 
 
    rpp.*
  , sourceOfData  = null
  , rosterID      = null
  , participantID = null

from      dbo.RMTS_PARTICIPANTS_POSSIBLE_VIEW_CORE (@clientID)            as rpp
left join dbo.RMTS_PARTICIPANTS_INCLUDED_VIEW_CORE (@clientID, @rosterID) as rpi on rpi.id = rpp.id
where (rpi.id is null)
)
GO

GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_EXCLUDED_VIEW_CORE] TO [webuser]
GO
