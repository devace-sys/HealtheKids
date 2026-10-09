use SPEDMON
go

/*-------------------------------
 * Exists drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_OBJECT_DATA') AND type IN (N'P', N'PC'))
DROP PROCEDURE dbo.GET_OBJECT_DATA
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE PROCEDURE dbo.GET_OBJECT_DATA
(
   @objectNameIn    as nvarchar(128)
  ,@objectIDIn      as int
  ,@standAloneHtml  as bit
  ,@cssLink         as varchar(1000)
  ,@htmlLinkOut     as varchar(1000) output
  ,@htmlOut         as varchar(max)  output
  ,@xmlOut          as xml           output
)

/***************************************************************************
 * GET_OBJECT_DATA */
/**
 * Generates HTML that describes the object
 * 
 * @param   objectNameIn    Name of object w/o dbo
 * @param   objectIDIn      Unique Object ID 
 * @param   standAloneHtml  0 = Output a section that can be placed with
 *                              other object data sections in a html doc
 *                          1 = output a section wrapped in its own html
 *                              doc
 * @param   cssLink         Link to external styleshet used to style the
 *                          object data section
 * @param   htmlLinkOut     Link for use in html doc
 * @param   htmlOut         HTML (text) out 
 * @param   xmlOut          XML object containing html document data
 ***************************************************************************/   
 
as
begin

set nocount on

declare @objectID          as int           = null
declare @objectName        as nvarchar(128) = null
declare @objectType        as varchar(50)   = null
declare @objectTypeDesc    as varchar(max)  = null
declare @xmlObj            as xml           = null
declare @htmlObj           as varchar(max)  = null

declare @clsSection        as varchar(50)   = 'db-obj-section'
declare @clsSubsection     as varchar(50)   = 'db-obj-sub-section'

declare @clsObject         as varchar(50)   = 'db-obj'
declare @clsParameterIn    as varchar(50)   = 'db-obj-parameter-in'
declare @clsParameterOut   as varchar(50)   = 'db-obj-parameter-out'
declare @clsColumn         as varchar(50)   = 'db-obj-column'
declare @clsDependedOn     as varchar(50)   = 'db-obj-depended-on-by'
declare @clsDependsOn      as varchar(50)   = 'db-obj-depends-on'

declare @ctrObject         as int           = 0
declare @ctrParameterIn    as int           = 0
declare @ctrParameterOut   as int           = 0
declare @ctrColumn         as int           = 0
declare @ctrDependedOn     as int           = 0
declare @ctrDependsOn      as int           = 0

declare @objectData as table
(
    [data_idx]         int identity(1,1) primary key
  , [object-class]     varchar(50)
  , [object_id]        int
  , [object_name]      nvarchar(128)
  , [object_type]      varchar(50)
  , [object_type_desc] varchar(max)
  , [object_length]    int null
)

/*============================================================
 * Retrieve data about the object itself and put the most
 * important values in variables we will use later
 *============================================================*/

insert into @objectData ([object-class],[object_id],[object_name],[object_type],[object_type_desc],[object_length])
select 
    [object-class] = @clsObject
  , [object_id] as [object_id]
  , [name]      as [object_name]
  , [type]      as [object_type]
  , [type_desc] as [object_type_desc]
  , null        as [object_length]
from sys.objects 
where 
      (1=1)
  and ((@objectIDIn is null)   or (object_id = @objectIDIn))
  and ((@objectNameIn is null) or (name = @objectNameIn))

select top 1 
    @objectID       = [object_id]
  , @objectName     = [object_name]
  , @objectType     = [object_type]
  , @objectTypeDesc = [object_type_desc]
from @objectData

/*============================================================
 * If there is no object data, get out
 *============================================================*/

if (@objectID is null) return(1)

/*============================================================
 * Retrieve data about the objects input parameters
 * and store them in order of declaration
 *============================================================*/

insert into @objectData ([object-class],[object_id],[object_name],[object_type],[object_type_desc],[object_length])
select 
    [object-class] = @clsParameterIn 
  , p.parameter_id    as [object_id]
  , p.name            as [object_name]
  , t.system_type_id  as [object_type]
  , t.name            as [object_type_desc]
  , p.max_length      as [object_length]
from sys.parameters as p
join sys.types      as t on t.system_type_id = p.system_type_id
where 
  p.object_id = @objectID and p.is_output = 0
order by p.parameter_id

/*============================================================
 * Retrieve data about the objects output parameters and store
 * them in order of declaration
 *============================================================*/

