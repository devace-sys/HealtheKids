USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_PRAC_GROUP_MAA_NOT_MAA_PAIR') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_PRAC_GROUP_MAA_NOT_MAA_PAIR
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[IS_PRAC_GROUP_MAA_NOT_MAA_PAIR] (@groupID1 int, @groupID2 int)     
returns bit    
    
/***************************************************************************    
 * IS_PRAC_GROUP_MAA_NOT_MAA_PAIR */    
/**    
 * Determines if @groupID1 and @groupID2 are a MAA not MAA pair
 *    
 * @param   groupID1        1st group id
 * @param   groupID2        2nd group id
 * @return  true or false
 ***************************************************************************/            
     
as           
begin    

declare @grpID1 as int
declare @grpID2 as int
declare @name   as varchar(8000)

/*-------------------------------    
 * Bad inputs result in immediate
 * exit with false
 *------------------------------*/    

if (@groupID1 is null) return 0
if (@groupID2 is null) return 0

if (@groupID1 <= 0) return 0
if (@groupID2 <= 0) return 0

/*-------------------------------    
 * Find group name for groupID1
 *------------------------------*/    
    
select @grpID1 = GROUP_ID,
       @name   = lower(dbo.STRING_SUB('(',GROUP_NAME ,1,1))
from
  GROUP_Group
where 
  GROUP_ID = @groupID1
  and (GROUP_TYPE = dbo.CONST_PRAC_GROUP_DISP_LEA()
  or   GROUP_TYPE = dbo.CONST_PRAC_GROUP_DISP_LEA_MAA())


if (@grpID1 is null) return 0

/*-------------------------------    
 * Find matching pair based on
 * name and filtering out the 
 * first groupID
 *------------------------------*/    

select @grpID2 = GROUP_ID
from
(
select GROUP_ID, 
       lower(dbo.STRING_SUB('(',GROUP_NAME ,1,1)) as name
from
  GROUP_Group
where   
 (GROUP_TYPE = dbo.CONST_PRAC_GROUP_DISP_LEA()
  or GROUP_TYPE = dbo.CONST_PRAC_GROUP_DISP_LEA_MAA())
) as q1
where name = @name and GROUP_ID <> @grpID1

if (@grpID2 is null) return 0

/*-------------------------------    
 * Test
 *------------------------------*/    

if (@groupID1 <> @grpID1) return 0
if (@groupID2 <> @grpID2) return 0

return 1

end    
    
GO
