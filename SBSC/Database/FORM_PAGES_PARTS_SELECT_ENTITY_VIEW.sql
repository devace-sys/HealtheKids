USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FORM_PAGES_PARTS_SELECT_ENTITY_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FORM_PAGES_PARTS_SELECT_ENTITY_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[FORM_PAGES_PARTS_SELECT_ENTITY_VIEW] (
    @userID                 as bigint
  , @userGroup              as int
  , @userRank               as int
  , @selectFrom             as int
  , @selectWhat             as int
  , @top                    as int
  , @active                 as bit
  , @reqEntityVal1          as varchar(8000)
  , @reqEntityVal2          as varchar(8000)
  , @term                   as varchar(1000)
  , @name                   as varchar(8000)
  , @value                  as varchar(8000)
)    
RETURNS @recs TABLE (name varchar(max)
                     , value varchar(max)
                     , detail varchar(max)
                     , active bit
                     , created datetime
                     , modified datetime)

 /***************************************************************************    
  * FORM_PAGES_PARTS_SELECT_ENTITY_VIEW */    
 /**    
  * Returns a list of entities
  * 
  * @parm    selectFrom     Select from
  * @parm    selectWhat     What to return
  * @parm    top
  * @parm    active      
  * @param   reqEntityVal1  Use based on @whatEntity.  Used for optional filtering
  * @param   reqEntityVal2  Use based on @whatEntity.  Used for optional filtering
  * @parm    term           Search term
  * @parm    name           Literal name
  * @parm    value          Literal unique value
  ***************************************************************************/                             
AS
begin


/*============================================================
 * Identify what this is
 *============================================================*/

declare @selectSearchFromWhatID as bigint       = null
declare @replaceValue           as bit          = null

declare @replaceWhoName         as varchar(max)
declare @replaceWhoValue        as varchar(max)
declare @replaceWithValue       as varchar(max)

select 
    @selectSearchFromWhatID = id
  , @replaceValue     = replaceValue
  , @replaceWhoName   = replaceWhoName
  , @replaceWhoValue  = replaceWhoValue
  , @replaceWithValue = replaceWithValue
from
dbo.FORM_PAGE_PART_SELECT_SEARCH_FROM_WHAT
where ((selectFrom = @selectFrom) and (selectWhat = @selectWhat))

/*============================================================
 * If not found, exit
 *============================================================*/

if (@selectSearchFromWhatID is null) return

/*============================================================
 * If replacement required TODO:Implement
 *============================================================*/
 
declare @term1    as varchar(255) = null
declare @term2    as varchar(255) = null

/*============================================================
 * Parse search term into parts
 *============================================================*/
 
if (@term is not null)
begin
  set @term1 = dbo.PARSE_SEARCH_TERM(@term,',',1)
  set @term2 = dbo.PARSE_SEARCH_TERM(@term,',',2)  
end

/*============================================================
 * Check active value
 *============================================================*/

if (@active is null) set @active = 1

/*============================================================
 * Check top value
 *============================================================*/

if (@top is not null) 
begin  
  if      (@top <= 0)                   set @top = dbo.CONST_MAX_ROWS()
  else if (@top > dbo.CONST_MAX_ROWS()) set @top = dbo.CONST_MAX_ROWS()
  
end
else if (@top is null)
begin
  set @top = dbo.CONST_MAX_ROWS() 
end

/*============================================================
 * If value is specified, set top to 1
 *============================================================*/

if (@value is not null)
begin
  set @top = 1
end

/*============================================================
 * Get and return records from various existing entities
 *============================================================*/

if (@selectFrom = 10)
begin

  insert into @recs
  select top (@top) 
    name
  , value
  , detail 
  , active
  , created
  , modified
  from dbo.FORM_PAGES_PARTS_SELECT_ENTITY_VIEW_CORE(@selectWhat
                                      , @active            
                                      , @reqEntityVal1
                                      , @reqEntityVal2
                                      , @term1
                                      , @term2
                                      , @name
                                      , @value) 
  order by name option(recompile);

end

/*============================================================
 * Get and return records from generic answer table
 *============================================================*/
 
else if (@selectFrom = 20)
begin

  insert into @recs
  select top (@top)
      name
    , value
    , '' as detail
    , active
    , null as created
    , null as modified
  from dbo.FORM_PAGE_PART_SELECT_SEARCH_NAME_VALUES
  where 
    ((selectFrom = 20) and (selectWhat = @selectWhat) and ((@term1 is null) or (name like @term1)))
  order by displayOrder
  option(recompile);
end
else
begin
   return
end

return

end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[FORM_PAGES_PARTS_SELECT_ENTITY_VIEW] TO [webuser]
GO   
