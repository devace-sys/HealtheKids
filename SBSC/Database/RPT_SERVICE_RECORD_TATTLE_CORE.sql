USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_SERVICE_RECORD_TATTLE_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_SERVICE_RECORD_TATTLE_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[RPT_SERVICE_RECORD_TATTLE_CORE]     
(@clientID  int, 
 @groupID   int, 
 @pracID    int,   
 @startDate datetime,    
 @endDate   datetime)     
 returns @tattle table(Client              nvarchar(max),     
                       [Start Date]        varchar(20),     
                       [End Date]          varchar(20),
                       [Practitioner Type] nvarchar(max),
                       [Reporting Group]   nvarchar(max),
                       [Practitioner ID]   int,
                       [Last Name]         nvarchar(100),
                       [First Name]        nvarchar(100))
                       
/***************************************************************************
 * RPT_SERVICE_RECORD_TATTLE_CORE */
/**
 * For a given client id (or all clients) and date range displays all
 * active practitioners who have not entered or submitted work
 *
 * @param  clientID        ClientID 
 * @param  groupID         GroupID   
 * @param  pracID          PractitionerID     
 * @param  startDate       Start date (required)    
 * @param  endDate         End date (required)
 * @return                 Table    
 ***************************************************************************/     
                       
begin

declare @startDateStr as varchar(20)
declare @endDateStr   as varchar(20)
declare @dateFormat   as int

/*-------------------------------------------------
 * Format our dates for display
 * see http://www.mssqltips.com/tip.asp?tip=1145
 * for a list of formats.
 *------------------------------------------------*/

set @dateFormat   = 101 
set @startDateStr = convert(varchar, @startDate , @dateFormat) 
set @endDateStr   = convert(varchar, @endDate   , @dateFormat)

/*-------------------------------
 * Generate records
 *------------------------------*/

insert into @tattle

select
  Client,
  [Start Date],
  [End Date],
  dg.group_name            as [Practitioner Type],
  isnull(rg.group_name,'') as [Reporting Group],
  [Practitioner ID],
  [Last Name],
  [First Name] 

from
(

  select
    c.CLIENT_NAME     as Client,
    @startDateStr     as [Start Date],
    @endDateStr       as [End Date],
    p.practitioner_ID as [Practitioner ID],
    p.LAST_NAME       as [Last Name],
    p.FIRST_NAME      as [First Name] 
  from CLIENTS_Client            as c
  join PRACTITIONER_Client       as pc on  pc.CLIENT_ID       = c.CLIENT_ID
                                       and c.CLIENT_ID       != 112
                                       and c.LEA             != 0
                                       and ((pc.DATE_START   <= @endDate)
                                       or  (pc.DATE_START    is null))                                     
  join PRACTITIONER_Practitioner as p  on  p.PRACTITIONER_ID  = pc.PRACTITIONER_ID 
                                       and p.ACTIVE = 1
                                       and p.FIRST_NAME not like '%ADJUST%'                                    
  left join SERVICE_RECORDS            as s  on  s.pracID           = pc.PRACTITIONER_ID                                           
                                             and s.clientID         = c.client_ID
                                             and s.dos between @startDate and @endDate                                             
                                             and (s.state <> dbo.CONST_SVC_REC_STATE_DEL())
                                             and (s.state <> dbo.CONST_SVC_REC_STATE_CIF())
  left join REPORTS_EXCLUDE            as re on  re.pracID = p.PRACTITIONER_ID
                                             and re.reptID = 6 /* TODO: Make a const */
  where
    ((s.id is null)  and 
     (re.id is null) and 
    ((@clientID is null) or (c.CLIENT_ID       = @clientID)) and
    ((@pracID   is null) or (p.PRACTITIONER_ID = @pracID)))  
) as q1

join (
  select 
      pg.PRACTITIONER_ID
    , gg.GROUP_NAME 
  from PRACTITIONER_GROUPS as pg
  join GROUP_Group         as gg on gg.GROUP_ID = pg.GROUP_ID
  where gg.GROUP_TYPE in (1,2) and gg.GROUP_ID <> 152 and ((@groupID  is null) or (gg.Group_ID = @groupID))
) as dg on dg.PRACTITIONER_ID =  q1.[Practitioner ID]

left join(
  select 
      pg.PRACTITIONER_ID
    , gg.GROUP_NAME 
  from PRACTITIONER_GROUPS as pg
  join GROUP_Group         as gg on gg.GROUP_ID = pg.GROUP_ID
  where gg.GROUP_TYPE in (3,5)
) as rg on rg.PRACTITIONER_ID =  q1.[Practitioner ID]

order by

  [Client]            asc,
  [Practitioner Type] asc,
  [Last Name]         asc, 
  [First Name]        asc                                           

return
end 
GO