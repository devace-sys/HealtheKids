USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SITES_Audit]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SITES_Audit]
GO

USE [SPEDMON]
GO



/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SITES_Audit] (@recID BIGINT,     
                                              @loggedOn DATETIME,    
                                              @userID   BIGINT,    
                                              @saveType INT,    
                                              @state    SMALLINT,    
                                              @reason   VARCHAR(7000),    
                                              @recordID BIGINT   OUTPUT)
AS 
BEGIN

SET NOCOUNT ON

INSERT INTO dbo.SITES_Audit_Log (recID, loggedOn, userID, saveType, state, reason)
VALUES (@recID, @loggedOn, @userID, @saveType, @state, @reason)

SET @recordID = SCOPE_IDENTITY()

RETURN(0)

END

GO


