USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.UPDATE_CLIENT_FY_TOTALS') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.UPDATE_CLIENT_FY_TOTALS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[UPDATE_CLIENT_FY_TOTALS]  
AS    

BEGIN     
    
/***************************************************************************    
 * UPDATE_CLIENT_FY_TOTALS */    
/**    
 * 
 ***************************************************************************/         

SET NOCOUNT ON        


BEGIN TRY

declare @fiscalYears as table (
   WHAT_FY                 int
  ,FY_DEFINITION           varchar(20)
  ,FY_START                date
  ,FY_END                  date
)

declare @clientFiscalYears as table (
    IDX                     bigint identity (1,1)
  , CLIENT_ID               bigint
  , LEA                     bit
  , WHAT_FY                 int
  , FY_DEFINITION           varchar(20)
  , FY_START                date
  , FY_END                  date
    unique    clustered (IDX)
  , unique nonclustered (CLIENT_ID, WHAT_FY, IDX)
)

declare @clientsWithFinTotals as table (
    IDX                     bigint identity (1,1)
  , CLIENT_ID               bigint
  , WHAT_FY                 int
  , FY_DEFINITION           varchar(20)
  , FY_START                date
  , FY_END                  date
  , TOT_SVCS                money
  , TOT_ADJS                money
  , TOT_STATE_FEES          money
  , TOT_DISB                numeric (18,8)

    unique    clustered (IDX)
  , unique nonclustered (CLIENT_ID, WHAT_FY, IDX)
)


declare @today              as datetime = getdate()
declare @okToReportUpToDate as date
declare @startDate          as date
declare @endDate            as date

/*============================================================
 * Compute date ranges
 *============================================================*/  

RAISERROR ('Computing data ranges to use', 0, 1) WITH NOWAIT

select top 1 @okToReportUpToDate = convert(date,OKToPublishUpToDate) from dbo.REPORT_PUBLICATION_CLASSES where (ID = 1)

select @startDate = convert(date,MIN(DATE_ADJUDICATED)) from dbo.CLAIM_Claim_Adjudication
set @endDate = convert(date,@okToReportUpToDate)

/*============================================================
 * Get the fiscal years to use.
 *============================================================*/  

RAISERROR ('Getting fiscal years to use', 0, 1) WITH NOWAIT

insert into @fiscalYears
select 
    WHAT_FY = (ROW_NUMBER() over (ORDER BY fy.FY_START desc) -1)
  , fy.FY_DEFINITION
  , fy.FY_START
  , fy.FY_END    
from dbo.COMPANY_FISCAL_YEARS as fy
where fy.FY_START between @startDate and @endDate
  

/*============================================================
 * Get the clients and fiscal years to report out on
 *============================================================*/  

RAISERROR ('Getting combination of clients and fiscal years', 0, 1) WITH NOWAIT

insert into @clientFiscalYears
 select 
    clc.CLIENT_ID
  , clc.LEA
  , fy.*
from       dbo.CLIENTS_CLIENT as clc
cross join @fiscalYears       as fy

/*============================================================
 * Get the financial totals that exist
 *============================================================*/  

RAISERROR ('Getting financial totals that exist', 0, 1) WITH NOWAIT

insert into @clientsWithFinTotals
select 
     frd.CLIENT_ID
   , fy.WHAT_FY
   , fy.FY_DEFINITION
   , fy.FY_START
   , fy.FY_END
   , frd.TOT_SVCS
   , frd.TOT_ADJS
   , TOT_STATE_FEES = frd.TOT_PAID - frd.TOT_DISB
   , frd.TOT_DISB 

from @fiscalYears as fy

cross apply (

  select * from dbo.COMPUTE_CLAIMS_PAID_SUMMARY_BY_FY_CORE (fy.FY_START, fy.FY_END, @okToReportUpToDate) as ccps
    
) as frd

/*============================================================
 * Drop indexes
 *============================================================*/  

RAISERROR ('Droping indexes on CLIENT_FY_TOTALS', 0, 1) WITH NOWAIT
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[CLIENT_FY_TOTALS]') AND name = N'CLIENT_ID_WHAT_FY')
DROP INDEX [CLIENT_ID_WHAT_FY] ON [dbo].[CLIENT_FY_TOTALS] WITH ( ONLINE = OFF )

/*============================================================
 * Truncate table
 *============================================================*/  

RAISERROR ('Truncating CLIENT_FY_TOTALS', 0, 1) WITH NOWAIT
truncate table dbo.CLIENT_FY_TOTALS

/*============================================================
 * Get fresh data
 *============================================================*/  

RAISERROR ('Repopulating CLIENT_FY_TOTALS', 0, 1) WITH NOWAIT

insert into dbo.CLIENT_FY_TOTALS
  select       
       fy.CLIENT_ID
     , fy.LEA 
     , fy.WHAT_FY
     , fy.FY_DEFINITION
     , fy.FY_START
     , fy.FY_END
     , frd.TOT_SVCS
     , frd.TOT_ADJS
     , frd.TOT_STATE_FEES
     , frd.TOT_DISB 
     , OK_TO_PUBLISH = @okToReportUpToDate
     , LAST_UPDATED   = @today    

  from @clientFiscalYears as fy

  outer apply (
  
    select * from @clientsWithFinTotals as bd where bd.CLIENT_ID = fy.CLIENT_ID and bd.WHAT_FY = fy.WHAT_FY

  ) as frd  


/*============================================================
 * Recreate indexes
 *============================================================*/  

RAISERROR ('Creating indexes on CLIENT_FY_TOTALS', 0, 1) WITH NOWAIT

CREATE UNIQUE CLUSTERED INDEX [CLIENT_ID_WHAT_FY] ON [dbo].[CLIENT_FY_TOTALS] 
(
	[CLIENT_ID] ASC,
	[WHAT_FY] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


/*============================================================
 * Done
 *============================================================*/  

RAISERROR ('Done', 0, 1) WITH NOWAIT

RETURN(0)    
END TRY    
BEGIN CATCH    
    
  /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
         
  -- Error or raise error with severity 11 to 19 will be caught here          
      
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
      
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
      
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
      
  -- Reraise the error so it returns back to the server    
      
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
    
END CATCH    
END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT EXECUTE ON  [dbo].[UPDATE_CLIENT_FY_TOTALS] TO [webuser]
GO
