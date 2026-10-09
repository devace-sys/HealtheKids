USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_TYPES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ONE_ON_ONE_AIDE_TYPES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ONE_ON_ONE_AIDE_TYPES_VIEW]
(
)

RETURNS TABLE 

/***************************************************************************    
 * ONE_ON_ONE_AIDE_TYPES_VIEW */    
/**    
 * Returns a table of one on one aid types
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(

  select
   
    [Name] = case
      when [Value] = 'RN'  then 'Registered Nurse'
      when [Value] = 'LVN' then 'Licensed Vocational Nurse'
      when [Value] = 'HA'  then 'Health Aide'
    end,
    
    [Value]
    
  from
  (  
    select distinct    
      one_on_one_aide_proc_for as [Value]
    from 
      SERVICES_VIEW_ALL() 
    where 
      one_on_one_aide_proc_for <> ''
  ) as q1
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ONE_ON_ONE_AIDE_TYPES_VIEW] TO [webuser]
GO   

