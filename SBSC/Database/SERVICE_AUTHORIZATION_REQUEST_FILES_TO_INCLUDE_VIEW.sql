USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @clientID                          bigint
  , @requestID                         bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW */    
 /**    
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

with
cte_p1
as
(
select top 1 
   t1.requestID
from dbo.SERVICE_AUTHORIZATION_REQUEST_AUTHORIZED_USERS as t1
where (
      (t1.requestID = @requestID)
  and (t1.userID    = @userID)
)
union
select top 1
  requestID = @requestID
from dbo.SERVICE_AUTHORIZATION_REQUESTS_IMPLIED_USERS_DATA_CORE (@userID, @clientID) as t2
)
,
cte_p2
as
(
select 
  fti.* 
from cte_p1 as p1
join dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE as fti on fti.requestID = p1.requestID
)
select 
    p2.id
  , [name]          = fu.originalName
  , [description]  = isnull(fu.description,'') 
  , uploadID        = fu.id
from cte_p2           as p2
join dbo.FILE_UPLOADS as fu on fu.id = p2.uploadID
join dbo.FILE_CLASSES as fc on fc.id = fu.fileClass

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  dbo.SERVICE_AUTHORIZATION_REQUEST_FILES_TO_INCLUDE_VIEW TO [webuser]
GO  
