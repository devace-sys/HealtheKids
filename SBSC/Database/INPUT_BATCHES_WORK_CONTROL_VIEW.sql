USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_WORK_CONTROL_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_WORK_CONTROL_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_BATCHES_WORK_CONTROL_VIEW]    
(
 @recID        BIGINT,     
 @clientID     BIGINT,
 @workType     smallint,
 @active       BIT,    
 @canEdit      BIT)    
 
  RETURNS TABLE  
 
 /***************************************************************************    
  * INPUT_BATCHES_WORK_CONTROL_VIEW */    
 /**    
  * Returns a table of INPUT_BATCHES_WORK_CONTROL that match the given parameters    
  *    
  * @param  clientID
  * @param  workType
  * @param  active          If client is active
  * @param  recID           Client record id    
  * @return                 Table of INPUT_BATCHES data    
  ***************************************************************************/    
 
AS
RETURN          
/*-------------------------------    
 * Retrieve records  
 *------------------------------*/  
( SELECT top (dbo.CONST_MAX_ROWS())          
          cc.CLIENT_NAME                AS Client,
          t.WorkType,          
          ib.Start_Date,
          ib.End_Date,
          ib.Note,
          ib.Date_Created,
          ib.WorkTypeID,
          ib.Client_ID,
          ib.id
   FROM INPUT_BATCHES_WORK_CONTROL      AS ib
   LEFT JOIN CLIENTS_client             AS cc  ON cc.Client_ID = ib.Client_ID   
   LEFT JOIN dbo.Type_of_work           AS t   ON t.id         = ib.WorkTypeID
   WHERE ((@clientID      IS NULL)  OR (ib.client_id           = @clientID))  
     AND ((@recID         IS NULL)  OR (ib.id                  = @recID))
     AND ((@active        IS NULL)  OR (ib.active              = @active))

)
         
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_WORK_CONTROL_VIEW] TO [webuser]
GO
 


