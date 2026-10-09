USE [Spedmon]
GO

/*-------------------------------
 * Turn on CLR support
 *------------------------------*/
 
EXEC sp_configure 'clr enabled', '1'
GO
RECONFIGURE
GO

/*-------------------------------
 * Drop existing "pass through"
 * UDFS first
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RegexMatch') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RegexMatch
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RegexReplace') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RegexReplace
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RegexSelectAll') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RegexSelectAll
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RegexSelectOne') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RegexSelectOne
GO

/*-------------------------------
 * Then drop assembly(s)
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.assemblies asms WHERE asms.name = N'DatabaseExtensions' and is_user_defined = 1)
DROP ASSEMBLY [DatabaseExtensions]
GO

/*-------------------------------
 * Next install assembly(s)
 *------------------------------*/

CREATE ASSEMBLY DatabaseExtensions from 'C:\spedmon\libs\DatabaseExtensions.dll' WITH
PERMISSION_SET = SAFE
GO

/*-------------------------------
 * Finally install "pass through" 
 * udfs
 *------------------------------*/

CREATE FUNCTION [dbo].[RegexMatch](@input [nvarchar](max), @pattern [nvarchar](max))
RETURNS [bit] WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DatabaseExtensions].[MBA.UserDefinedFunctions].[RegexMatch]
GO

CREATE FUNCTION [dbo].[RegexReplace](@expression [nvarchar](max), @pattern [nvarchar](max), @replace [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DatabaseExtensions].[MBA.UserDefinedFunctions].[RegexReplace]
GO

CREATE FUNCTION [dbo].[RegexSelectAll](@input [nvarchar](max), @pattern [nvarchar](max), @matchDelimiter [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [DatabaseExtensions].[MBA.UserDefinedFunctions].[RegexSelectAll]
GO

CREATE FUNCTION [dbo].[RegexSelectOne](@input [nvarchar](max), @pattern [nvarchar](max), @matchIndex [int])
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER 
AS
EXTERNAL NAME [DatabaseExtensions].[MBA.UserDefinedFunctions].[RegexSelectOne]
GO 
