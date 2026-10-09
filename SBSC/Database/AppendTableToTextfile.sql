USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.AppendTableToTextfile') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.AppendTableToTextfile
GO

IF type_id('[dbo].[NumberedLinesOfText]') IS NOT NULL DROP TYPE [dbo].[NumberedLinesOfText];
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE type NumberedLinesOfText AS TABLE
(
  line_num bigint identity(1,1),
        text_row varchar(max) NOT NULL
);
GO

CREATE PROCEDURE [dbo].[AppendTableToTextfile] (
    @Contents NumberedLinesOfText READONLY,
    @Path VARCHAR(255),
    @Filename VARCHAR(200),
    @createFile bit -- if null, defaults true
)    
AS 

BEGIN

SET nocount ON

DECLARE  @cur_row varchar(max);

declare @curIdx bigint
SELECT @curIdx=MIN(line_num) FROM @Contents
declare @maxIdx bigint
SELECT @maxIdx=MAX(line_num) FROM @Contents

WHILE (@curIdx <= @maxIdx) BEGIN
  SELECT @cur_row=text_row FROM @Contents WHERE line_num = @curIdX;
  exec dbo.AppendStringToFile @cur_row, @Path, @Filename, @createFile, 1 -- TextStream.WriteLine()
  SET @curIdx = @curIdx + 1
END;

END
GO



/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON TYPE::NumberedLinesOfText TO [webuser]
GO

GRANT EXECUTE ON  [dbo].[AppendTableToTextfile] TO [webuser]
GO