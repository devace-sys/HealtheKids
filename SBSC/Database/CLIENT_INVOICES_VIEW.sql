USE SPEDMON
GO

/*--------------------------------
 * Drop Function if Exists
 *-------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_INVOICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_INVOICES_VIEW
GO


/*--------------------------------
 * Object Definition
 *-------------------------------*/
CREATE FUNCTION [dbo].[CLIENT_INVOICES_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT

  , @startDateInvoiceRange           DATETIME
  , @endDateInvoiceRange             DATETIME
  , @invoicePaid         BIT

  , @distributionPaid    BIT

  -- , @startDateDistbPaidRange           DATETIME
  -- , @endDateDistbPaidRange             DATETIME

  , @startDateInvCollRange           DATETIME
  , @endDateInvCollRange             DATETIME


  , @calcShares          BIT

  , @inclPartner1Col           BIT
  , @inclRetentionCol          BIT

  , @inclCybhi                 BIT

  , @inclCybhiOnly             BIT

  , @active              BIT 
  , @recID               BIGINT 
)    


RETURNS 
TABLE
AS

RETURN (

  with p1 as (
    SELECT 

        ci.INVOICE_ID AS id,
        ci.CLIENT_ID AS clientID,
        cc.CLIENT_NAME AS clientName,

        ci.INVOICE_NUMBER AS invoiceNum,
        ci.INVOICE_AMOUNT AS invoiceAmt,

        ci.INVOICE_DATE AS invoiceDate,
        dbo.RPT_DATE_FMT_YYYY_MM_DD(ci.INVOICE_DATE) AS invoiceDateYMD,
        dbo.RPT_DATE_FMT(ci.INVOICE_DATE) AS invoiceDateStr,

        ci.Date_Collected AS dateCollected,
        dbo.RPT_DATE_FMT_YYYY_MM_DD(ci.Date_Collected) AS dateCollectedYMD,
        dbo.RPT_DATE_FMT(ci.Date_Collected) AS dateCollectedStr,

		ci.Deposit_Date AS depositDate,
        dbo.RPT_DATE_FMT_YYYY_MM_DD(ci.Deposit_Date) AS depositDateYMD,
        dbo.RPT_DATE_FMT(ci.Deposit_Date) AS depositDateStr,

		ci.Distributed_Date AS distributedDate,
        dbo.RPT_DATE_FMT_YYYY_MM_DD(ci.Distributed_Date) AS distributedDateYMD,
        dbo.RPT_DATE_FMT(ci.Distributed_Date) AS distributedDateStr,


		ci.Amount_Paid AS amountPaid,


        ci.Practi_Cal_Share AS pcalShare,

        ci.Notes AS notes,

		ci.Distribution_Notes  AS distributionNotes,

        CONCAT(cr1.first_name, ', ', cr1.last_name) AS consultant,
        cc.RevenueSharingCategoryLEACurrent AS revenueCode,

		ci.Revenue_Program                          AS revenueProgram,

        (ci.INVOICE_AMOUNT - (ci.INVOICE_AMOUNT * (cc.healtheKids_percent + cc.cybhi_percent + cc.crcs_percent + cc.cdeReporting_percent + cc.planImplementation_percent) / 100)) * cc.accounting_percent / 100 AS accountingFee,

		ci.INVOICE_AMOUNT  as InvoiceAmount ,

        ci.INVOICE_AMOUNT - (ci.INVOICE_AMOUNT * (cc.healtheKids_percent + cc.cybhi_percent + cc.crcs_percent + cc.cdeReporting_percent + cc.planImplementation_percent) / 100) AS partnerRevenue,

       (((  ci.INVOICE_AMOUNT - (ci.INVOICE_AMOUNT * (cc.healtheKids_percent + cc.cybhi_percent + cc.crcs_percent + cc.cdeReporting_percent + cc.planImplementation_percent) / 100)) * cc.csba_percent) / 100) AS csbaShareAcctFeeNotYetSubtd,


         ( (ci.INVOICE_AMOUNT - (ci.INVOICE_AMOUNT * (cc.healtheKids_percent + cc.cybhi_percent + cc.crcs_percent + cc.cdeReporting_percent + cc.planImplementation_percent) / 100)) * (100 - cc.accounting_percent) / 100) * cc.csba_percent / 100 AS csbaShareAcctFeeProportionallySubtd,


        (((ci.INVOICE_AMOUNT - (ci.INVOICE_AMOUNT * (cc.healtheKids_percent + cc.cybhi_percent + cc.crcs_percent + cc.cdeReporting_percent + cc.planImplementation_percent) / 100)) *  cc.lba_percent) / 100)  AS lbaShareAcctFeeAcctFeeNotYetSubtd,

        ((ci.INVOICE_AMOUNT - (ci.INVOICE_AMOUNT * (cc.healtheKids_percent + cc.cybhi_percent + cc.crcs_percent + cc.cdeReporting_percent + cc.planImplementation_percent) / 100)) * (100 - cc.accounting_percent) / 100) * cc.lba_percent / 100 AS lbaShareAcctFeeProportionallySubtd,


        CASE WHEN  @inclRetentionCol  =  1  THEN cc.clientRetention ELSE 0 END   AS  clientRetention,

		cc.mba_bba_percent, --cc.mba_dg_percent,
		cc.spEdCare_bba_percent, --cc.spEdCare_dg_percent,

		cc.smaa_1_percent, cc.smaa_2_percent, cc.smaa_3_percent ,
		-- TODO: not sure how SMAA is suppsd to be calculated

		ci.SpEdCare_After_AnI_Terminated      as  revShare  ,

		cc.initialContractStartDate           as initialContractStartDate ,

		cc.partner1_percent                   as partner1Percent ,
		cc.partner1E_percent                  as partner1EPercent ,

		cc.partner2_percent                   as partner2Percent  

    FROM dbo.Client_Invoices ci
    LEFT JOIN dbo.CLIENTS_Client cc ON cc.CLIENT_ID = ci.CLIENT_ID
    LEFT JOIN dbo.CLIENTS_Client_Reps cr1 ON cr1.id = cc.ClientRepIDLEACurrent
    WHERE 
        (@clientID IS NULL OR ci.CLIENT_ID = @clientID)
        AND (@recID IS NULL OR ci.INVOICE_ID = @recID)

        AND
        (

          (  ci.Revenue_Program IN ('LEA', 'CRCS', 'CYBHI')  AND   @inclCybhi = 1 AND ISNULL(@inclCybhiOnly, 0) = 0 )

             OR

          (  ci.Revenue_Program IN ('LEA', 'CRCS') AND ISNULL(@inclCybhi, 0) = 0 )

             OR

          (  ci.Revenue_Program = 'CYBHI' AND @inclCybhiOnly = 1   )
        )

        AND ( @startDateInvoiceRange IS NULL
             OR @endDateInvoiceRange IS NULL
             OR ci.INVOICE_DATE BETWEEN @startDateInvoiceRange AND @endDateInvoiceRange)

		-- AND (@startDateDistbPaidRange IS NULL
        --      OR @endDateDistbPaidRange IS NULL
        --      OR ci.Distributed_Date BETWEEN @startDateDistbPaidRange AND @endDateDistbPaidRange)


		AND (@startDateInvCollRange IS NULL
             OR @endDateInvCollRange IS NULL
             OR ci.Date_Collected BETWEEN @startDateInvCollRange AND @endDateInvCollRange)



        AND (@invoicePaid IS NULL OR (@invoicePaid = 1 AND ci.Date_Collected IS NOT NULL) OR (@invoicePaid = 0 AND ci.Date_Collected IS NULL))

		AND (@distributionPaid IS NULL
		      OR
			  ( @distributionPaid = 1 AND ci.Distributed_Date IS NOT NULL)
			  OR ( @distributionPaid = 0 AND ci.Distributed_Date IS NULL)
			 )

    ORDER BY cc.CLIENT_NAME ASC, ci.INVOICE_DATE DESC

	OFFSET 0 ROWS
	   -- ORDER BY clause requires OFFSET clause
  )
  select
     * ,
     csbaShare  =   csbaShareAcctFeeProportionallySubtd ,
     lbaShare   =   lbaShareAcctFeeProportionallySubtd
  from
  p1
  --
   OUTER APPLY (
     select * from
     [dbo].[CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC] (

	   InvoiceAmount         ,

	   mba_bba_percent       ,
	   mba_bba_percent ,           -- mba_dg_percent        ,
	   spEdCare_bba_percent  ,
	   spEdCare_bba_percent  ,     --spEdCare_dg_percent   ,

	   partnerRevenue        ,

       csbaShareAcctFeeNotYetSubtd                     ,

	   csbaShareAcctFeeProportionallySubtd             ,

       lbaShareAcctFeeAcctFeeNotYetSubtd               ,

	   lbaShareAcctFeeProportionallySubtd              ,

       accountingFee                                   ,

       RevenueProgram                                  ,

	   @inclPartner1Col               ,

       invoiceDate                    ,

       revShare     ,

       initialContractStartDate       ,

       partner1Percent                ,
       partner1EPercent               ,
       partner2Percent                 

     )    WHERE ( @calcShares=1  AND  revenueProgram != 'CYBHI' )

        UNION ALL

     select * from
     [dbo].[CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC_CYBHI] (

	   InvoiceAmount         ,

	   mba_bba_percent       ,
	   mba_bba_percent ,           -- mba_dg_percent        ,
	   spEdCare_bba_percent  ,
	   spEdCare_bba_percent  ,     --spEdCare_dg_percent   ,

	   partnerRevenue        ,

       csbaShareAcctFeeNotYetSubtd                     ,

	   csbaShareAcctFeeProportionallySubtd             ,

       lbaShareAcctFeeAcctFeeNotYetSubtd               ,

	   lbaShareAcctFeeProportionallySubtd              ,

       accountingFee                                   ,

       RevenueProgram                                  ,

	   @inclPartner1Col               ,

       invoiceDate                    ,

       null  , --   spEdCareAfterAniTerminated   -- NOT USED 

       initialContractStartDate       ,

       partner1Percent                ,
       partner1EPercent               ,
       partner2Percent                 


     )    WHERE ( @calcShares=1  AND  revenueProgram = 'CYBHI' )

   ) o1 
);
GO

/*-------------------------------
 * Grant Permissions
 *------------------------------*/
GRANT SELECT ON [dbo].[CLIENT_INVOICES_VIEW] TO [webuser];
GO