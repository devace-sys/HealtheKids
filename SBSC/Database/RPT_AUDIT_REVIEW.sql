 USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_AUDIT_REVIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_AUDIT_REVIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_AUDIT_REVIEW]()
returns  TABLE AS
RETURN


/***************************************************************************    
  * RPT_AUDIT_REVIEW */    
 /**    
  * Returns a table of AUDIT_REVIEW    
  *      
  * @return                 Table of AUDIT REVIEW data    
  * This function had to be modified when ever a worktype is added or deleted
  ***************************************************************************/     
 
select * from 
(select workcode,u.name, CONVERT(varchar(max),ar.AUDIT_DATE,101)+' - '+review_rate+'% '+isnull(ar.Note,'')  as rate 
  from (
    select id, firstname+' '+lastname as name from users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) 
          where userGroupID = dbo.CONST_USER_GROUP_SBS() and roleID in (3,4) and accountIsLockedOut = 0 
  ) u 
  join (select WORKTYPE_ID,STAFF_ID, MAX(AUDIT_DATE) as AUDIT_DATE from EMP_AUDIT_REVIEW group by WORKTYPE_ID,STAFF_ID) as ar_max on ar_max.STAFF_ID = u.id
  join EMP_AUDIT_REVIEW as ar on ar_max.STAFF_ID = ar.STAFF_ID and ar_max.WORKTYPE_ID = ar.WORKTYPE_ID and ar_max.AUDIT_DATE = ar.AUDIT_DATE
  join TYPE_OF_WORK as t on ar.WorkType_ID = t.id
  group by WorkCode,name,ar.AUDIT_DATE,REVIEW_RATE,note)as d     
  pivot(max(rate) for workcode in([1-1],CN,HA,HS,LVN,LMFT,NPS,RN,OT,PT,TCM,PSY,SW,SP,Trans,Qforms)) as p;

GO
/*-------------------------------
 * User Permissions
 *------------------------------*/
GRANT SELECT ON  [dbo].[RPT_AUDIT_REVIEW] TO [webuser]
GO