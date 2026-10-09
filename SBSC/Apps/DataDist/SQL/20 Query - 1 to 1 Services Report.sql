GO
USE spedmon

declare @sFYCurrent date = (select top 1 FY_START from COMPANY_FISCAL_YEARS where GETDATE() >= FY_START and GETDATE() <= FY_END)
declare @eFYCurrent date = (select top 1 FY_END from COMPANY_FISCAL_YEARS where GETDATE() >= FY_START and GETDATE() <= FY_END)

declare @sFYPrior date = (select top 1 FY_START from COMPANY_FISCAL_YEARS where dateadd(year,-1,GETDATE()) >= FY_START and dateadd(year,-1,GETDATE())  <= FY_END)
declare @eFYPrior date = (select top 1 FY_END from COMPANY_FISCAL_YEARS where dateadd(year,-1,GETDATE()) >= FY_START and dateadd(year,-1,GETDATE())  <= FY_END)

declare @priorFYDEF varchar(9) = (select top 1 year12 from dbo.DATE_IN_WHAT_FY(@sFYPrior,null) )
declare @currentFYDEF varchar(9) = (select top 1 year12 from dbo.DATE_IN_WHAT_FY(@sFYcurrent,null) )

;WITH tProcs AS (
      SELECT procedure_id
      FROM CLAIM_Procedures
      WHERE PROCEDURE_CODE IN ('T1002','T1003','T1004')
),

patientDayTotals as
(
     /* Minute and dollar amounts, subtotaled by patient, service date, and procedure */
     /* We also filter by current and prior fiscal year here */
     select 
          cc.CLIENT_ID ,cc.PATIENT_ID, cc.SERVICE_DATE, cc.PROCEDURE_ID, 
          SUM(sr.numMins) as minuteTotal, 
          SUM(ISNULL(cca.AMOUNT_PAID*cca.EDSPERCENT,0)) as paymentTotal 
     
     from CLAIM_Claim cc
     inner join tProcs 
          on cc.PROCEDURE_ID = tProcs.PROCEDURE_ID
     inner join SERVICE_RECORD_CLAIMS src 
          on cc.CLAIM_ID = src.claimID
     inner join SERVICE_RECORDS sr 
          on src.svcRecID = sr.id

     left outer join CLAIM_Claim_Adjudication cca 
          on cca.CLAIM_ID = cc.CLAIM_ID

     where 
          cc.SERVICE_DATE >= @sFYPrior 
          and cc.SERVICE_DATE <= @eFYCurrent
          
     group by cc.CLIENT_ID, cc.PATIENT_ID, cc.SERVICE_DATE, cc.PROCEDURE_ID
),

patientFYTotals as
(
     /* Do our next tier of sums, taking daily amounts and totaling by fiscal year */
     select pdt.CLIENT_ID, pdt.PATIENT_ID, PROCEDURE_ID, cfy.FY_DEFINITION, 
     SUM(pdt.minuteTotal) as minuteTotal, 
     SUM(pdt.paymentTotal) as paymentTotal 
     
     from patientDayTotals pdt
     inner join COMPANY_FISCAL_YEARS cfy 
          on pdt.SERVICE_DATE >= cfy.FY_START 
          and pdt.SERVICE_DATE <= cfy.FY_END
          
     /* Note that this is the last major GROUP_BY we have to use */
     group by pdt.CLIENT_ID, pdt.PATIENT_ID, pdt.PROCEDURE_ID, cfy.FY_DEFINITION
),

