USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SITES_UPDATE_DATA_FROM_CDE') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.SITES_UPDATE_DATA_FROM_CDE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[SITES_UPDATE_DATA_FROM_CDE]
AS
BEGIN   

SET NOCOUNT ON    	    

RAISERROR ('Updating site data from CDE data imports', 0, 1) WITH NOWAIT

begin try

/*============================================================
 * Refresh cross reference
 *============================================================*/  
exec SITES_REFRESH_PCAL_CDE_XREF_TABLES

/*============================================================
 * Get current clients
 *============================================================*/  
RAISERROR ('Get current clients', 0, 1) WITH NOWAIT

declare @CurrentClients as table (
    CLIENT_ID   bigint
  , CLIENT_CDS  varchar(7)
  , CLIENT_NAME varchar(1000)
  UNIQUE CLUSTERED (CLIENT_ID)
)
insert into @CurrentClientsselect    cc.CLIENT_ID  , cc.CLIENT_CDS  , cc.CLIENT_NAMEfrom dbo.CLIENTS_Client as ccwhere (        (cc.CLIENT_ID != 112)   and ((cc.LEA = 1) or (cc.MAA = 1))  )
/*============================================================
 * Look for updates
 *============================================================*/  
RAISERROR ('Searching for data we can update', 0, 1) WITH NOWAIT
declare @SiteUpdates as table (    ID                       bigint identity(1,1)  , CLIENT_ID                bigint  , CLIENT_CDS               varchar(7)  , CLIENT_NAME              varchar(1000)  , SITE_ID                  bigint  , SITE_CDS                 varchar(7)  , SITE_NAME                varchar(50)  , CLIENT_PROVIDED_SITE_UID varchar(1000)  , ADDRESS_1                varchar(1000)  
  , CITY                     varchar(1000)
  , STATE                    varchar(2)
  , ZIP5                     varchar(5)
  , ZIP4                     varchar(4)  , SAVE_TYPE                int  , REASON                   varchar(1000))/* Missing addresses */
RAISERROR ('Looking for missing addresses', 0, 1) WITH NOWAIT
insert into @SiteUpdatesselect     t1.CLIENT_ID  , t1.CLIENT_CDS  , t1.CLIENT_NAME   , t1.SITE_ID   , t1.SITE_CDS    , SITE_NAME = t1.PCAL_SITE_NAME  , t2.CLIENT_PROVIDED_SITE_UID  , ADDRESS_1 = t1.CDE_STREET  , CITY      = t1.CDE_CITY  , STATE     = t1.CDE_STATE  , ZIP5      = t1.CDE_ZIP5  , ZIP4      = t1.CDE_ZIP4  , SAVE_TYPE = dbo.CONST_SAVE_TYPE_EDIT()  , REASON    = 'Filled in missing address data from CDE data'from dbo.SITES_PCAL_CDE_XREF_MATCH as t1join dbo.SITES_SITE                as t2 on t2.SITE_ID = t1.SITE_ID
where t1.PCAL_HAS_ADDRESS = 0 and t1.CDE_HAS_ADDRESS = 1RAISERROR ('Looking for missing sites', 0, 1) WITH NOWAIT
insert into @SiteUpdatesselect     CLIENT_ID   = cc.CLIENT_ID  , CLIENT_CDS  = cc.CLIENT_CDS  , CLIENT_NAME = cc.CLIENT_NAME  , SITE_ID     = null  , SITE_CDS    = cde.CDSCodeLast7  , SITE_NAME   = SUBSTRING(cde.School,1,50)  , CLIENT_PROVIDED_SITE_UID = ''  , ADDRESS_1 = cde.Street  , CITY      = cde.City  , STATE     = cde.State  , ZIP5      = cde.Zip5  , ZIP4      = cde.Zip4  , SAVE_TYPE = dbo.CONST_SAVE_TYPE_NEW()  , REASON    = 'Added missing site from CDE data'from      @CurrentClients               as ccjoin      dbo.CDE_SCHOOLS_SITES_CURRENT as cde on cde.CDSCodeFirst7 = cc.CLIENT_CDSleft join dbo.SITES_SITE                as csc on csc.SITE_CDS      = cde.CDSCodeLast7 where (SITE_ID is null)/*============================================================
 * Check if there is any work to do
 *============================================================*/  
declare @numSites as bigint
select @numSites = count(ID) from @SiteUpdates 

/*============================================================
 * If none exit
 *============================================================*/  
if (@numSites = 0) 
begin
  RAISERROR ('No updates found', 0, 1) WITH NOWAIT  
  return(0)
end

/*============================================================
 * Otherwise do the work
 *============================================================*/  
