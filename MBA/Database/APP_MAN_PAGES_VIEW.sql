USE users
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.APP_MAN_PAGES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.APP_MAN_PAGES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[APP_MAN_PAGES_VIEW]
(@userID             BIGINT,
 @userGroup          INT,
 @userRank           INT,
 @appName            varchar(50),
 @okToDisplay        bit,
 @timeToDisplay      bit,
 @refDate            datetime,
 @active             bit,
 @includeContent     bit,
 @term               varchar(256),
 @recID              bigint
)
RETURNS TABLE
AS
RETURN
(

/***************************************************************************
 * APP_APP_MAN_PAGES_VIEW */
/**
 * Displays user data
 *
 * @param  clientID        ID of client or null for all clients
 * @param  roleID          user's username or null
 * @param  appName         user's email or null
 * @return                 Table of user data
 ***************************************************************************/

with cte_all as (
select
  mp.*,
  mporg.organizationID org_id,
  cc.CLIENT_NAME


from [users].dbo.APP_MAN_PAGES_VIEW_CORE (
    @userID
  , @userGroup
  , @userRank
  , @appName
  , @okToDisplay
  , @active
  , @timeToDisplay
  , @refDate
  , @includeContent
  , @recID ) mp

left join [dbo].[AppManPagesForAppOrganizations] as mporg on mporg.pageID = mp.id

left join [spedmon].[dbo].CLIENTS_Client cc ON cc.CLIENT_ID = mporg.organizationID

where (
      (1=1)
  and ((@term is null) or (title like '%' + isnull(@term,'') + '%'))
)
)


SELECT top (dbo.CONST_MAX_ROWS())

       id
     , MAX(appName) appName -- expect 1; grouping by id
     , MAX(startDate)  startDate -- expect 1; grouping by id
     , MAX(endDate) endDate -- expect 1; grouping by id
     , MAX([title]) [title] -- expect 1; grouping by id
     , MAX([description]) [description] -- expect 1; grouping by id
     , MAX(content) content -- expect 1; grouping by id
     , okToDisplay okToDisplay -- expect 1; grouping by id

     , include_in_welcome_package
     , display_order

     , MAX(created) created -- expect 1; grouping by id
     , MAX(createdBy) createdBy -- expect 1; grouping by id
     , MAX(lastModified) lastModified -- expect 1; grouping by id
     , MAX(lastModifiedBy) lastModifiedBy -- expect 1; grouping by id
     , active -- expect 1; grouping by id
     , MAX([name]) [name] -- expect 1; grouping by id
     , [timeToDisplay] -- expect 1; grouping by id
 , MAX(startDateStr) startDateStr -- expect 1; grouping by id
 , MAX(endDateStr) endDateStr -- expect 1; grouping by id
 , MAX(okToDisplayStr) okToDisplayStr -- expect 1; grouping by id
 , MAX(featuredImgFileData) featuredImgFileData
 , includeOnDashboard   includeOnDashboard

 , MAX(forUserRoleIdValsStr) forUserRoleIdValsStr -- expect 1; grouping by id
 , MAX(forUserRoleIdNamesStr) forUserRoleIdNamesStr -- expect 1; grouping by id

  ,STRING_AGG(CLIENT_NAME, '|') forOrgsNamesStr
  ,STRING_AGG(org_id, ',') forOrgsIDsStr

  , rowOrder

 FROM cte_all
 GROUP by
   id,
   okToDisplay, --expect 1

   include_in_welcome_package, -- expect 1
   display_order, -- expect 1; grouping by id

   active, --expect 1
   [timeToDisplay], --expect 1
   includeOnDashboard,
   rowOrder
order by rowOrder

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

grant select on AppManPagesForAppOrganizations to webuser
GO

GRANT SELECT ON  [dbo].[APP_MAN_PAGES_VIEW] TO [webuser]
GO
