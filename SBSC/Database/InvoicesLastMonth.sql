USE SPEDMON
GO

/****** Object:  UserDefinedFunction [dbo].[InvoicesLastMonth]    Script Date: 12/29/2020 5:39:10 PM ******/
DROP FUNCTION if exists [dbo].[InvoicesLastMonth]
GO

CREATE FUNCTION [dbo].[InvoicesLastMonth](
)
returns @retDetail table (
Client varchar(50),
INVOICE_NUMBER bigint,
Invoice_Date date,
Date_Collected date,
SpEdCare_Share decimal(10,2),
First_check date,
NEW_CLIENT_MARKER varchar(16),
[SpEdCare Share 1%] money) 

as			              						 	
begin


DECLARE @today DATE
SET @today = GETDATE()

declare @spedcareSharePercentage as money = convert(money,'.03')

DECLARE @OneYearAgoToday DATE
Set @OneYearAgoToday = DATEADD(year,-1, GETDATE())
--*************To get First Day LAST Month
DECLARE @FirstDayLASTMonth DATE
Set @FirstDayLASTMonth = DATEADD(month, DATEDIFF(month, -1, getdate()) - 2, 0)
--*************To get Last Day LAST Month
DECLARE @LastDayLASTmonth DATE
Set @LastDayLASTmonth = DATEADD(ss, -1, DATEADD(month, DATEDIFF(month, 0, getdate()), 0))


Set @OneYearAgoToday = DATEADD(year,-1, @today)

--*************To get First Day LAST Month


--select dbo.RPT_DATE_FMT(@FirstDayLASTMonth) + ' to ' + dbo.RPT_DATE_FMT(@LastDayLASTmonth) as 'Invoices Paid On What Dates' 

;
with
cte_base
as
(
  select

    cc.CLIENT_NAME                                                                           as 'Client Name'
  , ci.INVOICE_NUMBER                                                       as 'Inv #'
  , dbo.RPT_DATE_FMT(ci.INVOICE_DATE)                                                        as 'Invoice Date'
  , dbo.RPT_DATE_FMT(ci.Date_Collected)                                                      as 'Date Collected'
  , convert(varchar,ci.SpEdCare_After_AnI_Terminated)                                        as 'SpEdCare Share'
  , dbo.RPT_DATE_FMT(cc.FIRST_CHECK)                                                         as '1st Check'
  , convert(varchar,iif( (convert(date,cc.FIRST_CHECK) < @OneYearAgoToday),'0','1') )                  as 'NEW Client Marker'  
  , convert(money,(round((ci.SpEdCare_After_AnI_Terminated *  @spedcareSharePercentage),2))) as '3%'
  
FROM [dbo].[Client_Invoices] as ci
JOIN [dbo].[CLIENTS_Client]  as cc on cc.CLIENT_ID = ci.CLIENT_ID

WHERE (
      (convert(date,ci.Date_Collected) between @FirstDayLASTMonth and @LastDayLASTmonth)
  and (ci.Date_Collected is NOT NULL)
  and (ci.Revenue_Program = 'LEA')
)
)
,
cte_detail
as
(
select * from cte_base
)
,
cte_summary
as
(
  select
   [Client Name]       = ''
  ,[Inv #]             = ''
  ,[Invoice Date]      = ''
  ,[Date Collected]    = ''
  ,[SpEdCare Share]    = ''
  ,[1st Check]         = ''
  ,[NEW Client Marker] = ''
  ,[SpEdCare Share 1%] = sum(cb.[3%]) 
 
  from cte_base as cb
)
,
cte_combo
as
(
select top 1000000 * from cte_detail order by [Client Name]
--union all
--select * from cte_summary
)
insert into @retDetail
select * from cte_combo

return
end
go

 GRANT SELECT ON [dbo].[InvoicesLastMonth] to webuser
 GO
