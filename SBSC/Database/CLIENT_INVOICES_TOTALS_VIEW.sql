
USE SPEDMON
GO
 
/*-------------------------------
 * Drop Function if Exists
 *------------------------------*/

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_INVOICES_TOTALS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION dbo.CLIENT_INVOICES_TOTALS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLIENT_INVOICES_TOTALS_VIEW] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT 
  , @clientID            BIGINT
  , @startDateInvoiceRange           DATETIME
  , @endDateInvoiceRange             DATETIME
  , @invoicePaid         BIT
  , @distributionPaid    BIT

  , @startDateInvCollRange           DATETIME
  , @endDateInvCollRange             DATETIME

  , @calcShares          BIT

  , @inclPartner1Col           BIT
  , @inclRetentionCol          BIT

  , @inclCybhi                 BIT   -- NOTE: had I known I'd be expected to remove non-CYBHI rows from the CYBHI screen,
                                     --       perhaps I wouldn't have implemented @inclCybhiOnly as an afterthought.
									 --       Perhaps I would have used @inclCybhiOnly only, instead of two bitflags.

									 --       TODO!!! Consider simplifying/refactoring later.

  , @inclCybhiOnly             BIT
)    

 
RETURNS 
TABLE
AS
RETURN 
(
  with calcd_sums as (

	  select 
	      invoiceAmt       = sum(t1.invoiceAmt)

	    -- , spEdCareShare    = sum(t1.spEdCareShare)

	    , pcalShare        = sum(t1.pcalShare)
	    , accountingFee    = sum(t1.accountingFee)

        , partnerShareRevenue = sum(t1.partnerShareRevenue)

	    , partnerRevenue   = sum(t1.partnerRevenue)

	    , csbaShare        = sum(t1.csbaShare)
	    , lbaShare         = sum(t1.lbaShare)

	    , partner1Share    = sum(t1.partner1Share)

	    , partner2Share    = sum(t1.partner2Share)


	    , mbaBba		   = sum(t1.mbaBba)
	    , mbaShare		   = sum(t1.mbaShare)
	    , mbaDg		       = sum(t1.mbadg)

	    , spEdCareBba          = sum(t1.spEdCarebba)
	    , spEdCareDg	   = sum(t1.spEdCaredg)

	    , spEdCarePartners = sum(t1.spEdCarePartners)
	    , clientRetention  = sum(t1.clientRetention)

	    , revShare  = sum(t1.revShare)


  	from [dbo].[CLIENT_INVOICES_VIEW] (

	        @userID     --         BIGINT
  , @userGroup        --   INT  
  , @userRank         --   INT 
  , @clientID         --   BIGINT
  , @startDateInvoiceRange       --    DATETIME
  , @endDateInvoiceRange         --    DATETIME
  , @invoicePaid       --  BIT
  , @distributionPaid  --  BIT

  , @startDateInvCollRange       --    DATETIME
  , @endDateInvCollRange         --    DATETIME

  , @calcShares      --    BIT

  , @inclPartner1Col        --   BIT
  , @inclRetentionCol       --   BIT

  , @inclCybhi              --   BIT 

  , @inclCybhiOnly                --   BIT     

	  , 1 -- @active              BIT 
	  , null -- @recID               BIGINT 
  ) t1

  )
    SELECT
	  *,

	  invoiceAmtStr = CASE WHEN
	                     invoiceAmt IS NULL
						THEN ''
						ELSE '$' + FORMAT( invoiceAmt,'N2')
						END

    --, spEdCareShareStr = CASE WHEN spEdCareShare IS NULL THEN 'NULL'
	--ELSE '$' + FORMAT( spEdCareShare, 'N2')
	--					END



    , pcalShareStr = CASE WHEN pcalShare IS NULL THEN ''
	ELSE '$' + FORMAT( pcalShare, 'N2')
						END
	       
    , accountingFeeStr = CASE WHEN accountingFee IS NULL THEN ''
	ELSE '$' + FORMAT( accountingFee, 'N2')
						END

    , partnerShareRevenueStr = CASE WHEN accountingFee IS NULL THEN ''
	ELSE '$' + FORMAT( partnerShareRevenue, 'N2')
						END

    , partnerRevenueStr = CASE WHEN partnerRevenue IS NULL THEN '' 
	ELSE '$' + FORMAT( partnerRevenue, 'N2')
						END

    , csbaShareStr = CASE WHEN csbaShare IS NULL THEN '' 
	ELSE '$' + FORMAT( csbaShare, 'N2')
						END

    , lbaShareStr = CASE WHEN lbaShare IS NULL THEN '' 
	ELSE '$' + FORMAT( lbaShare, 'N2')
						END

    , partner1ShareStr = CASE WHEN partner1Share IS NULL THEN '' 
	ELSE '$' + FORMAT( partner1Share, 'N2')
						END


    , partner2ShareStr = CASE WHEN partner2Share IS NULL THEN '' 
	ELSE '$' + FORMAT( partner2Share, 'N2')
						END


	, mbaBbaStr = CASE WHEN mbaBba IS NULL THEN '' 
	ELSE '$' + FORMAT( mbaBba, 'N2')
						END

	, mbaShareStr = CASE WHEN mbaShare IS NULL THEN '' 
	ELSE '$' + FORMAT( mbaShare, 'N2')
						END

	, mbaDgStr = CASE WHEN mbaDg IS NULL THEN ''
	ELSE '$' + FORMAT( mbaDg, 'N2')
						END   

	, spEdCareBbaStr = CASE WHEN spEdCareBba IS NULL THEN '' 
	ELSE '$' + FORMAT( spEdCareBba, 'N2')
						END 
	 
	, spEdCareDgStr = CASE WHEN spEdCareDg IS NULL THEN '' 
	ELSE '$' + FORMAT( spEdCareDg, 'N2')
						END

	, spEdCarePartnersStr = CASE WHEN spEdCarePartners IS NULL THEN ''
	ELSE '$' + FORMAT( spEdCarePartners, 'N2')
						END

    , clientRetentionStr = CASE WHEN clientRetention IS NULL THEN '' 
	ELSE '$' + FORMAT( clientRetention, 'N2')
						END

    , revShareStr = CASE WHEN clientRetention IS NULL THEN '' 
	ELSE '$' + FORMAT( revShare , 'N2')
						END

	FROM calcd_sums c1
)
GO
 
/*-------------------------------
 * Grant Permissions
 *------------------------------*/
 
GRANT SELECT ON [dbo].[CLIENT_INVOICES_TOTALS_VIEW] TO [webuser];
GO
 


            
            
