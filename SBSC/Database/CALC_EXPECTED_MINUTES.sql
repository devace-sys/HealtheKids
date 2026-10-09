USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_EXPECTED_MINUTES') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_EXPECTED_MINUTES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CALC_EXPECTED_MINUTES]
(@sched      as bit,
 @entryMins  as int,
 @schedMins  as int
)

RETURNS int 
WITH SCHEMABINDING 
AS    
BEGIN
  
  /***************************************************************************    
   * CALC_EXPECTED_MINUTES */    
  /**    
   * Returns int if it is less than equal to max or max if it is greater than
   * max.
   *   
   * @param  int             Integer to evaluate
   * @param  max             Max value
   * @return                 Integer
   ***************************************************************************/  
    
  declare @hasEntryMins as bit = 0
  declare @hasSchedMins as bit = 0
  
  /*-------------------------------    
   * Exit if schedule is true
   * with schedule minutes
   *------------------------------*/

  if @sched is null set @sched = 0    
  if @sched = 1 return @schedMins
     
  /*-------------------------------    
   * Determine if we have entry 
   * minutes
   *------------------------------*/
    
  if (@entryMins is null) set @hasEntryMins = 0
  if (@entryMins = 0)     set @hasEntryMins = 1
  if (@entryMins > 0)     set @hasEntryMins = 1

   /*-------------------------------    
    * Determine if we have schedule
    * minutes
    *------------------------------*/
  
  if (@schedMins is null) set @hasSchedMins = 0
  if (@schedMins = 0)     set @hasSchedMins = 1
  if (@schedMins > 0)     set @hasSchedMins = 1
  
  /*-------------------------------    
   * If we have neither return null
   *------------------------------*/

  if (@hasEntryMins = 0 and @hasSchedMins = 0) return null

  /*-------------------------------    
   * If we have just schedule 
   * return it
   *------------------------------*/

  if (@hasEntryMins = 0 and @hasSchedMins = 1) return @schedMins  

  /*-------------------------------    
   * If we have just entry
   * return it
   *------------------------------*/

  if (@hasEntryMins = 1 and @hasSchedMins = 0) return @entryMins
   
  /*-------------------------------    
   * If we have BOTH return the 
   * lessor of
   *
   * 1. Schedule
   * 2. Entry
   *------------------------------*/
   
  if (@hasEntryMins = 1 and @hasSchedMins = 1)
  begin
    
    /*-------------------------------    
     * Schedule is less than entry
     * probably a minimum day or a 
     * day school is not in session
     *------------------------------*/

    if @schedMins < @entryMins return @schedMins

    /*-------------------------------    
     * Schedule is greater than entry
     * indicates that patient is
     * receiving less than scheduled
     * mins for that day
     *------------------------------*/

    if @schedMins > @entryMins return @entryMins
    
    /*-------------------------------    
     * Both the same, return one 
     *------------------------------*/

    if @schedMins = @entryMins return @entryMins
        
  end

  /*-------------------------------    
   * If we reach this point we
   * dont know what to do
   *------------------------------*/
    
  return null
  
END    
GO
