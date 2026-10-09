USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CREATE_UNIQUE_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CREATE_UNIQUE_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CREATE_UNIQUE_ID] ()    
returns varchar(255)    
as
begin
    
/***************************************************************************    
 * CREATE_UNIQUE_ID */    
/**    
 * Creates unique id for page requests, etc.
 *
 * @return  string or null
 ***************************************************************************/            
     

return (select NEW_UNIQUE_ID_STR_NO_DASH from dbo.GENERATE_NEW_UNIQUE_ID)

end    
    
GO
