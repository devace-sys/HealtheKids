USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURES_TRANSMITTABLE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURES_TRANSMITTABLE
GO

/*-------------------------------
 * Object Definitions
 *------------------------------*/

CREATE FUNCTION [dbo].CLAIM_PROCEDURES_TRANSMITTABLE
()
RETURNS table as


RETURN
(
	/* A list of procedures that are suitable for transmission */
	select * 
	from dbo.claim_procedures 
	where put_in_837 = 1
		and procedure_code not like 'Q%'
		/* TODO: External calls to this function often specify 'PROCEDURE_CODE_IS_Q = 0' as part of a join to services_view_core. Does this  procedure code filter handle that already? */
)
GO