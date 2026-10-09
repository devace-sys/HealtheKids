USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.CASELOAD_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.CASELOAD_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[CASELOAD_VIEW]    
(@userID     INT,    
 @userGroup  INT,    
 @userRank   INT,
 @clientID   INT,
 @pracID     INT,
 @active     BIT,
 @recID      INT)    

RETURNS TABLE

 /***************************************************************************    
  * CASELOAD_VIEW */    
 /**    
  * Returns a table of patients that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client    
  * @param  pracID          Practitioner ID for caseload
  * @param  inPracCaseLoad   In pracID's caseload
  * @param  lname           All or part of patients last name    
  * @param  fname           All or part of patients first name    
  * @param  dob             Patients dob    
  * @param  active          If patient is active    
  * @param  recID           Patient ID    
  * @return                 Table of patient data    
  ***************************************************************************/     
  
AS RETURN
(

 select 
   pp.[ID]                    as [id],   
   cc.CLIENT_NAME             as [clientName],
   isnull(pr.LAST_NAME,'') 
   + ', ' 
   + isnull(pr.FIRST_NAME,'') as [pracName],    
   pa.CONCAT_NAME             as [patName],   
   
   ppd.[START_DATE]           as [startDate],
   ppd.[END_DATE]             as [endDate],
   
   pps.[AsmtDueAnn],
   pps.[AsmtDueTriAnn],

   pps.[TmtEffectiveDate],
   
   dbo.RPT_TMT_SCHEDULE(pps.TmtFrqInd2,
                        pps.TmtDurInd2,
                        pps.TmtFrqGrp2,
                        pps.TmtDurGrp2,
     
                        pps.TmtFrqInd3,
                        pps.TmtDurInd3,
                        pps.TmtFrqGrp3,
                        pps.TmtDurGrp3,

                        pps.TmtFrqInd4,
                        pps.TmtDurInd4,
                        pps.TmtFrqGrp4,
                        pps.TmtDurGrp4,

                        pps.TmtFrqInd5,
                        pps.TmtDurInd5,
                        pps.TmtFrqGrp5,
                        pps.TmtDurGrp5,

                        pps.TmtFrqInd6,
                        pps.TmtDurInd6,
                        pps.TmtFrqGrp6,
                        pps.TmtDurGrp6) as [TmtSchedule],
     
   pps.[TmtFrqInd2],
   pps.[TmtDurInd2],
   pps.[TmtFrqGrp2],
   pps.[TmtDurGrp2],

   pps.[TmtFrqInd3],
   pps.[TmtDurInd3],
   pps.[TmtFrqGrp3],
   pps.[TmtDurGrp3],
      
   pps.[TmtFrqInd4],
   pps.[TmtDurInd4],
   pps.[TmtFrqGrp4],
   pps.[TmtDurGrp4],

   pps.[TmtFrqInd5],
   pps.[TmtDurInd5],
   pps.[TmtFrqGrp5],
   pps.[TmtDurGrp5],

   pps.[TmtFrqInd6],
   pps.[TmtDurInd6],
   pps.[TmtFrqGrp6],
   pps.[TmtDurGrp6],
      
   pps.[ID]                   as [pracPatSvcSchID],
   ppd.[ID]                   as [pracPatDateID],
   
   pp.[CLIENT_ID]             as [clientID], 
   pp.[PRACTITIONER_ID]       as [pracID], 
   pp.[PATIENT_ID]            as [patID]

 from PRACTITIONER_PATIENTS                  as pp
 join PRACTITIONER_PATIENTS_SERVICE_SCHEDULE as pps on pps.ID               = pp.CUR_PRAC_PAT_SVC_SCH_ID
 join PRACTITIONER_PATIENTS_DATES            as ppd on ppd.ID               = pp.CUR_PRAC_PAT_DATES_ID
 join PATIENTS_PATIENT                       as pa  on pa.PATIENT_ID        = pp.PATIENT_ID
 join PATIENTS_CLIENT                        as pac on pac.PATIENT_ID       = pa.PATIENT_ID
 join PRACTITIONER_Practitioner              as pr  on pr.PRACTITIONER_ID   = pp.PRACTITIONER_ID
 join PRACTITIONER_Client                    as prc on prc.PRACTITIONER_ID  = pr.PRACTITIONER_ID
 join CLIENTS_CLIENT                         as cc  on cc.CLIENT_ID         = pp.CLIENT_ID
 where 
   ((@clientID  is null)  or (pp.CLIENT_ID        = @clientID)) and 
   ((@pracID    is null)  or (pp.PRACTITIONER_ID  = @pracID))   and 
   ((@active    is null)  or (pp.ACTIVE           = @active))   and
   ((@recID     is null)  or (pp.ID               = @recID))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[CASELOAD_VIEW] TO [webuser]
GO
