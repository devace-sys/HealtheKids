USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITES_REFRESH_PCAL_CDE_XREF_TABLES') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SITES_REFRESH_PCAL_CDE_XREF_TABLES
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SITES_REFRESH_PCAL_CDE_XREF_TABLES]
AS
BEGIN   

SET NOCOUNT ON    	    

RAISERROR ('Refresh site pcal cde xref data', 0, 1) WITH NOWAIT

declare @today as datetime

declare @CurrentClients as table (
    CLIENT_ID   bigint
  , CLIENT_CDS  varchar(7)
  , CLIENT_NAME varchar(1000)
  UNIQUE CLUSTERED (CLIENT_ID)
)

declare @CdeSites as table (
    CLIENT_CDS  varchar(7)
  , SITE_CDS    varchar(7)
  , CLIENT_NAME varchar(100)  
  , SITE_NAME   varchar(100)
  , STREET      varchar(512)
  , CITY        varchar(512)
  , STATE       varchar(512)
  , ZIP5        varchar(5)
  , ZIP4        varchar(4)    
  , HAS_ADDRESS bit
  , CLOSED      bit
)
declare @OurSites as table (
    ID                       bigint identity(1,1)
  , CLIENT_CDS               varchar(7)
  , SITE_CDS                 varchar(7)
  , CLIENT_NAME              varchar(1000)  
  , SITE_NAME                varchar(100)
  , CLIENT_ID                bigint
  , SITE_ID                  bigint
  , CLIENT_PROVIDED_SITE_UID varchar(1000)
  , ADDRESS_1                varchar(1000)
  , CITY                     varchar(1000)
  , STATE                    varchar(2)
  , ZIP5                     varchar(5)
  , ZIP4                     varchar(4)
  , HAS_ADDRESS              bit
)
 
declare @SitesXref as table (
      XREF_ROW_ID             bigint identity(1,1)
    , CLIENT_CDS              varchar(7)
    , SITE_CDS                varchar(7)
    , CLIENT_NAME             varchar(1000)
    , PCAL_SITE_NAME          varchar(100)
    , PCAL_STREET             varchar(512)
    , PCAL_CITY               varchar(512)
    , PCAL_STATE              varchar(512)
    , PCAL_ZIP5               varchar(5)
    , PCAL_ZIP4               varchar(4)       
    , CDE_SITE_NAME           varchar(100)
    , CDE_STREET              varchar(512)
    , CDE_CITY                varchar(512)
    , CDE_STATE               varchar(512)
    , CDE_ZIP5                varchar(5)
    , CDE_ZIP4                varchar(4)       
    , CLIENT_ID               bigint
    , SITE_ID                 bigint
    , PCAL_HAS_ADDRESS        bit        
    , CDE_HAS_ADDRESS         bit 
    , CDE_REPORTS_SITE_MERGED_OR_CLOSED bit
   UNIQUE CLUSTERED (XREF_ROW_ID )
)set @today = getdate()/* Get current clients */
RAISERROR ('Get current clients', 0, 1) WITH NOWAIT
insert into @CurrentClients select    cc.CLIENT_ID  , cc.CLIENT_CDS  , cc.CLIENT_NAMEfrom dbo.CLIENTS_Client as ccwhere (        (cc.CLIENT_ID != 112)   and ((cc.LEA = 1) or (cc.MAA = 1))  )/* Get CDE sites */

RAISERROR ('Get current merged, and closed CDE sites', 0, 1) WITH NOWAIT

insert into @CdeSites
select 
    CLIENT_CDS  = upper(ltrim(rtrim(cc.CLIENT_CDS)))
  , SITE_CDS    = upper(ltrim(rtrim(cde.CDSCodeSite)))
  , CLIENT_NAME = cc.CLIENT_NAME
  , SITE_NAME   = cde.School
  , STREET      = ltrim(rtrim(isnull(cde.Street,'')))
  , CITY        = ltrim(rtrim(isnull(cde.City,'')))
  , STATE       = ltrim(rtrim(isnull(cde.State,'')))
  , ZIP5        = ltrim(rtrim(isnull(cde.Zip5,'')))  , ZIP4        = ltrim(rtrim(isnull(cde.Zip4,'')))
  , HAS_ADDRESS = null
  , CLOSED      = 0
from @CurrentClients               as cc
join dbo.CDE_SCHOOLS_SITES_CURRENT as cde on cde.CDSCodeFirst7 = cc.CLIENT_CDS

union

select 
    CLIENT_CDS  = upper(ltrim(rtrim(cc.CLIENT_CDS)))
  , SITE_CDS    = upper(ltrim(rtrim(SUBSTRING(cde.CDSCode,8,7))))
  , CLIENT_NAME = cc.CLIENT_NAME
  , SITE_NAME   = cde.School
  , STREET      = ltrim(rtrim(isnull(cde.Street,'')))
  , CITY        = ltrim(rtrim(isnull(cde.City,'')))
  , STATE       = ltrim(rtrim(isnull(cde.State,'')))
  , ZIP5        = ltrim(rtrim(isnull(SUBSTRING(cde.Zip,1,5),'')))  , ZIP4        = ltrim(rtrim(isnull(SUBSTRING(cde.Zip,6,4),'')))
  , HAS_ADDRESS = 1
  , CLOSED      = 1
from @CurrentClients            as cc
join dbo.CDE_SCHOOLS_PUBLIC     as cde on SUBSTRING(CdsCode,1,7) = cc.CLIENT_CDS
where ((StatusType = 'Closed') or (StatusType = 'Merged'))
  
update @CdeSites
SET HAS_ADDRESS = convert(bit, case when ((STREET != '') and (CITY != '') and (STATE != '') and (ZIP5 != '')) then 1 else 0 end)