insert into @objectData ([object-class],[object_id],[object_name],[object_type],[object_type_desc],[object_length])
select 
    [object-class] = @clsParameterOut
  , p.parameter_id    as [object_id]
  , p.name            as [object_name]
  , t.system_type_id  as [object_type]
  , t.name            as [object_type_desc]
  , p.max_length      as [object_length]
from sys.parameters as p
join sys.types      as t on t.system_type_id = p.system_type_id
where 
  p.object_id = @objectID and p.is_output = 1
order by p.parameter_id

/*============================================================
 * Retrieve data about the objects columns and store them
 * in order of declaration
 *============================================================*/

insert into @objectData ([object-class],[object_id],[object_name],[object_type],[object_type_desc],[object_length])
select 
    [object-class] = @clsColumn
  , c.column_id       as [object_id]
  , c.name            as [object_name]
  , t.system_type_id  as [object_type]
  , t.name            as [object_type_desc]
  , c.max_length      as [object_length]
from sys.columns    as c
join sys.types      as t on t.system_type_id = c.system_type_id
where 
  c.object_id = @objectID
order by c.column_id

/*============================================================
 * Retrieve data about what objects call this object
 *============================================================*/

insert into @objectData ([object-class],[object_id],[object_name],[object_type],[object_type_desc],[object_length])
select 
    [object-class] = @clsDependedOn
  , sobj.object_id    as [object_id]
  , sobj.name         as [object_name]
  , sobj.type         as [object_type]
  , sobj.type_desc    as [object_type_desc]
  , null              as [object_length]
from sys.sql_expression_dependencies as sed 
join sys.objects as sobj on sobj.object_id = sed.referencing_id
where sed.referenced_id = @objectID or sed.referenced_entity_name = @objectName
order by sobj.name

/*============================================================
 * Retrieve data about what objects this object calls
 *============================================================*/

insert into @objectData ([object-class],[object_id],[object_name],[object_type],[object_type_desc],[object_length])
select 
    [object-class] = @clsDependsOn
  , sobj.object_id    as [object_id]
  , sobj.name         as [object_name]
  , sobj.type         as [object_type]
  , sobj.type_desc    as [object_type_desc]
  , null              as [object_length]
from sys.sql_expression_dependencies as sed 
join sys.objects as sobj on sobj.object_id = sed.referenced_id
where sed.referencing_id = @objectID
order by sobj.name

/*============================================================
 * Populate counters
 *============================================================*/
 
select @ctrParameterIn  = COUNT([object_id]) from @objectData where [object-class] = @clsParameterIn
select @ctrParameterOut = COUNT([object_id]) from @objectData where [object-class] = @clsParameterOut
select @ctrColumn       = COUNT([object_id]) from @objectData where [object-class] = @clsColumn
select @ctrDependedOn   = COUNT([object_id]) from @objectData where [object-class] = @clsDependedOn
select @ctrDependsOn    = COUNT([object_id]) from @objectData where [object-class] = @clsDependsOn

/*============================================================
 * Create HTML (using XML)
 *============================================================*/
      
