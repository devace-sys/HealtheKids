USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.SERVICE_AUTHORIZATION_REQUEST_SET_STATUS ( 
    @requestID     bigint
  , @createdOn     datetime
  , @createdBy     bigint
  , @statusCode    bigint
  , @contextData   varchar(max)
)
AS
BEGIN

/***************************************************************************    
 * SERVICE_AUTHORIZATION_REQUEST_SET_STATUS */    
/**    
 * Creates file upload status record
 *
 ***************************************************************************/     


declare @recordID as bigint = null

/*###########################################################################
  # Exit if required values are not provided
  ###########################################################################*/  

if (@requestID  is null) return(1)
if (@statusCode is null) return(1)


/*###########################################################################
  # Set optional values to their defaults
  ###########################################################################*/  
 
if (@createdOn   is null) set @createdOn   = GETDATE()
if (@createdBy   is null) set @createdBy   = 0

/*###########################################################################
  # Save status 
  ###########################################################################*/  

set @recordID = null

insert into dbo.SERVICE_AUTHORIZATION_REQUEST_PROCESSING_STATUS_LOG (
     requestID
   , createdOn
   , createdBy
   , statusCode
   , contextData
) 
values (
    @requestID
  , @createdOn
  , @createdBy
  , @statusCode
  , @contextData
)

set @recordID = SCOPE_IDENTITY()   

/*###########################################################################
  # Update parent with current status
  ###########################################################################*/  

update dbo.SERVICE_AUTHORIZATION_REQUESTS 
set 
    currentStatusCode       = @statusCode
  , currentStatusLogEntryID = @recordID
  , lastModified            = @createdOn
  , lastModifiedBy          = @createdBy 
where (id = @requestID)

/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[SERVICE_AUTHORIZATION_REQUEST_SET_STATUS] TO [webuser]
GO