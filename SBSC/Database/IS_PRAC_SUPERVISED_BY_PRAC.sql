/* TODO: May no longer be in use.  Verify and drop/remove if so eventually. */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_PRAC_SUPERVISED_BY_PRAC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_PRAC_SUPERVISED_BY_PRAC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[IS_PRAC_SUPERVISED_BY_PRAC] (@supervisedPracID bigint, @supervisingPracID as bigint, @date as datetime)
RETURNS BIT
AS     
BEGIN    
  
  /* Uses [ACTIVE_SUPERVISED_START_END_IDX] index */
if (exists 
	(
		select top 1 t1.ID from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as t1
		where (
			t1.ACTIVE = 1
		and (SUPERVISED_PRAC_ID = @supervisedPracID)
		and (
			(@date is null)
			or
			(
			    ((START_DATE is null) or (@date >= START_DATE))
			and ((END_DATE is null  ) or (@date <= END_DATE  ))
			)
		)
		and (SUPERVISING_PRAC_ID = @supervisingPracID)
		and (t1.SHARE_NOTES = 0)
		and (t1.relationshipTypeID = 10)
		)
	)
)
begin
	return 1
end

return 0

      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[IS_PRAC_SUPERVISED_BY_PRAC] TO [webuser]
GO