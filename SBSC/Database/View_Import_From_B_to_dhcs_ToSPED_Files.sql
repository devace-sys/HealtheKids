use spedmon
go

--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[View_Import_From_B_to_dhcs_ToSPED_Files]'))
create or alter view [dbo].[View_Import_From_B_to_dhcs_ToSPED_Files] as
  with successful_C_runs as (
    select
      min(id) C_id, -- note: we are expecting 1.  But, just in case...
      TO_DHCS_log_entry
    FROM [View_Import_From_C_from_dhcs_ToSPED_Files]
    WHERE return_file_successfully_processed = 1
    GROUP BY TO_DHCS_log_entry
  )
  select B.*,
    CASE WHEN C.C_id IS NULL THEN 1 ELSE 0 END "awaiting_return_file",
    CASE WHEN C.C_id IS NOT NULL THEN 1 ELSE 0 END "return_file_processed_completed",
    C.C_id "ID_successful_Import_From_C_from_dhcs"
  FROM [dbo].[Import_From_B_to_dhcs_ToSPED_Files] B
  LEFT JOIN successful_C_runs C ON B.id = C.TO_DHCS_log_entry

GO
