USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT     
  , @clientID              bigint
  , @pracID                bigint  
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    
  
  select     
	  per.*  
    , employeeRelationshipName = er.TYPE_NAME
    , startDateStr             = dbo.RPT_DATE_FMT(per.startDate)
	, endDateStr               = dbo.RPT_DATE_FMT(per.endDate)
	, startDateYYYYMMDDStr     = dbo.RPT_DATE_FMT_YYYY_MM_DD(per.startDate)
	, endDateYYYYMMDDStr       = dbo.RPT_DATE_FMT_YYYY_MM_DD(per.endDate)

  from dbo.PRACTITIONER_EMPLOYMENT_RELATIONSHIPS as per
  join dbo.EMPLOYMENT_RELATIONSHIPS              as er on er.TYPE_ID = per.employeeRelationshipID
  
  where (   
        (1=1)
    and (per.clientID = @clientID)
    and (per.pracID   = @pracID)
    and ((@recID  is null) or (per.id     = @recID))
    and ((@active is null) or (per.active = @active))
  )
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_EMPLOYMENT_RELATIONSHIPS_VIEW] TO [webuser]
GO