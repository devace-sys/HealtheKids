USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates */    
/**    
 * 
 * Extracts data
 ***************************************************************************/   

CREATE FUNCTION [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates] (
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
  
    , [proc_mod_combo_paid_(2110_0700_SVC_SVC01)]      = svc.svc_proc_mod_combo_paid
    , [amount_submitted_(2110_0700_SVC_SVC02)]         = svc.svc_amount_submitted
    , [amount_paid_(2110_0700_SVC_SVC03)]              = svc.svc_amount_paid
    , [revenue_code_(2110_0700_SVC_SVC04)]             = svc.svc_revenue_code
    , [units_paid_(2110_0700_SVC_SVC05)]               = svc.svc_units_paid
    , [proc_mod_combo_submitted_(2110_0700_SVC_SVC06)] = svc.svc_proc_mod_combo_submitted
    , [units_submitted_(2110_0700_SVC_SVC07)]          = svc.svc_units_submitted    
	
	, [service_period_start_(2110_0800_DTM_DTM02)]     = svc_ps.[date]
	, [service_period_end_(2110_0800_DTM_DTM02)]       = svc_pe.[date]
	, [service_date_(2110_0800_DTM_DTM02)]             = svc_d.[date]
    , [line_item_control_number_(2110_1000)]           = licn.reference_identification
	
	, svc.segment_idx

  from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Detail_Line_Header (@receivedFileContentRecID, @tx_control_number) as lx  
  join dbo.Import_From_835_DS_002_Claim_Level_Claim_Payment_Info_Patient_Name_Claim_Dates as clp on ((clp.file_id = lx.file_id) and (clp.tx_control_number = lx.tx_control_number) and (clp.line_number = lx.line_number))
  join dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_SVC (@receivedFileContentRecID, @tx_control_number) as svc on svc.line_number = clp.line_number  
    
  outer apply (
    select top 1 
	  dps.[date] 
    from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM (  @receivedFileContentRecID
	                                                                    , @tx_control_number
																		, '2110'
																		, '150'
																		, svc.segment_idx) as dps 
    where (
          (dps.line_number = svc.line_number) 
      and (dps.related_to_segment_idx = svc.segment_idx)
    )
  ) as svc_ps

  outer apply (
    select top 1 
	  dpe.[date] 
    from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM (  @receivedFileContentRecID
	                                                                    , @tx_control_number
																		, '2110'
																		, '151'
																		, svc.segment_idx) as dpe 
    where (
          (dpe.line_number            = svc.line_number) 
      and (dpe.related_to_segment_idx = svc.segment_idx)
    )
  ) as svc_pe

  outer apply (
    select top 1 
	  dd.[date] 
    from dbo.Claims_835_Save_Data_Received_Parse_Into_Text_Columns_DTM (  @receivedFileContentRecID
	                                                                    , @tx_control_number
																		, '2110'
																		, '472'
																		, svc.segment_idx) as dd 
    where (
          (dd.line_number            = svc.line_number) 
      and (dd.related_to_segment_idx = svc.segment_idx)
    )
  ) as svc_d
  
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
 
GRANT SELECT ON  [dbo].[Claims_835_Save_Data_Received_Parse_Into_Text_Columns_Service_Level_Payment_Information_Service_Dates] TO [webuser]
GO