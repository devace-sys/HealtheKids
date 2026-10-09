USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_NOTES_PAT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_NOTES_PAT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_NOTES_PAT]    
(@clientID    INT,    
 @patID       INT)    
 RETURNS TABLE AS RETURN(    
   select top 1
        pn.NOTE_ID       as id
      , pn.PATIENT_ID    as patID
      , pn.NOTE          as note
   from dbo.PATIENTS_CLIENT    as pc
   join dbo.PATIENTS_Notes     as pn on pn.PATIENT_ID = pc.PATIENT_ID
   where ((1=1)     
     and ((@clientID is null) or (pc.CLIENT_ID       = @clientID))         
     and ((@patID    is null) or (pc.PATIENT_ID      = @patID)))
 )    
GO
