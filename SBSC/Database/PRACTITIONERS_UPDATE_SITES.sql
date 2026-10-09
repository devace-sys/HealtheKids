USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONERS_UPDATE_SITES') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.PRACTITIONERS_UPDATE_SITES
GO

/*-------------------------------
 * Create 
 *------------------------------*/
    
CREATE PROCEDURE [dbo].PRACTITIONERS_UPDATE_SITES (  
    @clientID bigint 
  , @userID   bigint = 0
  , @showMsgs bit    = 1
)    
AS    
BEGIN     
    
/***************************************************************************    
 * PRACTITIONERS_UPDATE_SITES */    
/**    
 ***************************************************************************/         
     
SET NOCOUNT ON    

exec dbo.PRINT_STATUS_MESSAGE 'Practitioners Update Sites - Starting'

/*============================================================
 * Init 
 *===========================================================*/  

declare @today           as datetime = getdate()
declare @earliestCreated as datetime = convert(date,(dateadd(day,-2,@today)))

declare @pracSites as table (    
    pracID   int
  , siteID   int  
unique clustered (pracID, siteID)
)

/*============================================================
 * Get latest site data from service records
 * Uses index on svc recs table
 *===========================================================*/  

exec dbo.PRINT_STATUS_MESSAGE 'Practitioners Update Sites - Get Latest Site Data from Service Records'


insert into @pracSites (    
    pracID
  , siteID
)
select     
    sr.pracID
  , sr.siteID  
from dbo.CLIENTS_Client            as clc
join dbo.PRACTITIONER_Client       as prc on prc.CLIENT_ID       = clc.CLIENT_ID
join dbo.PRACTITIONER_Practitioner as prp on prp.PRACTITIONER_ID = prc.PRACTITIONER_ID
join dbo.SERVICE_RECORDS           as sr  on (((sr.pracID = prp.PRACTITIONER_ID) and (sr.dos is not null) and (sr.id is not null))
                                              and (sr.state not in (99,199)))
where (
      ((@clientID is null) or (clc.CLIENT_ID = @clientID))
  and (clc.LEA    = 1)
  and (prp.ACTIVE = 1)
  and (sr.siteID is not null)
  and (sr.pracID is not null)
  and (sr.created >= @earliestCreated)
)

group by     
    sr.pracID
  , sr.siteID

exec dbo.PRINT_STATUS_MESSAGE 'Practitioners Update Sites - Update Prac Sites With Any Changes'

/*============================================================
 * Update prac sites with any changes
 * Uses index on prac_sites table
 *===========================================================*/  

insert into dbo.PRACTITIONER_SITES (
    pracID
  , siteID
  , created
  , createdBy
  , active
)
select 
    t1.pracID
  , t1.siteID
  , created   = @today
  , createdBy = @userID
  , active    = 1
from @pracSites                  as t1
left join dbo.PRACTITIONER_SITES as t2 on (((t2.pracID = t1.pracID) and (t2.id is not null)) and (t2.siteID = t1.siteID))
where 
  (t2.id is null)
    
exec dbo.PRINT_STATUS_MESSAGE 'Practitioners Update Sites - Done'

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[PRACTITIONERS_UPDATE_SITES] TO [webuser]
GO
