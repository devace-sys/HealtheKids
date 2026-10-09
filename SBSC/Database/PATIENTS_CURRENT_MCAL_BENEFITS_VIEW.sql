USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_CURRENT_MCAL_BENEFITS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_CURRENT_MCAL_BENEFITS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENTS_CURRENT_MCAL_BENEFITS_VIEW] (
	   @userID                   BigInt    
	 , @userGroup                Int    
	 , @userRank                 Int 
	 , @clientID                 BigInt    
	 , @currentBenefitStatusCode Int    /* 1= Current, 2= Expired, 3 = Unknown */
	 , @patID                    BigInt
	 , @recID                    Bigint
	 , @hasAltFormat             bit
)
     
RETURNS TABLE  

AS RETURN(

select top (dbo.CONST_MAX_ROWS())

    t1.* 
  , dobStr                                       = dbo.RPT_DATE_FMT(t1.dob)
  , latestDateMcalEligStr                        = dbo.RPT_DATE_FMT(t1.latestDateMCALElig)
  , latestDateMCALEligStrMoYr                    = dbo.RPT_DATE_FMT_MONTH_YEAR(t1.latestDateMCALElig,0)
  , currentParentConsentStatusStr                = dbo.RPT_BIT_TO_YNU(t1.currentParentConsentStatusVal)
  , currentParentConsentStatusEffDateStr         = dbo.RPT_DATE_FMT(t1.currentParentConsentStatusEffDate)
  , currentParentConsentStatusEffDateStrYYYYMMDD = dbo.RPT_DATE_FMT_YYYY_MM_DD(t1.currentParentConsentStatusEffDate)
  , patStudentID                                 = isnull(ps.STUDENT_ID,N'')
  , pgContacts                                   = isnull(pgs2.pgContacts,'')	
  , currentBenefitsStatusName = case 
      when t1.currentBenefitsStatusCode = 1 then 'Current'
      when t1.currentBenefitsStatusCode = 2 then 'Expired'
      when t1.currentBenefitsStatusCode = 3 then 'Unknown'
      else 'Unknown'
	end
  , currentSiteName = ps.SITE_NAME

from dbo.PATIENTS_CURRENT_MCAL_BENEFITS_VIEW_CORE (@clientID, @patID) as t1
join dbo.PATIENTS_SITES_VIEW_CURRENT              (@clientID)         as ps on ps.PATIENT_ID = t1.patID

outer apply (
    select 
 	    pgContacts  = STRING_AGG(convert(varchar(max),pgContact),(CHAR(13)+Char(10)+CHAR(13)+Char(10)))	  
	from
	(
	  select 
	      pgContact = 		            					 					 
					 + trim(isnull(perp1.FIRST_NAME,'')) 
		             + ' ' 
					 + trim(isnull(perp1.LAST_NAME,'')) 
					 + CHAR(13) + Char(10)
					 + 'Email: ' + trim(isnull(perp1.EMAIL,''))
					 + CHAR(13) + Char(10)
					 + 'Phone: ' + trim(isnull(perp1.PHONE,''))
	  from dbo.PATIENTS_PERSON as patp1 
	  join dbo.PERSONS_PERSON  as perp1 on perp1.ID = patp1.PERSON_ID
	  where     
	    (
	            (patp1.CLIENT_ID = t1.clientID)
	        and (patp1.PATIENT_ID = t1.patID))
		    and (perp1.CLASS_ID_1 = 1)		  
    ) as pgs1
  ) as pgs2

where (
      (t1.currentBenefitsStatusCode = @currentBenefitStatusCode)  
  and ((@hasAltFormat is null) or (t1.hasAltFormat = @hasAltFormat))
)

order by
  t1.[name]
)     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_CURRENT_MCAL_BENEFITS_VIEW] TO [webuser]
GO