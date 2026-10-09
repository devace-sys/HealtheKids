use spedmon
go

create or alter view dbo.[VIEW_PROMISED_SERVICES_IMPORTS] as
 SELECT
   f.id as [Import #],
   [file_name],
   client_id,
   began_processing,
   done_processing,
   error_str,
   r.*
 FROM
 dbo.[Import_From_A.5_SERVICES_From_Client_Files] f LEFT JOIN dbo.[Import_From_A.5_SERVICES_From_Client_File_Rows] r
   ON File_import_log_entry = f.id
GO