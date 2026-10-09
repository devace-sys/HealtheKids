USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Service_Dates') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Service_Dates
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Service_Dates */    
/**    
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Service_Dates] (
   @receivedFileContentRecID bigint
 , @tx_control_number        varchar(255)
) 

RETURNS 
TABLE
AS     
RETURN
(
  select    
      lx.*
	, [service_period_start_(2110_0800_DTM_DTM02)] = svc_ps.[date]
	, [service_period_end_(2110_0800_DTM_DTM02)]   = svc_pe.[date]
	, [service_date_(2110_0800_DTM_DTM02)]         = svc_d.[date]

  from      dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header (@receivedFileContentRecID, @tx_control_number)                as lx

  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM (@receivedFileContentRecID, @tx_control_number, '2110', '150',null) as svc_ps on svc_ps.line_number   = lx.line_number
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM (@receivedFileContentRecID, @tx_control_number, '2110', '151',null) as svc_pe on svc_pe.line_number   = lx.line_number  
  left join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM (@receivedFileContentRecID, @tx_control_number, '2110', '472',null) as svc_d  on svc_d.line_number    = lx.line_number
)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Service_Dates] TO [webuser]
GO