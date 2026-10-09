USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_EXPECTED_SERVICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_EXPECTED_SERVICES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_EXPECTED_SERVICES_VIEW] (
   @userID    BIGINT    
 , @userGroup INT
 , @userRank  INT
 , @clientID  BIGINT
 , @pracID    BIGINT
 , @patID     BIGINT
) 

RETURNS TABLE

  /***************************************************************************    
  * PATIENTS_EXPECTED_SERVICES_VIEW */    
 /**    
  * Returns a table of caseload records that match the given parameters    
  *    
  * @param  userID          Callers user id    
  * @param  userGroup       Callers user group    
  * @param  userRank        Callers user rank    
  * @param  clientID        Required.  ID of client    
  * @param  pracID          Practitioner id
  * @param  patID           ID of the patient    
  * @return                 Table of patient data    
  ***************************************************************************/ 
  
AS RETURN( 
	select top (dbo.CONST_MAX_ROWS()) *
	from
	(
		select  
		    id           = pes.ID
		  , startDateStr = dbo.RPT_DATE_FMT_YYYY_MM_DD(pes.[START_DATE])
		  , minsAnn      = pes.ANNUAL_MINUTES
		  , minsInd      = pes.INDIVIDUAL_MINUTES
		  , minsGrp      = pes.GROUP_MINUTES
		  , weekDaysJSON = pes.DAYS_OF_WEEK_JSON
		  , planType     = pes.PLAN_TYPE
		from dbo.PATIENTS_EXPECTED_SERVICES                        as pes
		join dbo.PRACTITIONER_Practitioner                         as prp on prp.PRACTITIONER_ID = @pracID
		join dbo.PRACTITIONER_Client                               as pc  on  pc.CLIENT_ID = @clientID
		                                                                  and pc.PRACTITIONER_ID = prp.PRACTITIONER_ID
		join dbo.PRACTITIONER_GROUPS                               as pg  on  pg.PRACTITIONER_ID = prp.PRACTITIONER_ID
		                                                                  and pg.GROUP_TYPE in (1,2)
		join dbo.GROUP_Group                                       as gg  on gg.GROUP_ID = pg.GROUP_ID
		                                                                  and gg.GROUP_TYPE in (1,2)
		join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as png on png.GROUP_ID = gg.GROUP_ID
		  
		where (
		      (pes.CLIENT_ID                        = @clientID)
		  and (pes.PATIENT_ID                       = @patID)
		  and (pes.GROUP_SERVICE_CLASS_PARTITION_ID = png.GROUP_SERVICE_CLASS_PARTITION_ID)
		  and (pes.GROUP_SERVICE_CLASS_NAME_ID      = png.GROUP_SERVICE_CLASS_NAME_ID)
	    )
	) as pess		
	order by pess.ID desc 		
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_EXPECTED_SERVICES_VIEW] TO [webuser]
GO   
