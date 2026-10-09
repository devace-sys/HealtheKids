
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC_COMPARE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC_COMPARE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * SVCNOTE_TEMPLATE_PREFERENCE_PRAC_COMPARE */   
 
 /*
	Individual-Template Conflicts: 
	
	Compare the current preference of the practitioner to the template(s) that could apply to that practitioner.
 */ 

/* ***************************************************************************/     

CREATE FUNCTION dbo.SVCNOTE_TEMPLATE_PREFERENCE_PRAC_COMPARE
(	@PracID             bigint	)
RETURNS TABLE
AS
RETURN
(
	select @PracID as InputPracID,  spp.*, stpp.MustUseNote as MustUseNote, stpp.Reason_Template_applied, stpp.TemplateID
	from
	(select @PracID as id) prc
	outer apply SVCNOTE_PRAC_PREF(@PRACID) spp
	outer apply SVCNOTE_TEMPLATE_PREFERENCE_PRAC(@pracID) stpp
)

GO