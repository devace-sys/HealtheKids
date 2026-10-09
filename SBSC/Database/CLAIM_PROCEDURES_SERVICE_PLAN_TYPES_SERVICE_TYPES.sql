USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CLAIM_PROCEDURES_SERVICE_PLAN_TYPES_SERVICE_TYPES]'))
DROP VIEW [dbo].[CLAIM_PROCEDURES_SERVICE_PLAN_TYPES_SERVICE_TYPES]
GO

CREATE VIEW [dbo].[CLAIM_PROCEDURES_SERVICE_PLAN_TYPES_SERVICE_TYPES] 
AS 

/***************************************************************************    
 * CLAIM_PROCEDURES_SERVICE_PLAN_TYPES_SERVICE_TYPES */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

/* All possible combos */

select 
      SERVICE_PLAN_TYPE_ID    = t2.PLAN_TYPE_ID
    , SERVICE_PLAN_TYPE_NAME  = t2.PLAN_NAME
    , t1.*
  from       dbo.CLAIM_PROCEDURES_SERVICE_TYPES_AND_SUB_TYPES as t1
  cross join dbo.CLAIM_PROCEDURES_SERVICE_PLAN_TYPES          as t2
GO


