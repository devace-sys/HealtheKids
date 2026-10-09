USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.IS_TERM_IN_TAGS') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.IS_TERM_IN_TAGS
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

/***************************************************************************    
 * IS_TERM_IN_TAGS
/**/    
 * If any of the space seperated values in @term are found in the
 * space seperated values of @tags then 1 is returned.  Otherwise 0. 
 * Set @matchAll to 0 if you want to find matches that have ANY of the terms
 ***************************************************************************/   

CREATE FUNCTION [dbo].[IS_TERM_IN_TAGS] (
    @term      as varchar(max)    = ''
  , @tags      as varchar(max)    = '' 
  , @matchAll  as bit             = 1
)
RETURNS BIT                                    
AS    
BEGIN    
  
  declare @termParts as table (
      [value] varchar(256)      not null
	, [idx]   int identity(1,1) not null
	unique clustered ([value] asc,[idx]) 
  )
  
  declare @tagsParts as table (
      [value] varchar(256)      not null
	, [idx]   int identity(1,1) not null
	unique clustered ([value] asc, [idx])  
  )

  declare @numTermParts as int = 0
  declare @numMatches   as int = 0
  
  /* Remove any extra spaces from @term and @terms*/

  set @term  = dbo.STRING_REMOVE_EXTRA_SPACES(@term)
  set @tags  = dbo.STRING_REMOVE_EXTRA_SPACES(@tags)
  
  /* If any of the inputs are empty get out */

  if (len(@term) = 0)  return 0
  if (len(@tags) = 0) return 0

  /* Get terms */

  insert into @termParts(
    [value]
  )  
  select 
    [value] = convert(varchar(256),t1.[value]) 
  from string_split(@term, ' ' ) as t1
  order by 
    t1.[value] asc

  insert into @tagsParts(
    [value]
  ) 
  select 
    [value] = convert(varchar(256),t2.[value]) 
  from string_split(@tags, ' ' ) as t2
  order by 
    t2.[value] asc
  
  /* The incoming term(s) have to all match whats in tags */

  if (@matchAll = 1)
  begin
    
    select @numTermParts = count([value]) from @termParts
  
    select 
      @numMatches = count(t2.[value])
    from @termParts    as t1    
    join @tagsParts    as t2 on t2.[value] = t1.[value]	
    
    if (@numTermParts = @numMatches)
    begin
      return 1
    end
	else
    begin
      return 0  
	end
 end /* Match all */
 else
 begin
   if exists (
      select top 1 
	    1      
      from @termParts    as t1    
      join @tagsParts    as t2 on t2.[value] = t1.[value]	
   )
   begin
     return 1
   end
   else
   begin
     return 0
   end
end

return 0

END    

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[IS_TERM_IN_TAGS] TO [webuser]

GO