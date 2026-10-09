USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.[Patients_Promised_Services_CDE_Audits_Current_Patients_View]
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_View] (
    @userID      bigint
  , @userGroup   int   
  , @userRank    int 
  , @clientID    bigint
  , @patID       bigint  
  , @patAbsentMinsAreSatisfiedMins bit = 1
)
    
returns table     
as
 
return 
(    

select 
       
	  
      [id]     = t1.patientsPromisedServicesCDEAuditsCurrentPatientsID
    , [name]   = pap.CONCAT_NAME
    , [ssid]   = isnull(pap.CSIS,N'')
	, t1.*
	, siteName = ss.SITE_NAME
	, spEdCaseManagerName = isnull(pap.spEdCaseManagerName,'')

from dbo.Patients_Promised_Services_CDE_Audits_Current_Patients_View_Core (
    @clientID
  , @patID
  , @patAbsentMinsAreSatisfiedMins) as t1

join dbo.PATIENTS_Patient                                                                     as pap on pap.PATIENT_ID   = t1.patID
join dbo.SITES_Site                                                                           as ss  on ss.SITE_ID = t1.siteID


) 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Patients_Promised_Services_CDE_Audits_Current_Patients_View] TO [webuser]
GO