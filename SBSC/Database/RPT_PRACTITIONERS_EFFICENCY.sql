USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PRACTITIONERS_EFFICENCY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PRACTITIONERS_EFFICENCY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
 /***************************************************************************    
  * RPT_PRACTITIONERS_EFFICENCY */    
 /**    
  ***************************************************************************/     

CREATE FUNCTION [dbo].[RPT_PRACTITIONERS_EFFICENCY]  (
    @userID                BIGINT
  , @userGroup             INT
  , @userRank              INT
  , @clientID              bigint
  , @rptGroupID			   bigint
  , @groupSvcClassNameID   bigint 
  , @pracID                bigint
  , @startDate             datetime
  , @endDate               datetime
)    
returns 
table
as
return 
(

select top (dbo.CONST_MAX_ROWS()) 
  t1.* 
from dbo.RPT_PRACTITIONERS_EFFICENCY_CORE ( 
    @userID 
  , @userGroup
  , @userRank
  , @clientID
  , @rptGroupID
  , @groupSvcClassNameID
  , @pracID    
  , @startDate
  , @endDate  
) as t1
order by  
   t1.reportingGroup
  ,t1.pracName
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].RPT_PRACTITIONERS_EFFICENCY TO [webuser]
GO

  