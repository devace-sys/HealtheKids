USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,
 @rcrSvcID       BIGINT,
 @tmtWhen        INT,
 @tmtHow         INT,
 @objName        VARCHAR(100)
)    

RETURNS @recs TABLE ([details] varchar(8000))
AS     
BEGIN
 
 /***************************************************************************    
  * RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON */    
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
  select * from RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED (@userID, @userGroup, @userRank, @rcrSvcID, @tmtWhen, @tmtHow)
)
insert into @hierarchyCreate (parent_ID,Object_ID,NAME,StringValue,ValueType)

/* Detail object members */

          select RowOrder,null, 'pracID',        CONVERT(varchar(8000), pracID),        'string' from detail
union all select RowOrder,null, 'pracName',      CONVERT(varchar(8000), pracName),      'string' from detail
union all select RowOrder,null, 'pracTitle',     CONVERT(varchar(8000), pracTitle),     'string' from detail
union all select RowOrder,null, 'pracDispGrpID', CONVERT(varchar(8000), pracDispGrpID), 'string' from detail

union all select RowOrder,null, 'inIEP',         CONVERT(varchar(8000), inIEP),         'string' from detail
union all select RowOrder,null, 'isMedNesc',     CONVERT(varchar(8000), isMedNesc),     'string' from detail

union all select RowOrder,null, 'scheduleDaily', CONVERT(varchar(8000), scheduleDaily), 'string' from detail
union all select RowOrder,null, 'scheduleMon',   CONVERT(varchar(8000), scheduleMon),   'string' from detail
union all select RowOrder,null, 'scheduleTue',   CONVERT(varchar(8000), scheduleTue),   'string' from detail
union all select RowOrder,null, 'scheduleWed',   CONVERT(varchar(8000), scheduleWed),   'string' from detail
union all select RowOrder,null, 'scheduleThu',   CONVERT(varchar(8000), scheduleThu),   'string' from detail
union all select RowOrder,null, 'scheduleFri',   CONVERT(varchar(8000), scheduleFri),   'string' from detail

union all select RowOrder,null, 'numMinsDaily',  CONVERT(varchar(8000), numMinsDaily),  'string' from detail
union all select RowOrder,null, 'numMinsMon',    CONVERT(varchar(8000), numMinsMon),    'string' from detail
union all select RowOrder,null, 'numMinsTue',    CONVERT(varchar(8000), numMinsTue),    'string' from detail
union all select RowOrder,null, 'numMinsWed',    CONVERT(varchar(8000), numMinsWed),    'string' from detail
union all select RowOrder,null, 'numMinsThu',    CONVERT(varchar(8000), numMinsThu),    'string' from detail
union all select RowOrder,null, 'numMinsFri',    CONVERT(varchar(8000), numMinsFri),    'string' from detail

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
    @objName,
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
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON] TO [webuser]
GO   
