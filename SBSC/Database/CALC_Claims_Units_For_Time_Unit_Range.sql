USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_Claims_Units_For_Time_Unit_Range') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_Claims_Units_For_Time_Unit_Range
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_Claims_Units_For_Time_Unit_Range] (   
    @initialProc          bit = 1
  , @minUnits             int = 0
  , @maxUnits             int = 0
  , @timeUnitMinsStart    int = -1
  , @timeUnitMinsEnd      int = -1
  , @timeUnitMinsRoundAt  int = -1
  , @numMins              int = 0
)
 
/***************************************************************************    
 * CALC_Claims_Units_For_Time_Unit_Range */    
/**    
 * Calculate claim units from the given params
 *
 ***************************************************************************/ 
      
returns @data TABLE (
    numUnitsAssigned   int
  , numMinsApplied     int
  , roundingApplied    bit
  , numMinsRemaining   int
)
AS     
BEGIN
  
  if (@minUnits not in (0,1))  return
  if (@maxUnits != 1)          return
  if (@timeUnitMinsStart <= 0) return
  if (@timeUnitMinsEnd   <= 0) return
  if (@timeUnitMinsStart = @timeUnitMinsEnd) return
  if (@timeUnitMinsStart > @timeUnitMinsEnd) return
  if (@initialProc = 0)                      return /* Only applies for initial procedure */

  declare @numUnitsAssigned  as int = 0
  declare @numMinsApplied    as int = 0
  declare @roundingApplied   as bit = 0
  declare @numMinsRemaining  as int = 0
  
  if (@numMins < @timeUnitMinsStart) 
  begin
    set @numUnitsAssigned  = 0  
    set @numMinsApplied    = 0  
    set @numMinsRemaining  = 0

    /* If we can possibly round */

	if ((@minUnits = 0) and (@timeUnitMinsRoundAt > 0))  
    begin

      /* And the minutes equal or cross the threshold then we can assign 1 unit to procedure 1 */

      if (@numMins >= @timeUnitMinsRoundAt) 
	  begin	    
	    set @numUnitsAssigned      = 1
	    set @numMinsApplied        = @numMins
        set @roundingApplied       = 1
	  end 
    end /* Can possibly round */
  end /* Less than range */

  else if (@numMins between @timeUnitMinsStart and @timeUnitMinsEnd)
  begin
    set @numUnitsAssigned  = 1
    set @numMinsApplied    = @numMins  
    set @numMinsRemaining  = 0
  end /* Within range */
  
  else if (@numMins > @timeUnitMinsEnd)
  begin
    set @numUnitsAssigned       = 1
    set @numMinsApplied         = @timeUnitMinsEnd  
    set @numMinsRemaining       = @numMins - @timeUnitMinsEnd
  end /* Greater than range */

  insert into @data (
      numUnitsAssigned
    , numMinsApplied 
    , roundingApplied
    , numMinsRemaining
  )
  values (
      @numUnitsAssigned
    , @numMinsApplied 
    , @roundingApplied
    , @numMinsRemaining
  )  

  return

END
GO
