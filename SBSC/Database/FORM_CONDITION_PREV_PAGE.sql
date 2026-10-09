USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FORM_CONDITION_PREV_PAGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_CONDITION_PREV_PAGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given a specific form and a current page ID, find the page previous to that ID. */

CREATE FUNCTION [dbo].FORM_CONDITION_PREV_PAGE ( 
  
  @formRequestID		varchar(max),
  @currentPage			bigint
  ) 

RETURNS bigint
AS
BEGIN

declare @prevFormPage bigint

;
with thisFormPageSubmits as
(
	select * from form_pages_submitted
	where formRequestID = @formrequestID
)

select top 1 @prevformpage = formPageDefinitionID from thisFormPageSubmits
where formPageDefinitionID <> @currentPage
/******************************************

	There are two cases where we might want to look at previous pages:
		We are on a page we have never before submitted, so no submitted Page record exists - use the current date and time to retrieve last page
		We are on a page that was submitted previously - use that page's created date to retrieve last page.
	
********************************************/
and CreatedOn < ISNULL((select top 1 createdOn from thisFormPageSubmits where formPageDefinitionID = @currentPage order by createdOn desc), GETDATE())
order by createdOn desc

/* If we couldn't find anything, return the current page */
if @prevFormPage is null
set @prevFormPage = @currentPage

/**************************************************************************************

	The method below backtraces conditional links to the current page.
	This is less useful than expected, as page ordering may mean that pages are visited in a different sequence than they are linked.
		(ex: having a question spawn subquestions as well as a final file upload page, sequenced to display to user after the subquestions are answered

declare @closuretype bigint = (select id from CLOSURE_TYPES where name = 'DataDrivenWebForm')
declare @conditionalFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPPCON')
declare @pageFieldType bigint = (select id from CLOSURE_FIELDTYPES where namecode = 'DDWFPID')

select top 1 @prevFormPage = pageId from 
(
select distinct fps.id, fps.formPageDefinitionID as pageID
from
	CLOSURE_TREE_RELTYPE_DEPTH_VIEW(@closuretype,0,@conditionalFieldType, @pageFieldType,1) ctrdv
	inner join FORM_PAGES_PARTS_CONDITIONS fppc on ctrdv.parent = fppc.id
	inner join FORM_PAGES_SUBMITTED fps on fppc.formPageID = fps.formPageDefinitionID
	
where ctrdv.child = @currentpage
) uPages
order by id desc

******************************************************************************************************************/

return @prevFormPage
END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].FORM_CONDITION_PREV_PAGE TO [webuser]
GO