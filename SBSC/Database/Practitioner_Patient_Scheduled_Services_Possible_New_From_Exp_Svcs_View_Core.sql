USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core] (
    @clientID      bigint
  , @pracID        bigint
  , @ppcesDataJSON varchar(max)
)    

returns @recs table (
    clonedFromID                                 bigint
  , clonedStartDate                              date
  , clonedEndDate                                date
 
  , patID                                        bigint
  , svcNamesListDataSourceID                     int
  , viaTeleHealth                                bit
  , nameID                                       bigint  
  , recurring                                    bit
  , practitionerPatientCaseloadExpectedServiceID bigint
  , startDate                                    date
  , endDate                                      date  
  , startTime                                    time(0)
  , numMins                                      int
  , mon                                          bit
  , monStartTime                                 time(0)
  , tue                                          bit
  , tueStartTime                                 time(0)
  , wed                                          bit
  , wedStartTime                                 time(0)
  , thu                                          bit
  , thuStartTime                                 time(0)
  , fri                                          bit
  , friStartTime                                 time(0)
  , possibleDup                                  bit default(0)
  , possibleDupRecordID                          bigint
)

BEGIN

 /*******************************************************************************    
  * Practitioner_Patient_Scheduled_Service_Possible_New_From_Exp_Svcs_View_Core */    
 /**    
  * Generates possible new schedule entries from new expected service data
  ******************************************************************************/     

declare @ppcesData as table (
    patID            bigint
  , spEdServiceCode  int
  , startDate        date
  , endDate          date
  , previousPPCESID  bigint default(-1)
  , recordID         bigint
)

/*############################################################################
 *# Parse incoming expected service data
 *############################################################################*/

insert into @ppcesData (
    patID
  , spEdServiceCode
  , startDate
  , endDate
  , previousPPCESID
  , recordID
)
select 
    t1.patID
  , t1.spEdServiceCode
  , t1.startDate
  , t1.endDate
  , t1.previousPPCESID
  , t1.recordID
from openjson(@ppcesDataJSON)
with (
      patID                     bigint       '$."patID"'
    , spEdServiceCode           int          '$."spEdServiceCode"'
    , startDate                 date         '$."startDate"'
    , endDate                   date         '$."endDate"'
	, previousPPCESID           bigint       '$."previousPPCESID"'
	, recordID                  bigint       '$."recordID"'
) as t1

/*############################################################################
 *# Generate possible records
 *############################################################################*/

insert into @recs (
    clonedFromID
  , clonedStartDate
  , clonedEndDate
  
  , patID 
  , svcNamesListDataSourceID
  , viaTeleHealth
  , nameID 
  , recurring
  , practitionerPatientCaseloadExpectedServiceID
  , startDate
  , endDate
  , startTime
  , numMins
  , mon
  , monStartTime
  , tue   
  , tueStartTime
  , wed 
  , wedStartTime 
  , thu 
  , thuStartTime 
  , fri 
  , friStartTime 
)
select 
    clonedFromID    = ppssvl2.id
  , clonedStartDate = ppssvl2.startDate
  , clonedEndDate   = ppssvl2.endDate
  
  , ppssvl2.patID 
  , ppssvl2.svcNamesListDataSourceID
  , ppssvl2.viaTeleHealth
  , ppssvl2.nameID 
  , ppssvl2.recurring
  , practitionerPatientCaseloadExpectedServiceID = ppces.recordID
  , ppces.startDate
  , ppces.endDate
  , ppssvl2.startTime
  , ppssvl2.numMins
  , ppssvl2.mon
  , ppssvl2.monStartTime
  , ppssvl2.tue   
  , ppssvl2.tueStartTime
  , ppssvl2.wed 
  , ppssvl2.wedStartTime 
  , ppssvl2.thu 
  , ppssvl2.thuStartTime 
  , ppssvl2.fri 
  , ppssvl2.friStartTime 
  
from @ppcesData as ppces
cross apply (
  
  /*-------------------------------
   * Get previous scheduled service
   * data for the previous ppces
   * row 
   *------------------------------*/
     
  select 
    ppss1.* 
  from dbo.Practitioner_Patient_Scheduled_Services as ppss1
  where ( 
        (ppss1.clientID = @clientID)
	and (ppss1.pracID   = @pracID)
	and (ppss1.patID    = ppces.patID)
	and (ppss1.practitionerPatientCaseloadExpectedServiceID = ppces.previousPPCESID)
    and (ppss1.active = 1)
  )
  
  
) as ppssvl2

/*############################################################################
 *# Identify possible duplicates by exact match.  These can be filtered out
 *# if needed by the caller.
 *############################################################################*/

update t1 
set 
    t1.possibleDup         = 1
  , t1.possibleDupRecordID = ppss2.id
from @recs as t1
cross apply (
  select 
    ppss1.id
  from dbo.Practitioner_Patient_Scheduled_Services as ppss1
  where (  
        (ppss1.clientID                  = @clientID)
    and (ppss1.pracID                    = @pracID)
    and (ppss1.patID                     = t1.patID)
    and (ppss1.startDate                 = t1.startDate)
    and (ppss1.endDate                   = t1.endDate)
    and (ppss1.svcNamesListDataSourceID  = t1.svcNamesListDataSourceID)
    and (ppss1.viaTeleHealth             = t1.viaTeleHealth)
    and (ppss1.nameID                    = t1.nameID)
    and (ppss1.numMins                   = t1.numMins)
    and (ppss1.mon                       = t1.mon)
    and (ppss1.tue                       = t1.tue)
    and (ppss1.wed                       = t1.wed)
    and (ppss1.thu                       = t1.thu)
    and (ppss1.fri                       = t1.fri)
	and (ppss1.active                    = 1)
	and (ppss1.endDate is not null)  /* Skipping open ended schedules */
  )
) as ppss2

/*############################################################################
 *# Return
 *############################################################################*/

return

END

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[Practitioner_Patient_Scheduled_Services_Possible_New_From_Exp_Svcs_View_Core] TO [webuser]
GO
