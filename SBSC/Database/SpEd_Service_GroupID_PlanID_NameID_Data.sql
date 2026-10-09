USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SpEd_Service_GroupID_PlanID_NameID_Data]'))
DROP VIEW [dbo].[SpEd_Service_GroupID_PlanID_NameID_Data]
GO

CREATE VIEW [dbo].[SpEd_Service_GroupID_PlanID_NameID_Data] 
AS 

/***************************************************************************    
 * SpEd_Service_GroupID_PlanID_NameID_Data */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select distinct
    snx.spEdSvcCodeValue
  , snx.groupID
  , snx.planTypeID
  , snx.nameID
  , groupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
  , rate = case 
      when (snx.svcTypeId = 1) then isnull(pr.RATE_ASSMT,0)
      when (snx.svcTypeId = 2) then isnull(pr.RATE_TMT  ,0)
	  when (snx.svcTypeId = 4) then isnull(pr.RATE_TCM,0)
	  else 0 end    
  , unitPerMinFactor = case 
      when (snx.svcTypeId = 1) then 1
      when (snx.svcTypeId = 2) then isnull(pr.UNIT_PER_MIN_FACTOR_TMT,1)
	  when (snx.svcTypeId = 4) then 15
	  else 1 end    
from      dbo.SpEd_Service                                      as ss
join      dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA             as snx on snx.spEdSvcCodeValue = ss.codeValue
join      dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100) and (png.GROUP_ID = snx.groupID))
left join dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES         as pr  on pr.GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID
where (
      (ss.active = 1)
  and (snx.spEdSvcCodeValue != -1)
  and (snx.isStandard = 1)
  and (snx.active     = 1)
  and (snx.id is not null)
)

GO


