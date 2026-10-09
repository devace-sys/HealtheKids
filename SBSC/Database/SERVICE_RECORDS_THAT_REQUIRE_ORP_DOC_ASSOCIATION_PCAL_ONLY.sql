USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY] (
    @userID        as   bigint
  , @userGroup     as   int  
  , @userRank      as   int    
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY*/    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 ***************************************************************************/     
    
return (    

select top (dbo.CONST_MAX_ROWS())
  
    t1.[Reference]           as [Document Reference]
  , t1.[Client]
  , t1.[Patient]
  , dbo.RPT_DATE_FMT(t1.DOS) as [Date]
  , t1.Mins                  as [Mins]
  , t1.id                    as [Service Record]
  
from dbo.SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_CORE (@userID, @userGroup, @userRank, 1) as t1

order by 

    t1.Reference
  , t1.EnteredOn
  , t1.id

)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORDS_THAT_REQUIRE_ORP_DOC_ASSOCIATION_PCAL_ONLY] TO [webuser]
GO