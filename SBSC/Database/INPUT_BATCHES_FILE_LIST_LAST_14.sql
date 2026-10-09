USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_FILE_LIST_LAST_14') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_FILE_LIST_LAST_14
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_BATCHES_FILE_LIST_LAST_14]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * INPUT_BATCHES_FILE_LIST_LAST_14 */    
 /**    
  * Shows list of input batch files received in the last 14 days
  *    
  * @return                Table 
  ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/

select top (dbo.CONST_MAX_ROWS()) [FileName] from dbo.INPUT_BATCHES_FILE_LIST_CORE(@userID, 
                                               @userGroup, 
                                               @userRank, 
                                               DATEADD(DAY,-14,DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE()))), 
                                               GETDATE())
order by [FileName] desc
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_FILE_LIST_LAST_14] TO [webuser]
GO   
