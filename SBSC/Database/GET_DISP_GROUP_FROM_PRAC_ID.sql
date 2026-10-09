USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_DISP_GROUP_FROM_PRAC_ID') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_DISP_GROUP_FROM_PRAC_ID
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GET_DISP_GROUP_FROM_PRAC_ID] (@pracID bigint)
RETURNS bigint
WITH SCHEMABINDING
AS     
BEGIN         
 declare @groupID as bigint = null
 select top 1        
   @groupID = prg.GROUP_ID   
 from dbo.PRACTITIONER_PRACTITIONER as prp  
 join dbo.PRACTITIONER_GROUPS       as prg  on  prg.PRACTITIONER_ID =  prp.PRACTITIONER_ID
                                                and prg.GROUP_TYPE in ( 1, 2 )
 where 
   (prp.PRACTITIONER_ID = @pracID)
                  
 return @groupID 
END    
GO