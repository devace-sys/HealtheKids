USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CRCS_PROGRAM_INFO_NUM_TRIPS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CRCS_PROGRAM_INFO_NUM_TRIPS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CRCS_PROGRAM_INFO_NUM_TRIPS] ( 
	   @clientID          BigInt 
	 , @fiscalYearID      Bigint
)
     
RETURNS TABLE  

AS RETURN(

select 
 
      fiscalYearID = @fiscalYearID
    , clientID     = @clientID 
    , allPats      = sum(isnull(q2.numTrips,0))
    , mcalPats     = sum(iif( (q2.isElig = 1), isnull(q2.numTrips,0) ,0)) 
 
  from dbo.COMPANY_FISCAL_YEARS as fy
 
  outer apply (
    select
       q1.numTrips 
     , isElig = convert(bit,(iif((q1.patBIC != N''),1,0)))
 
    from
    (
      select
 
         patBIC   = isnull(pap.BIC,N'')
       , numTrips = dbo.CALC_TOTAL_TRIPS_8 (sr.trip1Start, sr.trip1End, sr.trip2Start, sr.trip2End, sr.trip3Start, sr.trip3End, sr.trip4Start, sr.trip4End)   
       
      from dbo.SERVICE_RECORDS  as sr 
      join dbo.PATIENTS_Patient as pap on pap.PATIENT_ID = sr.patID
      where ( 
            (sr.clientID = @clientID)
        and (sr.patID is not null)
        and (sr.pracGrpSvcClsNameID is not null)
        and (sr.svcType = 3)
        and (sr.dos between fy.FY_START and fy.FY_END)
        and (sr.state not in (99,199))
        and (sr.patAbsent = 0)
      )
    ) as q1
  ) as q2
 
  where (fy.ID = @fiscalYearID)


) 
     
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CRCS_PROGRAM_INFO_NUM_TRIPS] TO [webuser]
GO