patientFYTransform as
(
     /* push the data out into seperate columns based on procedure and fiscal year */ 
     /* (for clarity's sake this is done seperate from the rollup) */
     select pft.CLIENT_ID, pft.PATIENT_ID, paymentTotal
          ,CASE when pft.fy_definition = @currentFYDEF and cp.procedure_code = 'T1002'
              then minuteTotal else 0 end as [curFY_T1002]
              
          ,CASE when pft.fy_definition = @currentFYDEF and cp.procedure_code = 'T1003'
              then minuteTotal else 0 end as [curFY_T1003]
          
          ,CASE when pft.fy_definition = @currentFYDEF and cp.procedure_code = 'T1004'
              then minuteTotal else 0 end as [curFY_T1004]
              
          ,CASE when pft.FY_DEFINITION = @currentFYDEF
              then paymentTotal else 0 end as [curFY_Amt]
     
          ,CASE when pft.fy_definition = @priorFYDEF and cp.procedure_code = 'T1002'
              then minuteTotal else 0 end as [priFY_T1002]
              
          ,CASE when pft.fy_definition = @priorFYDEF and cp.procedure_code = 'T1003'
              then minuteTotal else 0 end as [priFY_T1003]
          
          ,CASE when pft.fy_definition = @priorFYDEF and cp.procedure_code = 'T1004'
              then minuteTotal else 0 end as [priFY_T1004]
     
          ,CASE when pft.FY_DEFINITION = @priorFYDEF
              then paymentTotal else 0 end as [prevFY_Amt]
     
     from patientFYTotals pft
     inner join CLAIM_Procedures cp 
          on pft.PROCEDURE_ID = cp.PROCEDURE_ID
),


patientFYRollup as
(
     /* We do our sum/grouping rollup from the transform data */
     /* this should be pretty trivial, since our transform means 
      * that only one row should have non-zero values for each column*/
     select pft.CLIENT_ID, pft.PATIENT_ID
          ,SUM(pft.curFY_Amt) AS curFY_Amt 
          ,SUM(curFY_T1002) as curFY_T1002
          ,SUM(curFY_T1003) as curFY_T1003
          ,SUM(curFY_T1004) as curFY_T1004
          
          ,SUM(pft.prevFY_Amt) AS priFY_Amt
          ,SUM(priFY_T1002) as priFY_T1002
          ,SUM(priFY_T1003) as priFY_T1003
          ,SUM(priFY_T1004) as priFY_T1004

     from patientFYTransform pft

     /* small grouping here to make the rollup work - 
      * note that we don't have to use any further GROUP BY statements 
      * because the CTE wraps the inner workings */
     group by  pft.CLIENT_ID, pft.PATIENT_ID
),
clientPatientDataLink as
(
     /* Link in additional information that we didn't need when we were doing math */
     select 
          ccr.first_name
          ,ccr.last_name
          ,cc.CLIENT_NAME
          ,pp.CONCAT_NAME
          ,pp.DATE_OF_BIRTH
          ,pfr.*
     
     from patientFYRollup pfr
     inner join CLIENTS_Client cc 
          on pfr.CLIENT_ID = cc.CLIENT_ID
     inner join CLIENTS_Client_Reps ccr 
          on ccr.id = cc.ClientRepIDLEACurrent
     inner join PATIENTS_Patient pp 
          on pfr.PATIENT_ID = pp.PATIENT_ID
)

/* Finalize layout, formatting and column names so everything looks purty for humans */
select 
     last_name + ', ' + first_name				AS Consultant
     ,CLIENT_NAME								AS Client
     ,CONCAT_NAME								AS Patient
     ,PATIENT_ID								AS [Patient ID]
     ,CONVERT(VARCHAR(10),DATE_OF_BIRTH,101)	AS [DOB]
     ,CONVERT(VARCHAR(MAX),curFY_T1002)			AS [Procedure T1002 (RN)(Current)(Minutes)]
     ,CONVERT(VARCHAR(MAX),curFY_T1003)			AS [Procedure T1003 (LVN)(Current)(Minutes)]
     ,CONVERT(VARCHAR(MAX),curFY_T1004)			AS [Procedure T1004 (THCA)(Current)(Minutes)]
     ,'$' + CONVERT(VARCHAR(50),
            CONVERT(MONEY,curFY_Amt))			AS [Amount (Current FY)]

     ,CONVERT(VARCHAR(MAX),priFY_T1002)			AS [Procedure T1002 (RN)(Prior)(Minutes)]
     ,CONVERT(VARCHAR(MAX),priFY_T1003)			AS [Procedure T1003 (LVN)(Prior)(Minutes)]
     ,CONVERT(VARCHAR(MAX),priFY_T1004)			AS [Procedure T1004 (THCA)(Prior)(Minutes)]
     ,'$' + CONVERT(VARCHAR(50),
            CONVERT(MONEY,priFY_Amt))			AS [Amount (Prior FY)]
  
  from clientPatientDataLink 
GO
