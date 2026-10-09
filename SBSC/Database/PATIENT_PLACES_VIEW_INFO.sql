USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PLACES_VIEW_INFO') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PLACES_VIEW_INFO
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_PLACES_VIEW_INFO] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patID                  BIGINT  
)

RETURNS TABLE
AS
RETURN
(  

  select top (dbo.CONST_MAX_ROWS())
      [Name]    = name
    , [Address] = placeAddress
        
  from dbo.PATIENT_PLACES_VIEW_CORE (
     @userID        
   , @userGroup 
   , @userRank
   , @clientID
   , @patID
   , null          
   , 1      
   , null )
  
  order by 
    name
  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PLACES_VIEW_INFO] TO [webuser]
GO