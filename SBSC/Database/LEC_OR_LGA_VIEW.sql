USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.LEC_OR_LGA_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.LEC_OR_LGA_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[LEC_OR_LGA_VIEW] ( 
	   @userID            BigInt    
	 , @userGroup         Int    
	 , @userRank          Int 
	 , @active            Bit
	 , @term              varchar(50)
	 , @recID             Bigint
)
     
RETURNS TABLE  

AS RETURN(

select     
      lol.*	
  from dbo.LEC_OR_LGA_VIEW_CORE(@active, @recID) as lol 
  where (isnull(@term, '') = '') or (lol.name like '%' + @term + '%')
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[LEC_OR_LGA_VIEW] TO [webuser]
GO