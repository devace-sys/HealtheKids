USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_STATUS_TO_NAME') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_STATUS_TO_NAME
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLAIM_STATUS_TO_NAME](@status INT) 
RETURNS nvarchar(50) 
AS    
BEGIN    

  DECLARE @name AS NVARCHAR(50)    

  SELECT @name = CASE (@status) 
    WHEN dbo.CONST_CLAIM_STATUS_NOT_SUB()             THEN 'Not Yet Submitted' 
    WHEN dbo.CONST_CLAIM_STATUS_SUB_PENDING()         THEN 'Submitted Awaiting Adjudication' 
    WHEN dbo.CONST_CLAIM_STATUS_CHILD_OF_SENT_PROXY() THEN 'Submitted Awaiting Adjudication'
    WHEN dbo.CONST_CLAIM_STATUS_SUB_PAID()            THEN 'Paid' 
    WHEN dbo.CONST_CLAIM_STATUS_RECV_PROXY_PAID()     THEN 'Paid'
    WHEN dbo.CONST_CLAIM_STATUS_SUB_REJECT()          THEN 'Denied' 
    when dbo.CONST_CLAIM_STATUS_RECV_PROXY_DENIED()   THEN 'Denied'
  END

  RETURN @name     
END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[CLAIM_STATUS_TO_NAME] TO [webuser]
GO