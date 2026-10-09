USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Claim_Procedures_Generate_New_Procedures_Data_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Claim_Procedures_Generate_New_Procedures_Data_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[Claim_Procedures_Generate_New_Procedures_Data_Core] (
    @procName                 nvarchar(50) = null
  , @inPerson                 bit  = 1
  , @teleHealth               bit  = 1 
  , @iep                      bit  = 0
  , @ifsp                     bit  = 0
  , @noPlan                   bit  = 0
  , @cybhi                    bit  = 0
  , @ruHealth                 bit  = 0

  , @nameIdIfspIepInPerson    bigint
  , @nameIdIfspIepTelehealth  bigint
  
  , @nameIdNoPlanInPerson     bigint
  , @nameIdNoPlanTelehealth   bigint
  
  , @nameIdCybhiInPerson      bigint
  , @nameIdCybhiTelehealth    bigint
  
  , @nameIdRuHealthInPerson      bigint
  , @nameIdRuHealthTelehealth    bigint
  
  , @procCode                 nchar(10)
  , @intensityOfSvcModifier   nvarchar(10)
  , @allowedGroupsDataFormat  int = 1          /* 1 = Modifers, 2 = Group IDS, 3 = Group Names */
  , @allowedGroupsDataCSV     varchar(max)
  , @minUnits                 int
  , @maxUnits                 int
  , @unitType                 varchar(50)
  , @serviceTypeID            int
  , @serviceSubTypeID         int
  , @yearlyFlag               nchar(10)
  , @diagnosisCode            nchar(10) 
  , @diagnosisCodeIcd10       nchar(8)
  , @svcFee                   money
  , @effectiveDate            date
  , @expirationDate           date = null
  , @putIn837                 bit  = 1
  , @isSvcSelection           bit  = 1
)  

returns @claimProcedures TABLE (
	  [IDX]                  bigint identity(1,1)
	, [NEXT_MOD_SLOT]        int default(0)
	, [TELE_HEALTH]          bit default(0)
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
	, [TCM_LOW_RATE]         nchar(10) default(N'0.00')
	, [TCM_MEDIUM_RATE]      nchar(10) default(N'0.00')
	, [TCM_HIGH_RATE]        nchar(10) default(N'0.00')
	, [OVER_17_FEE]          nchar(10) default(N'0.00')
	, [UNDER_18_FEE]         nchar(10) default(N'0.00')
	, [PAGE]                 nchar(10) default(N'-1')
	, [DIAGNOSIS_CODE]       nchar(10) 
	, YEARLY_FLAG            nchar(10) 
	, PUT_IN_837             bit default(1)
	, COMBINE_INTO_PROXY     bit default(1) 
	, LINK_TO_SERVICE        bit default 0
	, [Active]               bit default 1
	, [ICD_10_DIAGNOSIS_CODE] nchar(8) NULL
	, [UNIT_TYPE]             varchar(50) default ('MINUTES')
	, [MIN_UNITS]             nchar(10) default (N'1')
	, [PROCEDURE_MODIFIER_4] nchar (10)    
	, [SERVICE_SELECTION]     bit default(1)
	, [SERVICE_TYPE_ID]       int 
	, [SERVICE_SUB_TYPE_1_ID] int
	, [SERVICE_SUB_TYPE_2_ID] int
	, [CPT_PROCEDURE]         bit     default(1)
	, PREVIOUS_PROCEDURE_ID   int 
	, PARENT_PROCEDURE_ID     int
	, SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS           bit default(0)
	, SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA bit default(1)
	, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS         bit default(0)
	, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE         int
	, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE  int
	, PLACE_OF_SERVICE_CODE                                              varchar (4) default '89'
	, HAS_LOGICAL_MODIFIER_22                                            bit         default 0
    , SELECT_PROC_FOR_CLAIM_USING_NUM_MINS                               bit         default 0 
	, SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT                     int         default -1
    , CYBHI_NAME                                                         int
	, billingProgramID                                                   tinyint     default 1
	, RU_HEALTH_NAME                                                     int
 )  
as
begin   

declare @procNameInPersonIFSP       as nchar(50) = N''
declare @procNameInPersonIEP        as nchar(50) = N''
declare @procNameInPersonNoPlan     as nchar(50) = N''
declare @procNameInPersonCybhi      as nchar(50) = N''
declare @procNameInPersonRuHealth   as nchar(50) = N''

