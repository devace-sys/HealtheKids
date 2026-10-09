USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(
  select 

	  [file_id]                                = @receivedFileContentRecID
	, [file_name]                              = fc.file_name
	, [file_saved_on]                          = fc.content_saved_on
	, [tx_control_number]                      = @tx_control_number
    , [client_name_(1000B_0800_N1_N103)]       = pye.name
    , [client_npi_(1000B_0800_N1_N107)]        = pye.id_code
  
  from dbo.Claims_835_Data_Received_File_Content                                                                              as fc
  join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N1  (@receivedFileContentRecID, @tx_control_number, '1000B') as pye on pye.file_id = fc.id

  where (fc.id = @receivedFileContentRecID)

)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client] TO [webuser]
GO