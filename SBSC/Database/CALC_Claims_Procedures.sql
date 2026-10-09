USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CLAIMS_Procedures') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CLAIMS_Procedures
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_CLAIMS_Procedures] 
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
 @svcDetFlag4       BIT
 )
 
/***************************************************************************    
 * CALC_CLAIMS_Procedures */    
/**    
 * Retrieve claim procedure data and rules from the given params
 *
 * @param   clientID  Client's record id     * @param   pracID    Practitioner's record id     * @param   patID     Patient's record id     * @param   planType  Patients plan type
 * @param   nameID    Service's (service provided) record id    
 * * @returns Table of claim procedure data that can be used to create claim records *
 ***************************************************************************/ 
      
RETURNS @procs TABLE (
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
AS     
BEGIN
    
/*============================================================
 * Immediately exit if required parms are not provided
 *============================================================*/ 

if (@clientID IS NULL) return
if (@pracID   IS NULL) return
if (@patID    IS NULL) return
if (@planType IS NULL) return
if (@nameID   IS NULL) return

/*============================================================
 * Setup worker variables
 *============================================================*/  

DECLARE @groupID      AS INT
DECLARE @svcType      AS INT
DECLARE @span2        AS BIT            -- Time based service record can span 2 claims    
DECLARE @minUnits1    AS INT            -- Min # for claim1, used for determining rounding rule application    
DECLARE @maxUnits1    AS INT            -- Max # for claim1, used for capping and overflow to 2nd claim    
DECLARE @minUnits2    AS INT            -- Min # units for claim 2    
DECLARE @maxUnits2    AS INT            -- Max # units for claim 2    
DECLARE @tempRecID    AS INT            -- Used for determining if a rec exists    
DECLARE @procID1      AS INT            -- Claim1 procedure id    
DECLARE @procID2      AS INT            -- Claim2 procedure id    
DECLARE @showOptions1 AS VARCHAR(255)   -- Display options for all procs.  Display minutes or miles?
DECLARE @showOptions2 AS VARCHAR(255)   -- Display options for all procs.  Display svc options?

/*============================================================
 * Init worker variables
 *============================================================*/  
    
SET @procID1      = 0    
SET @procID2      = 0    
SET @minUnits1    = 0    
SET @maxUnits1    = 0    
SET @minUnits2    = 0    
SET @maxUnits2    = 0
SET @showOptions1 = ''
SET @showOptions2 = ''

/*============================================================
 * Look up procedure data for 1st claim 
 * If this critical combo of data is not found, get out!
 *============================================================*/  
      
SET @tempRecID = NULL     
      
SELECT top 1
        @tempRecID    = nameID,    
        @minUnits1    = minUnits,    
        @maxUnits1    = maxUnits, 
        @svcType      = svcType,    
        @planType     = planType,    
        @span2        = span2,    
        @procID1      = procID,    
        @groupID      = groupID,       
        @showOptions1 = showOptions1,
        @showOptions2 = showOptions2

FROM   dbo.SERVICES_VIEW_BY_PRAC_PAT_PLAN (@clientID,@pracID,@patID,@dos,@planType,@nameID,0,null,null)

/*-------------------------------    
 * If we cant find it, there is
 * an issue with our data or
 * invalid parameters were passed
 * so get out!
 *-------------------------------*/    

IF @tempRecID IS NULL return

/*============================================================
 * Time based claims
 *============================================================*/         
 
IF (@svcType <> dbo.CONST_SERVICES_TRANSPORT())    
BEGIN       
  
  /*-------------------------------    
   * Can the time based service 
   * span 2 claims if it is
   * large enough?
   *------------------------------*/     
  
  IF (@span2 = 1)    
  BEGIN                         

    /*-------------------------------    
     * Yes.  Lookup the appropriate
     * 2nd procedure (22).  Note the
     * use of the is22 argument.
     *------------------------------*/     
    
    SET @tempRecID = NULL    
         
    SELECT  top 1
	        @tempRecID  = nameID,    
            @minUnits2  = minUnits,    
            @maxUnits2  = maxUnits,    
            @procID2    = procID    
                      
    FROM dbo.SERVICES_VIEW_BY_PRAC_PAT_PLAN (@clientID,@pracID,@patID,@dos,@planType,@nameID,1,null,null)    
        
    /*-------------------------------    
     * If we cant find it, there is
     * an issue with our data, get out!
     *-------------------------------*/      
        
    IF @tempRecID IS NULL return
                               
   END -- Can we claim 2  
 END -- Time based   
  
/*============================================================
 * Mile based claims
 *============================================================*/     
 
ELSE    
BEGIN    
              
  /*-------------------------------    
   * Transportation services always   
   * have two claims:    
   *
   * 1. claim for # of trips    
   * 2. claim for # of miles    
   *
   * We have already looked up the
   * # of trips procedure so all we
   * need is the # of miles procedure
   *-------------------------------*/    
               
  SET @tempRecID = NULL    
           
  SELECT  top 1
          @tempRecID  = nameID,    
          @minUnits2  = minUnits,    
          @maxUnits2  = maxUnits,    
          @procID2    = procID     
     
  FROM dbo.SERVICES_VIEW_BY_PRAC_PAT_PLAN(@clientID,@pracID,@patID,@dos,@planType,null,0,dbo.CONST_TRANS_PROC_NUM_MILES(),null) AS svcs         
  
  WHERE svcs.svctype = dbo.CONST_SERVICES_TRANSPORT()    
         
  /*-------------------------------    
   * If we cant find it, there is
   * an issue with our data, get out!
   *-------------------------------*/    

  IF @tempRecID IS NULL return
   
END    

/*============================================================
 * Output procedure data (if any)
 *============================================================*/          
        
/*-------------------------------    
 * Procedure 1
 *-------------------------------*/ 

IF (@procID1 <> 0)    
BEGIN    
  INSERT INTO @procs
    (IDX,GROUP_ID,SVC_TYPE,SPAN_2,PROCEDURE_ID,MIN_UNITS,MAX_UNITS,SHOW_OPTIONS_1,SHOW_OPTIONS_2)    
   VALUES     
    (1,@groupID,@svcType,@span2,@procID1,@minUnits1,@maxUnits1,@showOptions1,@showOptions2)    
END    
    
/*-------------------------------    
 * Procedure 2
 *-------------------------------*/ 

IF (@procID2 <> 0)
BEGIN    
  INSERT INTO @procs    
    (IDX,GROUP_ID,SVC_TYPE,SPAN_2,PROCEDURE_ID,MIN_UNITS,MAX_UNITS,SHOW_OPTIONS_1,SHOW_OPTIONS_2)    
   VALUES     
    (2,@groupID,@svcType,null,@procID2,@minUnits2,@maxUnits2,null,null)    
END    
    
RETURN

END
GO




