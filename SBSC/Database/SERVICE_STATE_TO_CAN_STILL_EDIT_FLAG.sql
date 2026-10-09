USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG](@state int) 
RETURNS bit
as 
begin
return convert (
    bit 
  ,(case 
      when @state = dbo.CONST_SVC_REC_STATE_NEW()  then 1
      when @state = dbo.CONST_SVC_REC_STATE_MOD()  then 1
      when @state  = dbo.CONST_SVC_REC_STATE_HOLD() then 1
      else 0 
    end))
end    
go
