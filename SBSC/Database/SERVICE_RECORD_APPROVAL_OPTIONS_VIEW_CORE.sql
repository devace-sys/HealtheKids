USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
	 
CREATE FUNCTION [dbo].[SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE] ()
 
RETURNS TABLE 
AS 
RETURN (
 
/***************************************************************************    
 * SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE () */    
/**    
 * Returns service record approval options
 *
 ***************************************************************************/      

with
cte_pass_1
as
(
select 
    [id]             = srao.id
  , [clientID]       = srao.clientID
  , [approvalSystem] = srao.approvalSystem
from dbo.SERVICE_RECORDS_APPROVAL_OPTIONS as srao
)
select * from cte_pass_1
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORD_APPROVAL_OPTIONS_VIEW_CORE] TO [webuser]
GO
