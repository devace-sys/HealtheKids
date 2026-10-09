USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW_ALL_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW_ALL_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICES_VIEW_ALL_CORE] (
    @clientID                     int
  , @groupID                      int
  , @servicePlanTypeID            int
  , @serviceTypeID                int
  , @serviceNameID                int
  , @procedureIsAllowed           bit
  , @procedureIsActive            bit
  , @procedureIsEffectiveForDOS   date
  , @procedureIsServiceSelection  bit
) 
RETURNS TABLE    

/***************************************************************************    
 * SERVICES_VIEW_ALL_CORE */    
/**   
 * Core function used to provide a reference table of related service,
 * procedue, and group data.  Meta data for these various related entities
 * is also provided.
 *
 * @param   clientID   Client ID used for retrieving client/group
 *                     specific service name aliases for standard services 
 *                     for the given groupID and client/group specific 
 *                     services unique to that client/group combo.
 *                     Must be used with a groupID.  Set this and groupID 
 *                     to null to limit output to just standard services.
 *
 * @param   groupID    Discipline group ID used for retrieving client/group
 *                     specific service name aliases for standard services 
 *                     for the given groupID AND client/group specific 
 *                     services unique to that client/group combo.  
 *                     Must be used with a clientID.  Set this and clientID 
 *                     to null to limit output to just standard services.
 *
 * @param   servicePlanTypeID    1    =  IFSP 
 *                               2    =  IEP 
 *                               3    =  No Plan 
 *                               null =  All
 *
 * @param   serviceTypeID        1    =  Assessement
 *                               2    =  Treatment/Therapy
 *                               3    =  Transportation
 *                               4    =  TCM
 *                               null =  All
 *
 * @param   serviceNameID        Specific Name id or null for all
 *                               Use in combination with @servicePlanTypeID.
 *                               If @servicePlanType is 1 or 2 then the nameid
 *                               column in IEP_IFSP names is referenced otherwise
 *                               the equivalent column in NO_PLAN names is referenced.
 *
 * @param   procedureIsAllowed   0    =  Show procedures no longer allowed
 *                               1    =  Show only allowed procedures
 *                               null =  All     
 * 
 * @param   procedureIsActive    Filters on Active flag in CLAIM_Procedures
 *                               0    =  Not active
 *                               1    =  Active
 *                               null = Does not matter
 *
 * @param  procedureIsEffectiveForDOS  Filters on date fields in CLAIM_Procedures
 *                                     to show procedures that are in effect for DOS
 *                                     or null for all procedures.
 *
 * @param  procedureIsServiceSelection Filters on flag in CLAIM_Procedures
 *                                     0   =  Show procedures that are not
 *                                            service selections
 *                                     1   =  Show procedures that are service
 *                                            selections
 *                                     null = Does not matter
 * @return table 
 ***************************************************************************/     

