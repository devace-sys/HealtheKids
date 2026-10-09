USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_CURRENT_MCAL_BENEFITS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_CURRENT_MCAL_BENEFITS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENTS_CURRENT_MCAL_BENEFITS_VIEW_CORE] (
	  @clientID                 BIGINT    
	, @patID                    BIGINT
)
     
RETURNS TABLE  

AS RETURN(
  with 
  
  /* Limit patients to matches from latest pop file import */

  cte_p0
  as
  (
  select 
      CLIENT_ID   = t1.clientID
    , PATIENT_ID  = t2.Matched_PatientID 
  from dbo.View_Latest_Successful_Total_Pop_Imports   as t1
  join dbo.Import_From_A_From_Client_ToSPED_File_rows as t2 on t2.FROM_CLIENT_log_entry = t1.latestImportFromID
  where 
    (t1.clientID = @clientID)
  )
  ,
  cte_p1
  as
  (
    select 
        pac.CLIENT_ID
	  , pac.PATIENT_ID
	  , [PATIENT_NAME]                             = pap.CONCAT_NAME
	  , pap.DATE_OF_BIRTH
	  , PATIENT_CURRENT_AGE                        = DATEDIFF(year,pap.DATE_OF_BIRTH,getdate()) 
	  , SSID                                       = isnull(pap.CSIS,N'')
      , BIC                                        = trim(isnull(pap.BIC,N''))
      , CURRENT_CONSENT_STATUS_VAL                 = pap.parentConsentMCAL
      , CURRENT_CONSENT_STATUS_EFF_DATE_VAL        = pap.parentConsentMCALEffectiveDate
      , CURRENT_CONSENT_STATUS_NOTES               = isnull(pap.parentConsentMCALNotes,'')
      , HAS_UNKNOWN_CONSENT                        = convert(bit,(iif((pap.parentConsentMCAL is null),1,0)))
	  , LATEST_DATE_MCAL_Y                         = pen2.MONTH_DATE
	  , MCAL_OUTREACH_NOTES                        = trim(isnull(pap.mcalOutreachNotes,''))
	  , spEdCaseManagerName                        = trim(isnull(pap.spEdCaseManagerName,''))
	  , altFormat                                  = trim(isnull(pap.altFormat,''))
    from cte_p0                  as p0
	join dbo.PATIENTS_Client     as pac on pac.CLIENT_ID = p0.CLIENT_ID and pac.PATIENT_ID = p0.PATIENT_ID
    join dbo.PATIENTS_Patient    as pap on pap.PATIENT_ID = pac.PATIENT_ID

	outer apply (
	  select top 1 
        pen1.MONTH_DATE 
	  from dbo.PATIENTS_ELIGIBILITY_NORMALIZED as pen1 
	  where (     
	            (pen1.PATIENT_ID = pac.PATIENT_ID)
	        and (pen1.IS_ELIG = 1)
      )
	  order by 
	    pen1.MONTH_DATE desc
	) as pen2
    
	
	where ( 
          (1=1)
	  and ((@patID is null) or (p0.PATIENT_ID = @patID)) 
      and (pap.ACTIVE = N'Y') 
    )
  )
  ,

  /* Limit patients to ages 22 or younger */

  cte_p2
  as
  (
    select 
        p1.* 
      , PATIENT_HAS_BIC             = convert(bit,(iif(p1.BIC = N'',0,1)))
      , LATEST_MCAL_Y_MONTHS_AGO    = datediff(month,p1.LATEST_DATE_MCAL_Y,getdate())
      , hasAltFormat = convert(bit, (case 	      
		    when p1.altFormat = 'NO ALTERNATE FORMAT NEEDED' then 0
		    when p1.altFormat = ''                           then 0
		    else 1 
		  end))	  
	from cte_p1 as p1
	where (    
      (p1.PATIENT_CURRENT_AGE <= 22)  /* Limit to 22 or younger */
    )
  )
  ,
  cte_p3
  as
  (
  select 
       p2.*    
     , CURRENT_BENEFIT_STATUS_CODE = 
        case when (p2.PATIENT_HAS_BIC = 1) then 
          case when (p2.LATEST_MCAL_Y_MONTHS_AGO <= 2) then 1  /* Current */
               when (p2.LATEST_DATE_MCAL_Y > 2)        then 2  /* Expired */
               else                                         3  /* Unknown*/
       end
       else 
         3 /* Unknown */
     end
    from cte_p2 as p2
  )

  select 
      [id]                                   = p3.PATIENT_ID
    , [name]                                 = p3.PATIENT_NAME
    , dob                                    = p3.DATE_OF_BIRTH
    , patCurrentAge                          = p3.PATIENT_CURRENT_AGE
    , patSSID                                = p3.SSID
    , patBIC                                 = p3.BIC   
    , patHasBIC                              = p3.PATIENT_HAS_BIC
	, currentBenefitsStatusCode              = p3.CURRENT_BENEFIT_STATUS_CODE
	, latestDateMCALElig                     = p3.LATEST_DATE_MCAL_Y
    , lastEligibleForMcalMonthsAgo           = p3.LATEST_MCAL_Y_MONTHS_AGO   
    , currentParentConsentStatusVal          = p3.CURRENT_CONSENT_STATUS_VAL
    , currentParentConsentStatusEffDate      = p3.CURRENT_CONSENT_STATUS_EFF_DATE_VAL
    , currentParentConsentStatusEffDateNotes = p3.CURRENT_CONSENT_STATUS_NOTES  
    , currentParentConsentStatusIsUnknown    = p3.HAS_UNKNOWN_CONSENT    
	, clientID                               = p3.CLIENT_ID
	, patID                                  = p3.PATIENT_ID
	, notes                                  = p3.MCAL_OUTREACH_NOTES
	, p3.spEdCaseManagerName
	, p3.altFormat
	, p3.hasAltFormat

  from cte_p3 as p3

)     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_CURRENT_MCAL_BENEFITS_VIEW_CORE] TO [webuser]
GO