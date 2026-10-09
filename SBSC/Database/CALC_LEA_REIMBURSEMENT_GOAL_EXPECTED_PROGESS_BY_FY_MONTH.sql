USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_LEA_REIMBURSEMENT_GOAL_EXPECTED_PROGESS_BY_FY_MONTH') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_LEA_REIMBURSEMENT_GOAL_EXPECTED_PROGESS_BY_FY_MONTH
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CALC_LEA_REIMBURSEMENT_GOAL_EXPECTED_PROGESS_BY_FY_MONTH] (
   @refDate           as date
 , @leaRecoveryBudget as money
)


RETURNS money
WITH SCHEMABINDING 
AS    
BEGIN


  declare @expectedAmt as money = 0
  declare @pctFactor   as money = 0  
  declare @month       as int
  
  if (@refDate is null)           set @refDate           = convert(date,getdate())
  if (@leaRecoveryBudget is null) set @leaRecoveryBudget = 0

  /* Percentages updated at the end of each month,
   * so we need to use the previous month's percentage
   * value for the current date
   */

  set @month = (datepart(MONTH,@refDate) - 1)

  if (@month = 0)
  begin
	set @month = 12
  end

  set @pctFactor = case 
    when @month in (7,8)   then 0
	when @month = 9        then .05
	when @month = 10       then .10
	when @month = 11       then .20
	when @month = 12       then .25
	when @month = 1        then .37
    when @month = 2        then .50
    when @month = 3        then .62
	when @month = 4        then .75
	when @month = 5        then .87
	when @month = 6        then 1
	else 0
   end     
   set @expectedAmt = (0.80 * @leaRecoveryBudget * @pctFactor)
   return @expectedAmt
END    
GO
