USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_CLASS_AND_TYPE_CORE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_CLASS_AND_TYPE_CORE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FILE_CLASS_AND_TYPE_CORE_VIEW] (
    @fileClassUploadAllowedFromPublic  as bit
  , @fileClassUploadAllowedFromPrivate as bit
  , @fileTypeUseInUploadList           as bit
  , @fileClassName                     as varchar(1000)
  , @fileTypeName                      as varchar(1000)
  , @fileClassValue                    as bigint
  , @fileTypeValue                     as varchar(100)
  , @fileClassActive                   as bit
  , @fileTypeActive                    as bit
)    

RETURNS TABLE
 
 /***************************************************************************    
  * FILE_CLASS_AND_TYPE_CORE_VIEW */    
 /**    
  * Returns a cross reference and processed list of records from 
  * FILE_CLASSES, TYPE_OF_WORK, and STUDENT_DATA_FILE_TYPES
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
with 
cte_file_class_pass_1 
as
(
select 
    [id]                          as [fileClassValue]
  , [name]                        as [fileClassName]
  --, [saveasnamepattern]           as [fileClassSaveAsNamePattern]
  , [upload_allowed_from_public]  as [fileClassUploadAllowedFromPublic]
  , [upload_allowed_from_private] as [fileClassUploadAllowedFromPrivate]
  , [active]                      as [fileClassActive]
from FILE_CLASSES 
where
    ((1=1)
and ((@fileClassUploadAllowedFromPublic  is null) or (upload_allowed_from_public  = @fileClassUploadAllowedFromPublic))
and ((@fileClassUploadAllowedFromPrivate is null) or (upload_allowed_from_private = @fileClassUploadAllowedFromPrivate))
and ((@fileClassValue                    is null) or (id                          = @fileClassValue))
and ((@fileClassActive                   is null) or (active                      = @fileClassActive))
and ((@fileClassName                     is null) or (name like (@fileClassName + '%'))))
)
,
cte_type_of_work_pass_1
as
(
select 
    File_Class_Id           as [fileClassId]
  , File_Upload_List_Name   as [fileTypeName]
  , WorkCode                as [fileTypeValue]
  , active                  as [fileTypeActive]
  , Use_In_File_Upload_List as [fileTypeUseInUploadList]
from TYPE_OF_WORK 
)
,
cte_student_data_pass_1
as
(
select 
    File_Class_Id           as [fileClassId]
  , File_Upload_List_Name   as [fileTypeName]
  , [TYPE_NAME]             as [fileTypeValue] 
  , active                  as [fileTypeActive]
  , Use_In_File_Upload_List as [fileTypeUseInUploadList]
from STUDENT_DATA_FILE_TYPES 
)
,
cte_combine_1
as
(
select * from cte_type_of_work_pass_1
union all
select * from cte_student_data_pass_1
)
,
cte_combine_2
as
(
select fc.* , ft.*
from cte_combine_1         as ft
join cte_file_class_pass_1 as fc on fc.fileClassValue = ft.fileClassId
where
((1=1)
and ((@fileTypeUseInUploadList is null) or (fileTypeUseInUploadList = @fileTypeUseInUploadList))
and ((@fileTypeActive          is null) or (fileTypeActive          = @fileTypeActive))
and ((@fileTypeValue           is null) or (fileTypeValue           = @fileTypeValue))
and ((@fileTypeName            is null) or (fileTypeName like (@fileTypeName + '%'))))
)
,
cte_output_1
as
(
  select * from cte_combine_2
)
select * from cte_output_1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FILE_CLASS_AND_TYPE_CORE_VIEW] TO [webuser]
GO   
