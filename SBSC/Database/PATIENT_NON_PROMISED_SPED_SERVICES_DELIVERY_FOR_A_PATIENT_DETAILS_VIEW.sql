USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_NON_PROMISED_SPED_SERVICES_DELIVERY_FOR_A_PATIENT_DETAILS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_NON_PROMISED_SPED_SERVICES_DELIVERY_FOR_A_PATIENT_DETAILS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[PATIENT_NON_PROMISED_SPED_SERVICES_DELIVERY_FOR_A_PATIENT_DETAILS_VIEW] (
    @clientID              int
  , @patID                 int
  , @planInEffectStartDate date
  , @planInEffectEndDate   date
)   

returns @recs table  (
    spEdServiceCode    int
  , spEdServiceName    varchar(512)
  , numOfSvcsEntered   int
  unique clustered  (spEdServiceCode)
)     
as
begin

/*============================================================
 * Early exit
 *===========================================================*/  

if (@clientID              is null) return
if (@patID                 is null) return
if (@planInEffectStartDate is null) return
if (@planInEffectEndDate   is null) return

declare @pps as table (
    spEdServiceCode                      int
  unique clustered (spEdServiceCode)
)

declare @pns as table (
    spEdServiceCode  int
  unique clustered (spEdServiceCode)
)

declare @snx as table (
      spEdSvcCodeValue    int
    , groupID             int
    , planTypeID          int
    , nameID              int
    , groupSvcClassNameID bigint
    , idx                 bigint identity(1,1)
  unique clustered (spEdSvcCodeValue, groupID, planTypeID, nameID, idx)
)
declare @planInEffectStartDateTime as datetime = @planInEffectStartDate
declare @planInEffectEndDateTime   as datetime = @planInEffectEndDate

/*============================================================
 * Get promised service codes
 *===========================================================*/  

insert into @pps (
  spEdServiceCode   
)
select distinct  
  lpps.spEdServiceCode
from dbo.PATIENT_PROMISED_SERVICES_LATEST_DATA (  @clientID
                                                , @patID
												, null												
												, null
												, null
												, null
												, null
												, @planInEffectStartDate
												, @planInEffectEndDate
												, null
												, null ) as lpps
where (
      (lpps.startDate <= lpps.endDate)
)

/*============================================================
 * Get non promised services
 *===========================================================*/  

insert into @pns (
  spEdServiceCode
)
select distinct  
  spEdServiceCode = ss.codeValue
from dbo.SpEd_Service as ss
left join @pps as pps on pps.spEdServiceCode = ss.codeValue
where (pps.spEdServiceCode is null)

/*============================================================
 * Get service name xref data
 *===========================================================*/  

insert into @snx (
    spEdSvcCodeValue
  , groupID 
  , planTypeID
  , nameID 
  , groupSvcClassNameID
)
select distinct
    snx.spEdSvcCodeValue
  , snx.groupID
  , snx.planTypeID
  , snx.nameID
  , snx.groupSvcClassNameID 
from    @pns                                           as ss
join    dbo.SpEd_Service_GroupID_PlanID_NameID_Data    as snx on snx.spEdSvcCodeValue = ss.spEdServiceCode

insert into @recs (
    spEdServiceCode
  , spEdServiceName
  , numOfSvcsEntered
)

select 
   pns.spEdServiceCode
 , spEdServiceName = ss.name
 , numOfSvcsEntered = count(sr.id)
from @pns                                      as pns
join @snx                                      as snx on snx.spEdSvcCodeValue = pns.spEdServiceCode 
join dbo.SERVICE_RECORDS                       as sr  on ( 
         /* Index predicate */
  (     (sr.clientID  = @clientID)
    and (sr.patID     = @patID)
	and (sr.dos between @planInEffectStartDateTime and @planInEffectEndDateTime)
	and (sr.groupID  = snx.groupID)
	and (sr.planType = snx.planTypeID)
	and (sr.nameID   = snx.nameID) 
	and (sr.id is not null)
  )     
  and (sr.state not in (99,199))
)
join dbo.SpEd_Service as ss on ss.codeValue = pns.spEdServiceCode

group by 
   pns.spEdServiceCode
  ,ss.[name]


return 

end 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_NON_PROMISED_SPED_SERVICES_DELIVERY_FOR_A_PATIENT_DETAILS_VIEW] TO [webuser]
GO