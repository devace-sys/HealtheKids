USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ */    
/**    
 * Extracts data from loop 2110
 * Note: There may be 100 of these per loop
 * We are using the technique where we include the segment number
 * in the group by to handle multiple LQ segments
 * Has pass through segment idx for proper relation to svc segments
 ***************************************************************************/  

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ] (
    @receivedFileContentRecID bigint
  , @tx_control_number        varchar(255)
  , @related_to_segment_idx   bigint
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
 , cp.segment_num
 , related_to_segment_idx   = @related_to_segment_idx

 , code_list_qualifier_code = max(case when cp.element_pos  = 2  then element_value end) 
 , remark_code              = max(case when cp.element_pos  = 3  then element_value end) 
 

from dbo.Claims_835_Data_Received_File_Content_Parsed as cp 

/* Predicate uses index */

where (
        (cp.file_id            = @receivedFileContentRecID) 
     and (cp.tx_control_number = @tx_control_number) 
	 and (cp.loop_name         = '2110')
	 and (cp.segment_name      = 'LQ')
	 and (cp.element_pos       > 1)
	 and (cp.id is not null)
)

group by
   cp.file_id
 , cp.tx_control_number
 , cp.line_number
 , cp.segment_num
)
GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ] TO [webuser]
GO