declare @procNameTeleHealthIFSP     as nchar(50) = N''
declare @procNameTeleHealthIEP      as nchar(50) = N''
declare @procNameTeleHealthNoPlan   as nchar(50) = N''
declare @procNameTeleHealthCybhi    as nchar(50) = N''
declare @procNameTeleHealthRuHealth as nchar(50) = N''

declare @namePartIFSP       as nvarchar(10)   = N'IFSP'
declare @namePartIEP        as nvarchar(10)   = N'IEP'
declare @namePartNoPlan     as nvarchar(10)   = N'NO-PLAN'
declare @namePartCybhi      as nvarchar(10)   = N'CYBHI'
declare @namePartRuHealth   as nvarchar(10)   = N'RU-HLTH'
declare @namePartTeleHealth as nvarchar(10)   = N'TLHL'
declare @namePartSpc        as nvarchar(10)   = N' ' 
declare @namePartNoSpc      as nvarchar(10)   = N''

declare @procModIFSP  as nchar(10)  = N'TL'
declare @procModIEP   as nchar(10)  = N'TM'
declare @procModCYBHI as nchar(10)  = N'U4'
declare @procModTlhl  as nchar(10)  = N'95'

declare @billingProgramLeaBop   as smallint = 1
declare @billingProgramCybhi    as smallint = 2
declare @billingProgramRuHealth as smallint = 3

declare @today as datetime = getdate()

declare @newProcs as table (
	  [NO_PLAN_NAME]         [int]       NULL
	, [IEP_IFSP_NAME]        [int]       NULL
	, [CYBHI_NAME]           [int]       NULL
	, [RU_HEALTH_NAME]       [int]       NULL
	, [PROCEDURE_CODE]       [nchar](10) NULL
	, [PROCEDURE_MODIFIER_1] [nchar](10) NULL
	, [PROCEDURE_MODIFIER_2] [nchar](10) NULL
	, [PROCEDURE_MODIFIER_3] [nchar](10) NULL
	, [PROCEDURE_MODIFIER_4] [nchar](10) NULL
	, [PROCEDURE_NAME]       [nvarchar](50) NULL
    , [IEP_REQUIRED]         nchar(10)     default (N'N')
	, [TELE_HEALTH]          bit           default(0)
	, [NEXT_MOD_SLOT]        int           default(0)
    , [BILLING_PROGRAM]      smallint      default(1) /* 1= LEA BOP 2= CYBHI 3=RU Health */
)

declare @groupIDs as table (
  GROUP_ID bigint
)

declare @groupNames as table (
  GROUP_NAME NVARCHAR(max)
)

declare @groupModifiers as table (
  PROCEDURE_MODIFIER nchar(10)
)

declare @allowedGroups as table (
   PROCEDURE_MODIFIER nchar(10)
  ,GROUP_ID           bigint
)

-- Clean up procedure name removing any reserved words

set @procName = trim(isnull(@procName,N''))
set @procName = replace(@procName,@namePartIFSP,       @namePartNoSpc)
set @procName = replace(@procName,@namePartIEP,        @namePartNoSpc)
set @procName = replace(@procName,@namePartNoPlan,     @namePartNoSpc)
set @procName = replace(@procName,@namePartCybhi,      @namePartNoSpc)
set @procName = replace(@procName,@namePartRuHealth,   @namePartNoSpc)
set @procName = replace(@procName,@namePartTeleHealth, @namePartNoSpc)
set @procName = trim(upper(@procName))

-- If there is no procedure name then get out

if (@procName = N'') return

-- Create procedure names using our naming convention for the various plan types and modality supported

set @procNameInPersonIFSP       = @namePartIFSP       + @namePartSpc + @procName
set @procNameInPersonIEP        = @namePartIEP        + @namePartSpc + @procName
set @procNameInPersonNoPlan     = @namePartNoPlan     + @namePartSpc + @procName
set @procNameInPersonCybhi      = @namePartCybhi      + @namePartSpc + @procName
set @procNameInPersonRuHealth   = @namePartRuHealth   + @namePartSpc + @procName

