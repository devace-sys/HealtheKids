USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_VIEW_EDITABLE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_VIEW_EDITABLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
   
CREATE FUNCTION [dbo].[SERVICE_RECORDS_VIEW_EDITABLE]    
   
(@clientID       AS   int,    
 @userID         AS   bigint,    
 @userGroup      AS   int,    
 @userRank       AS   int,
 @applyViewRules AS   bit    
 )    
   
returns TABLE    
AS    
   
/***************************************************************************    
 * SERVICE_RECORDS_VIEW_EDITABLE */    
/**    
 * Internal helper query for SERVICE_RECORDS_VIEW    
 * Indicates what service records are editable by userID
 *    
 * @param  clientID        Client ID (required)    
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records that can be edited    
 ***************************************************************************/    
   
RETURN (    
   
WITH

/*###########################################################################
  # Apply basic criterea for service records that can be edited
  ###########################################################################*/

cte_base
AS
(

SELECT
   sr.id
  ,sr.created
  ,sjsr.journalID
from      dbo.SERVICE_RECORDS                              as sr
left join Users.dbo.USERS_DATA_CORE ('spedcare',null,null,null,null) as uv on uv.id      = sr.userID

LEFT JOIN dbo.SvcJournal_Service_Records        AS sjsr ON sjsr.svcRecID = sr.id
WHERE  
       (1=1)
  AND ((@clientID IS NULL) OR (sr.clientID = @clientID))
 
  /*============================================================
   * Exclude service records that came from service journal
   *============================================================*/  
 
  AND ((@applyViewRules = 0) OR ((@applyViewRules = 1) AND (sjsr.journalID IS NULL)))
 
 /*============================================================
  * Only service records that have not been sent to claims
  * processing can be edited
  *============================================================*/  
 
  AND (dbo.SERVICE_STATE_TO_CAN_STILL_EDIT_FLAG(sr.state) = 1)
   
 /*============================================================
  * In general users can only edit records that they have
  * entered
  *============================================================*/  
   
  AND   ((sr.userID  = @userID)    
   
 /*============================================================
  * If the user happens to be a work leader they can edit
  * other SBSC staff entered work
  *============================================================*/  

  OR     ((@userGroup = dbo.CONST_USER_GROUP_SBS())    
  AND    (@userRank  >= 2)
  AND    (uv.userGroupID = dbo.CONST_USER_GROUP_SBS()))    
     
  )    
)  
,

/*###########################################################################
  # Look for service records that are in our basic critera set that also
  # are being held for supervisor approval.
  ###########################################################################*/

cte_sr_held_for_approval
AS
(
SELECT
  sra.svcRecID AS id
FROM dbo.SERVICE_RECORDS_APPROVAL AS sra
JOIN cte_base                     AS sr ON sr.id = sra.id
WHERE

  /*============================================================
   * Active approval record
   *============================================================*/  
 
  ((sra.active = 1)

  /*============================================================
   * And the record has been denied OR has not been approved yet
   *============================================================*/  
 
  AND ((sra.approved IS NULL) OR (sra.approved = 0))

  /*============================================================
   * And filter out client
   *============================================================*/  

  AND ((@clientID IS NULL) OR (sra.clientID = @clientID)))  
)
,

/*###########################################################################
  # Look for service records that are in our basic critera set that are not
  # being held for supervisor approval
  ###########################################################################*/

cte_sr_not_held_for_approval
AS
(
SELECT
  sr.id
FROM cte_base                      AS sr
LEFT JOIN cte_sr_held_for_approval AS sra ON sra.id = sr.id
WHERE
 
  /*============================================================
   * Service record is not in the waiting for approval list
   *============================================================*/  
 
  (sra.id IS NULL)

  /*============================================================
   * Only service records that are <= 7 days
   * (or whatever age cutoff is) can be edited
   *============================================================*/  
 
  --and ((@applyViewRules = 0) or (((@applyViewRules = 1) and (DATEDIFF (DAY, sr.created, getdate()) <= dbo.CONST_SVC_REC_AGE_CUTOFF()))))
)
,

/*###########################################################################
  # Combine services waiting for approval with services not waiting for
  # approval
  ###########################################################################*/

cte_combo
AS
(
SELECT * FROM cte_sr_held_for_approval
UNION
SELECT * FROM cte_sr_not_held_for_approval
)
,

/*###########################################################################
  # Output
  ###########################################################################*/

cte_output
AS
(
SELECT DISTINCT * FROM cte_combo
)

SELECT * FROM cte_output

)
GO