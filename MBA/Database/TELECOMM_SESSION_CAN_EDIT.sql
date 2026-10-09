USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TELECOMM_SESSION_CAN_EDIT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.TELECOMM_SESSION_CAN_EDIT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[TELECOMM_SESSION_CAN_EDIT](
   @active    BIT
 , @startDate DATETIME
 , @endDate   DATETIME
) 
RETURNS BIT
AS     
BEGIN  
  if (@active = 0) return 0  
  declare @today as datetime = getdate()
  if (@startDate > @today)  return 1  
  if (@startDate <= @today) return 0
  if (@endDate   <= @today) return 0
  return 1  
END    
GO
