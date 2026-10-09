USE [spedmon]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FY_TOTALS_LAST_7_ONTHEFLY') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FY_TOTALS_LAST_7_ONTHEFLY
GO

CREATE FUNCTION [dbo].[FY_TOTALS_LAST_7_ONTHEFLY](@refdate date, @clientID bigint, @leaIsActive bit, @numyrs int)
RETURNS TABLE
AS RETURN
(
  SELECT TOP (dbo.CONST_MAX_ROWS())
       CLIENT_NAME
      ,CLIENT_ID
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY0] AS [c3(_col_label)]
      ,[FY0_TOT_ADJS] AS c3
      ,'Total Disbursed ' + [FY0] AS [c4(_col_label)]
      ,[FY0_TOT_DISB] AS c4
      ,'Total Payments Authorized ' + [FY0] AS [c5(_col_label)]
      ,[FY0_TOT_DISB] + [FY0_TOT_STATE_FEES] AS c5
      ,'Totals Fees Deducted ' + [FY0] AS [c6(_col_label)]
      ,[FY0_TOT_STATE_FEES] AS c6
      ,'Total Value, Services Rendered ' + [FY0] AS [c7(_col_label)]
      ,[FY0_TOT_SVCS] AS c7    
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY1] AS [c8(_col_label)]
      ,[FY1_TOT_ADJS] AS c8
      ,'Total Disbursed ' + [FY1] AS [c9(_col_label)]
      ,[FY1_TOT_DISB] AS c9
      ,'Total Payments Authorized ' + [FY1] AS [c10(_col_label)]
      ,[FY1_TOT_DISB] + [FY1_TOT_STATE_FEES] AS c10
      ,'Totals Fees Deducted ' + [FY1] AS [c11(_col_label)]
      ,[FY1_TOT_STATE_FEES] AS c11
      ,'Total Value, Services Rendered ' + [FY1] AS [c12(_col_label)]
      ,[FY1_TOT_SVCS] AS c12   
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY2] AS [c13(_col_label)]
      ,"FY2_TOT_ADJS" AS c13
      ,'Total Disbursed ' + [FY2] AS [c14(_col_label)]
      ,"FY2_TOT_DISB" AS c14
      ,'Total Payments Authorized ' + [FY2] AS [c15(_col_label)]
      ,[FY2_TOT_DISB] + [FY2_TOT_STATE_FEES] AS c15
      ,'Totals Fees Deducted ' + [FY2] AS [c16(_col_label)]
      ,"FY2_TOT_STATE_FEES" AS c16
      ,'Total Value, Services Rendered ' + [FY2] AS [c17(_col_label)]
      ,"FY2_TOT_SVCS" AS c17      
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY3] AS [c18(_col_label)]
      ,"FY3_TOT_ADJS" AS c18
      ,'Total Disbursed ' + [FY3] AS [c19(_col_label)]
      ,"FY3_TOT_DISB" AS c19
      ,'Total Payments Authorized ' + [FY3] AS [c20(_col_label)]
      ,[FY3_TOT_DISB] + [FY3_TOT_STATE_FEES] AS c20
      ,'Totals Fees Deducted ' + [FY3] AS [c21(_col_label)]
      ,"FY3_TOT_STATE_FEES" AS c21
      ,'Total Value, Services Rendered ' + [FY3] AS [c22(_col_label)]
      ,"FY3_TOT_SVCS" AS c22     
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY4] AS [c23(_col_label)]
      ,"FY4_TOT_ADJS" AS c23
      ,'Total Disbursed ' + [FY4] AS [c24(_col_label)]
      ,"FY4_TOT_DISB" AS c24
      ,'Total Payments Authorized ' + [FY4] AS [c25(_col_label)]
      ,[FY4_TOT_DISB] + [FY4_TOT_STATE_FEES] AS c25
      ,'Totals Fees Deducted ' + [FY4] AS [c26(_col_label)]
      ,"FY4_TOT_STATE_FEES" AS c26
      ,'Total Value, Services Rendered ' + [FY4] AS [c27(_col_label)]
      ,"FY4_TOT_SVCS" AS c27   
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY5] AS [c28(_col_label)]
      ,"FY5_TOT_ADJS" AS c28
      ,'Total Disbursed ' + [FY5] AS [c29(_col_label)]
      ,"FY5_TOT_DISB" AS c29
      ,'TOT_TOT_PAID ' + [FY5] AS [c30(_col_label)]
      ,[FY5_TOT_DISB] + [FY5_TOT_STATE_FEES] AS c30
      ,'Totals Fees Deducted ' + [FY5] AS [c31(_col_label)]
      ,"FY5_TOT_STATE_FEES" AS c31
      ,'Total Value, Services Rendered ' + [FY5] AS [c32(_col_label)]
      ,"FY5_TOT_SVCS" AS c32
      
      ,'Total Adjs on Prev FYs, Entered ' + [FY6] AS [c33(_col_label)]
      ,"FY6_TOT_ADJS" AS c33
      ,'Total Disbursed ' + [FY6] AS [c34(_col_label)]
      ,"FY6_TOT_DISB" AS c34
      ,'Total Payments Authorized ' + [FY6] AS [c35(_col_label)]
      ,[FY6_TOT_DISB] + [FY6_TOT_STATE_FEES] AS c35
      ,'Totals Fees Deducted ' + [FY6] AS [c36(_col_label)]
      ,"FY6_TOT_STATE_FEES" AS c36
      ,'Total Value, Services Rendered ' + [FY6] AS [c37(_col_label)]
      ,"FY6_TOT_SVCS" AS c37
      
      ,OK_TO_REPORT_UP_TO_DATE
      
      FROM
      [dbo].[COMPUTE_FY_TOTALS_LAST_7_CORE] (@clientID, @leaIsActive, @refdate, @numyrs,1)   

ORDER BY

    CLIENT_NAME
)
GO

GRANT SELECT ON  [dbo].[FY_TOTALS_LAST_7_ONTHEFLY] TO [webuser]
GO   
