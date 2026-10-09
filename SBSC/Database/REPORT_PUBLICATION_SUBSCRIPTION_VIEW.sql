USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_SUBSCRIPTION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUBLICATION_SUBSCRIPTION_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[REPORT_PUBLICATION_SUBSCRIPTION_VIEW]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @clientID       BIGINT,
 @active         BIT,
 @includeSensitiveReportsAndInternalSubscribers BIT,
 @recID          BIGINT
)    

RETURNS TABLE
 
/***************************************************************************    
 * REPORT_PUBLICATION_SUBSCRIPTION_VIEW */ 
/**    
 * Returns subscription list
 * @return               Table 
 ***************************************************************************/                         
     
AS RETURN
(


/*-------------------------------
 * Return rows
 *------------------------------*/

select top (dbo.CONST_MAX_ROWS()) 
  rs.id,
  rs.clientID    as ClientID,
  cc.CLIENT_NAME as ClientName,
  rsr.ID         as SubscriberID,
  rsr.Name       as SubscriberName,
  rsr.Email                          as [SubscriberEmail],
  rs.PublicationID,
  rp.Name + ' - ' + rp.Description   as PublicationName,
  rs.AutoDistribute,
  rs.DistributionNotes,
  rs.Active,
  rs.Filetype_requested as FileTypeRequestedValue,
  rpft.[NAME] as FileTypeRequestedName
from dbo.REPORT_PUBLICATION_SUBSCRIPTIONS                                    as rs 
join dbo.REPORT_PUBLICATION_SUBSCRIBER_VIEW(null,null,null,null,null,0,null) as rsr  on rsr.ID = rs.SubscriberID
  AND (rsr."Internal?" = 0 OR @includeSensitiveReportsAndInternalSubscribers = 1)
join dbo.REPORT_PUBLICATION_VIEW(null,null,null,@includeSensitiveReportsAndInternalSubscribers) as rp  on rp.ID  = rs.PublicationID
join dbo.REPORT_PUBLICATION_FILE_TYPES                                       as rpft on rpft.[VALUE]  = rs.Filetype_requested
left join dbo.CLIENTS_CLIENT                                                 as cc   on cc.CLIENT_ID = rs.ClientID

where 
 
 (1=1) 
  and  ((@clientID is null)  or (rs.clientID = @clientID))    
  and  ((@active   is null)  or (rs.active   = @active))    
  and  ((@recID    is null)  or (rs.id       = @recID))

order by 

  cc.CLIENT_NAME, 
  rp.Name
  
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_SUBSCRIPTION_VIEW] TO [webuser]
GO   
