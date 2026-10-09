USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SELPA_RELATED_CLIENTS_VIEW') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SELPA_RELATED_CLIENTS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SELPA_RELATED_CLIENTS_VIEW] (    
    @userID    bigint
  , @userGroup int
  , @userRank  int
  , @selpaCode int
)
 
RETURNS TABLE      
AS RETURN
(      
select top (dbo.CONST_MAX_ROWS())
    t1.clientID
  , t1.clientName
  , t1.selpaCode
  , t1.selpaName
from dbo.SELPA_RELATED_CLIENTS_VIEW_CORE(@selpaCode) as t1
order by 
  t1.clientName 
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SELPA_RELATED_CLIENTS_VIEW] TO [webuser]
GO   

