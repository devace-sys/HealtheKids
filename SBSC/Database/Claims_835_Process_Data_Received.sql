USE [spedmon]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Claims_835_Process_Data_Received]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[Claims_835_Process_Data_Received]
GO

/***************************************************************************    
 * Claims_835_Process_Data_Received */    
/**    
 * Processes X12 content related to @receivedFileContentRecID
 ***************************************************************************/   

USE [spedmon]
GO

CREATE PROCEDURE [dbo].[Claims_835_Process_Data_Received] (
    @receivedFileContentRecID bigint
  , @findGeneralSegmentSpecs  bit
)
AS
BEGIN

SET NOCOUNT ON 

/* Perform initial parsing */

exec dbo.Claims_835_Save_Data_Received_Parse                     
    @receivedFileContentRecID
  , @findGeneralSegmentSpecs

/* Generate and assign line numbers */

exec dbo.Claims_835_Save_Data_Received_Parse_Generate_And_Assign_Line_Numbers 
  @receivedFileContentRecID

/* Pivot into rows we can use */

exec dbo.Claims_835_Save_Data_Received_Parse_Pivot               
  @receivedFileContentRecID

return
END
GO


