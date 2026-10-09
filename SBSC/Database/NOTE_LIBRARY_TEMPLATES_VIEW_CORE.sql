USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.NOTE_LIBRARY_TEMPLATES_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.NOTE_LIBRARY_TEMPLATES_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[NOTE_LIBRARY_TEMPLATES_VIEW_CORE] (
    @userID        as bigint    
  , @userGroup     as int  
  , @userRank      as int
  , @noteOwner     as bigint
  , @noteNamespace as varchar(500)
  , @noteSource    as varchar(500)
  , @clientID      as bigint
  , @pracID        as bigint
  , @patID         as bigint
  , @referenceDate as date
  , @term          as varchar(50)
  , @active        as bit
  , @recID         as bigint
)    

RETURNS TABLE
 
 /***************************************************************************    
  * NOTE_LIBRARY_TEMPLATES_VIEW_CORE */    
 /**    
  * Returns 
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  with
  cte_prescribed_orders  
  as
  (  
    select 
        id
      , [name]  = noteTemplateTitle
      , [notes] = noteTemplateText
    from dbo.SVCJOURNAL_JOURNAL_PRESCRIBED_ORDERS_VIEW (@userID,@userGroup,@userRank,@clientID, @pracID, null, @patID,@referenceDate,null,null,null,null,1)
    where ( 
           (1=1)
      and ((@term is null) or (noteTemplateTitle like ((@term + '%'))))
    )
  )
  ,
  cte_combined
  as
  (
    select * from cte_prescribed_orders
  )
  
  select top(dbo.CONST_MAX_ROWS())
    * 
  from cte_combined  
  order by 
    name
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[NOTE_LIBRARY_TEMPLATES_VIEW_CORE] TO [webuser]
GO  
