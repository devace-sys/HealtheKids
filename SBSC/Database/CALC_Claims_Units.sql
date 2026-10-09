USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CLAIMS_Units') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CLAIMS_Units
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_CLAIMS_Units] 
(@svcType    INT,
 @span2      BIT,
 @minUnits1  INT,
 @maxUnits1  INT,
 @minUnits2  INT,
 @maxUnits2  INT,
 @numMins    INT,
 @numTrips   SMALLINT,
 @numMiles   DECIMAL(7,1)
 )
 
/***************************************************************************    
 * CALC_CLAIMS_Units */    
/**    
 * Calculate claim units from the given params
 *
 * @param   svcType     Type of service
 * @param   span2       Time based service that can span 2 claims
 * @param   minUnits1   Min # of units for claim 1
 * @param   maxUnits1   Max # of units for claim 1
 * @param   minUnits2   Min # of units for claim 2
 * @param   maxUnits2   Max # of units for claim 2
 * @param   numMins     For time based services the number of minutes     
 * @param   numTrips    For mile based services the number of trips
 * @param   numMiles    For mile based services the number of miles
 *
 * @returns Table of unit calculations
 *
 ***************************************************************************/ 
      
RETURNS @units TABLE (
  IDX               int,
  NUM_UNITS         int,
  NUM_MINS          int,
  NUM_TRIPS         int,
  NUM_MILES         int
)
AS     
BEGIN
    
/*============================================================
 * Immediately exit if required parms are not provided
 *============================================================*/ 

if (@svcType   IS NULL) return
if (@span2     IS NULL) return
if (@minUnits1 IS NULL) return
if (@maxUnits1 is NULL) return

if (@span2 = 1)
begin
  if (@minUnits2 IS NULL) return
  if (@maxUnits2 is NULL) return
end

/*============================================================
 * Setup worker variables
 *============================================================*/  

DECLARE @remainder    AS INT    -- Used in rounding/capping calculations    
DECLARE @interimMins  AS INT    -- Used in rounding/capping calculations    
DECLARE @claim1Units  AS INT    -- Claim1 units    
DECLARE @claim2Units  AS INT    -- Claim2 units    
DECLARE @procPair     AS BIT

/*============================================================
 * Init worker variables
 *============================================================*/  
    
SET @remainder   = 0
SET @interimMins = 0
SET @claim1Units = 0    
SET @claim2Units = 0    
SET @procPair    = null

/*============================================================
 * Clean up optional parameters and provide default values
 *============================================================*/  
     
IF @numMins   IS NULL SET @numMins  = 0   
IF @numTrips  IS NULL SET @numTrips = 0
IF @numMiles  IS NULL SET @numMiles = 0

/*============================================================
 * Assessements
 * Either encounter or minute based
 * Rounding rule does not apply
 *============================================================*/         

IF (@svcType = dbo.CONST_SERVICES_ASSESS())
BEGIN

  /*-------------------------------    
   * 1 claim for assessements
   *------------------------------*/      

  SET @procPair = 0

  /*-------------------------------    
   * Encounter based assessement
   *------------------------------*/      

  IF ((@minUnits1 = 0) and (@maxUnits1 = 1))  
  BEGIN            

    SET @Claim1Units = 1
    SET @Claim2Units = 0   
  END -- Encounter based assessement
  
  /*-------------------------------    
   * Minute based assessement
   *------------------------------*/      
  
  ELSE 
  BEGIN  
  
    /*-------------------------------    
     * If less than 15 minutes were
     * entered and the procedure requires
     * at least 15 minutes then units 
     * will be 0
     *------------------------------*/                
  
    IF ((@numMins < dbo.CONST_TIME_UNIT_MIN()) AND (@minUnits1 >= 1))
    BEGIN    
      SET @interimMins = 0    
    END    

    /*-------------------------------    
     * Otherwise we can compute
     * units based on minutes.
     * There is no rounding rule
     * for assessements
     *------------------------------*/                
     
    ELSE    
    BEGIN         
      SET @interimMins = @numMins           
    END    
            
    /*-------------------------------    
     * If there is something wrong with
     * the calculation, there is an
     * issue with our data, get out!
     *-------------------------------*/    

    IF @interimMins < 0 return
             
    /*-------------------------------    
     * Now we convert to units
     *------------------------------*/      

    SET @claim1Units = @interimMins / dbo.CONST_TIME_UNIT_MIN() 
    SET @claim2Units = 0                           
    
    /*-------------------------------    
     * If the # of units exceeds the    
     * max allowed for this procedure    
     * cap the #units for this claim    
     * at the max and see if the service    
     * can span 2 claims    
     *------------------------------*/      
       
    IF (@claim1Units > @maxUnits1)
    BEGIN                       
      SET @claim1Units = @maxUnits1        /* Claim 1 is capped at max */         
    END -- Units exceeds max for claim 1
  
  END -- Minute based Assessement
  
END -- Assessement


/*============================================================
 * Treatments or TCM
 * All minute based
 * Rounding rule applies for all
 *============================================================*/         
 
