use SPEDMON
set nocount on

declare @835Data as XML

declare @835TransactionSets as table (
    Idx                             bigint identity(1,1)
  , TransactionControlNumber        char(4)
  , ClientNPI                       nchar(10)
  , ClientName                      varchar(256)
)

/********************************************************************************
 * Load XML document 
 ********************************************************************************/

RAISERROR ('Loading data', 0, 1) WITH NOWAIT

set @835Data = (
  select top 1 * from OPENROWSET (
    BULK 'C:\Transfer\Test835Files\20180823\CMCSUB9A7_01_835_082118.txt_import.xml', SINGLE_CLOB
  ) AS xmlData
)

declare @ClientNPI                as nchar(14) = N'1659489599'
declare @TransactionControlNumber as char(4) = ''

/********************************************************************************
 * Extract details
 ********************************************************************************/

RAISERROR ('Extracting details', 0, 1) WITH NOWAIT

insert into @835TransactionSets

select
    t1.ST.value    ('(ST02/text())[1]',           'char(4)')        as TransactionControlNumber
  , t1.PAYEE.value ('(N104/text())[1]',           'nchar(10)')      as ClientNPI
  , t1.PAYEE.value ('(N102/text())[1]',           'varchar(255)')   as ClientName
  
from
(
  select 
      col.query('./ST/*')                                     as ST
    , col.query('./Loop[@LoopId="1000B"]/N1/*')               as PAYEE
  from @835Data.nodes('/Transactions[1]/Transaction') as TX(col)
) as t1
  
select top 1 @TransactionControlNumber = TransactionControlNumber from @835TransactionSets where ClientNPI = @ClientNPI

select
     q2.LX
   , q2.L2100.value('(./Loop[1]/CLP[1]/CLP01[1]/text())[1]', 'varchar(256)')  as ClaimIDBackRef
   , q2.L2100.value('(./Loop[1]/CLP[1]/CLP02[1]/text())[1]', 'varchar(50)')   as ClaimStatusCode835  
   , q2.L2100.value('(./Loop[1]/CLP[1]/CLP03[1]/text())[1]', 'varchar(50)')   as ClaimAmountSubmitted
   , q2.L2100.value('(./Loop[1]/CLP[1]/CLP04[1]/text())[1]', 'varchar(50)')   as ClaimAmountPaid  
   , q2.L2100.value('(./Loop[1]/NM1[1]/NM103[1]/text())[1]', 'varchar(50)')   as LastName
   , q2.L2100.value('(./Loop[1]/NM1[1]/NM104[1]/text())[1]', 'varchar(50)')   as FirstName
   , q2.L2100.value('(./Loop[1]/NM1[1]/NM109[1]/text())[1]', 'char(14)')      as BIC
   , q2.L2110 
   
from
(
  select
      q1.LX
    , q1.L2100
    , q1.L2100.query('./Loop[1]/Loop[@LoopId="2110"][1]/.') as L2110
  from
  (
    select 
        L2000.col.value('(./LX[1]/LX01[1]/text())[1]','varchar(50)')    as LX
      , L2000.col.query('./Loop[@LoopId="2100"][1]/.')                  as L2100
    
    from @835Data.nodes('/Transactions[1]/Transaction[@ControlNumber[.= sql:variable("@TransactionControlNumber")]][1]/Loop[@LoopId="2000"]') as L2000(col)
  ) as q1
) as q2
