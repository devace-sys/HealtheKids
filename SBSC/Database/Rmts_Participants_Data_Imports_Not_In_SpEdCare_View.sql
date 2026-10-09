USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Rmts_Participants_Data_Imports_Not_In_SpEdCare_View') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Rmts_Participants_Data_Imports_Not_In_SpEdCare_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Rmts_Participants_Data_Imports_Not_In_SpEdCare_View] ( 
	   @userID           BigInt
	 , @userGroup        Int
	 , @userRank         Int     
	 , @clientID         BigInt    
	 , @fyQuarterID      Bigint
	 , @rmtsDataImportID Bigint
	 , @recID		     Bigint
)
     
RETURNS TABLE  

AS RETURN(

	select
		rp.*
	from dbo.Rmts_Participants_Data_Imports_Not_In_SpEdCare_View_Core(@clientID, @fyQuarterID, @rmtsDataImportID, @recID) as rp	
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Rmts_Participants_Data_Imports_Not_In_SpEdCare_View] TO [webuser]
GO