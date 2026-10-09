USE SPEDMON


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTE_PRAC_PREF') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTE_PRAC_PREF
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * SVCNOTE_PRAC_PREF */    
 /*
	Given a practitioner ID, returns data about the unexpired note preferences
	for that practitioner, including whether the preference can be edited by 
	the user.
 */
/* ***************************************************************************/     

CREATE FUNCTION dbo.SVCNOTE_PRAC_PREF 
(	@PracID             bigint	)
RETURNS TABLE
AS
RETURN
(
select top 1
	snpp.id as PreferenceID,
	snpp.PracID, 
	snpt.id as TypePreferenceId, 
	CASE 
		WHEN snpp.SetByUser = (select userID from practitioner_practitioner where practitioner_id = @pracid) 
			THEN 1 
		else 0 
	END  as PracCanModify,
	snpp.note
from 
	SVCNOTE_PRAC_PREFERENCE snpp 
	inner join SVCNOTE_PREFERENCE_TYPES snpt 
		on snpt.id = snpp.SvcNote_TypePreference
where 
	snpp.Expired_Date is null
	and snpp.pracid = @PracID
	
order by Created_Date desc

)
GO