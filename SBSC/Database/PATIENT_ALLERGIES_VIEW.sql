USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ALLERGIES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_ALLERGIES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_ALLERGIES_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT
  , @clientID			   bigint
  , @patID				   bigint
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    
select top (dbo.CONST_MAX_ROWS())
    pa.*
  , a.[name] as allergyName   
  
from dbo.PATIENT_ALLERGIES as pa 
JOIN ALLERGIES             as a on a.id = pa.[allergyID]
where (   
      (1=1)
  and (pa.clientID  = @clientID)
  and (pa.patID     = @patID)
  and (pa.active    = 1)
  and ((@recID is null) or (pa.id = @recID))
)
order by 
    pa.isPriority asc
  , a.[name] asc

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_ALLERGIES_VIEW] TO [webuser]
GO