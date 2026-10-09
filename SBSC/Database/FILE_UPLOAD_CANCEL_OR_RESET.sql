USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_CANCEL_OR_RESET') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_CANCEL_OR_RESET
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_CANCEL_OR_RESET ( 
    @uploadID                 bigint
  , @updatedByUserID          bigint   
  , @updatedOn                datetime
)
AS
BEGIN

/***************************************************************************    
 * FILE_UPLOAD_CANCEL_OR_RESET */    
/**    
 * Creates file upload record
 *
 ***************************************************************************/     

declare @statusCode as bigint = dbo.CONST_FILE_UPLOAD_STATUS_INITIAL()
declare @statusID   as bigint

/*###########################################################################
  # See if record exists or if it neeed to be updated
  ###########################################################################*/  

declare @recordID as bigint = null
select @recordID = id from FILE_UPLOADS where ((id = @uploadID) and (currentStatusCode = @statusCode))
if (@recordID is null) return (1)

/*###########################################################################
  # If so go ahead and update the record
  ###########################################################################*/  

update FILE_UPLOADS set 
    active            = 0
  , lastUpdatedBy     = @updatedByUserID
  , lastUpdatedOn     = @updatedOn 
where id = @recordID

/*###########################################################################
  # Set status
  ###########################################################################*/  

set @statusCode = dbo.CONST_FILE_UPLOAD_STATUS_DATA_FORM_CANCEL_OR_RESET()
exec FILE_UPLOAD_SET_STATUS @recordID, @updatedOn, @updatedByUserID, @statusCode, null, null, null, @statusID output


/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_SAVE] TO [webuser]

GO