use spedmon
go

create or alter view [dbo].[View_RMTS_SMAA_Info_Unfiltered] as
  SELECT rtn.ID
      ,rtn.TO_DHCS_log_entry
      ,rtn.B_FILE_ROW_NUM
      ,rtn.C_FILE_ROW_NUM
      ,rtn.PatientID
      ,rtn.in_return_file
      ,rtn.new_BIC
      ,rtn.BIC_changed
      ,rtn.BIC_noReturn
      ,rtn.multiple_return
      ,rtn.NOTE
      ,rtn.SSN
      ,rtn.Last_Name_Sent
      ,rtn.First_Name_Sent
      ,rtn.MI_Sent
      ,rtn.DOB_Sent
      ,rtn.Sex_Sent
      ,rtn.Client_First_9_of_NPI
      ,rtn.School_Name
      ,rtn.File_Number
      ,rtn.Last_Pop
      ,rtn.County_Code
      ,rtn.BIC
      ,rtn.BIC_Issue_Date
      ,rtn.Filler_01
      ,rtn.Match_Indicator
      ,rtn.Eligibility_Indicator
      ,rtn.Filler_02
      ,rtn.Current_Month_Eligibility
      ,rtn.Current_Month_SOC_Amount
      ,rtn.Current_Month_Cert_Day
      ,rtn.Current_Month_OHC_Indicator
      ,rtn.JAN_Eligibility
      ,rtn.JAN_SOC_Amount
      ,rtn.JAN_Cert_Day
      ,rtn.JAN_OHC_Indicator
      ,rtn.FEB_Eligibility
      ,rtn.FEB_SOC_Amount
      ,rtn.FEB_Cert_Day
      ,rtn.FEB_OHC_Indicator
      ,rtn.MAR_Eligibility
      ,rtn.MAR_SOC_Amount
      ,rtn.MAR_Cert_Day
      ,rtn.MAR_OHC_Indicator
      ,rtn.APR_Eligibility
      ,rtn.APR_SOC_Amount
      ,rtn.APR_Cert_Day
      ,rtn.APR_OHC_Indicator
      ,rtn.MAY_Eligibility
      ,rtn.MAY_SOC_Amount
      ,rtn.MAT_Cert_Day
      ,rtn.MAY_OHC__Indicator
      ,rtn.JUN_Eligibility
      ,rtn.JUN_SOC_Amount
      ,rtn.JUN_Cert_Day
      ,rtn.JUN_OHC_Indicator
      ,rtn.JUL_Eligibility
      ,rtn.JUL_SOC_Amount
      ,rtn.JUL_Cert_Day
      ,rtn.JUL_OHC_Indicator
      ,rtn.AUG_Eligibility
      ,rtn.AUG_SOC_Amount
      ,rtn.AUG_Cert_Day
      ,rtn.AUG_OHC_Indicator
      ,rtn.SEP_Eligibility
      ,rtn.SEP_SOC_Amount
      ,rtn.SEP_Cert_Day
      ,rtn.SEP_OHC_Indicator
      ,rtn.OCT_Eligibility
      ,rtn.OCT_SOC_Amount
      ,rtn.OCT_Cert_Day
      ,rtn.OCT_OHC_Indicator
      ,rtn.NOV_Eligibility
      ,rtn.NOV_SOC_Amount
      ,rtn.NOV_Cert_Day
      ,rtn.NOV_OHC_Indicator
      ,rtn.DEC_Eligibility
      ,rtn.DEC_SOC_Amount
      ,rtn.DEC_Cert_Day
      ,rtn.DEC_OHC_Indicator
      ,rtn.Meds_Current_Date
      ,cc.CLIENT_CDS
      ,cc.CLIENT_NAME
      ,pp.LASTPOP
	  
	  , rtn.FFPqualified
	  , CurLeaBopElig = iif( ((rtn.Current_Month_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , JanLeaBopElig = iif( ((rtn.JAN_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , FebLeaBopElig = iif( ((rtn.FEB_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , MarLeaBopElig = iif( ((rtn.MAR_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , AprLeaBopElig = iif( ((rtn.APR_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , MayLeaBopElig = iif( ((rtn.MAY_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , JunLeaBopElig = iif( ((rtn.JUN_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , JulLeaBopElig = iif( ((rtn.JUL_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , AugLeaBopElig = iif( ((rtn.AUG_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , SepLeaBopElig = iif( ((rtn.SEP_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , OctLeaBopElig = iif( ((rtn.OCT_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , NovLeaBopElig = iif( ((rtn.NOV_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')
	  , DecLeaBopElig = iif( ((rtn.DEC_Eligibility = 'Y') and (rtn.FFPqualified = 1)),'Y','N')

  FROM [spedmon].[dbo].[Import_From_B_and_C_File_rows] as rtn
  JOIN [dbo].[CLIENTS_Client] as cc on substring(cc.npi,1,9) = rtn.Client_First_9_of_NPI
  JOIN [dbo].PATIENTS_Patient pp ON rtn.PatientID = pp.PATIENT_ID
GO