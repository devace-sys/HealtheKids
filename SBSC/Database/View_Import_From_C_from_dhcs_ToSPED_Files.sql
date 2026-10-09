use spedmon
go

--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[View_Import_From_C_from_dhcs_ToSPED_Files]'))
create or alter view [dbo].[View_Import_From_C_from_dhcs_ToSPED_Files] as
  select
    *, 
    committed_transaction "return_file_successfully_processed", -- we're abstracting the logic of what counts as a "successful" run.
  -- here, any committed transaction is considered successful; we will not process the file a second time.
  --   However, I suppose we could change our minds and make it more stringent, down the road.
    CASE WHEN (error_str IS NULL OR TRIM(error_str) = '') AND COUNT_multiple_return = 0 THEN 1 ELSE 0 END "no_warning_alerts"
    -- This logic can also be re-defined at will.
  FROM [dbo].[Import_From_C_from_dhcs_ToSPED_Files];   
go
