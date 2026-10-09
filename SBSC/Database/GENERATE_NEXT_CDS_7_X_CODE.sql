USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[GENERATE_NEXT_CDS_7_X_CODE]'))
DROP VIEW [dbo].[GENERATE_NEXT_CDS_7_X_CODE]
GO

CREATE VIEW [dbo].[GENERATE_NEXT_CDS_7_X_CODE]
AS 
select top 1 
  NEXT_CDS_NUMBER = convert(nchar(7),(N'x' + right(N'000000'+ rtrim((convert(nvarchar(6),(q3.maxLastNumPartVal + 1)))),6)))
from
(
  select
    maxLastNumPartVal = max(q2.lastNumPartVal)  
  from
  (
    select
      lastNumPartVal = convert(int,q1.lastNumPartStr)
    from
    (
      select 
        lastNumPartStr = SUBSTRING(ss.SITE_CDS,2,7)
      from dbo.SITES_Site as ss
	  where (left(trim(ss.SITE_CDS),1) = N'x') 
      
    ) as q1
    where (ISNUMERIC(q1.lastNumPartStr) = 1)
  ) as q2
) as q3

GO