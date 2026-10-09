USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE
GO

/***************************************************************************
 * RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE */
/**
 *
 ***************************************************************************/

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE] ( 
    @clientID BIGINT
)    

RETURNS 
TABLE 
AS
RETURN
(

with
cte_p1
as
(

select 
    t1.* 
  , pr2.*
  , pr3.*
  , pr4.*
  , pr6.*
  , pr9.*
  , pr11.*

from dbo.PATIENT_PROMISED_SERVICES_RECENT_IEPS_DATA_CORE (@clientID,null) as t1

/* Calculate sub total plr for mental health */

cross apply (
  select top 1
    plrAmt2 = (pr.RATE_ASSMT * t1.numOfMentalHealthSvcsReqAssmt)
  from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr
  where 
    (pr.GROUP_SERVICE_CLASS_NAME_ID = 2)
) as pr2

/* Calculate sub total plr for health */

cross apply (
  select top 1
    plrAmt3 = (pr.RATE_ASSMT * t1.numOfHealthSvcsReqAssmt)
  from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr
  where 
    (pr.GROUP_SERVICE_CLASS_NAME_ID = 3)
) as pr3

/* Calculate sub total plr for OT */

cross apply (
  select top 1
    plrAmt4 = (pr.RATE_ASSMT * t1.numOfOTSvcsReqAssmt)
  from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr
  where 
    (pr.GROUP_SERVICE_CLASS_NAME_ID = 4)
) as pr4

/* Calculate sub total plr for pt */

cross apply (
  select top 1
    plrAmt6 = (pr.RATE_ASSMT * t1.numOfPTSvcsReqAssmt)
  from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr
  where 
    (pr.GROUP_SERVICE_CLASS_NAME_ID = 6)
) as pr6

/* Calculate sub total plr for speech */

cross apply (
  select top 1
    plrAmt9 = pr.RATE_ASSMT * t1.numOfSpeechSvcsReqAssmt
  from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr
  where 
    (pr.GROUP_SERVICE_CLASS_NAME_ID = 9)
) as pr9

/* Calculate sub total plr for om */

cross apply (
  select top 1
    plrAmt11 = (pr.RATE_ASSMT * t1.numOfOMSvcsReqAssmt)
  from dbo.GROUP_GROUP_SERVICE_CLASS_POTENTIAL_RATES as pr
  where 
    (pr.GROUP_SERVICE_CLASS_NAME_ID = 11)
) as pr11
)

select 

  p1.* 
  
  /* Calc tot num of missing assmts */

  , totNumReqAssmt = p1.numOfHealthSvcsReqAssmt
                   + p1.numOfMentalHealthSvcsReqAssmt
	  			   + p1.numOfOTSvcsReqAssmt
				   + p1.numOfPTSvcsReqAssmt
				   + p1.numOfSpeechSvcsReqAssmt
				   + p1.numOfOMSvcsReqAssmt

  /* Calc total potential lost reimbursement */

  , totPlrAmt = p1.plrAmt2
              + p1.plrAmt3
              + p1.plrAmt4
              + p1.plrAmt6
              + p1.plrAmt9
              + p1.plrAmt11

from cte_p1 as p1

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_PATIENT_PROMISED_SERVICES_MISSING_ASSESSMENTS_CORE] TO [webuser]
GO
