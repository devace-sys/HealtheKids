USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.INPUT_BATCHES_FILE_LIST_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.INPUT_BATCHES_FILE_LIST_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[INPUT_BATCHES_FILE_LIST_CORE]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @startDate      DATETIME,
 @endDate        DATETIME
)    

RETURNS TABLE
 
 /***************************************************************************    
  * INPUT_BATCHES_FILE_LIST_CORE */    
 /**    
  * Shows list of input batch files received 
  *    
  * @param  startDate      Start date
  * @param  endDate        End date
  * @return                Table 
  ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/

select         ib.Date_Recieved       as [DateReceived],       ib.File_Name           as [Filename]from   Input_Batches_Activity as iba join   Input_Batches          as ib on ib.id = iba.Input_Batches_IDwhere (iba.FROM_STATUS = 10) and (Date_Recieved between @startDate and @endDate))

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[INPUT_BATCHES_FILE_LIST_CORE] TO [webuser]
GO   