ELSE IF ((@svcType = dbo.CONST_SERVICES_TREATMENT()) OR (@svcType = dbo.CONST_SERVICES_TCM()))
BEGIN       
      
  /*-------------------------------    
   * Encounter based treatment or
   * TCM.  Example hearing check.
   * 1 claim service.
   *------------------------------*/      

  IF ((@minUnits1 = 0) and (@maxUnits1 = 1))
  BEGIN        
    SET @Claim1Units = 1      
    SET @procPair    = 0
  END -- Encounter based treatment or TCM
  
  /*-------------------------------    
   * Minute based treatment or TCM
   *------------------------------*/ 
  
  ELSE           
  BEGIN  
  
    /*-------------------------------    
     * Will be 1 claim service
     * unless there is an additional
     * services component (22, @span2)
     *------------------------------*/ 
   
    SET @procPair = 0
    if (@span2 = 1) SET @procPair = 1
    
    /*-------------------------------    
     * If less than 15 minutes were
     * entered and the procedure requires
     * at least 15 minutes then units 
     * will be 0
     *------------------------------*/       
    
    IF ((@numMins < dbo.CONST_TIME_UNIT_MIN()) AND (@minUnits1 >= 1))
    BEGIN    
      SET @interimMins = 0    
    END    

    /*-------------------------------    
     * Otherwise the min num of mins
     * has been reached
     *------------------------------*/                
     
    ELSE    
    BEGIN         
      SET @interimMins = @numMins           
    END    
            
    /*-------------------------------    
     * If there is something wrong with
     * the calculation, there is an
     * issue with our data, get out!
     *-------------------------------*/    

    IF @interimMins < 0 return
             
    /*-------------------------------    
     * Now we convert to units
     *------------------------------*/      

    SET @claim1Units = @interimMins / dbo.CONST_TIME_UNIT_MIN() 
    SET @remainder   = @interimMins % dbo.CONST_TIME_UNIT_MIN()    

    /*-------------------------------    
     * And "round" the remainder
     *------------------------------*/      
    
    IF @remainder >= dbo.CONST_MIN_RND() SET @claim1Units = @claim1Units + 1    
        
    /*-------------------------------    
     * If the # of units exceeds the    
     * max allowed for this procedure    
     * cap the #units for this claim    
     * at the max and see if the service    
     * can span 2 claims    
     *------------------------------*/      
       
    IF (@claim1Units > @maxUnits1)    
    BEGIN                  
      
      SET @claim2Units = @claim1Units - @maxUnits1   /* Claim 2 gets overflow if we can have a claim 2*/     
      SET @claim1Units = @maxUnits1                  /* Claim 1 is capped at max */
         
      /*-------------------------------    
       * Service can span 2 procedures          
       *------------------------------*/     
       
      IF (@span2 = 1)    
      BEGIN                                                  
        
        
        /*-------------------------------    
         * 2 claim service
         *------------------------------*/     

        SET @procPair = 1

        /*-------------------------------    
         * If the extra units exceeds the    
         * max allowed for this 2nd     
         * procedure cap the #units at the    
         * at the max     
         *-------------------------------*/    
                   
        IF (@claim2Units > @maxUnits2) SET @claim2Units = @maxUnits2    
         
      END -- We can overflow in 2nd claim
       
      ELSE       
      BEGIN                
         SET @claim2Units = 0
      END -- Cannot overflow into 2nd claim                
     END -- Units exceeds max for claim 1
   END -- Minute based treatment or TCM
 END -- Treatment or TCM   
   
/*============================================================
 * Transportation
 * All mile and trip based
 *============================================================*/     
 
ELSE IF (@svcType = dbo.CONST_SERVICES_TRANSPORT())    
BEGIN    
              
  /*-------------------------------    
   * Transportation claimset    
   * Transportation services    
   * have two claims:    
   *   - claim for # of trips    
   *   - claim for # of miles    
   *-------------------------------*/    
           
  SET @claim1Units = @numTrips    
  SET @claim2Units = @numMiles    
  
   /*-------------------------------    
    * Transport is 2 claim service
    *------------------------------*/     

   SET @procPair = 1
  
END -- Transportation

/*============================================================
 * Unknown service
 *============================================================*/     
 
ELSE
BEGIN
  SET @claim1Units = 0
  SET @claim2Units = 0
  SET @procPair    = null
END -- Unknown service

/*============================================================
 * Output claim calculations (if any)
 *============================================================*/          
        
/*-------------------------------    
 * 1 Claim Service
 *------------------------------*/     

IF (@procPair = 0)
BEGIN

  -- TODO: Replace unit <> 0 if there are problems
  
  --IF (@claim1Units <> 0) 
  --BEGIN    
  INSERT INTO @units
    (IDX, NUM_UNITS, NUM_MINS, NUM_TRIPS, NUM_MILES)
   VALUES     
    (1,@claim1Units,@numMins,@numTrips,@numMiles)    
  --END    
      
END

/*-------------------------------    
 * 2 Claim Service... including
 * 0 unit claims
 *------------------------------*/     

ELSE IF (@procPair = 1)
BEGIN

     
     INSERT INTO @units
      (IDX, NUM_UNITS, NUM_MINS, NUM_TRIPS, NUM_MILES)
     VALUES     
      (1,@claim1Units,@numMins,@numTrips,@numMiles)    
    
     INSERT INTO @units   
      (IDX, NUM_UNITS, NUM_MINS, NUM_TRIPS, NUM_MILES)
     VALUES     
      (2,@claim2Units,@numMins,@numTrips,@numMiles)    
END

ELSE
BEGIN
  RETURN
END
    
RETURN

END
GO




