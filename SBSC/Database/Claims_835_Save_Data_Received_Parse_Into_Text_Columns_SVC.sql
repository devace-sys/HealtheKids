USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC */    
/**    
 * Extracts data from loop 2110
 * Note: There may be up to 1000 of these in each loop 2100
 * We are using the technique where we include the segment_idx
 * in the group by to handle multiple SVC segments inside a CLP 
 ***************************************************************************/  

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC] (
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
 , cp.segment_idx

 , svc_proc_mod_combo_paid       = max(case when cp.element_pos  = 2  then element_value end) 
 , svc_amount_submitted          = try_convert(money,max(case when cp.element_pos = 3 then element_value end))
 , svc_amount_paid               = try_convert(money,max(case when cp.element_pos = 4 then element_value end)) 
 , svc_revenue_code              = max(case when cp.element_pos = 5 then element_value end) 
 , svc_units_paid                = try_convert(smallint,max(case when cp.element_pos = 6 then element_value end))
 , svc_proc_mod_combo_submitted  = max(case when cp.element_pos  = 7  then element_value end) 
 , svc_units_submitted           = try_convert(smallint,max(case when cp.element_pos = 8 then element_value end))
 

from dbo.Claims_835_Data_Received_File_Content_Parsed as cp 

where (
        (cp.file_id            = @receivedFileContentRecID) 
     and (cp.tx_control_number = @tx_control_number) 
	 and (cp.loop_name         = '2110')
	 and (cp.segment_name      = 'SVC')
	 and (cp.element_pos > 1)
)
group by
   cp.file_id
 , cp.tx_control_number
 , cp.line_number
 , cp.segment_idx
)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC] TO [webuser]
GO