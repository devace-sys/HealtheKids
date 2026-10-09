USE [spedmon]
GO

/****** Object:  StoredProcedure [dbo].[WriteStringToFile]    Script Date: 10/30/2018 14:11:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WriteStringToFile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[WriteStringToFile]
GO

USE [spedmon]
GO

CREATE PROCEDURE [dbo].[WriteStringToFile]
(

@String Varchar(max), --8000 in SQL Server 2000
@Path VARCHAR(255),
@Filename VARCHAR(200)
)

AS

DECLARE @objFileSystem int

,@objTextStream int,

            @objErrorObject int,

            @strErrorMessage Varchar(1000),

      @Command varchar(1000),

      @hr int,

            @fileAndPath varchar(500)



set nocount on



select @strErrorMessage='opening the File System Object'

EXECUTE @hr = sp_OACreate 'Scripting.FileSystemObject' , @objFileSystem OUT



Select @FileAndPath=@path+'\'+@filename

if @HR=0 Select @objErrorObject=@objFileSystem , @strErrorMessage='Creating file "'+@FileAndPath+'"'

if @HR=0 execute @hr = sp_OAMethod @objFileSystem , 'CreateTextFile'

      , @objTextStream OUT, @FileAndPath,2



if @HR=0 Select @objErrorObject=@objTextStream, 

      @strErrorMessage='writing to the file "'+@FileAndPath+'"'

if @HR=0 execute @hr = sp_OAMethod @objTextStream, 'Write', Null, @String



if @HR=0 Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'

if @HR=0 execute @hr = sp_OAMethod @objTextStream, 'Close'



if @hr<>0

      begin

      Declare 

            @Source varchar(255),

            @Description Varchar(255),

            @Helpfile Varchar(255),

            @HelpID int

      

      EXECUTE sp_OAGetErrorInfo @objErrorObject, 

            @source output,@Description output,@Helpfile output,@HelpID output

      Select @strErrorMessage='Error whilst '

                  +coalesce(@strErrorMessage,'doing something')

                  +', '+coalesce(@Description,'')

      raiserror (@strErrorMessage,16,1)

      end

EXECUTE sp_OADestroy @objFileSystem

EXECUTE sp_OADestroy @objTextStream

GO


