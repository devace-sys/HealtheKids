USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW_CORE] ( 
	   @active		   Bit
	 , @recID		   Bigint
)
     
RETURNS TABLE  

AS RETURN(

	select * from dbo.RMTS_REASONS_FOR_START_DATE_CHANGE as rr
	where (
			(1=1)
		and ((@active    is null) or (rr.active = @active))
		and ((@recID    is null)  or (rr.id = @recID))

    )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RMTS_REASONS_FOR_START_DATE_CHANGE_VIEW_CORE] TO [webuser]
GO