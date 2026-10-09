USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Clients_Create_Invoice') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Clients_Create_Invoice
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

           -- NOTE! TODO!  Cannot find any references of where this SPROC is called from.
           --              thus, no idea how invoices are being created or populated.
           --              Thoughts?

CREATE PROCEDURE [dbo].[Clients_Create_Invoice]   
        (       @REVENUE_PROGRAM                                        nvarchar(100),
                @REVENUE_SHARING_CATEGORY                       nvarchar(100),
                @TRNLINE_837_ID                                         BIGINT,
                @CLIENT_CDS                                                     varchar(8),
                @INVOICE_RATE                                           nvarchar(50),
                @INVOICE_AMOUNT                                         DECIMAL(18,2),
                @INVOICE_NUMBER                                         BIGINT,
                @INVOICE_DATE                                           DATE,
                @WhenToInvoice                                          CHAR(1),               
                @PAYLINE_835_ID                                         BIGINT,
                @CSBA_Share_B4                                          MONEY,
                @CSBA_Share_From_MBA_After                      MONEY,
                @CSBA_Share_From_AandI_After            MONEY,
                @CSBA_Share_After                                       MONEY,
                @LBandA_Share_B4                                        MONEY,
                @LBandA_Share_From_MBA_After            MONEY,
                @LBandA_Share_From_AandI_After          MONEY,
                @LBandA_Share_After                                     MONEY,
                @CSMG_Share_B4                                          MONEY,
                @MBA_Share_B4                                           MONEY,
               
                @SpEdCare_After_AnI_Terminated          MONEY,                    
                @MBA_After_AnI_Terminated                       MONEY,
                 
                @MBA_Share_After                                        MONEY,
                @MBA_Share_to_AandI_After                       MONEY,
                @AandI_Share_of_CSMG_Clients_After      MONEY,
                @AandI_Share_of_New_Clients_After       MONEY,
                @MAA_Claim_Year_FY                                      varchar(9),                                            
                @MBA_Share_to_MCF_After                         MONEY,
                @MCF_Share_After                                        MONEY,
                @Practi_Cal_Share                                   MONEY
        )  
