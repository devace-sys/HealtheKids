USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_ELIGIBILITY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_ELIGIBILITY
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
CREATE FUNCTION [dbo].[PATIENT_ELIGIBILITY]    
(@clientID  INT,    
 @patID     INT,    
 @elgDisp   SMALLINT,    
 @refDate   DATETIME    
)    
RETURNS @recs TABLE(monthDate DATETIME,    
                    eFlag     CHAR(2))     
     
AS    
BEGIN    
    
DECLARE @eDate    AS DATETIME    
DECLARE @eFlag    AS NVARCHAR(1)    
DECLARE @JanFlag  AS NVARCHAR(1)    
DECLARE @FebFlag  AS NVARCHAR(1)    
DECLARE @MarFlag  AS NVARCHAR(1)    
DECLARE @AprFlag  AS NVARCHAR(1)    
DECLARE @MayFlag  AS NVARCHAR(1)    
DECLARE @JunFlag  AS NVARCHAR(1)    
DECLARE @JulFlag  AS NVARCHAR(1)    
DECLARE @AugFlag  AS NVARCHAR(1)    
DECLARE @SepFlag  AS NVARCHAR(1)    
DECLARE @OctFlag  AS NVARCHAR(1)    
DECLARE @NovFlag  AS NVARCHAR(1)    
DECLARE @DecFlag  AS NVARCHAR(1)    
    
/*-------------------------------    
 * Fetch eligibity record for    
 * given clientID, patID    
 *------------------------------*/     
SELECT    
  @eDate    = peg.MEDS_CURRENT,    
  @eFlag    = peg.CURRENT_MONTH_ELIGIBILITY,    
  @JanFlag  = peg.JAN_ELIGIBILITY_INDICATOR,    
  @FebFlag  = peg.FEB_ELIGIBILITY_INDICATOR,    
  @MarFlag  = peg.MAR_ELIGIBILITY_INDICATOR,    
  @AprFlag  = peg.APR_ELIGIBILITY_INDICATOR,    
  @MayFlag  = peg.MAY_ELIGIBILITY_INDICATOR,    
  @JunFlag  = peg.JUN_ELIGIBILITY_INDICATOR,    
  @JulFlag  = peg.JUL_ELIGIBILITY_INDICATOR,    
  @AugFlag  = peg.AUG_ELIGIBILITY_INDICATOR,    
  @SepFlag  = peg.SEP_ELIGIBILITY_INDICATOR,    
  @OctFlag  = peg.OCT_ELIGIBILITY_INDICATOR,    
  @NovFlag  = peg.NOV_ELIGIBILITY_INDICATOR,    
  @DecFlag  = peg.DEC_ELIGIBILITY_INDICATOR     
FROM PATIENTS_CLIENT                AS pac     
LEFT JOIN dbo.PATIENTS_Eligibility  AS peg ON peg.PATIENT_ID = pac.PATIENT_ID    
WHERE pac.CLIENT_ID = @clientID AND pac.PATIENT_ID = @patID    
    
/*-------------------------------    
 * Return derived table    
 *------------------------------*/     
INSERT INTO @recs SELECT * FROM dbo.CALC_ELIGIBILITY(@elgDisp,@refDate,@eDate,@eFlag,@JanFlag,@FebFlag,@MarFlag,@AprFlag,@MayFlag,@JunFlag,@JulFlag,@AugFlag,@SepFlag,@OctFlag,@NovFlag,@DecFlag)    
RETURN    
END    
GO
