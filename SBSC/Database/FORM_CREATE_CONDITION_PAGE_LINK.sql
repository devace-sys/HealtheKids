/* Wrapper for closure linking to streamline connections between 
	Conditions and the Pages they lead to.	
	
	Also links the Page the condition evaluates to the child Page - this is useful metadata when we're doing deletes and things.
	
	 */

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_CREATE_CONDITION_PAGE_LINK') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_CREATE_CONDITION_PAGE_LINK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_CREATE_CONDITION_PAGE_LINK 
(
	@closuretype bigint,
	@formPagePartConditionID bigint,
	@childPageID bigint

)


AS
BEGIN

-- 0: var init
declare @conditionalFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPPCON')
declare @pageFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPID')

print @conditionalfieldType
print @pageFieldType

-- 1: create link between condition and page

exec CLOSURE_CREATE_LINK @closuretype, @conditionalFieldType, @formPagePartConditionID, @pageFieldType, @childPageID

-- 2: Create link between the parent page of the condition and the child page
declare @parentPageID bigint = (select fppc.formPageID from FORM_PAGES_PARTS_CONDITIONS fppc where id = @formPagePartConditionID)

exec CLOSURE_CREATE_LINK @closuretype, @pageFieldType, @parentPageID, @pageFieldType, @childPageID
	

END
GO