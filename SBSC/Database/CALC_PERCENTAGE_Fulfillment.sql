USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_PERCENTAGE_Fulfillment') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_PERCENTAGE_Fulfillment
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION dbo.CALC_PERCENTAGE_Fulfillment (
    @satisfied       int
  , @expected        int
) 
RETURNS REAL 
with schemabinding 
AS     
BEGIN
     
/* If nothing is expected and nothing is satisfied then we treat this as 100% */

if ((@satisfied = 0) and (@expected = 0))
begin
  set @satisfied = 1
  set @expected  = 1
end

/* Cap at 100% for cases where there is over delivery */

if (@satisfied > @expected)
begin
  set @satisfied = @expected
end

return dbo.CALC_PERCENTAGE (
    @satisfied    
  , @expected
  , 1 
  , 1 
  , 0)

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[CALC_PERCENTAGE_Fulfillment] TO [webuser]
GO