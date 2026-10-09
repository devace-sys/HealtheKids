USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM](@dos DATETIME, @today DATETIME) 
RETURNS INT
AS     

/***************************************************************************    
 * CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM */    
/**    
 * Determines based on date of service and today if we need to submit a
 * claim or lose it
 *   
 * @param   dos      Date of service
 * @param   today    Todays date
 * @return  int      -1    = Lost
 *                    0    = Still have time
 *                    1    = Out of time, sent it!
 *                    null = bad parms
 ***************************************************************************/         

BEGIN    
     
  DECLARE @age    as int
  DECLARE @day    as int
  DECLARE @status as int
  
  SET @status = NULL
  
  /*============================================================
   * If the params passed are not usable, exit now!
   *============================================================*/  
  
  IF @today IS NULL RETURN @status
  IF @dos   IS NULL RETURN @status
  IF @dos > @today  RETURN @status
  
  /*============================================================
   * Calculate age in months 
   *============================================================*/  
   
  SET @age = dbo.CALC_AGE_IN_MONTHS(@dos,@today)
  
  /*============================================================
   * Get the day number for today 
   *============================================================*/  
  
  SET @day = datepart(d,@today)
  
  /*============================================================
   * Age is over 12 months.  Lost
   *============================================================*/  

  IF (@age > 12) SET @status  = -1 -- Lost
  
  /*============================================================
   * Age is less than 12 months.  Still have time
   *============================================================*/  

  
  IF (@age < 12) SET @status  =  0 -- Still have time
  
  /*============================================================
   * Age is 12 months.  This is the last month we can send it!
   *============================================================*/  

  IF (@age = 12)
  BEGIN
    
    /* It's been 11 months - the practitioner is unlikely to ever put in additional services */
	SET @status = 1 -- Out of time, send it!
  
  END
  
  RETURN @status
      
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_SUBMIT_CLAIM_OR_LOSE_CLAIM] TO [webuser]
GO