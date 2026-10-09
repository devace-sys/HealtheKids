USE [SPEDMON]
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons_View') AND type IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons_View
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons_View] (    
    @userID      BIGINT
  , @userGroup   INT   
  , @userRank    INT
  , @term		 varchar(256)
)
 
RETURNS TABLE      
    
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS())
     t1.*
  from dbo.PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons as t1
  where (
         (t1.active = 1)
	and ( (@term is null) or (t1.[name] like (('%' + @term + '%'))) )
  )
  order by 
    t1.id
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].PATIENTS_Promised_Services_Delivery_Exception_Removed_Reasons_View TO [webuser]
GO   


