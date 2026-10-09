USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core] (    
    @userID            BIGINT
  , @userGroup         INT
  , @userRank          INT
  , @clientID          bigint
  , @pracID            bigint
)

returns @svcCodes table (
      spEdSvcCode int
	, isPref      bit default(1)
  unique clustered (spEdSvcCode)
)     
as
begin

declare @today                 as date    = convert(date,getdate())
declare @groupID               as bigint  = 0
declare @groupSvcClassNameID   as bigint  = 0

/*############################################################################
 *# Get practitioners discipline group ID and group family
 *############################################################################*/

select top 1 
    @groupID             = pg.GROUP_ID 
  , @groupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
from dbo.PRACTITIONER_Practitioner                              as prp
join dbo.PRACTITIONER_Client                                    as prc on prc.PRACTITIONER_ID = prp.PRACTITIONER_ID
join dbo.PRACTITIONER_GROUPS                                    as pg  on pg.PRACTITIONER_ID = prp.PRACTITIONER_ID
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA as png on png.GROUP_ID = pg.GROUP_ID
where (
      (prp.PRACTITIONER_ID = @pracID) 
  and (prc.CLIENT_ID = @clientID)
  and (pg.GROUP_TYPE in (1,2))
  and (png.GROUP_SERVICE_CLASS_PARTITION_ID = 100)
)

/*############################################################################
 *# See if the practitioner has indicated preferences
 *############################################################################*/

insert into @svcCodes (spEdSvcCode, isPref)
select distinct 
      t1.spEdServiceCode
	, isPref = 1
FROM dbo.PRACTITIONER_PREFERENCE_SPED_SERVICES_VIEW (
    @userID          
  , @userGroup 
  , @userRank  
  , @clientID
  , @pracID
  , null
  , null
  , 1     -- @active         BIT
  , null  -- @recID          BIGINT
) as t1    

/*############################################################################
 *# If not get associated codes based on practice family
 *############################################################################*/

IF ( ( SELECT COUNT(*) FROM @svcCodes ) = 0 )
begin
  insert into @svcCodes (
      spEdSvcCode
    , isPref
  )
  select distinct 
    spEdSvcCode = xref.spEdServiceCodeValue
   , isPref     = 0
  from dbo.SpEd_Service_Xref_Group_Service_Class_Name                              as xref
  join dbo.SERVICES_VIEW_ALL_CORE (@clientID,@groupID,null,null,null,1,1,@today,1) as svac on svac.CALPADS_SPED_SVC_CODE_VALUE = xref.spEdServiceCodeValue
  where (
        (xref.groupServiceClassNameID     = @groupSvcClassNameID)
    and (xref.active                      = 1)
    and (xref.okToUseForCaseloadImport    = 1)
    and (svac.CALPADS_SPED_SVC_CODE_VALUE != -1)
  )
end

return

end

 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core] TO [webuser]
GO