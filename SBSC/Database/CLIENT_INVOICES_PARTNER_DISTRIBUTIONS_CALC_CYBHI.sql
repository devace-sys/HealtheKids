USE SPEDMON
GO

/*---------------------------------
 * Drop Function if Exists
 *--------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC_CYBHI') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC_CYBHI
GO

/*--------------------------------
 * Object Definition
 *-------------------------------*/
CREATE FUNCTION [dbo].[CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC_CYBHI] (

   @invoiceAmount        [decimal](18, 2) , 

   @mbaBbaPercent         money ,
   @mbaDgPercent          money ,
   @spEdCareBbaPercent    money ,
   @spEdCareDgPercent     money ,

   @invAmt_W_HlthyK_Cyb_Crcs_Cde_plnImp_Proprtly_Subtrd        money ,   -- AKA "partnerRevenue", aka LEA BOP Revenue

   @csbaShareAcctFeeNotYetSubtd               money ,  -- NOT USED

   @csbaShareAcctFeeProportionallySubtd       money ,


   @lbaShareAcctFeeAcctFeeNotYetSubtd         money ,  -- NOT USED

   @lbaShareAcctFeeProportionallySubtd        money ,

   @accountingFee  money ,

   -- @spEdCareShare   money

   @revenueProgram                 [nvarchar](100)  ,

   @inclPartner1Col                BIT ,

   @invoiceDate                    date ,

   @spEdCareAfterAniTerminated     money , -- TODO!!  NOT USED!!!

   @initialContractStartDate       date ,

   @partner1Percent                money ,
   @partner1EPercent               money ,

   @partner2Percent                money  
)    
    
RETURNS 
TABLE
AS
RETURN (


  with 

   w_acctfee_subt as (
    SELECT
	  --*,
	 partnerShareRevenue                      =  @invAmt_W_HlthyK_Cyb_Crcs_Cde_plnImp_Proprtly_Subtrd - @accountingFee   ,
	 spEdCarePartnersWithEntireAcctFeeSubtrac =  @invoiceAmount   -   @accountingFee  

	--FROM   decide_switch_revenu_figur_for_spedcareamt_calc_req_acctfee_subt
  ),

  raw_spedpartnersand_mba as (

   SELECT
     *,

     @invAmt_W_HlthyK_Cyb_Crcs_Cde_plnImp_Proprtly_Subtrd
	  - @csbaShareAcctFeeProportionallySubtd
	  - @lbaShareAcctFeeProportionallySubtd
	  - spEdCarePartnersWithEntireAcctFeeSubtrac
	                              AS   mbaShareNeedsAcctFeeSubtrac

     FROM  w_acctfee_subt
   
  ),
  calcd_w_acct_fee as (

    SELECT
      * ,
      mbaShare                          = mbaShareNeedsAcctFeeSubtrac           -   @accountingFee  --,

    FROM  raw_spedpartnersand_mba
    
  ),
  w_partner1_share as (
      SELECT
           * ,
           CASE
		      WHEN   @inclPartner1Col IS NULL OR @inclPartner1Col = 0
		      THEN   0

		         -- TODO: not sure what this logic is
              WHEN @invoiceDate >= @initialContractStartDate AND @invoiceDate <= DATEADD(MONTH, 12, @initialContractStartDate )
              THEN ( @invoiceAmount * ( @partner1Percent + @partner1EPercent ) / 100)
                                                                             
              ELSE  ( @invoiceAmount * @partner1Percent / 100 )

           END
		   AS partner1Share  ,

           CASE
		      WHEN   @inclPartner1Col IS NULL OR @inclPartner1Col = 0
		      THEN   0
                      ELSE
			( @invoiceAmount * @partner2Percent / 100 )  
           END
                   AS partner2Share

     FROM  calcd_w_acct_fee
  )

  SELECT
     * ,
	--x72PctSpEdCarePartnersWithEntireAcctFeeSubtrac  AS  spEdCarePartners ,  -- TODO!!!  I think this is renamed on the frontend
	spEdCarePartnersWithEntireAcctFeeSubtrac  AS  spEdCarePartners ,  -- TODO!!!  I think this is renamed on the frontend

	-- mbaShare AS MbaShare ,  -- 

    mbaShare
	* @mbaBbaPercent / 100 AS mbaBba,

    mbaShare
    * @mbaDgPercent / 100 AS mbaDg,


   spEdCarePartnersWithEntireAcctFeeSubtrac
    * @spEdCareBbaPercent / 100 AS spEdCareBba,

   spEdCarePartnersWithEntireAcctFeeSubtrac
   * @spEdCareDgPercent / 100 AS spEdCareDg

   FROM  w_partner1_share

);
GO

/*-------------------------------
 * Grant Permissions
 *------------------------------*/
GRANT SELECT ON [dbo].[CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC_CYBHI] TO [webuser];
GO