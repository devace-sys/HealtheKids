USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW]    
(@userID         INT,    
 @userGroup      INT,    
 @userRank       INT,
 @clientID       BIGINT,
 @pracID         BIGINT,
 @pratPatGroupID BIGINT,
 @term           VARCHAR(500),
 @iep            BIT,
 @nameID         BIGINT,
 @refDate        DATE,
 @recID          INT)    

RETURNS TABLE

 /***************************************************************************    
  * PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client. 
  * @param  pracID          Required.  ID of practitioner.    
  * @param  patID           Required.  ID of patient.
  * @param  startDate       Start of month.
  * @param  endDate         End of month
  * @return                 Table of expected service data   
  ***************************************************************************/     
  
AS RETURN
(


select 
  * 
from dbo.PRACTITIONER_CASELOAD_OR_PATIENT_GROUP_MEMBERS_VIEW_CORE (
   @userID                 
 , @userGroup              
 , @userRank               
 , @clientID               
 , @pracID                 
 , 2
 , @pratPatGroupID         
 , null
 , @iep                    
 , @nameID                 
 , @refDate                
 , @recID                 
 )

)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_GROUP_MEMBERS_VIEW] TO [webuser]
GO
