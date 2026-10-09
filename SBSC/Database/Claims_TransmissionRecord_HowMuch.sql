use SPEDMON 
GO

if  exists (select * from dbo.sysobjects where id = object_id(N'[dbo].Claims_TransmissionRecord_HowMuch') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE Claims_TransmissionRecord_HowMuch
GO


CREATE PROCEDURE Claims_TransmissionRecord_HowMuch
(
	@transmission_IDS bigint_tabletype READONLY
)
AS
BEGIN

/*****************************************************

	After a transmission is run, we want confirmation 
	data re: claim data in the transmission.
	
	This query aggregates dollar amount totals for clients
	in a transmission, taking into account how TCM rates
	differ on a county-to-county basis.
	
	(TCM calculation has been moved to 837 invoicing)
		- DW 20130218
*****************************************************/

select 

	 ''																			as 'HOWMUCH IN TRANSMISSION'
	,tsbc.client_id
	,CASE 
		when exists 
			(
				select 1 from CLIENTS_Client		as cc 
				where 
					cc.CLIENT_ID = tsbc.CLIENT_ID 
					and FIRST_CHECK is null
			)
			then '*** FIRST TRANSMISSION *** ' + tsbc.CLIENT_NAME
		else tsbc.CLIENT_NAME
	 END																		as CLIENT_NAME
	,tsbc.TRANSMISSION_RECORD_ID												as TRANSMISSION_RECORD_ID
	,tsbc.CLIENT_SHORTNAME														as 'ShortName'
	,SUBSTRING(TSBC.CLIENT_CDS,0,3) + '-' + SUBSTRING(TSBC.CLIENT_CDS,3,999)	as 'CLIENT_CDS'
	
	,tsbc.TOTAL_NUMBER_CLAIMS													as 'Total Number of Claims'
	,tsbc.TOTAL_DOLLAR_AMOUNT													as 'Total Dollar Amount'  
	
	
	,CONVERT(DATE,tsbc.TRANSMISSION_DATE)										as Date_of_Transmission

	,tsbc.CLAIMS_SUBMITTED														as '# of Claims Submitted'
	,tsbc.AMOUNT_SUBMITTED														as 'Amount Submitted'  
	
	,tsbc.CLAIMS_RESUBMITTED													as 'Claims Resubmits'
	,tsbc.AMOUNT_RESUBMITTED													as 'Amounts Resubmitted'
	,tsbc.TRANSMISSION_LINE_ID													as 'Transmission Line ID'
	,tsbc.RevenueSharingCategoryLEA												as 'Revenue Sharing Category-LEA'
	,tsbc.WhenToInvoice															as 'When to Invoice'
	,tsbc.InvoiceRate															as 'Invoice Rate'
		
from 
	dbo.Transmission_Summary_By_Client_837											as tsbc
	inner join @transmission_IDS												as ti
		on tsbc.TRANSMISSION_RECORD_ID = ti.id
order by [Total Dollar amount] desc




select '' as 'TOTAL CLAIMS IN TRANSMISSION', 

	SUM(tsbc.TOTAL_NUMBER_CLAIMS) as 'Total claims', 
	SUM(tsbc.TOTAL_DOLLAR_AMOUNT) as 'Total Dollar amount'  ,

	SUM(tsbc.CLAIMS_SUBMITTED) as '# of Claims Submitted',
	SUM(tsbc.AMOUNT_SUBMITTED) as 'Amount Submitted'  ,
	
	SUM(tsbc.CLAIMS_RESUBMITTED) as 'Claims Resubmits',
	SUM(tsbc.AMOUNT_RESUBMITTED) as 'Amounts Resubmitted'  	

from 
	dbo.Transmission_Summary_By_Client_837		as tsbc
	inner join @transmission_IDS				as ti
		on tsbc.TRANSMISSION_RECORD_ID = ti.id


END
GO
 