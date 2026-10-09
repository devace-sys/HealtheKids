USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_KNOWN_HEALTH_PROBLEMS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_KNOWN_HEALTH_PROBLEMS_VIEW] (
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
    pkhp.*
  , khp.[name] as knownHealthProblemName
from dbo.PATIENT_KNOWN_HEALTH_PROBLEMS as pkhp 
join dbo.KNOWN_HEALTH_PROBLEMS         as khp on khp.id = pkhp.knownHealthProblemID 

where (   
      (1=1)
  and (pkhp.clientID = @clientID)
  and (pkhp.patID    = @patID)
  and (pkhp.active   = 1)
  and ((@recID  is null) or (pkhp.id = @recID))

)
order by 
    pkhp.isPriority asc
  , khp.[name] asc
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_KNOWN_HEALTH_PROBLEMS_VIEW] TO [webuser]
GO