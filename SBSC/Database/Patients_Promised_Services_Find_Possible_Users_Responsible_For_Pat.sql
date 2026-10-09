USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Patients_Promised_Services_Find_Possible_Users_Responsible_For_Pat') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Patients_Promised_Services_Find_Possible_Users_Responsible_For_Pat
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Patients_Promised_Services_Find_Possible_Users_Responsible_For_Pat] (
    @clientID                     bigint
  , @patID                        bigint
  , @startDate                    date
  , @endDate                      date
  , @svcTrackingClass             int 
  , @spEdServiceCode              int
  , @orpDocID                     bigint
  , @spEdCaseManagerName          varchar(256)
) 
RETURNS varchar(max)     
BEGIN    

declare @possibleUsersJSON as varchar(max) = '{"possibleUsers":[]}'

declare @possibleUsers as table (
    userLastFirstTitle varchar(256)
  , userID             bigint
)

declare @caseloadEntries as table (
    pracID          bigint
  , groupID         bigint
  , spEdServiceCode int
  , orpDocID        bigint
  , startDate       date
  , endDate         date
  , userID          bigint
  , userLastFirstTitle varchar(1000)
)

declare @possibleGroups as table (
  groupID bigint
)

/*###########################################################################
  # Get caseload entries  
  ###########################################################################*/

insert into @caseloadEntries (
    pracID 
  , groupID
  , spEdServiceCode
  , orpDocID
  , startDate
  , endDate 
  , userID
  , userLastFirstTitle
)

select distinct
    ppc.pracID
  , groupID = pg.GROUP_ID
  , ppces.spEdServiceCode
  , ppces.orpDocID
  , ppces.startDate
  , ppces.endDate
  , userID        = prc.UserID
  , userLastFirstTitle = prc.CONCAT_NAME + ' (' + gg.GROUP_NAME + ')'

from dbo.PRACTITIONER_PATIENT_CASELOAD                   as ppc
join dbo.PRACTITIONER_Practitioner                       as prc  on prc.PRACTITIONER_ID = ppc.pracID
join dbo.PRACTITIONER_GROUPS                             as pg on  pg.PRACTITIONER_ID = ppc.pracID
                                                               and pg.GROUP_TYPE in (1,2)
join dbo.GROUP_Group                                     as gg on gg.GROUP_ID = pg.GROUP_ID
join dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES as ppces on ppces.caseloadEntryID = ppc.id
where (
      (ppc.clientID = @clientID)
  and (ppc.patID = @patID)
  and (prc.ACTIVE = 1)
  and (ppces.active = 1)
)

/*###########################################################################
  # See if there are any caseload entries by service code
  ###########################################################################*/

-- TODO: Enhance to filter by date range prac set in their caseload

insert into @possibleUsers(userLastFirstTitle,userID)
select distinct t1.userLastFirstTitle, t1.userID
from @caseloadEntries as t1
where 
  (t1.spEdServiceCode = @spEdServiceCode)

if exists (select top 1 * from @possibleUsers)
begin
  set @possibleUsersJSON = '{"possibleUsers":' + convert(varchar(max),(select * from @possibleUsers FOR JSON AUTO, INCLUDE_NULL_VALUES)) +'}'
  return @possibleUsersJSON
end

/*###########################################################################
  # Find all possible resposible prac groups
  ###########################################################################*/

insert into @possibleGroups (groupID)
select
  xref.groupID 
from SpEd_Service_GroupID_PlanID_NameID_Data as xref
where 
  (xref.spEdSvcCodeValue = @spEdServiceCode)

/*###########################################################################
  # See if there are any caseload entries by group responsible
  ###########################################################################*/

insert into @possibleUsers(userLastFirstTitle,userID)
select distinct t1.userLastFirstTitle, t1.userID
from @caseloadEntries as t1
join @possibleGroups  as t2 on t2.groupID = t1.groupID

if exists (select top 1 * from @possibleUsers)
begin
  set @possibleUsersJSON = '{"possibleUsers":' + convert(varchar(max),(select * from @possibleUsers FOR JSON AUTO, INCLUDE_NULL_VALUES)) +'}'
  return @possibleUsersJSON
end

return @possibleUsersJSON

END    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[Patients_Promised_Services_Find_Possible_Users_Responsible_For_Pat] TO [webuser]
GO