USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GROUPS_VIEW](  @selectType as int 
                                    , @clientID   as int
                                    , @name       as nvarchar(256)
                                    , @active     as bit
									, @recID      as bigint  )
RETURNS TABLE 

/***************************************************************************
 * GROUPS_VIEW */
/**
 * Returns a list of groups 
 *
 * @param  groupType   "Old" Group type
 *                     1 = Allied discipline LEA + MAA + proc instructions
 *                     2 = Reporting group + category groups
 *                     3 = Allied discipline "super groups"
 * @param  clientID    Client record ID used to display report groups that
 *                     are unique to a given clientID as well as common report
 *                     groups
 * @param  active      Is group active
 *                       
 * @return             Table
 ***************************************************************************/  

AS RETURN (         
  select 
    selectType, 
    parentid, 
    id, 
    name, 
    groupType,
    groupTypeTitle,
    groupTypeDescription,
    clientID, 
    clientName, 
    active 
  from
  (
    /*-------------------------------
     * Allied discipline groups
     *------------------------------*/

    select
      selectType, 
      parentid,
      groupid         as [id], 
      groupname       as [name],
      groupType,
      groupTypeTitle,
      groupTypeDescription,
      clientID,
      clientName,
      active 
    from 
    dbo.GROUP_DISP_VIEW_ALL(@active)
    
    union

    /*-------------------------------
     * Reporting groups
     *------------------------------*/
    
    select 
      selectType,    
      parentid,
      groupid         as [id], 
      groupname       as [name],
      groupType,
      groupTypeTitle,
      groupTypeDescription,
      clientID,
      clientName,
      active
    from
    dbo.GROUP_REPT_VIEW_ALL (@clientID, @active)    
    
    union

    /*-------------------------------
     * Allied discipline
     * "super" groups
     *------------------------------*/
    
    select
      selectType, 
      parentid,
      groupid         as [id], 
      groupname       as [name],
      groupType,
      groupTypeTitle,
      groupTypeDescription,
      clientID,
      clientName,
      active 
    from 
    dbo.GROUP_DISP_SUPER_VIEW_ALL(@active)

  ) as pg
  
  where    
    ((1=1) 
	 and ((@recID  is null) or (pg.id = @recID))
     and ((@name       is null)   or ([name] like '%' + trim(isnull(@name,N'')) + '%'))  
     and ((@selectType is null)   or (selectType  = @selectType)))
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[GROUPS_VIEW] TO [webuser]
GO

