USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW] (
    @userID                                   BIGINT
  , @userGroup                                INT  
  , @userRank                                 INT      
  , @clientID                                 BIGINT
  , @pracID                                   BIGINT 
  , @patID                                    BIGINT 
  , @dos                                      DATETIME
  , @getAllClientJournalsIfPracAllowed        BIT 
  , @recID                                    BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW */    
 /**    
  * Returns a list of open journals
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(	
	---------------------------------------------------------------------
	-- Is prac a supervisor
	--------------------------------------------------------------------- 
	
	with
	cte_p1
	as
	(
	  select top 1
		numOfGroupsPracCanSupervise = count(ggdss.ID)
	  , clientID = @clientID
	  from dbo.PRACTITIONER_Client                       as pc
	  join dbo.PRACTITIONER_GROUPS                       as pg on pg.PRACTITIONER_ID = pc.PRACTITIONER_ID
	  join dbo.GROUP_GROUP_DIRECT_SUPERVISED_SUPERVISOR  as ggdss on ggdss.SUPERVISING_GROUP_ID = pg.GROUP_ID
	  where ( 
		      (1=1)
		  and (pc.CLIENT_ID = @clientID)
		  and (
				((@pracID is not null) and (pc.PRACTITIONER_ID = @pracID))
			 or ((@pracID is null)     and (@getAllClientJournalsIfPracAllowed = 1)) -- this is the case for admins and consultants
		  )
	  )
	)

    ---------------------------------------------------------------------
	-- All journals
	--------------------------------------------------------------------- 
	,
	cte_p2
	as
	(
	  select distinct
	  
		  sj2.id
		, sj2.dos
		, sj2.patID
		, sj2.name
		, sj2.patName
		, sj2.attendance
		, sj2.openingPracName
		, source = 1

	  from cte_p1 as p1
	  cross apply (
	    select 
	  	  sj1.id
	  	, dos = dbo.RPT_DATE_FMT(sj1.dos)
	  	, sj1.patID
		, patName = pap.CONCAT_NAME
		, attendance = iif(sj1.patAbsent = 1, 'Absent', 'Present')
		, openingPracName = pr.CONCAT_NAME
	  	, name = dbo.RPT_DATE_FMT(sj1.dos) + ' - (' + iif(sj1.patAbsent = 1, 'Absent', 'Present') + ') - ' + pap.CONCAT_NAME 
	    from [dbo].[SvcJournals] as sj1
	    join dbo.PATIENTS_Patient   as pap on pap.PATIENT_ID      = sj1.patID
		left join dbo.PRACTITIONER_Practitioner as pr on pr.PRACTITIONER_ID = sj1.openingPracId
	    where 
	  	    (sj1.clientID = p1.clientID)
	    and (sj1.completed = 0)
	    and (sj1.active = 1)
	    and (sj1.dos >= dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,getdate())))
	    and ((@clientID  is null) or (sj1.clientID  = @clientID))
	    and ((@patID     is null) or (sj1.patID     = @patID))
	    and ((@dos       is null) or (sj1.dos       = @dos))
	    and ((@recID     is null) or (sj1.id        = @recID))
		and (@getAllClientJournalsIfPracAllowed = 1) 
	  ) as sj2
	  where (p1.numOfGroupsPracCanSupervise != 0)
	)

	---------------------------------------------------------------------
	-- Practitioner's journals
	--------------------------------------------------------------------- 
	,
	cte_p3
	as
	(
	  select distinct
    
		  sj.id
		, dos = dbo.RPT_DATE_FMT(sj.dos)
		, sj.patID
		, name = dbo.RPT_DATE_FMT(sj.dos) + ' - (' + iif(sj.patAbsent = 1, 'Absent', 'Present') + ') - ' + pap.CONCAT_NAME 
		, patName = pap.CONCAT_NAME
		, attendance = iif(sj.patAbsent = 1, 'Absent', 'Present')
		, openingPracName = pr.CONCAT_NAME
		, source = 2

	  from dbo.SvcJournals as sj
	  join dbo.PATIENTS_Patient   as pap on pap.PATIENT_ID      = sj.patID
      left join dbo.PRACTITIONER_Practitioner as pr on pr.PRACTITIONER_ID = sj.openingPracId
	  where (
	  	(exists (select top 1 * from
	  				dbo.SvcJournal_Event_Entries  as sjee
	  			where sjee.journalID = sj.id and sjee.pracID = @pracID
	  	)
	  	or
	  	sj.openingPracId = @pracID
	  	) 
	  and ((sj.active = 1)
	  and ((@clientID  is null) or (sj.clientID  = @clientID))
	  and ((@patID     is null) or (sj.patID     = @patID))
	  and ((@dos       is null) or (sj.dos       = @dos))
	  and (sj.completed = 0)
	  and ((@recID     is null) or (sj.id        = @recID)))
	  and ((@getAllClientJournalsIfPracAllowed = 0))   
	  )
	)
 
	---------------------------------------------------------------------
	-- Final Union
	--------------------------------------------------------------------- 
	select * from cte_p2
	union
	select * from cte_p3
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SVCJOURNAL_JOURNAL_USER_OPEN_JOURNALS_VIEW] TO [webuser]
GO  
