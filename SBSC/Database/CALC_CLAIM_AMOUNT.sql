USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CALC_CLAIM_AMOUNT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CALC_CLAIM_AMOUNT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CALC_CLAIM_AMOUNT] (
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
WITH SCHEMABINDING 
AS     
BEGIN        
   
   declare @svcUnits    as money
   declare @svcFee      as money
   declare @minUnits    as int
   declare @maxUnits    as int   
   declare @claimAmount as money
   
   set @svcFee    = CONVERT(money,@PROC_SVC_FEE)
   set @svcUnits  = CONVERT(money,@SVC_UNITS)
   
   if (@SVC_TYPE = 4) /* TCM */
   begin
     set @CLIENT_TCM_RATE = lower(ltrim(rtrim(isnull(@CLIENT_TCM_RATE,''))))
     if      (@CLIENT_TCM_RATE = 'low')     set @svcFee = convert(money,@PROC_TCM_LOW_RATE)
     else if (@CLIENT_TCM_RATE = 'med')     set @svcFee = convert(money,@PROC_TCM_MED_RATE)
     else if (@CLIENT_TCM_RATE = 'high')    set @svcFee = convert(money,@PROC_TCM_HIGH_RATE)
     else                                   set @svcFee = convert(money,@PROC_TCM_LOW_RATE)    
   end
   else 
   begin
     set @minUnits = CONVERT(int,isnull(@PROC_MIN_UNITS,0))
     set @maxUnits = CONVERT(int,isnull(@PROC_MAX_UNITS,0))
     if ((@minUnits = 1) and (@maxUnits = 3)) /* 15-45.  Only one unit */
     begin       
       set @svcUnits = convert(money,1)
     end     
   end
   
   set @claimAmount = (@svcFee * @svcUnits)
   return @claimAmount
END				
				   
GO  