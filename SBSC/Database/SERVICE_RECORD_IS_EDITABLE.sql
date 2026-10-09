USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_IS_EDITABLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_IS_EDITABLE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
-- TODO: Remove this function it is no longer used.

CREATE FUNCTION [dbo].[SERVICE_RECORD_IS_EDITABLE](@userID INT, @userGroup INT, @userRank INT, @status1 CHAR(1), @status2 CHAR(1), @updateState INT, @recUserID INT) RETURNS bit AS    
BEGIN    
      
  DECLARE @clmRecsOK AS BIT    
  DECLARE @svcRecOK  AS BIT    
  DECLARE @canEdit   AS BIT    
      
  /*-------------------------------    
   * Immediate rejects    
   *------------------------------*/    
      
  IF (@updateState = dbo.CONST_SVC_REC_STATE_PORT_HEBS()) RETURN 0    
  IF (@updateState = dbo.CONST_SVC_REC_STATE_DEL())       RETURN 0    
  IF (@updateState = dbo.CONST_SVC_REC_STATE_CLOSED())    RETURN 0    
      
  /*-------------------------------    
   * Clients are only allowed to    
   * edit records they entered    
   * unless they are a district    
   * coordinator    
   *------------------------------*/    
     
  IF (@userGroup = dbo.CONST_USER_GROUP_CLIENT())     
  BEGIN        
    IF ((@userRank < 2) AND (@userID <> @recUserID)) RETURN 0    
  END    
        
  /*-------------------------------    
   * Input staff are only allowed    
   * to edit records they entered    
   * unless they are a work leader    
   * or higher    
   *------------------------------*/    
       
  IF (@userGroup = dbo.CONST_USER_GROUP_SBS())     
  BEGIN    
    IF ((@userRank < 2) AND (@userID <> @recUserID)) RETURN 0    
  END    
      
  /*-------------------------------    
   * Check claim status    
   *------------------------------*/    
      
  SET @clmRecsOK = 0    
  SET @status1   = ISNULL(@status1,'')    
  SET @status2   = ISNULL(@status2,'')    
  --SET @status1   = LTRIM(RTRIM(@status1))     
  --SET @status2   = LTRIM(RTRIM(@status2))    
      
  IF (@status1 = '1' OR @status1 = '') AND     
     (@status2 = '1' OR @status2 = '')     
  SET @clmRecsOK = 1    
           
  /*-------------------------------    
   * Check service record state    
   *------------------------------*/    
      
  SET @svcRecOK = 0    
      
  IF ((@updateState = dbo.CONST_SVC_REC_STATE_NEW()) OR    
     (@updateState  = dbo.CONST_SVC_REC_STATE_MOD()) OR    
     (@updateState  = dbo.CONST_SVC_REC_STATE_HOLD()))    
  SET @svcRecOK  = 1    
      
  SET @canEdit = 0    
  IF ((@svcRecOK = 1) AND (@clmRecsOK = 1)) SET @canEdit = 1    
      
  RETURN @canEdit    
      
END    
    
GO
