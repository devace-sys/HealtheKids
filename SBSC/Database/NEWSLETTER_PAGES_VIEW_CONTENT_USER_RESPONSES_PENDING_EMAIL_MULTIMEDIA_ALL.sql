USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL](  
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT

  , @pageID               BIGINT
  , @appName             varchar(50)

)


RETURNS TABLE 
AS
RETURN 
(
    /* Note: The union all is NOT redundant.  See the different use of the clientID
	 * assignment.
	 */

    select * from
    [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA](  
      @userID              
    , @userGroup             
    , @userRank

    , @pageID
    , @appName                

    , 0 -- @clientID
    )

    union all
    
    select * from
    [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA](  
      @userID              
    , @userGroup             
    , @userRank

    , @pageID
    , @appName             
 

    , null -- @clientID
    )
	
)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_USER_RESPONSES_PENDING_EMAIL_MULTIMEDIA_ALL] TO [webuser]
GO