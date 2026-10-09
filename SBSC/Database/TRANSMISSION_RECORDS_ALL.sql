USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[TRANSMISSION_RECORDS_ALL]'))
DROP VIEW [dbo].[TRANSMISSION_RECORDS_ALL]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[TRANSMISSION_RECORDS_ALL] 
AS 
(

/***************************************************************************    
 * TRANSMISSION_RECORDS_ALL */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select 
   TRANSMISSION_ROLLBACK_ID = null
  , tr.* 
from dbo.Transmission_Records as tr

union 

select 
  tra.* 
from dbo.Transmission_Records_Archive as tra

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSMISSION_RECORDS_ALL] TO [webuser]
GO
