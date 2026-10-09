USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CLAIMS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CLAIMS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_CLAIMS] 
(@clientID          INT,     
 @pracID            INT,
 @patID             INT,
 @dos               DATE,
 @planType          INT,    
 @nameID            INT, 
 @hasSvcDetailFlags BIT,
 @svcDetFlag1       BIT,
 @svcDetFlag2       BIT,
 @svcDetFlag3       BIT,
 @svcDetFlag4       BIT,
 @numMins           INT,
 @trip1Start        DECIMAL(7,1),    
 @trip1End          DECIMAL(7,1),    
 @trip2Start        DECIMAL(7,1),    
 @trip2End          DECIMAL(7,1),    
 @trip3Start        DECIMAL(7,1),    
 @trip3End          DECIMAL(7,1),    
 @trip4Start        DECIMAL(7,1),    
 @trip4End          DECIMAL(7,1))
 
/***************************************************************************    
 * CALC_CLAIMS*/    
/**    
 * Calculate claim data from the given params
 *
 * @param   clientID   Client's record id     * @param   siteID     Patients site record id
 * @param   pracID     Practitioner's record id     * @param   patID      Patient's record id     * @param   planType   Patients plan type
 * @param   nameID     Service's (service provided) record id    
 * @param   numMin     For time based services the number of minutes  * @param   trip1Start For mile based services.   * @param   trip1End   For mile based services.
 * @param   trip2Start For mile based services.   * @param   trip2End   For mile based services.
 * @param   trip3Start For mile based services.   * @param   trip3End   For mile based services.
 * @param   trip4Start For mile based services.   * @param   trip4End   For mile based services.
 * * @returns Table of claim data that can be used to create claim records *
 ***************************************************************************/ 
      
RETURNS @claims TABLE (
  IDX               int,
  GROUP_ID          int,
  SVC_TYPE          int,
  SPAN_2            bit,
  PROCEDURE_ID      int,
  NUM_UNITS         int,
  MIN_UNITS         int,
  MAX_UNITS         int,
  NUM_MINS          int,
  NUM_TRIPS         int,
  NUM_MILES         int
)

AS     
BEGIN
    
/*============================================================
 * Setup worker variables
 *============================================================*/  

DECLARE @numTrips AS SMALLINT
DECLARE @numMiles AS DECIMAL(7,1)

/*============================================================
 * Init worker variables
 *============================================================*/  
    
SET @numTrips  = 0
SET @numMiles  = 0

/*============================================================
 * Clean up optional parameters and provide default values
 *============================================================*/  
     
IF @numMins    IS NULL SET @numMins    = 0   
IF @trip1Start IS NULL SET @trip1Start = 0    
IF @trip1End   IS NULL SET @trip1End   = 0    
IF @trip2Start IS NULL SET @trip2Start = 0    
IF @trip2End   IS NULL SET @trip2End   = 0    
IF @trip3Start IS NULL SET @trip3Start = 0    
IF @trip3End   IS NULL SET @trip3End   = 0    
IF @trip4Start IS NULL SET @trip4Start = 0    
IF @trip4End   IS NULL SET @trip4End   = 0    
 
/*============================================================
 * Calculate total trips and miles
 *============================================================*/  

SET @numTrips = dbo.CALC_TOTAL_TRIPS_8(@trip1Start,@trip1End,@trip2Start,@trip2End,@trip3Start,@trip3End,@trip4Start,@trip4End)    
SET @numMiles = dbo.CALC_TOTAL_MILES_8(@trip1Start,@trip1End,@trip2Start,@trip2End,@trip3Start,@trip3End,@trip4Start,@trip4End)    

/*============================================================
 * Return data
 *============================================================*/  

insert @claims
select * from dbo.CALC_CLAIMS_Procedures_Units( @clientID
                                               ,@pracID
                                               ,@patID
                                               ,@dos
                                               ,@planType
                                               ,@nameID
                                               ,@hasSvcDetailFlags
                                               ,@svcDetFlag1
                                               ,@svcDetFlag2
                                               ,@svcDetFlag3
                                               ,@svcDetFlag4
                                               ,@numMins
                                               ,@numTrips
                                               ,@numMiles)
    
RETURN

END
GO




