USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.REPORT_PUBLICATION_DISTRIBUTION_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.REPORT_PUBLICATION_DISTRIBUTION_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[REPORT_PUBLICATION_DISTRIBUTION_VIEW]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @clientID       INT,
 @procRunDate    DATETIME,
 @autoDistribute BIT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * REPORT_PUBLICATION_DISTRIBUTION_VIEW */    
 /**    
  * Returns distribution list for report distribution app
  * Also prevents duplicate runs
  *
  * Note: This is for automation use only
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(

/*============================================================
 * pub_and_sub_det
 * List of publications and subscribers, no grouping
 *============================================================*/ 

with
pub_and_sub_det
as
(
  select 
  
    rs.ClientID                 as [ClientID],
    rp.ID                       as [PublicationID],
    convert(varchar(50),rsr.ID) as [SubscriberID],
    rsr.Email                   as [Email],
    rsr.is_internal,
    rs.Filetype_requested
   
  from dbo.REPORT_PUBLICATION_VIEW (null,null,null, 1) as rp
  join dbo.REPORT_PUBLICATION_SUBSCRIPTIONS            as rs  on rs.PublicationID = rp.ID 
  join dbo.REPORT_PUBLICATION_SUBSCRIBERS              as rsr on rsr.ID           = rs.SubscriberID -- ?? what does "rsr" stand for? I'd refactor is as "ppl" for 'people'
    
  where ((1=1)
    
  /*-------------------------------
   * Filters by optional client id
   * and auto distribute flag
   *------------------------------*/
    
    and ((@clientID       is null) or (rs.ClientID       = @clientID))
    and ((@autoDistribute is null) or (rs.AutoDistribute = @autoDistribute))

  /*-------------------------------
   * Limits distribution to 
   * active entities
   *------------------------------*/
        
    and (rp.active  = 1) 
    and (rs.active  = 1) 
    and (rsr.active = 1)) 

)

,

/*============================================================
 * pub_and_sub_grps
 *
 * List of publications and subscribers, grouped together
 *
 * Note: This assists in generating and distributing 
 * publications
 *============================================================*/ 

pub_and_sub_grps
as
(
  select
   
    t1.ClientID,
    t1.PublicationID,
    is_internal,
    Filetype_requested,
      
        /*-------------------------------
         * Groups all of subscriber ids
         * by clientID and
         * publicationID into a single
         * column delimited by ,
         *------------------------------*/

          -- not necessary; this field/property is not defined in Distribution.cs and is not actually used, anywhere
    /* 
    DistributeToSubscribers = substring((SELECT ( ', ' + SubscriberID )
                           FROM pub_and_sub_det as t2
                           WHERE (t1.ClientID = t2.ClientID) and (t1.PublicationID = t2.PublicationID)
                           FOR XML PATH( '' )
                         ), 3, 1000 ), */  -- not necessary; this field/property is not defined in Distribution.cs and is not actually used, anywhere
    
    /*-------------------------------
     * Groups all of the email
     * addresses by clientID and
     * publicationID into a single
     * column delimited by ;
     *------------------------------*/
    
    DistributeToEmails = STRING_AGG(Email,';') -- yay, much cleaner syntax in SQL Server 2017

  from pub_and_sub_det as t1
  group by 
    ClientID, 
    PublicationID,
    is_internal,
    Filetype_requested
)

,

/*============================================================
 * dist_retry_lst
 *
 * Retry list
 *
 * Note: Reference date is the date that was stored when the
 * retry was first issued
 *============================================================*/ 

dist_retry_lst
as
(
  select     
    cast(1 as bit)               as [IsRetry],
    rh.[ReferenceDate]           as [ReferenceDate],
    rs.ClientID,
    rp.ID                        as PublicationID,
    rp.Name                      as PublicationName,
    rp.Description               as PublicationDescription,
    rp.TrackingSheetDescription  as PublicationTrackingSheetDescription,
    rp.DistributionDateFormat    as PublicationDistributionDateFormat,
    rp.DistributionDescription1  as PublicationDistributionDescription1,
    rp.DistributionDescription2  as PublicationDistributionDescription2,
    rp.PublicationClass,
    rp.OKToPublishUpToDate,
    rp.DataSource,
    rp.DataSourceType,
    rp.Format,
    rp.Schedule,
    rp.RelativeDateRange1,
    rp.RelativeDateRange2,
    rh.ActualDateRange1,
    --rs.DistributeToSubscribers,
    rs.DistributeToEmails,
    rs.is_internal               as isInternal,
    rs.Filetype_requested        as fileTypeRequested,
    rp.ManagedByEmails,
    rp.DistEmailTitleTemplate,
    rp.DistEmailBodyTemplate,
    rp.DistEmailFooterTemplate
  from pub_and_sub_grps as rs
  join dbo.REPORT_PUBLICATION_VIEW (null,null,null, 1) as rp  on rp.ID = rs.PublicationID
  join dbo.REPORT_PUBLICATION_DISTRIBUTION_HISTORY  as rh on rh.ClientID        = rs.ClientID
                                                          and rh.PublicationID = rs.PublicationID
                                                          and rh.Status        != 0
                                                          and rh.RetryDate     = @procRunDate 
                                                          and rh.NextID        is null                                                     
)
,

