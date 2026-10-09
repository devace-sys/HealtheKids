USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_REIMBURSE_ESTIMATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_REIMBURSE_ESTIMATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_REIMBURSE_ESTIMATE] (
   @SVC_TYPE           int
 , @SVC_UNITS          int
 , @CLIENT_TCM_RATE    varchar(15)
 , @PROC_MIN_UNITS     nchar(10)
 , @PROC_MAX_UNITS     nchar(10)
 , @PROC_SVC_FEE       decimal(18,2)
 , @PROC_TCM_LOW_RATE  nchar(10)
 , @PROC_TCM_MED_RATE  nchar(10)
 , @PROC_TCM_HIGH_RATE nchar(10)
)
RETURNS money
AS     
BEGIN        

   declare @claimAmount     as money
   declare @div2            as money = convert(money,2)
   declare @edsPer          as money = convert(money,.965)
   declare @estimate        as money = 0
   
   set @claimAmount = dbo.CALC_CLAIM_AMOUNT (   @SVC_TYPE
                                              , @SVC_UNITS
                                              , @CLIENT_TCM_RATE
                                              , @PROC_MIN_UNITS
                                              , @PROC_MAX_UNITS
                                              , @PROC_SVC_FEE
                                              , @PROC_TCM_LOW_RATE
                                              , @PROC_TCM_MED_RATE
                                              , @PROC_TCM_HIGH_RATE)
   set @estimate = ((@claimAmount / @div2) * @edsPer)
   return convert(money,round(@estimate,2))
   
END				
				   
GO  