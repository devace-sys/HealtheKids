USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GROUPS_SERVICE_CLASS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GROUPS_SERVICE_CLASS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[GROUPS_SERVICE_CLASS_VIEW_CORE] (
    @userID     bigint   
  , @userGroup  int  
  , @userRank   int    
  , @source     int
  , @term       varchar(255)
)
 
/***************************************************************************    
 * GROUPS_SERVICE_CLASS_VIEW_CORE */    
/**    
 * Retrieve service class data from the given parameters
 *
 * @param   source    Partition id * @param   term      Search term * * @returns Table of service class data *
 ***************************************************************************/ 
      
returns @recs table (
    ID varchar(512)
  , Name varchar(1000)
  , Context1 varchar(8000)
  , GROUP_SERVICE_CLASS_PARTITION_ID bigint
  , GROUP_SERVICE_CLASS_PARTITION_NAME varchar(1000)
  , GROUP_SERVICE_CLASS_NAME_ID bigint
  , GROUP_SERVICE_CLASS_NAME  varchar(1000)
  
  UNIQUE CLUSTERED (
    GROUP_SERVICE_CLASS_NAME_ID
  )
)
AS     
BEGIN
    
/*============================================================
 * Immediately exit if required parms are not provided
 *============================================================*/ 

if (@source   IS NULL) return

/*============================================================
 * Table variable to hold working results
 *============================================================*/ 

declare @service_class_part_names_groups as table (
    ID varchar(512)
  , Name varchar(1000)
  , GROUP_SERVICE_CLASS_PARTITION_ID bigint
  , GROUP_SERVICE_CLASS_PARTITION_NAME varchar(1000)
  , GROUP_SERVICE_CLASS_NAME_ID bigint
  , GROUP_SERVICE_CLASS_NAME  varchar(1000)
  , GROUP_ID bigint
  , GROUP_NAME varchar(1000)
  , GROUP_NAME_ABBREVIATION varchar(1000)
)

/*============================================================
 * Get working results
 *============================================================*/ 

insert into @service_class_part_names_groups

select 
  
   ID    = convert(varchar(256),GROUP_SERVICE_CLASS_PARTITION_ID) 
         + '-' 
         + convert(varchar(256),GROUP_SERVICE_CLASS_NAME_ID)
         
  , Name = GROUP_SERVICE_CLASS_NAME

  , GROUP_SERVICE_CLASS_PARTITION_ID
  , GROUP_SERVICE_CLASS_PARTITION_NAME
  , GROUP_SERVICE_CLASS_NAME_ID
  , GROUP_SERVICE_CLASS_NAME
  , GROUP_ID
  , GROUP_NAME
  , GROUP_NAME_ABBREVIATION

from GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS_DATA

where (
  (GROUP_SERVICE_CLASS_PARTITION_ID = @source)
)

/*============================================================
 * Return results with context detail filtered by term
 *============================================================*/ 

insert into @recs

select distinct
    ID
  , Name
  , t4.Context1
  , GROUP_SERVICE_CLASS_PARTITION_ID
  , GROUP_SERVICE_CLASS_PARTITION_NAME
  , GROUP_SERVICE_CLASS_NAME_ID
  , GROUP_SERVICE_CLASS_NAME

from @service_class_part_names_groups as t1

cross apply (
  select [Context1] = STUFF (
    (
    select 
      N',' + t3.GROUP_NAME_ABBREVIATION
    from (
      select distinct GROUP_NAME_ABBREVIATION 
      from @service_class_part_names_groups 
      where (GROUP_SERVICE_CLASS_NAME_ID = t1.GROUP_SERVICE_CLASS_NAME_ID)        
     ) as t3 
     FOR XML PATH(''),TYPE).value('text()[1]','nvarchar(max)'),1,1,N'')

) as t4

where (
      (1=1)
  and ((@term is null) or (Name like isnull(@term,'') + '%'))
)

RETURN

END
GO