/*============================================================
 * dist_new_lst
 *
 * Potential new distributions
 *
 * Note: Reference date is the @runDate that is passed in
 *============================================================*/ 
 
dist_new_lst
as
(
  select 
    cast(0 as bit)               as [IsRetry],
    @procRunDate                 as [ReferenceDate],
    rs.ClientID,
    rp.ID                        as PublicationID,
    rp.Name                      as PublicationName,
    rp.Description               as PublicationDescription,
    rp.TrackingSheetDescription  as PublicationTrackingSheetDescription,
    rp.DistributionDateFormat    as PublicationDistributionDateFormat,
    rp.DistributionDescription1  as PublicationDistributionDescription1,
    rp.DistributionDescription2  as PublicationDistributionDescription2,
    rp.PublicationClass,
    rp.OKToPublishUpToDate,
    rp.DataSource,
    rp.DataSourceType,
    rp.Format,
    rp.Schedule,
    rp.RelativeDateRange1,
    rp.RelativeDateRange2,
    [ActualDateRange1] = '', 
    --rs.DistributeToSubscribers, 
    rs.DistributeToEmails,
    rs.is_internal               as isInternal,
    rs.Filetype_requested        as fileTypeRequested,
    rp.ManagedByEmails,
    rp.DistEmailTitleTemplate,
    rp.DistEmailBodyTemplate,
    rp.DistEmailFooterTemplate 
  from pub_and_sub_grps as rs
  join dbo.REPORT_PUBLICATION_VIEW (null,null,null, 1) as rp  on rp.ID = rs.PublicationID  
  
  /*-------------------------------
   * Prevents duplicate runs
   *------------------------------*/
  
  left join dbo.REPORT_PUBLICATION_DISTRIBUTION_HISTORY  as rh  on rh.ClientID  = rs.ClientID
                                                         and rh.PublicationID   = rs.PublicationID
                                                         and rh.procRunDate     = @procRunDate
                                                    
  where (rh.ID is null)  /* Leftover records */                                                   
)
,

/*============================================================
 * dist_lst
 *
 * The list combined
 *============================================================*/ 

dist_lst
as
(
  select * from dist_retry_lst
  union all
  select * from dist_new_lst
)

/*============================================================
 * Output results, filling in details
 *============================================================*/ 

select top (dbo.CONST_MAX_ROWS()) 

  /*-------------------------------
   * Results
   *------------------------------*/

  rs.*,
  
  /*-------------------------------
   * Client details
   *
   * Note: Client rep data has
   * fallback values
   *
   * TODO: Get these in constants
   * or global app settings  
   *------------------------------*/
 
  cc.CLIENT_NAME                                  as ClientName,

  isnull(um.FirstName,   '')                      as RepNameFirst,
  isnull(um.LastName,    '')                      as RepNameLast,  
  isnull(um.Email,       'mail@practi-cal.com')   as RepEmail, -- Q: Who monitors this inbox?
  isnull(um.PhoneNumber, '1-888-944-7798')        as RepPhone  -- NOTE: Probably doesn't matter, but I called this number and the office didn't ring.
                                                               -- It went straight to our voicemail.

from dist_lst                                 as rs
join dbo.REPORT_PUBLICATION_VIEW (null,null,null, 1) as rp  on rp.ID        = rs.PublicationID
left join dbo.CLIENTS_CLIENT                      as cc  on cc.CLIENT_ID = rs.ClientID
left join dbo.CLIENTS_Client_Reps                 as ccr on ccr.id       = cc.ClientRepIDLEACurrent
left join [users].[dbo].[Users]               as uu  on uu.userrid   = ccr.user_id
left join [users].[dbo].[Membership]          as um  on um.UserId    = uu.UserId


/*-------------------------------
 * Limits all report runs that
 * pertain to clients to active
 * clients, including re-runs
 *------------------------------*/

where 

  ((cc.LEA is null) or (cc.LEA = 1))

/*-------------------------------
 * Show oldest distributions
 * first
 *------------------------------*/

order by 
  
  [ReferenceDate], 
  [ClientName]

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[REPORT_PUBLICATION_DISTRIBUTION_VIEW] TO [webuser]
GO   
