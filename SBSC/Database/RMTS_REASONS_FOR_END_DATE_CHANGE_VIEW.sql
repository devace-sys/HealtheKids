USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW] (
    @userID         BIGINT    
  , @userGroup      BIGINT    
  , @userRank       INT
  , @active         bit
  , @term           varchar(50)
  , @recID          bigint
  
)    
RETURNS 
TABLE
AS
RETURN
(
  select * from dbo.RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW_CORE (@active, @recID) as rr
  where (
		 (1=1)
     and (@term is null) or (rr.reason like '%' + @term + '%')
  )
   
)
GO

GRANT SELECT ON  [dbo].[RMTS_REASONS_FOR_END_DATE_CHANGE_VIEW] TO [webuser]
GO
