USE SPEDMON
GO

/*---------------------------------
 * Drop Function if Exists
 *--------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC
GO

/*--------------------------------
 * Object Definition
 *-------------------------------*/
CREATE FUNCTION [dbo].[CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC] (

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

   @spEdCareAfterAniTerminated     money ,

   @initialContractStartDate       date ,

   @partner1Percent                money ,
   @partner1EPercent               money ,

   @partner2Percent                money  
)    



RETURNS 
TABLE
AS
RETURN (


  with  newcol_from_raw_params as (
     SELECT
     @invAmt_W_HlthyK_Cyb_Crcs_Cde_plnImp_Proprtly_Subtrd - @accountingFee    AS   partnerShareRevenue  --
  ),

  spedpartners_from_newcol as (

     SELECT
	*,

     ( partnerShareRevenue
	        -  @csbaShareAcctFeeProportionallySubtd
		-  @lbaShareAcctFeeProportionallySubtd
	 ) * 0.72      AS   spEdCarePartnersWithEntireAcctFeeSubtrac ,  --

     ( partnerShareRevenue
	    -  @csbaShareAcctFeeProportionallySubtd
		-  @lbaShareAcctFeeProportionallySubtd
	 ) * 0.28      AS   mbaPartnersWithEntireAcctFeeSubtrac   --

     FROM newcol_from_raw_params
   
  ),

  w_partner1_share as (
      SELECT
           * ,

		   mbaPartnersWithEntireAcctFeeSubtrac  AS mbaShare ,

           CASE
		      WHEN   @inclPartner1Col IS NULL OR @inclPartner1Col = 0
		      THEN   0

		         -- TODO: not sure what this logic is
              WHEN @invoiceDate >= @initialContractStartDate AND @invoiceDate <= DATEADD(MONTH, 12, @initialContractStartDate )
              THEN ( @spEdCareAfterAniTerminated * ( @partner1Percent + @partner1EPercent ) / 100)
                                                                             
              ELSE  ( @spEdCareAfterAniTerminated * @partner1Percent / 100 )
           END   AS partner1Share ,

           0
                 AS partner2Share

     FROM  spedpartners_from_newcol
  )

  SELECT
     * ,

	-- x72PctSpEdCarePartnersWithEntireAcctFeeSubtrac  AS  spEdCarePartners ,    -- TODO!!!  I think this is renamed on the frontend

	spEdCarePartnersWithEntireAcctFeeSubtrac          AS  spEdCarePartners  , -- 0.72 multiplication and all subtractions accounted for.
	                                                                          -- TODO! This is renamed on the frontend

    mbaPartnersWithEntireAcctFeeSubtrac
	* @mbaBbaPercent / 100 AS mbaBba,

    mbaPartnersWithEntireAcctFeeSubtrac
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
GRANT SELECT ON [dbo].[CLIENT_INVOICES_PARTNER_DISTRIBUTIONS_CALC] TO [webuser];
GO