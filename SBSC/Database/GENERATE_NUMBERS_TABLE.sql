USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GENERATE_NUMBERS_TABLE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GENERATE_NUMBERS_TABLE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[GENERATE_NUMBERS_TABLE] (
    @max as bigint
)
returns 
table
with schemabinding
as           
return
(
/* Courtesey of https://stackoverflow.com/a/1394239 */
WITH
  Pass0 as (select 1 as C union all select 1),          --2 rows
  Pass1 as (select 1 as C from Pass0 as A, Pass0 as B), --4 rows
  Pass2 as (select 1 as C from Pass1 as A, Pass1 as B), --16 rows
  Pass3 as (select 1 as C from Pass2 as A, Pass2 as B), --256 rows
  Pass4 as (select 1 as C from Pass3 as A, Pass3 as B), --65536 rows
  Pass5 as (select 1 as C from Pass4 as A, Pass4 as B), --4,294,967,296 rows
  Tally as (select row_number() over(order by C) as num from Pass5)
 select 
   num from Tally 
 where (num <= @max)
)
        
GO
