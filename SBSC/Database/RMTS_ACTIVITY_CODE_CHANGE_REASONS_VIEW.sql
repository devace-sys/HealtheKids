USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_ACTIVITY_CODE_CHANGE_REASONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_ACTIVITY_CODE_CHANGE_REASONS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_ACTIVITY_CODE_CHANGE_REASONS_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT
  , @rmtsCodeValue         varchar(10)     
  , @term				   VARCHAR(50)
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    
select 
    cr.id 
  , cr.[rmtsCodeValue]
  , cr.[name] 
  , cr.[description]
  , cr.created
  , cr.createdBy
  , cr.lastModified
  , cr.lastModifiedBy
  , cr.active
  
from dbo.RMTS_ACTIVITY_CODE_CHANGE_REASONS as cr
where (   
      (1=1)
  and ((@recID         is null) or (cr.id            = @recID))
  and ((@rmtsCodeValue is null) or (cr.rmtsCodeValue = @rmtsCodeValue))
  and ((@term          is null) or (cr.[name] like '%' + @term + '%'))
  and (cr.active = 1)
)
 
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_ACTIVITY_CODE_CHANGE_REASONS_VIEW] TO [webuser]
GO