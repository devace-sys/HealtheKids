USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FORM_CONDITION_OPENPAGE_OPCOMSET') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_CONDITION_OPENPAGE_OPCOMSET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about specific node, confirm that the identity closure for that node exists */

CREATE FUNCTION [dbo].FORM_CONDITION_OPENPAGE_OPCOMSET ( 
  
  @formRequestID		varchar(max)
  ) 

RETURNS @OpenedPages TABLE (page_id bigint)

AS
BEGIN

declare @formFormID bigint = (select top 1 formDefinitionID from FORM_FORM_SUBMITTED ffs where ffs.formRequestID = @formRequestID)
declare @closuretype bigint = (select ct.id from CLOSURE_TYPES ct inner join FORM_FORM_CLOSURES ffc on ct.id = ffc.closureTypeID and ffc.formID = @formFormID)
declare @conditionalFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPPCON')
declare @pageFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPID')

insert into @openedPages
select openedPages.id

from 

FORM_PAGES_PARTS_SUBMITTED fpps
/* yah, this needs to be more generic, but this is good proof of concept -DW */
inner join FORM_PAGES_PARTS_CONDITIONS fppc 
	on fpps.formPagePartDefinitionID = fppc.formPagePartID
	/* pull in closure to get d1 condition-page relations */
inner join dbo.CLOSURE_TREE_RELTYPE_DEPTH_VIEW(@closuretype, 0, @conditionalFieldType, @pageFieldType,1) tree on tree.parent = fppc.id
/* and then use child data to get newly-opened/available pages */
inner join FORM_PAGES openedPages on tree.child = openedPages.id and openedPages.formID = fppc.formID
	
where fpps.formRequestID = @formRequestID
and dbo.FORM_CONDITION_OPERATOR_COMPARE(fppc.id, fpps.value) = 1


 return 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].FORM_CONDITION_OPENPAGE_NULLSET TO [webuser]
GO