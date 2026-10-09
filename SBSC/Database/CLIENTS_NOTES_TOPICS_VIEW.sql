USE SPEDMON
GO
 
/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CLIENTS_NOTES_TOPICS_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CLIENTS_NOTES_TOPICS_VIEW
GO
 
/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CLIENTS_NOTES_TOPICS_VIEW] (
    @userID                bigint
  , @userGroup             bigint    
  , @userRank              int     
  , @active                bit
  , @recID                 bigint  
  , @term                  varchar(256)  
)
    
returns table     
as
 
return 
(
    
  /* TODO: Refactor to use displayOrder technique that we use for cases where we need a prescribed order */

  with
  cte_p1
  as
  (

  select
      nt.*
    , nameInTbl = nt.name
    , nameToDisp = trim(nt.name) /* Remove leading space from result name*/
  from dbo.CLIENTS_Notes_Topics as nt
  where (
        (1=1)
    and ((@active is null) or (nt.active = @active))  /* Note: The predicate order is important */
    and ((@recID  is null) or (id        = @recID))
  )
  )
  select top (dbo.CONST_MAX_ROWS())
      p1.id
    , [name] = p1.nameToDisp
    , p1.created
    , p1.createdBy
    , p1.lastModfied
    , p1.lastModifedBy
    , p1.active
  from cte_p1 as p1
  where ( 
        (1=1)
    and ((@term is null) or (p1.nameToDisp like (trim(isnull(@term,'')) + '%'))) /* Note: At least one row has a leading space in the name to force a sort order. */
  )
  order by
    p1.nameInTbl  
)
 
GO
 
/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CLIENTS_NOTES_TOPICS_VIEW] TO [webuser]
GO