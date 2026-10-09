USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Adjustment') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Adjustment
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Adjustment] (
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
	, [claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]   = clp.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
	, [claim_control_number_(2100_0100_CLP_CLP07)]                = clp.[claim_control_number_(2100_0100_CLP_CLP07)]      

	, [claim_adjustment_group_code_(2100_0200_CAS_CAS01)]     = cas.claim_adjustment_group_code 

    , [claim_adjustment_reason_code_1_(2100_0200_CAS_CAS02)]  = cas.claim_adjustment_reason_code_1
    , [monetary_amount_1_(2100_0200_CAS_CAS03)]               = cas.monetary_amount_1
    , [quantity_1_(2100_0200_CAS_CAS04)]                      = cas.quantity_1

    , [claim_adjustment_reason_code_2_(2100_0200_CAS_CAS05)]  = cas.claim_adjustment_reason_code_2
    , [monetary_amount_2_(2100_0200_CAS_CAS06)]               = cas.monetary_amount_2
    , [quantity_2_(2100_0200_CAS_CAS07)]                      = cas.quantity_2
    
	, [claim_adjustment_reason_code_3_(2100_0200_CAS_CAS08)]  = cas.claim_adjustment_reason_code_3 
    , [monetary_amount_3_(2100_0200_CAS_CAS09)]               = cas.monetary_amount_3              
    , [quantity_3_(2100_0200_CAS_CAS10)]                      = cas.quantity_3
    
	, [claim_adjustment_reason_code_4_(2100_0200_CAS_CAS11)]  = cas.claim_adjustment_reason_code_4
    , [monetary_amount_4_(2100_0200_CAS_CAS12)]               = cas.monetary_amount_4 
    , [quantity_4_(2100_0200_CAS_CAS13)]                      = cas.quantity_4              
    
	, [claim_adjustment_reason_code_5_(2100_0200_CAS_CAS14)]  = cas.claim_adjustment_reason_code_5
    , [monetary_amount_5_(2100_0200_CAS_CAS15)]               = cas.monetary_amount_5 
    , [quantity_5_(2100_0200_CAS_CAS16)]                      = cas.quantity_5              
    
	, [claim_adjustment_reason_code_6_(2100_0200_CAS_CAS17)]  = cas.claim_adjustment_reason_code_6
    , [monetary_amount_6_(2100_0200_CAS_CAS18)]               = cas.monetary_amount_6 
    , [quantity_6_(2100_0200_CAS_CAS19)]                      = cas.quantity_6   
    
  from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header (@receivedFileContentRecID, @tx_control_number) as lx  
  join dbo.Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates as clp on ((clp.file_id = lx.file_id) and (clp.tx_control_number = lx.tx_control_number) and (clp.line_number = lx.line_number))  
  join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS (@receivedFileContentRecID, @tx_control_number, '2100', null) as cas on cas.line_number = lx.line_number
  where 
    ((lx.file_id = @receivedFileContentRecID) and (lx.tx_control_number = @tx_control_number))   
)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Claim_Level_Adjustment] TO [webuser]
GO