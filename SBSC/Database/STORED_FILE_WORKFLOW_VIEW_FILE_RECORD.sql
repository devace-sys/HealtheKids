
USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STORED_FILE_WORKFLOW_VIEW_FILE_RECORD') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STORED_FILE_WORKFLOW_VIEW_FILE_RECORD
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STORED_FILE_WORKFLOW_VIEW_FILE_RECORD] (
   @inputBatchID  bigint
 , @fileReference varchar(500)
) 

RETURNS TABLE    

 /***************************************************************************    
  * STORED_FILE_WORKFLOW_VIEW_FILE_RECORD */    
 /**    
  * Returns work batch file target data for given input batch id and/or 
  * fileReference
  *    
  * @return                 Table of target data    
  ***************************************************************************/     
  
AS RETURN (   

select top 1 
  
  [id]       = ib.id
, [fileId]   = ib.File_name
, [label]    = ib.File_name
, [fileRoot] = 'C:\spedmon\data\files\network-symb-links\'
, [filePath] = ib.File_Location
, [fileName] = ib.File_Name

from dbo.INPUT_BATCHES as ib

where (
       (ib.id        = @inputBatchID)
    or (ib.File_Name = @fileReference + '.pdf')
    or (ib.File_Name = @fileReference + '.xls')
  )
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[STORED_FILE_WORKFLOW_VIEW_FILE_RECORD] TO [webuser]
GO