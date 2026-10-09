USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.TRANSMISSION_RECORD_ROLLBACK') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.TRANSMISSION_RECORD_ROLLBACK
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE PROCEDURE [dbo].[TRANSMISSION_RECORD_ROLLBACK] (
    @userID             BIGINT
  , @transmissionID     BIGINT
  , @reasonCode         BIGINT  
  , @notes              VARCHAR(MAX)
  , @test               BIT
  , @backfillMode       BIT )    
AS    
BEGIN     
    
/***************************************************************************    
 * TRANSMISSION_RECORD_ROLLBACK */    
/**    
 * Rolls back a transmission
 *    
 * @param   userID          The userid (bigint) of who is doing this
 * @param   transmissonID   Tranmission to rollback
 * @param   reasonCode      The reason for the rollback
 * @param   notes           Additional notes
 * @param   test            1 = Test only
 *                          0 = Do it
 * @param   @backfillMode   0 = No
 *                          1 = Yes.  Do not update claim or service records
 ***************************************************************************/         
     
SET NOCOUNT ON    
    
declare @txID                     as bigint = null
declare @claimSource              as bigint = null


/*###########################################################################
  # Find transmission
  ###########################################################################*/    

set @txID = null

select top 1
    @txID         = tra.Transmission_ID
  , @claimSource = isnull(tga.claimSource,1) /* Default to 1 */
  
from      dbo.TRANSMISSION_RECORDS_ALL       as tra
left join dbo.TRANSMISSION_GENERATIONS_ALL   as tga on tga.id = tra.generationID
where (tra.Transmission_ID = @transmissionID)

/*###########################################################################
  # If its not found then get out
  ###########################################################################*/    

if (@txID is null)
begin
  RAISERROR ('Transmission record does not exist', 0, 1) WITH NOWAIT 
  RETURN(0)
end

/*###########################################################################
  # Route request to appropriate rollback routine
  ###########################################################################*/    

if (@claimSource = 1)
begin
  RAISERROR ('New claims source - Current Claims', 0, 1) WITH NOWAIT 
  exec dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES @userID, @transmissionID, @reasonCode, @notes, @test, 0
  RETURN(0)
end

else if (@claimSource = 2)
begin
  RAISERROR ('New claims source - Retroactive Claims', 0, 1) WITH NOWAIT 
  exec dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES @userID, @transmissionID, @reasonCode, @notes, @test, 0
  RETURN(0)
end

else if (@claimSource = 3)
begin
  RAISERROR ('CIF source - Void Claims', 0, 1) WITH NOWAIT 
  exec dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_CIF_CLAIM_SOURCES @userID, @transmissionID, @reasonCode, @notes, @test, 0
  RETURN(0)
end
else 
begin
  RAISERROR ('New claims source - Current Claims', 0, 1) WITH NOWAIT 
  exec dbo.TRANSMISSION_RECORD_ROLLBACK_FOR_NEW_CLAIM_SOURCES @userID, @transmissionID, @reasonCode, @notes, @test, 0
  RETURN(0)
end

END    
    
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT EXECUTE ON  [dbo].[TRANSMISSION_RECORD_ROLLBACK] TO [webuser]
GO
