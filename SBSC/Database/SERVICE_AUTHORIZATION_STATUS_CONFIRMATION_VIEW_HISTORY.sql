USE SPEDMON
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY] (
    @userID                            BIGINT
  , @userGroup                         INT  
  , @userRank                          INT  
  , @clientID                          BIGINT
  , @orpDocumentID                     BIGINT
)    


RETURNS TABLE
 
 /***************************************************************************    
  * SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY */    
 /**    
  * 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(  
	select top (dbo.CONST_MAX_ROWS())
		 [name]            = enteredByUserName
	   , [effectivePeriod] = iif (t1.responseCode = 100, t1.effectiveDateStr + ' - ' + t1.expirationDateStr, t1.effectiveDateStr)
	   , [action]          = iif ((t1.responseCode = 200) /* Pending */
	                             , iif ((t1.entrySourceCode = 15), 'Pending E-Authorization' ,'Not Yet Signed/Pending Signature' )
								 , t1.responseShortName)
	   , t1.orpPracName                                 
	   , t1.orpPracTitle
	 from dbo.SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_CORE (@userID, @userGroup, @userRank, @clientID, @orpDocumentID, null, null, null) as t1 
	 order by 
			t1.id            desc
		  , t1.effectiveDate desc
		  , t1.enteredOn     desc
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[SERVICE_AUTHORIZATION_STATUS_CONFIRMATION_VIEW_HISTORY] TO [webuser]
GO  