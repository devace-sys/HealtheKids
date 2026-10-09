USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_PROCS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ONE_ON_ONE_AIDE_PROCS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ONE_ON_ONE_AIDE_PROCS_VIEW]
(
)

RETURNS TABLE 

/***************************************************************************    
 * ONE_ON_ONE_AIDE_PROCS_VIEW */    
/**    
 * Returns a table of one on one aid procedures
 *
 * @return table 
 ***************************************************************************/     

AS RETURN
(
  select distinct 
    one_on_one_aide_proc_for, 
    proc_id 
  from SERVICES_VIEW_ALL() 
  where 
    one_on_one_aide_proc_for <> ''  
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ONE_ON_ONE_AIDE_PROCS_VIEW] TO [webuser]
GO   

