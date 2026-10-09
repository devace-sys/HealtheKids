USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORD_LAST_MODIFIED_BY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORD_LAST_MODIFIED_BY
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORD_LAST_MODIFIED_BY]    
()    
 RETURNS TABLE AS RETURN(    
  SELECT q1.svcRecID,     
         q1.loggedOn,     
         q1.id,     
         q2.userID    
  FROM (SELECT svcRecID,     
        MAX(loggedOn)      AS loggedOn,    
        MAX(id)            AS id         
        FROM    
        SERVICE_RECORDS_AUDIT_LOG    
        GROUP BY svcRecID) AS q1    
  JOIN SERVICE_RECORDS_AUDIT_LOG AS q2 ON q2.id = q1.id     
 )    
    
GO