set @procNameTeleHealthIFSP     = @namePartTeleHealth + @namePartSpc + @procNameInPersonIFSP
set @procNameTeleHealthIEP      = @namePartTeleHealth + @namePartSpc + @procNameInPersonIEP
set @procNameTeleHealthNoPlan   = @namePartTeleHealth + @namePartSpc + @procNameInPersonNoPlan
set @procNameTeleHealthCybhi    = @namePartTeleHealth + @namePartSpc + @procNameInPersonCybhi
set @procNameTeleHealthRuHealth = @namePartTeleHealth + @namePartSpc + @procNameInPersonRuHealth

set @intensityOfSvcModifier  = trim(upper(isnull(@intensityOfSvcModifier,N'')))

-- If IFSP procedures are required generate a starter template record for them

if (@ifsp = 1) 
begin
  if (@inPerson = 1) 
  begin
    insert into @newProcs (
	    [IEP_IFSP_NAME]        
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_MODIFIER_1] 
  	  , [PROCEDURE_NAME]
	  , [IEP_REQUIRED]
	  , [BILLING_PROGRAM]
	)
    values (
        @nameIdIfspIepInPerson
      , @procCode
  	  , @procModIFSP
	  , @procNameInPersonIFSP     
	  , N'Y'
	  , @billingProgramLeaBop
	)     
  end

  if (@teleHealth = 1)
  begin
    insert into @newProcs (
	    [IEP_IFSP_NAME]        
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_MODIFIER_1] 
  	  , [PROCEDURE_NAME]
      , [TELE_HEALTH]
	  , [IEP_REQUIRED] 
	  , [BILLING_PROGRAM]
	)
	values (
        @nameIdIfspIepTelehealth
      , @procCode
  	  , @procModIFSP
	  , @procNameTeleHealthIFSP
      , 1
	  , N'Y'
	  , @billingProgramLeaBop
	)
	  
  end
end

-- If IEP procedures are required generate a starter template record for them

if (@iep = 1)
begin
  if (@inPerson = 1) 
  begin
    insert into @newProcs (
        [IEP_IFSP_NAME]        
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_MODIFIER_1] 
  	  , [PROCEDURE_NAME]
	  , [IEP_REQUIRED]
	  , [BILLING_PROGRAM]
	)
    values (
        @nameIdIfspIepInPerson
      , @procCode
  	  , @procModIEP
	  , @procNameInPersonIEP
      , N'Y'
	  , @billingProgramLeaBop
	)     
  end
  if (@teleHealth = 1)
  begin
    insert into @newProcs (
        [IEP_IFSP_NAME]        
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_MODIFIER_1] 
  	  , [PROCEDURE_NAME]
	  , [TELE_HEALTH]
	  , [IEP_REQUIRED] 
	  , [BILLING_PROGRAM]
	)
    values (
        @nameIdIfspIepTelehealth
      , @procCode
  	  , @procModIEP
	  , @procNameTeleHealthIEP
      , 1
	  , N'Y'
	  , @billingProgramLeaBop
	) 
  end
end

-- If no plan procedures are required generate a starter template record for them

if (@noPlan = 1)
begin
  if (@inPerson = 1) 
  begin
    insert into @newProcs (
        [NO_PLAN_NAME]         
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_NAME]
	  , [BILLING_PROGRAM]
	)
    values (
	    @nameIdNoPlanInPerson
      , @procCode
  	  , @procNameInPersonNoPlan
	  , @billingProgramLeaBop
    )     
  end
  if (@teleHealth = 1)
  begin
    insert into @newProcs (
        [NO_PLAN_NAME]         
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_NAME]
	  , [TELE_HEALTH]
	  , [BILLING_PROGRAM]
	)
    values (
        @nameIdNoPlanTelehealth
      , @procCode
  	  , @procNameTeleHealthNoPlan
      , 1
	  , @billingProgramLeaBop
	) 
  end
end

-- If cybhi procedures are required generate a starter template record for them

if (@cybhi= 1)
begin
  if (@inPerson = 1) 
  begin
    insert into @newProcs (
        [CYBHI_NAME]         
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_MODIFIER_1]
	  , [PROCEDURE_NAME]
	  , [BILLING_PROGRAM]
	)
    values (
	    @nameIdCybhiInPerson
      , @procCode
	  , @procModCYBHI /* First proc mod has to be U4 */
  	  , @procNameInPersonCybhi
	  , @billingProgramCybhi
    )     
  end
  if (@teleHealth = 1)
  begin
    insert into @newProcs (
        [CYBHI_NAME]          
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_MODIFIER_1]
	  , [PROCEDURE_NAME]
	  , [TELE_HEALTH]
	  , [BILLING_PROGRAM]
	)
    values (
        @nameIdCybhiTelehealth
      , @procCode
  	  , @procModCYBHI /* First proc mod has to be U4 */
	  , @procNameTeleHealthCybhi
      , 1
	  , @billingProgramCybhi
	) 
  end
