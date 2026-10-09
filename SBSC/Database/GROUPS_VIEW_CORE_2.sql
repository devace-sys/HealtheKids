USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_VIEW_CORE_2') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_VIEW_CORE_2
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GROUPS_VIEW_CORE_2] 
(@groupCategory as int)

RETURNS TABLE 

/***************************************************************************
 * GROUPS_VIEW_CORE_2 */
/**
 * Returns a list of groups based on category.  Category is based on
 * group type
 *
 * @param  groupCategory   Category of groups you want to view.  Category
 *                         is constructed using a combination of group types.
 *                         for example 1234 returns all groups.
 ***************************************************************************/  

AS RETURN (         
  with  
  cte_groups_core as 
  (

   /*-------------------------------
    * Everything
    * This is used as a base query
    *------------------------------*/

    select 
      g.PARENT_GROUP_ID,
      g.GROUP_ID,
      g.GROUP_NAME,
      g.GROUP_TYPE,
      g.GROUP_NAME_ABBREVIATION,
      gt.TITLE,
      /*-------------------------------
       * Modify the description for
       * reporting groups that have
       * speficic clients assigned
       *------------------------------*/
      [DESCRIPTION] = case 
        when (g.GROUP_TYPE <> 3)                                then gt.DESCRIPTION
        when ((g.GROUP_TYPE = 3) AND (g.CLIENT_ID is null))     then 'Non Client Specific ' + gt.DESCRIPTION
        when ((g.GROUP_TYPE = 3) AND (g.CLIENT_ID is not null)) then 'Client SPECIFIC '     + gt.DESCRIPTION                    
      end,
      g.ACTIVE,
      g.CLIENT_ID,
      c.CLIENT_NAME       
    from GROUP_Group         as g  
    join GROUP_GROUP_TYPES   as gt on gt.GROUP_TYPE = g.GROUP_TYPE
    left join CLIENTS_CLIENT as c  on c.CLIENT_ID   = g.CLIENT_ID
  )
  ,
  cte_groups_discipline_1 as 
  (
   
   /*-------------------------------
    * Allied discipline LEA
    *------------------------------*/

    select 1 as [GROUP_CATEGORY], * from cte_groups_core where (GROUP_TYPE = 1)    
    
  )
  ,
  cte_groups_discipline_2 as 
  (
   
   /*-------------------------------
    * Allied discipline LEA + MAA
    *------------------------------*/

    select 2 as [GROUP_CATEGORY], * from cte_groups_core where (GROUP_TYPE = 2)    

  )
  ,
  cte_groups_report as 
  (

   /*-------------------------------
    * Reporting groups
    *------------------------------*/

    select 
    3 as [GROUP_CATEGORY], * from cte_groups_core as gc where (GROUP_TYPE = 3)
  )
  ,
  cte_groups_proc as 
  (

   /*-------------------------------
    * Input/processing instruction
    * groups
    *------------------------------*/

    select 4 as [GROUP_CATEGORY], * from cte_groups_core where (GROUP_TYPE = 4)

  )
  ,
  cte_groups_cat as 
  (

   /*-------------------------------
    * Category (super) groups
    *------------------------------*/

    select 5 as [GROUP_CATEGORY], * from cte_groups_core where (GROUP_TYPE = 5)
  )
  ,
  cte_groups_all_disp as 
  (

   /*-------------------------------
    * All discipline groups
    *------------------------------*/

    select 12 as [GROUP_CATEGORY], * from cte_groups_core where ((GROUP_TYPE = 1) or (GROUP_TYPE = 2))
  )
  ,
  cte_groups_all_except_report_and_cat as 
  (

   /*-------------------------------
    * All groups except reporting
    * and category
    *------------------------------*/

    select 124 as [GROUP_CATEGORY], * from cte_groups_core where ((GROUP_TYPE <> 3) and (GROUP_TYPE <> 5))
  )
  ,
  
  cte_groups_all_report_and_cat as 
  (

   /*-------------------------------
    * All reporting and cat
    *------------------------------*/

    select 35 as [GROUP_CATEGORY], * from cte_groups_core where ((GROUP_TYPE = 3) or (GROUP_TYPE = 5))
  )

  ,
  cte_groups_all as
  (

   /*-------------------------------
    * All groups 
    *------------------------------*/

    select 12345 as [GROUP_CATEGORY] , * from cte_groups_core
  )

  /*-------------------------------
   * Combine
   *------------------------------*/
  
  select *
  from
  (
    select * from cte_groups_discipline_1
    union
    select * from cte_groups_discipline_2
    union
    select * from cte_groups_report
    union
    select * from cte_groups_proc
    union
    select * from cte_groups_cat
    union
    select * from cte_groups_all_disp
    union
    select * from cte_groups_all_except_report_and_cat
    union
    select * from cte_groups_all_report_and_cat
    union
    select * from cte_groups_all
  ) as q1 
  where [GROUP_CATEGORY] = @groupCategory
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[GROUPS_VIEW_CORE_2] TO [webuser]
GO

