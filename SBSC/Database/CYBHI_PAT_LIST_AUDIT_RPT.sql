USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CYBHI_PAT_LIST_AUDIT_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CYBHI_PAT_LIST_AUDIT_RPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CYBHI_PAT_LIST_AUDIT_RPT] (
  @clientID  BIGINT
)

/***************************************************************************    
 * CYBHI_PAT_LIST_AUDIT_RPT */    
/**    
 * Returns complete list of patients and if they can be included in
 * the TPA export and (if not) reasons why.
 *
 * This is essentially a pass through routine for CYBHI_PAT_LIST_RPT_CORE.
 * 
 ***************************************************************************/            

RETURNS TABLE

AS RETURN (
  
  select       
      [Record Number]
	, [CanExportRow] 
	, [ProblemsDetected] 
	, [Carelon PARENT Code]
	, [Submitter ID]	   
	, [Registering Provider ID]
	, [Enrollment Indicator]	
	, [Enrollment Start Date]	
	, [Enrollment End Date]    
	, [Carelon Assigned Member ID]
	, [Student ID]	  
	, [Last Name]	
	, [First Name]	
	, [Birth Date]	
	, [Unknown Address]	
	, [Member is Homeless]	
	, [Street Address Line 1]	
	, [City]	 
	, [State]	
	, [Zip Code]
	, [Gender At Birth]	
	, [Insurance Carrier Code 1]
	, [Insurance Policy Member ID 1]	
	, [Insurance Subscriber First Name 1]	
	, [Insurance Subscriber Last Name 1]	
	, [Insurance Primacy Indicator 1]	    
	, [Insurance Group Number 1]
	, [Insurance Carrier Code 2]	
	, [Insurance Policy Member ID 2]	
	, [Insurance Subscriber First Name 2]
	, [Insurance Subscriber Last Name 2]	
	, [Insurance Primacy Indicator 2]	 
	, [Insurance Group Number 2]
	, [No Phone]                
	, [Home Phone Area Code]    
	, [Home Phone Exchange Number]
	, [Home Phone Suffix]         
	, [FERPA Consent]    
	, [Enrollment State] 
	
  from dbo.CYBHI_PAT_LIST_RPT_CORE (@clientID, 0) as t1 
  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[CYBHI_PAT_LIST_AUDIT_RPT] TO [webuser]
GO