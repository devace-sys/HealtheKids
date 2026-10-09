USE SPEDMON
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE
GO

CREATE PROCEDURE [dbo].[RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE] (
    @userID        BIGINT    
  , @userGroup     INT    
  , @userRank      INT    
  , @clientID      INT    --

  , @rmtsReqID     BIGINT
  , @uploadedRptType int  -- TODO: don't think I'm using this anymore, should be removed

  , @isPrac        BIT

  , @editDelReason VARCHAR(7000)
  , @validateRec   BIT
  , @saveType      INT

  , @recID         BIGINT -- svcrecID   

  , @msgDupRec          VARCHAR(1000)    

  , @MsgNoRec           VARCHAR(1000)     
  , @MsgNoEdit          VARCHAR(1000)     
  , @MsgDataError       VARCHAR(1000)    





  , @MsgNotActive       VARCHAR(1000)


  , @spDetails          VARCHAR(8000) OUTPUT
  , @recordID           BIGINT        OUTPUT)    
AS    
BEGIN     
     
SET NOCOUNT ON    

declare @today             as datetime

set @today                     = getdate()
set @spDetails                 = ''
set @recordID                  = 0

declare @existingMatched       bigint;

select
         @recordID                 = id
       , @existingMatched          = svcRecID
       from [dbo].[RMTS_Moments]
       where id = @rmtsReqID AND clientID = @clientID

 IF ( ISNULL( @recordID, 0) = 0) 
  RAISERROR('Error: item not found.  Cannot match.', 11, 1)

 IF ( ISNULL( @existingMatched, 0) != 0) 
  RAISERROR('Error: item already matched to an existing servicerecord; cannot match to a servicerecord.  Unmatch this RMTS moment to continue; contact support if necessary.', 11, 1)

if (@validateRec = 1) return

  UPDATE [dbo].[RMTS_Moments]
  SET

    [svcRecID] = @recID,
    [svcrecIsAutoMatched] = 0,

    isComplete = 1,    

    mustCorrectThisMistake = 0,

    --rmtsReqNextStep = CASE WHEN @isPrac = 1 THEN 2 ELSE 3 END,
    rmtsReqNextStep = 3,

    rmtsReqState = CASE WHEN @isPrac = 1 THEN 5 ELSE 3 END  -- this needs to be 5 when called by a prac, 3 when called by an LEAcoor

  -- WHERE ( ID = @rmtsReqID
  --  AND clientID = @clientID )

  WHERE ID = @rmtsReqID
  
/*-------------------------------    
 * And we are done
 *------------------------------*/  

RETURN(0)    



END  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[RMTS_MOMENT_MATCH_SERVICE_RECORD_CORE] TO [webuser]
GO