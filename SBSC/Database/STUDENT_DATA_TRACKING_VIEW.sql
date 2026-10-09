USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.STUDENT_DATA_TRACKING_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.STUDENT_DATA_TRACKING_VIEW
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[STUDENT_DATA_TRACKING_VIEW](    
 
  @recID       BIGINT,    
  @clientID    BIGINT,
  @fileTypeID  INT,
  @quarter     INT,
  @fiscalYear  INT,
  @requestedBy BIGINT,
  @canEdit     BIT,
  @active      BIT)    
 
RETURNS TABLE      

/***************************************************************************    
 * STUDENT_DATA_TRACKING_VIEW */    
/**    
 * Returns a table of STUDENT_DATA_TRACKING RECORDS that match the given parameters.    
 * Each client has one or more student data files.      
 *    
 * @param  clientID        ID of client    
 * @param  fileTypeID      ID of file Type
 * @param  quarter         
 * @param  canEdit         If record can be edited by userID  
 * @param  recID           Student data file ID    
 * @return                 Table of Client student data files    
 ***************************************************************************/     
AS RETURN(      
    
/*-------------------------------    
 * Retrieve records   
 *------------------------------*/  
  
  select top (dbo.CONST_MAX_ROWS()) *
  from
  (
   select 
          cr.first_name +', '+cr.last_name  as [REP],
          c.NPI,
          c.CLIENT_CDS                      as [SCHMEDID],                                    
          CASE when ISNULL(c.MAA,0) = 0
		      then 'no'
		      else 'yes' end	            as [MAA?], 
          c.CLIENT_ID,
          c.ShortName                       as [CLIENT_SHORTNAME],    
          ft.TYPE_NAME                      as [DATA_TYPE],
          fy.FY_DEFINITION +' - Q'+ CONVERT(VARCHAR(2),sdt.QUARTER)
                                            as [Qtr],
          co.name                           as [COMPANY_REQUESTING],  
          sdt.DATE_REQUESTED                as [DATE_REQUESTED], 
          u2.name                           as [REQUESTED_BY],
          sdt.DATE_FOLLOWED_UP              as [DATE_FOLLOWED_UP], 
          sdt.DATE_NOTIFIED_REP             as [DATE_NOTIFIED_REP], 
          sdt.DATE_RECEIVED                 as [DATE_RECEIVED], 
          sdt.WHO_PREPARED_TXTfile          as [WHO_PREPARED_TXTfile], 
          sdt.DATE_PUT_IN_FOLDERS           as [DATE_PUT_IN_FOLDERS], 
          pf.Upload_Date                    as [Date_uploaded data into SPEDMON],
          ps.DATE_CREATED                   as [Date Part "B.Build DHS File.sql" Executed], 
          sdt.Nel2DHS_FILENAME              as [DHS_FILENAME], 
          sdt.DATE_SENT_TO_DHS              as [DATE_SENT_TO_DHS], 
          sdt.DATE_RECEIVED_DHS             as [DATE_RECEIVED_DHS], 
          ps.DATE_RETURNED                  as [Date Put into SBSCSQL2-import-export-fromdhs folder],  
          sdt.WHO_MOVED_TXTnMED_FILES       as [WHO_MOVED_TXTnMED_FILES], 
          sdt.DATE_MOVED_CL_FOLDERS         as [DATE_MOVED_CL_FOLDERS],  
          cc.CONTACT_FIRST_NAME + ', ' + cc.CONTACT_LAST_NAME 
                                            as [CONTACT NAME],
          cc.EMAIL                          as [CONTACT EMAIL],
          cc.SECONDARY_CONTACT_EMAIL        as [SECONDARY_CONTACT_EMAIL],
          c.CLIENT_NAME                     as [District_Full_ Name], 
          sdt.NOTES,                                                                                         
          fy.FY_DEFINITION                  as [FISCAL_YEAR],
          sdt.QUARTER                       as [QUARTER],
          sdt.ACTIVE,   
          cc.CONTACT_FIRST_NAME,
          cc.CONTACT_LAST_NAME,
          sdt.id,
          sdt.FILE_TYPE_ID,
          sdt.POPULATION_FILE_ID, 
          sdt.FISCAL_YEAR                   as [FISCAL_YEAR_ID],
          u.username                        as [CLIENT_REP_EMAIL],
          cr.first_name                     as [CLIENT_REP_FIRST_NAME],
          df.REQUESTED_BY                   as [RequestedUserID]
  from dbo.STUDENT_DATA_TRACKING as sdt
  left join dbo.CLIENTS_Client              as c  on c.CLIENT_ID           = sdt.CLIENT_ID
  left join dbo.CLIENTS_Client_Reps         as cr on cr.id                 = c.ClientRepIDLEACurrent
  left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)  
                                            as u  on  u.ID                 = cr.user_id
  left join dbo.STUDENT_DATA_FILE_TYPES     as ft on ft.id                 = sdt.FILE_TYPE_ID
                                                  and ft.ACTIVE            = 1
  left join dbo.CLIENT_STUDENT_DATA_FILES   as df on df.CLIENT_ID          = sdt.CLIENT_ID
                                                 and df.FILE_TYPE_ID       = sdt.FILE_TYPE_ID
                                                 and df.ACTIVE             = 1
  left join users.dbo.USERS_DATA_CORE(users.dbo.CONST_APP_NAME_SPEDCARE(),null,null,null,null)  
                                            as u2  on  u2.ID               = df.REQUESTED_BY
  left join dbo.COMPANIES                   as co on co.id                 = df.COMPANY_ID                                       
  left join dbo.CLIENT_STUDENT_DATA_CONTACT as cc on cc.CLIENT_ID          = sdt.CLIENT_ID
                                                 and cc.FILE_TYPE_ID       = sdt.FILE_TYPE_ID
  left join dbo.Population_Files            as pf on pf.File_ID            = sdt.POPULATION_FILE_ID
  left join dbo.PATIENTS_StudentData_FileID as ps on ps.Population_File_ID = sdt.POPULATION_FILE_ID
  left join dbo.COMPANY_FISCAL_YEARS        as fy on fy.ID                 = sdt.FISCAL_YEAR
  ) as sdtr
  where   ((@recID       is null) or (sdtr.id              = @recID))      and
          ((@clientID    is null) or (sdtr.CLIENT_ID       = @clientID))   and
          ((@fileTypeID  is null) or (sdtr.FILE_TYPE_ID    = @fileTypeID)) and
          ((@fiscalYear  is null) or (sdtr.FISCAL_YEAR_ID  = @fiscalYear)) and
          ((@quarter     is null) or (sdtr.QUARTER         = @quarter))    and
          ((@requestedBy is null) or (sdtr.RequestedUserID = @requestedBy))and
          ((@active      is null) or (sdtr.ACTIVE          = @active))
          

 
  order by CLIENT_SHORTNAME
)
  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[STUDENT_DATA_TRACKING_VIEW] TO [webuser]
GO
