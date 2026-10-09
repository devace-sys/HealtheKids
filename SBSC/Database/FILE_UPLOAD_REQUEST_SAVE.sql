USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_REQUEST_SAVE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.FILE_UPLOAD_REQUEST_SAVE
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.FILE_UPLOAD_REQUEST_SAVE ( 
  @request_public     bit,
  @request_private    bit,
  @request_id         varchar(1000),
  @request_token      varchar(1000),
  @request_ip         varchar(1000),
  @request_user_agent varchar(8000),
  @request_datetime   datetime,
  @county_code        varchar(2),
  @district_code      varchar(5),
  @last_name          varchar(1000),
  @first_name         varchar(1000),
  @work_email         varchar(1000),
  @file_class         bigint,
  @file_type          varchar(100),
  @ref_date           datetime,
  @uploaded_as        varchar(4000),
  @saved_as           varchar(4000),
  @saved_in           varchar(4000),
  @uploaded_from      bigint,
  @fileSize           bigint,
  @fileMimeType       varchar(8000)
)
AS
BEGIN

/***************************************************************************    
 * FILE_UPLOAD_REQUEST_SAVE */    
/**    
 * Public file upload request
 *
 ***************************************************************************/     

declare @uploadId as bigint = null

/*###########################################################################
  # This is a public upload
  ###########################################################################*/  

if (@uploaded_from = 1)

begin

  declare @userIDRef    as bigint     = null
  declare @clientIdRef  as bigint     = null
  declare @pracIdRef    as bigint     = null
  declare @clientCDSRef as varchar(7) = ''

  /*============================================================
   * Attempt to determine what client this came from (if any)
   *============================================================*/  	

  set @clientCDSRef = @county_code + @district_code
  select top 1 @clientIdRef = CLIENT_ID from CLIENTS_Client where (CLIENT_CDS = @clientCDSRef)

  /*============================================================
   * Attempt to determine what user this came from
   *============================================================*/  	
  
  select top 1 @userIDRef = u.userrid from users.dbo.Membership as m join users.dbo.Users as u on u.UserId = m.UserId where m.Email = @work_email


  /*============================================================
   * Attempt to determine what practitioner this came from (if any)
   *============================================================*/  	

  select top 1 @pracIdRef = PRACTITIONER_ID from PRACTITIONER_Practitioner as pp where pp.EMAIL = @work_email
  
  /*============================================================
   * Create new file upload record
   *============================================================*/  	

exec dbo.FILE_UPLOAD_SAVE 

    @userIDRef
  , null
  , null
  , @clientIDRef
  , @pracIDRef
  , null
  , null
  , @uploaded_as
  , @saved_as
  , @userIDRef
  , @work_email
  , @uploaded_from
  , @file_class
  , @file_type
  , @fileSize
  , @fileMimeType
  , @uploadID output


 /*============================================================
  * Add reference date to new record
  *============================================================*/  	

update dbo.FILE_UPLOADS set ReferenceDate1 = @ref_date where id = @uploadID


end

/*###########################################################################
  # Save new upload request record
  ###########################################################################*/  
  
insert into FILE_UPLOAD_REQUESTS (  

  [request_public],
  [request_private],
  [request_id],
  [request_token],
  [request_ip],
  [request_user_agent],
  [request_datetime],
  [county_code],
  [district_code],
  [last_name],
  [first_name],
  [work_email],
  [file_class],
  [file_type],
  [ref_date],
  [uploaded_as],
  [saved_as],
  [saved_in],
  [uploaded_from],
  [uploadId]  
)

values (

  @request_public,
  @request_private,
  @request_id,
  @request_token,
  @request_ip,
  @request_user_agent,
  @request_datetime,
  @county_code,
  @district_code,
  @last_name,
  @first_name,
  @work_email,
  @file_class,
  @file_type,
  @ref_date,
  @uploaded_as,
  @saved_as,
  @saved_in,
  @uploaded_from,
  @uploadId
)

/*============================================================
 * Set file upload status to indicate form is complete
 *============================================================*/  	

declare @statusID   as bigint = null
declare @statusCode as bigint = dbo.CONST_FILE_UPLOAD_STATUS_FORM_COMPLETE()

exec dbo.FILE_UPLOAD_SET_STATUS 
   @uploadID
  ,@request_datetime
  ,@userIDRef
  ,@statusCode
  ,null
  ,null
  ,null
  ,@statusID output
  


/*###########################################################################
  # Done
  ###########################################################################*/       

return (0)  
end
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
                         
GRANT EXECUTE ON  [dbo].[FILE_UPLOAD_REQUEST_SAVE] TO [webuser]

GO