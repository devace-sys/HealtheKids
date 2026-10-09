GO
USE SPEDMON

/*###########################################################################
  # Define period 1 & 2
  ###########################################################################*/ 

DECLARE @Period2Start	VARCHAR(MAX) = CONVERT(VARCHAR, (SELECT TOP 1 FY_START FROM COMPANY_FISCAL_YEARS WHERE GETDATE() >= FY_START AND GETDATE() <= FY_END), 101)
DECLARE @Period2End		VARCHAR(MAX) = CONVERT(VARCHAR, (SELECT TOP 1 FY_END FROM COMPANY_FISCAL_YEARS WHERE GETDATE() >= FY_START AND GETDATE() <= FY_END), 101)

DECLARE @Period1Start	VARCHAR(MAX) = CONVERT(VARCHAR, (SELECT TOP 1 FY_START FROM COMPANY_FISCAL_YEARS WHERE DATEADD(YEAR,-1,GETDATE()) >= FY_START AND DATEADD(YEAR,-1,GETDATE())  <= FY_END), 101)
DECLARE @Period1End		VARCHAR(MAX) = CONVERT(VARCHAR, (SELECT TOP 1 FY_END FROM COMPANY_FISCAL_YEARS WHERE DATEADD(YEAR,-1,GETDATE()) >= FY_START AND DATEADD(YEAR,-1,GETDATE())  <= FY_END), 101)

/*###########################################################################
  # Do not modify below this line
  ###########################################################################*/    

/*============================================================
 * Convert period data to full date time ranges 
 *============================================================*/

SET @Period1Start = @Period1Start + ' 00:00:00'
SET @Period1End   = @Period1End   + ' 23:59:00'
SET @Period2Start = @Period2Start + ' 00:00:00'
SET @Period2End   = @Period2End   + ' 23:59:00'

DECLARE @startDateDOS1 AS datetime  = convert(datetime,@Period1Start)
DECLARE @endDateDOS1   AS datetime  = convert(datetime,@Period1End)
DECLARE @startDateDOS2 AS datetime  = convert(datetime,@Period2Start)
DECLARE @endDateDOS2   AS datetime  = convert(datetime,@Period2End)

/*============================================================
 * Put period data in single column for display purposes
 *============================================================*/

DECLARE @P1 AS VARCHAR(255) = @Period1Start + ' - ' + @Period1End
DECLARE @P2 AS VARCHAR(255) = @Period2Start + ' - ' + @Period2End


/*============================================================
 * Run dbo.RPT_CLAIMS_PAID_BY_DATE_2P for all active LEA 
 * clients excludes detail rows and includes 
 * current LEA rep name
 *============================================================*/

SELECT *
FROM (
  SELECT 
      ltrim(rtrim(isnull(ccr.first_name,'') + ' ' + isnull(ccr.last_name,'')))	AS [District Rep]
    , cc.CLIENT_ID																AS [ID]
    , rc.Client																	AS [Client Name]
    , CASE [RPT_GROUP_ID] WHEN 0 THEN rc.[Group] END							AS [Practitioner Group]
    , rc.[Asmts P1]																AS [Assessments1]
    , rc.[Svcs & Trans P1]														AS [Services & Transportation1]
    , rc.[TCM P1]																AS [TCM1]
    , rc.[Total P1]																AS [Total1]
    , rc.[Asmts P2]																AS [Assessments2]
    , rc.[Svcs & Trans P2]														AS [Services & Transportation2]
    , rc.[TCM P2]																AS [TCM2]
    , rc.[Total P2]																AS [Total2]

  FROM dbo.CLIENTS_Client AS cc

  /*--------------------------------------
   * Run dbo.RPT_CLAIMS_PAID_BY_DATE_2P
   * and output only summary rows
   *-------------------------------------*/

  CROSS APPLY (
    SELECT * 
    FROM dbo.RPT_CLAIMS_PAID_BY_DATE_2P(cc.CLIENT_ID,@startDateDOS1,@endDateDOS1,null,null,@startDateDOS2,@endDateDOS2,null,null,1,1) 
    WHERE (RPT_ROW_TYPE = 2) AND (RPT_GROUP_ID IN (0,1,2))
  ) AS rc

  /*--------------------------------------
   * Include rep data
   *-------------------------------------*/

  LEFT JOIN dbo.CLIENTS_Client_Reps AS ccr ON ccr.id = cc.ClientRepIDLEACurrent

  /*--------------------------------------
   * Limit to active real LEA clients
   *-------------------------------------*/
   
  WHERE 
     (cc.LEA = 1)
     AND (cc.CLIENT_ID != 112)
     AND (rc.[Group] != 'State Errors and Adjustments')
) AS q1

/*--------------------------------------
 * Display in order of rep and client
 *-------------------------------------*/

ORDER BY
    [District Rep]
  , [Client Name]
GO
  
  