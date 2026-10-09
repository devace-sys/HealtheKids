USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB */    
/**    
 * Extracts data for a PLB segment
 *
 * Note: We are using the technique where we include the segment number
 * in the group by to handle multiple PLB segments within a tx_control_number
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB] (
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
 , t1.segment_num

 , provider_identifier                 = max(case when t1.element_pos   = 2  then element_value end)
 , last_date_of_providers_fiscal_year  = try_convert(date,max(case when t1.element_pos   = 3  then element_value end)) 
 , adjustment_identifier_1             = max(case when t1.element_pos   = 4  then element_value end)
 , monetary_amount_1                   = try_convert(money,max(case when t1.element_pos   = 5  then element_value end))
 , adjustment_identifier_2             = max(case when t1.element_pos   = 6  then element_value end)
 , monetary_amount_2                   = try_convert(money,max(case when t1.element_pos   = 7  then element_value end))
 , adjustment_identifier_3             = max(case when t1.element_pos   = 8  then element_value end)
 , monetary_amount_3                   = try_convert(money,max(case when t1.element_pos   = 9  then element_value end))
 , adjustment_identifier_4             = max(case when t1.element_pos   = 10  then element_value end)
 , monetary_amount_4                   = try_convert(money,max(case when t1.element_pos   = 11  then element_value end))
 , adjustment_identifier_5             = max(case when t1.element_pos   = 12  then element_value end)
 , monetary_amount_5                   = try_convert(money,max(case when t1.element_pos   = 13  then element_value end))
 , adjustment_identifier_6             = max(case when t1.element_pos   = 14  then element_value end)
 , monetary_amount_6                   = try_convert(money,max(case when t1.element_pos   = 15  then element_value end))


 from dbo.Claims_835_Data_Received_File_Content_Parsed as t1

 /* Predicate uses index */

where (
         (t1.file_id           = @receivedFileContentRecID) 
     and (t1.tx_control_number = @tx_control_number) 
     and (t1.loop_name is not null)
     and (t1.segment_name      = 'PLB')
     and (t1.element_pos > 1)
	 and (t1.id is not null)
)

group by
   t1.file_id
 , t1.tx_control_number
 , t1.segment_num

 )
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_PLB] TO [webuser]
GO