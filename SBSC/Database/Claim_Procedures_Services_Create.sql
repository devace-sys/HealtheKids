/* TODO: Add support for new claim procedure fields */

USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claim_Procedures_Services_Create') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.Claim_Procedures_Services_Create
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE [dbo].[Claim_Procedures_Services_Create] (
  @updateSnxData            bit = 0
, @userID                   bigint
, @svcName                  nvarchar(100) 
, @procName                 nvarchar(50) 
, @procCode                 nchar(10)  
, @intensityOfSvcModifier   nchar(10)  
, @inPerson                 bit  
, @teleHealth               bit  
, @iep                      bit  
, @ifsp                     bit  
, @noPlan                   bit  
, @cybhi                    bit
, @ruHealth                 bit
, @svcFee                   money
, @effectiveDate            date 
, @expirationDate           date 
, @minUnits                 int 
, @maxUnits                 int 
, @unitType                 varchar(50)
, @serviceTypeID            int
, @serviceSubTypeID         int
, @yearlyFlag               nchar(10)
, @diagnosisCode            nchar(10)
, @diagnosisCodeIcd10       nchar(8) 
, @putIn837                 bit
, @isSvcSelection           bit
, @allowedGroupsDataFormat  int         /* 1 = Modifers, 2 = Group IDS, 3 = Group Names */
, @allowedGroupsDataCSV     varchar(max)
)  
AS    
BEGIN    
   

/***************************************************************************    
 * Claim_Procedures_Services_Create */    
/**    
 ***************************************************************************/        
     
SET NOCOUNT ON    

declare @tranOpen  as bit = 0

BEGIN TRY    
begin transaction

set @tranOpen = 1   

declare @today                    as datetime = getdate()
declare @refDate                  as date     = convert(date,@today)
declare @nameIdIfspIepInPerson    as bigint 
declare @nameIdIfspIepTelehealth  as bigint 
declare @nameIdNoPlanInPerson     as bigint 
declare @nameIdNoPlanTelehealth   as bigint 
declare @nameIdCybhiInPerson      as bigint
declare @nameIdCybhiTelehealth    as bigint
declare @nameIdRuHealthInPerson   as bigint
declare @nameIdRuHealthTelehealth as bigint

declare @minIdx                   as bigint
declare @maxIdx                   as bigint
declare @curIdx                   as bigint

declare @claimProceduresAndAllowedGroups as table (
	  [IDX]                  bigint 
	, [NEXT_MOD_SLOT]        int 
	, [TELE_HEALTH]          bit 
	, [ALLOWED_GROUPS_CSV]   varchar(max) 
	, [NO_PLAN_NAME]         int 
	, [IEP_IFSP_NAME]        int 
	, [PROCEDURE_CODE]       nchar(10)      
	, [PROCEDURE_MODIFIER_1] nchar (10)    
	, [PROCEDURE_MODIFIER_2] nchar (10)    
	, [PROCEDURE_MODIFIER_3] nchar (10)    
	, [PROCEDURE_NAME]       nvarchar (50)
    , [DATE_ADDED]           datetime 
	, [DATE_MODIFIED]        datetime
	, [DATE_EFFECTIVE]       datetime 
	, [DATE_EXPIRES]         datetime
	, [IEP_REQUIRED]         nchar(10)
	, [SERVICE_FEE]          numeric (18, 2)
    , [MAX_UNITS]            nchar(10)
    , [MAX_SERVICE_UNITS]    nchar(10)
	, [TCM_LOW_RATE]         nchar(10) 
	, [TCM_MEDIUM_RATE]      nchar(10) 
	, [TCM_HIGH_RATE]        nchar(10) 
	, [OVER_17_FEE]          nchar(10) 
	, [UNDER_18_FEE]         nchar(10) 
	, [PAGE]                 nchar(10) 
	, [DIAGNOSIS_CODE]       nchar(10) 
	, YEARLY_FLAG            nchar(10) 
	, PUT_IN_837             bit 
	, COMBINE_INTO_PROXY     bit 
	, LINK_TO_SERVICE        bit 
	, [Active]               bit 
	, [ICD_10_DIAGNOSIS_CODE] nchar(8) 
	, [UNIT_TYPE]             varchar(50) 
	, [MIN_UNITS]             nchar(10) 
	, [PROCEDURE_MODIFIER_4]  nchar (10)    
	, [SERVICE_SELECTION]     bit 
	, [SERVICE_TYPE_ID]       int 
	, [SERVICE_SUB_TYPE_1_ID] int
	, [SERVICE_SUB_TYPE_2_ID] int
	, [CPT_PROCEDURE]         bit    
	, PREVIOUS_PROCEDURE_ID   int 
	, PARENT_PROCEDURE_ID     int
	, SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS           bit 
	, SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA bit 
	, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS         bit 
	, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE         int
	, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE  int
	, PLACE_OF_SERVICE_CODE                                              varchar (4) 
	, HAS_LOGICAL_MODIFIER_22                                            bit
    , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS                               bit         default 0 
	, SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT                     int         default -1
	, CYBHI_NAME                                                         int
	, billingProgramID                                                   tinyint
	, RU_HEALTH_NAME                                                     int
 )  

