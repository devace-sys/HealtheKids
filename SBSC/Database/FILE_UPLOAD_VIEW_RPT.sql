USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOAD_VIEW_RPT') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOAD_VIEW_RPT
GO

/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOAD_VIEW_RPT] (
    @userID              BIGINT
  , @userGroup           INT  
  , @userRank            INT
  , @clientID            BIGINT
  , @uploadedOnStartDate DATETIME
  , @uploadedOnEndDate   DATETIME
  , @fileClass           BIGINT
  , @environmentID       BIGINT 
  , @active              BIT
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOAD_VIEW_RPT */
/**
 * Returns file upload data
 *
 * @return Table
 ***************************************************************************/ 
with
cte_p1
as
(
  select  
    fudrc2.*
  from dbo.FILE_UPLOADS as fu
  cross apply (
    select top 1 
      fudrc1.* 
   from dbo.FILE_UPLOAD_DATA_RECORD_CORE (@userID, @userGroup, @userRank, @environmentID, fu.id, 1, 1) as fudrc1  
) as fudrc2

where ( 
       (1=1) 
  and ((@clientID            is null) or (fu.clientID         = @clientID))
  and ((@uploadedOnStartDate is null) or (fu.fileUploaded    >= @uploadedOnStartDate))
  and ((@uploadedOnEndDate   is null) or (fu.fileUploaded    <= @uploadedOnEndDate))
  and ((@fileClass           is null) or (fu.fileClass        = @fileClass))
  and ((@active              is null) or (fu.active           = @active))
  and (fu.isConfidentialPracticeFile = 0) /* Non confidential files only */
)

)

select top (dbo.CONST_MAX_ROWS())
  p1.* 
from cte_p1 as p1
order by 
     p1.clientName
   , p1.fileUploadedOn
)


GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOAD_VIEW_RPT] TO [webuser]
GO