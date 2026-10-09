USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

 IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PROMISED_MINS_SATISFIED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PROMISED_MINS_SATISFIED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CALC_PROMISED_MINS_SATISFIED](
    @numMins                       int = 0
  , @patAbsent                     bit = 0
  , @pracAbsent                    bit = 0
  , @makeupSession                 bit = 0
  , @patAbsentMinsAreSatisfiedMins bit = 1
  , @attendanceSelectionID         int = -1
) 
RETURNS INT 
AS     
BEGIN 
  
  declare @minsOut as int = 0
  
  select top 1 
    @minsOut = t1.numMinsSatisfied 
  from dbo.CALC_PROMISED_MINS_SATISFIED_AS_ROW (
      @numMins
	, @patAbsent
	, @pracAbsent
	, @makeupSession
	, @patAbsentMinsAreSatisfiedMins
	, @attendanceSelectionID ) as t1

  return @minsOut
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_PROMISED_MINS_SATISFIED] TO [webuser]
GO