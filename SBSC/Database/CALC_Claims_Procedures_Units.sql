USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CLAIMS_Procedures_Units') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CLAIMS_Procedures_Units
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_CLAIMS_Procedures_Units] 
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
 @numTrips          SMALLINT,
 @numMiles          DECIMAL(7,1)
 )
 
/***************************************************************************    
 * CALC_CLAIMS_Procedures_Units */    
/**    
 * Calculate claim data from the given params
 *
 * @param   clientID  Client's record id    
 * @param   siteID    Patients site record id
 * @param   pracID    Practitioner's record id    
 * @param   patID     Patient's record id    
 * @param   planType  Patients plan type
 * @param   nameID    Service's (service provided) record id    
 * @param   numMin    For time based services the number of minutes     
 * @param   numTrips  For mile based services the number of trips
 * @param   numMiles  For mile based services the number of miles
 *
 * @returns Table of claim data that can be used to create claim records
 *
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

declare @svcType   as int
declare @span2     as int
declare @procID1   as int
declare @minUnits1 as int
declare @maxUnits1 as int
declare @procID2   as int
declare @minUnits2 as int
declare @maxUnits2 as int

/*-------------------------------    
 * Claim procedure data
 *------------------------------*/ 

declare @procs as TABLE (
  IDX               int,
  GROUP_ID          int,
  SVC_TYPE          int,
  SPAN_2            bit,
  PROCEDURE_ID      int,
  MIN_UNITS         int,
  MAX_UNITS         int,
  SHOW_OPTIONS_1    varchar(255),
  SHOW_OPTIONS_2    varchar(255)
)

/*-------------------------------    
 * Claim unit calculations
 *------------------------------*/  
  
declare @units as TABLE (
  IDX               int,
  NUM_UNITS         int,
  NUM_MINS          int,
  NUM_TRIPS         int,
  NUM_MILES         int
)

/*============================================================
 * Clean up optional parameters and provide default values
 *============================================================*/  
     
IF @numMins  IS NULL SET @numMins  = 0  
IF @numTrips IS NULL SET @numTrips = 0
IF @numMiles IS NULL SET @numMiles = 0

/*============================================================
 * Look up procedure data
 *============================================================*/  

insert @procs
select * from dbo.CALC_Claims_Procedures (@clientID, 
                                          @pracID, 
                                          @patID,
                                          @dos, 
                                          @planType, 
                                          @nameID,
                                          @hasSvcDetailFlags,
                                          @svcDetFlag1,
                                          @svcDetFlag2,
                                          @svcDetFlag3,
                                          @svcDetFlag4
                                          )

/*============================================================
 * Extract data for procedure 1
 *============================================================*/  

select 
  @svcType   = SVC_TYPE,
  @span2     = SPAN_2, 
  @procID1   = PROCEDURE_ID,
  @minUnits1 = MIN_UNITS, 
  @maxUnits1 = MAX_UNITS
from @procs where IDX = 1

/*============================================================
 * Extract data for procedure 2
 *============================================================*/  

select 
  @procID2   = PROCEDURE_ID,
  @minUnits2 = MIN_UNITS, 
  @maxUnits2 = MAX_UNITS 
from @procs where IDX = 2

/*============================================================
 * Compute units for procedure 1 and 2
 *============================================================*/  

insert @units
select * from dbo.CALC_Claims_Units(@svcType,
                                    @span2,
                                    @minUnits1,
                                    @maxUnits1,
                                    @minUnits2,
                                    @maxUnits2,
                                    @numMins,
                                    @numTrips,
                                    @numMiles)

/*============================================================
 * Join and return data
 *============================================================*/  

insert @claims
select p.IDX as IDX, GROUP_ID, SVC_TYPE, SPAN_2, PROCEDURE_ID, NUM_UNITS, MIN_UNITS, MAX_UNITS, NUM_MINS, NUM_TRIPS, NUM_MILES
from @procs as p
join @units as u on u.IDX = p.IDX
    
RETURN

END
GO




