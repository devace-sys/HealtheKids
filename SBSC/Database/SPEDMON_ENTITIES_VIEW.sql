USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SPEDMON_ENTITIES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SPEDMON_ENTITIES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SPEDMON_ENTITIES_VIEW] (
    @whatEntity   as int
  , @top          as int
  , @active       as bit
  , @clientID     as bigint  
  , @term         as varchar(1000)
  , @name         as varchar(8000)
  , @value        as varchar(8000)
)    

RETURNS @recs TABLE (name varchar(max), value varchar(max), detail varchar(max), active bit, created datetime, modified datetime)
    
 /***************************************************************************    
  * SPEDMON_ENTITIES_VIEW */    
 /**    
  * Returns a list of entities
  * 
  * @param whatEntity 200 = Clients
  *                   300 = Sites
  *                   400 = Practitioner Groups - Discipline
  *                   425 = Practitioner Groups - Report
  *                   450 = Practitioner Groups - Super
  *                   475 = Practitioner Groups - Processing
  *                   485 = Practitioner Groups - Group Base
  *                   500 = Practitioners
  *                   600 = Patients
  *
  * @param clientID    Client ID to limit results to 
  * @param term        Search term
  * @param name
  * @param value
  ***************************************************************************/                             
AS

begin

declare @term1 as varchar(255) = null
declare @term2 as varchar(255) = null

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
 * Get and return records
 *============================================================*/

insert into @recs
select top (@top) *
from dbo.SPEDMON_ENTITIES_VIEW_CORE(  @whatEntity
                                    , @active            
                                    , @clientID
                                    , @term1
                                    , @term2
                                    , @name
                                    , @value) order by name option(recompile);

return
end

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SPEDMON_ENTITIES_VIEW] TO [webuser]
GO   
