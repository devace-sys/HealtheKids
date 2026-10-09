USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED] (
    @clientID            bigint
  , @patID               bigint
 )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED  */    
 /**    
  * Returns a table of latest iep session record entered for given client and patient
  *    
  * @return                 Table 
  ***************************************************************************/     
 
AS RETURN
( 
  select top 1 
    tsivc.*  
  from dbo.TELECOMM_SESSIONS_IEP_VIEW_CORE (null,null,null,@clientID, @patID,null,null) as tsivc
  /* Note: The where clause here is to enforce that a clientID and patID must be passed */
  where (
        (tsivc.clientID = @clientID)
    and (tsivc.patID = @patID)
  )
  order by 
    tsivc.id desc
)

GO

GRANT SELECT ON  [dbo].[TELECOMM_SESSIONS_IEP_GET_LAST_SESSION_ENTERED] TO [webuser]
GO
