USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('FORM_CONDITION_OPENPAGE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_CONDITION_OPENPAGE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/* Given information about specific node, confirm that the identity closure for that node exists */

CREATE FUNCTION [dbo].FORM_CONDITION_OPENPAGE_VIEW ( 
  
  @formRequestID		varchar(max)
  ) 

RETURNS TABLE
AS RETURN
(


select distinct page_id, fp.displayOrder from
(
select page_id from FORM_CONDITION_OPENPAGE_OPCOMSET(@formRequestID)
UNION
select page_id from FORM_CONDITION_OPENPAGE_NULLSET(@formRequestID)
) as open_pages
inner join FORM_PAGES fp
	on fp.id = open_pages.page_id
	
where open_pages.page_id not in 
	(select formPageDefinitionID from FORM_PAGES_SUBMITTED where formRequestID = @formRequestID)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
--GRANT SELECT ON  [dbo].FORM_CONDITION_OPENPAGE_VIEW TO [webuser]
GO