/* Create service names */

exec dbo.Claim_Procedures_Service_Names_Create_Core 
    @svcName
  , @inPerson  
  , @teleHealth
  , @iep  
  , @ifsp 
  , @noPlan
  , @cybhi
  , @ruHealth
  , @nameIdIfspIepInPerson    output
  , @nameIdIfspIepTelehealth  output
  , @nameIdNoPlanInPerson     output
  , @nameIdNoPlanTelehealth   output
  , @nameIdCybhiInPerson      output
  , @nameIdCybhiTelehealth    output
  , @nameIdRuHealthInPerson   output
  , @nameIdRuHealthTelehealth output


/* Get claim procedure data and allowed group data */

insert into @claimProceduresAndAllowedGroups
select 
  t1.*
from dbo.Claim_Procedures_Generate_New_Procedures_Data_Core (
    @procName 
  , @inPerson
  , @teleHealth
  , @iep 
  , @ifsp
  , @noPlan
  , @cybhi
  , @ruHealth
  , @nameIdIfspIepInPerson 
  , @nameIdIfspIepTelehealth 
  , @nameIdNoPlanInPerson  
  , @nameIdNoPlanTelehealth
  , @nameIdCybhiInPerson
  , @nameIdCybhiTelehealth
  , @nameIdRuHealthInPerson
  , @nameIdRuHealthTelehealth

  , @procCode                
  , @intensityOfSvcModifier
  , @allowedGroupsDataFormat  
  , @allowedGroupsDataCSV
  , @minUnits
  , @maxUnits
  , @unitType
  , @serviceTypeID 
  , @serviceSubTypeID 
  , @yearlyFlag 
  , @diagnosisCode 
  , @diagnosisCodeIcd10 
  , @svcFee 
  , @effectiveDate 
  , @expirationDate
  , @putIn837   
  , @isSvcSelection
  ) as t1              

/* Create procedure and allowed procedure records */

select @minIdx = min(cp.IDX), @maxIdx = max(cp.IDX) from @claimProceduresAndAllowedGroups as cp
set @curIdx = @minIdx

