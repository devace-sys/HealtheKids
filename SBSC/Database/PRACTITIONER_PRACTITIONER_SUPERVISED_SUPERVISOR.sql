USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR]'))
DROP VIEW [dbo].[PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR] 
AS 
(

/***************************************************************************    
 * PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR */    
/**    
 * Replaces a former table of the same name
 *
 * @return table
 ***************************************************************************/     

select distinct
  ID = RANK() OVER (ORDER BY 
    ppdss.CLIENT_ID
  , ppdss.SUPERVISED_PRAC_ID
  , ppdss.SUPERVISING_PRAC_ID
  , ppdss.ACTIVE)  /* Simulate unique ID that might have been in original table.  Dates were not in original  */
, ppdss.CLIENT_ID
, ppdss.SUPERVISED_PRAC_ID
, ppdss.SUPERVISING_PRAC_ID
, ppdss.ACTIVE
from dbo.PRACTITIONER_PRACTITIONER_DIRECT_SUPERVISED_SUPERVISOR as ppdss
join dbo.PRACTITIONER_GROUPS                                    as pg    on pg.PRACTITIONER_ID = ppdss.SUPERVISED_PRAC_ID
join dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR               as ggdss on ggdss.SUPERVISED_GROUP_ID = pg.GROUP_ID
where ( 
    
    (ggdss.ACTIVE = 1)
and (ggdss.approveServiceRecords = 1)
and (ppdss.SHARE_NOTES = 0)
and (ppdss.relationshipTypeID = 10)
)


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PRACTITIONER_SUPERVISED_SUPERVISOR] TO [webuser]
GO