as return (
     
with 

/*###########################################################################
  # cte_procedures
  #
  # Start with CLAIM_Procedures and provide optional filter for 
  # dos, active, and service selection 
  ###########################################################################*/ 

cte_procedures
as
(
   select 
     q0.*
   from
   (
     select
         [PROC_START_DATE] = convert(date, isnull (cp.DATE_EFFECTIVE, dbo.CONST_MIN_DATETIME()))
       , [PROC_END_DATE]   = convert(date, isnull (cp.DATE_EXPIRES,   dbo.CONST_MAX_DATETIME()))
       , [PROC_ACTIVE]     = convert(bit,  isnull (cp.Active,0))
       , cp1.NUM_SELECT_CHILD_PROCS_USING_SVC_DET_FLAGS
       , cp.*
     from dbo.CLAIM_Procedures as cp
     cross apply (
       select COUNT(PROCEDURE_ID) as NUM_SELECT_CHILD_PROCS_USING_SVC_DET_FLAGS
       from dbo.CLAIM_Procedures 
       where 
           (cp.SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS = 1)
       and (PARENT_PROCEDURE_ID                        = cp.PROCEDURE_ID) 
       and (SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS  = 1) 
     ) as cp1
   ) as q0
   where (
          (1=1)
      and ((@procedureIsEffectiveForDOS  is null) or ((convert(date,@procedureIsEffectiveForDOS)) between [PROC_START_DATE] and [PROC_END_DATE]))
      and ((@procedureIsActive           is null) or ([PROC_ACTIVE]     = @procedureIsActive))
      and ((@procedureIsServiceSelection is null) or (SERVICE_SELECTION = @procedureIsServiceSelection)) 
  )   
)
,

/*###########################################################################
  # cte_procedures_and_services_pass_1
  #
  # All possible procedures and services for all clients and groups and
  # provides service name aliases for a given @clientID and @groupID pair.
  ###########################################################################*/ 
  
cte_procedures_and_services_pass_1
as
(
select 

  /*--------------------------------------
   * Procedure data
   *-------------------------------------*/  

    cp.IEP_IFSP_NAME                                        as [PROCEDURE_IEP_IFSP_NAME_ID]
  , cp.NO_PLAN_NAME                                         as [PROCEDURE_NO_PLAN_NAME_ID] 
  , cp.CYBHI_NAME                                           as [PROCEDURE_CYBHI_NAME_ID]
  , cp.RU_HEALTH_NAME                                       as [PROCEDURE_RU_HEALTH_NAME_ID]
  , cp.SERVICE_SELECTION                                    as [PROCEDURE_IS_SERVICE_SELECTION] 
  , cp.CPT_PROCEDURE                                        as [PROCEDURE_IS_CPT_PROCEDURE]
  , cp.PARENT_PROCEDURE_ID                                  as [PROCEDURE_PARENT_PROCEDURE_ID]
  , cp.PROCEDURE_ID                                         as [PROCEDURE_ID]  

  , upper(trim(isnull(cp.[PROCEDURE_NAME],     N'')))       as [PROCEDURE_NAME]
  , upper(trim(isnull(cp.PROCEDURE_CODE,       N'')))       as [PROCEDURE_CODE]
  , upper(trim(isnull(cp.PROCEDURE_MODIFIER_1, N'')))       as [PROCEDURE_MOD_1]
  , upper(trim(isnull(cp.PROCEDURE_MODIFIER_2, N'')))       as [PROCEDURE_MOD_2]
  , upper(trim(isnull(cp.PROCEDURE_MODIFIER_3, N'')))       as [PROCEDURE_MOD_3]  
  , upper(trim(isnull(cp.PROCEDURE_MODIFIER_4, N'')))       as [PROCEDURE_MOD_4]  

  , cp.HAS_LOGICAL_MODIFIER_22                              as [HAS_LOGICAL_MODIFIER_22]

  , dbo.RPT_PROC_MOD_COMBO( cp.PROCEDURE_CODE
                           ,cp.PROCEDURE_MODIFIER_1
                           ,cp.PROCEDURE_MODIFIER_2
                           ,cp.PROCEDURE_MODIFIER_3
                           ,cp.PROCEDURE_MODIFIER_4)        as [PROCEDURE_PROC_MOD_COMBO]
						    
  , convert(decimal(18,4),isnull(cp.PAGE,N'0'))      as [PROCEDURE_MAN_PAGE]
  , trim(isnull(cp.DIAGNOSIS_CODE,N''))              as [PROCEDURE_DIAGNOSIS_CODE]
  , trim(isnull(cp.MAX_SERVICE_UNITS,N''))           as [PROCEDURE_MAX_SERVICE_UNITS]
  , trim(isnull(cp.MIN_UNITS,N''))                   as [PROCEDURE_MIN_UNITS] 
  , trim(isnull(cp.MAX_UNITS,N''))                   as [PROCEDURE_MAX_UNITS]
  , trim(isnull(UNIT_TYPE,''))                       as [PROCEDURE_UNIT_TYPE]
  , trim(isnull(cp.YEARLY_FLAG,N''))                 as [PROCEDURE_YEARLY_FLAG]
  , trim(isnull(cp.IEP_REQUIRED,N''))                as [PROCEDURE_IEP_REQUIRED]
  , isnull(cp.SERVICE_FEE,0)                         as [PROCEDURE_SERVICE_FEE]
  , isnull(cp.OVER_17_FEE,0)                         as [PROCEDURE_OVER_17_FEE]
  , isnull(cp.UNDER_18_FEE,0)                        as [PROCEDURE_UNDER_18_FEE]
  , isnull(cp.TCM_LOW_RATE,0)                        as [PROCEDURE_TCM_LOW_RATE]
  , isnull(cp.TCM_MEDIUM_RATE,0)                     as [PROCEDURE_TCM_MEDIUM_RATE]
  , isnull(cp.TCM_HIGH_RATE,0)                       as [PROCEDURE_TCM_HIGH_RATE]
   
  , cp.PROC_START_DATE                               as [PROCEDURE_START_DATE]
  , cp.PROC_END_DATE                                 as [PROCEDURE_END_DATE]
  , cp.PROC_ACTIVE                                   as [PROCEDURE_ACTIVE]
  , cp.PUT_IN_837                                    as [PROCEDURE_OK_TO_INCLUDE_IN_837]
  , cp.billingProgramID                              as [PROCEDURE_BILLING_PROGRAM_ID]

  /*--------------------------------------
   * Service name data 
   *-------------------------------------*/
   
  , coalesce (cin.IEP_IFSP_NAME_ID, cnp.NO_PLAN_NAME_ID, cybhi.CYBHI_NAME_ID, cruh.RU_HEALTH_NAME_ID)  as [SERVICE_NAME_ID]
  , trim(isnull(coalesce(cin.NAME, cnp.NAME, cybhi.NAME, cruh.NAME),''))                               as [SERVICE_NAME_STANDARD]

  /*--------------------------------------
   * Service name alias data
   *-------------------------------------*/
   
  , coalesce (cina.ID, cnpa.ID, cybhia.ID, cruha.ID, cruha.ID)                                            as [SERVICE_NAME_ALIAS_RECORD_ID]
  , coalesce (cina.IEP_IFSP_NAME_ID, cnpa.NO_PLAN_NAME_ID,cybhia.CYBHI_NAME_ID, cruha.RU_HEALTH_NAME_ID)  as [SERVICE_NAME_ALIAS_NAME_ID]  
  , trim(isnull(coalesce (cina.NAME, cnpa.NAME, cybhia.NAME, cruha.NAME),''))                             as [SERVICE_NAME_ALIAS]
  , coalesce (cina.CLIENT_ID, cnpa.CLIENT_ID, cybhia.CLIENT_ID, cruha.CLIENT_ID)                          as [SERVICE_NAME_ALIAS_FOR_CLIENT_ID]
  , coalesce (cina.GROUP_ID,  cnpa.GROUP_ID, cybhia.GROUP_ID, cruha.GROUP_ID)                             as [SERVICE_NAME_ALIAS_FOR_GROUP_ID]

  /*--------------------------------------
   * Service type data
   *-------------------------------------*/

  , cp.SERVICE_TYPE_ID                   as [SERVICE_TYPE_ID]
  , cpst.SERVICE_TYPE_NAME               as [SERVICE_TYPE]
  , cp.SERVICE_SUB_TYPE_1_ID             as [SERVICE_SUB_TYPE_1_ID]
  , cpsst1.SERVICE_TYPE_NAME             as [SERVICE_SUB_TYPE_1]           
  , cp.SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS                              as [SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS]
  , cp.NUM_SELECT_CHILD_PROCS_USING_SVC_DET_FLAGS                           as [NUM_SELECT_CHILD_PROCS_USING_SVC_DET_FLAGS]
  , cp.SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA                    as [SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA]
  , cp.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS                            as [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS]
  , cp.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE           as [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE]
  , cp.SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE    as [SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE]  
  , cp.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS                                 as [SELECT_PROC_FOR_CLAIM_USING_NUM_MINS]
  , cp.SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT                       as [SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT]
  , cp.SEL_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT
  , cp.TIME_UNIT_MINS_START
  , cp.TIME_UNIT_MINS_END
  , cp.TIME_UNIT_MINS_ROUND_AT

from      cte_procedures                      as cp

left join dbo.CLAIM_Procedures_Service_Types  as cpst   on  cpst.SERVICE_TYPE_ID   = cp.SERVICE_TYPE_ID
left join dbo.CLAIM_Procedures_Service_Types  as cpsst1 on  cpsst1.SERVICE_TYPE_ID = cp.SERVICE_SUB_TYPE_1_ID

left join dbo.CLAIM_IEPandIFSPNames           as cin    on  cin.IEP_IFSP_NAME_ID   = cp.IEP_IFSP_NAME
left join dbo.CLAIM_IEPandIFSPNames_ALIAS     as cina   on  cina.IEP_IFSP_NAME_ID  = cin.IEP_IFSP_NAME_ID
                                                        and cina.CLIENT_ID         = @clientID
                                                        and cina.GROUP_ID          = @groupID
left join dbo.CLAIM_NoPlanNames               as cnp    on  cnp.NO_PLAN_NAME_ID    = cp.NO_PLAN_NAME
left join dbo.CLAIM_NoPlanNames_ALIAS         as cnpa   on  cnpa.NO_PLAN_NAME_ID   = cnp.NO_PLAN_NAME_ID
                                                        and cnpa.CLIENT_ID         = @clientID
                                                        and cnpa.GROUP_ID          = @groupID

left join dbo.CLAIM_CYBHI_Names               as cybhi  on cybhi.CYBHI_NAME_ID     = cp.CYBHI_NAME
left join dbo.CLAIM_CYBHI_Names_ALIAS         as cybhia on cybhia.CYBHI_NAME_ID    = cp.CYBHI_NAME
                                                        and cybhia.CLIENT_ID       = @clientID
                                                        and cybhia.GROUP_ID        = @groupID

left join dbo.CLAIM_RU_HEALTH_Names           as cruh  on   cruh.RU_HEALTH_NAME_ID     = cp.RU_HEALTH_NAME
left join dbo.CLAIM_RU_HEALTH_Names_ALIAS     as cruha on   cruha.RU_HEALTH_NAME_ID    = cp.RU_HEALTH_NAME
                                                        and cruha.CLIENT_ID        = @clientID
                                                        and cruha.GROUP_ID         = @groupID
)
,

/*###########################################################################
  # cte_procedures_and_services_pass_2
  #
  # Building on cte_procedures_and_services_pass_1 generate meta data columns.
  ###########################################################################*/ 

cte_procedures_and_services_pass_2
as
(
  select 

    p1.* 
    
    /*--------------------------------------
     * Procedure data
     *-------------------------------------*/

    , [PROCEDURE_CODE_IS_Q]  = case when PROCEDURE_CODE like ('[Q][^Q]%') then 1 else 0 end        
    , [PROCEDURE_CODE_IS_QQ] = case when PROCEDURE_CODE like ('[Q][Q]%')  then 1 else 0 end

	  /* Note: To deal with AMAs procedure coding standard breaking change regarding some new
	   * "additional minute" treatment procedure codes (effective 1/1/2020) if the procedure 
	   * is flagged as having a logical modifier 22 we treat the procedure as it is if actually 
	   * has a 22 in one of the modifiers BUT we don't put a 22 in the proc mod combo that is
	   * used for claiming. */
    
	, [PROCEDURE_HAS_LOGICAL_22] = HAS_LOGICAL_MODIFIER_22
        
    , [PROCEDURE_HAS_22] = case 
      when PROCEDURE_MOD_1 = N'22' then 1    
      when PROCEDURE_MOD_2 = N'22' then 1    
      when PROCEDURE_MOD_3 = N'22' then 1    
      when PROCEDURE_MOD_4 = N'22' then 1 
	  when HAS_LOGICAL_MODIFIER_22 = 1 then 1 
	  else 0     
    end

    , [PROCEDURE_HAS_52] = case 
      when PROCEDURE_MOD_1 = N'52' then 1 
      when PROCEDURE_MOD_2 = N'52' then 1 
      when PROCEDURE_MOD_3 = N'52' then 1 
      when PROCEDURE_MOD_4 = N'52' then 1    
      else 0
    end
    
    , [PROCEDURE_HAS_TS] = case 
      when PROCEDURE_MOD_1 = N'TS' then 1  
      when PROCEDURE_MOD_2 = N'TS' then 1   
      when PROCEDURE_MOD_3 = N'TS' then 1 
      when PROCEDURE_MOD_4 = N'TS' then 1 

      else 0          
    end

    , [PROCEDURE_HAS_TL] = case 
      when PROCEDURE_MOD_1 = N'TL' then 1    
      when PROCEDURE_MOD_2 = N'TL' then 1    
      when PROCEDURE_MOD_3 = N'TL' then 1    
      when PROCEDURE_MOD_4 = N'TL' then 1          
      else 0          
    end                  
    
    , [PROCEDURE_HAS_TM] = case 
      when PROCEDURE_MOD_1 = N'TM' then 1 
      when PROCEDURE_MOD_2 = N'TM' then 1    
      when PROCEDURE_MOD_3 = N'TM' then 1  
      when PROCEDURE_MOD_4 = N'TM' then 1    
      else 0          
    end

    , [PROCEDURE_HAS_GT] = case /* Old telehealth modifier */
      when PROCEDURE_MOD_1 = N'GT' then 1 
      when PROCEDURE_MOD_2 = N'GT' then 1    
      when PROCEDURE_MOD_3 = N'GT' then 1  
      when PROCEDURE_MOD_4 = N'GT' then 1    
      else 0 
    end

    , [PROCEDURE_HAS_95] = case /* New telehealth modifier */
      when PROCEDURE_MOD_1 = N'95' then 1 
      when PROCEDURE_MOD_2 = N'95' then 1 
      when PROCEDURE_MOD_3 = N'95' then 1  
      when PROCEDURE_MOD_4 = N'95' then 1    
      else 0 
    end

	, [PROCEDURE_HAS_U1] = case /* Dyadic modifier */
	  when PROCEDURE_MOD_1 = N'U1' then 1 
      when PROCEDURE_MOD_2 = N'U1' then 1 
      when PROCEDURE_MOD_3 = N'U1' then 1  
      when PROCEDURE_MOD_4 = N'U1' then 1    
      else 0 
    end

    /*--------------------------------------
     * Service data
     *-------------------------------------*/
     
    , [SERVICE_NAME]  = case when ([SERVICE_NAME_ALIAS] != '') then [SERVICE_NAME_ALIAS] else [SERVICE_NAME_STANDARD] end
                 
    , [SERVICE_IS_IN_IFSP_IEP]  = iif((PROCEDURE_IEP_IFSP_NAME_ID  is not null),1,0)
    , [SERVICE_IS_IN_NO_PLAN]   = iif((PROCEDURE_NO_PLAN_NAME_ID   is not null),1,0)    
    , [SERVICE_IS_IN_CYBHI]     = iif((PROCEDURE_CYBHI_NAME_ID     is not null),1,0)
    , [SERVICE_IS_IN_RU_HEALTH] = iif((PROCEDURE_RU_HEALTH_NAME_ID is not null),1,0)
 
  from cte_procedures_and_services_pass_1 as p1
)
,

/*###########################################################################
  # cte_procedures_and_services_pass_3
  #
  # Building on cte_procedures_and_services_pass_2 generate meta data columns.
  ###########################################################################*/ 

cte_procedures_and_services_pass_3
as
(
select 

  p2.*  

  /*--------------------------------------
   * Procedure data
   *-------------------------------------*/

  , [PROCEDURE_CLAIM_SPAN_2]             = case when [PROCEDURE_MAX_SERVICE_UNITS] != N'' then 1 else 0 end
  , [PROCEDURE_TRANS_PROC_NUM]           = case when [PROCEDURE_CODE] = N'T2003' then 1    when [PROCEDURE_CODE]  = N'A0425' then 2 else 0 end    
  , [PROCEDURE_ONE_ON_ONE_AIDE_PROC_FOR] = case when [PROCEDURE_CODE] = N'T1002' then 'RN' when [PROCEDURE_CODE]  = N'T1003' then 'LVN' when [PROCEDURE_CODE] = N'T1004' then 'HA' else '' end 
   
  /*--------------------------------------
   * Service data
   *-------------------------------------*/

  , [SERVICE_IS_BILLABLE] = case 
    when [PROCEDURE_CODE_IS_Q]  = 1  then 0
    when [PROCEDURE_CODE_IS_QQ] = 1  then 0    
    else 1
    end
    
  , [SERVICE_HAS_NAME] = case when [SERVICE_NAME] != '' then 1 else 0 end

  , [SERVICE_PLAN_TYPE_ID] = case    
    when (SERVICE_IS_IN_IFSP_IEP = 1) then
	case 
	  when (PROCEDURE_HAS_TL = 1) then dbo.CONST_PLAN_IFSP() -- tl : 1
	  when (PROCEDURE_HAS_TM = 1) then dbo.CONST_PLAN_IEP()  -- tm : 2
	  else null
	 end
	 when (SERVICE_IS_IN_NO_PLAN   = 1) then dbo.CONST_PLAN_NONE()  -- 3
	 when (SERVICE_IS_IN_CYBHI     = 1) then dbo.CONST_PLAN_CYBHI() -- 4
	 when (SERVICE_IS_IN_RU_HEALTH = 1) then dbo.CONST_PLAN_RU_HEALTH() -- 5
	 else null
	end

  
  , [SERVICE_IS_PSEUDO_TELEHEALTH] = iif ((    (PROCEDURE_HAS_GT = 0) 
                                           and (PROCEDURE_HAS_95 = 0) 
										   and ([PROCEDURE_NAME] like 'TLHL%'))
										   ,1,0) /* This is for the COVID19 pseduo telelhealth services that we want to label as telehealth 
							                        but DHCS does not want the telehealth modifier */

  , [SERVICE_IS_TELEHEALTH]        = convert(bit,(iif(((PROCEDURE_HAS_GT = 1) or (PROCEDURE_HAS_95 = 1)),1,0)))
  

from cte_procedures_and_services_pass_2 as p2

)
,

/*###########################################################################
  # cte_procedures_and_services_pass_4_base
  #
  # Building on cte_procedures_and_services_pass_3 generate meta data columns
  # and include related group data.
  #
  # Note: Do not modify this pass to filter by groupID
  ###########################################################################*/ 

cte_procedures_and_services_pass_4_base
as
(
select 

    cps3.* 
  
  /*--------------------------------------
   * Procedure data
   *-------------------------------------*/    

  , [PROCEDURE_IS_ONE_ON_ONE]            = case when [PROCEDURE_ONE_ON_ONE_AIDE_PROC_FOR] <> '' then 1 else 0 end  
  , [PROCEDURE_IS_IN_ALLOWED_PROCEDURES] = case when cap.ALLOWED_PROCEDURE_ID is null then 0 else 1 end    
  
  , cap.CLIENT_ID                         as [PROCEDURE_ALLOWED_FOR_CLIENT_ID]
  , cap.GROUP_ID                          as [PROCEDURE_ALLOWED_FOR_GROUP_ID]

  /*--------------------------------------
   * Service data
   *-------------------------------------*/    

  , [SERVICE_IS_VIA_TELEHEALTH] = convert(bit,(iif((([SERVICE_IS_PSEUDO_TELEHEALTH] = 1) or ([SERVICE_IS_TELEHEALTH] = 1)),1,0)))
  , [SERVICE_PLAN_TYPE] = dbo.PLAN_TYPE_TO_NAME([SERVICE_PLAN_TYPE_ID])
  , [SERVICE_IS_DYADIC] = convert(bit,(iif((PROCEDURE_BILLING_PROGRAM_ID = 2), iif((PROCEDURE_HAS_U1 = 1),1,0),0)))

  /*--------------------------------------
   * Group data
   *-------------------------------------*/    

  , gg.GROUP_ID                           as [GROUP_ID] 
  , gg.PARENT_GROUP_ID                    as [GROUP_ID_PARENT_ID]
  , gg.GROUP_NAME                         as [GROUP_NAME]
  , gg.GROUP_NAME_ABBREVIATION            as [GROUP_NAME_ABBREVIATION]
  , gg.GROUP_TYPE                         as [GROUP_TYPE_ID]     
  , ggt.TITLE                             as [GROUP_TYPE_TITLE]
  , ggt.[DESCRIPTION]                     as [GROUP_TYPE_DESCRIPTION]
  , gg.GROUP_BASE                         as [GROUP_BASE]
  , gg.ACTIVE                             as [GROUP_IS_ACTIVE]  
  , scn.GROUP_SERVICE_CLASS_NAME_ID       as [GROUP_SERVICE_CLASS_NAME_ID] 
  , scn.GROUP_SERVICE_CLASS_NAME          as [GROUP_SERVICE_CLASS_NAME_NAME]
  , [GROUP_SERVICE_CLASS_NUM_SPEC_AUTH_DOC_AVAIL] = isnull (pbs.NUM_AVAIL, 0)
  , [GROUP_IS_MAA]     = case when gg.GROUP_TYPE = 2 then 1 else 0 end
  , [GROUP_IS_NOT_MAA] = case when gg.GROUP_TYPE = 1 then 1 else 0 end
  , [CALPADS_SPED_SVC_CODE_VALUE]      = isnull(calPads.spEdSvcCodeValue,-1)
  , [CALPADS_SPED_SVC_CODE_NAME]       = isnull(calPads.spEdSvcCodeName,'')
  , [CALPADS_SPED_SVC_CODE_VALUE_STR]  = trim(isnull(calPads.spEdSvcCodeValueStr,''))

from cte_procedures_and_services_pass_3 as cps3

left join dbo.CLAIM_Allowed_Procedures       as cap  on cap.PROCEDURE_ID = cps3.PROCEDURE_ID
left join dbo.GROUP_Group                    as gg   on gg.GROUP_ID           = cap.GROUP_ID   
left join dbo.GROUP_Group_Types              as ggt  on ggt.GROUP_TYPE        = gg.GROUP_TYPE                                                                   

left join dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as  png on png.GROUP_SERVICE_CLASS_PARTITION_ID = 100
                                                                and png.GROUP_ID                         = gg.GROUP_ID  

left join dbo.GROUP_GROUP_SERVICE_CLASS_NAMES                   as scn on scn.GROUP_SERVICE_CLASS_NAME_ID       = png.GROUP_SERVICE_CLASS_NAME_ID

outer apply (

  select 
  
    NUM_AVAIL = COUNT(pbsd.ID) 
  
  from dbo.CLIENT_PBS_DOCUMENTATION as pbsd 
  
  where (
        (pbsd.CLIENT_ID                   = @clientID)
    and (pbsd.GROUP_SERVICE_CLASS_NAME_ID = scn.GROUP_SERVICE_CLASS_NAME_ID)
    and ((@procedureIsEffectiveForDos is null) or (@procedureIsEffectiveForDOS between pbsd.START_DATE and pbsd.END_DATE))
    and (pbsd.ACTIVE = 1)
  )
  
) as pbs


outer apply ( 
  select top 1 
      spEdSvcCodeValue     = ss.codeValue
	, spEdSvcCodeName      = ss.[name]     
    , spEdSvcCodeValueStr  = convert(varchar(50),ss.codeValue)

  from dbo.CLAIM_SERVICE_NAME_XREF_AND_FORM_DATA as csn 
  join dbo.SpEd_Service                          as ss on ss.codeValue = csn.spEdSvcCodeValue
  where (
        (csn.planTypeID = cps3.SERVICE_PLAN_TYPE_ID)
    and (csn.groupID    = gg.GROUP_ID)
    and (csn.nameID     = cps3.SERVICE_NAME_ID)
    and (csn.isStandard = 1)
    and (csn.active     = 1)
  )
) as calPads

)
,

/*###########################################################################
  # cte_procedures_and_services_pass_4_standard_services
  #
  # Takes results from cte_procedures_and_services_pass_4_base and limits them
  # to just allowed standard services/procedures for all clients.  Provides
  # optional filtering by groupID.
  ###########################################################################*/ 

cte_procedures_and_services_pass_4_standard_services
as
(
select 
  * 
from cte_procedures_and_services_pass_4_base 
where 
      ((PROCEDURE_ALLOWED_FOR_CLIENT_ID is null)
  and ((@groupID is null) or (PROCEDURE_ALLOWED_FOR_GROUP_ID = @groupID)))
)
,

/*###########################################################################
  # cte_procedures_and_services_pass_4_unique_services
  #
  # Takes results from cte_procedures_and_services_pass_4_base and limits them
  # to just client unique services/procedures.
  ###########################################################################*/ 

cte_procedures_and_services_pass_4_unique_services
as
(
  select * 
  from cte_procedures_and_services_pass_4_base 
  where 
        ((PROCEDURE_ALLOWED_FOR_CLIENT_ID is not null) 
    and (PROCEDURE_ALLOWED_FOR_CLIENT_ID = @clientID)
    and (PROCEDURE_ALLOWED_FOR_GROUP_ID  = @groupID))
)
,

/*###########################################################################
  # cte_procedures_and_services_pass_4
  #
  # Combines results of cte_procedures_and_services_pass_4_standard_services and 
  # cte_procedures_and_services_pass_4_unique_services. 
  ###########################################################################*/ 

cte_procedures_and_services_pass_4
as
(
select

    [SERVICE_USING_ALIAS]                 = case when [SERVICE_NAME_ALIAS_RECORD_ID] is null then 0 else 1 end 
  , [SERVICE_ENTRY_ORP_DOCUMENT_REQUIRED] = dbo.IS_ORP_REQUIRED_FOR_SVC (  PROCEDURE_CODE_IS_QQ
                                                                         , SERVICE_TYPE_ID
                                                                         , @procedureIsEffectiveForDOS
																		 , PROCEDURE_BILLING_PROGRAM_ID )
  , q1.*
from
(
  select [SERVICE_IS_STANDARD] = 1, [SERVICE_IS_UNIQUE] = 0, * from cte_procedures_and_services_pass_4_standard_services
  union all
  select [SERVICE_IS_STANDARD] = 0, [SERVICE_IS_UNIQUE] = 1, * from cte_procedures_and_services_pass_4_unique_services
) as q1  
)
,

/*###########################################################################
  # cte_procedures_and_services_pass_5
  #
  # Mark if service is individual or group 
  # Compute what selection options should be shown
  # Eliminate any blank service names
  ###########################################################################*/ 

cte_procedures_and_services_pass_5
as
(
select 
  * 

  , SERVICE_IS_IND_OR_GRP = case when ((SERVICE_TYPE_ID = 2) and (SERVICE_SUB_TYPE_1_ID = 2001))  then 'GRP' 
                                 when ((SERVICE_TYPE_ID = 2) and (SERVICE_SUB_TYPE_1_ID = 2000))  then 'IND'
                                 when  (SERVICE_TYPE_ID = 2)                                    then 'IND'
                                 else ''
                                 end 

  , SERVICE_ENTRY_MINUTES_REQUIRED = case 
      when (PROCEDURE_BILLING_PROGRAM_ID = 1) then
      case 
        when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_ASSESS()) then 
          case 		  
		    when (SELECT_PROC_FOR_CLAIM_USING_NUM_MINS = 1)                      then 1
		    when ((PROCEDURE_MIN_UNITS = N'0') and (PROCEDURE_MAX_UNITS = N'1')) then 0 
		    else 1 
		  end
        when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_TREATMENT()) then 1
        when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_TCM())       then 1
        when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT()) then 0
		when (SERVICE_TYPE_ID = 5) then
		  case 
		    when (SERVICE_SUB_TYPE_1_ID = 5003) then 1 
			else 0 
		  end
        else 0
     end /* LEA BOP */
     when (PROCEDURE_BILLING_PROGRAM_ID = 2) then
	   case 
	     when (SERVICE_TYPE_ID = 5) then 0
		 else 1
	 end /* CYBHI */
		         	 	   
     when (PROCEDURE_BILLING_PROGRAM_ID = 3) then 0  /* RU health is just assmts right now so no mins required */
   
   end /* Mins required */

  , SERVICE_ENTRY_MILES_REQUIRED = case 
      when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT()) then 1
                                                              else 0
    end
    
  , SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED = case
      when (NUM_SELECT_CHILD_PROCS_USING_SVC_DET_FLAGS > 0) then 1
      when (SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS  = 1) then 1
                                                            else 0
    end

  
  , SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_1  = case when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_TRANSPORT()) 
                                                    then 'SHOW_MILES' 
                                                    else 'SHOW_MINUTES' 
                                                  end

  , SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_2  = case when (PROCEDURE_BILLING_PROGRAM_ID = 1) then
                                                  case 
                                                    
                                                    /* Speech Assessements after 7/1/2016 require entry of
                                                     * additional detail data. */
                                                    
                                                    when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_ASSESS()) then
                                                      case when 
                                                           ((SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS = 1)
                                                        and (SERVICE_IS_IN_IFSP_IEP = 1) 
                                                        and (PROCEDURE_CODE in ('92506','Q92506'))
                                                        and (GROUP_SERVICE_CLASS_NAME_ID = 9)
                                                        and (PROCEDURE_START_DATE >= dbo.CONST_SPEECH_ASSMT_SVC_DETAILS_REQUIRED_START_DATE()))
                                                      then 'SHOW_SPEECH_ASSESS_OPTIONS' else '' 
                                                    end
                                                    
                                                    /*  All treatments after 7/1/2018 by everyone require ORP
                                                     *  data to be submitted with any claims.
                                                     *  We have to ask for a prescription or order document unless..                                                     
                                                     *
                                                     * 1. There is a special authorization document for a given client
                                                     *    issued by a qualified ORP that covers all patients at that
                                                     *    client for services rendered by OT or PTs within a authorized 
                                                     *    dos range.
                                                     *
                                                     * 2. The rendering practitioner is in the Speech Discipline family
                                                     *    in which case we will be using 
                                                     
                                                     * explicit selection of a document for each individial patient
                                                     * from an ORP authorizing the service.  Speech also requires
                                                     * an ORP but it will be covered by a client wide PBS for all
                                                     * patients.
                                                     */
                                                     
                                                    when (SERVICE_TYPE_ID = dbo.CONST_SERVICES_TREATMENT()) then
                                                      case when (SERVICE_ENTRY_ORP_DOCUMENT_REQUIRED = 1) then
                                                        /* Doc is required, do we have to ask for it */
                                                        
                                                        /* OT or PT.  Ask only if we have to */
                                                        case 
                                                        when (GROUP_SERVICE_CLASS_NAME_ID in (9))   then '' /* Speech group, we never ask */                                                        
                                                        when (GROUP_SERVICE_CLASS_NAME_ID in (4,6)) then (case when (GROUP_SERVICE_CLASS_NUM_SPEC_AUTH_DOC_AVAIL = 0) then 'SHOW_TREATMENT_ORP_DOC_SELECTION' else '' end)
                                                        else 'SHOW_TREATMENT_ORP_DOC_SELECTION'
                                                      end else '' /* Doc is not required */
                                                    end  /* Treatment */
                                                    
                                                    
                                                    else '' /* If this is not assmt or tmt */
                                                end /* lea bop */
                                              else '' /*All other billing programs */
											  end /* show options 2*/
 
  , SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_3 = iif((    ([SERVICE_IS_VIA_TELEHEALTH] = 1) 
                                                      and (convert(date,@procedureIsEffectiveForDOS) = convert(date,getdate()))
													  and (1=1)
													  )
	                                                  , 'SHOW_TELEHEALTH'
	                                                  , '')    
 , SELECTION_FOR_MODALITY_FLAGS = case 
     when (SERVICE_TYPE_ID in (1,2,4) or ((SERVICE_TYPE_ID = 5) and (SERVICE_SUB_TYPE_1_ID in (5003,5004)))) then
	   case when [SERVICE_IS_VIA_TELEHEALTH] = 1 then 1 else 2 end	      
	 else 3
   end

