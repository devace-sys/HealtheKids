USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[IMPORT_FROM_835_LATEST_PATIENT_DATA_CHANGES]'))
DROP VIEW [dbo].[IMPORT_FROM_835_LATEST_PATIENT_DATA_CHANGES]
GO

CREATE VIEW [dbo].[IMPORT_FROM_835_LATEST_PATIENT_DATA_CHANGES] 
AS 

/***************************************************************************    
 * IMPORT_FROM_835_LATEST_PATIENT_DATA_CHANGES */
/**    
 *
 * @returns table
 ***************************************************************************/     

with
cte_get_latest_patient_data_correction_record_data_p1
as
(
  select
      CLIENT_NPI
    , PATIENT_BIC
    , LATEST_CHECK_DATE = MAX(CHECK_DATE)
  from
  (
    select 
 
      CLIENT_NPI  = t1.[client_npi_(1000B_0800_N1_N107)]
    , PATIENT_BIC = t1.[patient_bic_(2100_0300_NM1_109)]
    , CHECK_DATE  = t2.[check_issue_or_eft_effective_date_(BPR_0200_BPR16)]

    from dbo.Claims_835_Data_Received_File_Content       as  t0 
	join dbo.Import_From_835_DS_00A_Patient_Data_Changes as  t1 on t1.file_id = t0.id
    join dbo.Import_From_835_DS_001_Checks               as  t2 on t2.file_id = t1.file_id
                                                         and t2.tx_control_number = t1.tx_control_number
                                                         and t2.[client_npi_(1000B_0800_N1_N107)] = t1.[client_npi_(1000B_0800_N1_N107)]
    where
	  (t0.billingProgramID = 1) /* Limit to 835 files from LEA BOP */
  ) as q1
  group by
      CLIENT_NPI
    , PATIENT_BIC
)
,

cte_get_latest_patient_data_correction_record_data_p2
as
(
  select 
      
      CLIENT_NPI               = convert(nchar(10),    upper(trim(isnull(t1.CLIENT_NPI,  ''))))
    , PATIENT_BIC              = convert(nvarchar(14), upper(trim(isnull(t1.PATIENT_BIC, ''))))
    , PATIENT_LAST_CORRECTED   = convert(nvarchar(50), upper(trim(isnull(t3.[patient_last_corrected_(2100_0300_NM1_103)]       , ''))))
    , PATIENT_FIRST_CORRECTED  = convert(nvarchar(50), upper(trim(isnull(t3.[patient_first_name_corrected_(2100_0300_NM1_104)] , ''))))
    , PATIENT_MIDDLE_CORRECTED = convert(nvarchar(50), upper(trim(isnull(t3.[patient_middle_name_corrected_(2100_0300_NM1_105)], ''))))
	, t1.LATEST_CHECK_DATE

  from cte_get_latest_patient_data_correction_record_data_p1 as t1
  join dbo.Import_From_835_DS_001_Checks                     as t2 on  t2.[client_npi_(1000B_0800_N1_N107)]                    = t1.CLIENT_NPI
                                                                   and t2.[check_issue_or_eft_effective_date_(BPR_0200_BPR16)] = t1.LATEST_CHECK_DATE
  join dbo.Import_From_835_DS_00A_Patient_Data_Changes       as t3 on  t3.file_id                           = t2.file_id
                                                                   and t3.tx_control_number                 = t2.tx_control_number
	   														       and t3.[client_npi_(1000B_0800_N1_N107)] = t1.[CLIENT_NPI]															   
																   and t3.[patient_bic_(2100_0300_NM1_109)] = t1.[PATIENT_BIC]
)
,
cte_get_latest_patient_data_correction_record_data_p3
as
(
  select 

      clc.CLIENT_ID
    , pap.PATIENT_ID  
    , DHCS_LAST_NAME_OLD     = convert(nvarchar(50),upper(trim(isnull(pap.DHCS_LAST_NAME,   N''))))
    , DHCS_FIRST_NAME_OLD    = convert(nvarchar(50),upper(trim(isnull(pap.DHCS_FIRST_NAME,  N''))))
    , DHCS_MIDDLE_NAME_OLD   = convert(nvarchar(50),upper(trim(isnull(pap.DHCS_MIDDLE_NAME, N''))))
    , DHCS_LAST_NAME_NEW     = p2.PATIENT_LAST_CORRECTED
    , DHCS_FIRST_NAME_NEW    = p2.PATIENT_FIRST_CORRECTED
    , DHCS_MIDDLE_NAME_NEW   = p2.PATIENT_MIDDLE_CORRECTED
  
  from cte_get_latest_patient_data_correction_record_data_p2 as p2
  
  join dbo.CLIENTS_Client   as clc on  clc.NPI        = p2.CLIENT_NPI
  join dbo.PATIENTS_Patient as pap on  pap.BIC        = p2.PATIENT_BIC
  join dbo.PATIENTS_Client  as pac on  pac.CLIENT_ID  = clc.CLIENT_ID
                                   and pac.PATIENT_ID = pap.PATIENT_ID
)
,
cte_get_latest_patient_data_correction_record_data_p4
as
(
select 
   p3.*
  ,LNAME_DIFF = convert(bit,case when checksum(p3.DHCS_LAST_NAME_OLD)  = checksum(p3.DHCS_LAST_NAME_NEW)   then 0 else 1 end)
  ,FNAME_DIFF = convert(bit,case when checksum(p3.DHCS_FIRST_NAME_OLD) = checksum(p3.DHCS_FIRST_NAME_NEW)  then 0 else 1 end)
from cte_get_latest_patient_data_correction_record_data_p3 as p3
)
select * from cte_get_latest_patient_data_correction_record_data_p4
where ((LNAME_DIFF = 1) or (FNAME_DIFF = 1))

GO