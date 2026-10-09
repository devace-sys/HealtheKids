USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_SITES_GET') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_SITES_GET
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_SITES_GET] (
  @patID BIGINT
)    

RETURNS TABLE

 /***************************************************************************    
  * PATIENT_SITES_GET */    
 /**    
  * Returns a table of sites for a given patient
  *    
  * @return                 Table of patient site data
  ***************************************************************************/     
  
AS RETURN(
  select 
 	  PATIENT_ID = @patID
	, ps.PATIENT_SCHOOL_ID    
	, [START_DATE] = convert(datetime,(convert(date,ps.START_DATE)))
    , [END_DATE]   = convert(datetime,(convert(date,(isnull(ps.END_DATE,getdate())))))
    , ps.SITE_ID
  from dbo.PATIENTS_School as ps 
  where (
        (ps.PATIENT_ID = @patID)
	and (ps.SITE_ID is not null)
	and (ps.START_DATE is not null)
	and (ps.PATIENT_SCHOOL_ID is not null)
  ) /* Index predicate */
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_SITES_GET] TO [webuser]
GO
