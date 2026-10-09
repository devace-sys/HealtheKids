USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RPT_PRACTITONERS_REVIEWS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RPT_PRACTITONERS_REVIEWS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[RPT_PRACTITONERS_REVIEWS](      
  @clientID    INT,   
  @pracID      BIGINT,   
  @batchID     BIGINT,
  @statusID    INT,
  @ctgryID     INT,  
  @active      BIT )   
 
RETURNS TABLE      

/***************************************************************************    
 * RPT_PRACTITONERS_REVIEWS */    
/**    
 * Returns a table of practitioner reviews that match the given parameters.    
 *    
 * @param  ctgryID         categoryID  
 * @param  pracID          practitioners ID    
 * @param  active          If practitioner is active
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
    p.clientName               as Client,     
    p.name                     as Practitioner,
    c.CATEGORY_NAME            as Category,    
    pph.PROBLEM_SUMMARY        as Review,
    u.firstname+' '+u.lastname as ReviewedBy,
    pph.INPUT_BATCH_ID         as BatchID,
    pph.id                     as ReviewID,    
    p.id                       as PractitionerID,
    c.ID                       as CategoryID
  from dbo.PRACTITONERS_VIEW(null,null,null,0,@pracID, @clientID, null, null, null, null, null, null, @active, null, null) as p
       join   
       dbo.PRACTITIONERS_Problem_History as pph on pph.prac_id = p.id
                                               AND pph.ACTIVE  = 1
       left join dbo.STAMP_CATEGORIES    as c   on c.ID        = pph.Category
       left join input_batches           as ib  on ib.id       = pph.input_batch_id
       left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)
	                                     as u   on u.ID        = pph.REPORTED_BY
 where (@batchID  is null   or pph.INPUT_BATCH_ID     = @batchID)
   and (@ctgryID  is null   or pph.Category           = @ctgryID)  
   and (@statusID is null   or ib.Current_status_Code = @statusID or ib.Current_status_Code = 290 )                                                 
  ) as pv
  where (1=1)         
  order by pv.client, pv.Practitioner
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RPT_PRACTITONERS_REVIEWS] TO [webuser]
GO
