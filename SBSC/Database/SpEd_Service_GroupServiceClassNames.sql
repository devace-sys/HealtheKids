USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[SpEd_Service_GroupServiceClassNames]'))
DROP VIEW [dbo].[SpEd_Service_GroupServiceClassNames]
GO

CREATE VIEW [dbo].[SpEd_Service_GroupServiceClassNames] 
AS 
(

/***************************************************************************    
 * SpEd_Service_GroupServiceClassNames */    
/**    
 * 
 * @return table
 ***************************************************************************/     

select distinct top (10000) 
    spEdSvcCodeValue    = ss.codeValue
  , groupSvcClassNameID = png.GROUP_SERVICE_CLASS_NAME_ID
  , groupSvcClassName   = scn.GROUP_SERVICE_CLASS_NAME
from dbo.SpEd_Service                                      as ss
join dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA             as snx on snx.spEdSvcCodeValue = ss.codeValue
join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on ((png.GROUP_SERVICE_CLASS_PARTITION_ID = 100) and (png.GROUP_ID = snx.groupID))
join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as scn on scn.GROUP_SERVICE_CLASS_NAME_ID = png.GROUP_SERVICE_CLASS_NAME_ID
where (
      (ss.active = 1)
  and (snx.spEdSvcCodeValue != -1)
  and (snx.isStandard = 1)
  and (snx.active     = 1)
  and (snx.id is not null)
) /* Uses index */
order by 
    ss.codeValue
  , png.GROUP_SERVICE_CLASS_NAME_ID
)

GO