while (@curIdx <= @maxIdx)
begin
  
  declare @allowedGroups as table (
      IDX          bigint identity(1,1)
	, GROUP_ID     bigint
	, PROCEDURE_ID bigint
  )
  
  delete  @allowedGroups
  declare @allowedGroupsCsv as varchar(max) = ''
  declare @procedureID      as bigint       = null

  /* Save new procedure record */

  insert into dbo.CLAIM_Procedures (
        [NO_PLAN_NAME]
	  , [IEP_IFSP_NAME] 
	  , PROCEDURE_CODE
      , [PROCEDURE_MODIFIER_1] 
      , [PROCEDURE_MODIFIER_2] 
      , [PROCEDURE_MODIFIER_3] 
	  , [PROCEDURE_NAME] 
      , [DATE_ADDED] 
      , [DATE_MODIFIED]
      , [DATE_EFFECTIVE] 
      , [DATE_EXPIRES] 
      , [IEP_REQUIRED]
      , [SERVICE_FEE] 
      , [MAX_UNITS]
      , [MAX_SERVICE_UNITS]
      , [TCM_LOW_RATE]
      , [TCM_MEDIUM_RATE]
      , [TCM_HIGH_RATE]
      , [OVER_17_FEE]
      , [UNDER_18_FEE]
      , [PAGE]
      , [DIAGNOSIS_CODE]
      , [YEARLY_FLAG]
	  , [PUT_IN_837] 
      , [COMBINE_INTO_PROXY]
      , [LINK_TO_SERVICE]
      , [Active]
      , [ICD_10_DIAGNOSIS_CODE]
      , [UNIT_TYPE]
      , [MIN_UNITS]	  
	  , [PROCEDURE_MODIFIER_4] 
      , [SERVICE_SELECTION]
      , [SERVICE_TYPE_ID]    
      , [SERVICE_SUB_TYPE_1_ID] 
      , [SERVICE_SUB_TYPE_2_ID] 
      , [CPT_PROCEDURE]
      , PREVIOUS_PROCEDURE_ID 
      , [PARENT_PROCEDURE_ID]
      , [SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS]
      , [SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA]
      , [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS]
      , [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE]
      , [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE]
      , [PLACE_OF_SERVICE_CODE]
      , [HAS_LOGICAL_MODIFIER_22]
      
	  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS
	  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT 
      , CYBHI_NAME
	  , billingProgramID
	  , RU_HEALTH_NAME
  )
  select top 1  
        [NO_PLAN_NAME]
	  , [IEP_IFSP_NAME] 
	  , PROCEDURE_CODE
      , [PROCEDURE_MODIFIER_1] 
      , [PROCEDURE_MODIFIER_2] 
      , [PROCEDURE_MODIFIER_3] 
	  , [PROCEDURE_NAME] 
      , [DATE_ADDED] 
      , [DATE_MODIFIED]
      , [DATE_EFFECTIVE] 
      , [DATE_EXPIRES] 
      , [IEP_REQUIRED]
      , [SERVICE_FEE] 
      , [MAX_UNITS]
      , [MAX_SERVICE_UNITS]
      , [TCM_LOW_RATE]
      , [TCM_MEDIUM_RATE]
      , [TCM_HIGH_RATE]
      , [OVER_17_FEE]
      , [UNDER_18_FEE]
      , [PAGE]
      , [DIAGNOSIS_CODE]
      , [YEARLY_FLAG]
	  , [PUT_IN_837] 
      , [COMBINE_INTO_PROXY]
      , [LINK_TO_SERVICE]
      , [Active]
      , [ICD_10_DIAGNOSIS_CODE]
      , [UNIT_TYPE]
      , [MIN_UNITS]	  
	  , [PROCEDURE_MODIFIER_4] 
      , [SERVICE_SELECTION]
      , [SERVICE_TYPE_ID]    
      , [SERVICE_SUB_TYPE_1_ID] 
      , [SERVICE_SUB_TYPE_2_ID] 
      , [CPT_PROCEDURE]
      , PREVIOUS_PROCEDURE_ID 
      , [PARENT_PROCEDURE_ID]
      , [SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS]
      , [SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA]
      , [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS]
      , [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE]
      , [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE]
      , [PLACE_OF_SERVICE_CODE]
      , [HAS_LOGICAL_MODIFIER_22]
	  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS
	  , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT 
      , CYBHI_NAME
	  , billingProgramID
	  , RU_HEALTH_NAME
  from @claimProceduresAndAllowedGroups as t1 
  where (t1.IDX = @curIdx)

  /* Save new procedure_id we will use this to create allowed procedure data */

  set @procedureID = SCOPE_IDENTITY()
  
  /* Fetch allowed groups csv */
  
  select top 1 
    @allowedGroupsCsv = t1.ALLOWED_GROUPS_CSV 
  from @claimProceduresAndAllowedGroups as t1 
  where (t1.IDX = @curIdx)
  
  /* Create new allowed procedure data */

  insert into @allowedGroups (GROUP_ID,PROCEDURE_ID)
  select 
     GROUP_ID     = t2.[value] 
	,PROCEDURE_ID = @procedureID
  from string_split(@allowedGroupsCsv,',') as t2
  
  /* Save allowed procedure records.  
   * Note: This table does not have an identity column
   * so we have to provide this functionality manually
   */

  insert into dbo.CLAIM_Allowed_Procedures
  select 
      ALLOWED_PROCEDURE_ID = ( (SELECT MAX(allowed_procedure_id) FROM dbo.CLAIM_Allowed_Procedures) + (ROW_NUMBER() OVER (ORDER BY ag.IDX)) )
    , ag.GROUP_ID
    , ag.PROCEDURE_ID 
    , CLIENT_ID = null
 from @allowedGroups  as ag 
 
 set @curIdx = @curIdx + 1

