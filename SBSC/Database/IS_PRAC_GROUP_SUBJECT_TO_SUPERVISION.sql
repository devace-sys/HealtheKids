USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_PRAC_GROUP_SUBJECT_TO_SUPERVISION') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_PRAC_GROUP_SUBJECT_TO_SUPERVISION
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[IS_PRAC_GROUP_SUBJECT_TO_SUPERVISION] (@groupID bigint)
RETURNS BIT
AS     
BEGIN    

if ( exists (
    select top 1 
      t1.ID
    from dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR as t1
    where ( 
	      (t1.SUPERVISED_GROUP_ID = @groupID)
	  and (t1.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
	  and (t1.ACTIVE = 1)
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
 
GRANT EXECUTE ON  [dbo].[IS_PRAC_GROUP_SUBJECT_TO_SUPERVISION] TO [webuser]
GO