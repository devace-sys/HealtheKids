USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PAT_DOS_ELIGIBILITY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PAT_DOS_ELIGIBILITY
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PAT_DOS_ELIGIBILITY]    
(@dos      DATETIME,    
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
RETURNS CHAR(2) AS     
BEGIN    
  /***************************************************************************    
   * PAT_DOS_ELIGIBILITY */    
   /**    
   * Calculates and returns the eligibility flag value for the given parameters.    
   *    
   * @param  dos             Date of service    
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
   * @return                 E if elibible, NE if not, or ? if eligibility    
   *                         is unknown    
   ***************************************************************************/         
           
  DECLARE @eFlag AS CHAR(2)    
  SET @eFlag = NULL    
      
  /*-------------------------------    
   * Set dos is not passed in     
   * return unknown, otherwise    
   * set dos to start of    
   * its month    
   *------------------------------*/    
  IF @dos IS NULL RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
  SET @dos = dbo.DATE_START(@dos,3)    
      
  /*-------------------------------    
   * If the meds cur date is null    
   * or the default sql minimum or    
   * meds cur set to the start of    
   * its month is older than one year    
   * return an unknown.    
   *------------------------------*/    
  IF @mCurDate IS NULL RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
  IF @mCurDate <= dbo.CONST_MIN_DATETIME() RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
  SET @mCurDate = dbo.DATE_START(@mCurDate,3)    
  IF dbo.CALC_AGE_CURRENT(@mCurDate) > 1 RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
      
  /*-------------------------------    
   * If dos falls is within a year     
   * of medscur and all of the flags    
   * are the same value we can    
   * determine the value and exit    
   *------------------------------*/    
   IF ((@dos <= @mCurDate) AND (dbo.CALC_AGE(@dos,@mCurDate) <=1))    
   BEGIN    
     /*-------------------------------    
      * All flags are yes    
      *------------------------------*/    
     IF ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@mCurFlag)) = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JanFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@FebFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MarFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AprFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MayFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JunFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND         
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JulFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AugFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@SepFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@OctFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@NovFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()) AND    
        ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@DecFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES())    
     RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_YES()    
        
    /*-------------------------------    
    * All flags are no    
    *------------------------------*/    
    IF ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@mCurFlag)) = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JanFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@FebFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MarFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AprFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@MayFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JunFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND         
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@JulFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@AugFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@SepFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@OctFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@NovFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()) AND    
     ((dbo.PAT_ELIGIBILITY_FLAG_VALUE(@DecFlag))  = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO())    
   RETURN dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_NO()    
    
  END    
      
  /*-------------------------------    
   * If we reach this point then    
   * we have a mix of flags and    
   * we need to look at the actual    
   * date    
   *------------------------------*/    
       
  SELECT @eFlag = eFlag FROM dbo.CALC_ELIGIBILITY(3,@dos,@mCurDate,@mCurFlag,@JanFlag,@FebFlag,@MarFlag,@AprFlag,@MayFlag,@JunFlag,@JulFlag,@AugFlag,@SepFlag,@OctFlag,@NovFlag,@DecFlag)    
  IF @eFlag IS NULL SET @eFlag = dbo.CONST_PAT_ELIGIBILITY_FLAG_VALUE_UNK()    
  RETURN @eFlag    
END    
GO
