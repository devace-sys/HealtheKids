USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGE_CLEAR') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FORM_PAGE_CLEAR
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FORM_PAGE_CLEAR
(
	@formRequestID varchar(max),
	@currentPageID bigint
)
AS
BEGIN
	
	declare @formFormID bigint = (select top 1 formDefinitionID from FORM_FORM_SUBMITTED ffs where ffs.formRequestID = @formRequestID)
	
	/* when we create a link between a formPagePartCondition and the resulting Page, 
	we create a parent-child link between the Condition's relevant Page and the child Page of the Condition. */
	
	/* This can be leveraged here - given our currentPage, look for all descendant pages in the closure, 
	joined to submitted Pages and Parts to determine what needs to be deleted for this formRequestID */
	declare @closuretype bigint = (select ct.id from CLOSURE_TYPES ct inner join FORM_FORM_CLOSURES ffc on ct.id = ffc.closureTypeID and ffc.formID = @formFormID)
	declare @pageFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPID')
	
	delete from [FORM_PAGES_SUBMITTED]
	where formPageDefinitionID in
		(
			select tree.child from CLOSURE_TREE_RELTYPE_DEPTH_VIEW(@closuretype, 1,@pagefieldtype, @pagefieldtype,null) tree
			where tree.parent = @currentPageID
		)
		
		and formRequestID = @formRequestID
	
	
	delete from [FORM_PAGES_PARTS_SUBMITTED]
	where formPagePartDefinitionID in
		(
			select fpp.id from CLOSURE_TREE_RELTYPE_DEPTH_VIEW(@closuretype, 1,@pagefieldtype, @pagefieldtype,null) tree
			inner join FORM_PAGES_PARTS fpp on tree.child = fpp.formPageID
			where tree.parent = @currentPageID
		)
		
		and formRequestID = @formRequestID
	

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].FORM_PAGE_CLEAR TO [webuser]

GO






	