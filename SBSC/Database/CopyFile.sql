USE [spedmon]
GO

/****** Object:  StoredProcedure [dbo].[CopyFile]    Script Date: 10/30/2018 14:11:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CopyFile]') AND type IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[CopyFile]
GO

USE [spedmon]
GO

CREATE PROCEDURE [dbo].[CopyFile]
(
@Path VARCHAR(255),
@Filename VARCHAR(200),
@NewName VARCHAR(200)
)

AS

DECLARE
  @objFileSystem int,

  @objErrorObject int,
  @strErrorMessage varchar(1000),
  @spOA_exec_status_code int,  -- was originally "@hr", idk why

  @fileAndPath varchar(500),
  @NewFilenameAndPath varchar(500),

  @file_exists bit

SET nocount ON

  -- a primer: https://stackoverflow.com/a/8929732

SELECT @FileAndPath       =ISNULL(@path +'\','') + @filename
SELECT @NewFilenameAndPath=ISNULL(@path +'\','') + @NewName

select @strErrorMessage='opening the File System Object'

EXECUTE @spOA_exec_status_code = sp_OACreate 'Scripting.FileSystemObject', @objFileSystem OUT  -- create a FileSystemObject to control the file system;
                                                                                               -- then we can find/create/read/write files
                                                                                               -- see https://docs.microsoft.com/en-us/office/vba/language/reference/user-interface-help/filesystemobject-object
if @spOA_exec_status_code=0 begin
  select @objErrorObject=@objFileSystem, @strErrorMessage='finding file "'+@FileAndPath+'"'
  execute @spOA_exec_status_code = sp_OAMethod @objFileSystem, 'FileExists', @file_exists OUT, @FileAndPath

  if @spOA_exec_status_code=0 begin -- no error
    if (@file_exists = 0)  -- if file does not already exist
        raiserror ('Could not find file to append.  Create new file?',16,1)
    else begin  
      SET @strErrorMessage='file found: "'+@FileAndPath+'" ' + ' - copying the file'

      execute @spOA_exec_status_code = sp_OAMethod @objFileSystem, 'CopyFile', null, @FileAndPath, @NewFilenameAndPath, 1
                -- MoveFile and DeleteFile fail on the test server, for some reason, but CopyFile works fine.
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

EXECUTE sp_OADestroy @objFileSystem

GO

GRANT EXECUTE ON  [dbo].[CopyFile] TO [webuser]

GO