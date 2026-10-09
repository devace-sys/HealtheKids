USE SPEDMON


/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTE_PRAC_PREF_VALUE_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTE_PRAC_PREF_VALUE_VIEW
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * SVCNOTE_PRAC_PREF_VALUE_VIEW */    
 /*
	Given a practitioner ID, returns the most relevant preference available 
	for that practitioner, along with reference information about that 
	preference (formatted notes, etc). Template preference is given a higher priority 
	than personal preference.
 */
/* ***************************************************************************/    

CREATE FUNCTION dbo.SVCNOTE_PRAC_PREF_VALUE_VIEW 
(	@PracID             bigint	)
RETURNS TABLE
AS
RETURN
(
	select 
	  InputPracID, 
	  COALESCE(MustUseNote,TypePreferenceID) as TypePrefID , 
	  snpt.ShortPrefDesc, 
	  snpt.LongPrefDesc, 
	  snpt.UseFormattedNotes, 
	  prac_pref.Note as prac_note,
	  prac_pref.Reason_Template_applied,
	  prac_pref.PreferenceID,
	  prac_pref.TemplateID
	from 
		dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC_COMPARE(@pracID) as prac_pref
		left outer join SVCNOTE_PREFERENCE_TYPES snpt 
			on snpt.id = COALESCE(MustUseNote,TypePreferenceID)
)
GO