USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENT_ATTENDANCE_DAY_TYPES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENT_ATTENDANCE_DAY_TYPES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[CLIENT_ATTENDANCE_DAY_TYPES_VIEW]
(@userID       INT,    
 @userGroup    INT,    
 @userRank     INT,
 @clientID     int,
 @active       bit,
 @recID        bigint)

RETURNS TABLE 

/***************************************************************************    
 * CLIENT_ATTENDANCE_DAY_TYPES_VIEW */    
/**    
 * Returns a table of client attendance day types
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(
  
with 

/*============================================================
 * Day Types Shared by All Clients
 * This ensures we can return a shared list
 *============================================================*/  

cte_shared_day_types
as
(
  select 
    * ,
    '' as clientName  
  from CLIENT_ATTENDANCE_DAY_TYPES     
  where (clientID is null)
)
,

/*============================================================
 * All Day Types
 * This ensures we can return a client or record specific list
 *============================================================*/  

cte_client_specific_day_types
as
(
  select 
    ca.*,
    isnull(cc.CLIENT_NAME,'') as clientName  
  from    CLIENT_ATTENDANCE_DAY_TYPES   as ca
  left join CLIENTS_CLIENT              as cc  on cc.CLIENT_ID = ca.clientID
  where
    (1=1) 
    and ((@clientID is null) or (clientID = @clientID)) 
    and ((@recID    is null) or (id       = @recID))        
)
,

/*============================================================
 * All Day Types Combined
 *============================================================*/  

cte_combo_day_types
as
(
  select distinct *
  from
  (
    select * from cte_shared_day_types 
    union
    select * from cte_client_specific_day_types
  ) as q1
  
)

/*============================================================
 * Output
 *============================================================*/  

select * from cte_combo_day_types
where 
      (1=1)

  and ((@active   is null) or (Active   = @active))
  and ((@recID    is null) or (id       = @recID))        
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENT_ATTENDANCE_DAY_TYPES_VIEW] TO [webuser]
GO   

