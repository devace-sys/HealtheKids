USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PROGRAM_INFO_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PROGRAM_INFO_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PROGRAM_INFO_VIEW] ( 
	   @userID            BigInt    
	 , @userGroup         Int    
	 , @userRank          Int 
	 , @clientID          BigInt 
	 , @fiscalYearID      Bigint
	 , @active            Bit   
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN(

select     
      cpi.*	
  from dbo.CRCS_PROGRAM_INFO_VIEW_CORE(@clientID, @fiscalYearID, @active, @recID) as cpi   
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PROGRAM_INFO_VIEW] TO [webuser]
GO