USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR */    
/**    
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(

select 
   t1.file_id
 , t1.tx_control_number
 , transaction_handling_code                  = max(case when t1.element_pos   = 2  then element_value end)
 , monetary_amount                            = try_convert(money,max(case when t1.element_pos = 3 then element_value end))
 , credit_debit_flag_code                     = max(case when t1.element_pos   = 4  then element_value end)
 , payment_method_code                        = max(case when t1.element_pos   = 5  then element_value end)
 , payment_format_code                        = max(case when t1.element_pos   = 6  then element_value end)
 , dfi_id_number_qualifier_originating        = max(case when t1.element_pos   = 7  then element_value end)
 , dfi_id_number_originating                  = max(case when t1.element_pos   = 8  then element_value end)
 , account_number_qualifier_originating       = max(case when t1.element_pos   = 9  then element_value end)
 , account_number_originating                 = max(case when t1.element_pos   = 10  then element_value end)
 , originating_company_identifier             = max(case when t1.element_pos   = 11  then element_value end)
 , originating_company_supplemental_code      = max(case when t1.element_pos   = 12  then element_value end)
 , dfi_id_number_qualifier_receiving          = max(case when t1.element_pos   = 13  then element_value end)
 , dfi_id_number_receiving                    = max(case when t1.element_pos   = 14  then element_value end)
 , account_number_qualifier_receiving         = max(case when t1.element_pos   = 15  then element_value end)
 , account_number_receiving                   = max(case when t1.element_pos   = 16  then element_value end)
 , check_issue_or_eft_effective_date          = try_convert(date,max(case when t1.element_pos = 17 then element_value end))
 
 from dbo.Claims_835_Data_Received_File_Content_Parsed as t1
 
 /* Predicate uses index */

where (
         (t1.file_id           = @receivedFileContentRecID) 
     and (t1.tx_control_number = @tx_control_number) 
	 and (t1.loop_name is not null)
	 and (t1.segment_name      = 'BPR')
     and (t1.element_pos > 1)
	 and (t1.id is not null)
)
group by
   t1.file_id
 , t1.tx_control_number

)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_BPR] TO [webuser]
GO