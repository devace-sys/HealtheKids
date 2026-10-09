USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CLAIM_PROCEDURES_SERVICE_TYPES_AND_SUB_TYPES]'))
DROP VIEW [dbo].[CLAIM_PROCEDURES_SERVICE_TYPES_AND_SUB_TYPES]
GO

CREATE VIEW [dbo].[CLAIM_PROCEDURES_SERVICE_TYPES_AND_SUB_TYPES] 
AS 

/***************************************************************************    
 * CLAIM_PROCEDURES_SERVICE_TYPES_AND_SUB_TYPES */
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select 
      SERVICE_TYPE_ID         = t1.SERVICE_TYPE_ID
    , SERVICE_TYPE_NAME       = t1.SERVICE_TYPE_NAME
    , SERVICE_SUB_TYPE_1_ID   = t2.SERVICE_TYPE_ID
    , SERVICE_SUB_TYPE_1_NAME = t2.SERVICE_TYPE_NAME

  from      dbo.CLAIM_Procedures_Service_Types as t1
  left join dbo.CLAIM_Procedures_Service_Types as t2 on t2.SERVICE_TYPE_PARENT_ID = t1.SERVICE_TYPE_ID

  where 
    (t1.SERVICE_TYPE_PARENT_ID is null)
  

GO


