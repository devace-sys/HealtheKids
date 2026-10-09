USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_PARTICIPANTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_PARTICIPANTS_VIEW
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_PARTICIPANTS_VIEW] ( 
	   @userID            BigInt    
	 , @userGroup         Int    
	 , @userRank          Int 
	 , @clientID          BigInt    
	 , @rosterID          Bigint
	 , @active            Bit
	 , @recID		      Bigint
)
     
RETURNS TABLE  

AS RETURN(

select     
      ccc.*	
  from dbo.RMTS_PARTICIPANTS_VIEW_CORE(@clientID, @rosterID, @active, @recID) as ccc
  where
     ( isnull(@rosterID, 0) != 0 )
) 									      
     								       
GO									       
									       
/*-------------------------------	   		
 * User Permissions						
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_PARTICIPANTS_VIEW] TO [webuser]
GO