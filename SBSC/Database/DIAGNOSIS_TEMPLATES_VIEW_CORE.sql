USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.DIAGNOSIS_TEMPLATES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.DIAGNOSIS_TEMPLATES_VIEW_CORE
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[DIAGNOSIS_TEMPLATES_VIEW_CORE] (
 @userID                  BIGINT,    
 @userGroup               INT,    
 @userRank                INT,
 @clientID                BIGINT, 
 @groupServiceClassNameID BIGINT,
 @templateType            BIGINT,
 @term                    VARCHAR(256),
 @active                  BIT,
 @recID                   INT )    
 
RETURNS TABLE
 
 /***************************************************************************    
  * DIAGNOSIS_TEMPLATES_VIEW_CORE */    
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

select * from ( 

	select * from [dbo].[DiagnosisTemplates]
		where typeOfTemplateID = 1 and clientID is null     
														    
	union all											    
														    
	select * from dbo.DiagnosisTemplates				    
		where typeOfTemplateID = 2 and clientID = @clientID 
														    
	union all											    
														    
	select * from dbo.DiagnosisTemplates				    
		where typeOfTemplateID = 3 and clientID = @clientID and ownerUserID = @userID
) as dt
where (
       (1=1)   
   and (typeOfTemplateID = @templateType)
   and ((@active    is null)  or (dt.ACTIVE  = @active))
   and ((@recID     is null)  or (dt.ID      = @recID))
)

)
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[DIAGNOSIS_TEMPLATES_VIEW_CORE] TO [webuser]
GO