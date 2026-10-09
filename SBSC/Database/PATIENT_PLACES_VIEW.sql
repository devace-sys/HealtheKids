USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_PLACES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_PLACES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


CREATE FUNCTION [dbo].[PATIENT_PLACES_VIEW] (
   @userID                 BIGINT    
 , @userGroup              INT
 , @userRank               INT
 , @clientID               BIGINT
 , @patID                  BIGINT
 , @term                   varchar(255)
 , @active                 BIT
 , @recID                  BIGINT
 
)

RETURNS TABLE
AS
RETURN
(  

  select 
  
    pp.* 
  
  from dbo.PATIENT_PLACES_VIEW_CORE (
     @userID        
   , @userGroup 
   , @userRank
   , @clientID
   , @patID
   , @term          
   , @active      
   , @recID ) as pp

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_PLACES_VIEW] TO [webuser]
GO