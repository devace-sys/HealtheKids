USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_View_Prescribed_Orders_Prac_Training_Details] (
  @prescribedOrderID bigint
)    
RETURNS
TABLE
AS
RETURN
(
  select       
      [rowOrder]     = ROW_NUMBER() OVER (ORDER BY pid.id)
    , [id]           = pid.id
    , [pracID]       = pid.pracID
    , [pracName]     = prp.CONCAT_NAME
    , [pracTitle]    = gg.GROUP_NAME
    , [trainingDate] = isnull(pid.trainingDateTxt,'')

  from dbo.SvcJournal_Prescribed_Orders_Prac_Training_Details as pid 
  join dbo.PRACTITIONER_Practitioner                          as prp on  prp.PRACTITIONER_ID = pid.pracID
  join dbo.PRACTITIONER_GROUPS                                as prg on  prg.PRACTITIONER_ID = prp.PRACTITIONER_ID
                                                                     and prg.GROUP_TYPE in (1,2)
                                                                     and prg.ACTIVE = 1
  join dbo.GROUP_Group                                        as gg  on  gg.GROUP_ID         = prg.GROUP_ID
  
  where (pid.prescribedOrderID = @prescribedOrderID)
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_View_Prescribed_Orders_Prac_Training_Details] TO [webuser]
GO   
