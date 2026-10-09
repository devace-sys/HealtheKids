USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_NOTES_CLIENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_NOTES_CLIENT
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[INPUT_NOTES_CLIENT]    
(@clientID    INT)    
 RETURNS TABLE AS RETURN(    
   select INPUT_NOTE_CLIENT_ID as clientID,    
          INPUT_NOTE_ID        as id,    
          INPUT_NOTE           as note,    
          GETDATE()            as created,    
          GETDATE()            as lastModifed    
   from CLIENTS_InputNote     
   where (1=1) and    
   ((@clientID is NULL) or (INPUT_NOTE_CLIENT_ID = @clientID))     
 )    
GO
