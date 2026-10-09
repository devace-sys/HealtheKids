USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(
  select     
      lx.*    
    , [patient_last_(2100_0300_NM1_103)]                  = pat.last_name
    , [patient_first_name_(2100_0300_NM1_104)]            = pat.first_name
    , [patient_middle_name_(2100_0300_NM1_105)]           = pat.middle_name  
    , [patient_suffix_(2100_0300_NM1_107)]                = pat.suffix
	, [patient_bic_(2100_0300_NM1_109)]                   = pat.id_code 

	, [patient_last_corrected_(2100_0300_NM1_103)]        = patcor.last_name
    , [patient_first_name_corrected_(2100_0300_NM1_104)]  = patcor.first_name
    , [patient_middle_name_corrected_(2100_0300_NM1_105)] = patcor.middle_name  
	, [patient_suffix_corrected_(2100_0300_NM1_107)]      = pat.suffix        
  
  from      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header  (@receivedFileContentRecID, @tx_control_number)                as lx
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_NM1                 (@receivedFileContentRecID, @tx_control_number, '2100', 'QC')  as pat    on pat.line_number    = lx.line_number
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_NM1                 (@receivedFileContentRecID, @tx_control_number, '2100', '74')  as patcor on patcor.line_number = lx.line_number      
  
  where ((lx.file_id = @receivedFileContentRecID) and (lx.tx_control_number = @tx_control_number))
)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient] TO [webuser]
GO