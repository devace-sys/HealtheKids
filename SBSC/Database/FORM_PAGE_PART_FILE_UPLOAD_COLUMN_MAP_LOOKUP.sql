USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP] (
     @formID              as bigint
   , @fileFormPagePartID  as bigint
   , @columnName          as varchar(255)
   , @formRequestID       as varchar(255)
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP */
/**
 * Displays user data
 *
 * @param  columnName            Column name for file upload
 * @param  formPagePartID        Part ID we can find the value in
 * @param  formRequestID         Form request ID
 * @return                       Stored value
 ***************************************************************************/ 

select top 1
       
    columnName  = funp.partName

  , columnValue = 
    case cm.returnWhat
      when 1 then fppscv.value 
      when 2 then fppscv.selectedNames
    end
    
from dbo.FORM_PAGES_PARTS_FILE_UPLOAD_COLUMN_MAPPING as cm
join dbo.FILE_UPLOAD_NAME_PART                       as funp   on funp.id                         = cm.fileUploadNamePartID 
join dbo.FORM_PAGES_PARTS                            as fppfu  on fppfu.id                        = cm.fileFormPagePartID
join dbo.FORM_PAGES_PARTS                            as fppcv  on fppcv.id                        = cm.columnFormPagePartID
join dbo.FORM_PAGES_PARTS_SUBMITTED                  as fppsfu on fppsfu.formPagePartDefinitionID = cm.fileFormPagePartID
join dbo.FORM_PAGES_PARTS_SUBMITTED                  as fppscv on fppscv.formPagePartDefinitionID = cm.columnFormPagePartID
join dbo.FILE_UPLOADS                                as fu     on fu.id                           = fppsfu.crossRefID

where 

      (cm.formID              = @formID)
  and (cm.fileFormPagePartID  = @fileFormPagePartID) 
  and (funp.partName          = @columnName) 
  and (fppscv.formRequestID   = @formRequestID)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FORM_PAGE_PART_FILE_UPLOAD_COLUMN_MAP_LOOKUP] TO [webuser]
GO
