USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Payment_Information_Patient_Name_Claim_Payment_Claim_Dates') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Payment_Information_Patient_Name_Claim_Payment_Claim_Dates
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Payment_Information_Patient_Name_Claim_Payment_Claim_Dates] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(
select 
   
     pat.*
   , [claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]   = clp.claim_submitter_claim_tracking_id
   , [claim_status_code_(2100_0100_CLP_CLP02)]                   = clp.claim_status_code            
   , [claim_amount_submitted_(2100_0100_CLP_CLP03)]              = clp.claim_amount_submitted
   , [claim_amount_patient_responsibility_(2100_0100_CLP_CLP04)] = clp.claim_amount_patient_responsibility
   , [claim_amount_paid_(2100_0100_CLP_CLP05)]                   = clp.claim_amount_paid       
   , [claim_filing_indicator_code_(2100_0100_CLP_CLP06)]         = clp.claim_filing_indicator_code
   , [claim_control_number_(2100_0100_CLP_CLP07)]                = clp.claim_control_number         
   , [claim_facility_code_value_(2100_0100_CLP_CLP08)]           = clp.claim_facility_code_value
   , [claim_frequency_type_code_(2100_0100_CLP_CLP09)]           = clp.claim_frequency_type_code   	
   
   , [service_provider_id_code_qualifier_(2100_0300_NM1_NM108)]  = svcp.id_code_qualifier
   , [service_provider_id_code_(2100_0300_NM1_NM109)]            = svcp.id_code   
   
   , [statement_from_date_(2100_0500_DTM_DTM02)]                 = stmt_f.[date]
   , [statement_to_date_(2100_0500_DTM_DTM02)]                   = stmt_t.[date]
   , [claim_received_date_(2100_0500_DTM_DTM02)]                 = clm_r.[date]    
  
  from      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Patient (@receivedFileContentRecID, @tx_control_number)                as pat
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP                 (@receivedFileContentRecID, @tx_control_number)                as clp    on clp.line_number      = pat.line_number
  
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_NM1                 (@receivedFileContentRecID, @tx_control_number, '2100', '82')  as svcp   on svcp.line_number     = clp.line_number
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM                 (@receivedFileContentRecID, @tx_control_number, '2100', '232', null) as stmt_f on stmt_f.line_number   = clp.line_number
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM                 (@receivedFileContentRecID, @tx_control_number, '2100', '233', null) as stmt_t on stmt_t.line_number   = clp.line_number  
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM                 (@receivedFileContentRecID, @tx_control_number, '2100', '050', null) as clm_r  on clm_r.line_number    = clp.line_number

  where ((pat.file_id = @receivedFileContentRecID) and (pat.tx_control_number = @tx_control_number))
)
GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Payment_Information_Patient_Name_Claim_Payment_Claim_Dates] TO [webuser]
GO