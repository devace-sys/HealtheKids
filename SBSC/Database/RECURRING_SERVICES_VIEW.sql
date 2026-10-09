USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.RECURRING_SERVICES_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.RECURRING_SERVICES_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
 
CREATE FUNCTION [dbo].[RECURRING_SERVICES_VIEW]    
(@userID         BIGINT,    
 @userGroup      INT,    
 @userRank       INT, 
 @clientID       INT, 
 @patID          INT,
 @fiscalYearID   INT,
 @startDate      DATETIME,
 @endDate        DATETIME,
 @active         BIT,
 @recID          BIGINT
)    

RETURNS TABLE
 
 /***************************************************************************    
  * RECURRING_SERVICES_VIEW */    
 /**    
  * Returns list of recurring services records
  *
  * @return table 
  ***************************************************************************/                         
     
AS RETURN
(
  select 
    rs.*,
    convert(varchar(10), rs.startDate,     101)   as startDateStr,
    convert(varchar(10), rs.endDate,       101)   as endDateStr,
    convert(varchar(10), rs.effectiveDate, 101)   as effectiveDateStr,
    cc.CLIENT_NAME       as clientName, 
    pp.CONCAT_NAME       as patientName,
    fy.FY_DEFINITION     as fiscalYearName, 
    isnull(acal.name,'') as calendarName,    
    isnull(asch.name,'') as scheduleName,        
    ppids.pracIDsStr,
    ppnames.pracNamesStr,
    pptitles.pracTitlesStr,
    rsdprac.detailsPracsStr,
    rsdtmtbs.detailsTmtBSStr,
    rsdtmtdsind.detailsTmtDSIndStr,
    rsdtmtdsgrp.detailsTmtDSGrpStr,
    rsdtmtas.detailsTmtASStr,
    rsdtranhmss.detailsTransHmSsStr,
    rsdtransshm.detailsTransSsHmStr,
    rsdtranssos.detailsTransSsOsStr,
    rsdtranosss.detailsTransOsSsStr
    
  from RECURRING_SERVICES as rs
  
  /*============================================================
   * Client and patient names
   *============================================================*/  

  join CLIENTS_CLIENT       as cc  on cc.CLIENT_ID  = rs.clientID
  join PATIENTS_PATIENT     as pp  on pp.PATIENT_ID = rs.patID 
  
  /*============================================================
   * Fiscal year name
   *============================================================*/  
  
  join COMPANY_FISCAL_YEARS as fy on fy.id = rs.fiscalYearID
  
  /*============================================================
   * Calendar and bell schedule names (optional)
   *============================================================*/  
  
  left join CLIENT_ATTENDANCE_CALENDAR as acal on acal.id = rs.calendarID
  left join CLIENT_ATTENDANCE_SCHEDULE as asch on asch.id = rs.scheduleID
    
  /*============================================================
   * Practitioner ids (delimited string)
   *============================================================*/  
 
  cross apply(      
    select PracIDsStr
    from 
    (
      SELECT SUBSTRING(
        (SELECT ',' + s.PracIDStr
         FROM 
         (
           select convert(varchar(500),pracID) pracIDStr from dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC(@userID,@userGroup,@userRank,rs.id)
         ) as s       
         FOR XML PATH(''))
       ,2,200000) as [pracIDsStr]
     ) as s1
  ) as ppids

  /*============================================================
   * Practitioner names (delimited string)
   *============================================================*/  
 
  cross apply(      
   select PracNamesStr
  from 
  (
    SELECT SUBSTRING(
      (SELECT '|' + s.PracName
       FROM 
       (
         select pracName from dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC(@userID,@userGroup,@userRank,rs.id)
       ) as s       
       FOR XML PATH(''))
     ,2,200000) as [pracNamesStr]
   ) as s1
  ) as ppnames

  /*============================================================
   * Practitioner titles (delimited string)
   *============================================================*/  
     
  cross apply(      
    select PracTitlesStr
    from 
    (
      SELECT SUBSTRING(
        (SELECT '|' + s.PracTitle
         FROM 
         (
           select pracTitle from dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC(@userID,@userGroup,@userRank,rs.id)
         ) as s       
         FOR XML PATH(''))
       ,2,200000) as [pracTitlesStr]
     ) as s1
   ) as pptitles

  /*============================================================
   * Practitioner details (JSON string)
   *============================================================*/  
    
  cross apply(
    select details as [detailsPracsStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_PRAC_JSON(@userID,@userGroup,@userRank,rs.id)
  ) as rsdprac
 
  /*============================================================
   * Treatment Details - Before School
   *============================================================*/  

  outer apply(
    select details as [detailsTmtBSStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MIN_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TMT_WHEN_BS(), dbo.CONST_SERVICES_TMT_HOW_IND(),'details_tmt_bs')
  ) as rsdtmtbs

  /*============================================================
   * Treatment Details - During School - Individual
   *============================================================*/  

  outer apply(
    select details as [detailsTmtDSIndStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TMT_WHEN_DS(), dbo.CONST_SERVICES_TMT_HOW_IND(),'details_tmt_ds_ind')
  ) as rsdtmtdsind

  /*============================================================
   * Treatment Details - During School - Group
   *============================================================*/  

  outer apply(
    select details as [detailsTmtDSGrpStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_SCH_OR_MIN_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TMT_WHEN_DS(), dbo.CONST_SERVICES_TMT_HOW_GRP(),'details_tmt_ds_grp')
  ) as rsdtmtdsgrp


  /*============================================================
   * Treatment Details - After School
   *============================================================*/  

  outer apply(
    select details as [detailsTmtASStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MIN_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TMT_WHEN_AS(), dbo.CONST_SERVICES_TMT_HOW_IND(),'details_tmt_as')
  ) as rsdtmtas

  /*============================================================
   * Transportation Details - Home to School 
   *============================================================*/  

  outer apply(
    select details as [detailsTransHmSsStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TRANS_LOCATION_HOME(), dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(),'details_trans_hm_ss')
  ) as rsdtranhmss
  
  /*============================================================
   * Transportation Details - School to Home 
   *============================================================*/  

  outer apply(
    select details as [detailsTransSsHmStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(), dbo.CONST_SERVICES_TRANS_LOCATION_HOME(),'details_trans_ss_hm')
  ) as rsdtransshm

  /*============================================================
   * Transportation Details - School to Offsite Treatment
   *============================================================*/  

  outer apply(
    select details as [detailsTransSsOsStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(), dbo.CONST_SERVICES_TRANS_LOCATION_OFFSITE(),'details_trans_ss_os')
  ) as rsdtranssos

  /*============================================================
   * Transportation Details - Offsite Treatment to School
   *============================================================*/  

  outer apply(
    select details as [detailsTransOsSsStr] 
    from dbo.RECURRING_SERVICES_VIEW_DETAILS_SVC_MILE_BASED_JSON(@userID, @userGroup, @userRank, rs.id, dbo.CONST_SERVICES_TRANS_LOCATION_OFFSITE(), dbo.CONST_SERVICES_TRANS_LOCATION_SCHOOL(),'details_trans_os_ss')
  ) as rsdtranosss

  where (1=1)
    and ((@clientid     is null) or (rs.clientID     = @clientID))
    and ((@patid        is null) or (rs.patID        = @patID))
    and ((@fiscalYearID is null) or (rs.fiscalYearID = @fiscalYearID))
    and ((@startDate    is null) or (rs.startDate   >= @startDate))
    and ((@endDate      is null) or (rs.endDate     <= @endDate))
    and ((@recID        is null) or (rs.id           = @recID))
    and ((@active       is null) or (rs.active       = @active))

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[RECURRING_SERVICES_VIEW] TO [webuser]
GO   
