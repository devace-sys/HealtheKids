USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITONERS_VIEW_LEA_MAA_XREF_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITONERS_VIEW_LEA_MAA_XREF_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PRACTITONERS_VIEW_LEA_MAA_XREF_CORE](
  @clientID  INT,
  @groupType INT,
  @active    BIT)

RETURNS TABLE

/***************************************************************************
 * PRACTITIONERS_VIEW_LEA_MAA_XREF */
/**
 * Returns a table of practitioners that are common between LEA and MAA
 * Each client has one or more practitioners.
 *
 * @param  clientID        ID of client
 * @param  groupType       1 or 2
 * @param  active          LEA active
 * @return                 Table of practitioner data
 ***************************************************************************/

AS RETURN(

/*-------------------------------
 * Retrieve records
 *------------------------------*/

  select top (dbo.CONST_MAX_ROWS())
    q2.*
  from
  (
    select q1.*,
    ISDATE(q1.[MAA Active Detail]) as [MAA Active]
    from
    (
      select
        leaprac.clientID      as [LEA Client ID],
        leaprac.clientName    as [LEA Client],
        leaprac.id            as [LEA Practitioner ID],
        leaprac.name          as [LEA Practitioner],
        leaprac.groupIDDisp   as [LEA Practitioner Group ID],
        leaprac.groupNameDisp as [LEA Practitioner Group Name],
        leapracgrp.GROUP_TYPE as [LEA Practitioner Group Type],
        leaprac.active        as [LEA Active],
        maaprac.DistrictCDS   as [MAA Client ID],
        maaclt.District       as [MAA Client],
        maaprac.StaffID       as [MAA Participant ID],
        maaprac.Name          as [MAA Participant],
        maaprac.Activity      as [MAA Active Detail]
        from Spedmon.dbo.PRACTITONERS_VIEW_CORE(0,
                                                @clientID,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null, 
                                                @active
												,null
												,null
												,null) as leaprac
        left join SPEDMON..GROUPS_VIEW_CORE_2(12)        as leapracgrp on leapracgrp.GROUP_ID = leaprac.groupIDDisp
        join PractiCal.dbo.NewStaff                      as maaprac    on maaprac.Email       = leaprac.email
        join PractiCal.dbo.Districts                     as maaclt     on maaclt.DistrictCDS  = maaprac.DistrictCDS
      ) as q1
  ) as q2
  where (1=1)
  and   ((@groupType is null) or ([LEA Practitioner Group Type] = @groupType))
 order by [LEA Client], [LEA Practitioner]
)

GO

/*-------------------------------
 * User Permissions
 *
 * Note: This script also
 * requires the permissions
 * that are setup in:
 *
 * spedmon\batch\restore\
 * restore-partner-databases.sql
 *------------------------------*/

GRANT SELECT ON  [dbo].[PRACTITONERS_VIEW_LEA_MAA_XREF_CORE] TO [webuser]
GO
