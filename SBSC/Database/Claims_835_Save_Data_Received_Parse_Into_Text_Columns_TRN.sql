USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN */    
/**    
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN] (
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
 , trace_type_code                          = max(case when t1.element_pos   = 2  then element_value end)
 , check_or_eft_trace_number                = max(case when t1.element_pos   = 3  then element_value end)
 , originating_company_identifier           = max(case when t1.element_pos   = 4  then element_value end)
 , originating_company_supplemental_code    = max(case when t1.element_pos   = 5  then element_value end)
 
 from dbo.Claims_835_Data_Received_File_Content_Parsed as t1
 
 /* Predicate uses index */
 
 where (
         (t1.file_id           = @receivedFileContentRecID) 
     and (t1.tx_control_number = @tx_control_number) 
     and (t1.loop_name is not null)
	 and (t1.segment_name      = 'TRN')
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
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_TRN] TO [webuser]
GO