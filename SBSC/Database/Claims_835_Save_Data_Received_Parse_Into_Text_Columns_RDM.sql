USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_RDM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_RDM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_RDM */    
/**    
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_RDM] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
 , @loop_name                varchar(255)
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
 , report_transmission_code         = max(case when t1.element_pos   = 2  then element_value end)
 , name                             = max(case when t1.element_pos   = 3  then element_value end)
 , communication_number             = max(case when t1.element_pos   = 4  then element_value end)
 , reference_identifier_1           = max(case when t1.element_pos   = 5  then element_value end)
 , reference_identifier_2           = max(case when t1.element_pos   = 6  then element_value end)
 
from dbo.Claims_835_Data_Received_File_Content_Parsed as t1

/* Predicate uses index */

where (
         (t1.file_id           = @receivedFileContentRecID) 
     and (t1.tx_control_number = @tx_control_number) 
	 and (t1.loop_name         = @loop_name)
	 and (t1.segment_name      = 'RDM')
     and (t1.element_pos > 1)
     and (t1.id is not null)	 
)
group by
   t1.file_id
 , t1.tx_control_number
 , t1.line_number

)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_RDM] TO [webuser]
GO