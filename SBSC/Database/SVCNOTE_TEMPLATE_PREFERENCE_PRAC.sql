USE SPEDMON


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * SVCNOTE_TEMPLATE_PREFERENCE_PRAC */    
 /*
	Given a practitioner ID, returns data about the most applicable preference template
	for that practitioner.
	
	Default for applicable is prioritized by 
		1: set for practitioner (if template exists specifying such)
		2: set for practitioner group (again, if template exists)
		3: set for clientID (assuming template exists)
		
	If this returns 0 rows, no template has been set that would include this userID.
	
 */
/* ***************************************************************************/     

CREATE FUNCTION dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC 
(	@pracID             bigint	)
RETURNS TABLE
AS
RETURN
(
select top 1 
  case when spt.UseFormattedNotes <> 1 then NULL else snptemp.SvcNote_Preference END as MustUseNote, 
  snptemp.Reason_Template_Applied,
  snptemp.id as TemplateID
from
	practitioner_practitioner pp
	inner join PRACTITIONER_Client pc
		on pp.practitioner_id = pc.practitioner_id
	inner join PRACTITIONER_GROUPS pg 
		on pc.PRACTITIONER_ID = pg.PRACTITIONER_ID
	left outer join [SVCNOTE_PREFERENCE_TEMPLATES] snptemp 
		on (snptemp.pracid = pp.practitioner_id or snptemp.pracID is null)
		and (snptemp.Group_ID = pg.GROUP_ID or snptemp.Group_ID is null)
		and snptemp.Client_ID = pc.CLIENT_ID /* Template preferences -have- to be defined at the client level. */
		and snptemp.Active = 1
	left outer join SVCNOTE_PREFERENCE_TYPES spt on spt.id = snptemp.SvcNote_Preference 
where 
	pp.practitioner_id = @pracID
 
order by 
	snptemp.pracid		desc, 
	snptemp.Group_ID			desc, 
	snptemp.Client_ID			desc
/* In the future, other orderings may be necessary to pick the most applicable preference for a user. 
Template_Rule_Sequence would be used to preferentially set what we wanted to happen. */


)
GO
