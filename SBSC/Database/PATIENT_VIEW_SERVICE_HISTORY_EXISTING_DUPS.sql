USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_SERVICE_HISTORY_EXISTING_DUPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_SERVICE_HISTORY_EXISTING_DUPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_SERVICE_HISTORY_EXISTING_DUPS]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,     
 @clientID       INT,
 @patID          INT,
 @nameID         INT,
 @excludeRecID   BIGINT,
 @referenceLinkURL varchar(1000)
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VIEW_SERVICE_EXISTING_DUPS */    
 /**    
  * Returns last 13 months of existing duplicate records 
  * for a given patient and service
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @param  nameID        Service
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(
  select     
 
    [Record],
    [Reference] = [ReferenceURL]

 
  from dbo.PATIENT_VIEW_SERVICE_HISTORY_13M(@userID, 
                                        @userGroup, 
                                        @userRank, 
                                        @clientID, 
                                        @patID, 
                                        @nameID,
                                        @excludeRecID,
                                        @referenceLinkURL)
  where [DupCnt] > 0


)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_SERVICE_HISTORY_EXISTING_DUPS] TO [webuser]
GO   
