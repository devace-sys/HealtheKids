USE [SPEDMON]
GO

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CLIENTS_Client_Active_LEA]'))
DROP VIEW [dbo].[CLIENTS_Client_Active_LEA]
GO

USE [SPEDMON]
GO

CREATE VIEW [dbo].[CLIENTS_Client_Active_LEA] 
AS 
(

/***************************************************************************    
 * CLIENTS_Client_Active_LEA */    
/**    
 * 
 *
 * @return table
 ***************************************************************************/     

select
 
    CLIENT_ID
  , CLIENT_NAME
  , REP_NAME
  , REP_EMAIL
  , APPROVED_837
  , APPROVED_835
  , TCM_RATE 
  , HOLD_CLIENT_WORK_FOR_DAYS
  , CLIENT_CLAIM_TCM
  , CLIENT_CLAIM_NO_PLAN 
  , CLIENT_PARENT_CONSENT_AGREEMENT
  , LAST_TRANSMISSION_GENERATION_ID
  , LAST_TRANSMISSION_DATETIME
  , REP_ID
from dbo.CLIENTS_Client_All as cca
where (cca.LEA = 1)

)
GO
