USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW_CORE] (
  @userID              BIGINT,    
  @userGroup           INT,    
  @userRank            INT,
  @clientID            BIGINT,  
  @planID              bigint,  
  @active              BIT,
  @recID               INT )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW_CORE */    
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
   ppvc.*
 , action = pwppp.action
 , signed        = convert(bit, isnull(pwps.signed, 0))
 , signedDateStr = FORMAT (pwps.signedDateStr, 'MM/dd/yyyy') 
 , planID    = pwpvc.ID

         
from      dbo.PLAN_WRITER_PLANS_VIEW_CORE ( @userID
                                          , @userGroup
                                          , @userRank
                                          , @clientID
                                          , null
                                          , null
                                          , null
                                          , @planID ) as pwpvc

join      dbo.PATIENT_PERSONS_VIEW_CORE  (  @userID
                                          , @userGroup
                                          , @userRank
                                          , @clientID
                                          , null
                                          , null
                                          , null
                                          , null
                                          , @recID
										  , null)   as ppvc on ppvc.clientID = pwpvc.CLIENT_ID and ppvc.patientID = pwpvc.PATIENT_ID

join dbo.PLAN_WRITER_PLANS_PATIENT_PERSONS as pwppp on  pwppp.PLAN_ID           = pwpvc.ID
                                                    and pwppp.PATIENT_PERSON_ID = ppvc.ID
outer apply dbo.PLAN_WRITER_PLANS_SIGNATURES_VIEW(@userID, @userGroup, @userRank, @clientID, ppvc.userIDInt, @planID) as pwps  
                                     
)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PLAN_WRITER_PLANS_PATIENT_PERSONS_NO_EXCLUDE_VIEW_CORE] TO [webuser]
GO