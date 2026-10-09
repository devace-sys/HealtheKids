USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @rcrSvcID       BIGINT,
 @transFrom      INT,
 @transTo        INT
)    
RETURNS TABLE

 /***************************************************************************    
  * RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED */    
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
    transFrom, 
    transTo, 
    inIEP, 
    isMedNesc, 
    numMilesDaily, 
    numMilesMon,
    numMilesTue,
    numMilesWed,
    numMilesThu,
    numMilesFri
  from RECURRING_SERVICES_DETAILS_SVC_MILE_BASED   as rs
  join PRACTITIONER_PRACTITIONER                   as pp  on pp.PRACTITIONER_ID = rs.pracID
  join PRACTITIONER_GROUPS_VIEW_DISP()             as gd  on gd.PRACTITIONER_ID = pp.PRACTITIONER_ID
  where 
        rcrSvcID  = @rcrSvcID
    and transFrom = @transFrom
    and transTo   = @transTo
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED] TO [webuser]
GO   
