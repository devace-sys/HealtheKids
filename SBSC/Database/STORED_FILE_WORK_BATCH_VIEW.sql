
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_WORK_BATCH_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STORED_FILE_WORK_BATCH_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STORED_FILE_WORK_BATCH_VIEW] (
    @userID        BIGINT
  , @userGroup     INT
  , @userRank      INT    
  , @fileReference VARCHAR(500)
) 

RETURNS TABLE    

 /***************************************************************************    
  * STORED_FILE_WORK_BATCH_VIEW */    
 /**    
  * Returns work batch file target data for given fileReference
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank    
  * @return                 Table of target data    
  ***************************************************************************/     
  
AS RETURN (   

select top 1 
  
  [id]       = ibsr.inputBatchID
, [fileId]   = ibsr.reference
, [label]    = ibsr.reference
, [fileRoot] = 'C:\spedmon\data\files\network-symb-links\'
, [filePath] = ib.File_Location
, [fileName] = ib.File_Name

from dbo.INPUT_BATCHES_SERVICE_RECORDS as ibsr
join dbo.INPUT_BATCHES                 as ib   on ib.id = ibsr.inputBatchID

where 
  (ibsr.reference = @fileReference) 
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[STORED_FILE_WORK_BATCH_VIEW] TO [webuser]
GO