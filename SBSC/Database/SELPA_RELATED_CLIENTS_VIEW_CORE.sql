USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SELPA_RELATED_CLIENTS_VIEW_CORE') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SELPA_RELATED_CLIENTS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SELPA_RELATED_CLIENTS_VIEW_CORE] (    
  @selpaCode   int
)
 
RETURNS TABLE      
AS RETURN
(      
    
select 
    selpaCode  = se.code
  , selpaName  = se.[name]
  , clientID   = clc.CLIENT_ID
  , clientName = clc.CLIENT_NAME
 
from dbo.SELPAS         as se 
join dbo.CLIENTS_Client as clc on clc.SELPACode = se.[code]
where (
      (1=1) 
  and ((@selpaCode is null) or (se.code = @selpaCode))
)

)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SELPA_RELATED_CLIENTS_VIEW_CORE] TO [webuser]
GO   