from cte_procedures_and_services_pass_4
where ([SERVICE_NAME] != '')
)
,
/*###########################################################################
  # cte_procedures_and_services_pass_6
  #
  ###########################################################################*/ 
  
cte_procedures_and_services_pass_6
as
(

select

  SERVICE_PLAN_TYPE_ID
, SERVICE_PLAN_TYPE
, SERVICE_TYPE_ID
, SERVICE_TYPE
, SERVICE_SUB_TYPE_1_ID
, SERVICE_SUB_TYPE_1
, SERVICE_NAME_ID
, SERVICE_NAME_ALIAS_NAME_ID

/* Display assigned calpads code before service name if there is no code predefined already */

, [SERVICE_NAME] = iif ( ((SERVICE_NAME like '[0-9][0-9][0-9] - %') and (CALPADS_SPED_SVC_CODE_VALUE_STR != ''))
                       , SERVICE_NAME
                       , iif( (CALPADS_SPED_SVC_CODE_VALUE_STR = '')
					          , SERVICE_NAME
					          , (CALPADS_SPED_SVC_CODE_VALUE_STR + ' - ' + SERVICE_NAME))
				     )
			   
, SERVICE_NAME_STANDARD
, SERVICE_NAME_ALIAS
, SERVICE_NAME_ALIAS_RECORD_ID
, SERVICE_NAME_ALIAS_FOR_CLIENT_ID
, SERVICE_NAME_ALIAS_FOR_GROUP_ID
, SERVICE_IS_IN_IFSP_IEP
, SERVICE_IS_IN_NO_PLAN
, SERVICE_IS_IN_CYBHI
, SERVICE_IS_IN_RU_HEALTH
, SERVICE_IS_BILLABLE
, SERVICE_HAS_NAME
, SERVICE_USING_ALIAS
, SERVICE_IS_STANDARD
, SERVICE_IS_UNIQUE
, SERVICE_IS_IND_OR_GRP
, GROUP_ID
, GROUP_ID_PARENT_ID
, GROUP_NAME
, GROUP_NAME_ABBREVIATION
, GROUP_TYPE_ID
, GROUP_TYPE_TITLE
, GROUP_TYPE_DESCRIPTION 
, GROUP_BASE
, GROUP_SERVICE_CLASS_NAME_ID
, GROUP_SERVICE_CLASS_NAME_NAME
, GROUP_IS_MAA
, GROUP_IS_NOT_MAA

, PROCEDURE_IEP_IFSP_NAME_ID
, PROCEDURE_NO_PLAN_NAME_ID
, PROCEDURE_CYBHI_NAME_ID
, PROCEDURE_RU_HEALTH_NAME_ID

, PROCEDURE_IS_SERVICE_SELECTION
, PROCEDURE_IS_CPT_PROCEDURE
, PROCEDURE_ID
, PROCEDURE_PARENT_PROCEDURE_ID
, PROCEDURE_NAME
, PROCEDURE_CODE
, PROCEDURE_MOD_1
, PROCEDURE_MOD_2
, PROCEDURE_MOD_3
, PROCEDURE_MOD_4
, PROCEDURE_PROC_MOD_COMBO
, PROCEDURE_MAN_PAGE
, PROCEDURE_DIAGNOSIS_CODE
, PROCEDURE_MAX_SERVICE_UNITS
, PROCEDURE_MIN_UNITS
, PROCEDURE_MAX_UNITS
, PROCEDURE_UNIT_TYPE
, PROCEDURE_YEARLY_FLAG
, PROCEDURE_IEP_REQUIRED
, PROCEDURE_SERVICE_FEE
, PROCEDURE_OVER_17_FEE
, PROCEDURE_UNDER_18_FEE
, PROCEDURE_TCM_LOW_RATE
, PROCEDURE_TCM_MEDIUM_RATE
, PROCEDURE_TCM_HIGH_RATE
, PROCEDURE_START_DATE
, PROCEDURE_END_DATE
, PROCEDURE_ACTIVE
, PROCEDURE_CODE_IS_Q
, PROCEDURE_CODE_IS_QQ
, PROCEDURE_HAS_LOGICAL_22
, PROCEDURE_HAS_22
, PROCEDURE_HAS_52
, PROCEDURE_HAS_TS
, PROCEDURE_HAS_TL
, PROCEDURE_HAS_TM
, PROCEDURE_HAS_GT
, PROCEDURE_HAS_95
, PROCEDURE_HAS_U1
, PROCEDURE_CLAIM_SPAN_2
, PROCEDURE_TRANS_PROC_NUM
, PROCEDURE_ONE_ON_ONE_AIDE_PROC_FOR
, PROCEDURE_IS_ONE_ON_ONE
, PROCEDURE_IS_IN_ALLOWED_PROCEDURES
, PROCEDURE_ALLOWED_FOR_CLIENT_ID
, PROCEDURE_ALLOWED_FOR_GROUP_ID
, PROCEDURE_BILLING_PROGRAM_ID

, SELECT_PROC_FOR_CLAIM_USING_CHILD_PROCS
, NUM_SELECT_CHILD_PROCS_USING_SVC_DET_FLAGS
, SELECT_PROC_FOR_CLAIM_USING_NAME_ID_AND_PROC_DATA
, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS
, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_APPLY_MASK_VALUE
, SELECT_PROC_FOR_CLAIM_USING_SVC_DET_FLAGS_IF_MASK_RESULT_IS_VALUE
, SELECT_PROC_FOR_CLAIM_USING_NUM_MINS
, SELECT_PROC_FOR_CLAIM_USING_NUM_MINS_MIN_COUNT
, SEL_PROC_FOR_CLAIM_USING_NUM_MINS_MAX_COUNT /* Named to prevent conflict with any existing pseudo cols */
, TIME_UNIT_MINS_START
, TIME_UNIT_MINS_END
, TIME_UNIT_MINS_ROUND_AT

, SERVICE_ENTRY_MINUTES_REQUIRED
, SERVICE_ENTRY_MILES_REQUIRED
, SERVICE_ENTRY_SVC_DETAIL_FLAGS_REQUIRED 
, SERVICE_ENTRY_ORP_DOCUMENT_REQUIRED
, SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_1
, SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_2
, SERVICE_ENTRY_SVC_SELECTION_SHOW_OPTIONS_3

, [PROCEDURE_OK_TO_INCLUDE_IN_837]
, [GROUP_IS_ACTIVE]

, [SERVICE_RENDERED_VIA] = case 
     when (SELECTION_FOR_MODALITY_FLAGS = 1) then 'TELEHEALTH' 
	 when (SELECTION_FOR_MODALITY_FLAGS = 2) then 'IN_PERSON'	      
	 when (SELECTION_FOR_MODALITY_FLAGS = 3) then 'TELEHEALTH | IN_PERSON'
	 else 'TELEHEALTH | IN_PERSON'
   end

, [SERVICE_IS_VIA_TELEHEALTH]
, [SERVICE_IS_DYADIC]

, [CALPADS_SPED_SVC_CODE_VALUE]
, [CALPADS_SPED_SVC_CODE_NAME] 
, [CALPADS_SPED_SVC_CODE_VALUE_STR]

, [SELECTION_FOR_MODALITY_FLAGS]

from cte_procedures_and_services_pass_5 as p5

where(
      (1=1)
  and ((@servicePlanTypeID  is null) or ([SERVICE_PLAN_TYPE_ID]               = @servicePlanTypeID))
  and ((@serviceTypeID      is null) or ([SERVICE_TYPE_ID]                    = @serviceTypeID))
  and ((@serviceNameID      is null) or ([SERVICE_NAME_ID]                    = @serviceNameID))             
  and ((@procedureIsAllowed is null) or ([PROCEDURE_IS_IN_ALLOWED_PROCEDURES] = @procedureIsAllowed)))
)

