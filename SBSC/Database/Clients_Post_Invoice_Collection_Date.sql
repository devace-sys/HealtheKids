USE SPEDMON
/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Clients_Post_Invoice_Collection_Date') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.[Clients_Post_Invoice_Collection_Date]
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.[Clients_Post_Invoice_Collection_Date] 
	(	
		@INVOICE_AMOUNT						DECIMAL(18,2),
		@INVOICE_NUMBER						BIGINT,
		@INVOICE_DATE						DATE,
		
		@COLLECTION_DATE					DATE
		
		
	)  
AS    
BEGIN 

	declare @errorflag bit = 0
	
	declare @errorstring varchar(max) = 'Error on line (' 
		+ 'INV#: '	+ CONVERT(VARCHAR(MAX),@invoice_number)		+ ' ' 
		+ 'DATE: '	+ CONVERT(VARCHAR(MAX),@invoice_date)		+ ' '
		+ '$AMT: '	+ CONVERT(VARCHAR(MAX),@INVOICE_AMOUNT)		+ ' ' 
		+ 'COLDAT: '+ CONVERT(VARCHAR(MAX),@COLLECTION_DATE)	+ ') : '
	

	
	declare @sql_invoice_tgt_ids table (inv_id bigint)

/* Is there even anything in the collection date field? If blank or NULL, error */
if @COLLECTION_DATE is null or @COLLECTION_DATE = '19000101'
BEGIN
	set @errorstring = @errorstring + 'No collection date is specified for this invoice.)'
	set @errorflag = 1
	RAISERROR(@errorstring, 15, 1)
END


declare @invNumCt bigint = (select COUNT(*) from Client_Invoices where INVOICE_NUMBER = @INVOICE_NUMBER and Date_Collected is null)

declare @invNumDatCt bigint = (select COUNT(*) from Client_Invoices where INVOICE_NUMBER = @INVOICE_NUMBER and INVOICE_DATE = @INVOICE_DATE and Date_Collected is null)

declare @invNumDatAmtCt bigint = (select COUNT(*) from Client_Invoices where INVOICE_NUMBER = @INVOICE_NUMBER and INVOICE_DATE = @INVOICE_DATE and INVOICE_AMOUNT = @INVOICE_AMOUNT and Date_Collected is null)

declare @multiple_sql_targets bit = 0

declare @targetInvoiceID bigint = 0

/* If we can't find any records based on invoice number or date, error out. */

IF @invNumCt = 0
BEGIN
	set @errorstring = @errorstring + 'There are no uncollected invoices with the specified invoice number.'
	set @errorflag = 1
	RAISERROR(@errorstring, 15, 1)
END

ELSE IF @invNumDatCt = 0
BEGIN
	set @errorstring = @errorstring + 'There are no uncollected invoices with the specified invoice number and date.'
	set @errorflag = 1
	RAISERROR(@errorstring, 15, 1)
END

/* If more than one row matches #-date-amt, error */
else if @invNumDatAmtCt > 1
BEGIN
	set @errorstring = @errorstring + 'More than one invoice matches the criteria (invoice (#-date-amount)). Only one uncollected invoice should match this data set.'
	set @errorflag = 1
	RAISERROR(@errorstring, 15, 1)
END

/* If no rows match #-date-amt, see if we can do something based soley on #-date */
else if @invNumDatAmtCt = 0
BEGIN
	/* Only one number-date result means we need to check for partial collections */
	/* If number-date totals are non-zero: */
	IF @invNumDatCt = 1
	BEGIN
		declare @inv_curr_amt bigint = 0
			/* get the amount for this number-date single invoice and compare against amount we're collecting */
			/* Partial collection needs the amount collected to be LESS than the current amount of the invoice. */
		select @inv_curr_amt = INVOICE_AMOUNT 
		from Client_Invoices 
		where INVOICE_NUMBER = @INVOICE_NUMBER and INVOICE_DATE = @INVOICE_DATE
		
		if @inv_curr_amt > @INVOICE_AMOUNT
			BEGIN
		
				
				set @errorstring = @errorstring + 'The collection amount specified is less than the original amount billed for the invoice. If this is a partial collection, the existing invoice needs to be adjusted to collect the currently-paid amount and a new invoice entry created to indicate the remainder to be paid. DO THIS IN NEWTRANS SO REVENUE SHARES ARE CALCULATED PROPERLY.'
				set @errorflag = 1
				RAISERROR(@errorstring, 15, 1)

			END
		ELSE if @inv_curr_amt < @INVOICE_AMOUNT
			BEGIN
				set @errorstring = @errorstring + 'The collection amount specified is greater than the original amount billed for the invoice.'
				set @errorflag = 1
				RAISERROR(@errorstring, 15, 1)
			END
		/* We've established there's no match on amount, so straight equality comparison whould never happen. */
	END
	else if @invNumDatCt > 1
	BEGIN
	set @multiple_sql_targets = 1
		/* Do a quick check to see if a set of invoices in SQL for an inv# and date total up to the same amount we're specifying from QB */
		IF ABS(@INVOICE_AMOUNT) = (select ABS(SUM(INVOICE_AMOUNT)) from Client_Invoices where INVOICE_DATE = @INVOICE_DATE and @INVOICE_NUMBER = INVOICE_NUMBER)
		BEGIN
		
			set @errorstring = @errorstring + 'More than one match on (invoice # - Date). Is this a case where collection is distributed over multiple invoices?'
			set @errorflag = 1
			RAISERROR(@errorstring, 15, 1)		
			--set @multiple_sql_targets = 1
			--insert @sql_invoice_tgt_ids
			--select invoice_id from Client_Invoices where INVOICE_DATE = @INVOICE_DATE and @INVOICE_NUMBER = INVOICE_NUMBER
		END
	END
	
END

/* if there's only one match on #-date-amt, OK to collect */
	
/* Check for error flags - if none, update the record */	
if @errorflag = 0
BEGIN
	if @multiple_sql_targets = 0 and (select COUNT(*) from @sql_invoice_tgt_ids) = 0
	BEGIN 
		update Client_Invoices
		set Date_Collected = @COLLECTION_DATE
		where 
			INVOICE_AMOUNT= @INVOICE_AMOUNT 
			and INVOICE_DATE = @INVOICE_DATE
			and INVOICE_NUMBER = @INVOICE_NUMBER
			and Date_Collected is null
	END
	
	ELSE IF @multiple_sql_targets = 1 and (select COUNT(*) from @sql_invoice_tgt_ids) <> 0
	BEGIN
	
		update Client_Invoices
		set Date_Collected = @COLLECTION_DATE
		where 
			INVOICE_ID in (select INVOICE_ID from @sql_invoice_tgt_ids)
			and INVOICE_DATE = @INVOICE_DATE
			and INVOICE_NUMBER = @INVOICE_NUMBER
			and Date_Collected is null
	END
	
	
END

END
GO
