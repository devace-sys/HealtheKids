USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_VIEW] (
 @userID              BIGINT,    
 @userGroup           INT,    
 @userRank            INT,
 @clientID            BIGINT, 
 @patientID           BIGINT,
 @groupSvcClassNameID bigint,
 @term                varchar(256),
 @active              BIT,
 @recID               INT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_VIEW */    
 /**    
  * Returns a table of entities
  *    
  * @param   userID         The userid of who is requesting the operation
  * @param   userGroup      Users group    
  * @param   userRank       User rank      
  * @param   active         Active 0 = No 1 = Yes
  * @param   recID          Entity record id
  * @return                 Table of patient data    
  ***************************************************************************/     
 
AS RETURN
(
 
select 
   id					   = pwp.id
 , name                    = pwp.PLAN_NAME
 , planDateVal             = pwp.PLAN_DATE
 , planDateStr             = pwp.PLAN_DATE_STR
 , planTypeID              = pwp.PLAN_TYPE_ID
 , patientID               = pwp.PATIENT_ID
 , patientName             = pwp.PATIENT_NAME
 , clientID                = pwp.CLIENT_ID
 , clientName              = pwp.CLIENT_NAME 
 , groupServiceClassNameID = pwp.GROUP_SERVICE_CLASS_NAME_ID
 , patientDOBVal           = pwp.PATIENT_DOB_VAL
 , patientDOBStr           = pwp.PATIENT_DOB_STR 
 , patientGrade            = pwp.PATIENT_GRADE
 , patientStudentID        = pwp.PATIENT_STUDENT_ID
 , patientSiteName         = pwp.PATIENT_SITE_NAME
 , active                  = pwp.ACTIVE
 , planCreatorUserID       = isnull(pwp.CREATED_BY, '')
 , planCreatorSigned       = isnull(pwp.planCreatorSigned, 0)
 , planCreatorSignedDate   = FORMAT (pwp.planCreatorSignedDate, 'MM/dd/yyyy ')
 , planCreatorSignedName   = ua.firstName + ' ' + ua.lastName
 , pwp.planCreatorSignatureImg

from dbo.PLAN_WRITER_PLANS_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @patientID, @groupSvcClassNameID, @active, @recID) as pwp
left join users.dbo.USERS_ALL as ua on ua.id = pwp.CREATED_BY

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_VIEW] TO [webuser]
GO