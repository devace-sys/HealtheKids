USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_TASKS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_COMPLIANCE_TASKS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_COMPLIANCE_TASKS_VIEW] (
    @userID               BIGINT
  , @userGroup            INT  
  , @userRank             INT 
  , @term				  varchar(1000)
  , @active			      bit
  , @recID                BIGINT
)    

RETURNS TABLE
   
AS RETURN

select top (dbo.CONST_MAX_ROWS())
  cct.* 
from dbo.CLIENT_COMPLIANCE_TASKS_VIEW_CORE (
      @term
	, @active
	, @recID
) as cct
order by cct.[name]

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_COMPLIANCE_TASKS_VIEW] TO [webuser]
GO  
