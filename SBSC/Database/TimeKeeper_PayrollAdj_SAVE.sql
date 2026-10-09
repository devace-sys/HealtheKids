USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TimeKeeper_PayrollAdj_SAVE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TimeKeeper_PayrollAdj_SAVE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[TimeKeeper_PayrollAdj_SAVE](
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

exec [TimeKeeper].[dbo].[PayrollAdj_SAVE]   @userID,
  @userGroup,  
  @userRank,
  @recID,
  @startdate,
  @amount,
  @notes_reason,
  @editDelReason,
  @validateRec,
  @MsgNoRec,
  @MsgNoEdit,
  @recordID output,
  @spDetails output

end
GO

GRANT execute on dbo.TimeKeeper_PayrollAdj_SAVE to webuser
GO