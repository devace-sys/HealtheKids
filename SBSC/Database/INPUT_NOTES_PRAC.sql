USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_NOTES_PRAC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_NOTES_PRAC
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[INPUT_NOTES_PRAC]    
(@clientID    INT,    
 @pracID      INT)    
 RETURNS TABLE AS RETURN(    
   select pn.NOTE_PRACTITIONER_ID as pracID,    
          pn.NOTE_ID              as id,    
          pn.NOTE                 as note,    
          GETDATE()               as created,    
          GETDATE()               as lastModifed    
   from PRACTITIONER_CLIENT       as pc     
   join PRACTITIONER_NOTE         as pn on pn.NOTE_PRACTITIONER_ID = pc.PRACTITIONER_ID     
   where (1=1)     
   and ((@clientID is null) or (pc.CLIENT_ID       = @clientID))    
   and ((@pracID   is null) or (pc.PRACTITIONER_ID = @pracID)))    
        
GO
