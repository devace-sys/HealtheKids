USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Save_And_Process_File]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Claims_835_Save_And_Process_File]
GO

/***************************************************************************    
 * Claims_835_Save_And_Process_File */    
/**    
 * Entry point.
 * Saves content of @pathFileName and then processes it
 ***************************************************************************/   

USE [spedmon]
GO

CREATE PROCEDURE [dbo].[Claims_835_Save_And_Process_File] (
      @pathFileName      nvarchar(512)
	, @billingProgramID  tinyint = 1
	, @fileID            bigint output
)
AS
BEGIN
  SET NOCOUNT ON 
  set @fileID = 0

  declare @receivedFileContentRecID as bigint
  exec dbo.Claims_835_Save_Data_Received @pathFileName, @billingProgramID, @receivedFileContentRecID OUTPUT
  set @fileID = @receivedFileContentRecID
  exec dbo.Claims_835_Process_Data_Received             @receivedFileContentRecID, 0  
  return
END
GO


