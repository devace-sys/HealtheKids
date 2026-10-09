USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE] (
     @userID         BIGINT    
   , @userGroup      INT  
   , @userRank       INT
   , @uploadID       BIGINT
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE */
/**
 * Based on file class we return an effective upload date
 *
 * @return Table
 ***************************************************************************/ 

select top 1

    uploadID     
  , fileOffsetDays
  , effectiveUploadedOnDateTime = dateadd(day,fileOffsetDays,uploadedOnDate)

from (   

  select top 1
     uploadedOnDate 
    ,uploadID         = @uploadID       
    ,fileOffsetDays   =
   
    /*###########################################################################
      # Determine # of days to offset file upload effective date by based on
      # file class
      ###########################################################################*/    

    case (fileClassID) 
    
    /*============================================================
     * Work batches
     *============================================================*/

    when 1 then  

     /*--------------------------------------
      * If the file is sent on 
      *   a Friday after 12PM
      *   Saturday
      *   Sunday
      * The file is considered as being sent
      * on the following Monday
      *-------------------------------------*/
     
      case(uploadedOnWeekday)      
        when 6 then   /* Friday   */ case when uploadedAtHour >= 12 /* after 12 */ then 3 else /* Before 12 */ 0 end
        when 7 then 2 /* Saturday */
        when 1 then 1 /* Sunday   */
        else        0 /* Any other day */
    end

    /*============================================================
     * All other file classes
     *============================================================*/
     
    else 0 end  
  from (
    select top 1 
        uploadedOnDateTime
      , fileClassID
      , convert(date,uploadedOnDateTime)     as uploadedOnDate 
      , datepart(weekday,uploadedOnDateTime) as uploadedOnWeekday
      , datepart(hour, uploadedOnDateTime)   as uploadedAtHour
    from (
      select top 1 
	      fileClass as fileClassID
		, fileUploaded as uploadedOnDateTime 
       from dbo.FILE_UPLOADS as fued1 
	   where (fued1.id = @uploadID)
    ) as fued2
  ) as fued3
) as fued4

)

GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON [dbo].[FILE_UPLOAD_GENERATE_EFFECTIVE_UPLOAD_DATE] TO [webuser]
GO