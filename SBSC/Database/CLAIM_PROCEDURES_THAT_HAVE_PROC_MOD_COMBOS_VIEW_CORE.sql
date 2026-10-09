USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLAIM_PROCEDURES_THAT_HAVE_PROC_MOD_COMBOS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLAIM_PROCEDURES_THAT_HAVE_PROC_MOD_COMBOS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[CLAIM_PROCEDURES_THAT_HAVE_PROC_MOD_COMBOS_VIEW_CORE] (
    @procModCombosStr as varchar(8000)
  , @billingProgramID as tinyint 
)  
returns
table
as
return
(
  select 
 
    mp.* 
  
  from dbo.CLAIM_PROCEDURE_PROC_MOD_COMBO_STRS_TO_FIELDS(@procModCombosStr) as t1

  cross apply (
    select 
      cp.*
    from dbo.CLAIM_Procedures as cp
    where 
	  (1=1)
	  and ((@billingProgramID is null) or (cp.billingProgramID = @billingProgramID))
	  and ( dbo.CLAIM_PROCEDURE_COMPARE(   cp.PROCEDURE_CODE
	                                , cp.PROCEDURE_MODIFIER_1
		  				 		    , cp.PROCEDURE_MODIFIER_2
			 						, cp.PROCEDURE_MODIFIER_3
									, cp.PROCEDURE_MODIFIER_4
                                    , t1.PROCEDURE_CODE
									, t1.PROCEDURE_MODIFIER_1
									, t1.PROCEDURE_MODIFIER_2
									, t1.PROCEDURE_MODIFIER_3
									, t1.PROCEDURE_MODIFIER_4) = 1 ) 
  ) as mp
  
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLAIM_PROCEDURES_THAT_HAVE_PROC_MOD_COMBOS_VIEW_CORE] TO [webuser]
GO
