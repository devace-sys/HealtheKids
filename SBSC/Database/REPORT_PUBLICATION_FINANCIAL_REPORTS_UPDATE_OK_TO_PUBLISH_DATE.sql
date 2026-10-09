USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_FINANCIAL_REPORTS_UPDATE_OK_TO_PUBLISH_DATE') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.REPORT_PUBLICATION_FINANCIAL_REPORTS_UPDATE_OK_TO_PUBLISH_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[REPORT_PUBLICATION_FINANCIAL_REPORTS_UPDATE_OK_TO_PUBLISH_DATE]     
(
@OKToPublishUpToDate VARCHAR(1000)
)    
AS    

BEGIN     
    
/***************************************************************************    
 * REPORT_PUBLICATION_FINANCIAL_REPORTS_UPDATE_OK_TO_PUBLISH_DATE          */    
/**    
 * Calls REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE for all report
 * classes that contain financial data.
 *
 * Note: There is only one class right now, but there may be others in
 *       the future.  TODO: Update this when new classes are added.
 ***************************************************************************/         
     
SET NOCOUNT ON    


exec REPORT_PUBLICATION_CLASS_OK_TO_PUBLISH_DATE_UPDATE 1, @OKToPublishUpToDate

END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[REPORT_PUBLICATION_FINANCIAL_REPORTS_UPDATE_OK_TO_PUBLISH_DATE] TO [webuser]
GO
