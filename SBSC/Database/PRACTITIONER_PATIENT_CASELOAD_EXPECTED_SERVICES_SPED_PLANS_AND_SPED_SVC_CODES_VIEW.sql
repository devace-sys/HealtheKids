USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW] (
    @userID                BIGINT    
  , @userGroup             INT    
  , @userRank              INT     
  , @clientID              bigint
  , @pracID                bigint     
  , @patID                 bigint
  , @term				   varchar(256) = ''
  , @showCurrentOnly       bit = 1
)

/**************************************************************************************
 * PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW */
/**
 **************************************************************************************/
    
returns @recs table (
    id                       int identity(1,1)
  , [name]                   varchar(266)
  , spEdFreqCodeStr          varchar(10)  default('')
  , spEdFreqCodeAndNameShort varchar(266) default('')
  , minsPerFreqStr           varchar(50)  default('')
  , startDateYYYYMMDD        varchar(50)  default('')
  , endDateYYYYMMDD          varchar(50)  default('')
  , spEdServiceCodeStr       varchar(10)  default('')
  , spEdFreqName             varchar(256) default('')
  , numSvcLinesStr           varchar(50)  default('0')
  , hasSvcLinesDetailsStr    varchar(50)  default('No')
  , svcLinesDetailsJSON      varchar(max) default('[]')
  , selContextHTML           varchar(max) default ('')  
  , isPatPlanStr             varchar(50)  default ('No')
)   
as   
begin

declare @today   as datetime = getdate()
declare @refDate as datetime = null
declare @svcCodesPracSupports as table (
      [name]              varchar(266)
	, spEdServiceCode     int
    , spEdServiceCodeStr  varchar(10)  
    , spEdServiceName     varchar(256)
	  
  unique clustered (spEdServiceCode)
)

/*###########################################################################
  # Init term
  ###########################################################################*/

set @term = trim(isnull(@term,''))

/*###########################################################################
  # If we are only showing current plans then calculate a value for 
  # @ref date (oldest date of service allowed). 
  ###########################################################################*/

if (@showCurrentOnly = 1)
begin
  set @refDate = dbo.CALC_OLDEST_DOS_ALLOWED(convert(date,(@today)))
end
else
begin
  set @refDate = null
end

/*###########################################################################
  # Get spEd service codes that this practitioner supports
  # and limit selection to what matches @term
  ###########################################################################*/

insert into @svcCodesPracSupports (
    name
  , spEdServiceCode
  , spEdServiceCodeStr
  , spEdServiceName
)
select 
    q2.[name]
  , q2.spEdServiceCode
  , q2.spEdServiceCodeStr
  , q2.spEdServiceName
from
(
  select
    [name] = (q1.spEdServiceCodeStr  + ' ' + q1.spEdServiceName)    
    , q1.*
  from
  (
    select 
        spEdServiceCode    = t1.spEdSvcCode
      , spEdServiceCodeStr = convert(varchar(10),t1.spEdSvcCode)
      , spEdServiceName    = ss.[name]
    from dbo.Practitioner_Patient_Caseload_Expected_Services_Get_Pracs_Associated_SpEd_Services_Core (@userID,@userGroup,@userRank,@clientID,@pracID) as t1
    join dbo.SpEd_Service as ss on ss.codeValue = t1.spEdSvcCode
  ) as q1
) as q2
where ( 
      (1=1)
  and ((q2.[name] like ('%' + @term + '%')))
)

/*###########################################################################
  # Find all plans for this patient based on each spEdService code the
  # practitioner supports (limited to term) and refDate (if applicable)
  # and add these plans to the output (if any)
  ###########################################################################*/

insert into @recs (
    [name]
  , spEdFreqCodeStr 
  , spEdFreqCodeAndNameShort 
  , minsPerFreqStr 
  , startDateYYYYMMDD 
  , endDateYYYYMMDD 
  , spEdServiceCodeStr 
  , spEdFreqName 
  , numSvcLinesStr 
  , hasSvcLinesDetailsStr 
  , svcLinesDetailsJSON 
  , selContextHTML
  , isPatPlanStr  
)
select 
    ppsvc2.[name] 
  , ppsvc2.spEdFreqCodeStr 
  , ppsvc2.spEdFreqCodeAndNameShort 
  , ppsvc2.minsPerFreqStr 
  , ppsvc2.startDateYYYYMMDD 
  , ppsvc2.endDateYYYYMMDD 
  , ppsvc2.spEdServiceCodeStr 
  , ppsvc2.spEdFreqName 
  , ppsvc2.numSvcLinesStr 
  , ppsvc2.hasSvcLinesDetailsStr 
  , ppsvc2.svcLinesDetailsJSON 
  , ppsvc2.selContextHTML
  , 'Yes' 
from @svcCodesPracSupports as scps
cross apply (
  select 
    ppsvc1.* 
  from dbo.PATIENT_PROMISED_SERVICES_VIEW_CORE (@clientID, @patID, scps.spEdServiceCode, '', @refDate, null, null, 1, @today) as ppsvc1
) as ppsvc2

/*###########################################################################
  # Add the spEd service codes the practitioner supports to the output
  # (if any)
  ###########################################################################*/

insert into @recs (
    [name]
  , spEdServiceCodeStr
  , selContextHTML
)
select 
   [name]             = (scps.spEdServiceCodeStr  + ' ' + scps.spEdServiceName)  
 , spEdServiceCodeStr = scps.spEdServiceCodeStr
 , selContextHTML     = 'Selecting this service code will add a new plan to the students promised services when you save this record.<br>You will need to provide the plan start date, plan end date, frequency and duration below.'
from @svcCodesPracSupports as scps

/*###########################################################################
  # Done
  ###########################################################################*/

return

end

GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PRACTITIONER_PATIENT_CASELOAD_EXPECTED_SERVICES_SPED_PLANS_AND_SPED_SVC_CODES_VIEW] TO [webuser]
GO