end

-- If ru health procedures are required generate a starter template record for them

if (@ruHealth= 1)
begin
  if (@inPerson = 1) 
  begin
    insert into @newProcs (
        [RU_HEALTH_NAME]         
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_NAME]
	  , [BILLING_PROGRAM]
	)
    values (
	    @nameIdRuHealthInPerson
      , @procCode
  	  , @procNameInPersonRuHealth
	  , @billingProgramRuHealth
    )     
  end
  if (@teleHealth = 1)
  begin
    insert into @newProcs (
        [RU_HEALTH_NAME]          
	  , [PROCEDURE_CODE]       
	  , [PROCEDURE_NAME]
	  , [TELE_HEALTH]
	  , [BILLING_PROGRAM]
	)
    values (
        @nameIdRuHealthTelehealth
      , @procCode
  	  , @procNameTeleHealthRuHealth
      , 1
	  , @billingProgramRuHealth
	) 
  end
end

-- Update the next available mod slot in the template procs

update np
  set np.NEXT_MOD_SLOT = dbo.HAS_MOD_IN_SLOT_NUM(N'',np.PROCEDURE_MODIFIER_1, np.PROCEDURE_MODIFIER_2, np.PROCEDURE_MODIFIER_3, np.PROCEDURE_MODIFIER_4)
from @newProcs as np
 
-- If intensity of service is provided then add it to the template procs

if (@intensityOfSvcModifier != N'')
begin
 
  update np
   set
    np.[PROCEDURE_MODIFIER_1] = case when np.NEXT_MOD_SLOT = 1 then @intensityOfSvcModifier else np.PROCEDURE_MODIFIER_1 end 
  , np.[PROCEDURE_MODIFIER_2] = case when np.NEXT_MOD_SLOT = 2 then @intensityOfSvcModifier else np.PROCEDURE_MODIFIER_2 end
  , np.[PROCEDURE_MODIFIER_3] = case when np.NEXT_MOD_SLOT = 3 then @intensityOfSvcModifier else np.PROCEDURE_MODIFIER_3 end
  , np.[PROCEDURE_MODIFIER_4] = case when np.NEXT_MOD_SLOT = 4 then @intensityOfSvcModifier else np.PROCEDURE_MODIFIER_4 end
  from @newProcs as np

  update np
    set np.NEXT_MOD_SLOT = dbo.HAS_MOD_IN_SLOT_NUM(N'',np.PROCEDURE_MODIFIER_1, np.PROCEDURE_MODIFIER_2, np.PROCEDURE_MODIFIER_3, np.PROCEDURE_MODIFIER_4)
  from @newProcs as np

end

-- If we are not getting group data from group ids (default)
-- then get it from the mods

if (@allowedGroupsDataFormat = 1)
begin

  -- Get the various group modifiers and set "no modifier" groups to null

  insert into @groupModifiers
  select 
    PROCEDURE_MODIFIER = trim(upper(convert(nchar(10),iif(gm.[value] = '',null,gm.[value]))))
  from string_split(@allowedGroupsDataCSV,',') as gm

  -- Populate allowed groups working table from group modifiers list

  insert into @allowedGroups
  select 
       gm.PROCEDURE_MODIFIER 
     , ggm.GROUP_ID          
  from @groupModifiers                      as gm
  join dbo.[GROUP_Group_Proc_Mod_Modifiers] as ggm on isnull(ggm.CPT_MODIFIER,N'') = isnull(gm.PROCEDURE_MODIFIER,N'')

  -- Populate group list

  insert into @groupIDs (
    GROUP_ID
  )
  select distinct 
    ag.GROUP_ID 
  from @allowedGroups as ag

  -- Find group names

  insert into @groupNames (
    GROUP_NAME
   )
   select 
     gg.GROUP_NAME 
   from @groupIDs as t1
   join dbo.GROUP_Group as gg on gg.GROUP_ID = t1.GROUP_ID
  
end

-- Otherwise group ids are provided so we have to get the mods
-- (basically the reverse of above)

