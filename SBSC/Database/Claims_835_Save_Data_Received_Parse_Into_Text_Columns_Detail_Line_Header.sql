USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header */    
/**    
 * 
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(
  select     
      clc.*	
	, lx.line_number	
  from  dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client (@receivedFileContentRecID, @tx_control_number)   as clc
  join  dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX     (@receivedFileContentRecID, @tx_control_number)   as lx  on lx.tx_control_number = clc.tx_control_number
  
  where (
        (clc.file_id           = @receivedFileContentRecID) 
	and (clc.tx_control_number = @tx_control_number)
  )
)
GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header] TO [webuser]
GO