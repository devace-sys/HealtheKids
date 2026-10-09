use SPEDMON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].TRANSMISSION_GENERATION_CREATE') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop PROCEDURE dbo.TRANSMISSION_GENERATION_CREATE
GO

CREATE PROCEDURE dbo.TRANSMISSION_GENERATION_CREATE (
   @clientID           as bigint
 , @patientID          as bigint
 , @claimID            as bigint
 , @oldestDOS          as date
 , @newestDOS          as date
 , @oldestEntry        as date
 , @newestEntry        as date
 , @claimSource        as bigint
 , @claimSubSource     as bigint
 , @generationID       as bigint OUTPUT
)
AS
BEGIN

set nocount on

declare @generationDate as datetime = getdate()

/* Create the generation record */

insert into dbo.[TRANSMISSION_GENERATIONS] (
    dateCreated
  , clientID
  , patientID
  , claimID
  , oldestDOS
  , newestDOS
  , oldestEntry
  , newestEntry
  , claimSource
  , claimSubSource
) 
values(
    @generationDate
  , @clientID
  , @patientID
  , @claimID
  , @oldestDOS
  , @newestDOS
  , @oldestEntry
  , @newestEntry
  , @claimSource
  , @claimSubSource
)

set @generationID = SCOPE_IDENTITY()

END

GO