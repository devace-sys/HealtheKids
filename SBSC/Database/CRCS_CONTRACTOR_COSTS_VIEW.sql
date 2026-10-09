USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_CONTRACTOR_COSTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_CONTRACTOR_COSTS_VIEW
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
    
CREATE FUNCTION [dbo].[CRCS_CONTRACTOR_COSTS_VIEW] ( 
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
      ccc.*	
  from dbo.CRCS_CONTRACTOR_COSTS_VIEW_CORE(@clientID, @fiscalYearID, @recID) as ccc   
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_CONTRACTOR_COSTS_VIEW] TO [webuser]
GO