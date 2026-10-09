USE SPEDMON
GO
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP */    
/**    
 * Extracts data from loop 2100
 * Note: There is only one of these per line number but there may be an 
 * unlimited number of these
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(

select 
   cp.file_id
 , cp.tx_control_number
 , cp.line_number
 , claim_submitter_claim_tracking_id    = max(case when cp.element_pos  = 2  then element_value end) 
 , claim_status_code                    = max(case when cp.element_pos  = 3  then element_value end) 
 , claim_amount_submitted               = try_convert(money,max(case when cp.element_pos = 4 then element_value end))
 , claim_amount_paid                    = try_convert(money,max(case when cp.element_pos = 5 then element_value end)) 
 , claim_amount_patient_responsibility  = try_convert(money,max(case when cp.element_pos = 6 then element_value end))
 , claim_filing_indicator_code          = max(case when cp.element_pos  = 7  then element_value end) 
 , claim_control_number                 = max(case when cp.element_pos  = 8  then element_value end) 
 , claim_facility_code_value            = max(case when cp.element_pos  = 9  then element_value end) 
 , claim_frequency_type_code            = max(case when cp.element_pos  = 10 then element_value end) 

from dbo.Claims_835_Data_Received_File_Content_Parsed as cp 

where (
        (cp.file_id            = @receivedFileContentRecID) 
     and (cp.tx_control_number = @tx_control_number) 
	 and (cp.loop_name         = '2100')
	 and (cp.segment_name      = 'CLP')
	 and (cp.element_pos > 1)
)

group by
   cp.file_id
 , cp.tx_control_number
 , cp.line_number

)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CLP] TO [webuser]
GO