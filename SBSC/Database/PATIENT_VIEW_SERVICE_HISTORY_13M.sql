USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_SERVICE_HISTORY_13M') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_SERVICE_HISTORY_13M
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_SERVICE_HISTORY_13M]    
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
  * PATIENT_VIEW_SERVICE_HISTORY_13M */    
 /**    
  * Returns last 13 months of history for a given patient and service
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @param  nameID        Service
  * @return               Table 
  ***************************************************************************/                         

     
AS RETURN
(
  select
    *, 
    '(' + [RowNum] + ') ' + [DOSFmt] + ' [' + [Procedure 1] + ']' + ' ' + LEFT([Practitioner],14) + ' ' as [Record]
    ,[ReferenceURL] = '<a class="stored-file-link" target="_blank" href="' + @referenceLinkURL + [Reference] +'">' + [Reference] + '</a>'
  from dbo.PATIENT_VIEW_SERVICE_HISTORY(@userID, 
                                        @userGroup, 
                                        @userRank, 
                                        @clientID, 
                                        @patID, 
                                        @nameID, 
                                        DATEADD(month,-13,(dbo.DATE_MONTH_START_END(GETDATE(),0))), 
                                        GETDATE())
where ((@excludeRecID is null) or (id != @excludeRecID))     
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_SERVICE_HISTORY_13M] TO [webuser]
GO   