else if (@allowedGroupsDataFormat = 2)
begin

  -- Get group ids passed in

  insert into @groupIDs (
    GROUP_ID
  )
  select distinct 
    GROUP_ID = convert(bigint,t1.value)
  from string_split(@allowedGroupsDataCSV,',') as t1

  -- Find group names

  insert into @groupNames (
    GROUP_NAME
   )
   select 
     gg.GROUP_NAME 
   from @groupIDs as t1
   join dbo.GROUP_Group as gg on gg.GROUP_ID = t1.GROUP_ID
    
  -- Populate allowed groups working table from groupid list

  insert into @allowedGroups (
      PROCEDURE_MODIFIER
    , GROUP_ID
  )
  select distinct 
      PROCEDURE_MODIFIER = t2.CPT_MODIFIER 
    , t1.GROUP_ID
  from @groupIDs                               as t1
  left join dbo.GROUP_Group_Proc_Mod_Modifiers as t2 on t2.GROUP_ID = t1.GROUP_ID
                                                     and t2.ACTIVE = 1
  -- Create group modifiers list
 
  insert into @groupModifiers
  select distinct
      PROCEDURE_MODIFIER = trim(upper(convert(nchar(10),iif(t1.[PROCEDURE_MODIFIER] = N'',null,t1.[PROCEDURE_MODIFIER]))))
  from @allowedGroups as t1
end

-- Group names

else if (@allowedGroupsDataFormat = 3)
begin

  -- Extract group names 

  insert into @groupNames (
    GROUP_NAME
  )
  select distinct 
    GROUP_NAME= trim(t1.value)
  from string_split(@allowedGroupsDataCSV,',') as t1
  where (t1.value is not null)

  -- Find group ids 

  insert into @groupIDs (
    GROUP_ID
  )
  select distinct 
    gg.GROUP_ID
  from @groupNames as t1
  join dbo.GROUP_Group as gg on  ((gg.GROUP_NAME = t1.GROUP_NAME)
                             and (gg.GROUP_TYPE in (1,2))
                             and (gg.ACTIVE = 1))
  
-- Populate allowed groups working table from groupid list

  insert into @allowedGroups (
      PROCEDURE_MODIFIER
    , GROUP_ID
  )
  select distinct 
      PROCEDURE_MODIFIER = t2.CPT_MODIFIER 
    , t1.GROUP_ID
  from @groupIDs                               as t1
  left join dbo.GROUP_Group_Proc_Mod_Modifiers as t2 on t2.GROUP_ID = t1.GROUP_ID
                                                     and t2.ACTIVE = 1

  -- Create group modifiers list
 
  insert into @groupModifiers
  select distinct
      PROCEDURE_MODIFIER = trim(upper(convert(nchar(10),iif(t1.[PROCEDURE_MODIFIER] = N'',null,t1.[PROCEDURE_MODIFIER]))))
  from @allowedGroups as t1

end

-- Using our procedure templates, create sets for each discipline modifier

insert into @claimProcedures (
     [ALLOWED_GROUPS_CSV]
	,[NO_PLAN_NAME] 
	,[IEP_IFSP_NAME] 
	,[PROCEDURE_CODE] 
	,[PROCEDURE_MODIFIER_1] 
	,[PROCEDURE_MODIFIER_2] 
	,[PROCEDURE_MODIFIER_3] 
	,[PROCEDURE_MODIFIER_4]
	,[PROCEDURE_NAME]
	,[TELE_HEALTH]
    ,[IEP_REQUIRED]
    ,[CYBHI_NAME]
	,[billingProgramID]
	,[SERVICE_SELECTION]
	,[RU_HEALTH_NAME]
)
select  
	  np2.ALLOWED_GROUPS_CSV
	, np2.[NO_PLAN_NAME]         
	, np2.[IEP_IFSP_NAME]        
	, np2.[PROCEDURE_CODE]       
	, np2.[PROCEDURE_MODIFIER_1] 
	, np2.[PROCEDURE_MODIFIER_2] 
	, np2.[PROCEDURE_MODIFIER_3] 
	, np2.[PROCEDURE_MODIFIER_4] 
	, np2.[PROCEDURE_NAME]       
	, np2.[TELE_HEALTH]
	, np2.IEP_REQUIRED
	, np2.[CYBHI_NAME]
	, np2.[BILLING_PROGRAM]
	, @isSvcSelection
	, np2.[RU_HEALTH_NAME]
