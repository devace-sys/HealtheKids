USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FORM_CONDITION_NEXT_OPENPAGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_CONDITION_NEXT_OPENPAGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about specific node, confirm that the identity closure for that node exists */

CREATE FUNCTION [dbo].FORM_CONDITION_NEXT_OPENPAGE ( 
  
  @formRequestID		varchar(max)
  ) 

RETURNS bigint
AS
BEGIN

declare @nextFormPage bigint

select top 1 @nextformpage = page_id
from FORM_CONDITION_OPENPAGE_VIEW(@formRequestID)
order by displayOrder

return @nextFormPage
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].FORM_CONDITION_NEXT_OPENPAGE TO [webuser]
GO