/* Get Our sites */

RAISERROR ('Get current PCAL sites', 0, 1) WITH NOWAIT

insert into @ourSites
select
    CLIENT_CDS  = upper(ltrim(rtrim(cc.CLIENT_CDS)))
  , SITE_CDS    = upper(ltrim(rtrim(ss.SITE_CDS)))
  , CLIENT_NAME = cc.CLIENT_NAME
  , SITE_NAME   = ss.SITE_NAME
  , CLIENT_ID   = cc.CLIENT_ID
  , SITE_ID     = ss.SITE_ID
  , ss.CLIENT_PROVIDED_SITE_UID  , ADDRESS_1   = ltrim(rtrim(isnull(sa.ADDRESS_1     ,'')))  , CITY        = ltrim(rtrim(isnull(sa.CITY          ,'')))  , STATE       = ltrim(rtrim(isnull(sa.STATE         ,'')))  , ZIP5        = ltrim(rtrim(isnull(sa.ZIP           ,'')))  , ZIP4        = ltrim(rtrim(isnull(sa.ZIP_PLUS_FOUR ,'')))
  , HAS_ADDRESS = 0
from      @CurrentClients   as cc
join      dbo.SITES_Site    as ss on ss.SITE_CLIENT_ID = cc.CLIENT_ID
left join dbo.SITES_ADDRESS as sa on sa.SITE_ID        = ss.SITE_ID 
where (ss.ACTIVE = 1) 

update @ourSites
SET HAS_ADDRESS = convert(bit, case when ((ADDRESS_1 != '') and (CITY != '') and (STATE != '') and (ZIP5 != '')) then 1 else 0 end)

/* Build cross reference */

RAISERROR ('Rebuilding cross reference', 0, 1) WITH NOWAIT
  
insert into @SitesXref
select 
    ss.CLIENT_CDS
  , ss.SITE_CDS
  , ss.CLIENT_NAME
  , PCAL_SITE_NAME  = ss.SITE_NAME
  , PCAL_STREET     = ss.ADDRESS_1
  , PCAL_CITY       = ss.CITY
  , PCAL_STATE      = ss.STATE
  , PCAL_ZIP5       = ss.ZIP5
  , PCAL_ZIP4       = ss.ZIP4  
  , CDE_SITE_NAME_  = cs.SITE_NAME  
  , CDE_STREET      = cs.STREET
  , CDE_CITY        = cs.CITY
  , CDE_STATE       = cs.STATE
  , CDE_ZIP5        = cs.ZIP5
  , CDE_ZIP4        = cs.ZIP4
  , ss.CLIENT_ID
  , ss.SITE_ID  
  , PCAL_HAS_ADDRESS                  = ss.HAS_ADDRESS
  , CDE_HAS_ADDRESS                   = cs.HAS_ADDRESS
 
  , CDE_REPORTS_SITE_MERGED_OR_CLOSED = cs.CLOSED
from      @OurSites as ss
join      @CdeSites as cs on  cs.CLIENT_CDS = ss.CLIENT_CDS 
                          and cs.SITE_CDS   = ss.SITE_CDS

union

select 
    ss.CLIENT_CDS
  , ss.SITE_CDS
  , ss.CLIENT_NAME
  , PCAL_SITE_NAME  = ss.SITE_NAME
  , PCAL_STREET     = ss.ADDRESS_1
  , PCAL_CITY       = ss.CITY
  , PCAL_STATE      = ss.STATE
  , PCAL_ZIP5       = ss.ZIP5
  , PCAL_ZIP4       = ss.ZIP4  
  , CDE_SITE_NAME_  = cs.SITE_NAME  
  , CDE_STREET      = cs.STREET
  , CDE_CITY        = cs.CITY
  , CDE_STATE       = cs.STATE
  , CDE_ZIP5        = cs.ZIP5
  , CDE_ZIP4        = cs.ZIP4
  , ss.CLIENT_ID
  , ss.SITE_ID  
  , PCAL_HAS_ADDRESS                  = ss.HAS_ADDRESS
  , CDE_HAS_ADDRESS                   = cs.HAS_ADDRESS
  , CDE_REPORTS_SITE_MERGED_OR_CLOSED = cs.CLOSED
from      @OurSites as ss
join      @CdeSites as cs on  cs.SITE_CDS   = ss.SITE_CDS

RAISERROR ('Storing cross reference matches and mismatches', 0, 1) WITH NOWAIT

truncate table dbo.SITES_PCAL_CDE_XREF_MATCH
truncate table dbo.SITES_PCAL_CDE_XREF_NO_MATCH

insert into dbo.SITES_PCAL_CDE_XREF_MATCH
select
    *
  , XREF_UPDATED_ON = @today

from @SitesXref

insert into dbo.SITES_PCAL_CDE_XREF_NO_MATCH
select 
    t2.*
  , IS_PSEUDO = convert(bit,case when sp.ID is null then 0 else 1 end)
  , XREF_UPDATED_ON = @today
from
(
  select 
      cc.CLIENT_CDS
    , ss.SITE_CDS
    , cc.CLIENT_NAME
    , ss.SITE_NAME
    , cc.CLIENT_ID
    , ss.SITE_ID
  from      @currentClients   as cc
  join      @ourSites         as ss on ss.CLIENT_ID = cc.CLIENT_ID
  left join @SitesXref        as t1 on t1.SITE_ID   = ss.SITE_ID
  where (
    (t1.SITE_ID is null)
  )
) as t2
left join dbo.SITES_PSEUDONYMS as sp on sp.SITE_NAME = t2.SITE_NAME

RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SITES_REFRESH_PCAL_CDE_XREF_TABLES] TO [webuser]
GO
 
