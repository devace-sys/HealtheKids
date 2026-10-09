USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check */    
/**    
 * 
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check] (
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
	, [payer_name_(1000A_0800_N1_N103)]                                  = pyr.name
    , [payer_address_1_(1000A_1000_N3_N301)]                             = pyra1.address_line_1
	, [payer_address_2_(1000A_1000_N3_N302)]                             = pyra1.address_line_2
	, [payer_city_(1000A_1100_N4_N401)]                                  = pyra2.city
	, [payer_state_(1000A_1100_N4_N402)]                                 = pyra2.state_or_prov_code
	, [payer_zip_code_(1000A_1100_N4_N403)]                              = pyra2.postal_code
	, [payer_country_code_(1000A_1100_N4_N404)]                          = pyra2.country_code
	, [payer_country_sub_code_(1000A_1100_N4_N406)]                      = pyra2.country_code
	, [payer_tech_contact_name_(1000A_1300_PER_PER02)]                   = pyrct.name
	, [payer_tech_contact_communication_number_1_(1000A_1300_PER_PER04)] = pyrct.communication_number_1
	, [payer_tech_contact_communication_number_2_(1000A_1300_PER_PER06)] = pyrct.communication_number_2
	, [payer_tech_contact_communication_number_3_(1000A_1300_PER_PER08)] = pyrct.communication_number_3
	, [transaction_handling_code_(BPR_0200)]                             = bpr.transaction_handling_code
    , [monetary_amount_(BPR_0200_BPR02)]                                 = bpr.monetary_amount                        
    , [credit_debit_flag_code_(BPR_0200_BPR03)]                          = bpr.credit_debit_flag_code
    , [payment_method_code_(BPR_0200_BPR04)]                             = bpr.payment_method_code                    
    , [payment_format_code_(BPR_0200_BPR05)]                             = bpr.payment_format_code       
    , [dfi_id_number_qualifier_originating_(BPR_0200_BPR06)]             = bpr.dfi_id_number_qualifier_originating
    , [dfi_id_number_originating_(BPR_0200_BPR07)]                       = bpr.dfi_id_number_originating       
    , [account_number_qualifier_originating_(BPR_0200_BPR08)]            = bpr.account_number_qualifier_originating
    , [account_number_originating_(BPR_0200_BPR09)]                      = bpr.account_number_originating             
    , [originating_company_identifier_(BPR_0200_BPR10)]                  = bpr.originating_company_identifier      
    , [originating_company_supplemental_code_(BPR_0200_BPR11)]           = bpr.originating_company_supplemental_code
    , [dfi_id_number_qualifier_receiving_(BPR_0200_BPR12)]               = bpr.dfi_id_number_qualifier_receiving
    , [dfi_id_number_receiving_(BPR_0200_BPR13)]                         = bpr.dfi_id_number_receiving         
    , [account_number_qualifier_receiving_(BPR_0200_BPR14)]              = bpr.account_number_qualifier_receiving
    , [account_number_receiving_(BPR_0200_BPR15)]                        = bpr.account_number_receiving          
    , [check_issue_or_eft_effective_date_(BPR_0200_BPR16)]               = bpr.check_issue_or_eft_effective_date   	 
	, [trace_type_code_(TRN_0400_TRN01)]                                 = trn.trace_type_code
    , [check_or_eft_trace_number_(TRN_0400_TRN02)]                       = trn.check_or_eft_trace_number
    , [trace_originating_company_identifier_(TRN_0400_TRN03)]            = trn.originating_company_identifier
    , [trace_originating_company_supplemental_code_(TRN_0400_TRN04)]     = trn.originating_company_supplemental_code

  from      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client (@receivedFileContentRecID, @tx_control_number)                as clc
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR    (@receivedFileContentRecID, @tx_control_number)                as bpr on bpr.tx_control_number   = clc.tx_control_number  
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N1     (@receivedFileContentRecID, @tx_control_number, '1000A')       as pyr on pyr.tx_control_number   = bpr.tx_control_number  
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N3     (@receivedFileContentRecID, @tx_control_number, '1000A')       as pyra1 on pyr.tx_control_number = bpr.tx_control_number  
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_N4     (@receivedFileContentRecID, @tx_control_number, '1000A')       as pyra2 on pyr.tx_control_number = bpr.tx_control_number  
  join      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PER    (@receivedFileContentRecID, @tx_control_number, '1000A','BL')  as pyrct on pyr.tx_control_number = bpr.tx_control_number  
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN    (@receivedFileContentRecID, @tx_control_number)                as trn on trn.tx_control_number   = bpr.tx_control_number
    
  where ((clc.file_id = @receivedFileContentRecID) and (clc.tx_control_number = @tx_control_number))

)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Check] TO [webuser]
GO