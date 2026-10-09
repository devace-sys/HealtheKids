USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/

CREATE FUNCTION [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW]    
(@userID     INT,    
 @userGroup  INT,    
 @userRank   INT,
 @clientID   INT,
 @patID      INT,
 @pracID     INT,
 @active     BIT,
 @recID      INT)    

RETURNS TABLE

 /***************************************************************************    
  * ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW */    
 /**    
  * Returns a table of records that match the given parameters    
  *    
  * @param  clientID        Required.  ID of client    
  * @param  active          Active?   
  * @param  recID           Record ID    
  * @return                 Table of patient data    
  ***************************************************************************/     
  
AS RETURN
(
 select 
   aa.*,
   '1:1 ' + at.Value + ' SERVICES FOR ' + pa.CONCAT_NAME           as [name],
   isnull(aa.AideLastName,'') + ', ' + isnull(aa.AideFirstName,'') as [aideName],   
   cc.CLIENT_NAME             as [clientName],
   isnull(pr.CONCAT_NAME,'')  as [pracName],
   pa.CONCAT_NAME             as [patName], 
   ss.SITE_NAME               as [siteName],
   pa.DATE_OF_BIRTH           as [dob],
   at.Name                    as [oneOnOneAideTypeName],
   fy.FY_DEFINITION           as [fiscalYear],
   sh.name                    as [scheduleName],
   ac.name                    as [calendarName]
 from ONE_ON_ONE_AIDE_ASSIGNMENT      as aa
 join CLIENTS_CLIENT                  as cc  on cc.CLIENT_ID        = aa.clientID
 join PATIENTS_PATIENT                as pa  on pa.PATIENT_ID       = aa.patID
 join ONE_ON_ONE_AIDE_TYPES_VIEW()    as at  on at.Value            = aa.oneOnOneAideType
 left join PRACTITIONER_Practitioner  as pr  on pr.PRACTITIONER_ID  = aa.pracID
 left join dbo.SITES_Site             as ss  on ss.SITE_ID          = aa.siteID
 left join COMPANY_FISCAL_YEARS       as fy  on aa.fiscalYearID     = fy.ID 
 left join CLIENT_ATTENDANCE_CALENDAR as ac  on aa.calendarID       = ac.ID
 left join CLIENT_ATTENDANCE_SCHEDULE as sh  on sh.ID               = aa.scheduleID
 where
   (1=1) and
   ((@clientID  is null)  or (aa.clientID       = @clientID)) and
   ((@patID     is null)  or (aa.patID          = @patID))    and 
   ((@pracID    is null)  or (aa.pracID         = @pracID))   and 
   ((@active    is null)  or (aa.active         = @active))   and
   ((@recID     is null)  or (aa.id             = @recID))
)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[ONE_ON_ONE_AIDE_ASSIGNMENT_VIEW] TO [webuser]
GO
