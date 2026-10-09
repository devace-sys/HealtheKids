USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_VIEW_REFERENCE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_VIEW_REFERENCE
GO
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICES_VIEW_REFERENCE] (
@clientID as int,
@groupID  as int,
@planType as int,
@nameID   as int
)    

returns table     
as    
    
/***************************************************************************    
 * SERVICES_VIEW_REFERENCE */    
/**    
 * Internal helper query used to help locate a distinct nameID    
 *     
 * @return table    
 ***************************************************************************/     
    
return (    

select distinct 

 SERVICE_NAME_ID       as [name_id]
,SERVICE_PLAN_TYPE_ID  as [plan_type]
,SERVICE_NAME          as [svc_name]
,SERVICE_NAME_STANDARD as [svc_name_standard]
,SERVICE_NAME_ALIAS    as [svc_name_alias]

from dbo.SERVICES_VIEW_ALL_CORE (@clientID,@groupID,@planType,null,@nameID,null,null,null,null) 
where (SERVICE_HAS_NAME = 1)      
)  
GO
