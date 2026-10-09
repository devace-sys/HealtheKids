USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STAMPS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STAMPS_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STAMPS_VIEW](    
 
  @recID       INT,    
  @category    INT,
  @type        varchar(10),
  @active      bit,
  @canEdit     BIT)    
 
RETURNS TABLE      

/***************************************************************************    
 * STAMPS_VIEW */    
/**    
 * Returns a table of STAMP RECORDS that match the given parameters.    
 *       
 *    
 * @param   
 * @param  
 * @param  canEdit         If stamp can be edited by userID  
 * @param  recID           Stamp ID    
 * @return                 Table of Client stamps    
 ***************************************************************************/     
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
   select 
          st.DESCRIPTION,
          st.STAMP_NAME, 
          c.CATEGORY_NAME,
          st.TYPE,
          st.ACTIVE,
          st.CATEGORY,         
          st.STAMP_ID as id
  from dbo.STAMPS_STAMP as st
  left join  dbo.STAMP_CATEGORIES          as c  on c.id = st.CATEGORY

  ) as sc
  where   ((@recID      is null) or (sc.id  = @recID)) and
          ((@type       is null) or (sc.type      = @type))  and
          ((@category   is null) or (sc.category  = @category)) and
          ((@active     is null) or (sc.active    = @active))

  order by sc.TYPE,sc.CATEGORY_NAME,sc.STAMP_NAME
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[STAMPS_VIEW] TO [webuser]
GO
