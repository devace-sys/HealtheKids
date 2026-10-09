USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_MINUTES_OR_START_END_MILES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_MINUTES_OR_START_END_MILES
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_MINUTES_OR_START_END_MILES]
  (@svcType    INT,
   @numMins    INT,    
   @trip1Start DECIMAL(7,1), @trip1End DECIMAL(7,1),     
   @trip2Start DECIMAL(7,1), @trip2End DECIMAL(7,1),    
   @trip3Start DECIMAL(7,1), @trip3End DECIMAL(7,1),    
   @trip4Start DECIMAL(7,1), @trip4End DECIMAL(7,1))     

RETURNS VARCHAR(200)
AS     
BEGIN    
  
  DECLARE @minOrMiles AS VARCHAR(200)
  SET     @minOrMiles = ''
    
  IF (@svcType <> dbo.CONST_SERVICES_TRANSPORT())
    /*-------------------------------
     * Service is time based, return
     * number of minutes
     *------------------------------*/ 
    SET @minOrMiles = CONVERT(VARCHAR(100), @numMins) 
  ELSE
  BEGIN
  
    /*-------------------------------
     * Service is mile based return
     * start - end mile details
     * Note: varchar(10) accommodates
     * a maximum mileage of
     * 99,999,999.99 which should be
     * more than enough.
     *------------------------------*/
  
    SET @minOrMiles = 
    /* Trip 1 */
    CONVERT(varchar(10),@trip1Start) + ' - ' +
    CONVERT(varchar(10),@trip1End)   + ' | ' +
    /* Trip 2 */
    CONVERT(varchar(10),@trip2Start) + ' - ' +
    CONVERT(varchar(10),@trip2End)   + ' | ' +
    /* Trip 3 */
    CONVERT(varchar(10),@trip3Start) + ' - ' +
    CONVERT(varchar(10),@trip3End)   + ' | ' + 
    /* Trip 4 */
    CONVERT(varchar(10),@trip4Start) + ' - ' +
    CONVERT(varchar(10),@trip4End)
  
  END
  
  
  RETURN @minOrMiles
  
END    
GO
