USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.LEC_OR_LGA_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.LEC_OR_LGA_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[LEC_OR_LGA_VIEW_CORE] ( 
	     @active            Bit
	   , @recID             Bigint   
)
     
RETURNS TABLE  

AS RETURN(

  select 
	 lol.*
  from dbo.LEC_OR_LGA as lol
  where (
		(1=1)	
	and	((@recID  is null) or (lol.id     = @recID))
	and ((@active is null) or (lol.active = @active))
	)
) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[LEC_OR_LGA_VIEW_CORE] TO [webuser]
GO