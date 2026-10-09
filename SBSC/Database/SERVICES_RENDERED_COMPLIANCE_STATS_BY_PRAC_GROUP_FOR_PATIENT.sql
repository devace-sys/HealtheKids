USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT] (
     @userID                      bigint    
   , @userGroup                   int    
   , @userRank                    int 
   , @clientID                    bigint
   , @patID                       bigint
   , @startDate                   datetime
   , @endDate                     datetime
   , @pracGroupServiceClassNameID bigint
   , @pracID                      bigint
)

returns @recs table (
    CLIENT_ID       bigint
  , PATIENT_ID      bigint
  , GENERAL_SERVICE_PLAN_GROUP_NAME varchar(500)
  , FROM_DATE date
  , TO_DATE date
  , NUM_PRACS int
  , MIN_DOS date
  , MAX_DOS date
  , NUM_SVCS_PRESENT int
  , TOT_MINS_PRESENT int
  , NUM_SVCS_ABSENT int
  , TOT_MINS_ABSENT int
  
  
)
as
begin

declare @lookupMulti              as bit = 0
declare @lookupServiceClassNameID as bit = 0

if ((@pracGroupServiceClassNameID is null) and (@pracID is null))
begin
  set @lookupMulti              = 1
  set @lookupServiceClassNameID = 0
end

if ((@pracGroupServiceClassNameID is null) and (@pracID is not null))
begin
  set @lookupMulti              = 0
  set @lookupServiceClassNameID = 1
end

if ((@pracGroupServiceClassNameID is not null) and (@pracID is null))
begin
  set @lookupMulti              = 0
  set @lookupServiceClassNameID = 0  
end

if ((@pracGroupServiceClassNameID is not null) and (@pracID is not null))
begin
  set @lookupMulti              = 0
  set @lookupServiceClassNameID = 1
end

if (@lookupServiceClassNameId = 1)
begin

  set @pracGroupServiceClassNameID = null
  
  select top 1 

    @pracGroupServiceClassNameID = sd.GROUP_SERVICE_CLASS_NAME_ID

  from dbo.PRACTITIONER_GROUPS                          as pg 
  join dbo.GROUP_Group                                  as gg on gg.GROUP_ID = pg.GROUP_ID
  join dbo.CLAIM_PROCEDURES_GROUPS_SERVICE_CLASS_DATA() as sd on sd.GROUP_ID = gg.GROUP_ID
  where ( 
        (pg.PRACTITIONER_ID = @pracID)
    and (pg.GROUP_TYPE in (1,2))
    and (sd.GROUP_SERVICE_CLASS_PARTITION_ID = 1)
  )
end

if (@lookupMulti = 1)
begin

  insert into @recs  
  select distinct     
    sr.*    
  from dbo.GROUP_GROUP_SERVICE_CLASS_PARTITIONS_NAMES_GROUPS as scpng
  cross apply (  
    select 
        CLIENT_ID
      , PATIENT_ID
      , GENERAL_SERVICE_PLAN_GROUP_NAME 
      , FROM_DATE 
      , TO_DATE 
      , NUM_PRACS 
      , MIN_DOS 
      , MAX_DOS 
      , NUM_SVCS_PRESENT
      , TOT_MINS_PRESENT
      , NUM_SVCS_ABSENT 
      , TOT_MINS_ABSENT 
    from dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE (
       @userID
     , @userGroup
     , @userRank
     , @clientID
     , @patID
     , @startDate
     , @endDate
     , scpng.GROUP_SERVICE_CLASS_NAME_ID
    )
  ) as sr
  where (scpng.GROUP_SERVICE_CLASS_PARTITION_ID = 1)

end
else
begin

  insert into @recs  
  select
       CLIENT_ID
      , PATIENT_ID
      , GENERAL_SERVICE_PLAN_GROUP_NAME 
      , FROM_DATE 
      , TO_DATE 
      , NUM_PRACS 
      , MIN_DOS 
      , MAX_DOS 
      , NUM_SVCS_PRESENT
      , TOT_MINS_PRESENT
      , NUM_SVCS_ABSENT 
      , TOT_MINS_ABSENT 

  from dbo.SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT_CORE (
       @userID
     , @userGroup
     , @userRank
     , @clientID
     , @patID
     , @startDate
     , @endDate
     , @pracGroupServiceClassNameID
  )

end

return

end
go

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[SERVICES_RENDERED_COMPLIANCE_STATS_BY_PRAC_GROUP_FOR_PATIENT] TO [webuser]
GO
