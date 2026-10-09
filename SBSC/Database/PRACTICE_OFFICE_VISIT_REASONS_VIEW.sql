USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTICE_OFFICE_VISIT_REASONS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTICE_OFFICE_VISIT_REASONS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTICE_OFFICE_VISIT_REASONS_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT
  , @groupSvcClassNameID   BIGINT
  , @term				   VARCHAR(256)
  , @recID                 bigint    
  , @canEdit               bit
  , @active                BIT
)
    
returns table     
as
 
return 
(    
  select top (dbo.CONST_MAX_ROWS())
    povr.id 
  , povr.[name] 
  , povr.groupSvcClassNameID
  , povr.hasFormData
  , povr.formDataJSON
  , povr.practiceOfficeVisitResolutionID
  , povrs2.[name] as practiceOfficeVisitResolutionName
  , povr.hideVisitSection
  , povr.created
  , povr.createdBy
  , povr.lastModified
  , povr.lastModifiedBy
  , povr.active
  
from dbo.PRACTICE_OFFICE_VISIT_REASONS as povr

/* Resolution */

outer apply (
  select top 1 
     povrs1.[name]
  from dbo.PRACTICE_OFFICE_VISIT_RESOLUTIONS as povrs1
  where 
    (povrs1.id = povr.practiceOfficeVisitResolutionID)
) as povrs2

where (   
      (1=1)
  and (povr.groupSvcClassNameID = @groupSvcClassNameID)
  and ((@recID         is null) or (povr.id            = @recID))
  and ((@term          is null) or (povr.[name] like '%' + @term + '%'))
  and (povr.active = 1)
)
order by 
  povr.[name]
 
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTICE_OFFICE_VISIT_REASONS_VIEW] TO [webuser]
GO