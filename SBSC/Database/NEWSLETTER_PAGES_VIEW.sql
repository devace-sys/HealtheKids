USE spedmon
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.MULTIMEDIA_OUTREACH_CAMPAIGN_PAGES_VIEW
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NEWSLETTER_PAGES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NEWSLETTER_PAGES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[NEWSLETTER_PAGES_VIEW]
(
 @userID             BIGINT,
 @userGroup          INT,
 @userRank           INT,

 @appName            varchar(50),

 @active      bit,

 @sendEmailSelected  bit ,

 @includeContent     bit,
 @wIncluJoinsFromDropDownSelections  bit,

 @term               varchar(256),
 @recID              bigint
)

RETURNS TABLE
AS


RETURN
(


with cte_all as (
select
    mp.* 
  , [title] as [name]
  , isResourceLibraryTopicStr = dbo.RPT_BIT_TO_YN(mp.isResourceLibraryTopic)
  , mustResendStr             = dbo.RPT_BIT_TO_YN(mp.mustResend)
  , sendEmailSelectedStr      = dbo.RPT_BIT_TO_YN(mp.sendEmailSelected)
from dbo.NEWSLETTER_PAGES_VIEW_CORE (

    @userID
  , @userGroup
  , @userRank

  , @appName

  , @wIncluJoinsFromDropDownSelections
  

  , @active

  , @sendEmailSelected


  , @includeContent

  , null  /* @togglReadyToSend */
  , null  /* @mustSendOrResend */
  , null  /* @startdateReadyOrBlank */

  , @term

  , @recID ) mp

)



SELECT top (dbo.CONST_MAX_ROWS())
      *
 FROM cte_all

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/



GRANT SELECT ON  [dbo].[NEWSLETTER_PAGES_VIEW] TO [webuser]
GO
