USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @rcrSvcID       BIGINT
)    

RETURNS @recs TABLE ([details] varchar(8000))
AS     
BEGIN
 
 /***************************************************************************    
  * RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON */    
 /**    
  * Returns list of recurring services records
  *
  * @return table 
  ***************************************************************************/                         
     

declare @hierarchyCreate as JSONHierarchyCreate
declare @hierachy        as JSONHierarchy

;with

detail

as
(
  select * from RECURRING_SERVICES_VIEW_DETAILS_PRAC(@userID, @userGroup, @userRank, @rcrSvcID)
)
insert into @hierarchyCreate (parent_ID,Object_ID,NAME,StringValue,ValueType)

/* Detail object members */

          select RowOrder,null, 'pracID',        CONVERT(varchar(8000), pracID),        'string' from detail
union all select RowOrder,null, 'pracName',      CONVERT(varchar(8000), pracName),      'string' from detail
union all select RowOrder,null, 'pracTitle',     CONVERT(varchar(8000), pracTitle),     'string' from detail
union all select RowOrder,null, 'pracDispGrpID', CONVERT(varchar(8000), pracDispGrpID), 'string' from detail
union all select RowOrder,null, 'tmtBS',         CONVERT(varchar(8000), tmtBS),         'string' from detail
union all select RowOrder,null, 'tmtDSInd',      CONVERT(varchar(8000), tmtDSInd),      'string' from detail
union all select RowOrder,null, 'tmtDSGrp',      CONVERT(varchar(8000), tmtDSGrp),      'string' from detail
union all select RowOrder,null, 'tmtAS',         CONVERT(varchar(8000), tmtAS),         'string' from detail
union all select RowOrder,null, 'transHmSs',     CONVERT(varchar(8000), transHmSs),     'string' from detail
union all select RowOrder,null, 'transSsHm',     CONVERT(varchar(8000), transSsHm),     'string' from detail
union all select RowOrder,null, 'transSsOs',     CONVERT(varchar(8000), transSsOs),     'string' from detail
union all select RowOrder,null, 'transOsSs',     CONVERT(varchar(8000), transOsSs),     'string' from detail
union all select RowOrder,null, 'realNames',     CONVERT(varchar(8000), realNames),     'string' from detail

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
    'details_pracs_all',
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
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON] TO [webuser]
GO   
