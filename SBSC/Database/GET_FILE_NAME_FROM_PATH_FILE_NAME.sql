USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_FILE_NAME_FROM_PATH_FILE_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_FILE_NAME_FROM_PATH_FILE_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
/***************************************************************************    
 * GET_FILE_NAME_FROM_PATH_FILE_NAME */    
/**    
 * Returns the file name and extension portion of a path + file name in
 * @pathFileName
 ***************************************************************************/   

CREATE FUNCTION [dbo].[GET_FILE_NAME_FROM_PATH_FILE_NAME](
    @pathFileName nvarchar(512)
  , @delim        char(1)
) 
RETURNS nvarchar(512) 
WITH SCHEMABINDING 
AS    
BEGIN    

  declare @fileName as nvarchar(512)

  declare @parts as table (
     idx bigint identity(1,1)
    ,part nvarchar(512)
  )

  if (trim(isnull(@delim,'')) = '') set @delim = '\'

  insert into @parts
  select value from STRING_SPLIT(@pathFileName,@delim)

  select top 1 @fileName = trim(isnull(part,'')) from @parts order by idx desc

  return @fileName
END    
GO
