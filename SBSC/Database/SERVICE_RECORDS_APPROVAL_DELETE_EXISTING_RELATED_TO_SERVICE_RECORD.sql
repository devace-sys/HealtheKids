USE SPEDMON
GO

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 

CREATE PROCEDURE dbo.SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD
(
  @userID          BIGINT,    
  @userGroup       INT,    
  @userRank        INT,
  @svcRecID        BIGINT)

AS
BEGIN

/***************************************************************************    
 * SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD */ 
/**    
 * Create a new service record approval record
 *    
 * @param   userID          The userid of who saved the record    
 * @param   userGroup       Users group    
 * @param   userRank        User rank    
 * @param   svcRecID        Service record to associate with this note
 ***************************************************************************/     

/*============================================================
 * Verify incoming parameters that are essential for proper op
 *============================================================*/  
    
IF (@userID      IS NULL) RAISERROR ('userID is required',            11, 1)
IF (@userGroup   IS NULL) RAISERROR ('userGroup is required',         11, 1)    
IF (@userRank    IS NULL) RAISERROR ('userRank is required',          11, 1)    
IF (@svcRecID    IS NULL) RAISERROR ('Service record id is required', 11, 1)

/*============================================================
 * If this was entered by a non client get out
 *============================================================*/ 
  
IF (@userGroup != dbo.CONST_USER_GROUP_CLIENT()) RETURN (0)  

/*============================================================
 * "Delete"
 *============================================================*/ 

update dbo.SERVICE_RECORDS_APPROVAL 
set active = 0
where ((active = 1) and (svcRecID = @svcRecID))
  
return (0)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SERVICE_RECORDS_APPROVAL_DELETE_EXISTING_RELATED_TO_SERVICE_RECORD] TO [webuser]
GO

