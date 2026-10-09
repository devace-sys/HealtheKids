USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW] (
    @userID                            BIGINT 
  , @userGroup                         INT  
  , @userRank                          INT 
  , @systemWillGenerateFileUpload      BIT 
  , @fileUploadPending                 BIT 
  , @requestID                         BIGINT 
  , @uploadID                          bigint      
  , @active                            BIT 
  , @recID                             BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW */    
 /**    
  * 
  * 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select top (dbo.CONST_MAX_ROWS())
      sarpr.id
	, sar.clientID
    , sar.pracID  
    , sar.orpPracID
    , sar.patID
    , sar.groupSvcClassNameID
    , sar.fileClass
	, sar.fileNameSpace
	, sar.fileSource
    , sarpr.requestID
    , sarpr.uploadID
    , sarpr.created
    , sarpr.createdBy
    , sarpr.lastModified
    , sarpr.lastModifiedBy
	, sar.referencedEntityID

  from dbo.SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS as sarpr
  join dbo.SERVICE_AUTHORIZATION_REQUESTS                   as sar on sar.id = sarpr.requestID
  where (  
        (1=1)
    and ((@systemWillGenerateFileUpload is null) or (sarpr.systemWillGenerateFileUpload = @systemWillGenerateFileUpload))
    and ((@fileUploadPending            is null) or (sarpr.fileUploadPending            = @fileUploadPending))
	and ((@active is null)                       or (sarpr.active                       = @active))
  )

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_AUTHORIZATION_REQUESTS_PERMANENT_RECORDS_VIEW] TO [webuser]
GO  
