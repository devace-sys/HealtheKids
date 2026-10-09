USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_ELIGIBILITY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_ELIGIBILITY
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CALC_ELIGIBILITY]    
(@elgDisp  SMALLINT,    
 @refDate  DATETIME,    
 @mCurDate DATETIME,    
 @mCurFlag NVARCHAR(1),    
 @JanFlag  NVARCHAR(1),    
 @FebFlag  NVARCHAR(1),    
 @MarFlag  NVARCHAR(1),    
 @AprFlag  NVARCHAR(1),    
 @MayFlag  NVARCHAR(1),    
 @JunFlag  NVARCHAR(1),    
 @JulFlag  NVARCHAR(1),    
 @AugFlag  NVARCHAR(1),    
 @SepFlag  NVARCHAR(1),    
 @OctFlag  NVARCHAR(1),    
 @NovFlag  NVARCHAR(1),    
 @DecFlag  NVARCHAR(1))    
 RETURNS @recs TABLE(monthDate DATETIME,    
                     eFlag     CHAR(2))     
 AS     
 BEGIN          
  /***************************************************************************    
   * CALC_ELIGIBILITY */    
   /**    
   * Calculates and returns an eligibility lookup table for the given parameters.    
   *    
   * Note:    
   * The eligbility data for each patient is stored as a single record    
   * this record contains a date and flag column that indicates the date of    
   * the elibility and it also contains 12 flags that show the previous 12 months    
   * of eligibility.   For example if the elibility date is March of 2006 then    
   * the flags will show Feb 2006 - Jan 2006 and Dec 2005 to March 2005.    
   * Also Elibility determination is based on the month not the day     
   * so any dates that are used for comparison/calulation should be set to the    
   * start of their month component.  For example if a given date is 3/6/2010    
   * it should be set to 3/1/2010.    
   *    
   * @param  elgDisp         1= Return data as stored, 2= Return data with    
   *                         respect to refDate, 3= Return data for refDate    
   * @param  refDate         Reference date.  For example, date of service    
   * @param  mCurDate        Meds cur field from patients elibility record    
   * @param  mCurFlag        Meds cur flag from patients elibility record    
   * @param  JanFlag         Month flag from patients elibility record    
   * @param  FebFlag         Month flag from patients elibility record    
   * @param  MarFlag         Month flag from patients elibility record    
   * @param  AprFlag         Month flag from patients elibility record    
   * @param  MayFlag         Month flag from patients elibility record    
   * @param  JunFlag         Month flag from patients elibility record    
   * @param  JulFlag         Month flag from patients elibility record    
   * @param  AugFlag         Month flag from patients elibility record    
   * @param  SepFlag         Month flag from patients elibility record    
   * @param  OctFlag         Month flag from patients elibility record    
   * @param  NovFlag         Month flag from patients elibility record    
   * @param  DecFlag         Month flag from patients elibility record    
   * @return                 Table of known data or null if parms are missing    
   ***************************************************************************/         
     
 /*-------------------------------    
 * Converted Eligibility flags    
 * Y -> E, '' -> ?, N -> NE    
 *------------------------------*/    
  DECLARE @eFlg       AS CHAR(2)    
  DECLARE @elg1f      AS CHAR(2)    
  DECLARE @elg2f      AS CHAR(2)    
  DECLARE @elg3f      AS CHAR(2)    
  DECLARE @elg4f      AS CHAR(2)    
  DECLARE @elg5f      AS CHAR(2)    
  DECLARE @elg6f      AS CHAR(2)    
  DECLARE @elg7f      AS CHAR(2)    
  DECLARE @elg8f      AS CHAR(2)    
  DECLARE @elg9f      AS CHAR(2)    
  DECLARE @elg10f     AS CHAR(2)    
  DECLARE @elg11f     AS CHAR(2)    
  DECLARE @elg12f     AS CHAR(2)    
  DECLARE @eMon       AS SMALLINT    
  DECLARE @monCtr     AS SMALLINT    
    
  DECLARE @eDate      AS DATETIME    
  DECLARE @rDate      AS DATETIME    
      
/*-------------------------------    
 * Table variable that holds    
 * the parsed/split elibility    
 * record    
 *------------------------------*/    
DECLARE @elgFlgs TABLE    
(    
  monthNum SMALLINT,    
  eFlag    CHAR(2)     
)    
/*-------------------------------    
 * Table variable that holds    
 * the parsed/split elibility    
 * record with the month flags    
 * translated to month numbers that    
 * are with respect to the elibility    
 * month number    
 *------------------------------*/    
DECLARE @elgFlgsOrd TABLE    
(    
  num      SMALLINT IDENTITY(0,1),    
  monthNum SMALLINT,    
  eFlag    CHAR(2)     
)    
/*-------------------------------    
 * @elgFlgsOrd with calculated dates    
 * for each month with respect to     
 * the elibility date    
 *------------------------------*/    
DECLARE @elgAct TABLE    
(    
  num       SMALLINT IDENTITY(1,1),    
  monthNum  SMALLINT,    
  monthDate DATETIME,    
  eFlag     CHAR(2)     
)    
    
/*-------------------------------    
 * For reference date    
 *------------------------------*/    
DECLARE @elgRef TABLE    
(    
  monthDate DATETIME     
)    
    
/*-------------------------------    
 * If the meds cur date is null    
 * or the default sql minimum     
 * datetime value then return nothing    
 *------------------------------*/    
 IF @mCurDate IS NULL RETURN    
 IF @mCurDate <= dbo.CONST_MIN_DATETIME() RETURN    
     
