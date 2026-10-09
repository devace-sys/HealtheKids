USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE] (
    @userID                bigint    
  , @visitID               bigint
  , @today                 datetime
  , @statusCode            int
)  
AS    
BEGIN    
   
/***************************************************************************    
 * PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE */    
/**    
 * Note: This routine relies on the caller to provide a transaction block
 ***************************************************************************/        

/*============================================================
 * Add row to log
 *============================================================*/  

insert into dbo.PRACTICE_OFFICE_VISIT_STATUS_LOG (
   visitID
 , statusCode
 , loggedOn
 , userID )
values (
    @visitID
  , @statusCode
  , @today
  , @userID ) 

/*============================================================
 * Update current status 
 *============================================================*/  

update dbo.PRACTICE_OFFICE_VISITS 
set 
    currentVisitStatusCodeValue	  = @statusCode
  , lastModified                  = @today
  , lastModifiedBy                = @userID
where 
  (id = @visitID)

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTICE_OFFICE_VISITS_UPDATE_STATUS_LOG_CORE] TO [webuser]
GO
