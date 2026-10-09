USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VITALS_MEASUREMENTS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VITALS_MEASUREMENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].PATIENT_VITALS_MEASUREMENTS_VIEW (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @patID               BIGINT
  , @active              BIT 
  , @recID               BIGINT 
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VITALS_MEASUREMENTS_VIEW */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN

	select top (dbo.CONST_MAX_ROWS())
        id                      = pvm.id                      
      , clientID                = pvm.clientID
      , patID					= pvm.patID
	  ,	measurementDate			= pvm.measurementDate
	  , measurementDateStr		= dbo.RPT_DATE_FMT(pvm.measurementDate)		
	  , measurementDateYMD      = dbo.RPT_DATE_FMT_YYYY_MM_DD(pvm.measurementDate)
	  ,	measurmentTime			= pvm.measurmentTime
	  , measurmentTimeStr       = dbo.RPT_TIME_FMT(pvm.measurmentTime,0)
	  , measurmentTimeHMS       = dbo.RPT_TIME_FMT_HH_MM_SS(pvm.measurmentTime,0)
	  ,	temp					= pvm.temp
	  , tempStr					= isnull(cast(pvm.temp as varchar(10)), '')		
	  ,	pulseRate				= pvm.pulseRate
	  , pulseRateStr			= isnull(cast(pvm.pulseRate as varchar(10)), '')	
	  ,	respiratoryRate	        = pvm.respiratoryRate 
	  , respiratoryRateStr		= isnull(cast(pvm.respiratoryRate as varchar(10)), '')
	  ,	bloodPressureSys		= pvm.bloodPressureSys 
	  , bloodPressureSysStr		= isnull(cast(pvm.bloodPressureSys as varchar(10)), '')
	  ,	bloodPressureDia		= pvm.bloodPressureDia
	  , bloodPressureDiaStr		= isnull(cast(pvm.bloodPressureDia as varchar(10)), '') 
	  ,	o2Saturation			= pvm.o2Saturation 
	  , o2SaturationStr			= isnull(cast(pvm.o2Saturation as varchar(10)), '') 
	  , bloodGlucose			= pvm.bloodGlucose
	  , bloodGlucoseStr			= isnull(cast(pvm.bloodGlucose as varchar(10)), '') 
	  ,	heightFt				= pvm.heightFt
	  , heightFtStr				= isnull(cast(pvm.heightFt as varchar(10)), '') 
	  ,	heightInch				= pvm.heightInch
	  , heightInchStr			= isnull(cast(pvm.heightInch as varchar(10)), '') 
	  ,	weightlb				= pvm.weightlb
	  , weightlbStr				= isnull(cast(pvm.weightlb as varchar(10)), '') 
      
    from dbo.PATIENT_VITALS_MEASUREMENTS     as pvm
    join dbo.CLIENTS_CLIENT                  as clc   on clc.CLIENT_ID        = pvm.clientID

    where (
		  ((@clientID            is null) or (pvm.clientID                    = @clientID))
	  and ((@patID				 is null) or (pvm.patID						  = @patID))
      and ((@recID               is null) or (pvm.id                          = @recID))
      and ((@active              is null) or (pvm.active                      = @active))    
   )
 
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VITALS_MEASUREMENTS_VIEW] TO [webuser]
GO  
