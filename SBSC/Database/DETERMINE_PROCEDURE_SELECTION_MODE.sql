use SPEDMON
go

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DETERMINE_PROCEDURE_SELECTION_MODE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DETERMINE_PROCEDURE_SELECTION_MODE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * DETERMINE_PROCEDURE_SELECTION_MODE */    
/**    
 * Determines mode to use when selecting claim procedures
 * The mode determines how to use the claim procedure data
 *
 * @return               tinyint
 ***************************************************************************/   

CREATE FUNCTION dbo.[DETERMINE_PROCEDURE_SELECTION_MODE] (    
    @procedure_is_service_selection                    bit
  , @procedure_is_cpt_procedure                        bit
  , @select_proc_for_claim_using_child_procs           bit
  , @select_proc_for_claim_using_name_id_and_proc_data bit 
  , @select_proc_for_claim_using_svc_det_flags         bit
  , @service_entry_svc_detail_flags_required           bit
  , @select_proc_for_claim_using_num_mins              bit
  , @select_proc_for_claim_using_num_mins_min_count    int
) 
RETURNS tinyint
WITH SCHEMABINDING
AS 
BEGIN

if (@procedure_is_service_selection = 0) return 0

/*=====================================================
  *
  * Procedure Selection Mode 1
  *
  * If the selection service + proc record indicates 
  *
  * - it is not a CPT procedure
  * - select procs for claim using child procedures
  * - dont select procs using nameid and proc data
  * - dont select procs using service detail flags
  * - service entry svc detail flags are required
  *   (because child records require them) 
  *  - dont select proc using num units
  *=====================================================*/

if (
      (@procedure_is_cpt_procedure                        = 0)
  and (@select_proc_for_claim_using_child_procs           = 1)
  and (@select_proc_for_claim_using_name_id_and_proc_data = 0) 
  and (@select_proc_for_claim_using_svc_det_flags         = 0)
  and (@service_entry_svc_detail_flags_required           = 1)
  and (@select_proc_for_claim_using_num_mins              = 0)
  and (@select_proc_for_claim_using_num_mins_min_count    = -1)
)
begin
  return 1
end

/*=====================================================
 *
 * Procedure Selection and Unit Calculation Mode 2
 *
 * If the selection service + proc record indicates 
 *
 * - it is a CPT procedure
 * - dont select procs for claim using child procedures
 * - select procs using nameid and proc data
 * - dont select procs using service detail flags
 * - no service entry svc detail flags are required
 * - dont select proc using num units
 *=====================================================*/     


else if ( 
      (@procedure_is_cpt_procedure                        = 1)
  and (@select_proc_for_claim_using_child_procs           = 0)
  and (@select_proc_for_claim_using_name_id_and_proc_data = 1) 
  and (@select_proc_for_claim_using_svc_det_flags         = 0)
  and (@service_entry_svc_detail_flags_required           = 0)
  and (@select_proc_for_claim_using_num_mins              = 0)
  and (@select_proc_for_claim_using_num_mins_min_count    = -1)
)
begin
  return 2
end

/*=====================================================
  *
  * Procedure Selection Mode 3
  *
  * If the selection service + proc record indicates 
  *
  * - it is not a CPT procedure
  * - select procs for claim using child procedures
  * - dont select procs using nameid and proc data
  * - dont select procs using service detail flags
  * - service entry svc detail flags are not required
  * - select proc using num mins
  *=====================================================*/     

else if (
      (@procedure_is_cpt_procedure                        = 0)
  and (@select_proc_for_claim_using_child_procs           = 1)
  and (@select_proc_for_claim_using_name_id_and_proc_data = 0) 
  and (@select_proc_for_claim_using_svc_det_flags         = 0)
  and (@service_entry_svc_detail_flags_required           = 0)
  and (@select_proc_for_claim_using_num_mins              = 1)
  and (@select_proc_for_claim_using_num_mins_min_count    = 0)
)
begin
  return 3
end

else

/* Unknown mode */

begin
  return 0
end
  
return 0

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[DETERMINE_PROCEDURE_SELECTION_MODE] TO [webuser]
GO