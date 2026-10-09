USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GENERATE_NEW_UNIQUE_ID]'))
DROP VIEW [dbo].[GENERATE_NEW_UNIQUE_ID]
GO

CREATE VIEW [dbo].[GENERATE_NEW_UNIQUE_ID] 
AS 

/***************************************************************************    
 * GENERATE_NEW_UNIQUE_ID */    
/**    
 * Generates unique id that can be used for various purposes
 *
 * @return table
 ***************************************************************************/     

select
    NEW_UNIQUE_ID
  , NEW_UNIQUE_ID_STR
  , NEW_UNIQUE_ID_STR_NO_DASH = replace(NEW_UNIQUE_ID_STR,'-','')
from
(
  select 
      NEW_UNIQUE_ID
    , NEW_UNIQUE_ID_STR = convert(varchar(255),lower(convert(varchar(255),NEW_UNIQUE_ID)))
  from
  (
    select NEWID() as NEW_UNIQUE_ID
  ) as q1
) as q2

GO


