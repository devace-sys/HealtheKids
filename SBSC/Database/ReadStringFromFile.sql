USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ReadStringFromFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ReadStringFromFile]
GO

/***************************************************************************    
 * ReadStringFromFile */    
/**    
 * Reads content of @pathFileIn into @stringOut
 ***************************************************************************/   

USE [spedmon]
GO

/* Reads file into a string */

CREATE PROCEDURE [dbo].[ReadStringFromFile] (
  @pathFileIn NVARCHAR(512)
, @stringOut  VARCHAR(MAX) OUTPUT  
)
AS
BEGIN

SET NOCOUNT ON 

declare @sql         as NVARCHAR(MAX)
declare @parmsDefine as NVARCHAR(4000) 

set @sql         = N'select @stringOut = (select * from openrowset (bulk ''' + @pathFileIn + ''',SINGLE_CLOB) x)'
set @parmsDefine = N'@stringOut varchar(max) OUTPUT' 

exec sp_executesql @stmt = @sql, @params = @parmsDefine, @stringOut = @stringout OUTPUT  

END
GO


