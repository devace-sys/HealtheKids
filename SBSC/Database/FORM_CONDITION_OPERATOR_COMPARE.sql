USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FORM_CONDITION_OPERATOR_COMPARE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_CONDITION_OPERATOR_COMPARE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about specific node, confirm that the identity closure for that node exists */

CREATE FUNCTION [dbo].FORM_CONDITION_OPERATOR_COMPARE ( 
  
  @condition_id			bigint,
  @compare_to_value		varchar(max)
  ) 

RETURNS bit

AS
BEGIN
 declare @exists bit = 0
 declare @operator varchar(50)
 declare @condition_value varchar(max)
 
 declare @rootPartType bigint
 declare @rootPartMultiple bit
 
 select
		 @operator = conditionOperator
		,@condition_value = ConditionValue 
		,@rootPartType = fpp.formPagePartType
		,@rootPartMultiple = fpp.multiple
 from 
	form_pages_parts_conditions fppc
	inner join form_pages_parts fpp 
		on fppc.formpagepartid = fpp.id
	
 where fppc.id = @condition_id
 
 
 
 
	select @exists =
		CASE 
			/* Special case for multiple-answer selectboxes with multiple comma-seperated answers */
			when @rootPartType = 11 and @rootpartmultiple = 1
				AND @OPERATOR = '=' AND EXISTS (select 1 where @compare_to_value like '%'+@condition_value+'%')
				THEN 1
		
		
			WHEN @OPERATOR = '=' and @compare_to_value = @condition_value THEN 1
			
		END


 
	return @exists	 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].FORM_CONDITION_OPERATOR_COMPARE TO [webuser]
GO