USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_SHORT_SERVICE_HISTORY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_SHORT_SERVICE_HISTORY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_SHORT_SERVICE_HISTORY]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,     
 @clientID       INT,
 @patID          INT,
 @nameID         INT,
 @referenceLinkURL varchar(1000)
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VIEW_SHORT_SERVICE_HISTORY */    
 /**    
  * Returns last 13 months of history
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
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
                                            null,
                                            @referenceLinkURL)

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_SHORT_SERVICE_HISTORY] TO [webuser]
GO   
