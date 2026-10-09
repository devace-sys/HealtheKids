USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON] (
  @prescribedOrderID bigint
)    

RETURNS @recs TABLE ([details] varchar(8000))
AS     
BEGIN
 
 /***************************************************************************    
  * SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON */    
 /**    
  * Returns list of recurring services records
  *
  * @return table 
  ***************************************************************************/                         
     

declare @hierarchyCreate as JSONHierarchyCreate
declare @hierachy        as JSONHierarchy

declare @trainingDetails as table (
      rowOrder     int
    , id           bigint
    , pracID       bigint
    , pracName     varchar(512)
    , pracTitle    varchar(512)
    , trainingDate varchar(100)
)

insert into @trainingDetails
select * from dbo.SvcJournal_View_Prescribed_Orders_Prac_Training_Details( @prescribedOrderID )

;with

detail

as
(
  select * from @trainingDetails
)
insert into @hierarchyCreate (parent_ID,Object_ID,NAME,StringValue,ValueType)

/* Detail object members */

          select rowOrder, null, 'pracID',        CONVERT(varchar(8000), pracID),        'string' from detail
union all select rowOrder, null, 'pracName',      CONVERT(varchar(8000), pracName),      'string' from detail
union all select rowOrder, null, 'pracTitle',     CONVERT(varchar(8000), pracTitle),     'string' from detail
union all select rowOrder, null, 'trainingDate',  CONVERT(varchar(8000), trainingDate),  'string' from detail

/* Detail object */

union all 
  select 
    (select count(*) from detail)+1, 
    ROW_NUMBER() OVER ( ORDER BY id),    
    NULL, 
    '',
    'object' 
  from detail

/* Array of detail objects */

union all 
  select 
    (select count(*) from detail)+2,
    (Select count(*) from detail)+1,
    'details_pracs_training',
    '', 
    'array'

/* Containing object */

union all 
  select 
    null,
    (Select count(*) from detail)+2,
    '',
    '', 
    'object'

INSERT INTO @hierachy  
  SELECT * from @hierarchyCreate
 
INSERT INTO @recs 
  SELECT dbo.ToJSON(@hierachy)

RETURN

END
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SvcJournal_View_Prescribed_Orders_Prac_Training_Details_JSON] TO [webuser]
GO   