AS    
BEGIN

        SET NOCOUNT ON /* Make error messages more visible */
       
        declare @errorflag bit = 0
       
        declare @errorstring varchar(max) = 'Error on line ('
                + 'CDS: ' + CONVERT(VARCHAR(MAX),@Client_CDS)           + ' '
                + 'INV#: '+ CONVERT(VARCHAR(MAX),@invoice_number)       + ' '
                + 'DATE: '+ CONVERT(VARCHAR(MAX),@invoice_date)         + ' '
                + '$AMT: '+ CONVERT(VARCHAR(MAX),@INVOICE_AMOUNT)       + ' '
                + 'TLN: ' + ISNULL(CONVERT(VARCHAR(MAX),@TRNLINE_837_ID),'NULL')        + ' '
                + 'PLN: ' + ISNULL(CONVERT(VARCHAR(MAX),@PAYLINE_835_ID),'NULL')        + ') : '
       
        declare @buffer varchar(max) /* clear this after you're done */
       
        IF (NOT EXISTS (SELECT 1 WHERE @REVENUE_PROGRAM IN ('MAA','LEA','CRCS')) OR (ISNULL(@REVENUE_PROGRAM,'') = ''))
        BEGIN
                SET @errorstring = @errorstring + 'This invoice does not contain a valid invoice type identifier (LEA, MAA, CRCS, etc.)'
                SET @errorflag = 1
                RAISERROR(@errorstring, 15, 1)
        END
       
               
        declare @CLIENT_ID bigint = 0
               
        SET @CLIENT_ID = (SELECT top 1 Client_id FROM CLIENTS_Client cc WHERE cc.CLIENT_CDS = REPLACE(@CLIENT_CDS,'-',''))
       
        IF @CLIENT_ID IS NULL
        BEGIN
                SET @errorstring = @errorstring + 'The district number "' + @CLIENT_CDS + '" is not associated with any Spedcare client.'
                SET @errorflag = 1
                RAISERROR(@errorstring, 15, 1)
        END
       
        declare @MAA_Claim_Year_DB_Convert int /* Holder for when we convert this data into our internal fiscal-year format. */
       
        declare @leaCheckRevShares bit = 0
        declare @leaUpdateRevShares bit = 0
        declare @leaRevShareUpdateID bigint
       
        /* Check to see if an invoice record exists for this inv num/date/amt combination */
        IF EXISTS (SELECT 1 FROM Client_Invoices ci     WHERE ci.INVOICE_AMOUNT = @INVOICE_AMOUNT AND ci.INVOICE_DATE = @INVOICE_DATE AND ci.INVOICE_NUMBER = @INVOICE_NUMBER)
        BEGIN
                IF @REVENUE_PROGRAM <> 'LEA'
                BEGIN
                        SET @errorstring = @errorstring + 'This invoice block (inv #/date/amount) is already in use.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1) 
                END
                ELSE
                        SET @leaCheckRevShares = 1     
        END
       
       
        IF (SELECT COUNT(*) FROM Client_Invoices WHERE INVOICE_NUMBER = @INVOICE_NUMBER AND CLIENT_ID <> @CLIENT_ID) > 0
        BEGIN
                SET @errorstring = @errorstring + 'Invoice #' + CONVERT(varchar(max),@INVOICE_NUMBER) + ' is already in use for a different client.'
                SET @errorflag = 1
                RAISERROR(@errorstring, 15, 1)
        END
       
        /* Run specialized error checks depending on the invoice program */
       
        IF @REVENUE_PROGRAM = 'LEA'
        BEGIN
               
                /* set arguments that aren't used in this billing type to NULL */
                SET @MAA_Claim_Year_FY = NULL
                SET     @MBA_Share_to_MCF_After = NULL
                SET @MCF_Share_After = NULL
               
               
                /* Do error checks for LEA invoices */
               
                IF @leaCheckRevShares = 1
                BEGIN
                        /* We have an already existing invoice based on number-date-amount */
                        SELECT @leaRevShareUpdateID = invoice_id FROM Client_Invoices ci        WHERE ci.INVOICE_AMOUNT = @INVOICE_AMOUNT AND ci.INVOICE_DATE = @INVOICE_DATE AND ci.INVOICE_NUMBER = @INVOICE_NUMBER
                       
                        /* check this existing invoice against the revenue shares in our arguments */
                       
                        IF EXISTS (
                                SELECT 1 FROM Client_Invoices WHERE
                                            @leaRevShareUpdateID = INVOICE_ID
                                        AND (
                                                                ISNULL(@CSBA_Share_B4,0)                                                <> ISNULL(CSBA_Share_B4,0)
                                                        OR      ISNULL(@CSBA_Share_From_MBA_After,0)                    <> ISNULL(CSBA_Share_From_MBA_After,0)
                                                        OR  ISNULL(@CSBA_Share_From_AandI_After,0)                      <> ISNULL(CSBA_Share_From_AandI_After,0)
                                                        OR      ISNULL(@CSBA_Share_After,0)                                             <> ISNULL(CSBA_Share_After,0)
                                                        OR      ISNULL(@LBandA_Share_B4,0)                                              <> ISNULL(LBandA_Share_B4,0)
                                                        OR      ISNULL(@LBandA_Share_From_MBA_After,0)                  <> ISNULL(LBandA_Share_From_MBA_After,0)
                                                        OR      ISNULL(@LBandA_Share_From_AandI_After,0)                <> ISNULL(LBandA_Share_From_AandI_After,0)
                                                        OR      ISNULL(@LBandA_Share_After,0)                                   <> ISNULL(LBandA_Share_After,0)
                                                        OR      ISNULL(@CSMG_Share_B4,0)                                                <> ISNULL(CSMG_Share_B4,0)
                                                        OR      ISNULL(@MBA_Share_B4,0)                                                 <> ISNULL(MBA_Share_B4,0)
                                                        OR      ISNULL(@SpEdCare_After_AnI_Terminated,0)                <> ISNULL(SpEdCare_After_AnI_Terminated,0)
                                                        OR      ISNULL(@MBA_After_AnI_Terminated,0)                             <> ISNULL(MBA_After_AnI_Terminated,0)
                                                        OR      ISNULL(@MBA_Share_After,0)                                              <> ISNULL(MBA_Share_After,0)
                                                        OR      ISNULL(@MBA_Share_to_AandI_After,0)                             <> ISNULL(MBA_Share_to_AandI_After,0)
                                                        OR      ISNULL(@AandI_Share_of_CSMG_Clients_After,0)    <> ISNULL(AandI_Share_of_CSMG_Clients_After,0)
                                                        OR      ISNULL(@AandI_Share_of_New_Clients_After,0)             <> ISNULL(AandI_Share_of_New_Clients_After,0)
                                                        OR      ISNULL(@Practi_Cal_Share,0)                             <> ISNULL(Practi_Cal_Share,0)
                                                )
                                )
                        BEGIN
               
                                SET @leaUpdateRevShares = 1
                               
                        END
               
                END
               
                IF (SELECT  COUNT(psc.PAYMENT_LINE_ID) FROM Payment_Summary_By_Client_835 psc WHERE psc.PAYMENT_LINE_ID = @PAYLINE_835_ID) = 0 AND @PAYLINE_835_ID IS NOT NULL
                BEGIN
                        SET @errorstring =  @errorstring +  'This invoice has a payment identifier for a nonexistent payment line.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1)
                END    
               
                else IF (SELECT COUNT(TRANSMISSION_LINE_ID) FROM Transmission_Summary_By_Client_837 tsc WHERE tsc.TRANSMISSION_LINE_ID = @TRNLINE_837_ID) =0 AND @TRNLINE_837_ID IS NOT NULL
                BEGIN
                        SET @errorstring = @errorstring +  'This invoice has a transmission identifier for a nonexistent payment line.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1)
                END
               
                else IF (SELECT top 1 CLIENT_ID FROM Payment_Summary_By_Client_835 psc WHERE psc.PAYMENT_LINE_ID = @PAYLINE_835_ID) <> @CLIENT_ID
                BEGIN
                        SET @errorstring =  @errorstring +  'This invoice links to a payment identifier that is for a different client ID.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1)
                END
               
                else IF (SELECT top 1 CLIENT_ID FROM Transmission_Summary_By_Client_837 tsc WHERE tsc.TRANSMISSION_LINE_ID = @TRNLINE_837_ID) <> @CLIENT_ID
                BEGIN
                        SET @errorstring = @errorstring +  'This invoice links to a transmission identifier that is for a different client ID.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1)
                END
               
                /* Subshare checks of full shares to partners might not be needed. -DW 20151201 */
               
                --else if (@CSBA_Share_After <> @CSBA_Share_From_AandI_After + @CSBA_Share_From_MBA_After)
                --BEGIN
                --      set @errorstring = @errorstring +  'This invoice has a CSBA after-share total/subtotal mismatch.'
                --      set @errorflag = 1
                --      RAISERROR(@errorstring, 15, 1)
                --END
               
                --else if (@LBandA_Share_After <> @LBandA_Share_From_AandI_After + @LBandA_Share_From_MBA_After)
                --BEGIN
                --      set @errorstring = @errorstring +  'This invoice has a LB&A after-share total/subtotal mismatch.'
                --      set @errorflag = 1
                --      RAISERROR(@errorstring, 15, 1)
                --END
               
                else IF
                        (
                                (
                                          ISNULL(@CSBA_Share_B4 ,0)                                    
                                        + ISNULL(@CSBA_Share_After ,0)
                                        + ISNULL(@LBandA_Share_B4 ,0)                          
                                        + ISNULL(@LBandA_Share_After ,0)                                       
                                        + ISNULL(@CSMG_Share_B4 ,0)                                    
                                        + ISNULL(@MBA_Share_B4 ,0)
                                        + ISNULL(@SpEdCare_After_AnI_Terminated ,0)
                                        + ISNULL(@MBA_After_AnI_Terminated ,0)                                         
                                        + ISNULL(@MBA_Share_After ,0)                                  
                                        + ISNULL(@MBA_Share_to_AandI_After ,0)                 
                                        + ISNULL(@AandI_Share_of_CSMG_Clients_After     ,0)
                                        + ISNULL(@AandI_Share_of_New_Clients_After ,0) 
                                        + ISNULL(@MBA_Share_to_MCF_After ,0)                           
                                        + ISNULL(@MCF_Share_After,0)                   
										+ ISNULL(@Practi_Cal_Share,0)                   
                                       
                                )
                                <> @INVOICE_AMOUNT
                        )
                BEGIN
                        SET @errorstring = @errorstring +  'This invoice is for an amount that does not match up to revenue sharing totals.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1)
                END
        END
       
        IF @REVENUE_PROGRAM = 'CRCS'
        BEGIN
                /* Set arguments that aren't used in this billing type to NULL */
                SET @TRNLINE_837_ID = NULL
                SET @PAYLINE_835_ID = NULL
                SET @CSBA_Share_B4 = NULL
                SET @CSBA_Share_From_MBA_After = NULL
                SET @CSBA_Share_From_AandI_After = NULL
                SET @CSBA_Share_After = NULL
                SET @LBandA_Share_B4 = NULL
                SET @LBandA_Share_From_MBA_After = NULL
                SET @LBandA_Share_From_AandI_After = NULL
                SET @LBandA_Share_After = NULL
                SET @CSMG_Share_B4 = NULL
                SET @MBA_Share_to_AandI_After = NULL
                SET @AandI_Share_of_CSMG_Clients_After = NULL
                SET @INVOICE_RATE = NULL
                SET @WhenToInvoice = NULL
                SET @MAA_Claim_Year_FY = NULL
                SET @MBA_Share_to_MCF_After = NULL
                SET @MCF_Share_After = NULL
				SET @Practi_Cal_Share = null

                /* These can potentially hold values now for CRCS invoices */
                --set @SpEdCare_After_AnI_Terminated = null
                --set @MBA_After_AnI_Terminated = null
               
                /* Set arguments that are constant for all CRCS invoices */
                SET @REVENUE_SHARING_CATEGORY = 'CRCS'
       
        END
       
       
        IF @REVENUE_PROGRAM = 'MAA'
        BEGIN
       
                /* Set arguments that aren't used in this billing type to NULL */
               
                SET @TRNLINE_837_ID = NULL
                SET @PAYLINE_835_ID = NULL
                SET @CSBA_Share_From_MBA_After = NULL
                SET @CSBA_Share_From_AandI_After = NULL
                SET @LBandA_Share_From_MBA_After = NULL
                SET @LBandA_Share_From_AandI_After = NULL
                SET @MBA_Share_to_AandI_After = NULL
                SET @AandI_Share_of_CSMG_Clients_After = NULL
                SET @AandI_Share_of_New_Clients_After = NULL
                SET @SpEdCare_After_AnI_Terminated = NULL
                SET @MBA_After_AnI_Terminated = NULL
                SET @INVOICE_RATE = NULL
                SET @WhenToInvoice = NULL
               
       
                /* Convert fiscal year  */
       
                SET @MAA_Claim_Year_DB_Convert =
                        (
                                SELECT top 1 ID
                                FROM COMPANY_FISCAL_YEARS cfy
                                WHERE SUBSTRING(cfy.FY_DEFINITION, 3,2)+ '/' + SUBSTRING(cfy.FY_DEFINITION, 8,2) = @MAA_Claim_Year_FY
                                ORDER BY FY_START DESC
                        )
                       
                       
                IF @MAA_Claim_Year_DB_Convert IS NULL
                BEGIN
                        SET @errorstring = @errorstring +  'This invoice has a MAA claim year that does not match to a fiscal year entry in the database.'
                        SET @errorflag = 1
                        RAISERROR(@errorstring, 15, 1)
                END
        END

       
        IF @errorflag = 0
        /* Insert invoice after it's been checked for type errors */
        BEGIN
                IF @REVENUE_PROGRAM = 'LEA' AND @leaUpdateRevShares = 1 AND @leaRevShareUpdateID IS NOT NULL
                begin
                        SET @buffer = ''
                        SET @buffer = @errorstring + 'Invoice ID #' + CONVERT(varchar(max),@leaRevShareUpdateID) + ' is updating revenue shares based on provided information.'
                        RAISERROR(@buffer, 1,1)
                        SET @buffer = ''
                       
                        --select * from Client_Invoices ci where ci.INVOICE_ID = @leaRevShareUpdateID
                       
                        UPDATE Client_Invoices
                        SET
                                CLIENT_ID                                                       = @CLIENT_ID,
                                INVOICE_NUMBER                                          = @INVOICE_NUMBER,
                                INVOICE_DATE                                            = @INVOICE_DATE,
                                INVOICE_AMOUNT                                          = @INVOICE_AMOUNT,
                                TRNLINE_837_ID                                          = @TRNLINE_837_ID,
                                PAYLINE_835_ID                                          = @PAYLINE_835_ID,
                                CSBA_Share_B4                                           = @CSBA_Share_B4,
                                CSBA_Share_From_MBA_After                       = @CSBA_Share_From_MBA_After,
                                CSBA_Share_From_AandI_After                     = @CSBA_Share_From_AandI_After,
                                CSBA_Share_After                                        = @CSBA_SHARE_AFTER,
                                LBandA_Share_B4                                         = @LBANDA_SHARE_B4,
                                LBandA_Share_From_MBA_After                     = @LBandA_Share_From_MBA_After,
                                LBandA_Share_From_AandI_After           = @LBandA_Share_From_AandI_After,
                                LBandA_Share_After                                      = @LBandA_Share_After,
                                CSMG_Share_B4                                           = @CSMG_Share_B4,
                                MBA_Share_B4                                            = @MBA_Share_B4,
                                SpEdCare_After_AnI_Terminated           = @SpEdCare_After_AnI_Terminated,
                                MBA_After_AnI_Terminated                        = @MBA_After_AnI_Terminated,
                                MBA_Share_After                                         = @MBA_Share_After,
                                MBA_Share_to_AandI_After                        = @MBA_Share_to_AandI_After,
                                AandI_Share_of_CSMG_Clients_After       = @AandI_Share_of_CSMG_Clients_After,
                                AandI_Share_of_New_Clients_After        = @AandI_Share_of_New_Clients_After,
                                Revenue_Sharing_Category                        = @Revenue_Sharing_Category,
                                Invoice_Rate                                            = @Invoice_Rate,
                                Revenue_Program                                         = @REVENUE_PROGRAM,
                                WhenToInvoice                                           = @WhenToInvoice,
                                MAA_Claim_FiscalYear                            = @MAA_Claim_Year_FY,
                                MBA_Share_to_MCF_After                          = @MBA_Share_to_MCF_After,
                                MCF_Share_After                                         = @MCF_Share_After,
                                Practi_Cal_Share                    = @Practi_Cal_Share
                        WHERE
                                INVOICE_ID = @leaRevShareUpdateID
                       
                        SELECT 'REVUPDATE', * FROM Client_Invoices ci WHERE ci.INVOICE_ID = @leaRevShareUpdateID
                ENd
               
                ELSE IF @leaUpdateRevShares = 0
                BEGIN
                        INSERT INTO Client_Invoices
                        (
                                 CLIENT_ID,
                                 INVOICE_NUMBER,
                                 INVOICE_DATE,
                                 INVOICE_AMOUNT,
                                 TRNLINE_837_ID,
                                 PAYLINE_835_ID,
                                 CSBA_Share_B4,
                                 CSBA_Share_From_MBA_After,
                                 CSBA_Share_From_AandI_After,
                                 CSBA_Share_After,
                                 LBandA_Share_B4,
                                 LBandA_Share_From_MBA_After,
                                 LBandA_Share_From_AandI_After,
                                 LBandA_Share_After,
                                 CSMG_Share_B4,
                                 MBA_Share_B4,
                                 SpEdCare_After_AnI_Terminated,
                                 MBA_After_AnI_Terminated,     
                                 MBA_Share_After,
                                 MBA_Share_to_AandI_After,
                                 AandI_Share_of_CSMG_Clients_After,
                                 AandI_Share_of_New_Clients_After,
                                 Revenue_Sharing_Category,
                                 Invoice_Rate,
                                 Revenue_Program,
                                 WhenToInvoice,
                                 MAA_Claim_FiscalYear,
                                 MBA_Share_to_MCF_After,
                                 MCF_Share_After,
                                 Practi_Cal_Share
                               
                        )
               
                        VALUES
                        (
                                @CLIENT_ID,
                                @INVOICE_NUMBER,
                                @INVOICE_DATE,
                                @INVOICE_AMOUNT,
                                @TRNLINE_837_ID,
                                @PAYLINE_835_ID,
                                @CSBA_Share_B4,
                                @CSBA_Share_From_MBA_After,
                                @CSBA_Share_From_AandI_After,
                                @CSBA_Share_After,
                                @LBandA_Share_B4,
                                @LBandA_Share_From_MBA_After,
                                @LBandA_Share_From_AandI_After,
                                @LBandA_Share_After,
                                @CSMG_Share_B4,
                                @MBA_Share_B4,
                                @SpEdCare_After_AnI_Terminated,
                                @MBA_After_AnI_Terminated,     
                                @MBA_Share_After,
                                @MBA_Share_to_AandI_After,
                                @AandI_Share_of_CSMG_Clients_After,
                                @AandI_Share_of_New_Clients_After,
                                @REVENUE_SHARING_CATEGORY,
                                @INVOICE_RATE,
                                @REVENUE_PROGRAM,
                                @WhenToInvoice,
                                @MAA_Claim_Year_DB_Convert,
                                @MBA_Share_to_MCF_After,
                                @MCF_Share_After,
                                @Practi_Cal_Share
                        )
       
                        declare @new_invoice_ID bigint = SCOPE_IDENTITY()
                       
                        SELECT * FROM Client_Invoices ci WHERE ci.INVOICE_ID = @new_invoice_ID
                END    
                ELSE
                BEGIN
                        SET @errorstring = @errorstring +  'This invoice was neither created or updated.'
                        RAISERROR(@errorstring, 15, 1)
                END
                       
        END


END
GO
  