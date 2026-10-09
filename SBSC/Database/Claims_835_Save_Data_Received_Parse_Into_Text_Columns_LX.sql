USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX */    
/**    
 * Extracts data
 *
 * Note: This routines purpose is to return line numbers that are generated
 * when we parse an 835.
 *
 * It was originally based on line numbers we generated based on LX segments 
 * since the 835 for the LEA BOP includes LX segments for every individual CLP 
 * but it now references the CLP segment.
 *
 * We are assigning line numbers based on the CLP segments instead of LX 
 * because the 835 implementation guide states that LX is used to provide
 * a hiearchy for sorting purposes and it is NOT required but CLP is required
 * and CLP is next in the hierarchy chain.  
 *
 * Case in point the 835 for the CYBHI program uses LX to "group by" practitioner
 * and cannot be relied on for providing a line number for each claim.
 *
 * The CLP segment however is required and we can use it in combination with
 * some internal counters we generate to provide a reliable line number. 
 ***************************************************************************/  

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX] (
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
 , lx_assigned_number = cp.line_number
  
from dbo.Claims_835_Data_Received_File_Content_Parsed as cp 

/* Predicate uses index */

where (
        (cp.file_id            = @receivedFileContentRecID) 
     and (cp.tx_control_number = @tx_control_number) 
	 and (cp.loop_name         = '2100')
	 and (cp.segment_name      = 'CLP') /* CLP is required.  Was originally LX */	 
	 and (cp.element_pos       = 2)     /* 2 is a required element inside CLP */
	 and (cp.id is not null)
)
order by 
  cp.line_number
offset 0 rows 
)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LX] TO [webuser]
GO