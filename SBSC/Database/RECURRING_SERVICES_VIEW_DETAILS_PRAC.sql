USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_VIEW_DETAILS_PRAC]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @rcrSvcID       BIGINT
)    
RETURNS TABLE

 /***************************************************************************    
  * RECURRING_SERVICES_VIEW_DETAILS_PRAC */    
 /**    
  * Returns list of recurring services records
  *
  * @return table 
  ***************************************************************************/                         

AS RETURN
(
 
  select
    ROW_NUMBER() OVER (ORDER BY id) as RowOrder,
    id, 
    pracID, 
    pp.CONCAT_NAME as [pracName], 
    gd.groupName   as [pracTitle],
    gd.GROUP_ID    as [pracDispGrpID], 
    tmtBS, 
    tmtDSInd, 
    tmtDSGrp, 
    tmtAS,
    transHmSs, 
    transSsHm, 
    transSsOs, 
    transOsSs,
    realNames   
  from RECURRING_SERVICES_DETAILS_PRAC as rs
  join PRACTITIONER_PRACTITIONER       as pp  on pp.PRACTITIONER_ID = rs.pracID
  join PRACTITIONER_GROUPS_VIEW_DISP() as gd  on gd.PRACTITIONER_ID = pp.PRACTITIONER_ID
  where 
    rcrSvcID = @rcrSvcID
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_VIEW_DETAILS_PRAC] TO [webuser]
GO   
