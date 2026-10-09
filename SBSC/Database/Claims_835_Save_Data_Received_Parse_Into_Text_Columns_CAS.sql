USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS */    
/**    
 * Extracts data from CAS segments in given loop.  
 * 
 * Note: There may be up to 100 of these in a given loop
 * We are using the technique where we include the segment number
 * in the group by to handle multiple CAS segments
 *
 * Has pass through segment idx for proper relation to svc segments for
 * the CAS segements inside SVC segments.  CAS segments inside CLP segments
 * do not need this
 ***************************************************************************/  

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
 , @loop_name                varchar(255)
 , @related_to_segment_idx   bigint
) 

RETURNS 
TABLE
AS     
RETURN
(

select 
   t1.file_id
 , t1.tx_control_number
 , t1.line_number
 , t1.segment_num
 
 , related_to_segment_idx = @related_to_segment_idx

 , claim_adjustment_group_code      = max(case when t1.element_pos   = 2  then element_value end)
 
 , claim_adjustment_reason_code_1   = max(case when t1.element_pos   = 3  then element_value end)
 , monetary_amount_1                = try_convert(money,   max(case when t1.element_pos = 4  then element_value end))
 , quantity_1                       = try_convert(smallint,max(case when t1.element_pos   = 5  then element_value end))
 
 , claim_adjustment_reason_code_2   = max(case when t1.element_pos   = 6  then element_value end)
 , monetary_amount_2                = try_convert(money,   max(case when t1.element_pos   = 7  then element_value end))
 , quantity_2                       = try_convert(smallint,max(case when t1.element_pos   = 8  then element_value end))

 , claim_adjustment_reason_code_3   = max(case when t1.element_pos   = 9  then element_value end)
 , monetary_amount_3                = try_convert(money,   max(case when t1.element_pos   = 10  then element_value end))
 , quantity_3                       = try_convert(smallint,max(case when t1.element_pos   = 11  then element_value end))

 , claim_adjustment_reason_code_4   = max(case when t1.element_pos   = 12  then element_value end)
 , monetary_amount_4                = try_convert(money,   max(case when t1.element_pos   = 13  then element_value end))
 , quantity_4                       = try_convert(smallint,max(case when t1.element_pos   = 14  then element_value end))

 , claim_adjustment_reason_code_5   = max(case when t1.element_pos   = 15  then element_value end)
 , monetary_amount_5                = try_convert(money,   max(case when t1.element_pos   = 16  then element_value end))
 , quantity_5                       = try_convert(smallint,max(case when t1.element_pos   = 17  then element_value end))

 , claim_adjustment_reason_code_6   = max(case when t1.element_pos   = 18  then element_value end)
 , monetary_amount_6                = try_convert(money,   max(case when t1.element_pos   = 19  then element_value end))
 , quantity_6                       = try_convert(smallint,max(case when t1.element_pos   = 20  then element_value end))

 from dbo.Claims_835_Data_Received_File_Content_Parsed as t1

where (
         (t1.file_id           = @receivedFileContentRecID) 
     and (t1.tx_control_number = @tx_control_number) 
	 and (t1.loop_name         = @loop_name)
     and (t1.segment_name      = 'CAS')
     and (t1.element_pos > 1)
)
group by
   t1.file_id
 , t1.tx_control_number
 , t1.line_number
 , t1.segment_num
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_CAS] TO [webuser]
GO