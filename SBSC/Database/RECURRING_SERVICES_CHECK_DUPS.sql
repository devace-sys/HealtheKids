USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_CHECK_DUPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_CHECK_DUPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_CHECK_DUPS]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,     
 @clientID       INT,
 @patID          INT,
 @fiscalYearID   INT,
 @startDate      DATETIME,
 @endDate        DATETIME,
 @recID          BIGINT)    

RETURNS TABLE
 
 /***************************************************************************    
  * RECURRING_SERVICES_CHECK_DUPS */    
 /**    
  * Checks dups
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(

  select 
  *
  from 
  RECURRING_SERVICES 
  where
    ((@recID IS NULL) OR (ID != @recID)) 
    and (Active       =  1)
    and (clientID     =  @clientID)
    and (patID        =  @patID)
    and (fiscalYearID =  @fiscalYearID)
    and (@startDate   <= endDate) 
    and (@endDate     >= startDate)
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_CHECK_DUPS] TO [webuser]
GO   
