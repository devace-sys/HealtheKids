USE TimeKeeper
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PayrollAdj_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PayrollAdj_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PayrollAdj_SAVE](
    @userID               BIGINT    
  , @userGroup            INT  
  , @userRank             INT 
  , @recID                bigint
  , @startdate            date
  , @amount               decimal(10,2)
  , @notes_reason         varchar(max)
  , @editDelReason        VARCHAR(7000)
  , @validateRec          VARCHAR(7000)
  , @MsgNoRec             varchar(max)
  , @MsgNoEdit            varchar(max)
  , @recordID             BIGINT        OUTPUT
  , @spDetails            VARCHAR(8000) OUTPUT)  
AS    
BEGIN

SET @spDetails = ''
if not exists (
  select top 1 
    *
  from [dbo].[PayrollAdjustments]
  where ( 
      [period_startdate] = @startdate
  and [eid] = @recID
  )
)
begin
  INSERT INTO [dbo].[PayrollAdjustments]
    SELECT @recID, @startdate, @amount, @notes_reason
end
else
begin
  UPDATE [dbo].[PayrollAdjustments]
  SET [adjustment_amount] = @amount,
      [adjustment_notes_reason] = @notes_reason
  WHERE [period_startdate] = @startdate
  and [eid] = @recID
end
SET @recordID = @recID
return 0
end
GO

GRANT execute on dbo.PayrollAdj_SAVE to webuser
GO