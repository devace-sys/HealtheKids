USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_AMT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_AMT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_AMT */    
/**    
 * Extracts data
 ***************************************************************************/  

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_AMT] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
 , @loop_name                varchar(255)
 , @amount_qualifier_code    varchar(255)
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
 , amount_qualifier_code   = max(case when t1.element_pos   = 2  then element_value end) 
 , monetary_amount         = max(case when t1.element_pos   = 3  then element_value end) 
 , credit_debit_flag_code  = max(case when t1.element_pos   = 4  then element_value end) 
 
from dbo.Claims_835_Data_Received_File_Content_Parsed as t1
join (
  select distinct
    segment_idx
  from dbo.Claims_835_Data_Received_File_Content_Parsed as t2
  /* Predicate uses index */
  where (
           (t2.file_id           = @receivedFileContentRecID) 
       and (t2.tx_control_number = @tx_control_number) 
	   and (t2.loop_name         = @loop_name)
	   and (t2.segment_name      = 'AMT')
	   and (t2.element_pos       = 2)
	   and (t2.element_value     = @amount_qualifier_code)
	   and (t2.id is not null)
  )
) as t3 on t3.segment_idx = t1.segment_idx
/* Predicate uses index */
where (
         (t1.file_id           = @receivedFileContentRecID) 
     and (t1.tx_control_number = @tx_control_number) 
	 and (t1.loop_name         = @loop_name)
	 and (t1.segment_name      = 'AMT')
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
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_AMT] TO [webuser]
GO