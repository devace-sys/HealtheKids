USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSPORTATION_MGMT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TRANSPORTATION_MGMT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[TRANSPORTATION_MGMT_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @active                 BIT
 , @recID                  BIGINT )

RETURNS TABLE
AS
RETURN
(  
  select       
  
      id         = tm.ID
    , name       = clc.CLIENT_NAME
    , clientID   = tm.CLIENT_ID
    , clientName = clc.CLIENT_NAME
    , pracID     = tm.PRACTITIONER_ID
    , pracName   = prp.CONCAT_NAME
    , setup      = case when (prp.PRACTITIONER_ID is null) then 0 else 1 end    , active     = tm.ACTIVE
          
  from      dbo.CLIENTS_Client            as clc 
  join      dbo.TRANSPORTATION_MGMT       as tm  on tm.CLIENT_ID        = clc.CLIENT_ID  
  left join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = tm.PRACTITIONER_ID

  where ( 
        (1=1)    
    and (tm.CLIENT_ID = @clientID)
    and ((@active is null) or (tm.ACTIVE = @active))
    and ((@recID  is null) or (tm.ID     = @recID))
  )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSPORTATION_MGMT_VIEW] TO [webuser]
GO