RAISERROR ('Updates found', 0, 1) WITH NOWAIT  
declare @minIdx as bigintdeclare @maxIdx as bigintdeclare @curIdx as bigintselect @minIdx = min(ID) from @SiteUpdatesselect @maxIdx = max(ID) from @SiteUpdatesselect @curIdx = @minIdx
DECLARE @userID                   bigint
DECLARE @userGroup                int
DECLARE @userRank                 int
declare @clientName               varchar(1000)
declare @clientCDS                varchar(7)
DECLARE @SITE_CLIENT_ID           int
DECLARE @SITE_CDS                 varchar(1000)
DECLARE @SITE_NAME                varchar(1000)
DECLARE @CLIENT_PROVIDED_SITE_UID varchar(20)
DECLARE @ADDRESS_1                nvarchar(1000)
DECLARE @ADDRESS_2                nvarchar(1000)
DECLARE @CITY                     nvarchar(1000)
DECLARE @STATE                    nvarchar(1000)
DECLARE @ZIP                      nvarchar(5)
DECLARE @editDelReason            varchar(7000)
DECLARE @validateRec              bit
DECLARE @saveType                 int
DECLARE @recID                    bigint
DECLARE @MsgNoRec                 varchar(1000)
DECLARE @MsgNoEdit                varchar(1000)
DECLARE @MsgDupRec                varchar(1000)
DECLARE @MsgDataError             varchar(1000)
DECLARE @MsgNotActive             varchar(1000)
DECLARE @spDetails                varchar(8000)
DECLARE @recordID                 bigint
declare @recData1                 varchar(255)
declare @recData2                 varchar(255)
declare @recData3                 varchar(255)
declare @recData4                 varchar(255)

set @userID        = 0 /* System */
set @userGroup     = dbo.CONST_USER_GROUP_SBS()
set @userRank      = 9
set @validateRec   = 0
set @MsgNoRec      = 'No site record'
set @MsgNoEdit     = 'Can not edit site record'
set @MsgDupRec     = 'Duplicate site record'
set @MsgDataError  = 'Data error in site data'
set @MsgNotActive  = 'Site record is no longer active'
while (@curIdx <= @maxIdx)begin  
    set @spDetails = ''
    set @recordID  = 0
    set @recData1 = ''
    set @recData2 = ''
    set @recData3 = ''
    set @recData4 = ''
    
    select top 1
        @clientName               = CLIENT_NAME
      , @clientCDS                = CLIENT_CDS
      , @SITE_CLIENT_ID           = CLIENT_ID
      , @SITE_CDS                 = SITE_CDS
      , @SITE_NAME                = SITE_NAME
      , @CLIENT_PROVIDED_SITE_UID = CLIENT_PROVIDED_SITE_UID
      , @ADDRESS_1                = ADDRESS_1
      , @ADDRESS_2                = ''
      , @CITY                     = CITY
      , @STATE                    = STATE
      , @ZIP                      = ZIP5
      , @recID                    = SITE_ID
      , @saveType                 = SAVE_TYPE      , @editDelReason            = REASON
    from @SiteUpdates
    where (ID = @curIdx)
  
    declare @msg as varchar(8000)
    
    set @msg = convert(varchar(50),@curIdx) 
             + ' of ' 
             + convert(varchar(50),@maxIdx) 
             + ' - '
             + @ClientName
             + ' - '            
             + @SITE_NAME
             + ' ('
             + @clientCDS
             + @SITE_CDS
             + ') : '
             + @editDelReason
             
    RAISERROR (@msg, 0, 1) WITH NOWAIT

    /* TODO: Uncomment when this routine supports zip5 and phone */

	/*exec dbo.SITES_Save
      @userID
    , @userGroup
    , @userRank
    , @SITE_CLIENT_ID
    , @SITE_CDS
    , @SITE_NAME
    , @CLIENT_PROVIDED_SITE_UID
    , @ADDRESS_1
    , @ADDRESS_2
    , @CITY
    , @STATE
	, ''
    , @ZIP
    , ''
	, @editDelReason
    , @validateRec
    , @saveType
    , @recID
    , @MsgNoRec
    , @MsgNoEdit
    , @MsgDupRec
    , @MsgDataError
    , @MsgNotActive
    , @spDetails OUTPUT
    , @recordID  OUTPUT
    , @recData1  OUTPUT
    , @recData2  OUTPUT
    , @recData3  OUTPUT
    , @recData4  OUTPUT
    */    set @curIdx = @curIdx + 1end

/*============================================================
 * Refresh cross reference again
 *============================================================*/  
exec SITES_REFRESH_PCAL_CDE_XREF_TABLES

/*============================================================
 * Done
 *============================================================*/  
RETURN(0)

end try
begin catch

declare @ErrorMessage  as NVARCHAR(4000)    
declare @ErrorSeverity as INT    
declare @ErrorState    as INT    
      
set @ErrorMessage = ''

select  @ErrorMessage  = ERROR_MESSAGE(),    
        @ErrorSeverity = ERROR_SEVERITY(),    
        @ErrorState    = ERROR_STATE()    
   
      
set @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
print @ErrorMessage      
RETURN(1)
end catch 
RETURN(0)
END 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[SITES_UPDATE_DATA_FROM_CDE] TO [webuser]
GO
 
