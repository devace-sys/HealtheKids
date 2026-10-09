USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE] (
    @userID              as   bigint
  , @userGroup           as   int  
  , @userRank            as   int    
  , @clientID            as   bigint
  , @groupSvcClassNameID as   bigint
  , @pracID              as   bigint
  , @patID               as   bigint
  , @refDate             as   date
)    
returns table     
as    
    
/***************************************************************************    
 * SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE */    
/**    
 *     
 * @param  userID          User ID (Required)    
 * @param  userGroup       User group (Required)    
 * @param  userRank        User rank (Required)    
 * @return                 Service records and svc notes
 * TODO: Setup sharing
 ***************************************************************************/     
    
return (    

  select top 100

    [Date of Service]   = dbo.RPT_DATE_FMT(sr.dos)
  --, [Patient Absent]    = dbo.BIT_TO_YN(sr.patAbsent)
  , [Attendance Status] = sr.attendanceStatusSelectionName
  , [Service Rendered]  = sr.SVC_NAME
  , [Rendered By]       = sr.PR_CONCAT_NAME 
  , [Number of Minutes] = sr.numMins
  --, [Notes]             = sr.notes
  , [Notes]             = sr.svcNotesFormBuilderTextAndNotes

  from dbo.SERVICE_RECORDS_DATA_CORE (
	@userID
  , @clientID
  , @groupSvcClassNameID
  , @pracID
  , @patID 
  , null
  , dbo.CONST_MIN_DATETIME()
  , dbo.DATE_END(@refDate)  
  , null
  , null
  , null   
  , null  ) as sr
  
  order by 

    sr.dos desc
  , sr.id  desc
)  
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/
 
GRANT SELECT ON  [dbo].[SERVICE_RECORDS_NOTES_VIEW_LAST_AS_OF_REF_DATE] TO [webuser]
GO