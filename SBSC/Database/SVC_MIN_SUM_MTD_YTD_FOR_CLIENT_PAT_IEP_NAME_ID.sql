USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SVC_MIN_SUM_MTD_YTD_FOR_CLIENT_PAT_IEP_NAME_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SVC_MIN_SUM_MTD_YTD_FOR_CLIENT_PAT_IEP_NAME_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SVC_MIN_SUM_MTD_YTD_FOR_CLIENT_PAT_IEP_NAME_ID] (
    @clientID       bigint
  , @patID          bigint
  , @iep            bit
  , @nameID         bigint
  , @refDate        date
)

returns @recs table (
    clientID     bigint
  , patID        bigint
  , nameID       bigint
  , startDateYtd date
  , endDateYtd   date
  , startDateMtd date
  , endDateMtd   date
  , ytdNumMins   int
  , mtdNumMins   int
  , ytdNumSvcs   int
  , mtdNumSvcs   int
  , ytdDosMin    date
  , ytdDosMax    date
  , mtdDosMin    date
  , mtdDosMax    date
 ) 
  
as
begin

if (@clientID is null) return
if (@patID    is null) return
if (@iep      is null) return
if (@refDate  is null) return
if (@nameID   is null) return

declare @pracGroupServiceClassNameID as bigint
declare @svcTypeID as int
declare @svcSubTypeID as int

declare @svcData as table (
    clientID     bigint
  , patID        bigint
  , nameID       bigint
  , startDateYtd date
  , endDateYtd   date
  , startDateMtd date
  , endDateMtd   date
)

/******************************************************************************
 * Get class of group and service
 ******************************************************************************/

select top 1 
    @pracGroupServiceClassNameID = GROUP_SERVICE_CLASS_NAME_ID
  , @svcTypeID                   = SERVICE_TYPE_ID
  , @svcSubTypeID                = SERVICE_SUB_TYPE_1_ID  
from dbo.CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA()
where (
      (GROUP_SERVICE_CLASS_PARTITION_ID = 1)
  and (SERVICE_NAME_ID = @nameID) 
  and (IEP_OR_IFSP     = @iep)
)

/******************************************************************************
 * Get dates
 ******************************************************************************/

insert into @svcData 
select top 1 
   @clientID as clientID
 , @patID    as patID
 , @nameID   as nameID
 , FY_START  as startDateYtd
 , FY_END    as endDateYtd
 , convert ( date,dbo.DATE_MONTH_START_END ( @refDate,0 ) ) as startDateMtd
 , convert ( date,dbo.DATE_MONTH_START_END ( @refDate,1 ) ) as endDateYtd
from dbo.COMPANY_FISCAL_YEARS 
where 
  @refDate between FY_START and FY_END

/******************************************************************************
 * Get totals
 ******************************************************************************/

insert into @recs
select top 1
   sd.*
  ,ytd.numMins as ytdNumMins
  ,mtd.numMins as mtdNumMins
  ,ytd.numSvcs as ytdNumSvcs
  ,mtd.numSvcs as mtdNumSvcs
  ,ytd.dosMin  as ytdDosMin
  ,ytd.dosMax  as ytdDosMax
  ,mtd.dosMin  as mtdDosMin
  ,mtd.dosMax  as mtdDosMax  
from @svcData as sd

cross apply (
  
  select top 1
  
    numMins = TOT_MINS_PRESENT
  , numSvcs = NUM_SVCS_PRESENT
  , dosMin  = MIN_DOS
  , dosMax  = MAX_DOS
  
  from dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE (
 
     null
   , null
   , null
   , @clientID
   , @patID
   , sd.startDateYtd
   , sd.endDateYtd
   , @pracGroupServiceClassNameID
  )
  where (
        (IEP_OR_IFSP = @iep)
    and (SERVICE_TYPE_ID = @svcTypeID)
    and SERVICE_SUB_TYPE_ID = @svcSubTypeID 
  )
) as ytd

cross apply (
  
  select top 1
  
    numMins = TOT_MINS_PRESENT
  , numSvcs = NUM_SVCS_PRESENT
  , dosMin  = MIN_DOS
  , dosMax  = MAX_DOS
  
  from dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE (
 
     null
   , null
   , null
   , @clientID
   , @patID
   , sd.startDateMtd
   , sd.endDateMtd
   , @pracGroupServiceClassNameID
  )
  where (
        (IEP_OR_IFSP         = @iep)
    and (SERVICE_TYPE_ID     = @svcTypeID )
    and (SERVICE_SUB_TYPE_ID = @svcSubTypeID )
 )
) as mtd

return
end
go
