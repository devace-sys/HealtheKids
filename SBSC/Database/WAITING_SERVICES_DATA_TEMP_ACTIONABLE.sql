USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[WAITING_SERVICES_DATA_TEMP_ACTIONABLE]'))
DROP VIEW [dbo].[WAITING_SERVICES_DATA_TEMP_ACTIONABLE]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[WAITING_SERVICES_DATA_TEMP_ACTIONABLE] 
AS 
(

/***************************************************************************    
 * WAITING_SERVICES_DATA_TEMP_ACTIONABLE */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select 
 *   
from dbo.WAITING_SERVICES_DATA_TEMP
where (
      (holdReason != 'Patient has no BIC')
  and (holdReason != 'Patient has an invalid BIC')
  and (holdReason != 'Service is non billable')  
)

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[WAITING_SERVICES_DATA_TEMP_ACTIONABLE] TO [webuser]
GO
