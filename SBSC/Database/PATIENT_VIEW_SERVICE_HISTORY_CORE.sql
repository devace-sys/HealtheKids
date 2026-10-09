USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.PATIENT_VIEW_SERVICE_HISTORY_CORE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.PATIENT_VIEW_SERVICE_HISTORY_CORE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[PATIENT_VIEW_SERVICE_HISTORY_CORE]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT,     
 @clientID       INT,
 @patID          INT,
 @nameID         INT,
 @startDOS       DATETIME,
 @endDOS         DATETIME
)    

RETURNS TABLE
 
 /***************************************************************************    
  * PATIENT_VIEW_SERVICE_HISTORY_CORE */    
 /**    
  * Returns service history for a given patient and date range. 
  * Service (nameID) is optional.
  *    
  * @param  clientID      Client id
  * @param  patID         Patient id
  * @param  nameID        Service
  * @param  startDOS      Start date
  * @param  endDOS        End date
  * @return               Table 
  ***************************************************************************/                         

AS RETURN
(
  select
    [id],
    [dos],  

    /*-------------------------------
     * Create report friendly
     * dos column
     *------------------------------*/
    
    dbo.RPT_DATE_FMT(dos) as [DOSFmt],  
    
    [Patient],
    [Practitioner],
    [Service],
    [numMins],
    [tripsMiles],
    
    /*-------------------------------
     * Create report friendly
     * combined minutes or trips/miles
     * column.
     *
     * Content of this column is based
     * on service type
     *------------------------------*/
    
    case [svcType]
      when dbo.CONST_SERVICES_TRANSPORT() then tripsMiles     
      else CONVERT(VARCHAR(20), numMins)      
    end as [numMins_tripsMiles],
   
    [Procedure 1],
    [Procedure 2],
        
    [Reference],
    [clientID],
    [pracID],
    [patID],
    [nameID1],
    [nameID2],
    [claimID1],
    [claimID2],
    [procID1],
    [procID2] 
  from
  (
    select distinct /* Note: Distinct is neccessary to remove unwanted combos */
    
      sr.id,
      sr.dos,
      pp.CONCAT_NAME    as [Patient],
      pr.CONCAT_NAME    as [Practitioner],
      sva1.svc_name     as [Service],
      sr.svcType,    
      sr.numMins,
      
      /*-------------------------------
       * Create report friendly 
       * trips/miles column
       *------------------------------*/

      dbo.RPT_TRIPS_MILES
        (sr.svcType,    
         sr.trip1Start,    
         sr.trip1End,    
         sr.trip2Start,    
         sr.trip2End,    
         sr.trip3Start,    
         sr.trip3End,    
         sr.trip4Start,    
         sr.trip4End) AS tripsMiles,    
         
      /*-------------------------------
       * Create report friendly 
       * proc mod combo columns for
       * procedures 1 and 2
       *------------------------------*/
        
      dbo.RPT_PROC_MOD_COMBO
        (sva1.proc_code, 
         sva1.proc_mod1, 
         sva1.proc_mod2, 
         sva1.proc_mod3,
         sva1.proc_mod4)         as [Procedure 1],
                            
      dbo.RPT_PROC_MOD_COMBO
        (sva2.proc_code, 
         sva2.proc_mod1, 
         sva2.proc_mod2, 
         sva2.proc_mod3,
         sva2.proc_mod4)         as [Procedure 2],
       
      sr.reference               as [Reference],
    
      sr.clientID,
      sr.pracID,
      sr.patID,
      
      sva1.name_id     as nameID1,
      sva2.name_id     as nameID2,
      sr.claimID1      as claimID1,
      sr.claimID2      as claimID2,
      cc1.PROCEDURE_ID as procID1,
      cc2.PROCEDURE_ID as procID2 
                             
    from SERVICE_RECORDS as sr 

    join PRACTITIONER_Practitioner as pr    on  (pr.PRACTITIONER_ID  = sr.pracID)  
    join PATIENTS_Patient          as pp    on  (pp.PATIENT_ID)      = sr.patID
    join CLAIM_Claim               as cc1   on  (cc1.CLAIM_ID        = sr.claimID1)                             
    join SERVICES_VIEW_ALL()       as sva1  on  (sva1.proc_id        = cc1.PROCEDURE_ID)
    left join CLAIM_Claim          as cc2   on  (cc2.CLAIM_ID        = sr.claimID2)
    left join SERVICES_VIEW_ALL()  as sva2  on  (sva2.proc_id        = cc2.PROCEDURE_ID)
  
    where 
    
      sr.clientID = @clientID                   and
      sr.state <> dbo.CONST_SVC_REC_STATE_DEL() and /* Exclude deleted services */
      sr.state <> dbo.CONST_SVC_REC_STATE_CIF() and /* Exclude CIFd services */
      sr.patID = @patID                         and
      (sr.dos between @startDOS and @endDOS)    and
     ((@nameID is null) or (sr.nameID = @nameID))
   ) as q1
)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[PATIENT_VIEW_SERVICE_HISTORY_CORE] TO [webuser]
GO   
