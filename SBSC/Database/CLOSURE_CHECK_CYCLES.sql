USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('CLOSURE_CHECK_CYCLES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLOSURE_CHECK_CYCLES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about a potential link, check to make sure this link won't create a cycle where a child links back to any ancestors */

CREATE FUNCTION [dbo].CLOSURE_CHECK_CYCLES ( 
  
	@closuretype bigint,
	
	@parentfieldtype bigint,
	@parentfieldvalue bigint,

	@childfieldtype bigint,
	@childfieldvalue bigint
  ) 

RETURNS bit

AS
BEGIN
 declare @link_OK bit = 0
 
	if not exists (select 1 from Closure_Table_Structure 
					where @parentfieldtype = child_type and @parentfieldvalue = child 
					and @childfieldtype = parent_type and @childfieldvalue = parent
					and closure_type = @closuretype
					)
	BEGIN
		set @link_OK = 1	
	END
 
	return @link_OK	 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].CLOSURE_CHECK_CYCLES TO [webuser]
GO