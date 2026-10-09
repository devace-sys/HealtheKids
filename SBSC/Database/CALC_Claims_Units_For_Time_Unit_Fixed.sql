USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_Claims_Units_For_Time_Unit_Fixed') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_Claims_Units_For_Time_Unit_Fixed
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_Claims_Units_For_Time_Unit_Fixed] (
    @initialProc          bit = 1
  , @minUnits             int = 0
  , @maxUnits             int = 0
  , @timeUnitMinsStart    int = -1
  , @timeUnitMinsEnd      int = -1
  , @timeUnitMinsRoundAt  int = -1
  , @numMins              int = 0
)
 
/***************************************************************************    
 * CALC_Claims_Units_For_Time_Unit_Fixed */    
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
  
  if (@minUnits not in (0,1))                 return
  if (@maxUnits < 1)                          return
  if (@timeUnitMinsStart <= 0)                return
  if (@timeUnitMinsEnd   <= 0)                return
  if (@timeUnitMinsStart != @timeUnitMinsEnd) return

  declare @numUnitsAssigned  as int = 0
  declare @numMinsApplied    as int = 0
  declare @roundingApplied   as bit = 0
  declare @numMinsRemaining  as int = 0
  declare @remainder         as int = 0
  declare @calcUnits         as bit = 1

  if ((@numMins < @timeUnitMinsStart) and (@minUnits >= 1))
  begin
    if (@initialProc = 1)
	begin
	  
	  set @calcUnits = 0
	end    
  end
  
  if (@calcUnits = 1)
  begin
  
    set @numUnitsAssigned  = @numMins / @timeUnitMinsStart 
   
    if (@timeUnitMinsRoundAt > 0)
    begin
      set @remainder = @numMins % @timeUnitMinsStart
      if (@remainder >= @timeUnitMinsRoundAt) 
	  begin
	    set @numUnitsAssigned = @numUnitsAssigned + 1 
        set @roundingApplied  = 1
	  end /* remain*/
    end /* minsroundat */

    if (@numUnitsAssigned > @maxUnits)    
    begin
	  set @numMinsApplied   = (@maxUnits * @timeUnitMinsStart)	  
	  set @numUnitsAssigned = @maxUnits
	  set @numMinsRemaining = (@numMins - @numMinsApplied)
    end /* unitsassigned > maxunits*/
    else
	begin
	  set @numMinsApplied = @numMins
	end /* unitsassigned <= maxunits */
  end
                 
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
