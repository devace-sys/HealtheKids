USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW_ALL') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW_ALL
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SERVICES_VIEW_ALL] () 
RETURNS TABLE    

/***************************************************************************    
 * SERVICES_VIEW_ALL() */    
/**    
 * Core function.  Provides mapping between practitioner groups, procedures,
 * service names, etc.  Also abstracts out some poor table design.
 *
 * @return table 
 ***************************************************************************/     

AS RETURN (     

select
   [SERVICE_TYPE]                       as [svc]
  ,[SERVICE_PLAN_TYPE]                  as [plan]
  ,[PROCEDURE_MAN_PAGE]                 as [man_page]
  ,[SERVICE_NAME]                       as [svc_name]
  ,[GROUP_NAME]                         as [prac_group]
  ,[PROCEDURE_CODE]                     as [proc_code]
  ,[PROCEDURE_NAME]                     as [proc_name]
  ,[PROCEDURE_MOD_1]                    as [proc_mod1]
  ,[PROCEDURE_MOD_2]                    as [proc_mod2]
  ,[PROCEDURE_MOD_3]                    as [proc_mod3]
  ,[PROCEDURE_MOD_4]                    as [proc_mod4]
  ,[PROCEDURE_MAX_SERVICE_UNITS]        as [max_svc_units]
  ,[PROCEDURE_MAX_UNITS]                as [max_units]  
  ,[PROCEDURE_DIAGNOSIS_CODE]           as [diagnosis_code]
  ,[PROCEDURE_IEP_REQUIRED]             as [iep_req]     
  ,[PROCEDURE_YEARLY_FLAG]              as [year_flag]
  ,[PROCEDURE_HAS_22]                   as [is22]
  ,[PROCEDURE_HAS_52]                   as [is52]
  ,[PROCEDURE_HAS_TS]                   as [isTS]
  ,[PROCEDURE_HAS_GT]                   as [isGT]
  ,[PROCEDURE_HAS_95]                   as [is95]
  ,[PROCEDURE_MIN_UNITS]                as [min_units]
  ,[PROCEDURE_CLAIM_SPAN_2]             as [claim_span_2]
  ,[PROCEDURE_TRANS_PROC_NUM]           as [trans_proc_num]
  ,[PROCEDURE_ONE_ON_ONE_AIDE_PROC_FOR] as [one_on_one_aide_proc_for]
  ,[PROCEDURE_IS_ONE_ON_ONE]            as [isOneOnOne]
  ,[PROCEDURE_SERVICE_FEE]              as [service_fee]
  ,[PROCEDURE_OVER_17_FEE]              as [over_17_fee]    
  ,[PROCEDURE_UNDER_18_FEE]             as [under_18_fee]
  ,[PROCEDURE_TCM_LOW_RATE]             as [tcm_low_rate]
  ,[PROCEDURE_TCM_MEDIUM_RATE]          as [tcm_med_rate]
  ,[PROCEDURE_TCM_HIGH_RATE]            as [tcm_high_rate]  
  ,[SERVICE_PLAN_TYPE_ID]               as [plan_type]    
  ,[SERVICE_TYPE_ID]                    as [svc_type]     
  ,[SERVICE_NAME_ID]                    as [name_id]    
  ,[PROCEDURE_ID]                       as [proc_id]    
  ,[GROUP_ID]                           as [prac_group_id]
  ,[GROUP_IS_MAA]                       as [prac_group_is_maa] 
  ,[GROUP_IS_NOT_MAA]                   as [prac_group_is_not_maa]
  
from dbo.SERVICES_VIEW_ALL_CORE(null,null,null,null,null,1,null,null,null)

)    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICES_VIEW_ALL] TO [webuser]
GO