end /* while */

/* Add new services to xref and also add any services that may have gotten missed */

insert into dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA (
    planTypeID
  , groupID
  , nameID
  , svcTypeId
  , svcSubType1Id
  , iepIfspNameId
  , noPlanNameId
  , cybhiNameId
  , ruHealthNameId
  , serviceNameIdIsInIfspIep
  , serviceNameIdIsInNoPlan
  , serviceNameIdIsInCybhi
  , serviceNameIdIsInRuHealth
  , isStandard
  , hasFormData
  , hasClientID
  , formDataJSON
  , clientID
  , createdOn
  , createdBy
  , active
)
select distinct 
     planTypeID     = svc.SERVICE_PLAN_TYPE_ID
   , groupID        = svc.GROUP_ID
   , nameID         = svc.SERVICE_NAME_ID
   , svcTypeId      = svc.SERVICE_TYPE_ID
   , svcSubType1Id  = svc.SERVICE_SUB_TYPE_1_ID
   , iepIfspNameId  = svc.PROCEDURE_IEP_IFSP_NAME_ID
   , noPlanNameId   = svc.PROCEDURE_NO_PLAN_NAME_ID
   , cybhiNameId    = svc.PROCEDURE_CYBHI_NAME_ID
   , ruHealthNameId = svc.PROCEDURE_RU_HEALTH_NAME_ID
   , serviceNameIdIsInIfspIep  = convert(bit,(iif(svc.PROCEDURE_IEP_IFSP_NAME_ID   is not null,1,0)))
   , serviceNameIdIsInNoPlan   = convert(bit,(iif(svc.PROCEDURE_NO_PLAN_NAME_ID    is not null,1,0)))
   , serviceNameIdIsInCybhi    = convert(bit,(iif(svc.PROCEDURE_CYBHI_NAME_ID      is not null,1,0)))
   , serviceNameIdIsInRuHealth = convert(bit,(iif(svc.PROCEDURE_RU_HEALTH_NAME_ID  is not null,1,0)))
   , isStandard   = convert(bit,1)
   , hasFormData  = convert(bit,0)
   , hasClientID  = convert(bit,0)
   , formDataJSON = null
   , clientID     = null
   , createdOn    = @today
   , createdBy    = @userID
   , active       = convert(bit,1)
from dbo.SERVICES_VIEW_ALL_CORE (null,null,null,null,null,1,1,@refDate,1) as svc
join dbo.GROUP_Group                                                    as gg on  gg.GROUP_ID = svc.GROUP_ID
                                                                              and gg.GROUP_TYPE in (1,2)
                                                                              and gg.ACTIVE = 1
join dbo.CLAIM_Procedures                                               as cp on cp.PROCEDURE_ID = svc.PROCEDURE_ID
                                                                              and cp.Active = 1
																			  and cp.DATE_EXPIRES is null
