USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code */    
/**    
 * 
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code] (
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
    , [claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]   = clp.[claim_submitter_claim_tracking_id_(2100_0100_CLP_CLP01)]
	, [claim_control_number_(2100_0100_CLP_CLP07)]                = clp.[claim_control_number_(2100_0100_CLP_CLP07)]        
    , [code_list_qualifier_code_(2110_1300_LQ_LQ01)] = lq.code_list_qualifier_code
    , [remark_code_(2110_1300_LQ_LQ02)]              = lq.remark_code    
	, [line_item_control_number_(2110_1000)]         = licn.reference_identification

  from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header  (@receivedFileContentRecID, @tx_control_number) as lx  
  join dbo.Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates as clp on clp.file_id = lx.file_id and clp.tx_control_number = lx.tx_control_number and clp.line_number = lx.line_number
  join dbo.Import_From_835_DS_004_Service_Level_Payment_Info_Service_Dates as svc on  svc.file_id = clp.file_id and svc.tx_control_number = clp.tx_control_number and svc.line_number = clp.line_number

  cross apply (
    select 
      l.* 
    from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_LQ (@receivedFileContentRecID, @tx_control_number, svc.segment_idx) as l
    where (
	      (l.line_number = svc.line_number)
	  and (l.related_to_segment_idx = svc.segment_idx)           
	)
  ) as lq

  outer apply (
    select top 1 
      ref6r.reference_identification 
    from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_REF ( @receivedFileContentRecID
                                                                        , @tx_control_number
																	    , '2110'
																	    , '6R'
																	    , svc.segment_idx) as ref6r
    where (
	       (ref6r.line_number = svc.line_number)
      and  (ref6r.related_to_segment_idx = svc.segment_idx)
	)
  ) as licn

  where ((lx.file_id = @receivedFileContentRecID) and (lx.tx_control_number = @tx_control_number))

)

GO

/*------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Health_Care_Remark_Code] TO [webuser]
GO