select @xmlObj = (select   
@objectID       as "@id"
,
@clsSection     as "@class"
,      
(select @objectName as 'h2' for xml path(''),type)
,
(select
  @clsSubSection + ' ' + @clsObject as '@class'      
  ,
  @objectTypeDesc  as 'h3'  
  ,(select
   
    (select 'Parameters In '  , @ctrParameterIn  as 'span' for xml path ('li'), type)
   ,(select 'Parameters Out ' , @ctrParameterOut as 'span' for xml path ('li'), type)
   ,(select 'Columns '        , @ctrColumn       as 'span' for xml path ('li'), type)
   ,(select 'Depends On '     , @ctrDependsOn    as 'span' for xml path ('li'), type)
   ,(select 'Depends On '     , @ctrDependedOn   as 'span' for xml path ('li'), type)
  for xml path ('ul'), type)
for xml path ('div'), type)
,  
(select
  @clsSubSection + ' ' + @clsParameterIn as '@class'    
 ,(select 'Parameters In' as 'h3' for xml path(''),type)    
 ,(select        
     (select                
       (select 
         (select 'Name'    as 'th' for xml path(''), type)
        ,(select 'Type'    as 'th' for xml path(''), type)
        ,(select 'Length'  as 'th' for xml path(''), type)
       for xml path('tr'), type )         
     for xml path ('thead'), type)           
    ,(select     
       (select    
         (select od.[object_name]      as 'td' for xml path(''),type)
        ,(select od.[object_type_desc] as 'td' for xml path(''),type)
        ,(select od.[object_length]    as 'td' for xml path(''),type)
       from @objectData od
       where od.[object-class] = @clsParameterIn      
       for xml path('tr'), type)
     for xml path ('tbody'),type)
   for xml path('table'), type) 
where @ctrParameterIn > 0
for xml path ('div'), type)
,
(select
  @clsSubSection + ' ' + @clsParameterOut as '@class'    
 ,(select 'Parameters Out' as 'h3' for xml path(''),type)    
 ,(select        
     (select                
       (select 
         (select 'Name'    as 'th' for xml path(''), type)
        ,(select 'Type'    as 'th' for xml path(''), type)
        ,(select 'Length'  as 'th' for xml path(''), type)
       for xml path('tr'), type )         
     for xml path ('thead'), type)           
    ,(select     
       (select    
         (select od.[object_name]      as 'td' for xml path(''),type)
        ,(select od.[object_type_desc] as 'td' for xml path(''),type)
        ,(select od.[object_length]    as 'td' for xml path(''),type)
       from @objectData od
       where od.[object-class] = @clsParameterOut      
       for xml path('tr'), type)
     for xml path ('tbody'),type)
   for xml path('table'), type) 
where @ctrParameterOut > 0
for xml path ('div'), type)
,
(select
  @clsSubSection + ' ' + @clsColumn as '@class'    
 ,(select 'Columns' as 'h3' for xml path(''),type)    
 ,(select        
     (select                
       (select 
         (select 'Name'    as 'th' for xml path(''), type)
        ,(select 'Type'    as 'th' for xml path(''), type)
        ,(select 'Length'  as 'th' for xml path(''), type)
       for xml path('tr'), type )         
     for xml path ('thead'), type)           
    ,(select     
       (select    
         (select od.[object_name]      as 'td' for xml path(''),type)
        ,(select od.[object_type_desc] as 'td' for xml path(''),type)
        ,(select od.[object_length]    as 'td' for xml path(''),type)
       from @objectData od
       where od.[object-class] = @clsColumn
       for xml path('tr'), type)
     for xml path ('tbody'),type)
   for xml path('table'), type) 
where @ctrColumn > 0
for xml path ('div'), type)
,
(select
  @clsSubSection + ' ' + @clsDependsOn as '@class'    
 ,(select 'Depends On' as 'h3' for xml path(''),type)    
 ,(select        
     (select                
       (select 
         (select 'Name'    as 'th' for xml path(''), type)
        ,(select 'Type'    as 'th' for xml path(''), type)
       for xml path('tr'), type )         
     for xml path ('thead'), type)           
    ,(select     
       (select    
         (select od.[object_name]      as 'td' for xml path(''),type)
        ,(select od.[object_type_desc] as 'td' for xml path(''),type)
       from @objectData od
       where od.[object-class] = @clsDependsOn
       for xml path('tr'), type)
     for xml path ('tbody'),type)
   for xml path('table'), type) 
where @ctrDependsOn > 0
for xml path ('div'), type)
,
(select
  @clsSubSection + ' ' + @clsDependedOn as '@class'    
 ,(select 'Depended On' as 'h3' for xml path(''),type)    
 ,(select        
     (select                
       (select 
         (select 'Name'    as 'th' for xml path(''), type)
        ,(select 'Type'    as 'th' for xml path(''), type)
       for xml path('tr'), type )         
     for xml path ('thead'), type)           
    ,(select     
       (select    
         (select od.[object_name]      as 'td' for xml path(''),type)
        ,(select od.[object_type_desc] as 'td' for xml path(''),type)
       from @objectData od
       where od.[object-class] = @clsDependedOn
       for xml path('tr'), type)
     for xml path ('tbody'),type)
   for xml path('table'), type) 
where @ctrDependedOn > 0
for xml path ('div'), type)

for xml path('div'), type)

set @xmlOut        = @xmlObj
set @htmlObj       = convert(varchar(max),@xmlObj)
set @htmlLinkOut   = '<a href="#' + convert(varchar(50),@objectID) + '">' + @objectName + '</a>'

if (@standAloneHtml = 1)
begin
  set @htmlOut = '<!DOCTYPE html>'
                 + '<html>'
                 + '<head>'
                 + '<title>' + @objectName  + '</title>'
                 + '<meta name="viewport" content="width=device-width, initial-scale=1"/>'
                 + '<link rel="stylesheet" href="' + @cssLink + '" />'
                 + '</head>'
                 + '<body>' 
                 + @htmlObj 
                 + '</body>'
                 + '</html>'
end
else
begin
  set @htmlOut = @htmlObj
end
                
return(0)
end
