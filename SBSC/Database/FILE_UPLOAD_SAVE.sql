USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_SAVE ( 
    @userID                   bigint
  , @userGroup                int
  , @userRank                 int
  , @clientID                 bigint
  , @pracID                   bigint
  , @groupID                  bigint
  , @patID                    bigint
  , @originalName             varchar(8000)
  , @savedName                varchar(8000)
  , @fileUploadedByUserID     bigint
  , @fileUploaderContactEmail varchar(4000)
  , @fileUploadedFromSource   bigint
  , @fileClass                bigint
  , @fileSubClass             varchar(100)
  , @fileSize                 bigint
  , @fileMimeType             varchar(8000)
  , @recordID                 BIGINT        OUTPUT
)
AS
BEGIN

/***************************************************************************    
 * FILE_UPLOAD_SAVE */    
/**    
 * Creates file upload record
 *
 ***************************************************************************/     

/*###########################################################################
  # Init 
  ###########################################################################*/  
  
declare @today                      as datetime = getdate()
declare @lookupEmail                as bit = 0

set @recordID    = null
set @lookupEmail = 0

/*###########################################################################
  # If the contact email is not provided and we have a user id use the users
  # email.
  ###########################################################################*/  

if (@fileUploaderContactEmail is null) 
begin
  set @lookupEmail = 1
end
else
begin
  set @fileUploaderContactEmail = ltrim(rtrim(@fileUploaderContactEmail))
  if (@fileUploaderContactEmail = '') set @lookupEmail = 1
end

if ((@fileUploadedByUserID is not null) and (@lookupEmail = 1))
begin
  select top 1
    @fileUploaderContactEmail = m.Email 
  from users.dbo.Users      as u 
  join users.dbo.Membership as m on m.UserId = u.UserId
  where (u.userrid = @fileUploadedByUserID)
end

/*###########################################################################
  # Save file upload record
  ###########################################################################*/  

insert into dbo.FILE_UPLOADS (
    userID
  , userGroup
  , userRank
  , clientID
  , pracID
  , groupIDDisp
  , patID  
  , originalName
  , savedName
  , fileUploaded
  , fileUploadedFrom
  , fileUploadedBy
  , fileUploaderContactEmail
  , fileClass
  , fileSubClass
  , fileSize
  , fileMimeType
  , processFile
  , reviewFile
  , active )      

values (
    @userID
  , @userGroup
  , @userRank
  , @clientID
  , @pracID
  , @groupID
  , @patID
  , @originalName
  , @savedName
  , @today
  , @fileUploadedFromSource  
  , @fileUploadedByUserID
  , @fileUploaderContactEmail
  , @fileClass
  , @fileSubClass
  , @fileSize
  , @fileMimeType
  , 0
  , 0  
  , 1  )

set @recordID = SCOPE_IDENTITY()

/*###########################################################################
  # Set status
  ###########################################################################*/  

declare @statusCode as bigint = dbo.CONST_FILE_UPLOAD_STATUS_INITIAL()
declare @statusID   as bigint

exec FILE_UPLOAD_SET_STATUS @recordID, @today, @fileUploadedByUserID, @statusCode, @originalName, @savedName, null, @statusID output

  
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