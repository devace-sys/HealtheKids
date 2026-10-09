USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_PRAC_GROUP_SAME_BASE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_PRAC_GROUP_SAME_BASE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[IS_PRAC_GROUP_SAME_BASE] (@groupID1 int, @groupID2 int)     
returns bit    
    
/***************************************************************************    
 * IS_PRAC_GROUP_SAME_BASE */    
/**    
 * Determines if @groupID1 and @groupID2 are part of the same base group
 *    
 * @param   groupID1        1st group id
 * @param   groupID2        2nd group id
 * @return  true or false
 ***************************************************************************/            
     
as           
begin    

declare @grpID1 as int
declare @grpID2 as int
declare @name1  as varchar(8000)
declare @name2  as varchar(8000)

/*-------------------------------    
 * Bad inputs result in immediate
 * exit with false
 *------------------------------*/    

if (@groupID1 is null) return 0
if (@groupID2 is null) return 0

if (@groupID1 <= 0) return 0
if (@groupID2 <= 0) return 0

/*-------------------------------    
 * Find base name for groupID1
 * if its not found get out
 *------------------------------*/    
    
select @grpID1 = GROUP_ID,
       @name1  = GROUP_BASE
from
  GROUP_Group
where 
  GROUP_ID = @groupID1

if (@grpID1 is null) return 0

/*-------------------------------    
 * Find base name for groupID2
 * if its not found get out
 *------------------------------*/    

select @grpID2 = GROUP_ID,
       @name2  = GROUP_BASE
from
  GROUP_Group
where 
  GROUP_ID = @groupID2

if (@grpID2 is null) return 0

/*-------------------------------    
 * If base names are equal then
 * let the caller know
 *------------------------------*/    

if (@name1 = @name2)
  return 1

/*-------------------------------    
 * Otherwise
 *------------------------------*/    

return 0

end    
    
GO
