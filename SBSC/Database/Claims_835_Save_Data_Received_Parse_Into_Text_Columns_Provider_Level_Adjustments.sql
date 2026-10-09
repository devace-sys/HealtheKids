USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments */    
/**    
 * 
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments] (
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
	, [client_fiscal_year_end_(PLB_SUM_0100_PLB01)]    = plb.last_date_of_providers_fiscal_year
    , [adjustment_identifier_1_(PLB_SUM_0100_PLB01)]   = plb.adjustment_identifier_1
    , [monetary_amount_1_(PLB_SUM_0100_PLB01)]         = plb.monetary_amount_1
    , [adjustment_identifier_2_(PLB_SUM_0100_PLB01)]   = plb.adjustment_identifier_2
    , [monetary_amount_2_(PLB_SUM_0100_PLB01)]         = plb.monetary_amount_2
    , [adjustment_identifier_3_(PLB_SUM_0100_PLB01)]   = plb.adjustment_identifier_3
    , [monetary_amount_3_(PLB_SUM_0100_PLB01)]         = plb.monetary_amount_3
    , [adjustment_identifier_4_(PLB_SUM_0100_PLB01)]   = plb.adjustment_identifier_4
    , [monetary_amount_4_(PLB_SUM_0100_PLB01)]         = plb.monetary_amount_4
    , [adjustment_identifier_5_(PLB_SUM_0100_PLB01)]   = plb.adjustment_identifier_5
    , [monetary_amount_5_(PLB_SUM_0100_PLB01)]         = plb.monetary_amount_5
    , [adjustment_identifier_6_(PLB_SUM_0100_PLB01)]   = plb.adjustment_identifier_6
    , [monetary_amount_6_(PLB_SUM_0100_PLB01)]         = plb.monetary_amount_6
  
  from  dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Client (@receivedFileContentRecID, @tx_control_number)  as clc
  join  dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB    (@receivedFileContentRecID, @tx_control_number)  as plb on plb.tx_control_number = clc.tx_control_number
  
  where ((clc.file_id = @receivedFileContentRecID) and (clc.tx_control_number = @tx_control_number))
)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Provider_Level_Adjustments] TO [webuser]
GO