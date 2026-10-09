USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[TRANSMISSION_GENERATIONS_ALL]'))
DROP VIEW [dbo].[TRANSMISSION_GENERATIONS_ALL]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[TRANSMISSION_GENERATIONS_ALL] 
AS 
(

/***************************************************************************    
 * TRANSMISSION_GENERATIONS_ALL */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select 
    [TRANSMISSION_ROLLBACK_ID] = null
  , tg.* 
from dbo.TRANSMISSION_GENERATIONS as tg

union 

select 
  tga.* 
from dbo.TRANSMISSION_GENERATIONS_ARCHIVE as tga

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[TRANSMISSION_GENERATIONS_ALL] TO [webuser]
GO
