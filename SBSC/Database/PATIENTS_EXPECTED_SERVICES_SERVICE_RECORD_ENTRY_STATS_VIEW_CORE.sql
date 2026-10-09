/*
 * ********* NOTE: THIS IS FOR IEP SERVICES ONLY **********
 */


USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE] (
   @clientID              BIGINT
 , @patID                 BIGINT
 , @pracGrpSvcClassNameID BIGINT
 , @svcTypeID             INT
 , @startDOS              DATETIME
 , @endDOS                DATETIME
) 

RETURNS TABLE

 /***************************************************************************    
   * PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE */    
 /**    
  * Returns a single record that contains various stats 
  *    
  * @return                 Table 
  ***************************************************************************/ 
  
AS RETURN( 

select
    clientID    = @clientID
  , patID       = @patID
  , svcTypeID   = @svcTypeID
  , startDOS    = @startDOS
  , endDOS      = @endDos
  , q2.*
from
(
  select
      totMinsRegular    = sum(q1.numMinsRegular)
    , totMinsPatAbsent  = sum(q1.numMinsPatAbsent)
    , totMinsPracAbsent = sum(q1.numMinsPracAbsent)
    , totMinsMakeup     = sum(q1.numMinsMakeup)
    , totRecsRegular    = sum(q1.numRecsRegular)
    , totRecsPatAbsent  = sum(q1.numRecsPatAbsent)
    , totRecsPracAbsent = sum(q1.numRecsPracAbsent)
    , totRecsMakeup     = sum(q1.numRecsMakeup)
  from
  (
    select 
         sr.patID
	   
	   /* Minute count */
	   
	   , numMinsRegular        = case when sra2.id = 0 then sr.numMins else 0 end 
       , numMinsPatAbsent      = case when sra2.id = 1 then sr.numMins else 0 end 
       , numMinsPracAbsent     = case when sra2.id = 2 then sr.numMins else 0 end 
       , numMinsMakeup         = case when sra2.id = 4 then sr.numMins else 0 end 
	   
	   /* Record count */
	   
	   , numRecsRegular        = convert(int,(case when sra2.id = 0 then 1 else 0 end))
       , numRecsPatAbsent      = convert(int,(case when sra2.id = 1 then 1 else 0 end))
       , numRecsPracAbsent     = convert(int,(case when sra2.id = 2 then 1 else 0 end))
       , numRecsMakeup         = convert(int,(case when sra2.id = 4 then 1 else 0 end))

    from dbo.SERVICE_RECORDS as sr 

    cross apply (
      select top 1
         sra1.id   
      from dbo.SERVICE_RECORD_ATTENDANCE_FLAGS_TO_SELECTION_ID_AND_NAME (sr.patAbsent, sr.pracAbsent, sr.makeupSession) as sra1
    ) as sra2

    where ( 
	      /* Uses index [CLIENT_PAT_GRP_FAM_SVCTYPE_IDX_W_ADD_COLS] */
          ((sr.clientID           = @clientID)
      and (sr.patID               = @patID)
      and (sr.pracGrpSvcClsNameID = @pracGrpSvcClassNameID)
      and (sr.svcType             = @svcTypeID)
      and (sr.dos between @startDOS and @endDOS)
	  and (sr.id is not null))
	  and (sr.isIFSPorIEP = 1)
	  and (sr.state not in (99,199))
    )
  ) as q1
  group by 
    q1.patID
) as q2

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENTS_EXPECTED_SERVICES_SERVICE_RECORD_ENTRY_STATS_VIEW_CORE] TO [webuser]
GO   