/*###########################################################################
  # Output pass
  ###########################################################################*/ 

select  
   [SERVICE_ROW] = ROW_NUMBER () over (order by p6.SERVICE_PLAN_TYPE_ID, p6.SERVICE_TYPE_ID, p6.GROUP_ID, p6.PROCEDURE_ID) 
  , p6.*
  , SERVICE_NAME_WITHOUT_IN_PERSON_OR_TELEHEALTH_TEXT = dbo.SERVICE_NAME_REMOVE_IN_PERSON_AND_TELE_HEALTH_TEXT([SERVICE_NAME]) 
  , SERVICE_NAME_ID_ALT_MODALITY                      = csnamx2.nameIDAltModality
  , SERVICE_NAME_LIST_DATA_SOURCE_ID   = csnlds2.[id]
  , SERVICE_NAME_LIST_DATA_SOURCE_NAME = csnlds2.[name]
from cte_procedures_and_services_pass_6 as p6

outer apply (
  select top 1
    csnlds1.[id]   
  , csnlds1.[name] 
	  
  from dbo.CLAIM_Svc_Names_List_Data_Sources as csnlds1 
  where ( 
        (csnlds1.isIEPOrIFSP      = p6.SERVICE_IS_IN_IFSP_IEP)
    and (csnlds1.billingProgramID = p6.PROCEDURE_BILLING_PROGRAM_ID)
  )
) as csnlds2

outer apply ( 
  select top 1 
     csnamx1.nameIDAltModality    
  from dbo.CLAIM_SERVICE_NAME_ALT_MODALITY_XREF as csnamx1
  where (
        (csnamx1.groupID    = p6.GROUP_ID)
    and (csnamx1.planTypeID = p6.SERVICE_PLAN_TYPE_ID)
    and (csnamx1.nameID     = p6.SERVICE_NAME_ID)
  )
) as csnamx2

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICES_VIEW_ALL_CORE] TO [webuser]
GO