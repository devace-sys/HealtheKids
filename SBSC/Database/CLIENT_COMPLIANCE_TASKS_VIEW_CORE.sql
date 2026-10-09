USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_COMPLIANCE_TASKS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION CLIENT_COMPLIANCE_TASKS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_COMPLIANCE_TASKS_VIEW_CORE] (
    @term  varchar(1000)
  , @active bit
  , @recID bigint
)    
 
RETURNS TABLE
  
AS RETURN
( 
  select
	*
  from dbo.CLIENT_COMPLIANCE_TASKS as cct
  where (
		 (1=1)
     and ((isnull(@term, '') = '') OR (cct.[name] like '%' + @term + '%'))
	 and ((@active is null)        OR (cct.active = @active))
	 and ((@recID is null)         OR (cct.id = @recID))
  )
)

GO

GRANT SELECT ON  [dbo].[CLIENT_COMPLIANCE_TASKS_VIEW_CORE] TO [webuser]
GO
