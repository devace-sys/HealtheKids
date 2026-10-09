USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_REQUEST_STATUS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_REQUEST_STATUS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_REQUEST_STATUS_VIEW]
(@userID      BIGINT,    
 @userGroup   INT,    
 @userRank    INT,
 @formRequestID varchar(max),
 @formID     bigint,
 @formPageID bigint
 )

RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FORM_REQUEST_STATUS_VIEW */
/**
 * Displays status
 *
 * @return                 Table of user data
 ***************************************************************************/ 

select 
   dbo.FORM_CONDITION_PREV_PAGE(ffs.formRequestID, fp.id) as [prevPageID]
  ,fp.id                                                  as [currPageID]
  ,dbo.FORM_CONDITION_NEXT_OPENPAGE(ffs.formRequestID)    as [nextPageID]
  ,ffs.complete                                           as [complete]
  ,ffs.completedOn                                        as [completedOn]    
from FORM_FORM_SUBMITTED as ffs
join FORM_FORM           as ff on ff.id     = ffs.formDefinitionID
join FORM_PAGES          as fp on fp.formID = ff.id
where 
    ((ffs.formRequestID = @formRequestID) and (ff.id = @formID) and (fp.id = @formPageID))
    
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_REQUEST_STATUS_VIEW] TO [webuser]
GO
