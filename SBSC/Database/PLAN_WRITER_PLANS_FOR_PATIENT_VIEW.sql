USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_FOR_PATIENT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_FOR_PATIENT_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_FOR_PATIENT_VIEW] (
 @userID              BIGINT,    
 @userGroup           INT,    
 @userRank            INT,
 @clientID            BIGINT, 
 @patientID           BIGINT,
 @pracID			  BIGINT,
 @siteID			  BIGINT,
 @fiscalYearID        BIGINT,
 @isCreatedByCaller   BIT,
 @isExpiring          BIT,
 @isExpired           BIT,
 @term                varchar(256),
 @active              BIT,
 @recID               INT)    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_FOR_PATIENT_VIEW */    
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
	*
from dbo.PLAN_WRITER_PLANS_FOR_PATIENT_VIEW_CORE (@userID,
												  @userGroup,
												  @userRank,
												  @clientID,
												  @patientID,
												  @pracID,
												  @siteID,
												  @fiscalYearID,
												  @isCreatedByCaller,
												  @isExpiring,
												  @isExpired,
												  @active,
												  @recID)
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_FOR_PATIENT_VIEW] TO [webuser]
GO