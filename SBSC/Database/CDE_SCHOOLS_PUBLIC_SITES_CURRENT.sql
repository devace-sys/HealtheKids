USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CDE_SCHOOLS_PUBLIC_SITES_CURRENT]'))
DROP VIEW [dbo].[CDE_SCHOOLS_PUBLIC_SITES_CURRENT]
GO

CREATE VIEW [dbo].[CDE_SCHOOLS_PUBLIC_SITES_CURRENT] 
AS 

/***************************************************************************    
 * CDE_SCHOOLS_PUBLIC_SITES_CURRENT */
/**    
 *
 * This view queries that table and returns the most current data available.
 * @returns table
 ***************************************************************************/     

select
  *
from
(
  select 
    *
   , CDS_FIRST_7 = SUBSTRING(CDSCode,1,7)  
   , CDS_LAST_7  = SUBSTRING(CDSCode,8,7)   
  from CDE_SCHOOLS_PUBLIC
  where ((StatusType != 'Merged') and (StatusType != 'Closed'))
) as t1
where (CDS_LAST_7 != '0000000')


GO