USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[CDE_SCHOOLS_PRIVATE_SITES_CURRENT]'))
DROP VIEW [dbo].[CDE_SCHOOLS_PRIVATE_SITES_CURRENT]
GO

CREATE VIEW [dbo].[CDE_SCHOOLS_PRIVATE_SITES_CURRENT] 
AS 

/***************************************************************************    
 * CDE_SCHOOLS_PRIVATE_CURRENT */
/**    
 * The private school data is stored by appending the annual file we download
 * from the CDE website.  The file contains schools that submitted aff
 * for the fiscal year the file is named after.  Unlike the public CDE file
 * these files do not contain historical data.  Therefore we import the entire
 * file and append it to the table along with data that identifies when
 * it was published by CDE and the fiscal year the data pertains to.  
 *
 * This creates duplicate entries for some sites that differ only by published
 * date and fiscal year.
 *
 * This view queries that table and returns the most current data available.
 * @returns table
 ***************************************************************************/     

select
*
from
(
  select 
     t2.*
   , CDS_FIRST_7 = SUBSTRING(t2.[CDS Code],1,7)  
   , CDS_LAST_7  = SUBSTRING(t2.[CDS Code],8,7)  
  from
  (
    select 
      [Cds Code]
    , max([Published Date]) as [Published Date]
    from dbo.CDE_SCHOOLS_PRIVATE
    group by
      [CDS Code]
  ) as t1
  join dbo.CDE_SCHOOLS_PRIVATE as t2 on  t2.[CDS Code]       = t1.[CDS Code]
                                     and t2.[Published Date] = t1.[Published Date]
) as t3
where (t3.CDS_LAST_7 != '0000000')

GO