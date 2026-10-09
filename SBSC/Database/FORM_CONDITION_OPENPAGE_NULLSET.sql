USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FORM_CONDITION_OPENPAGE_NULLSET') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_CONDITION_OPENPAGE_NULLSET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about specific node, confirm that the identity closure for that node exists */

CREATE FUNCTION [dbo].FORM_CONDITION_OPENPAGE_NULLSET ( 
  
  @formRequestID		varchar(max)
  ) 

RETURNS @OpenedPages TABLE (page_id bigint)

AS
BEGIN

declare @formFormID bigint = (select top 1 formDefinitionID from FORM_FORM_SUBMITTED ffs where ffs.formRequestID = @formRequestID)

declare @closuretype bigint = (select ct.id from CLOSURE_TYPES ct inner join FORM_FORM_CLOSURES ffc on ct.id = ffc.closureTypeID and ffc.formID = @formFormID)
declare @conditionalFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPPCON')
declare @pageFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPID')
;
with satisfiedConditions as
(
select fppc.id as Condition_ID_Satisfied
from FORM_PAGES_SUBMITTED fps
inner join FORM_PAGES_PARTS_CONDITIONS fppc 
	on fps.formPageDefinitionID = fppc.formPageID 
	and fppc.formPagePartID is null
	
where fps.formRequestID = @formRequestID

UNION

select fppc.id as Condition_ID_Satisfied
from FORM_PAGES_PARTS_SUBMITTED fpps
inner join FORM_PAGES_PARTS_CONDITIONS fppc 
	on fpps.formPagePartDefinitionID = fppc.formPagePartID 
	and fppc.conditionOperator is null
where fpps.formRequestID = @formRequestID
)

insert into @OpenedPages
select openedPages.id
from satisfiedConditions sc

inner join dbo.CLOSURE_TREE_RELTYPE_DEPTH_VIEW(@closuretype, 0, @conditionalFieldType, @pageFieldType,1) tree 
on tree.parent = sc.Condition_ID_Satisfied
/* and then use child data to get newly-opened/available pages */
inner join FORM_PAGES openedPages on tree.child = openedPages.id

 return 
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].FORM_CONDITION_OPENPAGE_NULLSET TO [webuser]
GO