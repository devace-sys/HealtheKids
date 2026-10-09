USE [spedmon]
GO

DROP PROCEDURE IF EXISTS [dbo].[Timekeeper_RemoveFromFavoriteTasks]
GO


CREATE PROCEDURE [dbo].[Timekeeper_RemoveFromFavoriteTasks]
(

  @userID         BIGINT, -- not used
  @userGroup      INT, -- not used
  @userRank       INT, -- not used

  @recID            BIGINT,
  @taskID            BIGINT,

  @editDelReason  varchar(max), -- not used
  @validateRec    bit, -- not used
  @saveType       int, -- not used
    
  @MsgNoRec       VARCHAR(1000), -- not used
  @MsgNoEdit      VARCHAR(1000), -- not used
  @MsgDupRec      VARCHAR(1000), -- not used
  @MsgDataError   VARCHAR(1000), -- not used
  @MsgNotActive   VARCHAR(1000), -- not used

  @spDetails      VARCHAR(8000) OUTPUT,    
  @recordID       BIGINT        OUTPUT
)    
AS    
BEGIN
  SET @spDetails = '';
  exec [TimeKeeper].[dbo].[RemoveFromFavoriteTasks]  @recID, @taskID, @recordID output

END

GO


GRANT EXECUTE ON [dbo].[Timekeeper_RemoveFromFavoriteTasks]  TO [webuser]
GO