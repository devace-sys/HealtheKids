USE [spedmon]
GO

/****** Object:  StoredProcedure [dbo].[AppendStringToFile]    Script Date: 10/30/2018 14:11:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppendStringToFile]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[AppendStringToFile]
GO

USE [spedmon]
GO

CREATE PROCEDURE [dbo].[AppendStringToFile]
(
@String Varchar(max), --8000 in SQL Server 2000
@Path VARCHAR(255),
@Filename VARCHAR(200),
@createFile bit, -- if null, defaults true
@with_newline bit -- for appending to existing files, allows the developer to choose between calling TextStream.Write() and TextStream.WriteLine() methods
                  -- if null, defaults false
)

AS

DECLARE
  @objFileSystem int,
  @objFile int,
  @objTextStr int,
  @objErrorObject int,
  @strErrorMessage varchar(1000),
  @spOA_exec_status_code int,  -- was originally "@hr", idk why
  @fileAndPath varchar(500),
  @file_exists bit

SET nocount ON

  -- a primer: https://stackoverflow.com/a/8929732

SELECT @FileAndPath=@path+'\'+@filename

select @strErrorMessage='opening the File System Object'

EXECUTE @spOA_exec_status_code = sp_OACreate 'Scripting.FileSystemObject', @objFileSystem OUT  -- create a FileSystemObject to control the file system;
                                                                                               -- then we can find/create/read/write files
                                                                                               -- see https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object
if @spOA_exec_status_code=0 begin
  select @objErrorObject=@objFileSystem, @strErrorMessage='finding file "'+@FileAndPath+'"'
  execute @spOA_exec_status_code = sp_OAMethod @objFileSystem, 'FileExists', @file_exists OUT, @FileAndPath

  if @spOA_exec_status_code=0 begin -- no error
    if (@file_exists = 0) begin  -- if file does not already exist
      if (@createFile IS NULL or @createFile = 1) begin -- do we want to create a new file?
        if (@with_newline = 1)
          set @String += CHAR(13) + CHAR(10) -- Windows-style newline
        exec WriteStringToFile @String, @Path, @Filename  -- call pre-existing sproc... it's already been vetted
      end
      else
        raiserror ('Could not find file to append.  Create new file?',16,1)
    end
    else begin  
      SET @strErrorMessage='file found: "'+@FileAndPath+'"'
      execute @spOA_exec_status_code = sp_OAMethod @objFileSystem, 'GetFile', @objFile OUT, @FileAndPath
                  -- see https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/file-object

      IF @spOA_exec_status_code=0 begin
        SELECT @objErrorObject=@objFile,
        @strErrorMessage='opening file "'+@FileAndPath+'"'

        execute @spOA_exec_status_code = sp_OAMethod @objFile, 'OpenAsTextStream', @objTextStr OUT, 8 /* append */, 0 /* ASCII */
                  -- see https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/textstream-object

        IF @spOA_exec_status_code=0 begin
          IF (@with_newline IS NOT NULL AND @with_newline = 1)
            execute @spOA_exec_status_code = sp_OAMethod @objTextStr, 'WriteLine', NULL, @String
          else
            execute @spOA_exec_status_code = sp_OAMethod @objTextStr, 'Write', NULL, @String

          IF @spOA_exec_status_code=0 begin
            SET @strErrorMessage='closing the file "'+@FileAndPath+'"'
            execute @spOA_exec_status_code = sp_OAMethod @objTextStr, 'Close'
          end
        end
      end
    end
  end
  else
    SET @strErrorMessage='Could not find file to append.  Unknown reason; verify spelling, and check file, directory, and system permissions'
end

;if @spOA_exec_status_code<>0 begin
      declare
        @Source varchar(255), 
        @Description varchar(255),
        @Helpfile varchar(255),
        @HelpID int

      EXECUTE sp_OAGetErrorInfo @objErrorObject,   -- I'm not sure how to test this, right now, so I'm going to assume that this "GetErrorInfo" is the "right way" to do this.
                                             -- TODO: figure out if this will handle an OS/filesystem exception gracefully
            @source output,@Description output,@Helpfile output,@HelpID output

      --EXECUTE sp_displayoaerrorinfo @objErrorObject, @spOA_exec_status_code
        -- see this article:
        -- https://support.microsoft.com/en-us/help/243899/how-to-access-additional-information-about-errors-that-are-returned-wh
      
      SELECT @strErrorMessage='Error whilst '
                  +coalesce(@strErrorMessage,'doing something')
                  +', '+coalesce(@Description,'')

      raiserror (@strErrorMessage,16,1)  -- I'm not sure how to test this, right now, so I'm going to assume that this raiserror is the "right way" to do this.
                                             -- TODO: figure out if this raiserror priority will handle an OS/filesystem exception gracefully
end

EXECUTE sp_OADestroy @objTextStr
EXECUTE sp_OADestroy @objFileSystem
EXECUTE sp_OADestroy @objFile
--EXECUTE sp_OADestroy @objTextStr --TODO: why is this here twice?

GO

GRANT EXECUTE ON  [dbo].[AppendStringToFile] TO [webuser]

GO