USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.GET_SERVICE_NAME_ID_REPLACEMENT_FOR_GROUP_CHANGE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GET_SERVICE_NAME_ID_REPLACEMENT_FOR_GROUP_CHANGE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[GET_SERVICE_NAME_ID_REPLACEMENT_FOR_GROUP_CHANGE] (
   @clientID        as bigint
 , @planType        as int     
 , @dos             as datetime
 , @svcType         as int
 , @svcSubType1     as int
 , @viaTelehealth   as bit
 , @previousGroupID as bigint
 , @previousNameID  as bigint
 , @newGroupID      as bigint

) 
RETURNS bigint
as 
begin
  
  /*
   * Since we have different nameIDs for the exact same text for a service selection for different groups in the same family, we cannot
   * rely on the nameID to be the same.  So we have to use the text of the service selection. 
  */

  declare @previousName as nvarchar(100)
  declare @newName      as nvarchar(100)
  declare @nameIDOut    as bigint = null

  select top 1  
     @previousName = trim(isnull(sva.SERVICE_NAME_STANDARD,N''))
  from dbo.SERVICES_VIEW_ALL_CORE (  
      @clientID
    , @previousGroupID
    , @planType         /* Plan type */
    , @svcType          /* Service type */
    , @previousNameID   /* Service name id */
    , 1                 /* In allowed procs */
    , 1                 /* Active procs only */
    , @dos              /* Effective for given DOS*/
    , 1                 /* Selection only*/
  ) as sva
  where (
        (1=1)
    and ((@viaTelehealth is null) or (sva.SERVICE_IS_VIA_TELEHEALTH = @viaTelehealth))
	and ((@svcSubType1   is null) or (sva.SERVICE_SUB_TYPE_1_ID     = @svcSubType1))
  )
  
  if (@previousName = N'') return null

  select top 1  
     @newName   = trim(isnull(sva.SERVICE_NAME_STANDARD,N''))
   , @nameIDOut = sva.SERVICE_NAME_ID
  
  from dbo.SERVICES_VIEW_ALL_CORE (  
      @clientID
    , @newGroupID
    , @planType         /* Plan type */
    , @svcType          /* Service type */
    , null
    , 1                 /* In allowed procs */
    , 1                 /* Active procs only */
    , @dos              /* Effective for given DOS*/
    , 1                 /* Selection only*/
  ) as sva
  where ( 
        (sva.SERVICE_NAME_STANDARD = @previousName)
    and ((@viaTelehealth is null)  or (sva.SERVICE_IS_VIA_TELEHEALTH = @viaTelehealth))
	and ((@svcSubType1   is null)  or (sva.SERVICE_SUB_TYPE_1_ID     = @svcSubType1))
  )
   
  if (@newName = N'') return null
  if (@previousName != @newName) return null
  
  return @nameIDOut
  
end    
go