/*-------------------------------    
 * Set meds cur date to the start of    
 * its month.     
 *------------------------------*/    
 SET @eDate = dbo.DATE_START(@mCurDate,3)    
     
/*-------------------------------    
 * Convert incoming fields into    
 * elibility flags    
 *------------------------------*/     
SET @eFlg   = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@mCurFlag)    
SET @elg1f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JanFlag)    
SET @elg2f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@FebFlag)    
SET @elg3f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MarFlag)    
SET @elg4f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AprFlag)    
SET @elg5f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MayFlag)    
SET @elg6f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JunFlag)    
SET @elg7f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JulFlag)    
SET @elg8f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AugFlag)    
SET @elg9f  = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@SepFlag)    
SET @elg10f = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@OctFlag)    
SET @elg11f = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@NovFlag)    
SET @elg12f = dbo.PAT_ELIGIBILITY_FLAG_VALUE(@DecFlag)    
    
/*-------------------------------    
 * Get month# for meds cur date    
 *------------------------------*/     
SET @eMon = DATEPART(month,@eDate)    
      
/*-------------------------------    
 * Create records out of each     
 * eligibiliy flag and assign    
 * ordinal numbers    
 * For example @MarFlag which is    
 * stored in @elg3F is given a    
 * month # of 3 because March is    
 * the 3rd month.  Store these     
 * recs in @elgFlgs    
 *------------------------------*/     
    
 INSERT INTO @elgFlgs VALUES(1,@elg1f)    
 INSERT INTO @elgFlgs VALUES(2,@elg2f)    
 INSERT INTO @elgFlgs VALUES(3,@elg3f)    
 INSERT INTO @elgFlgs VALUES(4,@elg4f)    
 INSERT INTO @elgFlgs VALUES(5,@elg5f)    
 INSERT INTO @elgFlgs VALUES(6,@elg6f)    
 INSERT INTO @elgFlgs VALUES(7,@elg7f)    
 INSERT INTO @elgFlgs VALUES(8,@elg8f)    
 INSERT INTO @elgFlgs VALUES(9,@elg9f)    
 INSERT INTO @elgFlgs VALUES(10,@elg10f)    
 INSERT INTO @elgFlgs VALUES(11,@elg11f)    
 INSERT INTO @elgFlgs VALUES(12,@elg12f)    
    
 /*-------------------------------    
  * Create a new record out of    
  * the current eligibility month    
  * and insert into @elgFlgsOrd    
  * Then insert right after this     
  * all records from @elgFlg     
  * that have a month number <    
  * the current month.   Then     
  * insert right after this    
  * all records from @elgFlg    
  * that have a month number >=    
  * the current month    
  *------------------------------*/     
  INSERT INTO @elgFlgsOrd  VALUES (@eMon, @eFlg)    
  INSERT INTO @elgFlgsOrd (monthNum, eFlag) SELECT monthNum, eFlag FROM @elgFlgs WHERE monthNum <  @eMon ORDER BY monthNum DESC    
  INSERT INTO @elgFlgsOrd (monthNum, eFlag) SELECT monthNum, eFlag FROM @elgFlgs WHERE monthNum >= @eMon ORDER BY monthNum DESC    
      
  /*-------------------------------    
   * Finally derive the correct    
   * dates    
   *------------------------------*/       
  INSERT INTO @elgAct (monthNum, monthDate, eFlag) SELECT monthNum, DATEADD(month,(num*-1),@eDate) as monthDate, eFlag  FROM @elgFlgsOrd    
      
  /*-------------------------------    
   * Return data     
   *------------------------------*/     
   IF @elgDisp = 1    
   BEGIN    
    /*-------------------------------    
     * As it is stored    
     *------------------------------*/       
     INSERT @recs SELECT monthDate, eFlag FROM @elgAct    
   END    
   ELSE IF (@elgDisp = 2)    
   BEGIN    
     IF @refDate IS NULL SET @rDate = GETDATE()    
     SET @rDate = dbo.DATE_START(@rDate,3)    
    
    /*-------------------------------    
     * Return eligibility data    
     * in reference to refDate    
     * For example if we have data    
     * for 6/1/2010 to 6/1/2009 and    
     * the dos date is 8/13/2009    
     * we will return unknowns for    
     * 7/2010, and 8/2010 but    
     * we can return what data we have    
     * for 6/2010 to 8/2009    
     *------------------------------*/       
     SET @monCtr = 0    
     WHILE (@monCtr < 13)    
     BEGIN    
       INSERT INTO @elgRef VALUES (DATEADD(month,(@monCtr*-1),@rDate))    
       SET @monCtr = @monCtr + 1    
     END    
     INSERT @recs SELECT e1.monthDate, ISNULL(e2.eFlag,dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()) as eFlag FROM @elgRef AS e1 LEFT JOIN @elgAct AS e2 ON e1.monthDate = e2.monthDate    
    END    
   ELSE IF (@elgDisp = 3)    
   BEGIN    
     IF @refDate IS NULL SET @rDate = GETDATE()    
     SET @rDate = dbo.DATE_START(@refDate,3)    
    /*-------------------------------    
     * Return eligibility data    
     * for refDate (1 or 0 rows)    
     *------------------------------*/       
     INSERT @recs SELECT monthDate, eFlag FROM @elgAct WHERE monthDate = @rDate    
    END        
  RETURN    
END    
GO
