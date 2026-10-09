USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_Claims_Units_For_Time_Units') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_Claims_Units_For_Time_Units
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_Claims_Units_For_Time_Units] (    
     @span2                 bit
   , @minUnits1             int
   , @maxUnits1             int
   , @minUnits2             int
   , @maxUnits2             int
   , @timeUnitMinsStart1    int
   , @timeUnitMinsEnd1      int
   , @timeUnitMinsRoundAt1  int
   , @timeUnitMinsStart2    int
   , @timeUnitMinsEnd2      int
   , @timeUnitMinsRoundAt2  int
   , @numMins               int
)
 
/***************************************************************************    
 * CALC_Claims_Units_For_Time_Units */    
/**    
 * Calculate claim units from the given params
 *
 ***************************************************************************/ 
      
returns @unitData table (
    idx                int
  , numUnitsAssigned   int
  , numMinsApplied     int
  , roundingApplied    bit
  , numMinsRemaining   int
)
AS     
BEGIN
  
  declare @numMinsRemaining as int = 0

  /* Fixed units per minute */
  
  if (@timeUnitMinsStart1 = @timeUnitMinsEnd1)
  begin
    insert into @unitData
    select 
	    procNum = 1
	  , t1.* 
    from dbo.CALC_Claims_Units_For_Time_Unit_Fixed (
        1   /*@initialProc */
      , @minUnits1           
      , @maxUnits1           
      , @timeUnitMinsStart1  
      , @timeUnitMinsEnd1    
      , @timeUnitMinsRoundAt1
      , @numMins) as t1  
	  option(recompile)   
  end
  
  /* Minute range per unit (ie 15-45) */

  else if (@timeUnitMinsStart1 < @timeUnitMinsEnd1)
  begin
    insert into @unitData
    select 
	    idx = 1
	  , t1.* 
	from dbo.CALC_Claims_Units_For_Time_Unit_Range (
        1   /*@initialProc */
      , @minUnits1           
      , @maxUnits1           
      , @timeUnitMinsStart1  
      , @timeUnitMinsEnd1    
      , @timeUnitMinsRoundAt1
      , @numMins) as t1
	  option(recompile)
  end
  else
  begin
    return /* Invalid */
  end

  if (@span2 = 1)
  begin
    
	select top 1 @numMinsRemaining = numMinsRemaining from @unitData where idx = 1
  
    /* Fixed units per minute (only type supported for additional proc) */

    insert into @unitData	  
	select 
        idx = 2
	  , t1.* 
    from dbo.CALC_Claims_Units_For_Time_Unit_Fixed (
        0   /*@initialProc */
      , @minUnits2           
      , @maxUnits2           
      , @timeUnitMinsStart2  
      , @timeUnitMinsEnd2    
      , @timeUnitMinsRoundAt2
      , @numMinsRemaining) as t1
	  option(recompile)
  end

  return

END
GO
