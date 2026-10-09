USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW
GO

/*****************************************************************************************************
* IMPORTANT
* 
* For employee relationship, we are NOT going based off "dbo.EMPLOYMENT_RELATIONSHIPS"
* Instead we have: 
*      10: Employee
*      20: Contractor
*      30: Not on TSP
*      40: Duplicate
******************************************************************************************************/

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW] ( 
	   @userID            BigInt    
	 , @userGroup         Int    
	 , @userRank          Int 
	 , @clientID          BigInt    
	 , @fiscalYearID      BigInt
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN(

select     
      cfy.*	
  from dbo.CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW_CORE(@clientID, @fiscalYearID, @recID) as cfy  
  where cfy.employeeRelationshipID in (10, 20, 30) 
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PRAC_SALARIES_BEFORE_19_20_FY_VIEW] TO [webuser]
GO