USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_VIEW] (
    @userID                bigint
  , @userGroup             bigint    
  , @userRank              int     
  , @clientID              bigint
  , @groupSvcClassNameID   bigint
  , @active                bit
  , @recID                 bigint    
)
    
returns table     
as
 
return 
(    

select top (dbo.CONST_MAX_ROWS()) 
    spr.id
  , spr.clientID
  , groupSvcClassName   = scn.GROUP_SERVICE_CLASS_NAME
  , groupSvcClassNameID = scn.GROUP_SERVICE_CLASS_NAME_ID
  , spr.departmentHeadsCanViewSupervisedPracsPrivateNotes
  , spr.departmentHeadsCanViewSupervisedPracsStoredFiles
  , spr.departmentHeadsCanViewSupervisedPracsSvcRecs
  , spr.onlyDepartmentHeadsCanManageDirectSupervisionAssignments
  , spr.departmentHeadsCanOnlyViewSupervisedPracsDataInTheirReportingGroup
  , spr.departmentHeadsCanOnlyManageDirectSupervisionAssignmentsInTheirReportingGroup
  , spr.supervisingAndSupervisedPracsMustBeInSameReportingGroup
  , spr.departmentHeadsCanViewAllPracDataInTheirReportingGroup
  , spr.active

from dbo.CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES as spr
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                         as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = spr.groupServiceClassNameID
where (
      (spr.clientID = @clientID)
  and ((@groupSvcClassNameID is null) or (spr.groupServiceClassNameID = @groupSvcClassNameID))
  and (spr.active = 1)
)
order by 
  scn.GROUP_SERVICE_CLASS_NAME asc
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_GROUP_SERVICE_CLASS_NAME_SPECIFIC_PRACTICE_RULES_VIEW] TO [webuser]
GO