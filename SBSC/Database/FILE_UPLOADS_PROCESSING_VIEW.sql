USE SPEDMON
GO

/*-------------------------------
 * Exists/Drop
 *------------------------------*/
 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('dbo.FILE_UPLOADS_PROCESSING_VIEW') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.FILE_UPLOADS_PROCESSING_VIEW
GO


/*-------------------------------
 * Object Definition
 *------------------------------*/
    
CREATE FUNCTION [dbo].[FILE_UPLOADS_PROCESSING_VIEW] (
     @userID            BIGINT   
   , @userGroup         INT  
   , @userRank          INT
   , @environmentID     BIGINT
)
RETURNS TABLE 
AS
RETURN 
(

/***************************************************************************
 * FILE_UPLOADS_PROCESSING_VIEW */
/**
 * Returns file uploads that are JUST waiting for processing
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
    from dbo.FILE_UPLOAD_DATA_RECORD_CORE (@userID , @userGroup, @userRank , @environmentID , fu.id, 0,0) as fudrc1  
  ) as fudrc2

  where ( (fu.processFile = 1) and (fu.active = 1))

)
select top 1000 /* Process in batches of 1000 */
  p1.* 
from cte_p1 as p1
order by 
   p1.processingPriority asc
  ,p1.id asc

)
GO

/*-------------------------------
 * User Permissions
 *------------------------------*/

GRANT SELECT ON  [dbo].[FILE_UPLOADS_PROCESSING_VIEW] TO [webuser]
GO