outer apply (
  select top 1
    xfd1.id 
  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as xfd1 
  where (
         (xfd1.planTypeID    = svc.SERVICE_PLAN_TYPE_ID)
     and (xfd1.groupID       = svc.GROUP_ID)
     and (xfd1.nameID        = svc.SERVICE_NAME_ID)
     and (xfd1.svcTypeId     = svc.SERVICE_TYPE_ID)
     and (isnull(xfd1.svcSubType1Id,0)  = isnull(svc.SERVICE_SUB_TYPE_1_ID,       0))
     and (isnull(xfd1.iepIfspNameId,0)  = isnull(svc.PROCEDURE_IEP_IFSP_NAME_ID,  0))
     and (isnull(xfd1.noPlanNameId,0)   = isnull(svc.PROCEDURE_NO_PLAN_NAME_ID,   0))
     and (isnull(xfd1.cybhiNameId,0)    = isnull(svc.PROCEDURE_CYBHI_NAME_ID,     0))
	 and (isnull(xfd1.ruHealthNameId,0) = isnull(svc.PROCEDURE_RU_HEALTH_NAME_ID, 0))
	 and (xfd1.isStandard    = 1)
	 and (xfd1.active        = 1)
  )
) as xfd2
where 
    (xfd2.id is null)


/* Update modality xref.  Add any recs that are missing */

insert into dbo.CLAIM_SERVICE_NAME_ALT_MODALITY_XREF (
      groupID 
    , planTypeID 
    , nameID     
    , nameIDAltModality
	, generatedOn
)
select 
    groupID                               = gvam.GROUP_ID
  , planTypeID                            = gvam.SERVICE_PLAN_TYPE_ID
  , nameID                                = gvam.SERVICE_NAME_ID
  , nameIDAltModality                     = gvam.SERVICE_NAME_ID_ALT_MODALITY
  , generatedOn                           = @today
from dbo.SERVICES_GENERATE_AND_VIEW_ALT_MODALITY() as gvam
left join dbo.CLAIM_SERVICE_NAME_ALT_MODALITY_XREF as csnamx on ((csnamx.groupID    = gvam.GROUP_ID)
                                                             and (csnamx.planTypeID = gvam.SERVICE_PLAN_TYPE_ID)
                                                             and (csnamx.nameID     = gvam.SERVICE_NAME_ID))
where 
  (csnamx.groupID is null)

/* Update modality xref.  Update existing with any changes */

update csnamx
set 
   csnamx.nameIDAltModality                     = gvam.SERVICE_NAME_ID_ALT_MODALITY
 , generatedOn                                  = @today
from dbo.SERVICES_GENERATE_AND_VIEW_ALT_MODALITY() as gvam
join dbo.CLAIM_SERVICE_NAME_ALT_MODALITY_XREF      as csnamx on ((csnamx.groupID    = gvam.GROUP_ID)
                                                             and (csnamx.planTypeID = gvam.SERVICE_PLAN_TYPE_ID)
                                                             and (csnamx.nameID     = gvam.SERVICE_NAME_ID))
where (isnull(csnamx.nameIDAltModality,-1) != isnull(gvam.SERVICE_NAME_ID_ALT_MODALITY,-1))

/* Update cached snx data */

if (@updateSnxData = 1)
begin
  exec dbo.CLAIM_SERVICE_NAME_XREF_CALPAD_CODE_SNX_DATA_CACHED_UPDATE_CORE
end

commit transaction


set @tranOpen = 0
end try
begin catch
 
 /*-------------------------------    
   * If we end up here something    
   * went wrong.  Cancel any pending    
   * transactions and return any    
   * error any error messages to    
   * the caller    
   *------------------------------*/    
       
  -- Error or raise error with severity 11 to 19 will be caught here    
     
  IF @tranOpen = 1 ROLLBACK TRANSACTION    
     
  DECLARE @ErrorMessage  AS NVARCHAR(4000)    
  DECLARE @ErrorSeverity AS INT    
  DECLARE @ErrorState    AS INT    
     
  SELECT  @ErrorMessage  = ERROR_MESSAGE(),    
          @ErrorSeverity = ERROR_SEVERITY(),    
          @ErrorState    = ERROR_STATE()    
     
  SET @ErrorMessage = @ErrorMessage + ' ' + ERROR_PROCEDURE() + ' ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ']'    
     
  -- Reraise the error so it returns back to the server    
     
  RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState)    
 
end catch
	 
END      
GO

