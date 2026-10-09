USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_STAFF_REVIEWS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_STAFF_REVIEWS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_STAFF_REVIEWS](      
  @staffID     BIGINT,   
  @batchID     BIGINT,
  @ctgryID     INT,  
  @active      BIT )   
 
RETURNS TABLE      

/***************************************************************************    
 * RPT_STAFF_REVIEWS */    
/**    
 * Returns a table of staff reviews that match the given parameters.    
 *    
 * @param  ctgryID         categoryID  
 * @param  staffID         STAFF ID    
 * @param  active          if the staff review record is active
 * @param  batchID         Input batch ID    
 * @return                 Table of practitioner data    
 ***************************************************************************/     
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
  select 
    u1.firstname+' '+u1.lastname as Staff,
    c.CATEGORY_NAME              as Category,    
    sph.PROBLEM_SUMMARY          as Review,
    u2.firstname+' '+u2.lastname as ReviewedBy,
    ib.file_name                 as InputBatch,
    sph.id                       as ReviewID,    
    c.id                         as StaffID,
    c.ID                         as CategoryID
  from users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null) as u1
       join   
       dbo.STAFF_Problem_History as sph on sph.staff_id = u1.id
                                       AND sph.ACTIVE   = 1
       left join dbo.STAFF_PROBLEM_CATEGORIES as c   on c.ID  = sph.Category
       left join input_batches                as ib  on ib.id = sph.input_batch_id
       left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)
	                                     as u2   on u2.ID     = sph.REPORTED_BY
 where (@batchID  is null   or sph.INPUT_BATCH_ID     = @batchID)
   and (@staffID  is null   or u1.id                  = @staffID)  
   and (@ctgryID  is null   or sph.Category           = @ctgryID)  
  ) as pv
  where (1=1)         
  order by pv.Staff
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_STAFF_REVIEWS] TO [webuser]
GO
