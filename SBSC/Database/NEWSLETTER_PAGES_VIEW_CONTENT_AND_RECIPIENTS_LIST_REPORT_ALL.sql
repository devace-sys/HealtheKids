USE spedmon
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL
GO


/*-------------------------------
 * Exists/Drop
 *------------------------------*/


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL](  
    @userID              BIGINT    
  , @userGroup           INT    
  , @userRank            INT

  --, @isMultiMediaNewsletter bit

  , @term               varchar(256)
  , @pageID               BIGINT

  , @appName             varchar(50)
)

RETURNS TABLE 
AS
RETURN 
(

    select * from
    [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT](  
      @userID              
    , @userGroup 
    , @userRank            
    , @appName             
 
    , @term
    , @pageID

    , 0 -- @clientID
        
    )



                -- this subquery is run twice - for with @clientID null,
                -- and with @clientID = 0.
                -- This exhaustively finds all valid recipients, assoc with a client
                -- and not assoc with a client.


    union all
    
    select * from
    [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT](  
      @userID              
    , @userGroup             
    , @userRank            
    , @appName             

    , @term 
    , @pageID

    , null -- @clientID
    )
	
)
GO


/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[NEWSLETTER_PAGES_VIEW_CONTENT_AND_RECIPIENTS_LIST_REPORT_ALL] TO [webuser]
GO