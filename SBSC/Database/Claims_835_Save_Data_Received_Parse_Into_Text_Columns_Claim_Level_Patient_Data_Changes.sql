USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes */    
/**    
 * Returns any patient data changes in the 835 data stored for @receivedFileContentRecID
 * and @tx_control_number
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(
  select distinct

      lx.file_id
	 ,lx.file_name
	 ,lx.file_saved_on
	 ,lx.tx_control_number
	
	, lx.[client_name_(1000B_0800_N1_N103)]
	, lx.[client_npi_(1000B_0800_N1_N107)]   
	
	, [patient_bic_(2100_0300_NM1_109)]                   = pat.id_code     
	, [patient_last_(2100_0300_NM1_103)]                  = pat.last_name
    , [patient_first_name_(2100_0300_NM1_104)]            = pat.first_name
    , [patient_middle_name_(2100_0300_NM1_105)]           = pat.middle_name  
    , [patient_suffix_(2100_0300_NM1_107)]                = pat.suffix
	
	, [patient_last_corrected_(2100_0300_NM1_103)]        = patcor.last_name
    , [patient_first_name_corrected_(2100_0300_NM1_104)]  = patcor.first_name
    , [patient_middle_name_corrected_(2100_0300_NM1_105)] = patcor.middle_name  
	, [patient_suffix_corrected_(2100_0300_NM1_107)]      = patcor.suffix        
  
  from   dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header  (@receivedFileContentRecID, @tx_control_number)                as lx
  join   dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_NM1                 (@receivedFileContentRecID, @tx_control_number, '2100', 'QC')  as pat    on pat.line_number    = lx.line_number
  join   dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_NM1                 (@receivedFileContentRecID, @tx_control_number, '2100', '74')  as patcor on patcor.line_number = lx.line_number      
  
  where (
        (lx.file_id           = @receivedFileContentRecID)
    and (lx.tx_control_number = @tx_control_number)
	
	/* Limit to just first or last name corrections */
	and ( 
	       (pat.last_name != patcor.first_name)
	    or (pat.first_name != patcor.first_name)
	)
  
  )

)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient_Data_Changes] TO [webuser]
GO