from @groupModifiers as gm
cross apply (
  select  
    
    [ALLOWED_GROUPS_CSV] = (
	  select 
	  STRING_AGG (convert(varchar(max),ag.GROUP_ID), ',') 
	  from @allowedGroups as ag 
	  where (isnull(ag.PROCEDURE_MODIFIER,N'') = isnull(gm.PROCEDURE_MODIFIER,N''))
	)
	, np1.IEP_REQUIRED
	, np1.[NO_PLAN_NAME]         
	, np1.[IEP_IFSP_NAME]        
	, np1.[PROCEDURE_CODE]       
    , [PROCEDURE_MODIFIER_1] = case when np1.NEXT_MOD_SLOT = 1 then gm.PROCEDURE_MODIFIER else np1.PROCEDURE_MODIFIER_1 end 
    , [PROCEDURE_MODIFIER_2] = case when np1.NEXT_MOD_SLOT = 2 then gm.PROCEDURE_MODIFIER else np1.PROCEDURE_MODIFIER_2 end
    , [PROCEDURE_MODIFIER_3] = case when np1.NEXT_MOD_SLOT = 3 then gm.PROCEDURE_MODIFIER else np1.PROCEDURE_MODIFIER_3 end
    , [PROCEDURE_MODIFIER_4] = case when np1.NEXT_MOD_SLOT = 4 then gm.PROCEDURE_MODIFIER else np1.PROCEDURE_MODIFIER_4 end 
    , np1.[PROCEDURE_NAME]
	, np1.[TELE_HEALTH]
	, np1.[CYBHI_NAME]
	, np1.[BILLING_PROGRAM]
    , np1.[RU_HEALTH_NAME] 
  from @newProcs as np1
) as np2

-- Now data is in claim procedures so update the next available mod slot, dates, service fee

update cp
set 
   cp.NEXT_MOD_SLOT         = dbo.HAS_MOD_IN_SLOT_NUM(N'',cp.PROCEDURE_MODIFIER_1, cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)
  ,cp.DATE_ADDED            = @today
  ,cp.DATE_MODIFIED         = null
  ,cp.MIN_UNITS             = @minUnits
  ,cp.MAX_UNITS             = @maxUnits
  ,cp.DIAGNOSIS_CODE        = @diagnosisCode
  ,cp.ICD_10_DIAGNOSIS_CODE = @diagnosisCodeIcd10
  ,cp.SERVICE_TYPE_ID       = @serviceTypeID
  ,cp.SERVICE_SUB_TYPE_1_ID = @serviceSubTypeID
  ,cp.UNIT_TYPE             = @unitType
  ,cp.YEARLY_FLAG           = @yearlyFlag
  ,cp.DATE_EFFECTIVE        = @effectiveDate
  ,cp.DATE_EXPIRES          = @expirationDate
  ,cp.SERVICE_FEE           = @svcFee
  ,cp.PUT_IN_837            = @putIn837
from @claimProcedures as cp

-- If telehealth is specified then add the modifier to claim procedures in the next available mod slot

if (@teleHealth = 1)
begin
  update cp
   set
    cp.[PROCEDURE_MODIFIER_1] = case when cp.NEXT_MOD_SLOT = 1 then @procModTlhl else cp.PROCEDURE_MODIFIER_1 end 
  , cp.[PROCEDURE_MODIFIER_2] = case when cp.NEXT_MOD_SLOT = 2 then @procModTlhl else cp.PROCEDURE_MODIFIER_2 end
  , cp.[PROCEDURE_MODIFIER_3] = case when cp.NEXT_MOD_SLOT = 3 then @procModTlhl else cp.PROCEDURE_MODIFIER_3 end
  , cp.[PROCEDURE_MODIFIER_4] = case when cp.NEXT_MOD_SLOT = 4 then @procModTlhl else cp.PROCEDURE_MODIFIER_4 end
 from @claimProcedures as cp
 where (cp.TELE_HEALTH = 1)

  update cp
    set cp.NEXT_MOD_SLOT = dbo.HAS_MOD_IN_SLOT_NUM(N'',cp.PROCEDURE_MODIFIER_1, cp.PROCEDURE_MODIFIER_2, cp.PROCEDURE_MODIFIER_3, cp.PROCEDURE_MODIFIER_4)
  from @claimProcedures as cp

end

-- Done

return

end
go


 
