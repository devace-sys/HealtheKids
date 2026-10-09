USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.BUILD_FULL_SERVICE_NAME_STRING') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.BUILD_FULL_SERVICE_NAME_STRING
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[BUILD_FULL_SERVICE_NAME_STRING]
(
    @svcNameListDataSourceID     smallint

  , @planServiceNameStandard     nvarchar(100)
  , @noPlanServiceNameStandard   nvarchar(100)
  , @cybhiServiceNameStandard    nvarchar(100)
  , @ruHealthServiceNameStandard nvarchar(100)

  , @planServiceNameAlias       nvarchar(100)
  , @noPlanServiceNameAlias     nvarchar(100)
  , @cybhiServiceNameAlias      nvarchar(100)
  , @ruHealthServiceNameAlias   nvarchar(100)

  , @serviceTypeID              int
  , @groupBase                  varchar(50)
  , @hasSvcDetailFlags          bit
  , @svcDetFlag1                bit
  , @svcDetFlag2                bit
  , @svcDetFlag3                bit
  , @svcDetFlag4                bit
) 
RETURNS varchar(1000)
AS     
BEGIN    
 
     declare @serviceName     as nvarchar(100)
     declare @serviceDetails  as nvarchar(100)
     declare @fullServiceName as varchar (200)
      
	 set @serviceName = dbo.BUILD_SERVICE_NAME_STRING (  @svcNameListDataSourceID
													   , @planServiceNameStandard   
                                                       , @noPlanServiceNameStandard 
													   , @cybhiServiceNameStandard
                                                       , @ruHealthServiceNameStandard
													   , @planServiceNameAlias      
                                                       , @noPlanServiceNameAlias 
													   , @cybhiServiceNameAlias
													   , @ruHealthServiceNameAlias )
        
     set @serviceDetails = dbo.BUILD_SERVICE_DETAILS_STRING (  @serviceTypeID    
                                                             , @groupBase           
                                                             , @hasSvcDetailFlags
                                                             , @svcDetFlag1
                                                             , @svcDetFlag2
                                                             , @svcDetFlag3
                                                             , @svcDetFlag4 )
  
     set @fullServiceName = @serviceName + @serviceDetails
     
     return @fullServiceName

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[BUILD_FULL_SERVICE_NAME_STRING] TO [webuser]
GO