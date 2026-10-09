USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUBLICATION_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/


/* TODO: none of these params are even used for anything */
 
CREATE FUNCTION [dbo].[REPORT_PUBLICATION_VIEW]    
(@userID           BIGINT,    
 @userGroup        INT,    
 @userRank         INT,
 @includeSensitive BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * REPORT_PUBLICATION_VIEW */    
 /**    
  * Returns publication list
  * @return               Table 
  ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/

select 
  rp.*,      --TODO: drop column "Format" from [REPORT_PUBLICATIONS].  We will be using the Filetype_requested column in [REPORT_PUBLICATION_SUBSCRIPTIONS] from now on.
  ds.Name,   --      That field is populated by the widget on the Add New Subscription save screen.
  ds.DataSource,
  ds.DataSourceType,
  ds.PublicationClass,  
  rc.OKToPublishUpToDate,
  ds.DistEmailTitleTemplate,
  ds.DistEmailBodyTemplate,
  ds.DistEmailFooterTemplate
from REPORT_PUBLICATIONS             as rp 
join REPORT_PUBLICATION_DATA_SOURCES as ds on ds.ID = rp.[DataSourceID]
  AND (ds.isSensitive = 0 OR @includeSensitive = 1)
join REPORT_PUBLICATION_CLASSES      as rc on rc.ID = ds.[PublicationClass]

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_VIEW] TO [webuser]
GO   
